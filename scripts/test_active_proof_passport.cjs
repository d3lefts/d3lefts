"use strict";
// Scoped active-claim ledger: no historical Proof Passport or claim-status promotion.
const assert=require("node:assert/strict");
const fs=require("node:fs");
const read=path=>fs.readFileSync(path,"utf8");
const data=JSON.parse(read("docs/active-proof-passport.json"));
const html=read("docs/active-proof-passport.html");
const home=read("docs/index.html");
const moon=read("docs/new-moon.html");
const research=read("docs/research.html");
const site=read("docs/site.js");
const core=read("docs/erdos-paper-core.js");
const art=read("docs/media/overlap-16cell-fixture.svg");
assert.equal(data.schema,"nightfall-active-proof-passports-v1");
assert.equal(data.version,1);
assert.match(data.as_of,/^2026-11-\d\d$/);
assert.equal(data.lifecycle,"active");
assert.equal(data.frozen_historical_registry_unchanged,true);
assert.equal(data.claims.length,4);
assert.deepEqual(data.claims.map(x=>x.id),["q2-influence","q2-observation","finite-certificate","cubic-obstruction"]);
assert.equal(new Set(data.claims.map(x=>x.id)).size,data.claims.length);
const statuses=new Set(["paper-proof-internal-audit","reported-lean-checkpoint-replay-pending",
 "explicit-paper-proofs-not-external-refereed"]);
for(const c of data.claims){
 assert.ok(statuses.has(c.status),c.id+" wrong status");
 for(const key of ["title","claim","mechanism","evidence","audit","source","source_detail"])
  assert.ok(c[key]?.length>15,c.id+" missing "+key);
 assert.ok(Array.isArray(c.assumptions)&&c.assumptions.length>=2,c.id+" premises missing");
 assert.ok(Array.isArray(c.limitations)&&c.limitations.length>=2,c.id+" limits missing");
 assert.ok(fs.existsSync(c.source),c.id+" source unavailable: "+c.source);
 assert.ok(html.includes('id="'+c.id+'"'),"Missing static and accessible passport section "+c.id);
}
assert.ok(html.includes("manually versioned snapshot")||html.includes("manually versioned"));
assert.ok(html.includes(data.source_checkpoint.commit),"Dated source commit must be visible");
assert.ok(html.includes('href="active-proof-passport.json"'),"No machine-readable export link");
assert.ok(html.includes('href="passport.html"'),"Historical registry remains separate");
assert.ok(html.includes("no external")||html.includes("No global novelty"),"Evidence limitations absent");
assert.ok(html.includes('class="nf-claim-grid"')&&html.includes("Evidence"));
assert.ok(home.includes('href="active-proof-passport.html"'),"Active homepage has no source-bound claim ledger");
assert.ok(research.includes('href="active-proof-passport.html"'),"Research library lacks active registry handoff");
assert.ok(site.includes('"active-proof-passport.html"'),"Breadcrumb lifecycle classification missing");
assert.ok(read("docs/sitemap.xml").includes("/active-proof-passport.html"),"Sitemap missing active ledger");
// Preserve the frozen historical registry's exact 11-record purpose.
const historical=read("docs/research-registry.js");
assert.ok(historical.includes('"nightfall-proof-passports-v1"'));
assert.ok(!historical.includes('"q2-influence"'),"Active claims must not be inserted into historical frozen registry");
assert.equal((moon.match(/class="moon-evidence-grid"/g)||[]).length,5,"Five archive objects need the same four evidence fields");
for(const name of ["Result","Evidence","Significance","Limits"])
 assert.equal((moon.match(new RegExp("<dt>"+name+"</dt>","g"))||[]).length,5,"Archive label absent: "+name);
// Prove the educational figure's numerical summary from the actual 16-cell source, not from a handwaved drawing.
const raw=core.match(/const FIXTURE=Object.freeze\(\[([^\]]+)\]\)/);
assert.ok(raw,"Canonical finite fixture missing");
const a=raw[1].split(",").map(x=>Number(x.trim()));
assert.equal(a.length,16);assert.equal(a.reduce((x,y)=>x+y),64);
const D=8,k=3;
const q=a.reduce((s,x,i)=>s+(i-k>=0?x*(D-a[i-k]):0),0);
assert.equal(q,136);
assert.ok(art.includes(a.join(", ")),"SVG must list exact 16-cell fixture in alt description");
assert.ok(art.includes(`${2*q}/${a.length*D*D}`),"SVG rational exact value drifted");
assert.ok(art.includes("unrelated to the separate published 131072-cell witness"));
assert.ok(!/<script\b|<foreignObject\b/i.test(art),"Svg must remain static and inert");
assert.ok(moon.includes('src="media/overlap-16cell-fixture.svg"'),"Archive diagram not visible");
assert.ok(moon.includes("16-cell educational")&&moon.includes("different 131,072-cell witness"),"Fixture must not masquerade as full research result");
console.log("PASS: 4 manual active claim passports, no historical promotion, 5 provenance-complete archives, exact 16-cell operator fixture");
