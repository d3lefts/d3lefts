// Read-only historical evidence triage, not an authenticated receipt checker.
// No claim registry writes, network access, or promotion authority.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..');
const read=p=>fs.readFileSync(path.resolve(root,p));
const gitBlob=b=>crypto.createHash('sha1').update(Buffer.from('blob '+b.length+'\0')).update(b).digest('hex');
function validate(f){
  const assert=(v,m)=>{if(!v)throw Error(m);};
  const sha=/^[0-9a-f]{40}$/;
  assert(f.version===1&&Array.isArray(f.records)&&Array.isArray(f.observedRuns),"schema");
  const records=new Map(),runs=new Map();
  for(const x of f.observedRuns){
    assert(Number.isSafeInteger(x.id)&&!runs.has(x.id)&&sha.test(x.head)&&x.result==="success"&&Array.isArray(x.requiredSteps)&&x.requiredSteps.length>0,"invalid run");
    runs.set(x.id,x);
  }
  for(const x of f.records){
    assert(typeof x.id==="string"&&x.id&&!records.has(x.id)&&sha.test(x.head)&&sha.test(x.blob)&&x.scope==="historical-exact-head-only","record identity/scope");
    assert(typeof x.path==="string"&&x.path.startsWith("research/")&&!x.path.split("/").includes(".."),"path");
    assert(Array.isArray(x.names)&&x.names.length>0&&new Set(x.names).size===x.names.length&&Array.isArray(x.deps)&&new Set(x.deps).size===x.deps.length,"declarations/dependencies");
    assert(x.run===null||(runs.has(x.run)&&runs.get(x.run).head===x.head),"receipt head");
    records.set(x.id,x);
  }
  const visiting=new Set(),done=new Set();
  function visit(id){
    assert(records.has(id),"unknown dependency");
    assert(!visiting.has(id),"dependency cycle");
    if(done.has(id))return;
    visiting.add(id);
    for(const d of records.get(id).deps)visit(d);
    visiting.delete(id);done.add(id);
  }
  for(const id of records.keys())visit(id);
  return true;
}
function test(f){
  validate(f);
  const mutations=[
    x=>x.records[0].deps.push(x.records[0].id),
    x=>x.records[0].deps.push(x.records[1].id),
    x=>x.records[0].deps.push("unknown"),
    x=>x.records.push(x.records[0]),
    x=>x.observedRuns.push(x.observedRuns[0]),
    x=>x.records[0].run=x.observedRuns[1].id,
    x=>x.records[0].scope="current-main-certified",
    x=>x.records[0].names=[],
    x=>x.observedRuns[0].result="failure",
    x=>x.records[0].path="research/../outside"
  ];
  let blocked=0;
  for(const mutate of mutations){
    const x=JSON.parse(JSON.stringify(f));mutate(x);
    try{validate(x);}catch(e){blocked++;continue;}
    throw Error("malformed ledger accepted");
  }
  return {malformedLedgerControls:blocked,automaticPromotions:0};
}
const lock=JSON.parse(read('docs/fragment-salvage-lock.json'));
if(lock.schema!=='nightfall-fragment-salvage-lock/v1'||lock.scope!=='historical-exact-head-only'||lock.files.length!==2)throw Error('lock schema');
for(const e of lock.files)if(gitBlob(read(e.path))!==e.git_blob)throw Error('pinned byte mismatch '+e.path);
const fixture=JSON.parse(read(lock.files[0].path));
console.log(JSON.stringify(test(fixture),null,2));
require('node:child_process').execFileSync(process.execPath,[path.resolve(root,lock.files[1].path)],{stdio:'inherit'});
