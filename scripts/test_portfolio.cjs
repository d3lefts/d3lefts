"use strict";
const fs=require("node:fs");
const path=require("node:path");
const vm=require("node:vm");
const assert=require("node:assert/strict");
const ROOT=path.resolve(__dirname,"..");
const read=p=>fs.readFileSync(path.join(ROOT,p),"utf8");
const core=require("../docs/portfolio-core.js");
const sandbox={};
sandbox.window=sandbox;
vm.runInNewContext(read("docs/research-registry.js"),sandbox,{filename:"research-registry.js"});
const base=JSON.parse(JSON.stringify(sandbox.NightfallRegistry));
const original=core.project(base);
assert.equal(original.ok,true);
assert.equal(original.trackedCount,base.claims.length);
assert(original.trackedCount>=6);
assert(original.claims.some(c=>c.id==="erdos36" && c.publicFinite));
assert(original.claims.some(c=>c.id==="phase" && !c.publicFinite));
assert(original.changes.length>0);
assert(original.claims.every(c=>c.validityLabel && c.reproducibilityLabel));
assert(original.claims.every(c=>c.sources.every(s=>core.safeUrl(s.url)===s.url)));

// A new site-registered claim must appear automatically without editing portfolio.
const newer=JSON.parse(JSON.stringify(base));
newer.claims.push({
  id:"novel-test-portfolio",title:"Prospective discovery, scoped",
  kind:"Numerical candidate",field:"Algorithms",short:"Unreviewed example",
  validity:{level:"working",label:"Unreviewed numerical candidate"},
  reproducibility:{level:"partial",label:"Limited replay"},
  originality:{label:"Prior art open"},significance:{label:"Not established"},
  sources:[{label:"unsafe",url:"javascript:alert(1)"},
    {label:"source",url:"https://github.com/d3lefts/d3lefts/issues/1"}],
  open:["Adversarial external audit required"],
  history:[{date:"2026-10-30",kind:"candidate",label:"Recorded candidate"}]
});
let after=core.project(newer);
assert.equal(after.ok,true);
assert.equal(after.trackedCount,original.trackedCount+1);
assert.equal(after.claims[0].id,"novel-test-portfolio");
assert.equal(after.claims[0].publicFinite,false);
assert.equal(after.claims[0].sources.length,1);
assert.equal(after.changes[0].date,"2026-10-30");
// Status changes follow the registry, never preserve a stale elevated status.
newer.claims[newer.claims.length-1].validity={level:"finite",label:"Exact finite replay"};
newer.claims[newer.claims.length-1].reproducibility={level:"public",label:"Public reproducibility"};
assert.equal(core.project(newer).claims[0].publicFinite,true);
newer.claims[newer.claims.length-1].validity={level:"working",label:"Demoted after contradiction"};
assert.equal(core.project(newer).claims[0].publicFinite,false);
assert.equal(core.project(newer).claims[0].validityLabel,"Demoted after contradiction");
newer.claims.push({...newer.claims[newer.claims.length-1]});
assert.equal(core.project(newer).ok,false,"duplicate IDs fail closed");
assert.equal(core.project({schema:"unknown",claims:[]}).ok,false);
for(const u of ["javascript:alert(1)","data:text/html,hi","//external.example","../secrets.html"])
  assert.equal(core.safeUrl(u),"",u);

const page=read("docs/portfolio.html");
assert(page.includes('name="robots" content="noindex, nofollow, noarchive"'));
assert(page.includes('src="research-registry.js"'));
assert(page.includes('src="portfolio-core.js"'));
assert(page.includes('src="portfolio.js"'));
for(const id of ["pf-live-records","pf-live-events","pf-live-summary"])assert(page.includes('id="'+id+'"'));
for(const file of ["docs/index.html","docs/about.html","docs/sitemap.xml","README.md"]){
  assert(!read(file).includes("portfolio.html"),file+" must not expose a public-facing link");
}
assert(!read("docs/sitemap.xml").includes("/portfolio"));
console.log("Unlisted portfolio: canonical-registry tracking, append, demotion, unsafe-source, and discovery exclusions pass.");
