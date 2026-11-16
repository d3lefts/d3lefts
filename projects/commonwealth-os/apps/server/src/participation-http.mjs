// Local-only, synthetic Commonwealth browser/API integration.
// Imported by src/http.mjs; never sets CORS or enables official voting.
import { readFileSync } from 'node:fs';
import { resolve, dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { publicDossier } from '../../browser/participation-core.mjs';
const HERE=dirname(fileURLToPath(import.meta.url));
const BROWSER=resolve(HERE,'../../browser');
const ASSETS=new Set(['index.html','styles.css','workspace.css','participation.css','participation-backend.css','app.mjs','core.mjs','fixtures.mjs','workspace.mjs','history-core.mjs','historical-fixtures.js','question-data.mjs','participation-core.mjs','participation-ui.mjs']);
const MIME={html:'text/html; charset=utf-8',css:'text/css; charset=utf-8',mjs:'text/javascript; charset=utf-8',js:'text/javascript; charset=utf-8'};
const HEADERS={
 'Cache-Control':'no-store', 'X-Content-Type-Options':'nosniff',
 'Referrer-Policy':'no-referrer', 'X-Frame-Options':'DENY',
 'Content-Security-Policy':"default-src 'none'; script-src 'self'; style-src 'self'; img-src 'self' data:; connect-src 'self'; base-uri 'none'; object-src 'none'; frame-ancestors 'none'; form-action 'self'"
};
const json=(res,status,value)=>{res.writeHead(status,{'Content-Type':'application/json; charset=utf-8',...HEADERS});res.end(JSON.stringify(value));};

export function serveSyntheticBrowser(req,res,path){
 if(req.method!=='GET'&&req.method!=='HEAD')return false;
 if(path==='/demo') {res.writeHead(302,{'Location':'/demo/','Cache-Control':'no-store'});res.end();return true;}
 if(!path.startsWith('/demo/'))return false;
 const file=path.slice('/demo/'.length)||'index.html';
 if(!ASSETS.has(file)) {json(res,404,{error:'DEMO_ASSET_NOT_FOUND'});return true;}
 const contents=readFileSync(join(BROWSER,file));
 const ext=file.split('.').pop();res.writeHead(200,{'Content-Type':MIME[ext]||'application/octet-stream',...HEADERS});
 res.end(req.method==='HEAD'?undefined:contents);return true;
}
async function body(req){
 if(!/^application\/json(?:\s*;|$)/i.test(req.headers['content-type']||'')){const e=new Error('JSON_CONTENT_TYPE_REQUIRED');e.http=415;throw e;}
 let b='';for await(const ch of req){b+=ch;if(b.length>32768){const e=new Error('PARTICIPATION_PAYLOAD_TOO_LARGE');e.http=413;throw e;}}
 try{const v=JSON.parse(b);if(!v||typeof v!=='object'||Array.isArray(v))throw Error();return v;}
 catch{const e=new Error('INVALID_PARTICIPATION_JSON');e.http=400;throw e;}
}
export async function serveParticipationAPI(req,res,path,actor,participation){
 const m=path.match(/^\/api\/v1\/participation\/(UAH|HOA|HSV)(?:\/(commands|dossiers)\/?([A-Za-z0-9-]+)?)?$/);
 if(!m)return false;
 const [,institution,suffix,id]=m;
 if(req.method==='GET'&&!suffix){json(res,200,participation.read(actor,institution));return true;}
 if(req.method==='POST'&&suffix==='commands'&&!id){json(res,200,participation.command(actor,institution,await body(req)));return true;}
 if(req.method==='GET'&&suffix==='dossiers'&&id){
  const board=participation.read(actor,institution).board;
  const p=board.proposals.find(p=>p.id===id&&p.institution===institution);
  if(!p){json(res,404,{error:'UNKNOWN_FICTIONAL_PROPOSAL'});return true;}
  json(res,200,{mode:'SYNTHETIC_ONLY',dossier:publicDossier(p),official:false});return true;
 }
 json(res,405,{error:'UNSUPPORTED_PARTICIPATION_METHOD'});return true;
}
