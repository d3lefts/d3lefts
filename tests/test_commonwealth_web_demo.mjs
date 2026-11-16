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
 ["docs/commonwealth-browser/styles.css","projects/commonwealth-os/apps/browser/styles.css"]
];
test("The website mirrors exactly the source demo bytes",()=>{
 for(const [site,source] of mirrors) assert.deepEqual(read(site),read(source),site+" drifted from source");
});
test("Two self-contained working interfaces are linked from an accessible product page",()=>{
 const page=text("docs/commonwealth.html");
 assert.match(page,/<main id="main">/);
 assert.match(page,/<title>Commonwealth OS/);
 assert.match(page,/name="description"/);
 assert.match(page,/rel="canonical"/);
 assert.match(page,/site.js/);
 assert.match(page,/commonwealth.css/);
 for(const route of ["commonwealth-demos/living-voter.html","commonwealth-browser/index.html"]){
  assert.ok(existsSync(join("docs",route)),"missing iframe source "+route);
  assert.ok(page.includes('src="'+route+'"'),"missing live iframe "+route);
  assert.ok(page.includes('href="'+route+'"'),"missing fullscreen route "+route);
 }
 assert.ok(text("docs/index.html").includes('href="commonwealth.html"'));
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
 for(const phrase of ["Nonbinding","not a voting service","fictional","unknown","No official votes","NOT","not a deployment commitment"]){
  assert.ok(page.toLowerCase().includes(phrase.toLowerCase()),"lost explicit trust boundary "+phrase);
 }
 const core=text("docs/commonwealth-browser/core.mjs");
 for(const phrase of ["SUPPORTED_IN_SIMULATION","REJECTED_IN_SIMULATION","INDETERMINATE","officialCertification:false","legalAuthorization:\"NOT_ASSESSED\"","independentVerification:\"NOT_PERFORMED\""]){
  assert.ok(core.includes(phrase),"lost evidence-scope marker "+phrase);
 }
});
