// Strict offline OIDC ID-token validation adapter for synthetic, pre-registered issuers.
// Intentionally NOT a complete authorization-code client, WebAuthn server, or IdP.
// No network discovery, dynamic jku/x5u/jwk, or roles/eligibility from token claims.
import { createPublicKey, verify as verifySignature } from 'node:crypto';

const failure = (reason) => { const e = new Error(`OIDC_${reason}`); e.code=e.message; throw e; };
function decodePart(segment){
 if(typeof segment!=='string'||!/^[A-Za-z0-9_-]+$/.test(segment)||segment.length>10000)failure('ENCODING');
 try { return JSON.parse(Buffer.from(segment,'base64url').toString('utf8')); } catch { failure('JSON'); }
}
const isStr=x=>typeof x==='string'&&x.length>0;
function acceptableClaims(c,{issuer,clientId,nonce,clock,skewSeconds,maxAgeSeconds}){
 if(!c||typeof c!=='object'||Array.isArray(c))failure('CLAIMS');
 if(c.iss!==issuer||!isStr(c.sub))failure('ISSUER_OR_SUB');
 const audiences=typeof c.aud==='string'?[c.aud]:c.aud;
 if(!Array.isArray(audiences)||audiences.length<1||!audiences.every(isStr)||!audiences.includes(clientId))failure('AUDIENCE');
 if(audiences.length>1&&c.azp!==clientId)failure('AZP');
 if(c.azp!==undefined&&c.azp!==clientId)failure('AZP');
 if(!isStr(nonce)||c.nonce!==nonce)failure('NONCE');
 if(!Number.isSafeInteger(c.iat)||!Number.isSafeInteger(c.exp)||c.exp<=c.iat||c.iat>clock+skewSeconds||c.exp<=clock-skewSeconds||c.iat<clock-maxAgeSeconds-skewSeconds)failure('TIME');
 if(c.nbf!==undefined&&(!Number.isSafeInteger(c.nbf)||c.nbf>clock+skewSeconds))failure('NBF');
 if(c.auth_time!==undefined&&(!Number.isSafeInteger(c.auth_time)||c.auth_time>clock+skewSeconds))failure('AUTH_TIME');
}

/**
 * issuerConfig is a TRUSTED, static per-institution configuration, not token-provided data.
 * nonceLedger.consume(nonce, institutionId) must atomically consume an issued nonce;
 * production requires a shared durable ledger and issuer/redirect/PKCE validation.
 */
export async function verifyIdToken(token,{issuerConfig,institutionId,nonce,nonceLedger,clock=Math.floor(Date.now()/1000),skewSeconds=30,maxAgeSeconds=600}){
 if(typeof token!=='string'||token.length>16000)failure('TOKEN');
 const sections=token.split('.');if(sections.length!==3)failure('TOKEN');
 const [encodedHeader,encodedClaims,encodedSignature]=sections;
 const header=decodePart(encodedHeader),claims=decodePart(encodedClaims);
 const {issuer,clientId,alg,jwks,tenants=[]}=issuerConfig??{};
 if(!isStr(institutionId)||!Array.isArray(tenants)||!tenants.includes(institutionId))failure('TENANT_ISSUER');
 if(!isStr(issuer)||!isStr(clientId)||!['RS256','ES256','EdDSA'].includes(alg)||!Array.isArray(jwks))failure('ISSUER_CONFIG');
 if(!header||header.alg!==alg||!isStr(header.kid)||header.crit!==undefined||header.jwk!==undefined||header.jku!==undefined||header.x5u!==undefined)failure('HEADER');
 const matching=jwks.filter(k=>k.kid===header.kid&&k.use!=='enc'&&(!k.alg||k.alg===alg));
 if(matching.length!==1)failure('KEY');
 const k=matching[0];
 if((alg==='RS256'&&k.kty!=='RSA')||(alg==='ES256'&&(k.kty!=='EC'||k.crv!=='P-256'))||(alg==='EdDSA'&&(k.kty!=='OKP'||k.crv!=='Ed25519')))failure('KEY_TYPE');
 let publicKey;
 try { publicKey=createPublicKey({key:k,format:'jwk'}); } catch { failure('INVALID_KEY'); }
 const payload=Buffer.from(`${encodedHeader}.${encodedClaims}`,'ascii');
 const sig=Buffer.from(encodedSignature,'base64url');
 const algorithm=alg==='RS256'?'RSA-SHA256':alg==='ES256'?'sha256':null;
 const options=alg==='ES256'?{key:publicKey,dsaEncoding:'ieee-p1363'}:publicKey;
 if(!verifySignature(algorithm,payload,options,sig))failure('SIGNATURE');
 acceptableClaims(claims,{issuer,clientId,nonce,clock,skewSeconds,maxAgeSeconds});
 if(!nonceLedger||typeof nonceLedger.consume!=='function'||await nonceLedger.consume(nonce,institutionId)!==true)failure('NONCE_REPLAY');
 // Membership is NEVER inferred from claims supplied by a federation provider.
 return Object.freeze({institutionId,issuer,subject:claims.sub,authenticatedAt:claims.auth_time??claims.iat,mode:'FEDERATED_IDENTITY_ONLY',authorization:'NOT_GRANTED'});
}

export function makeSyntheticNonceLedger(){
 const issued=new Set();
 return { issue(nonce,institutionId){if(!isStr(nonce)||issued.has(`${institutionId}:${nonce}`))failure('NONCE');issued.add(`${institutionId}:${nonce}`);},
 consume(nonce,institutionId){const key=`${institutionId}:${nonce}`;if(!issued.has(key))return false;issued.delete(key);return true;} };
}

export function resolveInstitutionalActor(principal,membershipLookup){
 if(principal?.authorization!=='NOT_GRANTED'||typeof membershipLookup!=='function')failure('MAPPING');
 const record=membershipLookup(principal.institutionId,principal.issuer,principal.subject);
 if(!record||record.institutionId!==principal.institutionId||record.active!==true||!isStr(record.actorId))failure('UNBOUND_PRINCIPAL');
 return Object.freeze({institutionId:record.institutionId,actorId:record.actorId,identity:principal,roleSource:'INSTITUTIONAL_REGISTRY_ONLY'});
}
