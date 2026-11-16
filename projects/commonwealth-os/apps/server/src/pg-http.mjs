// PostgreSQL-only synthetic participation HTTP host. No official voting API.
import http from 'node:http';
import { parse, fileURLToPath } from 'node:url';
import { resolve, dirname, join } from 'node:path';
import { readFileSync } from 'node:fs';
import { PgParticipationStore } from './pg-participation.mjs';
import { signingKey, exportEvidence } from './evidence.mjs';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const hdr={'Cache-Control':'no-store','X-Content-Type-Options':'nosniff','Referrer-Policy':'no-referrer','Cross-Origin-Resource-Policy':'same-origin'};
function json(res,status,data){res.writeHead(status,{...hdr,'Content-Type':'application/json; charset=utf-8','Content-Security-Policy':"default-src 'none'"});res.end(JSON.stringify(data));}
async function parseBody(req){
  let size=0;const chunks=[];
  for await(const chunk of req){size+=chunk.length;if(size>65536){const e=Error('PAYLOAD_TOO_LARGE');e.http=413;throw e;}chunks.push(chunk);}
  try{
    if(req.headers['content-type']?.split(';')[0]?.trim()!=='application/json')throw Error();
    const v=JSON.parse(Buffer.concat(chunks).toString('utf8'));
    if(!v||Array.isArray(v)||typeof v!=='object')throw Error();
    return v;
  }catch{const e=Error('INVALID_JSON_REQUEST');e.http=400;throw e;}
}
export function createPgServer(store,{keyPath=join(root,'data','pg-receipt-key.pem')}={}){
  const privateKey=signingKey(keyPath);
  return http.createServer(async(req,res)=>{
    try{
      const path=parse(req.url||'').pathname;
      if(req.method==='GET'&&path?.startsWith('/browser/')){
        const name=path==='/browser/'?'index.html':path.slice('/browser/'.length);
        if(!/^[A-Za-z0-9][A-Za-z0-9._-]*\.(?:html|mjs|js|css|json|svg)$/.test(name))return json(res,404,{error:'NOT_FOUND'});
        try{
          const content=readFileSync(resolve(root,'../browser',name));
          const mime=name.endsWith('.html')?'text/html':name.endsWith('.css')?'text/css':name.endsWith('.svg')?'image/svg+xml':name.endsWith('.json')?'application/json':'text/javascript';
          res.writeHead(200,{...hdr,'Content-Type':mime+'; charset=utf-8','Content-Security-Policy':"default-src 'self'; script-src 'self'; connect-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; object-src 'none'; frame-ancestors 'none'; base-uri 'none'"});
          return res.end(content);
        }catch{return json(res,404,{error:'NOT_FOUND'});}
      }
      if(req.method==='GET'&&path==='/healthz')return json(res,200,{mode:'SYNTHETIC_PG_ONLY',officialVoting:false,realIdentity:false});
      const token=(req.headers.authorization||'').match(/^Bearer ([a-f0-9]{64})$/)?.[1];
      if(!token)return json(res,401,{error:'UNAUTHENTICATED'});
      if(req.method==='GET'&&path==='/api/v1/me')return json(res,200,await store.me(token));
      if(req.method==='POST'&&path==='/api/v1/participation/commands')return json(res,200,await store.command(token,await parseBody(req)));
      const board=path?.match(/^\/api\/v1\/participation\/([a-z0-9-]+)\/board$/);
      if(req.method==='GET'&&board)return json(res,200,await store.view(token,board[1]));
      const d=path?.match(/^\/api\/v1\/participation\/([a-z0-9-]+)\/(dossiers|receipts)\/([A-Za-z0-9-]+)$/);
      if(req.method==='GET'&&d){
        const data=await store.dossier(token,d[1],d[3]);
        return json(res,200,d[2]==='receipts'?exportEvidence(data,privateKey):data);
      }
      return json(res,404,{error:'NOT_FOUND'});
    }catch(e){
      const status=e.http||(/^(PARTICIPATION_|FORBIDDEN_|PG_)/.test(e.code||'')?409:500);
      return json(res,status,{error:status===500?'INTERNAL_SERVER_ERROR':(e.code||e.message)});
    }
  });
}
if(process.argv[1]&&resolve(process.argv[1])===fileURLToPath(import.meta.url)){
  if(process.env.COMMONWEALTH_BIND&&process.env.COMMONWEALTH_BIND!=='127.0.0.1')throw Error('PG_DEMO_BIND_LOCALHOST_ONLY');
  const store=await PgParticipationStore.connect();
  const server=createPgServer(store);
  const port=Number(process.env.COMMONWEALTH_PORT??4180);
  server.listen(port,'127.0.0.1',()=>console.log('Commonwealth synthetic PG participation at http://127.0.0.1:'+port+'/browser/'));
  process.once('SIGINT',()=>server.close(async()=>{await store.close();process.exitCode=0;}));
}
