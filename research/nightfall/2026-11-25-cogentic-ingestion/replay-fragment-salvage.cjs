// Prototype only: historical evidence triage; no mathematical or current-main status promotion.
const fs=require('node:fs'),path=require('node:path');
function replay(fixture){
  const clone=x=>JSON.parse(JSON.stringify(x));
  const canonical=x=>x===null||typeof x!=="object"?JSON.stringify(x):Array.isArray(x)?"["+x.map(canonical).join(",")+"]":"{"+Object.keys(x).sort().map(k=>JSON.stringify(k)+":"+canonical(x[k])).join(",")+"}";
  const records=new Map(fixture.records.map(r=>[r.id,r]));if(records.size!==fixture.records.length)throw Error("duplicate trust record");
  const runs=new Map(fixture.observedRuns.map(r=>[r.id,r]));if(runs.size!==fixture.observedRuns.length)throw Error("duplicate trust run");
  function check(candidate,revoked=new Set(),active=new Set()){
    if(!candidate||typeof candidate.id!=="string"||!records.has(candidate.id))return "unknown";
    const trusted=records.get(candidate.id);
    if(canonical(candidate)!==canonical(trusted))return "scope-or-identity-mismatch";
    if(revoked.has(candidate.id)||revoked.has(candidate.head)||revoked.has(candidate.blob)||revoked.has(candidate.run))return "revoked";
    if(active.has(candidate.id))return "cycle";
    if(candidate.run===null)return "pending";
    const run=runs.get(candidate.run);
    if(!run||run.head!==candidate.head||run.result!=="success"||!run.requiredSteps.length)return "no-trusted-receipt";
    const next=new Set(active);next.add(candidate.id);
    for(const dep of candidate.deps)if(check(records.get(dep),revoked,next)!=="historical-evidence")return "dependency-blocked";
    return "historical-evidence";
  }
  const original=fixture.records.map(r=>({id:r.id,outcome:check(r),named:r.names.length}));
  const good=original.filter(x=>x.outcome==="historical-evidence");
  const pending=original.filter(x=>x.outcome==="pending");
  const [a,b,c,d,e]=fixture.records;
  const mut=(r,fn)=>{let x=clone(r);fn(x);return x;};
  const controls=[
    ["unknown-id",mut(a,x=>x.id="invented"),[],"unknown"],
    ["alter-head",mut(a,x=>x.head="0".repeat(40)),[],"scope-or-identity-mismatch"],
    ["alter-blob",mut(a,x=>x.blob="0".repeat(40)),[],"scope-or-identity-mismatch"],
    ["different-path",mut(a,x=>x.path+=".bak"),[],"scope-or-identity-mismatch"],
    ["widen-claim",mut(a,x=>x.names.push("Unproved.Theorem")),[],"scope-or-identity-mismatch"],
    ["current-main-promotion",mut(a,x=>x.scope="current-main-certified"),[],"scope-or-identity-mismatch"],
    ["remove-dependency",mut(b,x=>x.deps=[]),[],"scope-or-identity-mismatch"],
    ["cross-head-receipt",mut(c,x=>x.run=a.run),[],"scope-or-identity-mismatch"],
    ["forged-pending-receipt",mut(d,x=>x.run=a.run),[],"scope-or-identity-mismatch"],
    ["self-review-assertion",mut(a,x=>x.independentReview=true),[],"scope-or-identity-mismatch"],
    ["revoked-fragment",a,[a.id],"revoked"],
    ["revoked-dependency",b,[a.blob],"dependency-blocked"],
    ["revoked-run",c,[c.run],"revoked"],
    ["revoked-source-head",b,[b.head],"revoked"],
    ["pending-dependent",e,[],"pending"]
  ].map(([name,request,revoked,want])=>({name,want,got:check(request,new Set(revoked))}));
  const failures=controls.filter(x=>x.got!==x.want);
  const invalidPromotions=controls.filter(x=>x.got==="historical-evidence").length;
  if(good.length!==3||pending.length!==2||failures.length||invalidPromotions)throw Error(JSON.stringify({original,controls}));
  return {archiveCases:original.length,historicalModules:good.length,historicalNamedDeclarations:good.reduce((s,x)=>s+x.named,0),pendingModules:pending.length,wholeParentClosedRejectBaseline:0,controls:controls.length,controlFailures:failures.length,invalidPromotions,currentMainPromotions:0,original,controlOutcomes:controls};
}
const fixture=JSON.parse(fs.readFileSync(path.join(__dirname,'fragment-salvage-fixture.json'),'utf8'));
console.log(JSON.stringify(replay(fixture),null,2));
