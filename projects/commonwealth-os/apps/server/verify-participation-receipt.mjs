// Independently implemented portable synthetic receipt verifier.
// Verifies only Ed25519 payload integrity under the supplied key.
// Does not establish official legal authority or independently replay SQLite history.
import { createPublicKey, createHash, verify } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

function canonical(x){
  if(x===null||typeof x!=='object')return JSON.stringify(x);
  if(Array.isArray(x))return '['+x.map(canonical).join(',')+']';
  return '{'+Object.keys(x).sort().map(k=>JSON.stringify(k)+':'+canonical(x[k])).join(',')+'}';
}
function insist(ok,reason){if(!ok)throw Error(reason);}
export function verifySyntheticParticipationReceipt(envelope,{trustedPublicKeyPem}={}){
  insist(envelope?.envelope==='commonwealth.os.portable-evidence.v1','RECEIPT_FORMAT_INVALID');
  const p=envelope.payload;
  insist(p?.kind==='COMMONWEALTH_SYNTHETIC_DOSSIER_V1' && p.official===false &&
    p.individualAdviceIncluded===false && p.certification==='NOT_CERTIFIED' &&
    p.ledger?.verification==='LOCAL_REPLAY_ONLY' && p.ledger.externalAnchor===false,'RECEIPT_SCOPE_INVALID');
  insist(envelope.signature?.alg==='Ed25519' && typeof envelope.signature.publicKeyPem==='string' &&
    typeof envelope.signature.signature==='string','RECEIPT_SIGNATURE_MISSING');
  const pem=envelope.signature.publicKeyPem;
  const key=createPublicKey(pem);
  const fingerprint=createHash('sha256').update(pem).digest('hex');
  insist(fingerprint===envelope.signature.keyId,'RECEIPT_FINGERPRINT_INVALID');
  if(trustedPublicKeyPem){
    const pinned=createPublicKey(trustedPublicKeyPem).export({type:'spki',format:'pem'}).toString();
    insist(pem===pinned,'RECEIPT_PINNED_KEY_MISMATCH');
  }
  insist(verify(null,Buffer.from(canonical(p),'utf8'),key,Buffer.from(envelope.signature.signature,'base64')),'RECEIPT_SIGNATURE_INVALID');
  return {ok:true,authenticity:trustedPublicKeyPem?'PINNED_LOCAL_KEY':'SELF_ASSERTED_KEY',
    hashChain:'NOT_INDEPENDENTLY_REPLAYED',sourceCustody:'NOT_VERIFIED',officialCertification:false,
    headHash:p.ledger.headHash,sequence:p.ledger.sequence};
}
if(process.argv[1]&&resolve(process.argv[1])===fileURLToPath(import.meta.url)){
  try{
    const envelope=JSON.parse(readFileSync(process.argv[2],'utf8'));
    const pinned=process.argv[3]?readFileSync(process.argv[3],'utf8'):undefined;
    console.log(JSON.stringify(verifySyntheticParticipationReceipt(envelope,{trustedPublicKeyPem:pinned})));
  }catch(e){console.error(JSON.stringify({ok:false,error:e.message}));process.exitCode=1;}
}
