// Deliberately separate hash-chain checker: no Store, reducer, ledger or codec imports.
// This checks a LOCAL SQLite file, not real-world authority or external custody.
import { DatabaseSync } from 'node:sqlite';
import { createHash } from 'node:crypto';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

function canonical(value){
  if(value===null||typeof value!=='object')return JSON.stringify(value);
  if(Array.isArray(value))return '['+value.map(canonical).join(',')+']';
  return '{'+Object.keys(value).sort().map(k=>JSON.stringify(k)+':'+canonical(value[k])).join(',')+'}';
}
const digest=x=>createHash('sha256').update(canonical(x),'utf8').digest('hex');
function demand(v,code){if(!v)throw Error(code);}
export function verifyLocalParticipationChain(file,institutionId){
  demand(/^(student-demo|union-demo|municipal-demo)$/.test(institutionId),'UNKNOWN_DEMO_TENANT');
  const db=new DatabaseSync(file,{readOnly:true});
  try{
    const stream=db.prepare('SELECT seq,head_hash FROM participation_streams WHERE institution_id=?').get(institutionId);
    const events=db.prepare('SELECT seq,event_json,previous_hash,hash FROM participation_events WHERE institution_id=? ORDER BY seq').all(institutionId);
    let prev='GENESIS',seq=0,seed=null;
    for(const row of events){
      const event=JSON.parse(row.event_json);
      demand(row.seq===++seq&&event.seq===seq,'INDEPENDENT_SEQUENCE_MISMATCH');
      demand(event.institutionId===institutionId,'INDEPENDENT_TENANT_MISMATCH');
      demand(row.previous_hash===prev,'INDEPENDENT_PREVIOUS_HASH_MISMATCH');
      demand(row.hash===digest({event,previousHash:prev}),'INDEPENDENT_EVENT_HASH_MISMATCH');
      demand(typeof event.nonce==='string'&&/^[0-9a-f]{32}$/.test(event.nonce),'INDEPENDENT_NONCE_MISSING');
      demand(/^[0-9a-f]{64}$/.test(event.stateHash)&&/^[0-9a-f]{64}$/.test(event.seedHash),'INDEPENDENT_COMMITMENT_INVALID');
      demand(seed===null||seed===event.seedHash,'INDEPENDENT_FIXTURE_DRIFT');
      seed=event.seedHash;prev=row.hash;
    }
    demand((stream?.seq??0)===seq && (stream?.head_hash??'GENESIS')===prev,'INDEPENDENT_HEAD_MISMATCH');
    return {ok:true,institutionId,sequence:seq,headHash:prev,status:'LOCAL_HASH_CHAIN_ONLY',realAuthority:false,independentCustody:false,transitionReplayVerified:false};
  }finally{db.close();}
}
if(process.argv[1]&&resolve(process.argv[1])===fileURLToPath(import.meta.url)){
  try{console.log(JSON.stringify(verifyLocalParticipationChain(process.argv[2],process.argv[3])));}
  catch(e){console.error(JSON.stringify({ok:false,error:e.message}));process.exitCode=1;}
}
