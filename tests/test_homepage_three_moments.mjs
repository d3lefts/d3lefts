// Research lifecycle contract: NULL FIELD is active; NEW MOON preserves historical results.
import {readFileSync} from "node:fs";
import assert from "node:assert/strict";
import test from "node:test";
const field=readFileSync("docs/index.html","utf8");
const moon=readFileSync("docs/new-moon.html","utf8");
const styles=readFileSync("docs/home-rhythm.css","utf8");
const count=(s,re)=>(s.match(re)||[]).length;

test("NULL FIELD leads with current product-space research, not an Erdős archival headline",()=>{
 const stages=['<section class="hero wrap nf-opening"','<section class="nf-cinema',
               '<section class="section wrap flagships"','id="featured-title"',
               'id="new-discoveries"','id="observatory"','id="review"','id="work"']
               .map(t=>field.indexOf(t));
 assert.ok(stages.every((v,i)=>v>=0&&(i===0||v>stages[i-1])),String(stages));
 assert.ok(field.includes("ACTIVE RESEARCH")&&field.includes("Wright"));
 assert.ok(field.includes('id="hero-title-archive">Low interaction.<br><em>Detectable influence.</em>'));
 assert.ok(field.includes("observability.html")&&field.includes("product-space-influence.html")&&field.includes("active-proof-passport.html"));
 assert.ok(field.includes("CUBIC_OBSTRUCTION_NOTE.md"));
 assert.ok(!field.includes('id="live-case"'),"Finite Sidon exhibit belongs to NEW MOON");
 assert.ok(!field.includes("ERDŐS #36 / FEATURED FINITE WITNESS"));
 assert.equal(count(field,/<article class="flagship-card /g),4,"Four separately scoped active program views");
 assert.equal(count(field,/class="nf-claim-passport"/g),4,"Each active program has a claim-status ledger");
});
test("NEW MOON archives exact finite witnesses and preserves original proof boundaries",()=>{
 assert.ok(moon.includes('id="moon-title">What survives<br><em>becomes the record.</em>'));
 for(const id of ["archived-records","live-case","sidon-witness","first-test","workbench"])
  assert.ok(moon.includes('id="'+id+'"'),id);
 for(const value of ["0.380856370118","131,072","17 / 30","global optimality",
                     "separate","INTERNAL REPLAY","Erdős","Sidon","PAS"])
  assert.ok(moon.toLowerCase().includes(value.toLowerCase()),"Archive lost scoped evidence: "+value);
 const widget=moon.match(/<div class="sf-witness"[^>]*>([\s\S]*?)<\/div>/)?.[1];
 assert.ok(widget,"No-JS archived Sidon witness missing");
 assert.equal(count(widget,/class="sf-point(?: chosen)?"/g),30,"All 30 integer positions are visible");
 assert.equal(count(widget,/class="sf-point chosen"/g),17,"17 chosen Sidon points remain");
 assert.ok(moon.includes("verify_sidon30_standalone.py"));
 assert.ok(moon.includes("overlap-16cell-fixture.svg"));
 assert.equal(count(moon,/class="moon-evidence-grid"/g),5,"All archived records have result, evidence, significance and limits");
 assert.ok(!moon.includes('CASE 005 / NOVEMBER 2026'),"Current Wright frontier is not an archival result");
});
test("Cross-entrance navigation is explicit and in both directions",()=>{
 for(const page of [field,moon]){
  assert.ok(page.includes('data-nf-route="archive"'));
  assert.ok(page.includes('data-nf-route="moon"'));
  assert.ok(page.includes('NULL FIELD <small>Active research</small>'));
  assert.ok(page.includes('NEW MOON <small>Archived research</small>'));
  const ids=new Set([...page.matchAll(/\bid="([^"]+)"/g)].map(m=>m[1]));
  for(const m of page.matchAll(/href="#([a-z0-9_-]+)"/gi))
   assert.ok(ids.has(m[1]),"Broken within-page anchor #"+m[1]);
 }
 assert.ok(field.includes('href="new-moon.html#archived-records"'));
 assert.ok(moon.includes('href="index.html"'));
 assert.equal(count(field,/<a\b/g)<=45,true,"Active homepage link budget");
 assert.ok(count(field,/<section\b/g)<=13,"Active homepage section budget");
 assert.ok(count(field,/<details\b/g)<=2,"Avoid nested disclosures");
});
test("Both entrances retain accessible still artwork and scoped evidence links",()=>{
 assert.ok(field.includes('id="nf-scroll-cinema"'));
 assert.ok(field.indexOf('id="nf-scroll-cinema"')<field.indexOf('id="flagships"'));
 assert.ok(field.includes('href="home-rhythm.css"'));
 assert.ok(field.includes('href="home-dual-experience.css"'));
 assert.ok(moon.includes('class="moon-end wrap"'));
 assert.ok(field.includes('href="evidence.html#public-downloads"'));
 assert.ok(field.includes('href="constellation.html#map"'));
 assert.ok(moon.includes('href="evidence.html#public-downloads"'));
 for(const q of [".nf-focus-result-grid",".nf-secondary-frontiers-grid",
                 ".nf-deep-disclosure > summary:focus-visible",
                 "@media (max-width:820px)","@media (max-width:620px)",
                 "@media (prefers-reduced-motion:reduce)"])
  assert.ok(styles.includes(q),q);
});
test("Archival designation is not a certification or novelty promotion",()=>{
 assert.ok(field.toLowerCase().includes("external review")&&field.includes("unproved"));
 assert.ok(moon.includes("Archived means preserved for inspection"));
 assert.ok(moon.includes("not a global")||moon.includes("Global optimality"));
 assert.ok(moon.includes("EXTERNAL REVIEW OPEN"));
 assert.ok(moon.includes("IMPORTED THEOREM DEPENDENCIES"));
 assert.ok(field.includes("no edge certifies a transfer theorem"));
});
