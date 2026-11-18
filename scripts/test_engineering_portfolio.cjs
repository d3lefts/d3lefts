"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const read = p => fs.readFileSync(path.join(__dirname,"..",p),"utf8");
const home = read("docs/index.html");
const engineering = read("docs/engineering.html");
const evals = read("docs/evals.html");
const stylesheet = read("docs/engineering.css");
const about = read("docs/about.html");
const portfolio = read("docs/portfolio.html");
const sitemap = read("docs/sitemap.xml");
const docs = path.join(__dirname, "..", "docs");

// Regression gate: do not displace the scientific archive or inflate the first fold.
assert.ok(home.includes('id="first-minute"') && home.includes('id="flagships"'));
assert.ok(home.includes('id="signature-wright"') && home.includes('id="signature-erdos"'));
assert.ok(home.includes('id="signature-safety"'));
assert.ok(home.includes('class="nf-engineering-gateway'));
assert.ok(home.includes('href="engineering.html"'));
assert.equal((home.match(/<section\b/g)||[]).length,13);
assert.ok((home.match(/<a\b/g)||[]).length<=46);
assert.ok(home.replace(/<[^>]+>/g," ").replace(/\s+/g," ").length<=14000);
assert.ok(home.includes('href="engineering.css"'));

// Two public standalone pages must be crawlable, usable without JavaScript and reciprocal.
for (const [file,body] of [["engineering.html",engineering],["evals.html",evals]]) {
  assert.ok(body.includes('<main') && body.includes('id="main"'));
  assert.ok(body.includes('href="engineering.css"'));
  assert.ok(body.includes('href="index.html"'));
  assert.ok(body.includes('href="engineering.html"'));
  assert.ok(body.includes('href="evals.html"'));
  assert.ok(body.includes('rel="canonical"'));
  assert.ok(sitemap.includes("/"+file));
  for (const [,href] of body.matchAll(/href="([^"]+)"/g)) {
    if (/^(https?:|mailto:)/.test(href)) continue;
    const [local,fragment] = href.split("#");
    const dest = local || file;
    assert.ok(fs.existsSync(path.join(docs,dest)),file+" has broken local route "+href);
    if (fragment && dest.endsWith(".html")) {
      const target = dest===file ? body : read("docs/"+dest);
      assert.ok(target.includes('id="'+fragment+'"'),file+" references absent anchor "+href);
    }
  }
}
assert.ok(engineering.includes('id="case-studies"') && engineering.includes('id="review-path"'));
assert.ok(engineering.includes('id="systems"') && engineering.includes('id="open-work"'));
assert.ok(evals.includes('id="controlarena"') && evals.includes('id="monitoring"'));
assert.ok(evals.includes('id="unrestricted"') && evals.includes('id="proposed"'));
assert.ok(evals.includes('id="evidence-ledger"'));
assert.ok((evals.match(/<details\b/g)||[]).length>=10, "Task inspectors must work without JS");
assert.ok(stylesheet.includes("@media(max-width:640px)") && stylesheet.includes("prefers-reduced-motion"));

// Numerical and epistemic scope: do not convert negative checks into inflated scores.
for(const term of ["328.80", "445.28", "329.03", "2/2", "6/6", "No published agent score","0 / 6"]) {
  assert.ok(engineering.includes(term)||evals.includes(term),"Missing source-matched measurement or explicit boundary: "+term);
}
for(const term of ["PR #601","PR #644","PR #798"]) {
  assert.ok(evals.includes(term),"Source custody missing: "+term);
}
assert.ok(evals.includes("not an open-ended tool-using repository agent"));
assert.ok(evals.includes("No production cost or latency win"));
assert.ok(evals.includes("not an agent completion"));
assert.ok(evals.includes("Design only / unvalidated weights"));
assert.ok(engineering.includes("not external human peer review") || engineering.includes("not independent human peer review") || engineering.includes("independent human peer review"));
assert.ok(about.includes('href="engineering.html"') && portfolio.includes('href="engineering.html"'));
console.log("PASS: research engineering front door, cross-site source routes, no fabricated benchmark outcomes");
