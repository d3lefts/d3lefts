#!/usr/bin/env node
'use strict';
// Generated evidence view; no proof execution or status mutation.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..');
const inputPaths={
  "active": "docs/active-proof-passport.json",
  "historical": "docs/lean-certificate-provenance.json",
  "pending": "docs/lean-pending-source-custody.json",
  "recent": "docs/recent-research.json",
  "v2": "docs/proof-passport-v2.json",
  "reconciled": "docs/active-passport-source-reconciliation-v2.json",
  "warrants": "docs/lean-warrant-bridge-v1.json",
  "overlay": "docs/lean-proof-passport-overlay.json",
  "catalogue": "research/catalogue/CLAIMS.json",
  "salvage": "research/nightfall/2026-11-25-cogentic-ingestion/fragment-salvage-fixture.json",
  "publications": "papers/publications.json",
  "compiler": "docs/lean-compiler-lock.json",
  "observed": "docs/proof-passport-v3-observed-receipts.json",
  "paper_vi_publication": "research/nightfall/paper-vi-publication-20261125/CERTIFICATE.json"
};
function build(d,paths){
 const assert=(v,m)=>{if(!v)throw Error(m)};
 const sha=/^[a-f0-9]{40}$/;
 const records=[],byId=new Map(),sources=new Map();
 const put=(origin,x,info={})=>{
  const id=origin+":"+x.id;
  assert(typeof x.id==="string"&&x.id&&!byId.has(id),"duplicate/invalid record "+id);
  const row={id,origin:paths[origin],original_id:x.id,title:x.title||null,kind:info.kind||"claim-reference",state:info.state||"reported-scope-only",path:info.path||null,blob:info.blob||null,head:info.head||null,run:info.run||null,job:info.job||null,pr:info.pr||null,declarations:info.declarations||[],scope:info.scope||null,dependencies:info.dependencies||[],unresolved_dependencies:info.unresolved||[],links:info.links||[],promotion_authorized:false};
  if(row.blob)assert(sha.test(row.blob),"bad blob "+id);
  if(row.head)assert(sha.test(row.head),"bad head "+id);
  if(row.run!==null)assert(Number.isSafeInteger(row.run)&&row.run>0,"bad run "+id);
  assert(Array.isArray(row.declarations)&&row.declarations.every(n=>typeof n==="string"&&n.length>0),"bad declaration "+id);
  byId.set(id,row);records.push(row);return row;
 };
 const decl=n=>typeof n==="string"&&n?[n]:[];
 const runURL=s=>typeof s==="string"&&/\/actions\/runs\/(\d+)/.test(s)?Number(s.match(/\/actions\/runs\/(\d+)/)[1]):null;
 for(const [origin,rows] of [["historical",d.historical.modules],["pending",d.pending.sources]]){
  for(const x of rows){
   assert(typeof x.path==="string"&&x.path.startsWith("research/nightfall/")&&x.path.endsWith(".lean")&&!x.path.split("/").includes(".."),"invalid source path");
   assert(sha.test(x.source_blob_sha)&&!sources.has(x.path),"bad/duplicate custody "+x.path);
   const note=x.receipt_scope||x.ci_receipt_scope||x.note||"";
   const leads=origin==="pending"?[...new Set([...note.matchAll(/\b\d{10,12}\b/g)].map(m=>Number(m[0])))]:[];
   sources.set(x.path,{path:x.path,blob:x.source_blob_sha,custody:origin,classification:x.classification,legacy_run:x.ci_run||null,receipt_leads:leads,evidence:[]});
   if(origin==="historical")put(origin,{id:x.path},{kind:"historical-source-receipt",path:x.path,blob:x.source_blob_sha,head:x.ci_run_head_sha,run:x.ci_run,scope:x.note,state:"legacy-source-match"});
  }
 }
 for(const x of d.historical.off_main_certificates||[])put("historical",{...x,id:"off-main-"+x.id},{kind:"archived-receipt-reference",path:x.path,run:x.source_ci,scope:"Frozen off-main scope; see original record.",state:"historical-branch-reference"});
 for(const x of d.active.claims)put("active",x,{state:x.status,scope:x.claim,links:["reconciled:"+x.id]});
 for(const x of d.reconciled.records)put("reconciled",x,{kind:"claim-source-reconciliation",path:x.primary_source?.path,blob:x.primary_source?.git_blob_sha1,head:x.receipt?.head_sha,run:x.receipt?.ci_run,pr:x.receipt?.pr,declarations:decl(x.formal_declaration),scope:x.actual_scope,state:"source-reconciled-not-new-kernel",links:["active:"+x.id]});
 for(const x of d.recent.claims)put("recent",x,{kind:"claim-reference",head:x.head,run:x.run,pr:x.pr,declarations:decl(x.declaration),scope:x.scope,state:x.tier});
 for(const x of d.v2.records)put("v2",x,{kind:"named-receipt-reference",path:x.source?.kind==="repository"?x.source.path:null,blob:x.source?.kind==="repository"?x.source.git_blob_sha1:null,head:x.receipt?.head_sha,run:x.receipt?.run_id,pr:x.receipt?.pr,declarations:decl(x.formal?.declaration),scope:x.claim_scope,state:x.assertion_status,dependencies:(x.dependencies||[]).map(y=>"v2:"+y)});
 for(const x of d.warrants.records)put("warrants",x,{kind:"named-warrant-reference",path:x.source_path,blob:x.source_blob_sha1,head:x.receipt_head,run:x.run_id,pr:x.pr,declarations:decl(x.declaration),scope:x.scope,state:x.evidence_status});
 for(const x of d.overlay.records)put("overlay",x,{kind:"named-receipt-reference",path:x.source_path,blob:x.git_blob_sha1,head:x.evidence?.head,run:x.evidence?.ci_run,pr:x.evidence?.pr,declarations:decl(x.theorem_declaration),scope:typeof x.limitations==="string"?x.limitations:null,state:"legacy-overlay",unresolved:x.dependencies||[],links:x.passport_id&&d.active.claims.some(y=>y.id===x.passport_id)?["active:"+x.passport_id]:[]});
 for(const x of d.catalogue.claims)put("catalogue",x,{kind:"catalogue-claim",path:typeof x.primary==="string"&&x.primary.endsWith(".lean")?x.primary:null,head:x.formal?.head,run:runURL(x.formal?.receipt),declarations:decl(x.formal?.declaration),scope:x.claim_scope,state:x.validity,unresolved:x.dependencies||[]});
 for(const x of d.salvage.records)put("salvage",x,{kind:"historical-fragment",path:x.path,blob:x.blob,head:x.head,run:x.run,pr:x.pr,declarations:x.names,scope:x.scope,state:x.run?"historical-evidence-reference":"pending",dependencies:x.deps.map(y=>"salvage:"+y)});
 for(const x of d.publications.records)put("publications",x,{kind:"publication-reference",scope:x.scope,state:x.publication_status});
 for(const x of d.observed.records){
  assert(x.job_status==="success"&&x.run&&x.job&&x.head&&x.blob&&x.declarations.length,"incomplete observed receipt "+x.id);
  put("observed",x,{kind:"observed-job-named-audit",path:x.path,blob:x.blob,head:x.head,run:x.run,job:x.job,pr:x.pr,declarations:x.declarations,scope:x.scope,state:"observed-historical-job-pass"});
 }
 const pc=d.paper_vi_publication;
 assert(pc&&pc.staged&&pc.tensor&&pc.staged.local_kernel,"incomplete Paper VI certificate archive");
 assert(pc.staged.local_kernel.exit_status===0&&/^[a-f0-9]{64}$/.test(pc.staged.export_sha256)&&/^[a-f0-9]{64}$/.test(pc.staged.local_kernel.log_sha256),"bad reported local replay receipt");
 assert(pc.staged.theorems.every(n=>d.observed.records.some(x=>x.pr===pc.staged.pr&&x.run===pc.staged.reconciled_run&&x.declarations.includes(n))),"Paper VI staged audit scope detached");
 assert(pc.tensor.theorems.every(n=>d.observed.records.some(x=>x.pr===pc.tensor.pr&&x.run===pc.tensor.run&&x.declarations.some(m=>m.endsWith("."+n)))),"Paper VI tensor audit scope detached");
 put("paper_vi_publication",{id:"staged-original-head",title:pc.manuscript},{kind:"publication-scope-kernel-reference",head:pc.staged.source_head,run:pc.staged.run,pr:pc.staged.pr,declarations:pc.staged.theorems,scope:pc.scope,state:"archived-publication-scope-pass",links:["observed:pr1201-PaperVIGeneralLatentTerminal"]});
 put("paper_vi_publication",{id:"staged-local-export-replay",title:"Paper VI closed dependency local kernel replay"},{kind:"reported-local-kernel-replay",head:pc.staged.source_head,run:pc.staged.export_run,pr:pc.staged.pr,declarations:pc.staged.theorems,scope:"Archived local replay exit 0; export artifact "+pc.staged.export_artifact+"; export SHA256 "+pc.staged.export_sha256+"; local log SHA256 "+pc.staged.local_kernel.log_sha256+". Not freshly replayed by this generator. Source integration and manuscript correspondence remain separate.",state:"reported-local-kernel-pass",links:["paper_vi_publication:staged-original-head","observed:pr1201-PaperVIGeneralLatentTerminal"]});
 put("paper_vi_publication",{id:"tensor-headline",title:"Paper VI tensor representation obstruction"},{kind:"publication-scope-kernel-reference",head:pc.tensor.head,run:pc.tensor.run,pr:pc.tensor.pr,declarations:pc.tensor.theorems,scope:pc.scope,state:"archived-publication-scope-pass",links:["observed:pr1212-PaperVITensorTerminal"]});
 const rev=new Set(d.observed.revoked||[]);
 const visiting=new Set(),done=new Map();
 function disposition(id){
  assert(byId.has(id),"unknown dependency "+id);
  assert(!visiting.has(id),"dependency cycle "+id);
  if(done.has(id))return done.get(id);
  visiting.add(id);const x=byId.get(id),s=sources.get(x.path);
  const deps=x.dependencies.map(disposition);
  let result="not-applicable";
  if(x.path&&x.blob)result=s?(s.blob===x.blob?"current-custody-blob-match":"source-drift"):"off-main-or-out-of-scope";
  if([id,x.original_id,x.blob,x.head,x.run].some(y=>rev.has(y)))result="revoked";
  else if(deps.some(y=>["revoked","dependency-blocked","source-drift"].includes(y)))result="dependency-blocked";
  visiting.delete(id);done.set(id,result);return result;
 }
 for(const x of records){
  for(const l of x.links)assert(byId.has(l),"unknown link "+l);
  x.source_match=disposition(x.id);
  if(x.path&&x.blob&&x.source_match==="current-custody-blob-match")sources.get(x.path).evidence.push(x.id);
 }
 const counts={};
 for(const x of records)counts[x.origin]=(counts[x.origin]||0)+1;
 const inventory=[...sources.values()].sort((a,b)=>a.path.localeCompare(b.path));
 const direct=inventory.filter(s=>s.evidence.some(id=>byId.get(id).run!==null));
 return {schema:"nightfall.generated-proof-passports.v3",policy:"Evidence view only. Historical receipts, current-source identity, dependency replay, mathematical statement equivalence, independent review, originality, significance and publication remain separate. No automatic promotion; no global CI census claim.",input_paths:paths,compiler:d.compiler,summary:{custody_sources:inventory.length,historical_source_records:d.historical.modules.length,pending_legacy_custody:d.pending.sources.length,source_paths_with_exact_blob_and_receipt_reference:direct.length,pending_source_paths_with_receipt_leads:inventory.filter(s=>s.receipt_leads.length).length,known_record_refs:records.length,distinct_referenced_runs:new Set(records.map(r=>r.run).filter(Boolean)).size,observed_job_modules:d.observed.records.length,observed_named_declaration_refs:d.observed.records.reduce((n,r)=>n+r.declarations.length,0),record_counts_by_input:counts,all_historical_runs_exhaustive:false,current_kernel_replay_in_this_generator:false,automatic_promotions:0},sources:inventory,records:records.sort((a,b)=>a.id.localeCompare(b.id)),paper_vi_publication_certificate:pc,failed_jobs:d.observed.failed_jobs||[],exceptions:d.observed.exceptions||[],limitations:["The source inventory is exhaustive only for the tracked research/nightfall Lean tree when the local byte/coverage gate passes.","Receipt leads extracted from prose are candidates only. The PR/run API does not enumerate all historical jobs here.","Cross-registry claim aliases are preserved; do not sum record counts as discoveries. Only explicit dependency edges are checked; imported Lean closure and semantic correspondence require separate replay/review.","Source match means equal file bytes, not equal dependency closure or a current compiler proof. Off-main evidence stays off-main."]};
}
function selfTest(d,paths){
 const base=build(d,paths);const bad=[
 x=>x.pending.sources.push(x.pending.sources[0]),
 x=>x.pending.sources[0].source_blob_sha="not-a-blob",
 x=>x.observed.records[0].job_status="failure",
 x=>x.salvage.records[0].deps.push(x.salvage.records[0].id),
 x=>x.salvage.records[0].deps.push("missing"),
 x=>x.v2.records[0].dependencies.push(x.v2.records[0].id),
 x=>x.reconciled.records.pop()
 ];
 let blocked=0;
 for(const m of bad){const x=JSON.parse(JSON.stringify(d));m(x);try{build(x,paths)}catch(e){blocked++;continue;}throw Error("mutation accepted");}
 const rev=JSON.parse(JSON.stringify(d));rev.observed.revoked=["native-oracle"];const rv=build(rev,paths);
 if(rv.records.find(x=>x.id==="salvage:native-oracle").source_match!=="revoked"||rv.records.find(x=>x.id==="salvage:native-terminal").source_match!=="dependency-blocked")throw Error("revocation not propagated");
 const drift=JSON.parse(JSON.stringify(d));const target=drift.observed.records.find(x=>drift.pending.sources.some(y=>y.path===x.path));drift.pending.sources.find(y=>y.path===target.path).source_blob_sha="0".repeat(40);
 if(build(drift,paths).records.find(x=>x.id==="observed:"+target.id).source_match!=="source-drift")throw Error("source drift not detected");
 return {blocked,revocation_and_drift:2,summary:base.summary};
}
const d=Object.fromEntries(Object.entries(inputPaths).map(([k,p])=>[k,JSON.parse(fs.readFileSync(path.join(root,p),'utf8'))]));
const out=build(d,inputPaths);
const blob=b=>crypto.createHash('sha1').update(Buffer.from('blob '+b.length+'\0')).update(b).digest('hex');
const walk=p=>fs.readdirSync(path.join(root,p),{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(p+'/'+e.name):e.isFile()&&e.name.endsWith('.lean')?[p+'/'+e.name]:[]);
const actual=walk('research/nightfall').sort(),registered=out.sources.map(x=>x.path).sort();
if(JSON.stringify(actual)!==JSON.stringify(registered))throw Error('Lean custody inventory drift: reconcile missing/extra paths before sync');
for(const s of out.sources)if(blob(fs.readFileSync(path.join(root,s.path)))!==s.blob)throw Error('Lean source blob drift '+s.path);
out.input_blobs=Object.fromEntries(Object.entries(inputPaths).map(([k,p])=>[k,blob(fs.readFileSync(path.join(root,p)))]));
if(process.argv.includes('--self-test'))console.log(JSON.stringify(selfTest(d,inputPaths)));
const bytes=JSON.stringify(out,null,2)+'\n';
const target=path.join(root,'docs/proof-passport-v3.json');
if(process.argv.includes('--write'))fs.writeFileSync(target,bytes);
if(process.argv.includes('--check')&&(!fs.existsSync(target)||fs.readFileSync(target,'utf8')!==bytes))throw Error('Generated passport stale: run node scripts/sync_proof_passports_v3.cjs --write and commit snapshot');
const i=process.argv.indexOf('--output');if(i>=0){const dest=process.argv[i+1];fs.mkdirSync(path.dirname(dest),{recursive:true});fs.writeFileSync(dest,bytes);}
console.log(JSON.stringify(out.summary,null,2));
