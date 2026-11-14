"use strict";
/* Proof-carrying discovery is a research methodology, NOT a certification status.
 * Check published copy against the two independently dated claim registries. */
const fs=require("node:fs");
const assert=require("node:assert/strict");
const read=p=>fs.readFileSync(p,"utf8");
const historicSource=read("docs/research-registry.js");
const start=historicSource.indexOf("const REGISTRY=");
const end=historicSource.indexOf(";\nconst claimById",start);
assert.ok(start>=0&&end>start,"Canonical historical registry format changed");
const historic=JSON.parse(historicSource.slice(start+"const REGISTRY=".length,end));
const active=JSON.parse(read("docs/active-proof-passport.json"));
const leanManifest=JSON.parse(read("docs/lean-certificate-provenance.json"));
assert.ok(read("docs/discovery-system.html").includes(`${leanManifest.modules.length} Lean modules / novelty quarantine`),"Discovery-site source census drifted from Lean manifest");
assert.ok(read("docs/lean-certificate-provenance.html").includes(`PROVENANCE v${leanManifest.revision}`),"Provenance website footer version drifted");
assert.equal(historic.schema,"nightfall-proof-passports-v1");
assert.equal(active.schema,"nightfall-active-proof-passports-v1");
assert.equal(historic.asOf,"2026-10-30");
assert.equal(active.as_of,"2026-11-14");
assert.equal(active.version,13);
assert.equal(historic.claims.length,11);
assert.equal(historic.mechanisms.length,5);
assert.equal(historic.edges.length,20);
assert.equal(active.claims.length,12);
const historicalIDs=new Set(historic.claims.map(c=>c.id));
assert.ok(active.claims.every(c=>!historicalIDs.has(c.id)),"Current claims must not shadow historical claim identity");
const edgeTypes=new Set(historic.edges.map(e=>e.relation));
assert.deepEqual([...edgeTypes].sort(),["analogy","finite-check","method","open-premise"]);
for(const id of ["sidon30","erdos36"]){
 assert.ok(historic.edges.some(e=>e.from===id&&e.to==="exact-enumeration"&&e.relation==="finite-check"),"Source graph does not support the claimed common finite-check operator: "+id);
}
const system=read("docs/discovery-system.html");
const css=read("docs/discovery-system.css");
for(const [count,label] of [[historic.claims.length,"curated historical Proof Passports"],[active.claims.length,"separate active claim passports"],[historic.mechanisms.length,"historical mechanism categories"],[historic.edges.length,"typed historical claim–mechanism links"]]){
 assert.ok(system.includes("<dt>"+count+"</dt><dd>"+label+"</dd>"),"Displayed source-derived count diverged: "+label);
}
for(const stage of ["REPRESENT","INVENT","CERTIFY","ATTACK","REMEMBER","TRANSFER"])assert.ok(system.includes(stage),"Missing discovery lifecycle stage: "+stage);
for(const page of ["index.html","new-moon.html","passport.html","active-proof-passport.html","constellation.html","atlas.html","review.html"]){
 assert.ok(system.includes('href="'+page+'"')||system.includes('href="'+page+"#"),"Missing research-system destination "+page);
}
assert.ok(system.includes('id="cycle"')&&system.includes('href="#cycle"'),"Entry into the workflow broken");
assert.ok(system.includes('href="active-proof-passport.json"'),"Live active registry provenance absent");
assert.ok(system.includes("not yet integrated into the frozen historical graph"),"Active research must not be silently added to historical graph");
assert.ok(system.includes("not counts of proved theorems"),"System statistics need explicit count scope");
assert.ok(system.includes("not a theorem that every complex system is discoverable"),"Scientific overclaim must be disallowed");
assert.ok(system.includes("neither a live feed"),"Dated graph must not imply automatic updating");
assert.ok(system.includes("Kernel compilation certifies only the exact formal declaration"),"Lean certification scope must be explicit");
assert.ok(system.includes("Internal cross-model criticism is not an independent human referee"),"Internal reviews are not external");
assert.ok(system.includes("Novelty requires a dated"),"Novelty gate absent");
assert.equal((system.match(/<li><span class="ds-step">/g)||[]).length,6);
assert.ok(css.includes("@media(max-width:620px)")&&css.includes("@media(prefers-reduced-motion:reduce)"),"Responsive/reduced-motion contract absent");
assert.ok(!/\b(?:published theorem|globally solved|all systems are discoverable)\b/i.test(system),"Unscoped global novelty or universal solve claim");
const roles={
 "docs/index.html":'id="observatory"',
 "docs/new-moon.html":'id="archived-records"',
 "docs/constellation.html":'id="map"',
 "docs/about.html":'id="research-system"',
 "docs/passport.html":'class="pp-coverage"',
 "docs/active-proof-passport.html":'href="active-proof-passport.json"',
 "docs/atlas.html":'id="atlas-explore"',
 "docs/research.html":'class="wrap archive-coverage"',
 "docs/review.html":'id="start-here"',
 "docs/evidence.html":'class="wrap evidence-page"',
 "docs/observability.html":'id="quadratic"'
};
for(const [file,anchor] of Object.entries(roles)){
 const body=read(file);
 assert.ok(body.includes(anchor),file+" lost existing reader function");
 assert.ok(body.includes('href="discovery-system.html"'),file+" omits system identity handoff");
}
const home=read("docs/index.html"),moon=read("docs/new-moon.html");
assert.ok(home.includes("PROOF PASSPORTS + CONSTELLATION"),"Active home is not graph/passport centered");
assert.ok(home.includes("no edge certifies a transfer theorem"),"Home overstates relationship transfer");
assert.equal((home.match(/class="nf-evidence-cycle"/g)||[]).length,1);
assert.ok(moon.includes("THE PRESERVATION HALF OF THE DISCOVERY SYSTEM"),"Archive lifecycle absent");
assert.ok(moon.includes("preserve negative tests")||moon.includes("Preserve negative tests"),"Failures must remain visible");
assert.ok(read("docs/sitemap.xml").includes("/discovery-system.html"),"Discovery-system canonical URL absent from sitemap");
assert.ok(read("docs/README.md").includes("[Discovery System](discovery-system.html)"),"Maintenance charter missing");
console.log("PASS: source-matched discovery identity; 11 historical, 12 active, 5 mechanisms, 20 typed links; gated claims and typed transfers");
