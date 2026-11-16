// PostgreSQL event verifier independent of the application/reducer adapter.
// Audits AES-GCM + hash chain + externally supplied signed checkpoint PREFIX.
// It does NOT certify transitions, source authenticity, or actual external custody.
import pg from 'pg';
import { createHash,createDecipheriv } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { verifyExternalCheckpoint } from './verify-pg-anchor.mjs';

function canon(v){
  if(v===null||typeof v!=='object')return JSON.stringify(v);
  if(Array.isArray(v))return '['+v.map(canon).join(',')+']';
  return '{'+Object.keys(v).sort().map(k=>JSON.stringify(k)+':'+canon(v[k])).join(',')+'}';
}
const digest=v=>createHash('sha256').update(canon(v),'utf8').digest('hex');
function requireTruth(ok,error){if(!ok)throw Error(error);}
export async function verifyPgAnchoredPrefix({connectionString,eventKeyHex,envelope,pinnedPublicKeyPem}){
  const signed=verifyExternalCheckpoint(envelope,pinnedPublicKeyPem);
  requireTruth(/^[a-f0-9]{64}$/i.test(eventKeyHex),'VERIFIER_EVENT_KEY_REQUIRED');
  const u=new URL(connectionString);
  requireTruth(['127.0.0.1','localhost','[::1]','::1'].includes(u.hostname),'VERIFIER_LOCALHOST_ONLY');
  const pool=new pg.Pool({connectionString,max:1});
  const client=await pool.connect();
  try{
    await client.query('BEGIN ISOLATION LEVEL REPEATABLE READ READ ONLY');
    const tenant=signed.tenant;
    const [headRes,eventsRes]=await Promise.all([
      client.query('SELECT seq,head_hash FROM cw_pg_streams WHERE tenant=$1',[tenant]),
      client.query('SELECT seq,previous_hash,hash,nonce,tag,ciphertext FROM cw_pg_events WHERE tenant=$1 ORDER BY seq',[tenant])
    ]);
    requireTruth(headRes.rowCount===1,'VERIFIER_TENANT_MISSING');
    let seq=0,last='GENESIS',sawAnchor=signed.sequence===0;
    if(signed.sequence===0)requireTruth(signed.headHash==='GENESIS','ANCHOR_GENESIS_INVALID');
    const ivs=new Set();
    for(const e of eventsRes.rows){
      requireTruth(e.seq===++seq,'VERIFIER_SEQUENCE_GAP');
      requireTruth(e.previous_hash===last,'VERIFIER_HASH_LINK_BROKEN');
      const iv=e.nonce.toString('hex');
      requireTruth(!ivs.has(iv),'VERIFIER_NONCE_REUSED');ivs.add(iv);
      let decoded;
      try{
        const decipher=createDecipheriv('aes-256-gcm',Buffer.from(eventKeyHex,'hex'),e.nonce);
        decipher.setAAD(Buffer.from(canon({tenant,seq,previousHash:last,hash:e.hash}),'utf8'));
        decipher.setAuthTag(e.tag);
        decoded=JSON.parse(Buffer.concat([decipher.update(e.ciphertext),decipher.final()]).toString('utf8'));
      }catch{throw Error('VERIFIER_AEAD_FAILURE');}
      requireTruth(decoded.seq===seq && decoded.institutionId===tenant,'VERIFIER_EVENT_SCOPE_MISMATCH');
      requireTruth(decoded.seedHash===envelope.payload.seedHash,'VERIFIER_SEED_MISMATCH');
      requireTruth(digest({event:decoded,previousHash:last})===e.hash,'VERIFIER_EVENT_DIGEST_MISMATCH');
      last=e.hash;
      if(seq===signed.sequence){
        requireTruth(last===signed.headHash,'ANCHORED_PREFIX_MISMATCH');
        sawAnchor=true;
      }
    }
    requireTruth(sawAnchor,'ANCHORED_PREFIX_TRUNCATED');
    requireTruth(headRes.rows[0].seq===seq&&headRes.rows[0].head_hash===last,'VERIFIER_DB_HEAD_MISMATCH');
    await client.query('COMMIT');
    return {ok:true,tenant,sequence:seq,headHash:last,anchoredPrefixSequence:signed.sequence,
      pinnedSignature:true,anchoredPrefixMatched:true,cryptographicReplay:true,
      transitionValidity:'NOT_VERIFIED',sourceAuthority:'NOT_VERIFIED',
      externalCustody:'NOT_ESTABLISHED_BY_CHECKER',official:false};
  }catch(e){try{await client.query('ROLLBACK');}catch{}throw e;}finally{client.release();await pool.end();}
}
if(process.argv[1]?.endsWith('verify-pg-ledger-anchor.mjs')){
  try{
    const envelope=JSON.parse(readFileSync(process.argv[2],'utf8'));
    const pinnedPublicKeyPem=readFileSync(process.argv[3],'utf8');
    const result=await verifyPgAnchoredPrefix({connectionString:process.env.COMMONWEALTH_PG_URL,eventKeyHex:process.env.COMMONWEALTH_PG_EVENT_KEY,envelope,pinnedPublicKeyPem});
    console.log(JSON.stringify(result));
  }catch(e){console.error(JSON.stringify({ok:false,error:e.message}));process.exitCode=1;}
}
