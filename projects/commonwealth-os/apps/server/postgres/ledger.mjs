// PostgreSQL persistence adapter. Real backend only when a privileged
// deployment provisions PostgreSQL/RLS roles, TLS, backups and institutional authority.
// No runtime pg dependency for the SQLite demo; supply an instance of pg.Pool.
import { canon, sha, invariant } from '../src/codec.mjs';
import { policyValid } from '../src/policy.mjs';
const idRE=/^[a-z][a-z0-9-]{1,63}$/;
const itemRE=/^[a-z][a-z0-9-]{2,63}$/;
function reject(code){ const e=new Error(code);e.code=code;throw e; }
export class PostgresLedger {
 constructor(pool){if(!pool||typeof pool.connect!=='function')throw Error('PG_POOL_REQUIRED');this.pool=pool;}
 async appendAuthority(client,institutionId,action,details){
  const r=await client.query('SELECT seq,event_hash FROM cwos.authority_events WHERE institution_id=$1 ORDER BY seq DESC LIMIT 1',[institutionId]);
  const seq=Number(r.rows[0]?.seq??0)+1,previousHash=r.rows[0]?.event_hash??'GENESIS';
  const event={seq,institutionId,action,details};const eventHash=sha({event,previousHash});
  await client.query('INSERT INTO cwos.authority_events VALUES($1,$2,$3,$4,$5)',[institutionId,seq,event,previousHash,eventHash]);
  return {seq,hash:eventHash};
 }
 // Every tenant command is an authenticated SERVER call: never accept the tenant
 // from a raw browser query parameter. The local setting is scoped to one tx.
 async withTenantTx(institutionId,fn){
  if(!idRE.test(institutionId))reject('BAD_TENANT');
  const client=await this.pool.connect();
  try{
   await client.query('BEGIN ISOLATION LEVEL SERIALIZABLE');
   await client.query("SELECT set_config('app.tenant_id',$1,true)",[institutionId]);
   const value=await fn(client);await client.query('COMMIT');return value;
  }catch(e){await client.query('ROLLBACK');throw e;}finally{client.release();}
 }
 async bootstrapSyntheticInstitution({institutionId,name,policy,actors}){
  if(!idRE.test(institutionId)||!policyValid(policy)||!Array.isArray(actors)||!name)reject('INVALID_BOOTSTRAP');
  return this.withTenantTx(institutionId,async client=>{
   await client.query('INSERT INTO cwos.institutions(id,name) VALUES($1,$2)',[institutionId,name]);
   await client.query('INSERT INTO cwos.policies(institution_id,version,policy,policy_hash) VALUES($1,1,$2,$3)',[institutionId,policy,sha(policy)]);
   await this.appendAuthority(client,institutionId,'INSTITUTION_PROVISIONED',{name,policyVersion:1,policyHash:sha(policy),eligibilityVersion:1});
   let epoch=1;
   for(const a of actors){
    if(!idRE.test(a.id)||!['admin','chair','clerk','member','auditor','release-reviewer'].includes(a.role)||typeof a.eligible!=='boolean')reject('INVALID_ACTOR');
    await client.query('INSERT INTO cwos.actors(institution_id,actor_id,role,eligible) VALUES($1,$2,$3,$4)',[institutionId,a.id,a.role,a.eligible]);
    if(a.role==='member')epoch++;
    await this.appendAuthority(client,institutionId,'ACTOR_PROVISIONED',{actorId:a.id,role:a.role,eligible:a.eligible,active:true,eligibilityVersion:epoch});
   }
   await client.query('UPDATE cwos.institutions SET eligibility_version=$2 WHERE id=$1',[institutionId,epoch]);
   return {institutionId,eligibilityVersion:epoch};
  });
 }
 async currentActor(client,institutionId,actorId){
  const r=await client.query('SELECT actor_id,role,eligible,active FROM cwos.actors WHERE institution_id=$1 AND actor_id=$2',[institutionId,actorId]);
  return r.rows[0]??null;
 }
 async updateMemberEligibility({institutionId,adminId,memberId,eligible}){
  if(typeof eligible!=='boolean')reject('BAD_ELIGIBILITY');
  return this.withTenantTx(institutionId,async client=>{
   const inst=(await client.query('SELECT * FROM cwos.institutions WHERE id=$1 FOR UPDATE',[institutionId])).rows[0];if(!inst)reject('UNKNOWN_INSTITUTION');
   const admin=await this.currentActor(client,institutionId,adminId),member=await this.currentActor(client,institutionId,memberId);
   if(!admin?.active||admin.role!=='admin'||!member?.active||member.role!=='member')reject('MEMBER_UPDATE_DENIED');
   await client.query('UPDATE cwos.actors SET eligible=$3 WHERE institution_id=$1 AND actor_id=$2',[institutionId,memberId,eligible]);
   const version=Number(inst.eligibility_version)+1;
   await client.query('UPDATE cwos.institutions SET eligibility_version=$2 WHERE id=$1',[institutionId,version]);
   await this.appendAuthority(client,institutionId,'ELIGIBILITY_CHANGED',{actorId:memberId,eligible,by:adminId,eligibilityVersion:version});
   return {institutionId,memberId,eligible,eligibilityVersion:version};
  });
 }
 async updatePolicy({institutionId,adminId,policy}){
  if(!policyValid(policy))reject('BAD_POLICY');
  return this.withTenantTx(institutionId,async client=>{
   const inst=(await client.query('SELECT * FROM cwos.institutions WHERE id=$1 FOR UPDATE',[institutionId])).rows[0];if(!inst)reject('UNKNOWN_INSTITUTION');
   const admin=await this.currentActor(client,institutionId,adminId);
   if(!admin?.active||admin.role!=='admin')reject('POLICY_CHANGE_DENIED');
   const version=Number(inst.policy_version)+1;
   await client.query('INSERT INTO cwos.policies(institution_id,version,policy,policy_hash) VALUES($1,$2,$3,$4)',[institutionId,version,policy,sha(policy)]);
   await client.query('UPDATE cwos.institutions SET policy_version=$2 WHERE id=$1',[institutionId,version]);
   await this.appendAuthority(client,institutionId,'POLICY_CHANGED',{by:adminId,policyVersion:version,policyHash:sha(policy)});
   return {institutionId,policyVersion:version};
  });
 }
 async applySyntheticCommand({institutionId,itemId,actorId,action,expectedVersion,payload={},key}){
  if(!idRE.test(institutionId)||!itemRE.test(itemId)||!idRE.test(actorId)||!Number.isSafeInteger(expectedVersion)||typeof key!=='string'||!/^[-A-Za-z0-9._:]{8,120}$/.test(key))reject('BAD_COMMAND');
  if(!['CREATE','REVISE','SUBMIT','AGENDA','BEGIN','ATTEND','LOCK','OPEN','CAST','CLOSE','REVIEW'].includes(action))reject('UNSUPPORTED_POSTGRES_TRANSITION');
  return this.withTenantTx(institutionId,async client=>{
   // Shared institution row lock linearizes authority changes and decisions.
   const ir=await client.query('SELECT * FROM cwos.institutions WHERE id=$1 FOR UPDATE',[institutionId]);if(!ir.rows.length)reject('UNKNOWN_INSTITUTION');
   const inst=ir.rows[0];
   const a=await this.currentActor(client,institutionId,actorId);if(!a?.active)reject('INACTIVE_ACTOR');
   const request={institutionId,itemId,actorId,action,expectedVersion,payload};const requestHash=sha(request);
   const idempotent=await client.query('SELECT request_hash,response FROM cwos.requests WHERE institution_id=$1 AND actor_id=$2 AND command_key=$3',[institutionId,actorId,key]);
   if(idempotent.rows.length){if(idempotent.rows[0].request_hash!==requestHash)reject('IDEMPOTENCY_CONFLICT');return idempotent.rows[0].response;}
   let itemResult=await client.query('SELECT * FROM cwos.items WHERE institution_id=$1 AND item_id=$2 FOR UPDATE',[institutionId,itemId]);
   let item=itemResult.rows[0]??null,from=item?.state??null,to=from,details={},revision=item?.current_revision??0;
   if(action==='CREATE'){
    if(item||expectedVersion!==0||!['member','chair'].includes(a.role)||typeof payload.body!=='string'||!payload.body.trim())reject('BAD_CREATE');
    revision=1;to='DRAFT';
    await client.query('INSERT INTO cwos.items(institution_id,item_id,state,version,current_revision,proposer) VALUES($1,$2,$3,1,1,$4)',[institutionId,itemId,to,actorId]);
    const bodyHash=sha({institutionId,itemId,revision,body:payload.body,previousHash:'GENESIS'});
    await client.query('INSERT INTO cwos.revisions(institution_id,item_id,revision,body,previous_hash,body_hash,author) VALUES($1,$2,1,$3,$4,$5,$6)',[institutionId,itemId,payload.body,'GENESIS',bodyHash,actorId]);
    details={revision,bodyHash};
   }else{
    if(!item||Number(item.version)!==expectedVersion)reject('VERSION_CONFLICT');
    const transitions={SUBMIT:['DRAFT','IN_REVIEW'],AGENDA:['IN_REVIEW','AGENDA_SET'],BEGIN:['AGENDA_SET','DELIBERATING'],ATTEND:['DELIBERATING','DELIBERATING'],LOCK:['DELIBERATING','MOTION_LOCKED'],OPEN:['MOTION_LOCKED','BALLOT_OPEN'],CAST:['BALLOT_OPEN','BALLOT_OPEN'],CLOSE:['BALLOT_OPEN','BALLOT_CLOSED'],REVIEW:['BALLOT_CLOSED','REVIEWED_DEMO']};
    if(action==='REVISE'){
     if(!['DRAFT','IN_REVIEW','AGENDA_SET','DELIBERATING'].includes(from)||!(item.proposer===actorId||a.role==='clerk')||typeof payload.body!=='string'||!payload.body.trim())reject('REVISION_FORBIDDEN');
     revision=item.current_revision+1;to='DRAFT';
     const prior=await client.query('SELECT body_hash FROM cwos.revisions WHERE institution_id=$1 AND item_id=$2 ORDER BY revision DESC LIMIT 1',[institutionId,itemId]);
     const previousHash=prior.rows[0].body_hash,bodyHash=sha({institutionId,itemId,revision,body:payload.body,previousHash});
     await client.query('INSERT INTO cwos.revisions(institution_id,item_id,revision,body,previous_hash,body_hash,author) VALUES($1,$2,$3,$4,$5,$6,$7)',[institutionId,itemId,revision,payload.body,previousHash,bodyHash,actorId]);
     await client.query('DELETE FROM cwos.attendance WHERE institution_id=$1 AND item_id=$2',[institutionId,itemId]);
     details={revision,bodyHash};
    }else{
     const edge=transitions[action];if(!edge||edge[0]!==from)reject('INVALID_TRANSITION');to=edge[1];
     const role={SUBMIT:['member','chair'],AGENDA:['chair'],BEGIN:['chair'],ATTEND:['clerk'],LOCK:['chair'],OPEN:['chair'],CAST:['member'],CLOSE:['chair'],REVIEW:['clerk']}[action];
     if(!role.includes(a.role)||(action==='SUBMIT'&&actorId!==item.proposer&&a.role!=='chair'))reject('FORBIDDEN_ROLE');
     const pr=await client.query('SELECT policy FROM cwos.policies WHERE institution_id=$1 AND version=$2',[institutionId,inst.policy_version]);if(!pr.rows.length)reject('MISSING_POLICY');const policy=pr.rows[0].policy;
     const att=await client.query('SELECT actor_id FROM cwos.attendance WHERE institution_id=$1 AND item_id=$2 ORDER BY actor_id',[institutionId,itemId]);
     const attendees=att.rows.map(r=>r.actor_id);
     if(action==='ATTEND'){
      if(!Array.isArray(payload.attendees)||new Set(payload.attendees).size!==payload.attendees.length)reject('BAD_ATTENDANCE');
      for(const memberId of payload.attendees){const member=await this.currentActor(client,institutionId,memberId);if(!member?.active||!member.eligible||member.role!=='member')reject('INELIGIBLE_ATTENDEE');}
      await client.query('DELETE FROM cwos.attendance WHERE institution_id=$1 AND item_id=$2',[institutionId,itemId]);
      for(const memberId of payload.attendees)await client.query('INSERT INTO cwos.attendance VALUES($1,$2,$3)',[institutionId,itemId,memberId]);
      details={attendees:[...payload.attendees].sort()};
     }
     if(action==='LOCK'){
      if(attendees.length<policy.quorum)reject('QUORUM_UNMET');
      if(policy.quorumFraction){
       const eligible=(await client.query('SELECT count(*)::int AS n FROM cwos.actors WHERE institution_id=$1 AND role=$2 AND active AND eligible',[institutionId,'member'])).rows[0].n;
       const q=policy.quorumFraction,left=BigInt(attendees.length)*BigInt(q.denominator),right=BigInt(eligible)*BigInt(q.numerator);
       if(q.strict?left<=right:left<right)reject('QUORUM_FRACTION_UNMET');
      }
      await client.query('UPDATE cwos.items SET locked_revision=$3,locked_policy_version=$4,locked_eligibility_version=$5 WHERE institution_id=$1 AND item_id=$2',[institutionId,itemId,revision,inst.policy_version,inst.eligibility_version]);
      const roster=(await client.query('SELECT actor_id FROM cwos.actors WHERE institution_id=$1 AND role=$2 AND active AND eligible ORDER BY actor_id',[institutionId,'member'])).rows.map(x=>x.actor_id);
      details={lockedRevision:revision,policyVersion:Number(inst.policy_version),policyHash:sha(policy),eligibilityVersion:Number(inst.eligibility_version),attendees,eligibleRoster:roster};
     }
     if(['OPEN','CAST','CLOSE','REVIEW'].includes(action)){
      if(Number(item.locked_revision)!==Number(item.current_revision)||Number(item.locked_policy_version)!==Number(inst.policy_version)||Number(item.locked_eligibility_version)!==Number(inst.eligibility_version))reject('AUTHORITY_CHANGED');
      details={...details,lockedRevision:Number(item.locked_revision),policyVersion:Number(inst.policy_version),eligibilityVersion:Number(inst.eligibility_version)};
     }
     if(action==='CAST'){
      if(!a.eligible||!attendees.includes(actorId)||!['yes','no','abstain'].includes(payload.choice))reject('NOT_ELIGIBLE');
      await client.query('INSERT INTO cwos.rollcall_votes VALUES($1,$2,$3,$4)',[institutionId,itemId,actorId,payload.choice]);
      details={...details,voter:actorId,choice:payload.choice};
     }
     if(action==='REVIEW'){
      if(actorId===item.proposer)reject('SEPARATION_OF_DUTIES');
      const vr=await client.query('SELECT actor_id,choice FROM cwos.rollcall_votes WHERE institution_id=$1 AND item_id=$2 ORDER BY actor_id',[institutionId,itemId]);
      if(vr.rows.some(v=>v.actor_id===actorId))reject('REVIEWER_VOTED');
      const yes=vr.rows.filter(v=>v.choice==='yes').length,no=vr.rows.filter(v=>v.choice==='no').length,abstain=vr.rows.filter(v=>v.choice==='abstain').length;
      if(attendees.length<policy.quorum)reject('QUORUM_UNMET');
      if(policy.quorumFraction){
       const eligible=(await client.query('SELECT count(*)::int AS n FROM cwos.actors WHERE institution_id=$1 AND role=$2 AND active AND eligible',[institutionId,'member'])).rows[0].n;
       const q=policy.quorumFraction,left=BigInt(attendees.length)*BigInt(q.denominator),right=BigInt(eligible)*BigInt(q.numerator);
       if(q.strict?left<=right:left<right)reject('QUORUM_FRACTION_UNMET');
      }
      const basis=policy.approvalBasis??'DECISIVE';const denom={DECISIVE:yes+no,CAST:vr.rows.length,PRESENT:attendees.length,ELIGIBLE:(await client.query('SELECT count(*)::int AS n FROM cwos.actors WHERE institution_id=$1 AND role=$2 AND active AND eligible',[institutionId,'member'])).rows[0].n}[basis];
      const lhs=BigInt(yes)*BigInt(policy.yesDenominator),rhs=BigInt(denom)*BigInt(policy.yesNumerator);
      const accepted=denom>0&&(policy.strict?lhs>rhs:lhs>=rhs),outcome=accepted?'SUPPORTED_IN_SIMULATION':'REJECTED_IN_SIMULATION';
      await client.query('UPDATE cwos.items SET reviewer=$3,outcome=$4 WHERE institution_id=$1 AND item_id=$2',[institutionId,itemId,actorId,outcome]);
      details={...details,outcome,counts:{yes,no,abstain},reviewer:actorId};
     }
    }
    await client.query('UPDATE cwos.items SET state=$3,version=version+1,current_revision=$4 WHERE institution_id=$1 AND item_id=$2',[institutionId,itemId,to,revision]);
   }
   const authority=(await client.query('SELECT seq,event_hash FROM cwos.authority_events WHERE institution_id=$1 ORDER BY seq DESC LIMIT 1',[institutionId])).rows[0];
   if(!authority)reject('MISSING_AUTHORITY_JOURNAL');
   details={...details,authoritySeq:Number(authority.seq),authorityHash:authority.event_hash};
   const previousEvent=await client.query('SELECT seq,event_hash FROM cwos.events WHERE institution_id=$1 AND item_id=$2 ORDER BY seq DESC LIMIT 1',[institutionId,itemId]);
   const seq=Number(previousEvent.rows[0]?.seq??0)+1,previousHash=previousEvent.rows[0]?.event_hash??'GENESIS';
   const event={seq,institutionId,itemId,actorId,actorRole:a.role,action,from,to,details};
   const eventHash=sha({event,previousHash});
   await client.query('INSERT INTO cwos.events(institution_id,item_id,seq,event,previous_hash,event_hash) VALUES($1,$2,$3,$4,$5,$6)',[institutionId,itemId,seq,event,previousHash,eventHash]);
   const response={institutionId,itemId,action,state:to,version:action==='CREATE'?1:expectedVersion+1,revision,eventHash,official:false};
   await client.query('INSERT INTO cwos.requests(institution_id,actor_id,command_key,request_hash,response) VALUES($1,$2,$3,$4,$5)',[institutionId,actorId,key,requestHash,response]);
   return response;
  });
 }
 async readEvidence(institutionId,itemId){
  return this.withTenantTx(institutionId,async c=>{
   const item=(await c.query('SELECT * FROM cwos.items WHERE institution_id=$1 AND item_id=$2',[institutionId,itemId])).rows[0];
   if(!item)reject('UNKNOWN_ITEM');
   const events=(await c.query('SELECT event,previous_hash,event_hash FROM cwos.events WHERE institution_id=$1 AND item_id=$2 ORDER BY seq',[institutionId,itemId])).rows;
   const revisions=(await c.query('SELECT revision,body,previous_hash,body_hash,author FROM cwos.revisions WHERE institution_id=$1 AND item_id=$2 ORDER BY revision',[institutionId,itemId])).rows;
   const authorityRows=(await c.query('SELECT event,previous_hash,event_hash FROM cwos.authority_events WHERE institution_id=$1 ORDER BY seq',[institutionId])).rows;
   const policies=(await c.query('SELECT version,policy,policy_hash FROM cwos.policies WHERE institution_id=$1 ORDER BY version',[institutionId])).rows;
   const members=(await c.query('SELECT actor_id,role,eligible,active FROM cwos.actors WHERE institution_id=$1 ORDER BY actor_id',[institutionId])).rows;
   const institution=(await c.query('SELECT policy_version,eligibility_version FROM cwos.institutions WHERE id=$1',[institutionId])).rows[0];
   const attendance=(await c.query('SELECT actor_id FROM cwos.attendance WHERE institution_id=$1 AND item_id=$2 ORDER BY actor_id',[institutionId,itemId])).rows.map(r=>r.actor_id);
   const votes=(await c.query('SELECT actor_id,choice FROM cwos.rollcall_votes WHERE institution_id=$1 AND item_id=$2 ORDER BY actor_id',[institutionId,itemId])).rows;
   return {format:'commonwealth.os.pg-ledger.v0.5-synthetic',institutionId,item,
      events:events.map(e=>({...e.event,previousHash:e.previous_hash,hash:e.event_hash})),
      revisions,authorityJournal:authorityRows.map(e=>({...e.event,previousHash:e.previous_hash,hash:e.event_hash})),
      policies,members,institution,attendance,votes,officialCertification:false,legalAuthority:'NOT_ASSESSED'};
  });
 }
}
