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
assert.equal(original.mechanisms.length,base.mechanisms.length,"canonical mechanisms must be projected");
assert(original.mechanisms.some(m=>m.id==="symmetry-reduction" && m.kind==="analogy"),
  "Untested symmetry analogy must retain its status");
assert(original.mechanisms.some(m=>m.id==="dependency-gates" &&
  m.connections.some(e=>e.relation==="open-premise" && e.claimId==="werner")),
  "Werner premise cannot silently be promoted into a verified transfer");
assert(original.mechanisms.every(m=>m.connections.every(e=>
  ["finite-check","method","open-premise","analogy"].includes(e.relation))),
  "Graph edges must retain their authored evidence type");
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
newer.mechanisms.push({
  id:"novel-mechanism",title:"Source-bound experiment transfer",kind:"analogy",
  description:"Candidate only",scope:"No same-model transfer established."
});
newer.edges.push({
  from:"novel-test-portfolio",to:"novel-mechanism",relation:"analogy",
  label:"Unreviewed similarity",note:"An analogy, not a proof",
  source:"https://github.com/d3lefts/d3lefts/issues/1"
});
const withEdge=core.project(newer);
assert(withEdge.mechanisms.some(m=>m.id==="novel-mechanism" &&
  m.connections.some(e=>e.claimId==="novel-test-portfolio" && e.relation==="analogy")));
newer.edges.push({from:"unknown-claim",to:"novel-mechanism",relation:"finite-check"});
assert.equal(core.project(newer).mechanisms.find(m=>m.id==="novel-mechanism").connections.length,1,
  "Unknown claims must not be linked to canonical mechanisms");
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
assert(page.includes('id="approved-findings"'));
const approvedOnly=page.split('<div class="pf-five-grid">')[1]?.split('</div>\n  <p class="pf-five-boundary">')[0] || "";
assert.equal((approvedOnly.match(/<article>/g)||[]).length,5,
  "Exactly five site-approved scoped findings must appear");
assert(page.includes("SITE_ORIGINALITY_ADDENDUM_20261029.md"));
assert(page.includes('id="pf-mechanism-list"'));
assert(page.includes('id="pf-evaluation-title"'));
assert(page.includes("No graph edge is a new theorem"));
// Career evidence must lead without promoting the AI-agent archive to staffed employment.
const careerPos=page.indexOf('id="career"'), sciencePos=page.indexOf('id="work"');
assert(careerPos>0 && sciencePos>careerPos,"Career experience must precede the technical archive");
assert.equal((page.match(/class="pf-career-card"/g)||[]).length,3);
for(const key of ["id=\"walmart\"","id=\"autograph\"","id=\"amazon\"",
  "id=\"foundations\"","resume.html","linkedin.com/in/devin-jarel-wright",
  "2015 General Donald R. Keith","AI assistants","not a staffed laboratory"]){
 assert(page.includes(key),"Career evidence missing: "+key);
}
assert(page.includes("released after my tenure"),"Amazon release dates require a plain boundary");
const resume=read("docs/resume.html");
assert(resume.includes('name="robots" content="noindex, nofollow, noarchive"'));
assert(resume.includes("Walmart Global Tech") && resume.includes("HPM Building Supply"));
assert(resume.includes("2015") && resume.includes("NIGHTFALL"));
assert(!read("docs/index.html").includes("resume.html"));
assert(!read("docs/sitemap.xml").includes("resume.html"));
const about=read("docs/about.html");
assert(about.includes("AI workflows") || about.includes("AI-assistant role labels"));
assert(about.includes("not human staff members"));
console.log("Portfolio: approved scoped findings, source-linked mechanism transfers, updates, demotions and unlisted boundaries pass.");
