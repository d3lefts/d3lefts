// Site/demo composition verification. Runs offline; does not claim deployment or external review.
import {readFileSync,existsSync} from "node:fs";
import {join,dirname} from "node:path";
import assert from "node:assert/strict";
import test from "node:test";
const read=p=>readFileSync(p);
const text=p=>read(p).toString("utf8");
const mirrors=[
 ["docs/commonwealth-demos/living-voter.html","projects/commonwealth-os/prepilot/v1.3.1/living_voter_mobile.html"],
 ["docs/commonwealth-browser/index.html","projects/commonwealth-os/apps/browser/index.html"],
 ["docs/commonwealth-browser/app.mjs","projects/commonwealth-os/apps/browser/app.mjs"],
 ["docs/commonwealth-browser/core.mjs","projects/commonwealth-os/apps/browser/core.mjs"],
 ["docs/commonwealth-browser/fixtures.mjs","projects/commonwealth-os/apps/browser/fixtures.mjs"],
 ["docs/commonwealth-browser/styles.css","projects/commonwealth-os/apps/browser/styles.css"],
 ["docs/commonwealth-browser/historical-fixtures.js","projects/commonwealth-os/apps/browser/historical-fixtures.js"],
 ["docs/commonwealth-browser/history-core.mjs","projects/commonwealth-os/apps/browser/history-core.mjs"],
 ["docs/commonwealth-browser/question-data.mjs","projects/commonwealth-os/apps/browser/question-data.mjs"],
 ["docs/commonwealth-browser/workspace.mjs","projects/commonwealth-os/apps/browser/workspace.mjs"],
 ["docs/commonwealth-browser/workspace.css","projects/commonwealth-os/apps/browser/workspace.css"],
 ["docs/commonwealth-browser/tests/history-core.test.mjs","projects/commonwealth-os/apps/browser/tests/history-core.test.mjs"],
 ["docs/commonwealth-browser/tests/question-bank.test.mjs","projects/commonwealth-os/apps/browser/tests/question-bank.test.mjs"],
 ["docs/commonwealth-browser/tests/entrypoint.test.mjs","projects/commonwealth-os/apps/browser/tests/entrypoint.test.mjs"],
 ["docs/commonwealth-browser/experience-core.mjs","projects/commonwealth-os/apps/browser/experience-core.mjs"],
 ["docs/commonwealth-browser/experience.mjs","projects/commonwealth-os/apps/browser/experience.mjs"],
 ["docs/commonwealth-browser/experience.css","projects/commonwealth-os/apps/browser/experience.css"],
 ["docs/commonwealth-browser/tests/experience-core.test.mjs","projects/commonwealth-os/apps/browser/tests/experience-core.test.mjs"]
];
test("The website mirrors exactly the source demo bytes",()=>{
 for(const [site,source] of mirrors) assert.deepEqual(read(site),read(source),site+" drifted from source");
});
test("Guided civic experience is public, fictional, and role specific",()=>{
 const entry=text("docs/commonwealth-browser/index.html");
 const page=text("docs/commonwealth-os.html");
 assert.ok(page.includes("commonwealth-browser/index.html#cwexp"));
 for(const role of ["resident","representative","developer"])
   assert.ok(entry.includes('data-cwexp-role="'+role+'"'));
 assert.ok(entry.includes("ILLUSTRATIVE COUNTS / NOT SURVEY DATA"));
 assert.ok(entry.includes("not a vote"));
});
test("The Warrant has its own legal-evidence route and never claims judicial power",()=>{
 const page=text("docs/commonwealth-warrant.html");
 const js=text("docs/commonwealth-warrant.mjs");
 const home=text("docs/commonwealth.html");
 const os=text("docs/commonwealth-os.html");
 const app=text("docs/commonwealth-browser/index.html");
 const intel=text("docs/commonwealth-intelligence.html");
 for(const label of ["AUTHORITY","EVIDENCE","ASSURANCE","Verified Evidence","Unverified","Contested","Illustrative"])
  assert.ok(page.includes(label),"missing status/layer "+label);
 for(const phrase of ["not a judicial warrant","nonbinding","no signed issuance","not a legal instrument"])
  assert.ok(page.toLowerCase().includes(phrase.toLowerCase()),"missing legal boundary: "+phrase);
 assert.ok(home.includes("The Commonwealth Warrant"));
 assert.ok(os.includes("The Warrant"));
 assert.ok(intel.includes("commonwealth-warrant.html"));
 assert.ok(app.includes("Technical Proof Passport"));
 assert.ok(app.includes("../commonwealth-warrant.html"));
 assert.doesNotMatch(js,/fetch\\s*\\(|localStorage|sessionStorage|indexedDB|XMLHttpRequest|sendBeacon/);
});
test("Two self-contained working interfaces are linked from an accessible product page",()=>{
 const page=text("docs/commonwealth.html");
 assert.match(page,/<main id="main">/);
 assert.match(page,/<title>Commonwealth OS/);
 assert.match(page,/name="description"/);
 assert.match(page,/rel="canonical"/);
 assert.match(page,/commonwealth-shell.js/);
 assert.match(page,/commonwealth.css/);
 assert.match(page,/commonwealth-shell.css/);
 assert.doesNotMatch(page,/<script src="site.js"/);
 assert.doesNotMatch(page,/href="site.css"/);
 for(const route of ["commonwealth-demos/living-voter.html","commonwealth-browser/index.html"]){
  assert.ok(existsSync(join("docs",route)),"missing iframe source "+route);
  assert.ok(page.includes('src="'+route+'"'),"missing live iframe "+route);
  assert.ok(page.includes('href="'+route+'"'),"missing fullscreen route "+route);
 }
 assert.ok(text("docs/index.html").includes('href="https://d3lefts.github.io/commonwealth/"'));
 assert.ok(page.includes('href="https://d3lefts.github.io/commonwealth/"'),"The legacy civic landing must hand off to the independently deployed product");
 assert.ok(text("docs/new-moon.html").includes('href="commonwealth.html"'));
 assert.ok(text("docs/portfolio.html").includes('href="commonwealth.html"'));
 assert.ok(text("docs/sitemap.xml").includes("commonwealth.html"));
});
test("Standalone HTML and ESM module dependencies are within the static site",()=>{
 const b="docs/commonwealth-browser";
 const index=text(b+"/index.html");
 const app=text(b+"/app.mjs");
 for(const local of ["styles.css","app.mjs"]){
  assert.ok(index.includes("./"+local));
  assert.ok(existsSync(join(b,local)));
 }
 for(const local of ["fixtures.mjs","core.mjs"]){
  assert.ok(app.includes("./"+local));
  assert.ok(existsSync(join(b,local)));
 }
 assert.ok(text("docs/commonwealth-demos/living-voter.html").includes('id="preview-top"'),"no JS-blocked iPhone fallback");
});
test("The public demo does not promote fictional or hypothetical data to binding elections",()=>{
 const page=text("docs/commonwealth.html");
 for(const phrase of ["Nonbinding","not a voting service","fictional","unknown","Official votes or real-user profiles collected","NOT","not a deployment commitment"]){
  assert.ok(page.toLowerCase().includes(phrase.toLowerCase()),"lost explicit trust boundary "+phrase);
 }
 const core=text("docs/commonwealth-browser/core.mjs");
 for(const phrase of ["SUPPORTED_IN_SIMULATION","REJECTED_IN_SIMULATION","INDETERMINATE","officialCertification:false","legalAuthorization:\"NOT_ASSESSED\"","independentVerification:\"NOT_PERFORMED\""]){
  assert.ok(core.includes(phrase),"lost evidence-scope marker "+phrase);
 }
});

test("Commonwealth public entrances share a civic identity without NIGHTFALL chrome injection",()=>{
 const landing=text("docs/commonwealth.html"),workspace=text("docs/commonwealth-os.html"),
   discover=text("docs/commonwealth-intelligence.html"),chrome=text("docs/site.js");
 const family=text("docs/commonwealth-family.css");
 for(const page of [landing,workspace,discover]){
  assert.ok(page.includes('href="commonwealth-mark.svg"'),"Civic identity icon missing");
  assert.ok(page.includes("Synthetic")||page.includes("synthetic")||page.includes("FICTIONAL")||page.includes("Fictional"),
    "Synthetic demonstration scope missing");
 }
 assert.ok(landing.includes('class="cw-page cw-republic"'),"Primary civic visual identity missing");
 for(const page of [workspace,discover]){
  assert.ok(page.includes('href="commonwealth-family.css"'),"Shared civic palette missing");
  assert.ok(page.includes('href="commonwealth.html"'),"Commonwealth home link missing");
  assert.ok(!page.includes("N∕F")&&!page.includes("NULL FIELD"),"Research lab branding leaked into civic product");
 }
 assert.ok(workspace.includes('class="cw-page cw-family cw-family-os"'));
 assert.ok(discover.includes('class="cw-family cw-family-intelligence"'));
 assert.ok(chrome.includes('page==="commonwealth.html"||page.startsWith("commonwealth-")'),
   "NIGHTFALL navigation injection must stop at Commonwealth boundary");
 assert.ok(family.includes(".cw-family-os")&&family.includes(".cw-family-intelligence"));
 assert.ok(!workspace.includes("NOV 2026 DESIGN SNAPSHOT"),"Undated product preview must not imply a dated research result");
 assert.ok(!discover.includes("RESEARCH DEMO · 2026"),"Generic footer date returned");
});
