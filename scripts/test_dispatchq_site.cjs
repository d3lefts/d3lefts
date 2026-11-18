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
assert.ok(p.includes('id="coverage-contrast"'));
assert.ok(p.includes('id="concurrent-witness"'));
assert.ok(p.includes('id="blackbox-stress"') && p.includes('id="grader-proof-attack"'));
assert.ok(p.includes("8 / 8 duplicate-claim rounds.") && p.includes("44384068910"));
assert.ok(p.includes("Five wrong repairs.") && p.includes("Five perfect scores."));
assert.ok(p.includes("5 of 12 defects scored 100/100.") && p.includes("12 of 12 tested faults detected."));
assert.ok(p.includes("/pull/838") && p.includes("/pull/839"));
assert.ok(p.includes("No real coding agents were scored"));
assert.ok(eng.includes("unmodified-API six-process stress"));
assert.ok(lab.includes("five incorrect repairs 100/100"));
assert.ok(p.includes("Both claim the same job."));
assert.ok(p.includes("source-targeted race witness") || p.includes("A source-targeted race witness."));
assert.ok(p.includes("44380919138") && p.includes("/pull/836"));
assert.ok(eng.includes("two-process forced interleaving"));
assert.ok(p.includes("The smoke suite was green."));
assert.ok(p.includes("3 of 3 green.") && p.includes("8 defects exposed."));
assert.ok(p.includes("44349472666") && p.includes("44351598574"));
assert.ok(p.includes("05edf787fbd1cb3841ed4aa813361ee1024b354f6fcd7505a56eddf98cbfd406"));
assert.ok(p.includes("two database exceptions were valid rejections"));
assert.ok(!p.includes("10 defects exposed."));
assert.ok(p.includes("not a finalized benchmark"));
assert.ok(p.includes("not the withheld grader"));
assert.ok(p.includes("independent human"));
assert.ok(p.includes("draft PR #818") && p.includes("draft PR #820"));
assert.ok(p.includes("candidate author's published evidence"));
assert.ok(p.includes("hidden tests") || p.includes("withheld grader"));
assert.ok(eng.includes('href="dispatchq-b1.html"'));
assert.ok(lab.includes('href="dispatchq-b1.html"'));
assert.ok(lab.includes('id="dispatchq"'));
assert.ok(eng.includes('id="current-eval"') && eng.includes("Two tasks."));
assert.ok(eng.includes("DispatchQ-B1") && eng.includes("ArtifactGraph-B2"));
assert.ok(lab.includes('id="artifactgraph"'), "B2 evaluator missing");
assert.ok(lab.includes("11 contract violations, 9 positive controls"));
assert.ok(lab.includes("zero unexpected errors, zero mismatches"));
assert.ok(lab.includes("author-hidden grader") && lab.includes("Neither test suite is an AI model success rate"));
assert.ok(lab.includes("https://github.com/d3lefts/d3lefts/pull/824"));
assert.ok(lab.includes("https://github.com/d3lefts/d3lefts/pull/825"));
assert.ok(lab.includes("https://github.com/d3lefts/d3lefts/actions/runs/44354996082"));
assert.ok(lab.includes('id="run-evidence"'));
assert.ok(lab.includes("original author reference passed only 20/22"));
assert.ok(lab.includes("private local audit, not independently replayed by public CI"));
assert.ok(lab.includes("https://github.com/d3lefts/d3lefts/pull/827"));
assert.ok(lab.includes("https://github.com/d3lefts/d3lefts/actions/runs/44357912261"));
assert.ok(lab.includes("incompatible 50/100 and 7/7 score scales"));
assert.ok(lab.includes("externally SHA-256-pinned"));
assert.ok(lab.includes("https://github.com/d3lefts/d3lefts/pull/830"));
assert.ok(lab.includes("https://github.com/d3lefts/d3lefts/actions/runs/44374815964"));
assert.ok(lab.includes("zero accepted blind agent scores"));

assert.ok((lab.match(/<details\b/g) || []).length >= 16, "B2 inspection details missing");

assert.ok(profile.includes("Master of Science in Software Engineering (in progress; anticipated March 2027)"));
const resume = read("docs/resume.html");
assert.ok(resume.includes("Master of Science in Software Engineering, in progress; anticipated March 2027 (not yet conferred)"));
assert.ok(resume.includes('href="dispatchq-b1.html"'));
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
