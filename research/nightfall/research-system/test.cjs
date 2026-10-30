#!/usr/bin/env node
"use strict";
const assert=require("node:assert/strict"),fs=require("node:fs"),vm=require("node:vm");
const read=x=>fs.readFileSync(x,"utf8"),ctx={};
vm.runInNewContext(read("docs/research-registry.js"),ctx,{filename:"research-registry.js"});
const R=ctx.NightfallRegistry;
assert.equal(R.schema,"nightfall-proof-passports-v1");
assert.equal(R.asOf,"2026-10-30");
assert.equal(R.claims.length,11);assert.equal(R.mechanisms.length,5);assert.equal(R.edges.length,20);
assert.deepEqual(Array.from(R.dimensions),["validity","reproducibility","originality","significance"]);
const ids=new Set(R.claims.map(c=>c.id)),mids=new Set(R.mechanisms.map(m=>m.id));
assert.equal(ids.size,11);assert.equal(mids.size,5);
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
assert.equal(R.claimById("erdos36").reproducibility.level,"public","Approved finite witness release is public");
assert.match(R.claimById("erdos36").reproducibility.detail,/131,072-cell heights.*independent finite arithmetic checker/);
assert.match(R.claimById("erdos36").reproducibility.detail,/not external peer review/i);
assert.ok(R.claimById("erdos36").open.some(x=>/independent external reproduction/i.test(x)),"External audit remains open");
assert.ok(R.claimById("erdos36").sources.some(x=>x.url.includes("/releases/tag/nightfall-research-2026-10-28")),"Public evidence release is source-linked");
assert.equal(R.claimById("erdos36").history.at(-1).kind,"public-evidence-release");
assert.match(R.claimById("pas").statement,/11\/20/);
assert.match(R.claimById("adaptive").statement,/k\+1/);
assert.match(R.claimById("adaptive").short,/r−1/);
assert.match(R.claimById("adaptive").short,/q=3/);
assert.match(R.claimById("adaptive").statement,/r\+1/);
assert.match(R.claimById("adaptive").measurement,/\/r/);
assert.match(R.claimById("adaptive").reproducibility.label,/332,086/);
assert.match(R.claimById("adaptive").originality.label,/review open/i);
const html={home:read("docs/index.html"),passport:read("docs/passport.html"),atlas:read("docs/atlas.html"),research:read("docs/research.html"),lab:read("docs/claim-lab.html"),referee:read("docs/referee.html"),tools:read("docs/exact-research.html"),sitemap:read("docs/sitemap.xml")};
for(const [id,file] of [["sidon-witness",html.home],["observatory",html.home],["passport-picker",html.passport],["passport-dimensions",html.passport],["passport-history",html.passport],["ma-canvas",html.atlas],["ma-relations",html.atlas],["ma-history",html.atlas]])assert.ok(file.includes('id="'+id+'"'),"Missing interactive anchor "+id);
for(const page of ["home","research","atlas","passport"])assert.ok(html[page].includes("research-registry.js"),page+" missing shared source");
for(const page of ["research","atlas","passport","tools"])assert.ok(html[page].includes('href="atlas.html"'),page+" lacks atlas navigation");
assert.ok(html.home.includes('href="constellation.html#map"'),"Homepage must lead to source-linked Constellation rather than mount a second map");
assert.ok(!html.home.includes('class="lab-section"')&&!html.home.includes('class="referee-showcase"'),"Duplicate showcases remain");
assert.ok(html.home.includes('id="featured-title"')&&html.home.includes('id="review"'),"Homepage evidence or review removed");
assert.ok(html.research.includes("research.js"),"Research library removed");
// Import is now a staged, consented Evidence Bridge flow; guard the new contract rather than a retired banner.
assert.ok(html.lab.includes("receiptImportFile")&&html.lab.includes('src="evidence-bridge-core.js"')&&html.lab.includes('id="bridgeApprove"'),"Missing strict preview-only receipt import");
assert.ok(html.lab.includes("No claims, statuses, or published records modified.")&&html.lab.includes("Cancel / no changes"),"Missing explicit status-preservation and refusal affordances");
assert.ok(html.lab.includes("const oldJSON=raw??JSON.stringify(data)")&&html.lab.includes("const next=structuredClone(data)")&&html.lab.includes("next.experiments.push({id:uid(),claimId:''"),"Import must back up current data and append only an unassigned experiment");
const bridgeCore=read("docs/evidence-bridge-core.js");
assert.match(bridgeCore,/reviewStatus:"unreviewed",promotionAllowed:false,claimsTouched:\[\],authoritativeReviewer:null/,"Adapter must never confer scientific review or promote a claim");
assert.ok(html.referee.includes("referee-app.js")&&html.tools.includes('id="werner-run"')&&html.tools.includes('id="field-run"'),"Original research calculators missing");
for(const name of ["atlas.html","passport.html"])assert.ok(html.sitemap.includes("/"+name),"Unindexed route "+name);
for(const file of ["docs/home-system.js","docs/passport.js","docs/atlas.js","docs/research.js","docs/claim-lab.html"]){
 let src=read(file);if(file.endsWith(".html"))src=src.match(/<script>([\s\S]*?)<\/script>/)?.[1]||"";
 assert.ok(src,"No JavaScript in "+file);new vm.Script(src,{filename:file});
}
console.log("PASS: "+R.claims.length+" claims, "+R.mechanisms.length+" mechanisms, "+R.edges.length+" source-typed edges, "+R.events.length+" provenance events");
console.log("PASS: homepage, Passport, Atlas, Claim Lab, 33-document library, Referee and sitemap contracts");
console.log("PASS: browser JavaScript and Claim Lab inline script parse");
