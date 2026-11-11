"use strict";
const assert=require("node:assert/strict"),fs=require("node:fs");
const p=fs.readFileSync("docs/mathematical-results.html","utf8");
const src=fs.readFileSync("research/nightfall/observability-publication/SOURCE_ACCESS.md","utf8");
const home=fs.readFileSync("docs/index.html","utf8");
const moon=fs.readFileSync("docs/new-moon.html","utf8");
const rev=fs.readFileSync("docs/review.html","utf8");
for(const id of ["quadratic","observation","finite-transfer","comparison","sources","finite","open"])
 assert.ok(p.includes('id="'+id+'"'),"Missing mathematical route "+id);
assert.ok(p.includes("225(1+√3)")&&p.includes("Θ(rm/η)"),"Current quadratic coefficient or query scope drift");
assert.ok(p.includes("v6 LaTeX source")||p.includes("v6 manuscript source"),"Full public v6 source status missing");
for(const s of ["Turturean","Aaronson","Efron","external","not a full proof","not an exhaustive"])
 assert.ok(p.toLowerCase().includes(s.toLowerCase()),"Claim-status boundary missing: "+s);
assert.ok(src.includes("53-line editorial synopsis")&&src.includes("Not checked in here"),"Missing proof-access inventory");
assert.ok(home.includes('href="mathematical-results.html"')&&rev.includes('id="theorem-audit"'));
assert.ok(moon.includes("Archived research")&&!moon.includes("Archived breakthroughs"));
assert.ok(fs.readFileSync("docs/sitemap.xml","utf8").includes("mathematical-results.html"));
console.log("PASS: theorem-first page, honest proof access, prior art and independent referee gates");
