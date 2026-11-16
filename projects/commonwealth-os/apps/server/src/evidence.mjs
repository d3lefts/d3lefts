import { generateKeyPairSync, createPrivateKey, createPublicKey, sign, createHash } from 'node:crypto';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname } from 'node:path';
import { canon } from './codec.mjs';

export function signingKey(keyPath) {
  if (!existsSync(keyPath)) {
    mkdirSync(dirname(keyPath),{recursive:true,mode:0o700});
    const pair=generateKeyPairSync('ed25519');
    const key=pair.privateKey.export({type:'pkcs8',format:'pem'});
    writeFileSync(keyPath,key,{mode:0o600,flag:'wx'});
  }
  return createPrivateKey(readFileSync(keyPath));
}
export function exportEvidence(snapshot,privateKey) {
  const publicKeyPem=createPublicKey(privateKey).export({type:'spki',format:'pem'}).toString();
  const keyId=createHash('sha256').update(publicKeyPem).digest('hex');
  const signature=sign(null,Buffer.from(canon(snapshot),'utf8'),privateKey).toString('base64');
  return {
    envelope:'commonwealth.os.portable-evidence.v1',
    payload:snapshot,
    signature:{alg:'Ed25519',keyId,publicKeyPem,signature},
    signerTrust:'UNVERIFIED_UNLESS_PINNED_EXTERNALLY',
  };
}
