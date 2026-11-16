// Commonwealth participation ledger v1.3. Synthetic-only: no legal or voting authority.
// Reuses the existing SQLite transaction and demo actor system. PostgreSQL not yet implemented.
import { randomBytes } from 'node:crypto';
import { seededBoard, transact, validateBoard, publicDossier, CHOICES } from '../../browser/participation-core.mjs';
import { canon, sha, invariant } from './codec.mjs';

export const PARTICIPATION_SCOPE=Object.freeze({
  'student-demo':'UAH','union-demo':'HOA','municipal-demo':'HSV'
});
const GENESIS='GENESIS';
const memberActions=new Set(['CREATE','COMMENT','ADVISE','AMEND','CORRECTION']);
const clerkActions=new Set(['RESPOND_COMMENT','REVIEW_AMEND','MILESTONE']);
const chairActions=new Set(['STAGE']);
const allowed=new Set([...memberActions,...clerkActions,...chairActions]);
const clone=x=>JSON.parse(JSON.stringify(x));

function initial(institutionId){
  const code=PARTICIPATION_SCOPE[institutionId];
  invariant(!!code,'PARTICIPATION_TENANT_NOT_CONFIGURED',404);
  const board=seededBoard();
  board.proposals=board.proposals.filter(p=>p.institution===code);
  validateBoard(board);
  return board;
}
function authorize(actor,command){
  const type=command?.type;
  invariant(allowed.has(type),'PARTICIPATION_ACTION_UNSUPPORTED',400);
  if(memberActions.has(type)) invariant(actor.role==='member' && actor.eligible===1,'PARTICIPATION_MEMBER_REQUIRED',403);
  if(clerkActions.has(type)) invariant(actor.role==='clerk','PARTICIPATION_CLERK_REQUIRED',403);
  if(chairActions.has(type)) invariant(actor.role==='chair','PARTICIPATION_CHAIR_REQUIRED',403);
}
function normalize(actor,cmd,scope){
  invariant(cmd && typeof cmd==='object' && !Array.isArray(cmd),'PARTICIPATION_COMMAND_REQUIRED',400);
  const clean={...cmd,institution:scope};
  // UI role dropdown is never authority. Only authenticated server actor may act as steward.
  delete clean.role;
  if(clerkActions.has(cmd.type)||chairActions.has(cmd.type))clean.role='DEMO_STEWARD';
  return clean;
}
export class ParticipationLedger {
  constructor(store){
    this.store=store;
    store.db.exec([
      'CREATE TABLE IF NOT EXISTS participation_streams (institution_id TEXT PRIMARY KEY, seq INTEGER NOT NULL, head_hash TEXT NOT NULL);',
      'CREATE TABLE IF NOT EXISTS participation_events (institution_id TEXT NOT NULL, seq INTEGER NOT NULL, event_json TEXT NOT NULL, previous_hash TEXT NOT NULL, hash TEXT NOT NULL, PRIMARY KEY(institution_id,seq));',
      'CREATE TABLE IF NOT EXISTS participation_requests (institution_id TEXT NOT NULL, actor_id TEXT NOT NULL, request_key TEXT NOT NULL, request_hash TEXT NOT NULL, response_json TEXT NOT NULL, PRIMARY KEY(institution_id,actor_id,request_key));',
      "CREATE TRIGGER IF NOT EXISTS participation_events_no_update BEFORE UPDATE ON participation_events BEGIN SELECT RAISE(ABORT,'IMMUTABLE_PARTICIPATION_EVENT'); END;",
      "CREATE TRIGGER IF NOT EXISTS participation_events_no_delete BEFORE DELETE ON participation_events BEGIN SELECT RAISE(ABORT,'IMMUTABLE_PARTICIPATION_EVENT'); END;"
    ].join('\n'));
  }
  // Full private commands never leave the authenticated ledger service.
  // Replay verifies chain continuity, state transitions and source fixture dependency.
  replay(institutionId){
    let board=initial(institutionId);
    const seedHash=sha(board);
    const events=this.store.all('SELECT * FROM participation_events WHERE institution_id=? ORDER BY seq',institutionId);
    let head=GENESIS, seq=0;
    for(const row of events){
      const e=JSON.parse(row.event_json);
      invariant(row.seq===seq+1 && e.seq===row.seq && e.institutionId===institutionId,'PARTICIPATION_SEQUENCE_CORRUPT');
      invariant(row.previous_hash===head && sha({event:e,previousHash:head})===row.hash,'PARTICIPATION_CHAIN_CORRUPT');
      invariant(e.seedHash===seedHash,'PARTICIPATION_SEED_CHANGED');
      if(e.command.type!=='ADVISE'){
        const applied=transact(board,e.command);
        invariant(applied.ok,'PARTICIPATION_REPLAY_REJECTED');
        board=applied.board;
      } else {
        invariant(CHOICES.includes(e.command.choice),'PARTICIPATION_ADVICE_CORRUPT');
        const proposal=board.proposals.find(p=>p.institution===e.command.institution&&p.id===e.command.id);
        invariant(!!proposal && ['OPEN','REVIEW'].includes(proposal.stage),'PARTICIPATION_REPLAY_REJECTED');
      }
      invariant(sha(board)===e.stateHash,'PARTICIPATION_STATE_CORRUPT');
      head=row.hash;seq=row.seq;
    }
    const stream=this.store.one('SELECT seq,head_hash FROM participation_streams WHERE institution_id=?',institutionId);
    invariant((stream?.seq??0)===seq && (stream?.head_hash??GENESIS)===head,'PARTICIPATION_HEAD_CORRUPT');
    validateBoard(board);
    return {board,events:events.map(r=>JSON.parse(r.event_json)),headHash:head,sequence:seq,seedHash};
  }
  command(actor,request){
    const {institutionId,key,expectedSequence,expectedRevision,command}=request??{};
    this.store.actorFor(actor,institutionId);
    const scope=PARTICIPATION_SCOPE[institutionId];
    invariant(!!scope,'PARTICIPATION_TENANT_NOT_CONFIGURED',404);
    invariant(typeof key==='string' && /^[a-zA-Z0-9._:-]{8,120}$/.test(key),'PARTICIPATION_KEY_REQUIRED',400);
    invariant(Number.isSafeInteger(expectedSequence)&&expectedSequence>=0,'PARTICIPATION_SEQUENCE_REQUIRED',400);
    invariant(Number.isSafeInteger(expectedRevision)&&expectedRevision>=0,'PARTICIPATION_REVISION_REQUIRED',400);
    authorize(actor,command);
    const cmd=normalize(actor,command,scope);
    const requestHash=sha({institutionId,cmd,expectedSequence,expectedRevision});
    return this.store.tx(()=>{
      this.store.actorFor(actor,institutionId);
      authorize(actor,command);
      const prior=this.store.one('SELECT * FROM participation_requests WHERE institution_id=? AND actor_id=? AND request_key=?',institutionId,actor.id,key);
      if(prior){
        invariant(prior.request_hash===requestHash,'PARTICIPATION_IDEMPOTENCY_CONFLICT');
        return JSON.parse(prior.response_json);
      }
      const state=this.replay(institutionId);
      invariant(state.sequence===expectedSequence,'PARTICIPATION_SEQUENCE_CONFLICT');
      const before=cmd.type==='CREATE'?null:state.board.proposals.find(p=>p.id===cmd.id&&p.institution===scope);
      invariant(cmd.type==='CREATE' ? expectedRevision===0 : !!before&&before.revision===expectedRevision,'PARTICIPATION_REVISION_CONFLICT');
      const check=transact(state.board,cmd);
      invariant(check.ok,'PARTICIPATION_INVALID_'+(check.reason||'COMMAND').replace(/[^A-Za-z0-9]+/g,'_').slice(0,90));
      // Each actor's advisory position remains a PRIVATE event, outside public board state.
      // A later accepted amendment never carries a previous-revision stance forward.
      const board=cmd.type==='ADVISE'?state.board:check.board;
      const event={
        seq:state.sequence+1,institutionId,actorId:actor.id,actorRole:actor.role,
        command:cmd,at:new Date().toISOString(),nonce:randomBytes(16).toString('hex'),
        seedHash:state.seedHash,stateHash:sha(board)
      };
      const hash=sha({event,previousHash:state.headHash});
      this.store.run('INSERT INTO participation_events VALUES(?,?,?,?,?)',institutionId,event.seq,canon(event),state.headHash,hash);
      this.store.run('INSERT INTO participation_streams VALUES(?,?,?) ON CONFLICT(institution_id) DO UPDATE SET seq=excluded.seq,head_hash=excluded.head_hash',institutionId,event.seq,hash);
      const result={mode:'SYNTHETIC_ONLY',institutionId,sequence:event.seq,revision:cmd.type==='CREATE'?1:(board.proposals.find(p=>p.id===cmd.id)?.revision??null),headHash:hash,accepted:true,official:false};
      this.store.run('INSERT INTO participation_requests VALUES(?,?,?,?,?)',institutionId,actor.id,key,requestHash,canon(result));
      return result;
    });
  }
  // Tenant-scoped read projection: private position/remarks are visible only to
  // their submitting actor or to the fictional reviewer explicitly allowed to review.
  view(actor,institutionId){
    return this.store.readTx(()=>{
      this.store.actorFor(actor,institutionId);
      const state=this.replay(institutionId),board=clone(state.board);
      const reviewer=['clerk','auditor','admin','chair'].includes(actor.role);
      const ownerOf={};
      const amendments={};
      const corrections=new Set();
      let correctionIndex=0;
      for(const event of state.events){
        const c=event.command;
        if(c.type==='COMMENT'){
          const id=c.id;
          ownerOf[id]??=[];
          ownerOf[id].push(event.actorId);
        }
        if(c.type==='AMEND'){
          amendments[c.id]??=[];
          amendments[c.id].push(event.actorId);
        }
        if(c.type==='CORRECTION') {correctionIndex++;if(event.actorId===actor.id)corrections.add('R-'+correctionIndex);}
      }
      // Resolve advice revision at event time by replay of public events; required
      // because a response to v1 must never be presented as a v2 response.
      let walk=initial(institutionId);
      const mine=new Map();
      for(const event of state.events){
        const c=event.command;
        if(c.type==='ADVISE' && event.actorId===actor.id){
          const p=walk.proposals.find(x=>x.id===c.id);
          if(p)mine.set(c.id+':'+p.revision,{revision:p.revision,author:'FICTIONAL_VISITOR',choice:c.choice});
        } else if(c.type!=='ADVISE')walk=transact(walk,c).board;
      }
      for(const p of board.proposals){
        p.positions=[...mine.entries()].filter(([k])=>k.startsWith(p.id+':')).map(([,x])=>x);
        p.comments=p.comments.map((c,i)=>{
          const own=ownerOf[p.id]?.[i]===actor.id;
          return (own||reviewer)?c:{...c,text:'[Contribution withheld pending moderation]',author:'REDACTED',response:c.response?'[Reviewer response withheld]':undefined};
        });
        p.amendments=p.amendments.map((a,i)=>{
          const own=amendments[p.id]?.[i]===actor.id;
          return (own||reviewer||a.status==='ACCEPTED')?a:{...a,text:'[Proposed text withheld pending review]',reason:'[Withheld]',author:'REDACTED'};
        });
      }
      board.corrections=board.corrections.filter(c=>corrections.has(c.id));
      return {mode:'SYNTHETIC_ONLY',board,sequence:state.sequence,headHash:state.headHash,integrity:'REPLAYED_LOCAL_CHAIN',official:false};
    });
  }
  dossier(actor,institutionId,proposalId){
    return this.store.readTx(()=>{
      this.store.actorFor(actor,institutionId);
      const state=this.replay(institutionId);
      const proposal=state.board.proposals.find(p=>p.id===proposalId);
      invariant(!!proposal,'PARTICIPATION_PROPOSAL_NOT_FOUND',404);
      return {...publicDossier(proposal),ledger:{sequence:state.sequence,headHash:state.headHash,verification:'LOCAL_REPLAY_ONLY',externalAnchor:false},certification:'NOT_CERTIFIED',individualAdviceIncluded:false};
    });
  }
}
