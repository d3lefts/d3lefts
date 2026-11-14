"use strict";
/* Read-only editorial/research communication contract. Scientific proof is
   reviewed elsewhere; this gate prevents source/status presentation drift. */
const assert=require("node:assert/strict");
const fs=require("node:fs");
const read=path=>fs.readFileSync(path,"utf8");

const railPages=[
 "mathematical-results","observability","review","research",
 "quantum-observability","agent-safety-under-abstraction",
 "november-2026","new-moon","erdos-paper","product-space-influence"
];
for(const page of railPages){
 const body=read("docs/"+page+".html");
 assert.equal((body.match(/class="nf-evidence-rail wrap"/g)||[]).length,1,page+": missing single evidence rail");
 const section=body.match(/<dl class="nf-evidence-rail wrap"[^>]*>([\s\S]*?)<\/dl>/)?.[1]||"";
 assert.equal((section.match(/<dt>/g)||[]).length,3,page+": not three evidence labels");
 assert.equal((section.match(/<dd>/g)||[]).length,3,page+": not three evidence statements");
 assert.ok(!/THEOREM PROVED END-TO-END|WORLD-FIRST PROVEN/i.test(section),page+": invalid promotion");
}

const navPages=[
 "mathematical-results","observability","research","product-space-influence",
 "quantum-observability","agent-safety-under-abstraction",
 "november-2026","active-proof-passport"
];
const targets=["index.html","active-proof-passport.html","research.html","review.html"];
for(const page of navPages){
 const body=read("docs/"+page+".html");
 const nav=body.match(/<nav class="nav" id="site-nav" aria-label="Primary navigation">([\s\S]*?)<\/nav>/)?.[1]||"";
 const links=[...nav.matchAll(/href="([^"]+)"/g)].map(x=>x[1]);
 assert.deepEqual(links,targets,page+": principal research navigation drift");
}
const home=read("docs/index.html");
assert.ok(home.includes('href="active-proof-passport.html#q2-influence"'),"First-screen current proof passport missing");
assert.ok(home.includes("C₂=(10+2√2)²(1+√3)²"),"Proposed scalar constant drift");
assert.ok(home.includes("not end-to-end Lean-certified"),"Full quadratic Lean status misrepresented");

const mathematics=read("docs/mathematical-results.html");
const review=read("docs/review.html");
const observability=read("docs/observability.html");
const dispatch=read("docs/november-2026.html");
const quantum=read("docs/quantum-observability.html");
assert.ok(mathematics.includes("v9.2 PDF")&&mathematics.includes("Corollary 6.2"),"Latest source-custody risk missing");
assert.ok(mathematics.includes("225(1+√3)")&&mathematics.includes("historical"),"Older constant must be retained with scope");
assert.ok(review.includes("C₂=(10+2√2)²(1+√3)²")&&review.includes("global matched parity"),"Current referee task drift");
assert.ok(observability.includes("conditional on the scalar quadratic influence theorem")&&observability.includes("lower example alone"),"Conditional upper/lower separation absent");
assert.ok(quantum.includes("Conditional on quadratic C₂"),"Quantum implication lost scalar dependency");
assert.ok(dispatch.includes("Sixty-seven scoped Lean source modules"),"Current provenance census drift");
const registry=JSON.parse(read("docs/active-proof-passport.json"));
const manifest=JSON.parse(read("docs/lean-certificate-provenance.json"));
assert.equal(registry.version,13);
assert.equal(registry.claims.length,12);
assert.equal(manifest.modules.length,67);
assert.ok(registry.claims.find(x=>x.id==="q2-influence").claim.includes("736.673"));
const css=read("docs/site.css");
assert.ok(css.includes(".nf-evidence-rail")&&css.includes("@media(max-width:680px)"),"Shared mobile editorial styling missing");
const guide=read("docs/RESEARCH_COMMUNICATION_GUIDE.md");
assert.ok(guide.includes("Claim:")&&guide.includes("Evidence:")&&guide.includes("Limit:"),"Scientific design contract missing");
console.log("PASS research communication: 10 evidence rails, 8 common nav routes, current v9.2 and scope, live registry and responsive visual tokens");
