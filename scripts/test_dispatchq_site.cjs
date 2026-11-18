"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const { join } = require("node:path");
const read = f => fs.readFileSync(f, "utf8");
const p = read("docs/dispatchq-b1.html");
const eng = read("docs/engineering.html");
const lab = read("docs/evals.html");
const profile = read("docs/portfolio.html");
const sitemap = read("docs/sitemap.xml");

assert.ok(p.includes('id="dispatchq-title"'));
for (const id of ["challenge", "process", "failure-diagnosis", "evidence"]) {
  assert.ok(p.includes('id="' + id + '"'), "Missing review gate " + id);
}
assert.ok((p.match(/<details\b/g) || []).length >= 5);
assert.ok(p.includes("0</strong>") && p.includes("Blind agent evaluations"));
assert.ok(p.includes("100/100") && p.includes("author reference score"));
assert.ok(p.includes("52–60/100"));
assert.ok(p.includes("not a finalized benchmark"));
assert.ok(p.includes("not the withheld grader"));
assert.ok(p.includes("independent human"));
assert.ok(p.includes("draft PR #818") && p.includes("draft PR #820"));
assert.ok(p.includes("candidate author's published evidence"));
assert.ok(p.includes("hidden tests") || p.includes("withheld grader"));
assert.ok(eng.includes('href="dispatchq-b1.html"'));
assert.ok(lab.includes('href="dispatchq-b1.html"'));
assert.ok(lab.includes('id="dispatchq"'));
assert.ok(profile.includes("Master of Science in Software Engineering (in progress; anticipated March 2027)"));
assert.ok(sitemap.includes("/dispatchq-b1.html"));
const ids = [...p.matchAll(/\bid="([^"]+)"/g)].map(x => x[1]);
assert.equal(new Set(ids).size, ids.length, "duplicate ID on dossier");

for (const [,href] of p.matchAll(/href="([^"]+)"/g)) {
  if (/^(https?:|mailto:)/.test(href)) continue;
  const [target, fragment] = href.split("#");
  const local = target || "dispatchq-b1.html";
  assert.ok(fs.existsSync(join("docs",local)), "missing route " + href);
  if (fragment) {
    const source = target ? read(join("docs",target)) : p;
    assert.ok(source.includes('id="' + fragment + '"'), "missing fragment " + href);
  }
}
assert.ok(p.includes('rel="canonical"') && p.includes('<main id="main"'));
assert.ok(p.includes('href="engineering.css"'));
console.log("PASS: DispatchQ evidence-scoped task dossier, career context, source routes and limits");
