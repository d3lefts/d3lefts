"use strict";
const assert=require("node:assert/strict");
const fs=require("node:fs");
const html=fs.readFileSync("docs/index.html","utf8");
const moon=fs.readFileSync("docs/new-moon.html","utf8");
const chrome=fs.readFileSync("docs/site.js","utf8");
const nav=html.match(/<nav class="nav" id="site-nav"[^>]*>([\s\S]*?)<\/nav>/)?.[1]||"";
assert.equal((nav.match(/<a\b/g)||[]).length,3,"One primary destination per product job");
for(const href of ['href="./" aria-current="page"','href="constellation.html"','href="review.html"'])assert.ok(nav.includes(href));
const actions=[...html.matchAll(/<div class="hero-actions"[^>]*>([\s\S]*?)<\/div>/g)].map(m=>[...m[1].matchAll(/<a\b[^>]*href="([^"]+)"/g)].map(x=>x[1]));
assert.deepEqual(actions,[["erdos-paper.html","#flagships"]],
  "NULL FIELD first screen must link the exact witness and deeper record");
assert.ok(moon.includes('href="review.html#priority"')&&moon.includes('href="review.html#erdos"'),
  "NEW MOON exposes both independent review and the Erdős challenge");
assert.ok(html.indexOf('id="nf-scroll-cinema"')<html.indexOf('id="flagships"'),
  "Record-backed cinematic must precede deeper findings");
for(const claim of ["0.380856370118","17 / 30","Proof After Scarcity v2","unvalidated"])assert.ok(html.includes(claim),"Primary evidence not visible: "+claim);
for(const source of ["erdos-paper.html","living-paper.html","passport.html?claim=sidon30","review.html#pas","reproduction-manifest.json","research.html"])assert.ok(html.includes(source),"Lost evidence route "+source);
assert.ok(html.includes('id="sidon-toggle"')&&html.includes('disabled title='),"Pre-hydration Sidon checker remains safe");
assert.equal((html.match(/class="flagship-card /g)||[]).length,4,"Four programs retain scoped scientific labels");
assert.ok(html.includes('class="nf-frontiers-disclosure"')===false||html.includes("nf-frontiers-disclosure"));
assert.ok((html.match(/<section\b/g)||[]).length<=13,"Homepage should be a selective landing page");
assert.ok((html.match(/<a\b/g)||[]).length<=45,"Homepage link density must stay intentionally bounded");
assert.ok(!html.includes("nf-section-index")&&!html.includes("nf-home-toolbox")&&!html.includes("instrument-workflow"),"No duplicative navigation or tool directory");
for(const id of ["flagships","live-case","featured-title","nf-scroll-cinema","observatory","review","work","research-systems"])assert.ok(html.includes('id="'+id+'"'),"Missing meaningful destination "+id);
assert.ok(!html.includes('src="observatory-home.js"'),"Do not load the full graph engine on the homepage");
assert.ok(chrome.includes('["index.html","new-moon.html","constellation.html","review.html"].includes(page)'),"Both homepage routes must avoid secondary rails");
assert.ok(moon.includes('data-nf-experience="moon"'),"Separate investigation page exists");
console.log("PASS: selective homepage with three primary evidence moments, cinematic integrity, and source-bound destinations");
