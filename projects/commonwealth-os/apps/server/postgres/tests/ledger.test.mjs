import test from 'node:test';import assert from 'node:assert/strict';
import {readFileSync,mkdtempSync,rmSync} from 'node:fs';import {fileURLToPath} from 'node:url';import {dirname,resolve,join} from 'node:path';
import {createRequire} from 'node:module';
const require=createRequire(import.meta.url);
const {Pool}=require('pg');
import {PostgresLedger} from '../ledger.mjs';
import {verifyPgLedger,verifySignedPgEnvelope} from '../verify-ledger.mjs';
import {signingKey,exportEvidence} from '../../src/evidence.mjs';
import {createPublicKey} from 'node:crypto';import {tmpdir} from 'node:os';
const here=dirname(fileURLToPath(import.meta.url));
const adminUrl=process.env.CWOS_POSTGRES_TEST_URL;
if(!adminUrl)throw Error('CWOS_POSTGRES_TEST_URL_REQUIRED; do not run this suite against real databases');
const admin=new Pool({connectionString:adminUrl,max:2});
const appUrl=new URL(adminUrl);appUrl.username='cwos_test_app';appUrl.password='cwos-test-only';
const app=new Pool({connectionString:appUrl.href,max:4});
const tenantA='union-fixture',tenantB='student-fixture';
let number=0;const key=()=>`pg-test-${++number}-operation`;
function cmd(ledger,institutionId,itemId,actorId,action,expectedVersion,payload={},oldKey=key()){
 return ledger.applySyntheticCommand({institutionId,itemId,actorId,action,expectedVersion,payload,key:oldKey});
}
const policy={quorum:2,yesNumerator:1,yesDenominator:2,strict:true};
const actors=[{id:'member-a',role:'member',eligible:true},{id:'member-b',role:'member',eligible:true},{id:'chair',role:'chair',eligible:false},{id:'clerk',role:'clerk',eligible:false},{id:'admin',role:'admin',eligible:false}];
const ledger=new PostgresLedger(app);
await test('trusted migration owner creates schema and non-owner RLS role',async()=>{
 const migrations=readFileSync(resolve(here,'../001_ledger.sql'),'utf8');
 await admin.query(migrations);
 await admin.query("CREATE ROLE cwos_test_app LOGIN PASSWORD 'cwos-test-only' NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS");
 await admin.query('GRANT CONNECT ON DATABASE cwos_test TO cwos_test_app');
 await admin.query('GRANT USAGE ON SCHEMA cwos TO cwos_test_app');
 for(const table of ['institutions','actors','policies','items','revisions','events','authority_events','attendance','rollcall_votes','requests','sources','source_links','projections','publication_approvals']){
  await admin.query(`GRANT SELECT,INSERT,UPDATE,DELETE ON cwos.${table} TO cwos_test_app`);
 }
 const grants=await admin.query("SELECT rolbypassrls,rolsuper FROM pg_roles WHERE rolname='cwos_test_app'");
 assert.deepEqual([grants.rows[0].rolbypassrls,grants.rows[0].rolsuper],[false,false]);
});
await test('tenant-scoped persistent end-to-end synthetic rollcall and independent replay',async()=>{
 await ledger.bootstrapSyntheticInstitution({institutionId:tenantA,name:'Fictional union',policy,actors});
 await ledger.bootstrapSyntheticInstitution({institutionId:tenantB,name:'Fictional student council',policy,actors});
 const id='procedural-motion';
 const trace=[['member-a','CREATE',0,{body:'Fictional governance motion'}],['member-a','SUBMIT',1,{}],['chair','AGENDA',2,{}],['chair','BEGIN',3,{}],['clerk','ATTEND',4,{attendees:['member-a','member-b']}],['chair','LOCK',5,{}],['chair','OPEN',6,{}],['member-a','CAST',7,{choice:'yes'}],['member-b','CAST',8,{choice:'yes'}],['chair','CLOSE',9,{}],['clerk','REVIEW',10,{}]];
 for(const [actor,action,version,payload] of trace){const r=await cmd(ledger,tenantA,id,actor,action,version,payload);assert.equal(r.version,version+1);}
 const proof=await ledger.readEvidence(tenantA,id);assert.equal(verifyPgLedger(proof).ok,true);assert.equal(proof.item.outcome,'SUPPORTED_IN_SIMULATION');
 const d=mkdtempSync(join(tmpdir(),'cwos-pg-sign-'));try {
  const key=signingKey(join(d,'demo.pem'));
  const pinned=createPublicKey(key).export({format:'pem',type:'spki'}).toString();
  const signed=exportEvidence(proof,key);
  assert.equal(verifySignedPgEnvelope(signed,{trustedPublicKeyPem:pinned}).ok,true);
  const falsified=structuredClone(signed);falsified.payload.events[7].details.choice='no';
  assert.throws(()=>verifySignedPgEnvelope(falsified,{trustedPublicKeyPem:pinned}),/PG_REPLAY_SIGNATURE/);
  assert.throws(()=>verifySignedPgEnvelope(signed,{trustedPublicKeyPem:'wrong'}),/PG_REPLAY_PIN_MISMATCH/);
 }finally{rmSync(d,{force:true,recursive:true});}
 assert.equal(proof.events.length,11);
 const bad=structuredClone(proof);bad.events[7].details.choice='no';assert.throws(()=>verifyPgLedger(bad),/PG_REPLAY_HASH/);
});
await test('idempotency and rejection leave commit position unchanged',async()=>{
 const id='second-motion';const k=key();
 const first=await cmd(ledger,tenantA,id,'member-a','CREATE',0,{body:'Synthetic proposal'},k);
 const repeated=await cmd(ledger,tenantA,id,'member-a','CREATE',0,{body:'Synthetic proposal'},k);
 assert.deepEqual(first,repeated);
 await assert.rejects(()=>cmd(ledger,tenantA,id,'member-a','CREATE',0,{body:'changed'},k),/IDEMPOTENCY_CONFLICT/);
 await assert.rejects(()=>cmd(ledger,tenantA,id,'clerk','SUBMIT',1),/FORBIDDEN_ROLE/);
 const evidence=await ledger.readEvidence(tenantA,id);assert.equal(evidence.events.length,1);
});
await test('RLS excludes wrong-tenant records even with table SELECT privileges',async()=>{
 const c=await app.connect();try{
  await c.query('BEGIN');await c.query("SELECT set_config('app.tenant_id',$1,true)",[tenantB]);
  const r=await c.query('SELECT item_id FROM cwos.items WHERE institution_id=$1',[tenantA]);assert.equal(r.rows.length,0);
  const change=await c.query('UPDATE cwos.items SET state=$1 WHERE institution_id=$2',["PUBLISHED",tenantA]);assert.equal(change.rowCount,0);
  await c.query('ROLLBACK');
 }finally{c.release();}
});
await test('immutability triggers block revision and event edits; sealed vault unavailable',async()=>{
 await assert.rejects(()=>ledger.withTenantTx(tenantA,c=>c.query("UPDATE cwos.revisions SET body='rewritten' WHERE item_id='procedural-motion'")),/IMMUTABLE_LEDGER_RECORD/);
 await assert.rejects(()=>ledger.withTenantTx(tenantA,c=>c.query("DELETE FROM cwos.events WHERE item_id='procedural-motion'")),/IMMUTABLE_LEDGER_RECORD/);
 const c=await app.connect();try{await assert.rejects(()=>c.query('SELECT * FROM cwos_ballot_vault.sealed_ballot'),/permission denied/);}finally{c.release();}
});
await test('institution policy and membership epoch changes fail closed and are independently visible',async()=>{
 const id='stale-decision';
 for(const [actor,action,version,payload] of [['member-a','CREATE',0,{body:'Fictional policy'}],['member-a','SUBMIT',1,{}],['chair','AGENDA',2,{}],['chair','BEGIN',3,{}],['clerk','ATTEND',4,{attendees:['member-a','member-b']}],['chair','LOCK',5,{}],['chair','OPEN',6,{}]]){
  await cmd(ledger,tenantA,id,actor,action,version,payload);
 }
 const before=await ledger.readEvidence(tenantA,id);assert.equal(verifyPgLedger(before).authorityStatus,'UNCHANGED');
 await ledger.updatePolicy({institutionId:tenantA,adminId:'admin',policy:{...policy,quorum:3}});
 const after=await ledger.readEvidence(tenantA,id);assert.equal(verifyPgLedger(after).authorityStatus,'RECHECK_REQUIRED');
 await assert.rejects(()=>cmd(ledger,tenantA,id,'member-a','CAST',7,{choice:'yes'}),/AUTHORITY_CHANGED/);
 const changed=await ledger.updateMemberEligibility({institutionId:tenantA,adminId:'admin',memberId:'member-b',eligible:false});assert.ok(changed.eligibilityVersion>before.institution.eligibility_version);
 await assert.rejects(()=>cmd(ledger,tenantA,id,'member-a','CAST',7,{choice:'yes'}),/AUTHORITY_CHANGED/);
 assert.equal(verifyPgLedger(await ledger.readEvidence(tenantA,id)).authorityStatus,'RECHECK_REQUIRED');
});
await test('wrong-tenant and missing active actor are denied by the adapter',async()=>{
 await assert.rejects(()=>cmd(ledger,tenantB,'procedural-motion','unlisted','CREATE',0,{body:'bad'}),/INACTIVE_ACTOR/);
 const r=await ledger.readEvidence(tenantA,'procedural-motion');assert.equal(r.events.length,11);
});
await app.end();await admin.end();
