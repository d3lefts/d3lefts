"use strict";
const assert=require("node:assert/strict");
const fs=require("node:fs");
const field=fs.readFileSync("docs/index.html","utf8");
const moon=fs.readFileSync("docs/new-moon.html","utf8");
const chrome=fs.readFileSync("docs/site.js","utf8");
const nav=field.match(/<nav class="nav" id="site-nav"[^>]*>([\s\S]*?)<\/nav>/)?.[1]||"";
assert.equal((nav.match(/<a\b/g)||[]).length,3,"Keep the three primary research destinations");
for(const href of ['href="./" aria-current="page"','href="constellation.html"','href="review.html"'])assert.ok(nav.includes(href));
const actions=[...field.matchAll(/<div class="hero-actions"[^>]*>([\s\S]*?)<\/div>/g)]
 .map(m=>[...m[1].matchAll(/<a\b[^>]*href="([^"]+)"/g)].map(x=>x[1]));
assert.deepEqual(actions,[["observability.html","product-space-influence.html"]],
 "NULL FIELD first screen must lead to active observability and influence");
assert.ok(moon.includes('href="evidence.html#public-downloads"')&&moon.includes('href="review.html#erdos"'),
 "NEW MOON must expose public frozen evidence and independent Erdős audit");
assert.ok(field.indexOf('id="nf-scroll-cinema"')<field.indexOf('id="flagships"'),"Research cinema before proof catalogue");
for(const claim of ["DEGREE TWO","Product-space certificate engine","The cubic frontier","A bound is not a proof"])
 assert.ok(field.includes(claim),"Active research boundary lost: "+claim);
for(const claim of ["0.380856370118","17 / 30","131,072","global optimality","INTERNAL REPLAY"])
 assert.ok(moon.includes(claim),"Archived finite evidence lost: "+claim);
for(const path of ["erdos-paper.html","living-paper.html","passport.html?claim=sidon30",
                   "evidence.html#public-downloads","research.html"])
 assert.ok(moon.includes(path),"Archive source route lost: "+path);
assert.ok(moon.includes('id="sidon-toggle"')&&moon.includes('disabled title='),"Archived no-JS Sidon checker stays safe");
assert.equal((field.match(/class="flagship-card /g)||[]).length,4,"Four current programs retain status summaries");
assert.ok((field.match(/<section\b/g)||[]).length<=13,"Active home remains selective");
assert.ok((field.match(/<a\b/g)||[]).length<=45,"Active home link budget");
assert.ok(!field.includes("nf-section-index")&&!field.includes("nf-home-toolbox"),"No duplicate navigation");
for(const id of ["flagships","featured-title","nf-scroll-cinema","observatory","review","work","research-systems"])
 assert.ok(field.includes('id="'+id+'"'),"Missing active anchor "+id);
assert.ok(moon.includes('id="live-case"')&&moon.includes('id="archived-records"'));
assert.ok(!field.includes('src="home-system.js"'),"Do not hydrate active cards using historical registry data");
assert.ok(chrome.includes('["index.html","new-moon.html","constellation.html","review.html"].includes(page)'),"No duplicate home rails");
console.log("PASS: active NULL FIELD and historical NEW MOON with distinct proof and witness paths");
