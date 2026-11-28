"use strict";
const assert=require("node:assert/strict");
const fs=require("node:fs");
const field=fs.readFileSync("docs/index.html","utf8");
const moon=fs.readFileSync("docs/new-moon.html","utf8");
const chrome=fs.readFileSync("docs/site.js","utf8");
const nav=field.match(/<nav class="nav" id="site-nav"[^>]*>([\s\S]*?)<\/nav>/)?.[1]||"";
assert.equal((nav.match(/<a\b/g)||[]).length,4,"Keep the three primary research destinations plus Publications");
for(const href of ['href="./" aria-current="page"','href="constellation.html"','href="publications.html"','href="review.html"'])assert.ok(nav.includes(href));
const actions=[...field.matchAll(/<div class="hero-actions"[^>]*>([\s\S]*?)<\/div>/g)]
 .map(m=>[...m[1].matchAll(/<a\b[^>]*href="([^"]+)"/g)].map(x=>x[1]));
assert.deepEqual(actions,[["#first-minute","#flagships"]],
 "NIGHTFALL first screen must offer a one-minute evidence orientation and a direct flagship research route");
assert.ok(field.includes('id="first-minute"')&&field.indexOf('id="first-minute"')<field.indexOf('id="nightfall-story"'),"Evidence guide must precede the full research story");
assert.ok(field.includes('href="mathematical-results.html"'),"Specialist mathematical research entry point missing");
assert.ok(moon.includes('href="evidence.html#public-downloads"')&&moon.includes('href="review.html#erdos"'),
 "NEW MOON must expose public frozen evidence and independent Erdős audit");
assert.ok(field.indexOf('id="nf-scroll-cinema"')<field.indexOf('id="flagships"'),"Research cinema before proof catalogue");
for(const claim of ["LEAN-CERTIFIED DEGREE-TWO THEOREM","Product-space certificate engine","The cubic frontier","A bound is not a proof"])
 assert.ok(field.includes(claim),"Active research boundary lost: "+claim);
for(const claim of ["0.380856370118","17 / 30","131,072","global optimality","INTERNAL REPLAY"])
 assert.ok(moon.includes(claim),"Archived finite evidence lost: "+claim);
for(const path of ["erdos-paper.html","living-paper.html","passport.html?claim=sidon30",
                   "evidence.html#public-downloads","research.html"])
 assert.ok(moon.includes(path),"Archive source route lost: "+path);
assert.ok(moon.includes('id="sidon-toggle"')&&moon.includes('disabled title='),"Archived no-JS Sidon checker stays safe");
assert.ok((field.match(/class="flagship-card /g)||[]).length>0,"Current programs retain status summaries");
assert.ok((field.match(/<section\b/g)||[]).length<=14,"Active home remains selective (including scholarly archive)");
assert.ok((field.match(/<a\b/g)||[]).length<=57,"Active home link budget (includes publications and explicit Q2 receipts)");
assert.ok(!field.includes("nf-section-index")&&!field.includes("nf-home-toolbox"),"No duplicate navigation");
for(const id of ["flagships","featured-title","nf-scroll-cinema","observatory","review","work","research-systems"])
 assert.ok(field.includes('id="'+id+'"'),"Missing active anchor "+id);
assert.ok(moon.includes('id="live-case"')&&moon.includes('id="archived-records"'));
assert.ok(!field.includes('src="home-system.js"'),"Do not hydrate active cards using historical registry data");
assert.ok(chrome.includes('["index.html","new-moon.html","constellation.html","review.html"].includes(page)'),"No duplicate home rails");
const heroLink=field.match(/<a\b[^>]*href="([^"]+)"[^>]*class="nf-hero-jump"/)?.[1];
assert.ok(heroLink,"A direct evidence link must precede the long hero copy");
const publications=JSON.parse(fs.readFileSync("papers/publications.json","utf8"));
assert.ok(publications.records.some(r=>heroLink==="https://doi.org/"+r.doi)||/^(recent-research|research-dispatch-\d{8}|active-proof-passport)\.html(?:#[-\w]+)?$/.test(heroLink),"Hero must lead to a registered publication or current evidence page");
assert.ok(field.includes("LEAN-CERTIFIED DEGREE-TWO THEOREM")&&field.includes("independent external review remain open"),"Displayed theorem must identify proof scope and review boundary");
console.log("PASS: active NULL FIELD and historical NEW MOON with current theorem passport first");
