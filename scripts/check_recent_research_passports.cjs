"use strict";
const fs=require("node:fs");const path=require("node:path");const assert=require("node:assert/strict");
const root=path.resolve(__dirname,".."),read=p=>fs.readFileSync(path.join(root,p),"utf8");const d=JSON.parse(read("docs/recent-research.json"));
assert.equal(d.schema,"nightfall.recent-research-passports.v1");assert.equal(d.as_of,"2026-11-19");assert.ok(d.frozen_legacy_registry_unchanged);
const tiers=new Set(["merged-lean","branch-lean","analytic","pending"]);const ids=new Set();
assert.ok(d.claims.length>=12);for(const c of d.claims){assert.ok(!ids.has(c.id),"duplicate "+c.id);ids.add(c.id);assert.ok(tiers.has(c.tier));
for(const k of ["title","claim","scope","mechanism","certificate","limit","credit","next","source","passport","status_label"]){assert.ok(typeof c[k]==="string"&&c[k].length>12,c.id+" / "+k);}
assert.match(c.source,/^https:\/\/github.com\/d3lefts\/d3lefts\/pull\/\d+$/);if(c.tier==="merged-lean"||c.tier==="branch-lean"){assert.ok(c.declaration&&c.run&&c.receipt,c.id+" missing pinned named receipt");}if(c.tier==="pending"||c.tier==="analytic")assert.ok(!c.run,c.id+" unverified claim promoted");
const p="research/nightfall/2026-11-recent-passports/"+c.id+".md";const m=read(p);assert.ok(m.includes(c.claim)&&m.includes(c.limit)&&m.includes(c.source),c.id+" passport drift");}
const page=read("docs/recent-research.html"),js=read("docs/recent-research.js");assert.ok(page.includes("recent-research.json")&&page.includes("recent-research.js"));
assert.ok(!js.includes(".innerHTML"));new (require("node:vm").Script)(js,{filename:"recent-research.js"});
for(const p of ["docs/index.html","docs/theory.html","docs/active-proof-passport.html","docs/sitemap.xml"])assert.ok(read(p).includes("recent-research.html"),p+" missing recent ledger link");
console.log("PASS "+d.claims.length+" source-scoped passports, evidence tiers, links and page renderer");
