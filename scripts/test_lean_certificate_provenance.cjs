"use strict";
// Editorial provenance check, NOT a substitute for Lean or a novelty determination.
const fs=require("node:fs"),assert=require("node:assert/strict"),path=require("node:path");
const m=JSON.parse(fs.readFileSync("docs/lean-certificate-provenance.json","utf8"));
const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(d,e.name)):e.name.endsWith(".lean")?[path.join(d,e.name).replaceAll("\\","/")]:[]);
const real=walk("research/nightfall").sort(),got=m.modules.map(x=>x.path).sort();
assert.equal(m.schema,"nightfall-lean-provenance-v1");
assert.deepEqual(got,real,"Unclassified Lean file (must not silently inherit originality)");
assert.equal(new Set(got).size,got.length);
assert.equal(m.modules.length,39,"Frozen source count changed: refresh manifest against exact main tree");
const valid=new Set(["quarantine","derived-transfer","finite-construction"]);
for(const r of m.modules){
 assert.ok(valid.has(r.classification),r.path);
 assert.ok(fs.existsSync(r.path),"Missing module "+r.path);
 assert.equal(r.global_priority,"unverified",r.path);
 assert.ok(r.note.length>20,r.path);
 if(r.classification!=="quarantine") assert.ok(r.passport&&fs.existsSync("docs/"+r.passport),"Unpassported derived or constructed certificate "+r.path);
 if(r.ci_run!==null)assert.ok(Number.isSafeInteger(r.ci_run)&&r.ci_run>0,"Malformed CI pointer "+r.path);
}
for(const key of ["quarantine","derived-transfer","finite-construction"]){
 const n=m.modules.filter(x=>x.classification===key).length;
 assert.ok(n>0,key+" empty");
 const expected={quarantine:m.counts.quarantine,"derived-transfer":m.counts.derived_transfer,"finite-construction":m.counts.finite_construction}[key];
 assert.equal(n,expected,key+" count drift");
}
const phases=m.modules.filter(x=>x.classification==="finite-construction");
assert.deepEqual(phases.map(x=>x.path),["research/nightfall/formalization/phase_block/PhaseBlock.lean"]);
const page=fs.readFileSync("docs/lean-certificate-provenance.html","utf8");
assert.equal((page.match(/<tr><td>\d\d<\/td>/g)||[]).length,39,"Missing static site entries");
assert.ok(page.includes("Quarantine does not retract kernel compilation"));
assert.ok(page.includes('href="lean-certificate-provenance.json"'));
const source=fs.readFileSync("docs/phase-block-proof-passport.html","utf8");
assert.ok(source.includes("eighty_one_distinct_outputs")&&source.includes("40995299592")&&source.includes("priority"));
const active=fs.readFileSync("docs/active-proof-passport.html","utf8");
assert.ok(active.includes("lean-certificate-provenance.html")&&active.includes('id="phase-block"'));
const site=fs.readFileSync("docs/site.js","utf8");
for(const n of ["phase-block-proof-passport.html","lean-certificate-provenance.html"])assert.ok(site.includes('"'+n+'"'));
const sitemap=fs.readFileSync("docs/sitemap.xml","utf8");
for(const n of ["phase-block-proof-passport.html","lean-certificate-provenance.html"])assert.ok(sitemap.includes("/"+n));
console.log("PASS: 39 Lean files classified; quarantines prevent originality promotion; separate finite construction has full passport.");
