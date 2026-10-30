"use strict";
// Claim-registry editorial contract; no mathematical proof or benchmark replay.
const fs=require("node:fs");
const vm=require("node:vm");
const assert=require("node:assert/strict");
const source=fs.readFileSync("docs/research-registry.js","utf8");
const sandbox={window:{}};vm.runInNewContext(source,sandbox);
const R=sandbox.window.NightfallRegistry;
assert.equal(R.asOf,"2026-10-30");
assert.equal(R.claims.length,11);
assert.equal(new Set(R.claims.map(c=>c.id)).size,R.claims.length);
const added=["asua-collateral","shadow-nonabelian","factor-network","erdos-dual-ceiling","phase-tail"];
const root="https://github.com/d3lefts/d3lefts/blob/main/";
for(const id of added){
  const c=R.claimById(id);assert(c,"missing "+id);
  for(const p of ["title","short","statement","conditions","metric","measurement","kind"])assert(c[p],"empty "+id+" "+p);
  for(const k of R.dimensions){const d=c[k];assert(d&&d.level&&d.label&&d.detail,"empty dimension "+id+" "+k);}
  assert(c.assumptions.length>=3&&c.open.length>=2&&c.history.length&&c.sources.length>=2);
  for(const p of [...c.sources.map(s=>s.url),...c.history.map(h=>h.url)]){
    assert(p.startsWith(root),"unscoped url "+p);
    assert(fs.existsSync(p.slice(root.length)),"source link missing "+p);
  }
  assert(c.open.every(x=>x.length>15),"missing adversarial follow-up "+id);
  assert(!c.originality.label.toLowerCase().includes("novel contribution"),"unreviewed priority inflated");
}
const html=fs.readFileSync("docs/passport.html","utf8");
const library=fs.readFileSync("docs/research.html","utf8");
assert(html.includes("Eleven curated Proof Passports"));
assert(library.includes("40 → 11 → 5"));
assert(library.includes("Explore the eleven Proof Passports"));
const manifest=JSON.parse(fs.readFileSync("research/nightfall/SITE_CURATED_40_20261030.json","utf8"));
const originalManifest=JSON.parse(fs.readFileSync("research/nightfall/SITE_CURATED_33_20261029.json","utf8"));
assert.equal(manifest.entries.length,40);
assert.equal(new Set(manifest.entries.map(x=>x.id)).size,40);
assert.equal(originalManifest.entries.length,33);
for(const entry of originalManifest.entries)assert.deepEqual(manifest.entries.find(x=>x.id===entry.id),entry);
for(const id of ["34","35","36","37"]){
 const e=manifest.entries.find(x=>x.id===id);assert.equal(e.evidence,"working");
 assert(e.boundary.includes("Draft PR")&&e.boundary.includes("review"));
 const s="research/nightfall/"+e.source;assert(fs.existsSync(s));
 assert(library.includes('data-doc-id="'+id+'"'));
}
assert.equal(manifest.entries.find(x=>x.id==="39").evidence,"proposal");
assert.equal(manifest.entries.find(x=>x.id==="40").evidence,"software");
for(const entry of manifest.entries)assert(fs.existsSync("research/nightfall/"+entry.source));
assert.equal((library.match(/<article class="atlas-card"/g)||[]).length,40);
assert(library.includes('value="proposal"'));
for(const e of R.edges){assert(R.claimById(e.from));assert(R.mechanismById(e.to));assert(e.source,"unsourced graph edge");}
console.log("Proof Passport batch: 11 curated records, five new scoped claims, source paths and graph invariants PASS");
