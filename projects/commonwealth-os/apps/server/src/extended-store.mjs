import { randomBytes } from 'node:crypto';
import { Store } from './store.mjs';
import { canon, sha, invariant } from './codec.mjs';
import { policyValid } from './policy.mjs';

const stamp=()=>new Date().toISOString();
const idPattern=/^[a-z][a-z0-9-]{1,63}$/;
const itemIdPattern=/^[a-z][a-z0-9-]{2,63}$/;
const roles=new Set(['admin','chair','clerk','member','auditor','release-reviewer']);
const writableStates=new Set(['DRAFT','IN_REVIEW','AGENDA_SET','DELIBERATING']);
const voidStates=new Set(['DRAFT','IN_REVIEW','AGENDA_SET','DELIBERATING','MOTION_LOCKED','BALLOT_OPEN','BALLOT_CLOSED']);
const extCommands=new Set(['VOID','PREPARE_PUBLICATION','REVIEW_PUBLICATION','PUBLISH_PREVIEW','CORRECT_PUBLICATION','ATTACH_SOURCE']);
const isText=(x,max)=>typeof x==='string'&&x.trim().length>0&&x.length<=max;

// Stateful, LOCAL synthetic research extension. NOT an official decision system.
export class ExtendedStore extends Store {
  constructor(file=':memory:'){
    super(file);
    this.tx(()=>{
      const version=Number(this.one('PRAGMA user_version').user_version);
      invariant(version===0||version===4,'UNSUPPORTED_SCHEMA_VERSION');
      this.db.exec(`
        CREATE TABLE IF NOT EXISTS authority_journal (
          institution_id TEXT NOT NULL, seq INTEGER NOT NULL,
          event_json TEXT NOT NULL, previous_hash TEXT NOT NULL, hash TEXT NOT NULL,
          PRIMARY KEY(institution_id,seq));
        CREATE TABLE IF NOT EXISTS source_documents (
          institution_id TEXT NOT NULL, source_id TEXT NOT NULL, version INTEGER NOT NULL,
          text TEXT NOT NULL, status TEXT NOT NULL, source_uri TEXT NOT NULL,
          previous_hash TEXT NOT NULL, hash TEXT NOT NULL, at TEXT NOT NULL,
          PRIMARY KEY(institution_id,source_id,version));
        CREATE TABLE IF NOT EXISTS item_sources (
          institution_id TEXT NOT NULL,item_id TEXT NOT NULL,source_id TEXT NOT NULL,
          source_version INTEGER NOT NULL,hash TEXT NOT NULL,
          PRIMARY KEY(institution_id,item_id,source_id));
        CREATE TABLE IF NOT EXISTS projections (
          institution_id TEXT NOT NULL,item_id TEXT NOT NULL,revision INTEGER NOT NULL,
          content TEXT NOT NULL,reason TEXT NOT NULL,previous_hash TEXT NOT NULL,
          hash TEXT NOT NULL,at TEXT NOT NULL,
          PRIMARY KEY(institution_id,item_id,revision));
        CREATE TABLE IF NOT EXISTS publication_approvals (
          institution_id TEXT NOT NULL,item_id TEXT NOT NULL,revision INTEGER NOT NULL,
          actor_id TEXT NOT NULL,at TEXT NOT NULL,
          PRIMARY KEY(institution_id,item_id,revision,actor_id));
        CREATE TABLE IF NOT EXISTS schema_migrations (version INTEGER PRIMARY KEY,applied_at TEXT NOT NULL);
        CREATE TRIGGER IF NOT EXISTS immutable_authority_up BEFORE UPDATE ON authority_journal BEGIN SELECT RAISE(ABORT,'IMMUTABLE_AUTHORITY'); END;
        CREATE TRIGGER IF NOT EXISTS immutable_authority_del BEFORE DELETE ON authority_journal BEGIN SELECT RAISE(ABORT,'IMMUTABLE_AUTHORITY'); END;
        CREATE TRIGGER IF NOT EXISTS immutable_source_up BEFORE UPDATE ON source_documents BEGIN SELECT RAISE(ABORT,'IMMUTABLE_SOURCE'); END;
        CREATE TRIGGER IF NOT EXISTS immutable_source_del BEFORE DELETE ON source_documents BEGIN SELECT RAISE(ABORT,'IMMUTABLE_SOURCE'); END;
        CREATE TRIGGER IF NOT EXISTS immutable_projection_up BEFORE UPDATE ON projections BEGIN SELECT RAISE(ABORT,'IMMUTABLE_PROJECTION'); END;
        CREATE TRIGGER IF NOT EXISTS immutable_projection_del BEFORE DELETE ON projections BEGIN SELECT RAISE(ABORT,'IMMUTABLE_PROJECTION'); END;
        CREATE TRIGGER IF NOT EXISTS immutable_approval_up BEFORE UPDATE ON publication_approvals BEGIN SELECT RAISE(ABORT,'IMMUTABLE_APPROVAL'); END;
        CREATE TRIGGER IF NOT EXISTS immutable_approval_del BEFORE DELETE ON publication_approvals BEGIN SELECT RAISE(ABORT,'IMMUTABLE_APPROVAL'); END;
        PRAGMA user_version=4;
      `);
      this.run('INSERT OR IGNORE INTO schema_migrations VALUES(?,?)',4,stamp());
    });
  }
  authority(id){return this.all('SELECT * FROM authority_journal WHERE institution_id=? ORDER BY seq',id).map(x=>({...JSON.parse(x.event_json),previousHash:x.previous_hash,hash:x.hash}));}
  appendAuthority(institutionId,action,details){
    const last=this.one('SELECT seq,hash FROM authority_journal WHERE institution_id=? ORDER BY seq DESC LIMIT 1',institutionId);
    const event={seq:(last?.seq??0)+1,institutionId,action,details,at:stamp()};
    const previousHash=last?.hash??'GENESIS';
    const hash=sha({event,previousHash});
    this.run('INSERT INTO authority_journal VALUES(?,?,?,?,?)',institutionId,event.seq,canon(event),previousHash,hash);
    return hash;
  }
  addEvent(item,actor,action,details,from,to){
    const head=this.one('SELECT seq,hash FROM authority_journal WHERE institution_id=? ORDER BY seq DESC LIMIT 1',item.institution_id);
    invariant(!!head,'MISSING_AUTHORITY_JOURNAL');
    return super.addEvent(item,actor,action,{...details,authoritySeq:head.seq,authorityHash:head.hash},from,to);
  }
  sourceCurrencyOK(id,itemId){
    const deps=this.sourceDependencies(id,itemId);
    return deps.every(d=>{const row=this.one('SELECT version FROM source_documents WHERE institution_id=? AND source_id=? ORDER BY version DESC LIMIT 1',id,d.sourceId);return row?.version===d.version;});
  }
  // Trusted local bootstrap is NOT exposed on the HTTP API. Actor history is complete for NEW v0.4 institutions.
  provisionInstitution(id,name,policy){
    invariant(idPattern.test(id)&&isText(name,160),'BAD_INSTITUTION',400);
    invariant(policyValid(policy),'BAD_POLICY',400);
    return this.tx(()=>{
      invariant(!this.one('SELECT id FROM institutions WHERE id=?',id),'INSTITUTION_EXISTS');
      this.run('INSERT INTO institutions(id,name) VALUES(?,?)',id,name);
      this.run('INSERT INTO policies VALUES(?,?,?,?,?)',id,1,canon(policy),sha(policy),stamp());
      this.appendAuthority(id,'INSTITUTION_PROVISIONED',{name,policyVersion:1,policyHash:sha(policy),eligibilityVersion:1});
    });
  }
  provisionActor(institutionId,id,role,eligible=false){
    invariant(idPattern.test(id)&&roles.has(role)&&typeof eligible==='boolean','BAD_ACTOR',400);
    const token=randomBytes(32).toString('hex');
    this.tx(()=>{
      this.institution(institutionId);
      this.run('INSERT INTO actors VALUES(?,?,?,?,?,?)',institutionId,id,role,eligible?1:0,1,sha(token));
      if(role==='member')this.run('UPDATE institutions SET eligibility_version=eligibility_version+1 WHERE id=?',institutionId);
      const v=this.institution(institutionId).eligibility_version;
      this.appendAuthority(institutionId,'ACTOR_PROVISIONED',{actorId:id,role,eligible,active:true,eligibilityVersion:v});
    });
    return token;
  }
  setEligibility(actor,institutionId,memberId,eligible,key){
    this.actorFor(actor,institutionId);invariant(actor.role==='admin','ADMIN_REQUIRED',403);
    return this.idempotent(actor,institutionId,key,{op:'SET_ELIGIBILITY',memberId,eligible},()=>{
      invariant(typeof eligible==='boolean','BAD_ELIGIBILITY',400);
      const target=this.one('SELECT id,role FROM actors WHERE institution_id=? AND id=? AND active=1',institutionId,memberId);
      invariant(target?.role==='member','NOT_MEMBER',404);
      this.run('UPDATE actors SET eligible=? WHERE institution_id=? AND id=?',eligible?1:0,institutionId,memberId);
      this.run('UPDATE institutions SET eligibility_version=eligibility_version+1 WHERE id=?',institutionId);
      const epoch=this.institution(institutionId).eligibility_version;
      this.appendAuthority(institutionId,'ELIGIBILITY_CHANGED',{actorId:memberId,eligible,eligibilityVersion:epoch,by:actor.id});
      return {institutionId,memberId,eligible,eligibilityVersion:epoch};
    });
  }
  revokeActor(actor,institutionId,memberId,key){
    this.actorFor(actor,institutionId);invariant(actor.role==='admin','ADMIN_REQUIRED',403);
    return this.idempotent(actor,institutionId,key,{op:'REVOKE_ACTOR',memberId},()=>{
      const target=this.one('SELECT * FROM actors WHERE institution_id=? AND id=? AND active=1',institutionId,memberId);
      invariant(!!target && actor.id!==memberId,'CANNOT_REVOKE',409);
      this.run('UPDATE actors SET active=0,eligible=0 WHERE institution_id=? AND id=?',institutionId,memberId);
      this.run('UPDATE institutions SET eligibility_version=eligibility_version+1 WHERE id=?',institutionId);
      const epoch=this.institution(institutionId).eligibility_version;
      this.appendAuthority(institutionId,'ACTOR_REVOKED',{actorId:memberId,eligibilityVersion:epoch,by:actor.id});
      return {institutionId,memberId,eligibilityVersion:epoch};
    });
  }
  setPolicy(actor,institutionId,policy,key){
    this.actorFor(actor,institutionId);invariant(actor.role==='admin','ADMIN_REQUIRED',403);
    return this.idempotent(actor,institutionId,key,{op:'SET_POLICY',policy},()=>{
      invariant(policyValid(policy),'BAD_POLICY',400);
      const version=this.institution(institutionId).policy_version+1;
      this.run('INSERT INTO policies VALUES(?,?,?,?,?)',institutionId,version,canon(policy),sha(policy),stamp());
      this.run('UPDATE institutions SET policy_version=? WHERE id=?',version,institutionId);
      this.appendAuthority(institutionId,'POLICY_CHANGED',{policyVersion:version,policyHash:sha(policy),by:actor.id});
      return {institutionId,policyVersion:version,hash:sha(policy)};
    });
  }
  // Never fetches remote content. Explicit synthetic URI only.
  addSource(actor,institutionId,sourceId,text,status,sourceUri,key){
    this.actorFor(actor,institutionId);invariant(actor.role==='admin','ADMIN_REQUIRED',403);
    return this.idempotent(actor,institutionId,key,{op:'ADD_SOURCE',sourceId,text,status,sourceUri},()=>{
      invariant(idPattern.test(sourceId)&&isText(text,50000)&&['DRAFT','PROPOSED','ENACTED','REPEALED','UNKNOWN'].includes(status)&&
        typeof sourceUri==='string'&&sourceUri.startsWith('synthetic:'),'INVALID_SYNTHETIC_SOURCE',400);
      const prior=this.one('SELECT version,hash FROM source_documents WHERE institution_id=? AND source_id=? ORDER BY version DESC LIMIT 1',institutionId,sourceId);
      const version=(prior?.version??0)+1,previousHash=prior?.hash??'GENESIS';
      const digest=sha({institutionId,sourceId,version,text,status,sourceUri,previousHash});
      this.run('INSERT INTO source_documents VALUES(?,?,?,?,?,?,?,?,?)',institutionId,sourceId,version,text,status,sourceUri,previousHash,digest,stamp());
      this.appendAuthority(institutionId,'SOURCE_REVISED',{sourceId,version,hash:digest,by:actor.id});
      return {sourceId,version,hash:digest};
    });
  }
  sourceDependencies(id,itemId){
    return this.all('SELECT source_id,source_version,hash FROM item_sources WHERE institution_id=? AND item_id=? ORDER BY source_id',id,itemId)
      .map(x=>({sourceId:x.source_id,version:x.source_version,hash:x.hash}));
  }
  projections(id,itemId){return this.all('SELECT * FROM projections WHERE institution_id=? AND item_id=? ORDER BY revision',id,itemId)
    .map(x=>({revision:x.revision,content:x.content,reason:x.reason,previousHash:x.previous_hash,hash:x.hash,at:x.at}));}
  publicationApprovals(id,itemId){return this.all('SELECT revision,actor_id AS actorId,at FROM publication_approvals WHERE institution_id=? AND item_id=? ORDER BY revision,actor_id',id,itemId);}
  command(actor,request){
    const {institutionId,itemId,action,key,expectedVersion,payload={}}=request??{};
    if(!extCommands.has(action))return super.command(actor,request);
    this.actorFor(actor,institutionId);
    invariant(itemIdPattern.test(itemId),'BAD_ITEM_ID',400);
    invariant(Number.isSafeInteger(expectedVersion)&&expectedVersion>=0,'EXPECTED_VERSION_REQUIRED',400);
    invariant(payload&&typeof payload==='object'&&!Array.isArray(payload),'BAD_PAYLOAD',400);
    return this.idempotent(actor,institutionId,key,{institutionId,itemId,action,expectedVersion,payload},()=>{
      const item=this.item(institutionId,itemId);
      invariant(item.version===expectedVersion,'VERSION_CONFLICT',409);
      const from=item.state;
      let to=from,details={};
      const latest=this.one('SELECT * FROM projections WHERE institution_id=? AND item_id=? ORDER BY revision DESC LIMIT 1',institutionId,itemId);
      if(action==='ATTACH_SOURCE'){
        invariant(writableStates.has(from)&&(actor.id===item.proposer||actor.role==='clerk'),'SOURCE_ATTACHMENT_FORBIDDEN',403);
        invariant(idPattern.test(payload.sourceId),'BAD_SOURCE_ID',400);
        const source=this.one('SELECT * FROM source_documents WHERE institution_id=? AND source_id=? ORDER BY version DESC LIMIT 1',institutionId,payload.sourceId);
        invariant(source&&source.status!=='UNKNOWN','UNVERIFIED_SOURCE',409);
        this.run('INSERT INTO item_sources VALUES(?,?,?,?,?) ON CONFLICT(institution_id,item_id,source_id) DO UPDATE SET source_version=excluded.source_version,hash=excluded.hash',institutionId,itemId,source.source_id,source.version,source.hash);
        if(from==='AGENDA_SET'||from==='DELIBERATING')this.run('DELETE FROM attendance WHERE institution_id=? AND item_id=?',institutionId,itemId);
        details={sourceId:source.source_id,sourceVersion:source.version,sourceHash:source.hash};
        to='DRAFT'; // changing source attribution invalidates review
      } else if(action==='VOID'){
        invariant(actor.role==='chair'&&voidStates.has(from),'VOID_FORBIDDEN',403);
        invariant(isText(payload.reason,1000),'VOID_REASON_REQUIRED',400);
        to='VOIDED';details={reason:payload.reason};
      } else if(action==='PREPARE_PUBLICATION'||action==='CORRECT_PUBLICATION'){
        invariant(actor.role==='clerk','CLERK_REQUIRED',403);
        invariant(action==='PREPARE_PUBLICATION'?from==='REVIEWED_DEMO':from==='PUBLISHED_PREVIEW','PUBLICATION_STATE_INVALID');
        invariant(isText(payload.content,10000)&&isText(payload.reason,1000),'PUBLICATION_CONTENT_INVALID',400);
        // Never allow raw ballots or arbitrary hidden private evidence in public projection.
        invariant(!payload.content.includes('"votes"')&&!payload.content.includes('"token_hash"'),'PRIVATE_FIELD_DETECTED',400);
        const prev=latest?.hash??'GENESIS',revision=(latest?.revision??0)+1;
        const hash=sha({institutionId,itemId,revision,content:payload.content,reason:payload.reason,previousHash:prev});
        this.run('INSERT INTO projections VALUES(?,?,?,?,?,?,?,?)',institutionId,itemId,revision,payload.content,payload.reason,prev,hash,stamp());
        to='PUBLICATION_REVIEW';details={revision,projectionHash:hash,reason:payload.reason};
      } else if(action==='REVIEW_PUBLICATION'){
        invariant(from==='PUBLICATION_REVIEW'&&!!latest,'PUBLICATION_NOT_PREPARED');
        invariant(actor.role==='release-reviewer'&&actor.id!==item.proposer&&actor.id!==item.reviewer,'INDEPENDENT_REVIEWER_REQUIRED',403);
        invariant(payload.projectionHash===latest.hash,'PROJECTION_HASH_MISMATCH');
        invariant(!this.one('SELECT 1 AS x FROM publication_approvals WHERE institution_id=? AND item_id=? AND revision=? AND actor_id=?',institutionId,itemId,latest.revision,actor.id),'DUPLICATE_APPROVAL');
        this.run('INSERT INTO publication_approvals VALUES(?,?,?,?,?)',institutionId,itemId,latest.revision,actor.id,stamp());
        details={revision:latest.revision,projectionHash:latest.hash,reviewer:actor.id};
      } else if(action==='PUBLISH_PREVIEW'){
        invariant(from==='PUBLICATION_REVIEW'&&!!latest,'PUBLICATION_NOT_PREPARED');
        invariant(actor.role==='clerk'&&actor.id===item.reviewer,'CERTIFYING_CLERK_REQUIRED',403);
        const approvals=this.all('SELECT actor_id FROM publication_approvals WHERE institution_id=? AND item_id=? AND revision=?',institutionId,itemId,latest.revision);
        invariant(approvals.length>=2,'TWO_APPROVALS_REQUIRED');
        invariant(this.institution(institutionId).policy_version===item.locked_policy_version&&this.institution(institutionId).eligibility_version===item.locked_eligibility_version,'AUTHORITY_CHANGED');
        invariant(this.sourceCurrencyOK(institutionId,itemId),'SOURCE_SUPERSEDED');
        to='PUBLISHED_PREVIEW';details={revision:latest.revision,projectionHash:latest.hash,reviewers:approvals.map(x=>x.actor_id).sort(),mode:'SYNTHETIC_PREVIEW_ONLY'};
      }
      this.run('UPDATE items SET state=?,version=? WHERE institution_id=? AND id=?',to,item.version+1,institutionId,itemId);
      const hash=this.addEvent(item,actor,action,details,from,to);
      return {institutionId,itemId,action,state:to,version:item.version+1,hash,details,officialCertification:false};
    });
  }
  // A single committed view: journal, source versions, projections, and active authority are coherent.
  snapshot(actor,id,itemId){
    return this.readTx(()=>{
      this.actorFor(actor,id);
      const item=this.item(id,itemId), institution=this.institution(id);
      return {format:'commonwealth.os.demo-evidence.v2',institution:{id:institution.id,name:institution.name,policyVersion:institution.policy_version,eligibilityVersion:institution.eligibility_version},
        item:{id:item.id,state:item.state,version:item.version,currentRevision:item.current_revision,proposer:item.proposer,lockedRevision:item.locked_revision,lockedPolicyVersion:item.locked_policy_version,lockedEligibilityVersion:item.locked_eligibility_version,reviewer:item.reviewer,outcome:item.outcome},
        policies:this.all('SELECT version,policy_json,hash FROM policies WHERE institution_id=? ORDER BY version',id).map(x=>({version:x.version,policy:JSON.parse(x.policy_json),hash:x.hash})),
        members:this.all('SELECT id,role,eligible,active FROM actors WHERE institution_id=? ORDER BY id',id),
        revisions:this.revisions(id,itemId).map(x=>({revision:x.revision,body:x.body,bodyHash:x.body_hash,previousHash:x.previous_hash,author:x.author,at:x.at})),
        attendance:this.present(id,itemId),votes:this.votes(id,itemId),events:this.events(id,itemId),authorityJournal:this.authority(id),
        sources:this.all('SELECT * FROM source_documents WHERE institution_id=? ORDER BY source_id,version',id).map(x=>({sourceId:x.source_id,version:x.version,text:x.text,status:x.status,sourceUri:x.source_uri,previousHash:x.previous_hash,hash:x.hash,at:x.at})),
        sourceDependencies:this.sourceDependencies(id,itemId),projections:this.projections(id,itemId),publicationApprovals:this.publicationApprovals(id,itemId),
        legalAuthority:'NOT_ASSESSED',officialCertification:false,independentHumanReview:'NOT_PERFORMED'};
    });
  }
  publicPreview(actor,id,itemId){
    this.actorFor(actor,id);
    const item=this.item(id,itemId);
    invariant(item.state==='PUBLISHED_PREVIEW','NOT_PUBLISHED');
    const p=this.projections(id,itemId).at(-1);
    invariant(!!p,'NOT_PUBLISHED');
    const institution=this.institution(id);
    const fresh=institution.policy_version===item.locked_policy_version&&institution.eligibility_version===item.locked_eligibility_version&&this.sourceCurrencyOK(id,itemId);
    return {mode:'SYNTHETIC_PREVIEW_ONLY',institutionId:id,itemId,revision:p.revision,content:p.content,projectionHash:p.hash,authorityStatus:fresh?'NO_CHANGE_DETECTED':'STALE_RECHECK_REQUIRED',officialCertification:false};
  }
}
