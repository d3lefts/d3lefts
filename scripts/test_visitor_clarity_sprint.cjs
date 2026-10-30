"use strict";
// Vesper 2026-10-29 visitor-clarity gate. Source-only safeguards complement
// the existing full-site, mobile, reduced-motion and theme browser tests.
const assert=require("node:assert/strict");
const fs=require("node:fs");
const read=path=>fs.readFileSync(path,"utf8");
const home=read("docs/index.html");
const about=read("docs/about.html");
const review=read("docs/review.html");
const theme=read("docs/ethereal-theme.js");
const themeTest=read("scripts/test_ethereal_theme.mjs");
const verifier=read("research/nightfall/projects/sidon-finite-30/verify_sidon30_standalone.py");
const witness=read("research/nightfall/projects/sidon-finite-30/witness_30.txt");

assert.ok(fs.existsSync("docs/portfolio.html") && fs.existsSync("docs/resume.html"));
assert.ok(about.includes('href="portfolio.html">Professional background &amp; portfolio'));
assert.ok(home.includes('href="portfolio.html">Professional portfolio &amp; résumé'));
assert.ok(home.includes('href="review.html#start-here">Try an exact finite review'));

assert.ok(theme.includes('nightfall.theme.v1'),"Keep existing storage and page theme key");
assert.ok(theme.includes('active?"NULL FIELD":"NEW MOON"'),"Visible switch names both destinations");
assert.ok(theme.includes("New Moon is active. Switch to NULL FIELD"));
assert.ok(theme.includes("NULL FIELD is active. Switch to NEW MOON"));
assert.ok(themeTest.includes('"NULL FIELD"')&&themeTest.includes('"NEW MOON"'),
  "Mobile/desktop route tests use canonical atmosphere names");

// The two cinematic chapters and the exact scientific record are retained.
for(const id of ['id="nf-scroll-cinema"','id="flagships"','class="nf-opening-overlap"',
                 'class="nf-cinema-record"','class="nf-cinema-record-value"'])
  assert.ok(home.includes(id),"Lost opening or scientific element: "+id);
assert.ok((home.match(/0\.380856370118/g)||[]).length>=3,
  "Opening score must remain visible in the animated and static records");
assert.ok(home.includes("131,072")&&home.includes("external review open"),
  "Opening witness identity and external audit gate survive");
assert.ok(home.includes("Review path: obtain the integer heights"),
  "Second cinematic chapter should guide investigation, not repeat the intro");
assert.ok(home.includes("global optimality remains unproved"),
  "Preserve the distinction between a finite witness and the global problem");

// New beginner route is runnable, bounded, and never confuses authorship or
// reproduction with novelty or external mathematical review.
assert.ok(review.includes('id="start-here"')&&review.includes('href="#start-here"'));
assert.ok(review.includes('href="#priority">Advanced theorem-review queue'));
assert.ok(review.includes("verify_sidon30_standalone.py"));
assert.ok(review.includes("witness_30.txt"));
assert.ok(review.includes("weak_sidon_four_point_tests"));
assert.ok(review.includes("three_term_arithmetic_progressions"));
assert.ok(review.includes("PASS, FAIL or INCONCLUSIVE"));
assert.ok(review.includes("novelty, peer review and asymptotic implications remain separate") ||
          review.includes("Novelty, peer review and asymptotic implications remain separate"));
assert.ok(verifier.includes("WITNESS_SHA")&&verifier.includes("27405") &&
          verifier.includes("'exact_sidon_number':17"));
assert.ok(witness.includes(",")&&witness.trim().split(",").length===30,
  "Guided review points to real frozen coordinates");
assert.ok(review.includes('id="priority"')&&review.includes('id="submit"')&&
          review.includes('id="sidon"'),"Existing advanced review routes preserved");
console.log("PASS: named atmospheric controls, researcher portfolio handoff, evidence-first opening, and reproducible novice reviewer path");
