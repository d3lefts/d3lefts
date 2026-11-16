import test from 'node:test';
import assert from 'node:assert/strict';
import { Store } from '../src/store.mjs';

// Source-different, bounded JavaScript interpretation of the Lean phase/epoch
// specification. Compares actual SQLite steps against an independent model.
// Finite testing is NOT a formal JS -> Lean refinement proof.
const basePolicy={quorum:2,yesNumerator:1,yesDenominator:2,strict:true};
let nonce=0;
const idem=()=> 'trace-verify-'+String(++nonce).padStart(9,'0');
const names=['member-a','member-b','member-c','chair','clerk','admin','auditor'];
function newFixture(){
  const store=new Store(':memory:');
  store.provisionInstitution('union-demo','Fictional pilot',basePolicy);
  const users={};
  for(const id of names){
    const role=id.startsWith('member')?'member':id;
    const eligible=id==='member-a'||id==='member-b';
    users[id]={role,token:store.provisionActor('union-demo',id,role,eligible)};
  }
  const memberEligibility={'member-a':true,'member-b':true,'member-c':false};
  let model={
    phase:'DRAFT',itemVersion:1,revision:1,
    policyVersion:1,eligibilityVersion:1,
    locked:null,castBy:[],attendance:[],
    quorum:basePolicy.quorum, memberEligibility
  };
  const real=()=>{
    const actor=store.authenticate(users.auditor.token);
    const s=store.snapshot(actor,'union-demo','test-item');
    return {
      phase:s.item.state,itemVersion:s.item.version,revision:s.item.currentRevision,
      policyVersion:s.institution.policyVersion,
      eligibilityVersion:s.institution.eligibilityVersion,
      locked:s.item.lockedRevision==null?null:{
        revision:s.item.lockedRevision,policyVersion:s.item.lockedPolicyVersion,
        eligibilityVersion:s.item.lockedEligibilityVersion
      },
      castBy:s.votes.map(v=>v.actorId).sort(),
      attendance:s.attendance.slice().sort(),
      quorum:s.policies.at(-1).policy.quorum,
      memberEligibility:Object.fromEntries(
        s.members.filter(a=>a.role==='member').map(a=>[a.id,a.eligible===1])
      )
    };
  };
  const equal=()=>assert.deepEqual(real(),model);
  const create=store.authenticate(users['member-a'].token);
  store.command(create,{institutionId:'union-demo',itemId:'test-item',
    action:'CREATE',key:idem(),expectedVersion:0,
    payload:{body:'A completely fictional legislative motion'}});
  equal();
  // An independently written transition predicate for the in-scope fields.
  const oracle=(action,user,payload,expectedVersion)=>{
    const m=model,role=users[user].role;
    if(expectedVersion!==m.itemVersion)return null;
    const s=structuredClone(m);
    const fresh=()=>!!s.locked&&s.locked.revision===s.revision&&
      s.locked.policyVersion===s.policyVersion&&
      s.locked.eligibilityVersion===s.eligibilityVersion;
    switch(action){
      case 'REVISE':
        if(!['DRAFT','IN_REVIEW','AGENDA_SET','DELIBERATING'].includes(s.phase)||!(user==='member-a'||role==='clerk'))return null;
        s.revision++;s.phase='DRAFT';s.attendance=[];break;
      case 'SUBMIT':
        if(s.phase!=='DRAFT'||!(user==='member-a'||role==='chair'))return null;
        s.phase='IN_REVIEW';break;
      case 'AGENDA':
        if(s.phase!=='IN_REVIEW'||role!=='chair')return null;
        s.phase='AGENDA_SET';break;
      case 'BEGIN':
        if(s.phase!=='AGENDA_SET'||role!=='chair')return null;
        s.phase='DELIBERATING';break;
      case 'ATTEND':
        if(s.phase!=='DELIBERATING'||role!=='clerk')return null;
        if(!Array.isArray(payload.attendees)||new Set(payload.attendees).size!==payload.attendees.length||
           !payload.attendees.every(v=>s.memberEligibility[v]===true))return null;
        s.attendance=payload.attendees.slice().sort();break;
      case 'LOCK':
        if(s.phase!=='DELIBERATING'||role!=='chair'||s.attendance.length<s.quorum)return null;
        s.locked={policyVersion:s.policyVersion,eligibilityVersion:s.eligibilityVersion,revision:s.revision};
        s.phase='MOTION_LOCKED';break;
      case 'OPEN':
        if(s.phase!=='MOTION_LOCKED'||role!=='chair'||!fresh())return null;
        s.phase='BALLOT_OPEN';break;
      case 'CAST':
        if(s.phase!=='BALLOT_OPEN'||role!=='member'||!s.memberEligibility[user]||
           !s.attendance.includes(user)||!fresh()||s.castBy.includes(user)||
           !['yes','no','abstain'].includes(payload.choice))return null;
        s.castBy.push(user);s.castBy.sort();break;
      case 'CLOSE':
        if(s.phase!=='BALLOT_OPEN'||role!=='chair'||!fresh())return null;
        s.phase='BALLOT_CLOSED';break;
      case 'REVIEW':
        if(s.phase!=='BALLOT_CLOSED'||role!=='clerk'||s.attendance.length<s.quorum||
           s.castBy.includes(user)||user==='member-a'||!fresh())return null;
        s.phase='REVIEWED_DEMO';break;
      default:return null;
    }
    s.itemVersion++;
    return s;
  };
  function action(action,user,payload={},stale=false){
    const v=model.itemVersion-(stale?1:0),expected=oracle(action,user,payload,v);
    const actor=store.authenticate(users[user].token);
    const request={institutionId:'union-demo',itemId:'test-item',
      action,expectedVersion:v,payload,key:idem()};
    if(expected){
      const response=store.command(actor,request);
      assert.equal(response.version,expected.itemVersion);
      model=expected;
    }else{
      assert.throws(()=>store.command(actor,request),undefined,
        'invalid synthetic command must be rejected');
    }
    equal();
  }
  function policyEdit(quorum){
    const actor=store.authenticate(users.admin.token);
    store.setPolicy(actor,'union-demo',{...basePolicy,quorum},idem());
    model.policyVersion++;
    model.quorum=quorum;
    equal();
  }
  function eligibilityEdit(member,flag){
    const actor=store.authenticate(users.admin.token);
    store.setEligibility(actor,'union-demo',member,flag,idem());
    model.eligibilityVersion++;
    model.memberEligibility[member]=flag;
    equal();
  }
  return {action,policyEdit,eligibilityEdit,close:()=>store.close()};
}
const phases=[
  [],
  [['SUBMIT','member-a'],['AGENDA','chair'],['BEGIN','chair']],
  [['SUBMIT','member-a'],['AGENDA','chair'],['BEGIN','chair'],
   ['ATTEND','clerk',{attendees:['member-a','member-b']}],['LOCK','chair'],['OPEN','chair']],
  [['SUBMIT','member-a'],['AGENDA','chair'],['BEGIN','chair'],
   ['ATTEND','clerk',{attendees:['member-a','member-b']}],['LOCK','chair'],['OPEN','chair'],
   ['CAST','member-a',{choice:'yes'}],['CLOSE','chair']],
];
function rng(seed){
  let state=seed>>>0;
  return ()=>{state=(Math.imul(1664525,state)+1013904223)>>>0;return state/4294967296;};
}
test('720 bounded, deterministic SQLite-vs-spec command decisions and projections',()=>{
  const candidates=['REVISE','SUBMIT','AGENDA','BEGIN','ATTEND','LOCK','OPEN','CAST','CLOSE','REVIEW'];
  let checked=0;
  for(let trial=0;trial<12;trial++){
    const f=newFixture(),draw=rng(91073+trial*917);
    try{
      for(const [cmd,who,payload] of phases[trial%phases.length])
        f.action(cmd,who,payload??{});
      for(let i=0;i<60;i++){
        const r=draw();
        if(r<0.06){f.policyEdit(1+Math.floor(draw()*3));checked++;continue;}
        if(r<0.12){f.eligibilityEdit(draw()<0.5?'member-a':'member-b',draw()<0.5);checked++;continue;}
        const cmd=candidates[Math.floor(draw()*candidates.length)];
        const who=names[Math.floor(draw()*names.length)];
        const payload=cmd==='REVISE'?{body:'Fictional revision '+i}:
          cmd==='ATTEND'?{attendees:['member-a','member-b']}:
          cmd==='CAST'?{choice:'yes'}:{};
        f.action(cmd,who,payload,draw()<0.12);
        checked++;
      }
    }finally{f.close();}
  }
  assert.equal(checked,720);
});
