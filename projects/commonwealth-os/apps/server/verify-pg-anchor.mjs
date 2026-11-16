// Independent offline checkpoint signature verifier; no SQLite / PG imports.
import { createPublicKey, createHash, verify } from 'node:crypto';
import { readFileSync } from 'node:fs';
function canonical(v){
  if(v===null||typeof v!=='object')return JSON.stringify(v);
  if(Array.isArray(v))return '['+v.map(canonical).join(',')+']';
  return '{'+Object.keys(v).sort().map(k=>JSON.stringify(k)+':'+canonical(v[k])).join(',')+'}';
}
function check(ok,name){if(!ok)throw Error(name);}
export function verifyExternalCheckpoint(envelope,trustedPem){
  check(typeof trustedPem==='string'&&trustedPem.includes('BEGIN PUBLIC KEY'),'PINNED_CHECKPOINT_KEY_REQUIRED');
  const e=envelope?.payload,s=envelope?.signature;
  check(envelope?.envelope==='commonwealth.os.portable-evidence.v1','INVALID_CHECKPOINT_ENVELOPE');
  check(e?.format==='cw.pg.synthetic-checkpoint.v1'&&e.official===false&&e.externalAnchor===false,'INVALID_CHECKPOINT_SCOPE');
  check(Number.isSafeInteger(e.sequence)&&e.sequence>=0,'INVALID_CHECKPOINT_SEQUENCE');
  check(e.headHash==='GENESIS'||/^[0-9a-f]{64}$/.test(e.headHash),'INVALID_CHECKPOINT_HEAD');
  check(s?.alg==='Ed25519'&&typeof s.publicKeyPem==='string'&&typeof s.signature==='string','INVALID_CHECKPOINT_SIGNATURE');
  const normalized=createPublicKey(trustedPem).export({format:'pem',type:'spki'}).toString();
  check(s.publicKeyPem===normalized,'PINNED_CHECKPOINT_SIGNER_MISMATCH');
  check(createHash('sha256').update(normalized).digest('hex')===s.keyId,'CHECKPOINT_FINGERPRINT_MISMATCH');
  check(verify(null,Buffer.from(canonical(e)),createPublicKey(normalized),Buffer.from(s.signature,'base64')),'CHECKPOINT_SIGNATURE_INVALID');
  return {ok:true,pinned:true,tenant:e.tenant,sequence:e.sequence,headHash:e.headHash,sourceCustody:'NOT_VERIFIED',externalStorage:'NOT_ESTABLISHED',official:false};
}
if(process.argv[1]?.endsWith('verify-pg-anchor.mjs')){
  try{
    const doc=JSON.parse(readFileSync(process.argv[2],'utf8'));
    const key=readFileSync(process.argv[3],'utf8');
    console.log(JSON.stringify(verifyExternalCheckpoint(doc,key)));
  }catch(e){console.error(JSON.stringify({ok:false,error:e.message}));process.exitCode=1;}
}
