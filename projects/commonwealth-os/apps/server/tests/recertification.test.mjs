import test from 'node:test';
import assert from 'node:assert/strict';
import {dependencyRecord,recertifyImpact} from '../src/recertification.mjs';
import {createMockIdentityIssuer} from '../adapters/mock-identity.mjs';
const payload={institution:{id:'union-demo'},item:{id:'a-motion',lockedPolicyVersion:2,lockedEligibilityVersion:7,lockedRevision:3},
 events:[{action:'LOCK',details:{sources:[{sourceId:'rule-a',version:1,hash:'abc'}]}},{hash:'root'}],
 authorityJournal:[{hash:'auth-root'}],sourceDependencies:[{sourceId:'rule-a',version:1,hash:'abc'}]};
test('minimal recertification detects only relevant institutional changes',()=>{
 const d=dependencyRecord(payload);
 assert.equal(recertifyImpact(d,[{institutionId:'other-org',type:'POLICY_CHANGED',version:99}]).status,'UNCHANGED_UNDER_DECLARED_DEPENDENCIES');
 assert.equal(recertifyImpact(d,[{institutionId:'union-demo',type:'POLICY_CHANGED',version:3}]).status,'RECHECK_REQUIRED');
 assert.equal(recertifyImpact(d,[{institutionId:'union-demo',type:'SOURCE_REVISED',sourceId:'unused',version:5,hash:'new'}]).status,'UNCHANGED_UNDER_DECLARED_DEPENDENCIES');
 assert.equal(recertifyImpact(d,[{institutionId:'union-demo',type:'SOURCE_REVISED',sourceId:'rule-a',version:2,hash:'def'}]).status,'RECHECK_REQUIRED');
 assert.equal(recertifyImpact(d,[{institutionId:'union-demo',type:'ELIGIBILITY_CHANGED',epoch:8}]).status,'RECHECK_REQUIRED');
 assert.equal(recertifyImpact(d,[{institutionId:'union-demo',type:'UNRECOGNIZED_CHANGE'}]).status,'UNKNOWN');
});
test('missing source graph cannot be silently called unchanged',()=>{
 const d=dependencyRecord({...payload,events:[]});
 assert.equal(recertifyImpact(d,[{institutionId:'union-demo',type:'SOURCE_REVISED',sourceId:'other',version:2,hash:'new'}]).status,'UNKNOWN');
});
test('mock signed identity: scoped to tenant, audience, nonce, signature and expiry',()=>{
 const p=createMockIdentityIssuer();
 const token=p.issue({institutionId:'union-demo',subject:'fictional-person',nonce:'session-one',scope:['demo:read'],expiresAt:3000});
 assert.equal(p.verifyAssertion(token,{institutionId:'union-demo',nonce:'session-one',nowEpochSeconds:2000}).subject,'fictional-person');
 for(const args of [
  {institutionId:'student-demo',nonce:'session-one',nowEpochSeconds:2000},
  {institutionId:'union-demo',nonce:'another',nowEpochSeconds:2000},
  {institutionId:'union-demo',nonce:'session-one',nowEpochSeconds:3000},
  {institutionId:'union-demo',nonce:'session-one',nowEpochSeconds:2000,allowedScope:'demo:cast'}
 ])assert.throws(()=>p.verifyAssertion(token,args));
 assert.throws(()=>p.verifyAssertion(token.slice(0,-2)+'aa',{institutionId:'union-demo',nonce:'session-one',nowEpochSeconds:2000}));
});
