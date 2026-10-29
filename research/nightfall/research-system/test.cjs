#!/usr/bin/env node
"use strict";
const assert=require("node:assert/strict"),fs=require("node:fs"),vm=require("node:vm");
const read=x=>fs.readFileSync(x,"utf8"),ctx={};
vm.runInNewContext(read("docs/research-registry.js"),ctx,{filename:"research-registry.js"});
const R=ctx.NightfallRegistry;
assert.equal(R.schema,"nightfall-proof-passports-v1");
assert.equal(R.asOf,"2026-10-28");
assert.equal(R.claims.length,5);assert.equal(R.mechanisms.length,5);assert.equal(R.edges.length,13);
assert.deepEqual(Array.from(R.dimensions),["validity","reproducibility","originality","significance"]);
const ids=new Set(R.claims.map(c=>c.id)),mids=new Set(R.mechanisms.map(m=>m.id));
assert.equal(ids.size,5);assert.equal(mids.size,5);
for(const c of R.claims){
 for(const k of ["id","title","field","kind","statement","conditions","short","measurement","metric"])assert.ok(typeof c[k]==="string"&&c[k].length>(k==="id"||k==="measurement"?1:4),c.id+" missing "+k);
 for(const dimension of R.dimensions)assert.ok(c[dimension]?.label&&c[dimension]?.detail&&c[dimension]?.level,c.id+" bad "+dimension);
 assert.ok(c.sources.length&&c.assumptions.length&&c.open.length,c.id+" missing evidence gate");
 for(const x of c.sources){assert.ok(x.label);assert.match(x.url,/^(https:\/\/|[a-z0-9].*\.html)/)}
 for(const e of c.history){assert.match(e.date,/^2026-\d\d-\d\d$/);assert.ok(e.url&&e.detail&&e.label,c.id+" incomplete history")}
 assert.equal(R.claimById(c.id).title,c.title);
}
for(const m of R.mechanisms){assert.ok(m.scope&&m.description,m.id+" missing scope");assert.ok(m.witnesses.every(id=>ids.has(id)))}
for(const e of R.edges){assert.ok(ids.has(e.from)&&mids.has(e.to),"Dangling graph relation");assert.ok(["finite-check","method","open-premise","analogy"].includes(e.relation),"Unsupported relation");assert.ok(e.source&&e.note&&e.label,"Uncited graph relation");assert.ok(R.mechanismById(e.to).witnesses.includes(e.from),"Unlisted mechanism membership")}
assert.equal(R.claimById("sidon30").measurement,"17 / 30");
assert.match(R.claimById("phase").validity.label,/Conditional/);
assert.match(R.claimById("erdos36").reproducibility.detail,/pending/i);
assert.match(R.claimById("pas").statement,/11\/20/);
const html={home:read("docs/index.html"),passport:read("docs/passport.html"),atlas:read("docs/atlas.html"),research:read("docs/research.html"),lab:read("docs/claim-lab.html"),referee:read("docs/referee.html"),tools:read("docs/exact-research.html"),sitemap:read("docs/sitemap.xml")};
for(const [id,file] of [["sidon-witness",html.home],["home-evidence-history",html.home],["passport-picker",html.passport],["passport-dimensions",html.passport],["passport-history",html.passport],["ma-canvas",html.atlas],["ma-relations",html.atlas],["ma-history",html.atlas]])assert.ok(file.includes('id="'+id+'"'),"Missing interactive anchor "+id);
for(const page of ["home","research","atlas","passport"])assert.ok(html[page].includes("research-registry.js"),page+" missing shared source");
for(const page of ["home","research","atlas","passport","tools"])assert.ok(html[page].includes('href="atlas.html"'),page+" lacks atlas navigation");
assert.ok(!html.home.includes('class="lab-section"')&&!html.home.includes('class="referee-showcase"'),"Duplicate showcases remain");
assert.ok(html.home.includes('id="featured-title"')&&html.home.includes('id="review"'),"Homepage evidence or review removed");
assert.ok(html.research.includes("research.js"),"Research library removed");
assert.ok(html.lab.includes("receiptImportFile")&&html.lab.includes("Claim statuses unchanged"),"No status-preserving receipt import");
assert.ok(html.referee.includes("referee-app.js")&&html.tools.includes('id="werner-run"')&&html.tools.includes('id="field-run"'),"Original research calculators missing");
for(const name of ["atlas.html","passport.html"])assert.ok(html.sitemap.includes("/"+name),"Unindexed route "+name);
for(const file of ["docs/home-system.js","docs/passport.js","docs/atlas.js","docs/research.js","docs/claim-lab.html"]){
 let src=read(file);if(file.endsWith(".html"))src=src.match(/<script>([\s\S]*?)<\/script>/)?.[1]||"";
 assert.ok(src,"No JavaScript in "+file);new vm.Script(src,{filename:file});
}
console.log("PASS: "+R.claims.length+" claims, "+R.mechanisms.length+" mechanisms, "+R.edges.length+" source-typed edges, "+R.events.length+" provenance events");
console.log("PASS: homepage, Passport, Atlas, Claim Lab, 30-document library, Referee and sitemap contracts");
console.log("PASS: browser JavaScript and Claim Lab inline script parse");
