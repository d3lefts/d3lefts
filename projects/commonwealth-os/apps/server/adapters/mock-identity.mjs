// NON-PRODUCTION synthetic identity federation contract test adapter.
// Signed synthetic credentials cannot authorize real votes or municipal actions.
import {generateKeyPairSync,sign,verify} from 'node:crypto';
const canonical=value=>value===null||typeof value!=='object'?JSON.stringify(value):Array.isArray(value)?'['+value.map(canonical).join(',')+']':'{'+Object.keys(value).sort().map(k=>JSON.stringify(k)+':'+canonical(value[k])).join(',')+'}';
const encode=v=>Buffer.from(canonical(v)).toString('base64url');
const decode=v=>JSON.parse(Buffer.from(v,'base64url').toString('utf8'));
export function createMockIdentityIssuer({audience='commonwealth-synthetic-local',issuer='synthetic://identity-provider'}={}){
 const keys=generateKeyPairSync('ed25519');
 const publicKeyPem=keys.publicKey.export({format:'pem',type:'spki'}).toString();
 const issue=({institutionId,subject,nonce,scope=['demo:read'],expiresAt})=>{
  if(!institutionId||!subject||!nonce||!Number.isSafeInteger(expiresAt)||!Array.isArray(scope))throw Error('BAD_SYNTHETIC_ASSERTION');
  const claims={kind:'SYNTHETIC_IDENTITY_ONLY',iss:issuer,aud:audience,institutionId,sub:subject,nonce,scope,exp:expiresAt};
  const payload=encode(claims),signature=sign(null,Buffer.from(payload),keys.privateKey).toString('base64url');
  return `${payload}.${signature}`;
 };
 const verifyAssertion=(token,{institutionId,nonce,nowEpochSeconds,allowedScope='demo:read'}={})=>{
  if(!Number.isSafeInteger(nowEpochSeconds))throw Error('CLOCK_REQUIRED');
  const parts=typeof token==='string'?token.split('.'):[];
  if(parts.length!==2||!verify(null,Buffer.from(parts[0]),keys.publicKey,Buffer.from(parts[1],'base64url')))throw Error('INVALID_ASSERTION_SIGNATURE');
  const c=decode(parts[0]);
  if(c.kind!=='SYNTHETIC_IDENTITY_ONLY'||c.iss!==issuer||c.aud!==audience||c.institutionId!==institutionId||c.nonce!==nonce||c.exp<=nowEpochSeconds||!c.scope.includes(allowedScope))throw Error('ASSERTION_SCOPE_OR_EXPIRY');
  return {institutionId:c.institutionId,subject:c.sub,scope:[...c.scope],mode:'SYNTHETIC_ONLY'};
 };
 return {issue,verifyAssertion,publicKeyPem,issuer,audience};
}
