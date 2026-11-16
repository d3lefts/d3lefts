import test from 'node:test';import assert from 'node:assert/strict';
import {generateKeyPairSync,sign} from 'node:crypto';
import {verifyIdToken,makeSyntheticNonceLedger,resolveInstitutionalActor} from './oidc-bridge.mjs';
import {admitBallotSession,redactBallotEvidence,MODES} from './ballot-boundary.mjs';
const keys=generateKeyPairSync('ed25519');
const jwk={...keys.publicKey.export({format:'jwk'}),kid:'pinned-key-1',use:'sig',alg:'EdDSA'};
const config={issuer:'https://synthetic-issuer.example',clientId:'cwos-dev',tenants:['union-demo'],alg:'EdDSA',jwks:[jwk]};
const time=2000000000;
const b=x=>Buffer.from(JSON.stringify(x)).toString('base64url');
function token(c,head={alg:'EdDSA',kid:'pinned-key-1'}){const s=`${b(head)}.${b(c)}`;return `${s}.${sign(null,Buffer.from(s),keys.privateKey).toString('base64url')}`;}
const claims={iss:config.issuer,sub:'subject-1',aud:'cwos-dev',nonce:'nonce-v1',iat:time-60,exp:time+90,role:'admin',eligible:true};
function issue(nonce='nonce-v1'){const ledger=makeSyntheticNonceLedger();ledger.issue(nonce,'union-demo');return ledger;}
test('OIDC strict pinned issuer, signature, audience and nonce, with institution-owned grants',async()=>{
 const nonceLedger=issue();const p=await verifyIdToken(token(claims),{issuerConfig:config,institutionId:'union-demo',nonce:'nonce-v1',nonceLedger,clock:time});
 assert.equal(p.authorization,'NOT_GRANTED');
 assert.throws(()=>resolveInstitutionalActor(p,()=>null),/UNBOUND_PRINCIPAL/);
 const actor=resolveInstitutionalActor(p,(tenant,iss,sub)=>({institutionId:tenant,actorId:'member-a',active:true}));assert.equal(actor.actorId,'member-a');
 await assert.rejects(()=>verifyIdToken(token(claims),{issuerConfig:config,institutionId:'union-demo',nonce:'nonce-v1',nonceLedger,clock:time}),/NONCE_REPLAY/);
});
test('OIDC rejects forged role, tenant, alg confusion, stale and extra audiences',async()=>{
 const attempt=async(t,configOverride=config,n='nonce-v1')=>verifyIdToken(t,{issuerConfig:configOverride,institutionId:'union-demo',nonce:n,nonceLedger:issue(n),clock:time});
 await assert.rejects(()=>attempt(token({...claims,iss:'https://evil.example'})),/ISSUER_OR_SUB/);
 await assert.rejects(()=>attempt(token({...claims,aud:'other'})),/AUDIENCE/);
 await assert.rejects(()=>attempt(token({...claims,aud:['cwos-dev','evil']})),/AZP/);
 await assert.rejects(()=>attempt(token({...claims,exp:time-100})),/TIME/);
 await assert.rejects(()=>attempt(token({...claims,nonce:'bad'})),/NONCE/);
 await assert.rejects(()=>attempt(token(claims,{alg:'none',kid:'pinned-key-1'})),/HEADER/);
 await assert.rejects(()=>attempt(token(claims,{alg:'EdDSA',kid:'pinned-key-1',jku:'https://evil.example/jwks'})),/HEADER/);
 await assert.rejects(()=>attempt(token(claims),{...config,tenants:['municipal-demo']}),/TENANT_ISSUER/);
});
test('ballot gate refuses official and private elections; synthetic roll-call only',()=>{
 const basic={institutionId:'union-demo',lockedRevision:2,policyVersion:1,eligibilityVersion:4};
 assert.equal(admitBallotSession({...basic,mode:MODES.SYNTHETIC_ROLL_CALL}).allowed,true);
 for(const mode of [MODES.CONFIDENTIAL,MODES.OFFICIAL,'anything-else'])assert.equal(admitBallotSession({...basic,mode}).allowed,false);
 assert.equal(admitBallotSession({...basic,mode:MODES.SYNTHETIC_ROLL_CALL,legalAuthority:true}).allowed,false);
 assert.equal(admitBallotSession({mode:MODES.SYNTHETIC_ROLL_CALL}).allowed,false);
});
test('public evidence projection is strict allowlist; voters cannot leak',()=>{
 const fixture={publicationApproved:true,institutionId:'union-demo',motionId:'test-motion',motionDigest:'xx',reviewDigest:'yy',counts:{yes:2,no:1,abstain:0},votes:[{person:'alice',choice:'yes'}],ssn:'NOT_PUBLIC'};
 const r=redactBallotEvidence(fixture,{visibility:'PUBLIC_REVIEWED'});
 assert.ok(!JSON.stringify(r).includes('alice')&&!JSON.stringify(r).includes('ssn'));
 assert.throws(()=>redactBallotEvidence({...fixture,publicationApproved:false},{visibility:'PUBLIC_REVIEWED'}),/PUBLICATION_NOT_APPROVED/);
});
