"use strict";
/* An offline gate for the three destination public research experience. */
const assert=require("node:assert/strict");
const fs=require("node:fs");
const read=path=>fs.readFileSync(path,"utf8");
for(const [file,current] of [
 ["docs/index.html","./"],
 ["docs/constellation.html","constellation.html"],
 ["docs/review.html","review.html"]
]){
 const html=read(file);
 const nav=html.match(/<nav\b[^>]*id="site-nav"[^>]*>([\s\S]*?)<\/nav>/);
 assert.ok(nav,"Primary navigation missing: "+file);
 const links=[...nav[1].matchAll(/<a\b([^>]*)>([\s\S]*?)<\/a>/g)];
 assert.equal(links.length,3,"Require exactly three primary destinations in "+file);
 const hrefs=links.map(x=>x[1].match(/href="([^"]+)"/)?.[1]);
 assert.deepEqual(hrefs,["./","constellation.html","review.html"]);
 const active=links.filter(x=>x[1].includes('aria-current="page"'));
 assert.equal(active.length,1,"Require one current destination in "+file);
 assert.equal(active[0][1].match(/href="([^"]+)"/)?.[1],current);
}
const home=read("docs/index.html");
for(const href of ["#flagships","constellation.html#map","review.html#priority"]){
 assert.ok(home.includes('class="nf-archive-accession" href="'+href+'"'),"Golden Hour misses "+href);
 assert.ok(home.includes('class="nf-process-case" href="'+href+'"'),"New Moon misses "+href);
}
const graph=read("docs/constellation.js");
assert.ok(graph.includes("Challenge this claim / Independent Review"));
for(const match of ['selected==="erdos36"?"#erdos"','selected==="sidon30"?"#sidon"','selected==="pas"?"#pas"']){
 assert.ok(graph.includes(match),"Missing claim-to-dossier review route "+match);
}
const review=read("docs/review.html");
assert.ok(review.includes('href="#priority">Choose a falsifiable claim'));
assert.ok(review.includes('https://github.com/d3lefts/d3lefts/issues/new/choose'));
assert.ok(review.includes('two curated v2 evidence ZIPs are public'));
assert.ok(!review.includes('complete certificate ZIP still needs a public binary mirror'));
const shared=read("docs/site.js");
for(const destination of ["01 / Homepage · Results","02 / Constellation · Connections","03 / Independent Review · Challenge"]){
 assert.ok(shared.includes(destination),"Missing shared destination "+destination);
}
assert.ok(shared.includes('aria-current","page"'));
assert.ok(!shared.includes('05 / Review'));
console.log("PASS: all three destinations and claim-specific review handoffs");
