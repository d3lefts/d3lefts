// Commonwealth PostgreSQL participation backend v1.4, SYNTHETIC ONLY.
// Persistent authority and actor checks share one PG transaction; no cross-DB auth.
// Existing SQLite reducer is used strictly as an ephemeral deterministic replay
// interpreter, never as durable storage for PostgreSQL mode.
import pg from 'pg';
const { Pool } = pg;
import { DatabaseSync } from 'node:sqlite';
import { createCipheriv, createDecipheriv, randomBytes } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { Store } from './store.mjs';
import { ParticipationLedger, PARTICIPATION_SCOPE } from './participation.mjs';
import { canon, sha, invariant } from './codec.mjs';

const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const POLICY={quorum:2,yesNumerator:1,yesDenominator:2,strict:false};
const GENESIS='GENESIS';
const validTenant=t=>Object.hasOwn(PARTICIPATION_SCOPE,t);
function fail(code,status=409){const e=Error(code);e.code=code;e.http=status;throw e;}
export function pgConfigFromEnv(env=process.env){
  const url=env.COMMONWEALTH_PG_URL;
  const secret=env.COMMONWEALTH_PG_EVENT_KEY;
  invariant(typeof url==='string'&&url.length>0,'PG_URL_REQUIRED',400);
  const parsed=new URL(url);
  invariant(parsed.protocol==='postgresql:'||parsed.protocol==='postgres:','PG_URL_INVALID',400);
  invariant(['localhost','127.0.0.1','::1','[::1]'].includes(parsed.hostname),'PG_LOCALHOST_ONLY',400);
  invariant(typeof secret==='string'&&/^[a-f0-9]{64}$/i.test(secret),'PG_EVENT_KEY_REQUIRED_32_BYTE_HEX',400);
  return {url,key:Buffer.from(secret,'hex')};
}
const aad=(tenant,seq,prev,hash)=>Buffer.from(canon({tenant,seq,previousHash:prev,hash}),'utf8');

export class PgParticipationStore{
  constructor(pool,key){
    invariant(Buffer.isBuffer(key)&&key.length===32,'PG_EVENT_KEY_INVALID',400);
    this.pool=pool;this.key=key;
  }
  static async connect(config=pgConfigFromEnv()){
    const pool=new Pool({connectionString:config.url,max:8,statement_timeout:12000,connectionTimeoutMillis:4000});
    const instance=new PgParticipationStore(pool,config.key);
    try{await instance.init();return instance;}catch(e){await pool.end();throw e;}
  }
  async init(){
    const schema=readFileSync(resolve(root,'migrations/001_pg_participation.sql'),'utf8');
    await this.pool.query(schema);
  }
  async close(){await this.pool.end();}
  async tx(fn,{readonly=false}={}){
    const client=await this.pool.connect();
    try{
      await client.query(readonly?'BEGIN ISOLATION LEVEL REPEATABLE READ READ ONLY':'BEGIN');
      const result=await fn(client);
      await client.query('COMMIT');
      return result;
    }catch(e){try{await client.query('ROLLBACK');}catch{}throw e;}finally{client.release();}
  }
  _seal(tenant,row){
    const iv=randomBytes(12);
    const cipher=createCipheriv('aes-256-gcm',this.key,iv);
    cipher.setAAD(aad(tenant,row.seq,row.previous_hash,row.hash));
    const ciphertext=Buffer.concat([cipher.update(row.event_json,'utf8'),cipher.final()]);
    return {nonce:iv,tag:cipher.getAuthTag(),ciphertext};
  }
  _open(tenant,row){
    try{
      const decipher=createDecipheriv('aes-256-gcm',this.key,row.nonce);
      decipher.setAAD(aad(tenant,row.seq,row.previous_hash,row.hash));
      decipher.setAuthTag(row.tag);
      return Buffer.concat([decipher.update(row.ciphertext),decipher.final()]).toString('utf8');
    }catch{fail('PG_EVENT_AUTHENTICATION_FAILED');}
  }
  async _actor(client,token,lock=false){
    invariant(typeof token==='string'&&/^[0-9a-f]{64}$/.test(token),'UNAUTHENTICATED',401);
    const result=await client.query('SELECT tenant,actor_id,role,eligible,active FROM cw_pg_actors WHERE token_hash=$1'+(lock?' FOR SHARE':''),[sha(token)]);
    const found=result.rows[0];
    invariant(found?.active===true,'UNAUTHENTICATED',401);
    return {institutionId:found.tenant,id:found.actor_id,role:found.role,eligible:found.eligible?1:0,active:1};
  }
  async me(token){
    return this.tx(async client=>{
      const a=await this._actor(client,token);
      return {id:a.id,institutionId:a.institutionId,role:a.role,eligible:a.eligible,mode:'SYNTHETIC_ONLY'};
    },{readonly:true});
  }
  // Copy encrypted journal into a new :memory: SQLite interpreter for rigorous
  // backward-compatible reducer replay. PG remains sole durable source.
  _memory(tenant,actor,stream,rows){
    const mem=new Store(':memory:');
    try{
      mem.provisionInstitution(tenant,'Fictional '+tenant,POLICY);
      mem.run('INSERT INTO actors VALUES(?,?,?,?,?,?)',tenant,actor.id,actor.role,actor.eligible,actor.active,sha('ephemeral-'+actor.id));
      const ledger=new ParticipationLedger(mem);
      if(stream){
        mem.run('INSERT INTO participation_streams VALUES(?,?,?)',tenant,stream.seq,stream.head_hash);
      }
      for(const row of rows){
        const plain=this._open(tenant,row);
        mem.run('INSERT INTO participation_events VALUES(?,?,?,?,?)',tenant,row.seq,plain,row.previous_hash,row.hash);
      }
      ledger.replay(tenant);
      return {ledger,mem};
    }catch(e){mem.close();throw e;}
  }
  async _load(client,tenant){
    const result=await client.query('SELECT tenant,seq,head_hash FROM cw_pg_streams WHERE tenant=$1',[tenant]);
    invariant(result.rowCount===1,'PG_TENANT_NOT_PROVISIONED',404);
    const entries=await client.query('SELECT seq,previous_hash,hash,nonce,tag,ciphertext FROM cw_pg_events WHERE tenant=$1 ORDER BY seq',[tenant]);
    return {stream:result.rows[0],rows:entries.rows};
  }
  async command(token,request){
    const {institutionId,key,command,expectedSequence,expectedRevision}=request??{};
    invariant(validTenant(institutionId),'PG_UNKNOWN_TENANT',404);
    invariant(typeof key==='string'&&/^[A-Za-z0-9._:-]{8,120}$/.test(key),'PARTICIPATION_KEY_REQUIRED',400);
    invariant(Number.isSafeInteger(expectedSequence)&&expectedSequence>=0,'PARTICIPATION_SEQUENCE_REQUIRED',400);
    invariant(Number.isSafeInteger(expectedRevision)&&expectedRevision>=0,'PARTICIPATION_REVISION_REQUIRED',400);
    invariant(command&&typeof command==='object'&&!Array.isArray(command),'PARTICIPATION_COMMAND_REQUIRED',400);
    return this.tx(async client=>{
      // A role/eligibility update cannot commit while this actor is locked.
      const actor=await this._actor(client,token,true);
      invariant(actor.institutionId===institutionId,'FORBIDDEN_TENANT',403);
      const locked=await client.query('SELECT seq,head_hash FROM cw_pg_streams WHERE tenant=$1 FOR UPDATE',[institutionId]);
      invariant(locked.rowCount===1,'PG_TENANT_NOT_PROVISIONED',404);
      const hash=sha({institutionId,cmd:{...command,institution:PARTICIPATION_SCOPE[institutionId],...(command.type==='RESPOND_COMMENT'||command.type==='REVIEW_AMEND'||command.type==='MILESTONE'||command.type==='STAGE'?{role:'DEMO_STEWARD'}:{})},expectedSequence,expectedRevision});
      const prior=await client.query('SELECT request_hash,response_json FROM cw_pg_requests WHERE tenant=$1 AND actor_id=$2 AND request_key=$3',[institutionId,actor.id,key]);
      if(prior.rowCount){
        invariant(prior.rows[0].request_hash===hash,'PARTICIPATION_IDEMPOTENCY_CONFLICT');
        return prior.rows[0].response_json;
      }
      const {stream,rows}=await this._load(client,institutionId);
      const {ledger,mem}=this._memory(institutionId,actor,stream,rows);
      try{
        const result=ledger.command(actor,{institutionId,key,expectedSequence,expectedRevision,command});
        const row=mem.one('SELECT seq,event_json,previous_hash,hash FROM participation_events WHERE institution_id=? ORDER BY seq DESC LIMIT 1',institutionId);
        const ciphertext=this._seal(institutionId,row);
        await client.query('INSERT INTO cw_pg_events (tenant,seq,previous_hash,hash,nonce,tag,ciphertext) VALUES ($1,$2,$3,$4,$5,$6,$7)',[institutionId,row.seq,row.previous_hash,row.hash,ciphertext.nonce,ciphertext.tag,ciphertext.ciphertext]);
        await client.query('UPDATE cw_pg_streams SET seq=$2,head_hash=$3 WHERE tenant=$1',[institutionId,row.seq,row.hash]);
        await client.query('INSERT INTO cw_pg_requests (tenant,actor_id,request_key,request_hash,response_json) VALUES ($1,$2,$3,$4,$5::jsonb)',[institutionId,actor.id,key,hash,JSON.stringify(result)]);
        return result;
      }finally{mem.close();}
    });
  }
  async _read(token,tenant,fn){
    invariant(validTenant(tenant),'PG_UNKNOWN_TENANT',404);
    return this.tx(async client=>{
      const actor=await this._actor(client,token);
      invariant(actor.institutionId===tenant,'FORBIDDEN_TENANT',403);
      const {stream,rows}=await this._load(client,tenant);
      const {ledger,mem}=this._memory(tenant,actor,stream,rows);
      try{return fn(ledger,actor,stream);}finally{mem.close();}
    },{readonly:true});
  }
  view(token,tenant){return this._read(token,tenant,(ledger,actor)=>ledger.view(actor,tenant));}
  dossier(token,tenant,id){return this._read(token,tenant,(ledger,actor)=>ledger.dossier(actor,tenant,id));}
  async checkpoint(tenant){
    invariant(validTenant(tenant),'PG_UNKNOWN_TENANT',404);
    return this.tx(async client=>{
      const {stream,rows}=await this._load(client,tenant);
      // Independent read verifies AEAD, chain, reducer, and head against
      // repository-pinned initial fixture through the temporary interpreter.
      const actor={institutionId:tenant,id:'anchor-checker',role:'auditor',eligible:0,active:1};
      const {ledger,mem}=this._memory(tenant,actor,stream,rows);
      try{
        const replay=ledger.replay(tenant);
        return {format:'cw.pg.synthetic-checkpoint.v1',tenant,sequence:replay.sequence,headHash:replay.headHash,seedHash:replay.seedHash,at:new Date().toISOString(),official:false,externalAnchor:false};
      }finally{mem.close();}
    },{readonly:true});
  }
  async provision(tenant,actors){
    invariant(validTenant(tenant),'PG_UNKNOWN_TENANT',404);
    return this.tx(async client=>{
      const old=await client.query('SELECT tenant FROM cw_pg_streams WHERE tenant=$1 FOR UPDATE',[tenant]);
      invariant(old.rowCount===0,'PG_TENANT_ALREADY_PROVISIONED');
      await client.query('INSERT INTO cw_pg_streams (tenant,seq,head_hash) VALUES ($1,0,$2)',[tenant,GENESIS]);
      const output={};
      for(const a of actors){
        invariant(['admin','chair','clerk','auditor','member'].includes(a.role),'PG_BAD_ROLE',400);
        invariant(/^[a-z][a-z0-9-]{1,63}$/.test(a.id),'PG_BAD_ACTOR_ID',400);
        const token=randomBytes(32).toString('hex');
        await client.query('INSERT INTO cw_pg_actors (tenant,actor_id,role,eligible,active,token_hash) VALUES ($1,$2,$3,$4,TRUE,$5)',[tenant,a.id,a.role,Boolean(a.eligible),sha(token)]);
        output[a.id]=token;
      }
      return output; // synthetic tokens only; never log these in tests or CI
    });
  }
  // One-way offline transfer: source SQLite must be quiescent; it is opened read-only.
  // All three tenants are imported atomically, preserving event digest and head.
  async migrateSqlite(file){
    const src=new DatabaseSync(file,{readOnly:true});
    try{
      const source=[];
      for(const tenant of Object.keys(PARTICIPATION_SCOPE)){
        const row=src.prepare('SELECT seq,head_hash FROM participation_streams WHERE institution_id=?').get(tenant);
        const actors=src.prepare('SELECT id,role,eligible,active,token_hash FROM actors WHERE institution_id=?').all(tenant);
        const records=src.prepare('SELECT seq,event_json,previous_hash,hash FROM participation_events WHERE institution_id=? ORDER BY seq').all(tenant);
        invariant(actors.length>0,'PG_SOURCE_ACTORS_MISSING');
        const interpreter=new Store(':memory:');
        try{
          interpreter.provisionInstitution(tenant,'Fictional '+tenant,POLICY);
          interpreter.run('INSERT INTO actors VALUES(?,?,?,?,?,?)',tenant,'migration-auditor','auditor',0,1,sha('migration-auditor-'+tenant));
          const l=new ParticipationLedger(interpreter);
          if(row)interpreter.run('INSERT INTO participation_streams VALUES(?,?,?)',tenant,row.seq,row.head_hash);
          for(const r of records)interpreter.run('INSERT INTO participation_events VALUES(?,?,?,?,?)',tenant,r.seq,r.event_json,r.previous_hash,r.hash);
          l.replay(tenant); // source must be intact and replayable
        }finally{interpreter.close();}
        source.push({tenant,actors,records,stream:row??{seq:0,head_hash:GENESIS}});
      }
      await this.tx(async client=>{
        const exists=await client.query('SELECT tenant FROM cw_pg_streams LIMIT 1');
        invariant(exists.rowCount===0,'PG_DESTINATION_NOT_EMPTY');
        for(const s of source){
          await client.query('INSERT INTO cw_pg_streams VALUES ($1,0,$2)',[s.tenant,GENESIS]);
          for(const a of s.actors)
            await client.query('INSERT INTO cw_pg_actors VALUES ($1,$2,$3,$4,$5,$6)',[s.tenant,a.id,a.role,Boolean(a.eligible),Boolean(a.active),a.token_hash]);
          for(const r of s.records){
            const sealed=this._seal(s.tenant,r);
            await client.query('INSERT INTO cw_pg_events VALUES ($1,$2,$3,$4,$5,$6,$7)',[s.tenant,r.seq,r.previous_hash,r.hash,sealed.nonce,sealed.tag,sealed.ciphertext]);
          }
          await client.query('UPDATE cw_pg_streams SET seq=$2,head_hash=$3 WHERE tenant=$1',[s.tenant,s.stream.seq,s.stream.head_hash]);
        }
      });
      return source.map(s=>({tenant:s.tenant,sequence:s.stream.seq,headHash:s.stream.head_hash,actorCount:s.actors.length}));
    }finally{src.close();}
  }
}
