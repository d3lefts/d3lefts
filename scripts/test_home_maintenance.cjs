"use strict";
// Static homepage asset-maintenance contract. Browser tests remain the visual
// and behavioral authority; this guard stops retired code returning unnoticed.
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const read=f=>fs.readFileSync(f,"utf8");
const html=read("docs/index.html");
const css=read("docs/home-rhythm.css");
const home=read("docs/home-system.js");
const styles=[...html.matchAll(/<link\s+rel="stylesheet"\s+href="([^"]+)"/g)].map(x=>x[1]);
const scripts=[...html.matchAll(/<script\s+src="([^"]+)"\s+defer><\/script>/g)].map(x=>x[1]);
assert.equal(styles.length,7,"Homepage should need seven route-scoped stylesheets, not the retired eighth");
assert.equal(scripts.length,7,"Canonical registry and both scroll controllers must remain on the page");
assert.equal(new Set(styles).size,styles.length,"Duplicate stylesheet requests");
assert.equal(new Set(scripts).size,scripts.length,"Duplicate script requests");
for(const asset of [...styles,...scripts]){
  assert.ok(!asset.includes("/")&&!asset.includes(".."),"Asset path must be a local docs file");
  assert.ok(fs.existsSync(path.join("docs",asset)),"Missing local dependency "+asset);
}
assert.ok(!styles.includes("home-focus.css"),"Retired homepage focus stylesheet must stay retired");
assert.ok(!fs.existsSync("docs/home-focus.css"),"Deleted homepage stylesheet was reintroduced");
for(const selector of [".nf-hero-guide",".nf-case-more",".nf-case-more-links",".nf-focus-result-grid",".nf-secondary-frontiers-grid"]){
  assert.ok(css.includes(selector),"Active homepage style was lost: "+selector);
}
for(const retired of [".nf-home-toolbox",".nf-section-index",".nf-audits-disclosure",".nf-findings-disclosure",".nf-provenance-disclosure",".instrument-bridge"]){
  assert.ok(!css.includes(retired),"Dead homepage-specific stylesheet rule returned: "+retired);
}
for(const removed of ['.feature-grid > a',"home-evidence-history"]){
  assert.ok(!home.includes(removed),"Dead homepage hydration returned: "+removed);
}
for(const live of ["SIDON_WITNESS","SIDON_SUBSET","aria-pressed","NightfallRegistry","erdos36","phase","werner","adaptive"]){
  assert.ok(home.includes(live),"Canonical exact source hydration lost: "+live);
}
for(const id of ["flagships","live-case","nf-scroll-cinema","observatory","review","work"]){
  assert.ok(html.includes('id="'+id+'"'),"Homepage journey anchor lost: "+id);
}
assert.ok(css.length<=7500&&home.length<=3000,"Homepage-only CSS/JS debt exceeded the documented budget");
const total=styles.map(f=>fs.statSync(path.join("docs",f)).size).reduce((a,b)=>a+b,0);
console.log("PASS homepage maintenance: "+styles.length+" CSS, "+scripts.length+" JS; "+total+" stylesheet bytes (uncompressed), "+css.length+" active rhythm CSS bytes, "+home.length+" source-hydration JS bytes");
