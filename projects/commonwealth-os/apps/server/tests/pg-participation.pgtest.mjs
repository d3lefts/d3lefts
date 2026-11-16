// PostgreSQL + legacy SQLite parity / security / migration experiment.
// Requires a dedicated EPHEMERAL PostgreSQL database; destructive test data.
import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, rmSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { tmpdir } from 'node:os';
import { createHash, createPublicKey } from 'node:crypto';
import { Store } from '../src/store.mjs';
import { ParticipationLedger } from '../src/participation.mjs';
import { PgParticipationStore } from '../src/pg-participation.mjs';
import { signingKey, exportEvidence } from '../src/evidence.mjs';
import { verifyExternalCheckpoint } from '../verify-pg-anchor.mjs';
import { verifyPgAnchoredPrefix } from '../verify-pg-ledger-anchor.mjs';
import { createPgServer } from '../src/pg-http.mjs';

const digest=bytes=>createHash('sha256').update(bytes).digest('hex');
const tenants=['student-demo','union-demo','municipal-demo'];
const policy={quorum:2,yesNumerator:1,yesDenominator:2,strict:false};
const reason='A documented and fictional review rationale for this change.';
const correction='Private correction concerning an unverified source statement.';
const amendment={type:'AMEND',id:'P-UAH-01',text:'Evaluate a fictional campus shuttle with a published accessibility and cost review.',reason:'Make the scope testable'};
const command=(tenant,command,key,seq,revision)=>({institutionId:tenant,command,key,expectedSequence:seq,expectedRevision:revision});
const scope='student-demo';
async function checkReject(p,pattern){await assert.rejects(p,pattern);}

test('cold migration, PostgreSQL durability, concurrent writers, AEAD tamper detection, private data and signed checkpoint',async()=>{
  const dir=mkdtempSync(join(tmpdir(),'cw-pg-migration-'));
  const srcFile=join(dir,'cold.sqlite');
  const sqlite=new Store(srcFile);
  const tokens={};
  try{
    // Construct an independently verifiable original SQLite v1.3 journal.
    const legacy=new ParticipationLedger(sqlite);
    for(const tenant of tenants){
      sqlite.provisionInstitution(tenant,'Fictional '+tenant,policy);
      tokens[tenant]={};
      for(const [name,role,elig] of [['member-a','member',true],['member-b','member',true],['clerk','clerk',false],['chair','chair',false]]){
        tokens[tenant][name]=sqlite.provisionActor(tenant,name,role,elig);
      }
    }
    const actor=name=>sqlite.authenticate(tokens[scope][name]);
    const sourceA=legacy.command(actor('member-a'),command(scope,{type:'ADVISE',id:'P-UAH-01',choice:'SUPPORT'},'legacy-stance-001',0,1));
    legacy.command(actor('member-a'),command(scope,{type:'COMMENT',id:'P-UAH-01',text:'Unpublished synthetic objection with unique secret marker KITE-ORCHID.',stance:'CONCERN'},'legacy-comment-002',1,1));
    assert.equal(sourceA.sequence,1);
    const expected=legacy.replay(scope);
    sqlite.close();
    const before=digest(readFileSync(srcFile));

    const pg=await PgParticipationStore.connect();
    try{
      const moved=await pg.migrateSqlite(srcFile);
      assert.equal(moved.find(x=>x.tenant===scope).sequence,2);
      assert.equal(digest(readFileSync(srcFile)),before,'source database must not mutate during import');
      const current=await pg.checkpoint(scope);
      assert.equal(current.headHash,expected.headHash);
      assert.equal(current.sequence,2);
      const migratedRetry=await pg.command(tokens[scope]['member-a'],command(scope,{type:'ADVISE',id:'P-UAH-01',choice:'SUPPORT'},'legacy-stance-001',0,1));
      assert.deepEqual(migratedRetry,sourceA);
      assert.equal((await pg.checkpoint(scope)).sequence,2,'idempotent retry must not append');
      await checkReject(pg.command(tokens[scope]['member-a'],command(scope,{type:'ADVISE',id:'P-UAH-01',choice:'OPPOSE'},'legacy-stance-001',0,1)),/IDEMPOTENCY_CONFLICT/);
      await checkReject(pg.migrateSqlite(srcFile),/PG_DESTINATION_NOT_EMPTY/);
      const own=await pg.view(tokens[scope]['member-a'],scope);
      const other=await pg.view(tokens[scope]['member-b'],scope);
      assert.equal(own.board.proposals[0].positions[0].choice,'SUPPORT');
      assert.equal(other.board.proposals[0].positions.length,0);
      assert.doesNotMatch(JSON.stringify(other),/KITE-ORCHID/);
      assert.doesNotMatch(JSON.stringify(await pg.dossier(tokens[scope]['member-b'],scope,'P-UAH-01')),/KITE-ORCHID|SUPPORT/);
      await checkReject(pg.view(tokens['union-demo']['member-a'],scope),/FORBIDDEN_TENANT/);

      // Two independently authenticated clients read the same sequence, only one can commit.
      const pair=[
        pg.command(tokens[scope]['member-b'],command(scope,amendment,'simultaneous-amendment-003',2,1)),
        pg.command(tokens[scope]['member-a'],command(scope,{type:'COMMENT',id:'P-UAH-01',text:'Second fictional concern arrived during an amendment proposal.',stance:'QUESTION'},'simultaneous-comment-004',2,1))
      ];
      const settled=await Promise.allSettled(pair);
      assert.equal(settled.filter(x=>x.status==='fulfilled').length,1);
      assert.match(String(settled.find(x=>x.status==='rejected').reason),/PARTICIPATION_SEQUENCE_CONFLICT/);
      let state=await pg.view(tokens[scope]['member-a'],scope);
      assert.equal(state.sequence,3);

      if(state.board.proposals[0].amendments.length===0){
        await pg.command(tokens[scope]['member-b'],command(scope,amendment,'followup-amendment-005',3,1));
        state=await pg.view(tokens[scope]['member-b'],scope);
      }
      await checkReject(pg.command(tokens[scope]['member-a'],command(scope,{type:'REVIEW_AMEND',id:'P-UAH-01',amendmentId:'A-1',decision:'ACCEPT',reason},'forged-review-006',state.sequence,1)),/PARTICIPATION_CLERK_REQUIRED/);
      const versioned=await pg.command(tokens[scope]['clerk'],command(scope,{type:'REVIEW_AMEND',id:'P-UAH-01',amendmentId:'A-1',decision:'ACCEPT',reason},'fictional-clerk-review-006',state.sequence,1));
      assert.equal(versioned.revision,2);
      await checkReject(pg.command(tokens[scope]['member-a'],command(scope,{type:'ADVISE',id:'P-UAH-01',choice:'OPPOSE'},'stale-revision-007',versioned.sequence,1)),/PARTICIPATION_REVISION_CONFLICT/);
      const after=await pg.view(tokens[scope]['member-a'],scope);
      assert.equal(after.board.proposals[0].positions.some(p=>p.revision===2),false);
      assert.equal(after.board.proposals[0].positions.some(p=>p.revision===1),true);
      const replay=await pg.checkpoint(scope);

      // Verify encrypted at rest, not plain JSON and no secret phrase.
      const persisted=await pg.pool.query('SELECT seq,ciphertext,nonce,tag,hash FROM cw_pg_events WHERE tenant=$1 ORDER BY seq',[scope]);
      assert.ok(persisted.rows.length>=4);
      for(const e of persisted.rows){
        assert.equal(e.nonce.length,12);assert.equal(e.tag.length,16);
        assert.equal(e.ciphertext.includes(Buffer.from('KITE-ORCHID')),false);
      }
      const original=persisted.rows[0];
      await pg.pool.query('ALTER TABLE cw_pg_events DISABLE TRIGGER cw_pg_events_immutable');
      try{
        await pg.pool.query('UPDATE cw_pg_events SET ciphertext=$3 WHERE tenant=$1 AND seq=$2',[scope,original.seq,Buffer.from('tampered')]);
      }finally{await pg.pool.query('ALTER TABLE cw_pg_events ENABLE TRIGGER cw_pg_events_immutable');}
      await checkReject(pg.checkpoint(scope),/PG_EVENT_AUTHENTICATION_FAILED/);
      await pg.pool.query('ALTER TABLE cw_pg_events DISABLE TRIGGER cw_pg_events_immutable');
      try{
        await pg.pool.query('UPDATE cw_pg_events SET ciphertext=$3 WHERE tenant=$1 AND seq=$2',[scope,original.seq,original.ciphertext]);
      }finally{await pg.pool.query('ALTER TABLE cw_pg_events ENABLE TRIGGER cw_pg_events_immutable');}
      assert.equal((await pg.checkpoint(scope)).headHash,replay.headHash);

      // Reauthorization: locked actor credentials cannot commit after revocation.
      await pg.pool.query("UPDATE cw_pg_actors SET eligible=false WHERE tenant=$1 AND actor_id='member-a'",[scope]);
      await checkReject(pg.command(tokens[scope]['member-a'],command(scope,{type:'ADVISE',id:'P-UAH-01',choice:'SUPPORT'},'revoked-credential-008',replay.sequence,2)),/PARTICIPATION_MEMBER_REQUIRED/);
      await pg.pool.query("UPDATE cw_pg_actors SET eligible=true WHERE tenant=$1 AND actor_id='member-a'",[scope]);

      const anchor=await pg.checkpoint(scope);
      const signing=signingKey(join(dir,'checkpoint-key.pem'));
      const envelope=exportEvidence(anchor,signing);
      const pinned=createPublicKey(signing).export({type:'spki',format:'pem'}).toString();
      assert.equal(verifyExternalCheckpoint(envelope,pinned).headHash,anchor.headHash);
      const anchored=await verifyPgAnchoredPrefix({connectionString:process.env.COMMONWEALTH_PG_URL,eventKeyHex:process.env.COMMONWEALTH_PG_EVENT_KEY,envelope,pinnedPublicKeyPem:pinned});
      assert.equal(anchored.anchoredPrefixMatched,true);
      const altered=structuredClone(envelope);altered.payload.sequence=anchor.sequence+1;
      assert.throws(()=>verifyExternalCheckpoint(altered,pinned),/CHECKPOINT_SIGNATURE_INVALID/);
      assert.throws(()=>verifyExternalCheckpoint(envelope,createPublicKey(signingKey(join(dir,'forged-key.pem'))).export({type:'spki',format:'pem'}).toString()),/PINNED_CHECKPOINT_SIGNER_MISMATCH/);

      // A later legitimate append does not invalidate an externally pinned prefix.
      const advanced=await pg.command(tokens[scope]['member-a'],command(scope,{type:'ADVISE',id:'P-UAH-01',choice:'OPPOSE'},'post-anchor-advisory-009',anchor.sequence,2));
      assert.equal(advanced.sequence,anchor.sequence+1);
      assert.equal((await verifyPgAnchoredPrefix({connectionString:process.env.COMMONWEALTH_PG_URL,eventKeyHex:process.env.COMMONWEALTH_PG_EVENT_KEY,envelope,pinnedPublicKeyPem:pinned})).anchoredPrefixMatched,true);

      // Unprivileged HTTP paths do not expose commands, encrypted rows, or private advice.
      const server=createPgServer(pg,{keyPath:join(dir,'receipt-key.pem')});
      await new Promise(ok=>server.listen(0,'127.0.0.1',ok));
      try{
        const base='http://127.0.0.1:'+server.address().port;
        const h={Authorization:'Bearer '+tokens[scope]['member-b']};
        assert.equal((await fetch(base+'/api/v1/participation/'+scope+'/board')).status,401);
        assert.equal((await fetch(base+'/api/v1/participation/'+scope+'/board',{headers:{Authorization:'Bearer '+tokens['union-demo']['member-a']}})).status,403);
        const r=await fetch(base+'/api/v1/participation/'+scope+'/board',{headers:h});
        assert.equal(r.status,200);
        assert.doesNotMatch(JSON.stringify(await r.json()),/KITE-ORCHID|SUPPORT/);
        assert.equal((await fetch(base+'/browser/')).status,200);
      }finally{await new Promise(ok=>server.close(ok));}

      // Manifest contains no credentials and can validate a separate restored database.
      const manifest=process.env.CW_PG_RECOVERY_MANIFEST;
      if(manifest){const latest=await pg.checkpoint(scope);writeFileSync(manifest,JSON.stringify({tenant:scope,headHash:latest.headHash,sequence:latest.sequence,seedHash:latest.seedHash}),{mode:0o600});}
    }finally{await pg.close();}
  }finally{try{sqlite.close();}catch{}rmSync(dir,{recursive:true,force:true});}
});
