"use strict";
const assert=require("node:assert/strict"),fs=require("node:fs");
const p=fs.readFileSync("docs/mathematical-results.html","utf8");
const src=fs.readFileSync("research/nightfall/observability-publication/SOURCE_ACCESS.md","utf8");
const home=fs.readFileSync("docs/index.html","utf8");
const moon=fs.readFileSync("docs/new-moon.html","utf8");
const rev=fs.readFileSync("docs/review.html","utf8");
for(const id of ["quadratic","observation","finite-transfer","comparison","sources","finite","open"])
 assert.ok(p.includes('id="'+id+'"'),"Missing mathematical route "+id);
const current=JSON.parse(fs.readFileSync("docs/current-site-evidence.json","utf8"));
const q=current.claims.find(c=>c.id==="q2-influence");
assert.ok(q&&p.includes(q.display_coefficient)&&p.includes(q.receipt)&&p.includes(q.scope_marker),"Current quadratic claim must match its source and receipt");
assert.ok(p.includes("Θ(rm/η)"),"Separate fixed-query proposal scope drift");
// Historical manuscripts are not required on a current-result page.
for(const s of ["Turturean","Aaronson","Efron","external","non-author","not an exhaustive"])
 assert.ok(p.toLowerCase().includes(s.toLowerCase()),"Claim-status boundary missing: "+s);
assert.ok(src.includes("53-line editorial synopsis")&&src.includes("Not checked in here"),"Missing proof-access inventory");
assert.ok(home.includes('href="mathematical-results.html"')&&rev.includes('id="theorem-audit"'));
assert.ok(moon.includes("Archived research")&&!moon.includes("Archived breakthroughs"));
assert.ok(fs.readFileSync("docs/sitemap.xml","utf8").includes("mathematical-results.html"));
assert.ok(p.includes("conditional")&&p.includes("not a single-query variance decrement"),"Conditional rank proof or analytic review gate missing");
console.log("PASS: source-bound current theorem page, rank/model separation and review gates");
