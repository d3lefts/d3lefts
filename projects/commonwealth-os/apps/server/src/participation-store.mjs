// Fictional, localhost-only persistence adapter. Requires the existing Store's
// authenticated actorFor/idempotent transaction wrapper. Never authorizes votes.
import { createHash } from 'node:crypto';
import {INSTITUTIONS,seededBoard,transact,budgetSlate,validateBoard} from '../../browser/participation-core.mjs';

const canonical=v=>v===null||typeof v!=='object'?JSON.stringify(v):Array.isArray(v)?'['+v.map(canonical).join(',')+']':'{'+Object.keys(v).sort().map(k=>JSON.stringify(k)+':'+canonical(v[k])).join(',')+'}';
const hash=v=>createHash('sha256').update(canonical(v)).digest('hex');
const fail=(code,http=409)=>{const e=new Error(code);e.code=code;e.http=http;throw e;};
const STEWARDS=new Set(['admin','chair','clerk']);
const EVERYONE=new Set(['admin','chair','clerk','member']);
const STEWARD_ACTIONS=new Set(['RESPOND_COMMENT','REVIEW_AMEND','STAGE','MILESTONE','BUDGET']);
const VISITOR_ACTIONS=new Set(['CREATE','COMMENT','AMEND','CORRECTION']);
const MAX_COMMAND=8_000;
const INITIAL_HASH='GENESIS';

function initialBoard(institution){
 const seed=seededBoard();
 const board={...seed,proposals:seed.proposals.filter(p=>p.institution===institution),corrections:[]};
 validateBoard(board);
 return board;
}
export class ParticipationStore {
 constructor(store){
  this.store=store;
  this.db=store.db;
  this.db.exec(`
   CREATE TABLE IF NOT EXISTS participation_boards (
    institution_id TEXT PRIMARY KEY, version INTEGER NOT NULL,
    board_json TEXT NOT NULL, board_hash TEXT NOT NULL, head_hash TEXT NOT NULL);
   CREATE TABLE IF NOT EXISTS participation_events (
    institution_id TEXT NOT NULL, version INTEGER NOT NULL,
    actor_id TEXT NOT NULL, command_json TEXT NOT NULL, command_hash TEXT NOT NULL,
    board_hash TEXT NOT NULL, previous_hash TEXT NOT NULL, event_hash TEXT NOT NULL,
    PRIMARY KEY(institution_id,version));
   CREATE TRIGGER IF NOT EXISTS participation_events_immutable_update BEFORE UPDATE ON participation_events
    BEGIN SELECT RAISE(ABORT,'IMMUTABLE_PARTICIPATION_EVENT'); END;
   CREATE TRIGGER IF NOT EXISTS participation_events_immutable_delete BEFORE DELETE ON participation_events
    BEGIN SELECT RAISE(ABORT,'IMMUTABLE_PARTICIPATION_EVENT'); END;
  `);
 }
 #map(actor,institution){
  if(!INSTITUTIONS[institution])fail('UNKNOWN_SYNTHETIC_PARTICIPATION_INSTITUTION',404);
  const expected={UAH:'student-demo',HOA:'hoa-demo',HSV:'municipal-demo'}[institution];
  this.store.actorFor(actor,expected);
 }
 #load(institution){
  const row=this.db.prepare('SELECT * FROM participation_boards WHERE institution_id=?').get(institution);
  const events=this.db.prepare('SELECT * FROM participation_events WHERE institution_id=? ORDER BY version').all(institution);
  let replay=initialBoard(institution),previous=INITIAL_HASH;
  for(let i=0;i<events.length;i++){
   const e=events[i];
   if(e.version!==i+1||e.previous_hash!==previous)fail('PARTICIPATION_CHAIN_BROKEN');
   let command;try{command=JSON.parse(e.command_json);}catch{fail('PARTICIPATION_EVENT_INVALID');}
   if(hash(command)!==e.command_hash)fail('PARTICIPATION_EVENT_CHANGED');
   replay=this.#reduce(replay,command);
   if(hash(replay)!==e.board_hash)fail('PARTICIPATION_REPLAY_MISMATCH');
   const expectedHash=hash({institution,version:e.version,actorId:e.actor_id,commandHash:e.command_hash,boardHash:e.board_hash,previous});
   if(expectedHash!==e.event_hash)fail('PARTICIPATION_EVENT_HASH_MISMATCH');
   previous=e.event_hash;
  }
  if(!row){if(events.length)fail('PARTICIPATION_BOARD_MISSING');return {version:0,board:replay,headHash:INITIAL_HASH};}
  const serialized=JSON.parse(row.board_json);
  if(row.version!==events.length||hash(serialized)!==row.board_hash||row.board_hash!==hash(replay)||row.head_hash!==previous)fail('PARTICIPATION_SNAPSHOT_MISMATCH');
  return {version:row.version,board:serialized,headHash:previous};
 }
 #reduce(board,command){
  if(command.type==='BUDGET'){
   const b=budgetSlate(command.institution,command.selected);
   if(!b.feasible)fail('BUDGET_OVER_CEILING',400);
   return {...board,budgetSubmission:{...b,status:'FICTIONAL_STEWARD_SLATE',note:'No money allocated or counted as a public vote'}};
  }
  const r=transact(board,command);
  if(!r.ok)fail('PARTICIPATION_REJECTED_'+r.reason.replace(/[^A-Za-z0-9]+/g,'_').slice(0,80),400);
  return r.board;
 }
 read(actor,institution){
  this.#map(actor,institution);
  return this.store.readTx(()=>{
   this.#map(actor,institution);
   const data=this.#load(institution);
   // The board stores no personal ADVISE positions. These remain client-local.
   return {...data,mode:'SYNTHETIC_ONLY',officialVoting:false,realImport:false,integrity:'LOCAL_REPLAY_ONLY',warning:'Fictional members and local key custody; not government authentication or election integrity.'};
  });
 }
 command(actor,institution,input){
  this.#map(actor,institution);
  if(!input||typeof input!=='object'||Array.isArray(input))fail('BAD_PARTICIPATION_INPUT',400);
  const {key,expectedVersion,command}=input;
  if(!Number.isSafeInteger(expectedVersion)||expectedVersion<0||!command||typeof command!=='object'||Array.isArray(command))fail('BAD_PARTICIPATION_COMMAND',400);
  if(JSON.stringify(command).length>MAX_COMMAND)fail('PARTICIPATION_COMMAND_TOO_LARGE',413);
  if(command.institution && command.institution!==institution)fail('CROSS_INSTITUTION_COMMAND',403);
  if(!VISITOR_ACTIONS.has(command.type)&&!STEWARD_ACTIONS.has(command.type))fail('ACTION_NOT_DURABLE_OR_AUTHORIZED',403);
  const role=STEWARDS.has(actor.role)?'DEMO_STEWARD':null;
  if(STEWARD_ACTIONS.has(command.type)&&!role)fail('STEWARD_REQUIRED',403);
  if(!EVERYONE.has(actor.role))fail('PARTICIPATION_READ_ONLY_ROLE',403);
  // Ignore/replace caller-controlled role. Reducer validates stage and revision.
  const normalized={...command,institution,role};
  const idempotentReq={op:'PARTICIPATION_V1',institution,expectedVersion,command:normalized};
  return this.store.idempotent(actor,actor.institutionId,key,idempotentReq,()=>{
   this.#map(actor,institution); // recheck inside BEGIN IMMEDIATE
   const old=this.#load(institution);
   if(old.version!==expectedVersion)fail('STALE_PARTICIPATION_VERSION',409);
   const board=this.#reduce(old.board,normalized);
   validateBoard(board);
   const version=old.version+1,boardHash=hash(board),commandHash=hash(normalized);
   const eventHash=hash({institution,version,actorId:actor.id,commandHash,boardHash,previous:old.headHash});
   this.db.prepare('INSERT INTO participation_events VALUES(?,?,?,?,?,?,?,?)').run(institution,version,actor.id,canonical(normalized),commandHash,boardHash,old.headHash,eventHash);
   this.db.prepare(`INSERT INTO participation_boards VALUES(?,?,?,?,?) ON CONFLICT(institution_id) DO UPDATE SET version=excluded.version,board_json=excluded.board_json,board_hash=excluded.board_hash,head_hash=excluded.head_hash`).run(institution,version,canonical(board),boardHash,eventHash);
   return {version,board,headHash:eventHash,mode:'SYNTHETIC_ONLY',officialVoting:false,realImport:false,integrity:'LOCAL_REPLAY_ONLY'};
  });
 }
}
