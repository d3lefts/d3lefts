"use strict";
// Vesper 2026-10-29 visitor-clarity gate. Source-only safeguards complement
// the existing full-site, mobile, reduced-motion and theme browser tests.
const assert=require("node:assert/strict");
const fs=require("node:fs");
const read=path=>fs.readFileSync(path,"utf8");
const home=read("docs/index.html");
const moon=read("docs/new-moon.html");
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
assert.ok(theme.includes("NEW MOON is active. Open NULL FIELD"));
assert.ok(theme.includes("NULL FIELD is active. Open NEW MOON"));
assert.ok(theme.includes("Warm Night palette is active. Switch to Deep Space palette"));
assert.ok(theme.includes("Deep Space palette is active. Switch to Warm Night palette"),"On shared pages the toggle changes appearance, not the research lifecycle");
assert.ok(themeTest.includes('"NULL FIELD"')&&themeTest.includes('"NEW MOON"'),
  "Mobile/desktop route tests use canonical atmosphere names");

// The active cinematic remains source-bound; historical exact objects live in NEW MOON.
for(const id of ['id="nf-scroll-cinema"','id="flagships"','class="nf-opening-overlap"',
                 'class="nf-cinema-record"','class="nf-cinema-record-value"'])
  assert.ok(home.includes(id),"Lost opening or scientific element: "+id);
assert.ok((moon.match(/0\.380856370118/g)||[]).length>=1,
  "Archived Erdős witness value must remain visible in NEW MOON");
assert.ok(moon.includes("131,072")&&moon.includes("EXTERNAL REVIEW OPEN"),
  "Archived witness identity and external review limit survive");
assert.ok(moon.includes("erdos-paper.html")&&moon.includes("evidence.html#public-downloads"),
  "Historical record must link exact source and frozen release");
assert.ok(moon.includes("Global optimality"),
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
assert.ok(review.includes("The seed and affine construction come from an earlier anonymous reader submission"),
  "Review page must explicitly credit earlier seed and map");
assert.ok(review.includes("5/9 bound is stronger than the finite 17/30 ratio"),
  "Review page must not suggest the fixed witness improves the current asymptotic bound");
assert.ok(review.includes("novelty review"),
  "Endpoint and hypergraph-criticality priority remain open");
assert.ok(verifier.includes("WITNESS_SHA")&&verifier.includes("27405") &&
          verifier.includes("'exact_sidon_number':17"));
assert.ok(witness.includes(",")&&witness.trim().split(",").length===30,
  "Guided review points to real frozen coordinates");
assert.ok(review.includes('id="priority"')&&review.includes('id="submit"')&&
          review.includes('id="sidon"'),"Existing advanced review routes preserved");

// First-impression editorial budget: supporting evidence remains, repetition does not.
const editorial=read("docs/index.html").replace(/<[^>]+>/g," ").replace(/\s+/g," ");
const openingCss=read("docs/home-opening-cinema.css");
assert.ok(editorial.length<=12000,"Homepage exceeded its signature-first editorial copy budget");
assert.ok(home.includes('href="#flagships"'),"First-fold route to the three signature results is missing");
for(const id of ["signature-wright","signature-erdos","signature-safety"])
 assert.ok(home.includes('id="'+id+'"'),"Signature research priority was displaced: "+id);
assert.ok(home.indexOf('id="signature-wright"')<home.indexOf('id="signature-erdos"')&&home.indexOf('id="signature-erdos"')<home.indexOf('id="signature-safety"'),"Principal results should lead in stated order");
for(const selector of ["#main>.hero.nf-opening","#nf-scroll-cinema.nf-cinema--still .nf-cinema-stage","#flagships .nf-signature-card"])
 assert.ok(openingCss.includes(selector),"Compact evidence-first layout regression: "+selector);
assert.equal((home.match(/<a\b/g)||[]).length<=45,true,"Avoid recreating competing navigation directories");

console.log("PASS: active NULL FIELD, signature-first evidence and copy budget, archival NEW MOON, exact novice reviewer path");
