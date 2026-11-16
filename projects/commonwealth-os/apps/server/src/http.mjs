import http from 'node:http';
import { parse } from 'node:url';
import { resolve, join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { ExtendedStore } from './extended-store.mjs';
import { createPublicKey } from 'node:crypto';
import { verifyExtended } from '../verify-v2.mjs';
import { dependencyRecord, recertifyImpact } from './recertification.mjs';
import { signingKey, exportEvidence } from './evidence.mjs';

const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const json=(res,status,body)=>{
  res.writeHead(status,{'Content-Type':'application/json; charset=utf-8','Cache-Control':'no-store','X-Content-Type-Options':'nosniff','Content-Security-Policy':"default-src 'none'",'Access-Control-Allow-Origin':'none'});
  res.end(JSON.stringify(body));
};
async function body(req) {
  let raw='';
  for await (const chunk of req) {raw+=chunk; if(Buffer.byteLength(raw,'utf8')>65536) {const e=new Error('PAYLOAD_TOO_LARGE');e.http=413;throw e;}}
  try { const value=JSON.parse(raw);if(!value || typeof value!=='object'||Array.isArray(value))throw Error();return value;}catch{const e=new Error('INVALID_JSON');e.http=400;throw e;}
}
export function createServer({dbPath=':memory:',keyPath=join(root,'data','signing-key.pem'),store:givenStore}={}) {
  const store=givenStore??new ExtendedStore(dbPath);
  const privateKey=signingKey(keyPath);
  const server=http.createServer(async(req,res)=>{
    try{
      const path=parse(req.url||'').pathname;
      if(req.method==='GET'&&path==='/healthz')return json(res,200,{status:'local-demo-only',officialVoting:false,municipalIngestion:false});
      const token=(req.headers.authorization||'').match(/^Bearer ([a-f0-9]{64})$/)?.[1];
      const actor=store.authenticate(token);
      if(req.method==='GET'&&path==='/api/v1/me')return json(res,200,{id:actor.id,institutionId:actor.institutionId,role:actor.role,eligible:actor.eligible,mode:'SYNTHETIC_ONLY'});
      if(req.method==='POST'&&path==='/api/v1/commands') {
        const b=await body(req);
        return json(res,200,store.command(actor,b));
      }
      if(req.method==='POST'&&path==='/api/v1/eligibility'){
        const b=await body(req);
        return json(res,200,store.setEligibility(actor,b.institutionId,b.memberId,b.eligible,b.key));
      }
      if(req.method==='POST'&&path==='/api/v1/policies'){
        const b=await body(req);
        return json(res,200,store.setPolicy(actor,b.institutionId,b.policy,b.key));
      }
      if(req.method==='POST'&&path==='/api/v1/actors/revoke'){
        const b=await body(req);
        if(typeof store.revokeActor!=='function')return json(res,501,{error:'EXTENDED_STORE_REQUIRED'});
        return json(res,200,store.revokeActor(actor,b.institutionId,b.memberId,b.key));
      }
      if(req.method==='POST'&&path==='/api/v1/sources'){
        const b=await body(req);
        if(typeof store.addSource!=='function')return json(res,501,{error:'EXTENDED_STORE_REQUIRED'});
        return json(res,200,store.addSource(actor,b.institutionId,b.sourceId,b.text,b.status,b.sourceUri,b.key));
      }
      if(req.method==='POST'&&path==='/api/v1/recertify'){
        if(!['admin','auditor'].includes(actor.role))return json(res,403,{error:'AUDITOR_REQUIRED'});
        const b=await body(req);
        if(actor.institutionId!==b.envelope?.payload?.institution?.id)return json(res,403,{error:'FORBIDDEN_TENANT'});
        const trustedPublicKeyPem=createPublicKey(privateKey).export({type:'spki',format:'pem'}).toString();
        const report=verifyExtended(b.envelope,{trustedPublicKeyPem});
        return json(res,200,{verification:report,impact:recertifyImpact(dependencyRecord(b.envelope.payload),b.changes),mode:'SYNTHETIC_ONLY'});
      }
      const match=path?.match(/^\/api\/v1\/institutions\/([a-z0-9-]+)\/items\/([a-z0-9-]+)(\/evidence|\/public-preview)?$/);
      if(req.method==='GET'&&match){
        const [,institutionId,itemId,suffix]=match;
        store.actorFor(actor,institutionId);
        const snap=store.snapshot(actor,institutionId,itemId);
        if(suffix==='/public-preview'){
          if(typeof store.publicPreview!=='function')return json(res,501,{error:'EXTENDED_STORE_REQUIRED'});
          return json(res,200,store.publicPreview(actor,institutionId,itemId));
        }
        if(suffix==='/evidence'){
          if(!['admin','clerk','auditor'].includes(actor.role))return json(res,403,{error:'EVIDENCE_ROLE_REQUIRED'});
          return json(res,200,exportEvidence(snap,privateKey));
        }
        // Do not expose voter-level evidence to generic members via the item endpoint.
        const {item,institution}=snap;return json(res,200,{item,institution,mode:'SYNTHETIC_ONLY'});
      }
      return json(res,404,{error:'NOT_FOUND'});
    }catch(e){return json(res,e.http||((e.code||e.message)==='UNAUTHENTICATED'?401:409),{error:e.code||e.message||'ERROR'});}
  });
  return {server,store};
}
if(process.argv[1]&&resolve(process.argv[1])===fileURLToPath(import.meta.url)){
  const {server}=createServer({dbPath:process.env.COMMONWEALTH_DB??join(root,'data','commonwealth.sqlite'),keyPath:process.env.COMMONWEALTH_KEY??join(root,'data','signing-key.pem')});
  const bind=process.env.COMMONWEALTH_BIND??'127.0.0.1';
  if(bind!=='127.0.0.1'&&bind!=='::1')throw new Error('DEMO_SERVER_LOCALHOST_ONLY');
  server.listen(Number(process.env.COMMONWEALTH_PORT??4180),bind,()=>console.log('Commonwealth OS synthetic API listening on '+server.address().address+':'+server.address().port));
}
