import { DatabaseSync } from 'node:sqlite';
import { randomBytes } from 'node:crypto';
import { canon, sha, invariant, policyOK, tallyOK } from './codec.mjs';
import { quorumCheck } from './policy.mjs';

const STATE = Object.freeze({
  SUBMIT: ['DRAFT', 'IN_REVIEW'],
  AGENDA: ['IN_REVIEW', 'AGENDA_SET'],
  BEGIN: ['AGENDA_SET', 'DELIBERATING'],
  ATTEND: ['DELIBERATING', 'DELIBERATING'],
  LOCK: ['DELIBERATING', 'MOTION_LOCKED'],
  OPEN: ['MOTION_LOCKED', 'BALLOT_OPEN'],
  CAST: ['BALLOT_OPEN', 'BALLOT_OPEN'],
  CLOSE: ['BALLOT_OPEN', 'BALLOT_CLOSED'],
  REVIEW: ['BALLOT_CLOSED', 'REVIEWED_DEMO'],
});
const can = (actor, ...roles) => roles.includes(actor.role) && actor.active === 1;
const now = () => new Date().toISOString();
const rand = () => randomBytes(12).toString('hex');

export class Store {
  constructor(file = ':memory:') {
    this.db = new DatabaseSync(file);
    this.db.exec('PRAGMA foreign_keys=ON; PRAGMA busy_timeout=5000; PRAGMA journal_mode=WAL;');
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS institutions (id TEXT PRIMARY KEY,name TEXT NOT NULL,policy_version INTEGER NOT NULL DEFAULT 1,eligibility_version INTEGER NOT NULL DEFAULT 1);
      CREATE TABLE IF NOT EXISTS policies (institution_id TEXT NOT NULL,version INTEGER NOT NULL,policy_json TEXT NOT NULL,hash TEXT NOT NULL,at TEXT NOT NULL,PRIMARY KEY(institution_id,version));
      CREATE TABLE IF NOT EXISTS actors (institution_id TEXT NOT NULL,id TEXT NOT NULL,role TEXT NOT NULL,eligible INTEGER NOT NULL,active INTEGER NOT NULL,token_hash TEXT UNIQUE NOT NULL,PRIMARY KEY(institution_id,id));
      CREATE TABLE IF NOT EXISTS items (institution_id TEXT NOT NULL,id TEXT NOT NULL,state TEXT NOT NULL,version INTEGER NOT NULL,current_revision INTEGER NOT NULL,proposer TEXT NOT NULL,locked_revision INTEGER,locked_policy_version INTEGER,locked_eligibility_version INTEGER,reviewer TEXT,outcome TEXT,PRIMARY KEY(institution_id,id));
      CREATE TABLE IF NOT EXISTS revisions (institution_id TEXT NOT NULL,item_id TEXT NOT NULL,revision INTEGER NOT NULL,body TEXT NOT NULL,body_hash TEXT NOT NULL,previous_hash TEXT NOT NULL,author TEXT NOT NULL,at TEXT NOT NULL,PRIMARY KEY(institution_id,item_id,revision));
      CREATE TABLE IF NOT EXISTS attendance (institution_id TEXT NOT NULL,item_id TEXT NOT NULL,actor_id TEXT NOT NULL,PRIMARY KEY(institution_id,item_id,actor_id));
      CREATE TABLE IF NOT EXISTS votes (institution_id TEXT NOT NULL,item_id TEXT NOT NULL,actor_id TEXT NOT NULL,choice TEXT NOT NULL,PRIMARY KEY(institution_id,item_id,actor_id));
      CREATE TABLE IF NOT EXISTS events (institution_id TEXT NOT NULL,item_id TEXT NOT NULL,seq INTEGER NOT NULL,event_json TEXT NOT NULL,previous_hash TEXT NOT NULL,hash TEXT NOT NULL,PRIMARY KEY(institution_id,item_id,seq));
      CREATE TABLE IF NOT EXISTS requests (institution_id TEXT NOT NULL,actor_id TEXT NOT NULL,command_key TEXT NOT NULL,request_hash TEXT NOT NULL,response_json TEXT NOT NULL,PRIMARY KEY(institution_id,actor_id,command_key));
      CREATE TRIGGER IF NOT EXISTS revisions_no_update BEFORE UPDATE ON revisions BEGIN SELECT RAISE(ABORT,'IMMUTABLE_REVISION'); END;
      CREATE TRIGGER IF NOT EXISTS revisions_no_delete BEFORE DELETE ON revisions BEGIN SELECT RAISE(ABORT,'IMMUTABLE_REVISION'); END;
      CREATE TRIGGER IF NOT EXISTS policies_no_update BEFORE UPDATE ON policies BEGIN SELECT RAISE(ABORT,'IMMUTABLE_POLICY'); END;
      CREATE TRIGGER IF NOT EXISTS policies_no_delete BEFORE DELETE ON policies BEGIN SELECT RAISE(ABORT,'IMMUTABLE_POLICY'); END;
      CREATE TRIGGER IF NOT EXISTS events_no_update BEFORE UPDATE ON events BEGIN SELECT RAISE(ABORT,'IMMUTABLE_EVENT'); END;
      CREATE TRIGGER IF NOT EXISTS events_no_delete BEFORE DELETE ON events BEGIN SELECT RAISE(ABORT,'IMMUTABLE_EVENT'); END;
      CREATE TRIGGER IF NOT EXISTS votes_no_update BEFORE UPDATE ON votes BEGIN SELECT RAISE(ABORT,'IMMUTABLE_VOTE'); END;
      CREATE TRIGGER IF NOT EXISTS votes_no_delete BEFORE DELETE ON votes BEGIN SELECT RAISE(ABORT,'IMMUTABLE_VOTE'); END;
    `);
  }
  close() { this.db.close(); }
  one(sql, ...args) { return this.db.prepare(sql).get(...args); }
  all(sql, ...args) { return this.db.prepare(sql).all(...args); }
  run(sql, ...args) { return this.db.prepare(sql).run(...args); }
  tx(fn) { this.db.exec('BEGIN IMMEDIATE'); try { const result=fn(); this.db.exec('COMMIT'); return result; } catch(e){ this.db.exec('ROLLBACK'); throw e; } }

  readTx(fn) { this.db.exec('BEGIN'); try { const result=fn(); this.db.exec('COMMIT'); return result; } catch(e){ this.db.exec('ROLLBACK'); throw e; } }
  // Bootstrap is a local trusted-administrator operation, never exposed over HTTP.
  provisionInstitution(id, name, policy) {
    invariant(/^[a-z][a-z0-9-]{1,63}$/.test(id), 'BAD_INSTITUTION', 400);
    invariant(policyOK(policy), 'BAD_POLICY', 400);
    return this.tx(() => {
      invariant(!this.one('SELECT id FROM institutions WHERE id=?',id), 'INSTITUTION_EXISTS');
      this.run('INSERT INTO institutions(id,name) VALUES(?,?)',id,name);
      this.run('INSERT INTO policies VALUES(?,?,?,?,?)',id,1,canon(policy),sha(policy),now());
    });
  }
  provisionActor(institutionId, id, role, eligible = false) {
    invariant(['admin','chair','clerk','member','auditor','release-reviewer'].includes(role), 'BAD_ROLE',400);
    invariant(/^[a-z][a-z0-9-]{1,63}$/.test(id), 'BAD_ACTOR_ID',400);
    const token = randomBytes(32).toString('hex');
    return this.tx(() => {
      invariant(this.one('SELECT id FROM institutions WHERE id=?',institutionId), 'UNKNOWN_INSTITUTION',404);
      this.run('INSERT INTO actors VALUES(?,?,?,?,?,?)',institutionId,id,role,eligible?1:0,1,sha(token));
      return token;
    });
  }
  authenticate(token) {
    invariant(typeof token==='string' && /^[a-f0-9]{64}$/.test(token),'UNAUTHENTICATED',401);
    const a = this.one('SELECT * FROM actors WHERE token_hash=? AND active=1',sha(token));
    invariant(!!a,'UNAUTHENTICATED',401);
    return {institutionId:a.institution_id,id:a.id,role:a.role,eligible:a.eligible,active:a.active};
  }
  actorFor(a, institutionId) {
    invariant(a && a.institutionId===institutionId && a.active===1,'FORBIDDEN_TENANT',403);
    const latest=this.one('SELECT role,eligible,active FROM actors WHERE institution_id=? AND id=?',institutionId,a.id);
    invariant(latest?.active===1 && latest.role===a.role && latest.eligible===a.eligible,'ACTOR_SESSION_STALE',403);
    return a;
  }
  institution(id) {
    const i=this.one('SELECT * FROM institutions WHERE id=?',id);
    invariant(!!i,'UNKNOWN_INSTITUTION',404); return i;
  }
  activePolicy(id) {
    const i=this.institution(id);
    const row=this.one('SELECT * FROM policies WHERE institution_id=? AND version=?',id,i.policy_version);
    return { ...JSON.parse(row.policy_json), version:row.version, hash:row.hash };
  }
  setEligibility(actor, institutionId, memberId, eligible, key) {
    return this.adminAction(actor,institutionId,key,{op:'SET_ELIGIBILITY',memberId,eligible},()=>{
      invariant(typeof eligible==='boolean','BAD_ELIGIBILITY',400);
      const target=this.one('SELECT id,role FROM actors WHERE institution_id=? AND id=?',institutionId,memberId);
      invariant(target?.role==='member','NOT_MEMBER',404);
      this.run('UPDATE actors SET eligible=? WHERE institution_id=? AND id=?',eligible?1:0,institutionId,memberId);
      this.run('UPDATE institutions SET eligibility_version=eligibility_version+1 WHERE id=?',institutionId);
      return {institutionId,memberId,eligible,eligibilityVersion:this.institution(institutionId).eligibility_version};
    });
  }
  setPolicy(actor,institutionId,policy,key) {
    return this.adminAction(actor,institutionId,key,{op:'SET_POLICY',policy},()=>{
      invariant(policyOK(policy),'BAD_POLICY',400);
      const v=this.institution(institutionId).policy_version+1;
      this.run('INSERT INTO policies VALUES(?,?,?,?,?)',institutionId,v,canon(policy),sha(policy),now());
      this.run('UPDATE institutions SET policy_version=? WHERE id=?',v,institutionId);
      return {institutionId,policyVersion:v,hash:sha(policy)};
    });
  }
  adminAction(actor,id,key,request,action) {
    this.actorFor(actor,id); invariant(can(actor,'admin'),'ADMIN_REQUIRED',403);
    return this.idempotent(actor,id,key,request,action);
  }
  idempotent(actor,id,key,request,action) {
    invariant(typeof key==='string' && /^[A-Za-z0-9._:-]{8,120}$/.test(key),'BAD_IDEMPOTENCY_KEY',400);
    const digest=sha(request);
    return this.tx(()=>{
      this.actorFor(actor,id);
      const prior=this.one('SELECT * FROM requests WHERE institution_id=? AND actor_id=? AND command_key=?',id,actor.id,key);
      if(prior){invariant(prior.request_hash===digest,'IDEMPOTENCY_CONFLICT',409);return JSON.parse(prior.response_json);}
      const result=action();
      this.run('INSERT INTO requests VALUES(?,?,?,?,?)',id,actor.id,key,digest,canon(result));
      return result;
    });
  }
  item(id,itemId) {
    const item=this.one('SELECT * FROM items WHERE institution_id=? AND id=?',id,itemId);
    invariant(!!item,'UNKNOWN_ITEM',404);return item;
  }
  revisions(id,itemId) { return this.all('SELECT * FROM revisions WHERE institution_id=? AND item_id=? ORDER BY revision',id,itemId); }
  votes(id,itemId) { return this.all('SELECT actor_id AS actorId,choice FROM votes WHERE institution_id=? AND item_id=? ORDER BY actor_id',id,itemId); }
  present(id,itemId) { return this.all('SELECT actor_id AS actorId FROM attendance WHERE institution_id=? AND item_id=? ORDER BY actor_id',id,itemId).map(x=>x.actorId); }
  events(id,itemId) { return this.all('SELECT * FROM events WHERE institution_id=? AND item_id=? ORDER BY seq',id,itemId).map(e=>({...JSON.parse(e.event_json),previousHash:e.previous_hash,hash:e.hash})); }
  addEvent(item,actor,action,details,from,to) {
    const previous=this.one('SELECT seq,hash FROM events WHERE institution_id=? AND item_id=? ORDER BY seq DESC LIMIT 1',item.institution_id,item.id);
    const event={seq:(previous?.seq??0)+1,institutionId:item.institution_id,itemId:item.id,actorId:actor.id,actorRole:actor.role,action,from,to,details,at:now()};
    const previousHash=previous?.hash??'GENESIS';
    const hash=sha({event,previousHash});
    this.run('INSERT INTO events VALUES(?,?,?,?,?,?)',item.institution_id,item.id,event.seq,canon(event),previousHash,hash);
    return hash;
  }
  addRevision(id,itemId,body,actor) {
    invariant(typeof body==='string'&&body.trim().length>0&&body.length<=20000,'INVALID_TEXT',400);
    const prev=this.one('SELECT revision,body_hash FROM revisions WHERE institution_id=? AND item_id=? ORDER BY revision DESC LIMIT 1',id,itemId);
    const revision=(prev?.revision??0)+1;
    const prevHash=prev?.body_hash??'GENESIS';
    const bodyHash=sha({institutionId:id,itemId,revision,body,previousHash:prevHash});
    this.run('INSERT INTO revisions VALUES(?,?,?,?,?,?,?,?)',id,itemId,revision,body,bodyHash,prevHash,actor.id,now());
    return {revision,bodyHash};
  }
  // Single authoritative command path: all checks and mutations occur inside BEGIN IMMEDIATE.
  command(actor,request) {
    const {institutionId,itemId,action,key,expectedVersion,payload={}}=request??{};
    this.actorFor(actor,institutionId);
    invariant(typeof itemId==='string'&&/^[a-z][a-z0-9-]{2,63}$/.test(itemId),'BAD_ITEM_ID',400);
    invariant(typeof action==='string'&&typeof payload==='object'&&payload!==null&&!Array.isArray(payload),'BAD_ACTION',400);
    invariant(Number.isSafeInteger(expectedVersion)&&expectedVersion>=0,'EXPECTED_VERSION_REQUIRED',400);
    return this.idempotent(actor,institutionId,key,{institutionId,itemId,action,expectedVersion,payload},()=>{
      if(action==='CREATE') {
        invariant(can(actor,'member','chair'),'PROPOSER_REQUIRED',403);
        invariant(expectedVersion===0,'VERSION_CONFLICT');
        invariant(!this.one('SELECT id FROM items WHERE institution_id=? AND id=?',institutionId,itemId),'ITEM_EXISTS');
        this.run('INSERT INTO items(institution_id,id,state,version,current_revision,proposer) VALUES(?,?,?,?,?,?)',institutionId,itemId,'DRAFT',1,1,actor.id);
        const revision=this.addRevision(institutionId,itemId,payload.body,actor);
        const item=this.item(institutionId,itemId);
        this.addEvent(item,actor,action,{revision:revision.revision,bodyHash:revision.bodyHash},null,'DRAFT');
        return {institutionId,itemId,state:'DRAFT',version:1,revision:1};
      }
      const item=this.item(institutionId,itemId);
      invariant(item.version===expectedVersion,'VERSION_CONFLICT');
      const old=item.state;
      const transitions={SUBMIT:'IN_REVIEW',AGENDA:'AGENDA_SET',BEGIN:'DELIBERATING',ATTEND:'DELIBERATING',LOCK:'MOTION_LOCKED',OPEN:'BALLOT_OPEN',CAST:'BALLOT_OPEN',CLOSE:'BALLOT_CLOSED',REVIEW:'REVIEWED_DEMO'};
      let next=transitions[action];let details={};let revision=item.current_revision;
      if(action==='REVISE') {
        invariant(['DRAFT','IN_REVIEW','AGENDA_SET','DELIBERATING'].includes(old),'REVISION_LOCKED');
        invariant(item.proposer===actor.id||can(actor,'clerk'),'REVISION_FORBIDDEN',403);
        const result=this.addRevision(institutionId,itemId,payload.body,actor);
        revision=result.revision;next='DRAFT';
        if(old==='AGENDA_SET'||old==='DELIBERATING')this.run('DELETE FROM attendance WHERE institution_id=? AND item_id=?',institutionId,itemId);
        details={revision,bodyHash:result.bodyHash};
      } else {
        invariant(Object.hasOwn(transitions,action),'UNKNOWN_ACTION',400);
        const allowedFrom=STATE[action][0];invariant(old===allowedFrom,'INVALID_TRANSITION');
        if(['SUBMIT'].includes(action)) invariant(item.proposer===actor.id||can(actor,'chair'),'PROPOSER_REQUIRED',403);
        if(['AGENDA','BEGIN','LOCK','OPEN','CLOSE'].includes(action)) invariant(can(actor,'chair'),'CHAIR_REQUIRED',403);
        if(action==='ATTEND') {
          invariant(can(actor,'clerk'),'CLERK_REQUIRED',403);
          invariant(Array.isArray(payload.attendees)&&payload.attendees.length<=500,'INVALID_ATTENDANCE',400);
          const unique=new Set(payload.attendees);
          invariant(unique.size===payload.attendees.length,'DUPLICATE_ATTENDANCE',400);
          for(const id of unique){const a=this.one('SELECT * FROM actors WHERE institution_id=? AND id=?',institutionId,id);invariant(a?.eligible===1&&a.role==='member'&&a.active===1,'INELIGIBLE_ATTENDEE',403);}
          this.run('DELETE FROM attendance WHERE institution_id=? AND item_id=?',institutionId,itemId);
          for(const id of unique) this.run('INSERT INTO attendance VALUES(?,?,?)',institutionId,itemId,id);
          details={attendees:[...unique].sort()};
        }
        if(action==='LOCK') {
          const i=this.institution(institutionId),policy=this.activePolicy(institutionId);
          invariant(quorumCheck(policy,this.present(institutionId,itemId).length,this.all('SELECT id FROM actors WHERE institution_id=? AND role=? AND eligible=1 AND active=1',institutionId,'member').length)===true,'QUORUM_UNMET');
          this.run('UPDATE items SET locked_revision=?,locked_policy_version=?,locked_eligibility_version=? WHERE institution_id=? AND id=?',revision,i.policy_version,i.eligibility_version,institutionId,itemId);
          details={lockedRevision:revision,policyVersion:i.policy_version,policyHash:policy.hash,eligibilityVersion:i.eligibility_version,attendees:this.present(institutionId,itemId),eligibleRoster:this.all('SELECT id FROM actors WHERE institution_id=? AND role=? AND eligible=1 AND active=1 ORDER BY id',institutionId,'member').map(x=>x.id),sources:typeof this.sourceDependencies==='function'?this.sourceDependencies(institutionId,itemId):[]};
        }
        if(['OPEN','CAST','CLOSE','REVIEW'].includes(action)) {
          const i=this.institution(institutionId);
          invariant(item.locked_policy_version===i.policy_version&&item.locked_eligibility_version===i.eligibility_version,'AUTHORITY_CHANGED');
          invariant(item.locked_revision===item.current_revision,'MOTION_CHANGED');
          if(typeof this.sourceCurrencyOK==='function')invariant(this.sourceCurrencyOK(institutionId,itemId),'SOURCE_SUPERSEDED');
          details={...details,policyVersion:i.policy_version,eligibilityVersion:i.eligibility_version,lockedRevision:item.locked_revision};
        }
        if(action==='CAST') {
          invariant(can(actor,'member')&&actor.eligible===1,'NOT_ELIGIBLE',403);
          invariant(this.present(institutionId,itemId).includes(actor.id),'NOT_PRESENT',403);
          invariant(['yes','no','abstain'].includes(payload.choice),'INVALID_CHOICE',400);
          invariant(!this.one('SELECT actor_id FROM votes WHERE institution_id=? AND item_id=? AND actor_id=?',institutionId,itemId,actor.id),'DUPLICATE_CAST');
          this.run('INSERT INTO votes VALUES(?,?,?,?)',institutionId,itemId,actor.id,payload.choice);
          details={...details,voter:actor.id,choice:payload.choice};
        }
        if(action==='REVIEW') {
          invariant(can(actor,'clerk'),'CLERK_REQUIRED',403);
          invariant(actor.id!==item.proposer,'SEPARATION_OF_DUTIES',403);
          invariant(!this.one('SELECT actor_id FROM votes WHERE institution_id=? AND item_id=? AND actor_id=?',institutionId,itemId,actor.id),'REVIEWER_VOTED',403);
          const policy=this.activePolicy(institutionId), present=this.present(institutionId,itemId),votes=this.votes(institutionId,itemId);
          invariant(quorumCheck(policy,present.length,this.all('SELECT id FROM actors WHERE institution_id=? AND role=? AND eligible=1 AND active=1',institutionId,'member').length)===true,'QUORUM_UNMET');
          const result=tallyOK(policy,votes,{presentCount:present.length,eligibleCount:this.all('SELECT id FROM actors WHERE institution_id=? AND role=? AND eligible=1 AND active=1',institutionId,'member').length});
          const outcome=result.accepted?'SUPPORTED_IN_SIMULATION':'REJECTED_IN_SIMULATION';
          this.run('UPDATE items SET reviewer=?,outcome=? WHERE institution_id=? AND id=?',actor.id,outcome,institutionId,itemId);
          details={...details,outcome,counts:{yes:result.yes,no:result.no,abstain:result.abstain},reviewer:actor.id};
        }
      }
      const newVersion=item.version+1;
      this.run('UPDATE items SET state=?,version=?,current_revision=? WHERE institution_id=? AND id=?',next,newVersion,revision,institutionId,itemId);
      const hash=this.addEvent(item,actor,action,details,old,next);
      return {institutionId,itemId,state:next,version:newVersion,revision,hash,...(details.outcome?{outcome:details.outcome}:{})};
    });
  }
  snapshot(actor,id,itemId) {
    return this.readTx(()=>{
    this.actorFor(actor,id);
    const item=this.item(id,itemId);
    const institution=this.institution(id);
    const policyRows=this.all('SELECT version,policy_json,hash FROM policies WHERE institution_id=? ORDER BY version',id).map(x=>({version:x.version,policy:JSON.parse(x.policy_json),hash:x.hash}));
    const members=this.all('SELECT id,role,eligible,active FROM actors WHERE institution_id=? ORDER BY id',id);
    const revisions=this.revisions(id,itemId).map(x=>({revision:x.revision,body:x.body,bodyHash:x.body_hash,previousHash:x.previous_hash,author:x.author,at:x.at}));
    return {format:'commonwealth.os.demo-evidence.v1',institution:{id:institution.id,name:institution.name,policyVersion:institution.policy_version,eligibilityVersion:institution.eligibility_version},item:{id:item.id,state:item.state,version:item.version,currentRevision:item.current_revision,proposer:item.proposer,lockedRevision:item.locked_revision,lockedPolicyVersion:item.locked_policy_version,lockedEligibilityVersion:item.locked_eligibility_version,reviewer:item.reviewer,outcome:item.outcome},policies:policyRows,members,revisions,attendance:this.present(id,itemId),votes:this.votes(id,itemId),events:this.events(id,itemId),legalAuthority:'NOT_ASSESSED',officialCertification:false};
    });
  }
}
