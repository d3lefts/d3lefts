"use strict";
// Scoped active-claim ledger: no historical Proof Passport or claim-status promotion.
const assert=require("node:assert/strict");
const fs=require("node:fs");
const read=path=>fs.readFileSync(path,"utf8");
const data=JSON.parse(read("docs/active-proof-passport.json"));
const html=read("docs/active-proof-passport.html");
const home=read("docs/index.html");
const moon=read("docs/new-moon.html");
const research=read("docs/research.html");
const site=read("docs/site.js");
const core=read("docs/erdos-paper-core.js");
const art=read("docs/media/overlap-16cell-fixture.svg");
assert.equal(data.schema,"nightfall-active-proof-passports-v1");
assert.equal(data.version,13);
assert.match(data.as_of,/^2026-11-\d\d$/);
assert.equal(data.lifecycle,"active");
assert.equal(data.frozen_historical_registry_unchanged,true);
assert.equal(data.claims.length,12);
assert.deepEqual(data.claims.map(x=>x.id),["q2-influence","q2-observation","finite-certificate","cubic-obstruction","kaczmarz-logfree","four-shuffle","nested-address-separation","finite-palette-recovery","fair-sign-cubic","universal-spectral","certificate-acquisition","phase-block"]);
assert.equal(new Set(data.claims.map(x=>x.id)).size,data.claims.length);
const statuses=new Set(["paper-proof-internal-audit","lean-kernel-checked-finite-product-scope",
 "exact-proof-attacks-cubic-open","written-proof-exact-check-replay-priority-open","computer-assisted-exact-finite-priority-open",
 "exact-finite-construction-priority-open","analytic-candidate-finite-lean-core","draft-pr-fair-sign-subclass",
 "analytic-conditional-universal-observability","conditional-certificate-adaptive-theorem","lean-checked-finite-construction-priority-open"]);
for(const c of data.claims){
 assert.ok(statuses.has(c.status),c.id+" wrong status");
 for(const key of ["title","claim","mechanism","evidence","audit","source","source_detail"])
  assert.ok(c[key]?.length>15,c.id+" missing "+key);
 assert.ok(Array.isArray(c.assumptions)&&c.assumptions.length>=2,c.id+" premises missing");
 assert.ok(Array.isArray(c.limitations)&&c.limitations.length>=2,c.id+" limits missing");
 assert.ok(fs.existsSync(c.source),c.id+" source unavailable: "+c.source);
 assert.ok(html.includes('id="'+c.id+'"'),"Missing static and accessible passport section "+c.id);
}
assert.ok(html.includes("manually versioned snapshot")||html.includes("manually versioned"));
assert.ok(html.includes(data.source_checkpoint.commit),"Dated source commit must be visible");
assert.ok(html.includes('href="active-proof-passport.json"'),"No machine-readable export link");
assert.ok(html.includes('href="passport.html"'),"Historical registry remains separate");
assert.ok(html.includes("no external")||html.includes("No global novelty"),"Evidence limitations absent");
assert.ok(html.includes('class="nf-claim-grid"')&&html.includes("Evidence"));
assert.ok(home.includes('href="active-proof-passport.html"'),"Active homepage has no source-bound claim ledger");
assert.ok(research.includes('href="active-proof-passport.html"'),"Research library lacks active registry handoff");
assert.ok(site.includes('"active-proof-passport.html"'),"Breadcrumb lifecycle classification missing");
assert.ok(read("docs/sitemap.xml").includes("/active-proof-passport.html"),"Sitemap missing active ledger");
// Protect the new active Kaczmarz passport and its source chain.
const kPage=read("docs/kaczmarz-proof-passport.html");
const kProof=read("research/nightfall/2026-11-kaczmarz-logfree/PROOF.md");
const kPassport=read("research/nightfall/2026-11-kaczmarz-logfree/PROOF_PASSPORT.md");
const kChecker=read("research/nightfall/2026-11-kaczmarz-logfree/exact_audit.py");
const kClaim=data.claims.find(c=>c.id==="kaczmarz-logfree");
assert.ok(kClaim&&kClaim.source_checkpoint==="c3e4806e4c0e266785a19f99bc0a4748d533d439");
assert.ok(kClaim.status.includes("priority-open"));
assert.ok(kPage.includes("K−1")||kPage.includes("K-1"));
assert.ok(kPage.includes("unscaled Theorem 1")&&kPage.includes("52,416"),"Source-matched theorem and independent replay must be visible");
assert.ok(kProof.includes("Theorem A")&&kProof.includes("ceil(W / epsilon^2) - 1"),"Unscaled quantified first-hitting proof missing");
assert.ok(kClaim.claim.includes("ceil(||A||_F^2/epsilon^2)-1")&&kClaim.audit.includes("no author correspondence"),"Source-matched bound or no-contact instruction missing");
assert.ok(fs.existsSync("research/nightfall/2026-11-kaczmarz-logfree/independent_exhaustive_audit.py"),"Independent checker missing");
assert.ok(kPage.includes("Independent")&&kPage.includes("Originality")&&kPage.includes("2,880"));
assert.ok(kPage.includes('href="active-proof-passport.html#kaczmarz-logfree"'));
assert.ok(kPage.includes('role="math"'));
assert.ok(kProof.includes("consistent")&&kProof.includes("first-hitting")&&kProof.toLowerCase().includes("priority for the log-free corollary is unverified"));
assert.ok(kPassport.includes("Originality")&&kPassport.includes("Stop rule"));
assert.ok(kChecker.includes("Fraction")&&kChecker.includes("weighted-max")&&kChecker.includes("best-iterate"));
assert.ok(home.includes('href="kaczmarz-proof-passport.html"'));
assert.ok(research.includes('href="kaczmarz-proof-passport.html"'));
assert.ok(html.includes('href="kaczmarz-proof-passport.html"'));
assert.ok(site.includes('"kaczmarz-proof-passport.html"'));
assert.ok(read("docs/sitemap.xml").includes("/kaczmarz-proof-passport.html"));
// New exact four-shuffle proof is a sixth ACTIVE claim, not a historical or
// internally approved Original Finding. Reproducibility is a separate gate.
const fClaim=data.claims.find(c=>c.id==="four-shuffle");
const fPage=read("docs/four-shuffle-proof-passport.html");
const fSource=read("research/nightfall/2026-11-four-shuffle/PROOF_PASSPORT.md");
const fChecker=read("research/nightfall/2026-11-four-shuffle/verify_four_shuffle.py");
assert.ok(fClaim&&fClaim.status.includes("priority-open"));
assert.ok(fClaim.claim.includes("20")&&fClaim.claim.includes("19"));
assert.ok(fPage.includes("302")&&fPage.includes("24")&&fPage.includes("external mathematical review"));
assert.ok(fPage.includes('href="active-proof-passport.html#four-shuffle"'));
assert.ok(fSource.includes("Bevan")&&fSource.includes("Bouvel"));
assert.ok(fChecker.includes("WITNESS")&&fChecker.includes("assert count==302")&&fChecker.includes("assert tested==24"));
assert.ok(home.includes('href="four-shuffle-proof-passport.html"'));
assert.ok(research.includes('href="four-shuffle-proof-passport.html"'));
assert.ok(site.includes('"four-shuffle-proof-passport.html"'));
assert.ok(read("docs/sitemap.xml").includes("/four-shuffle-proof-passport.html"));
// Seven detailed source-bound research passports: two upgrades and five new.
const expanded=[
 ["finite-certificate","finite-product-influence-proof-passport.html","finite-product-influence.md","LEAN","19"],
 ["cubic-obstruction","cubic-obstruction-proof-passport.html","cubic-obstruction-ledger.md","OPEN","rare"],
 ["nested-address-separation","nested-address-proof-passport.html","nested-address-separation.md","EXACT","1,945"],
 ["finite-palette-recovery","finite-palette-recovery-proof-passport.html","finite-palette-recovery.md","OPEN","Δ"],
 ["fair-sign-cubic","fair-sign-cubic-proof-passport.html","fair-sign-cubic.md","DRAFT","354"],
 ["universal-spectral","universal-spectral-proof-passport.html","universal-spectral.md","OPEN","332"],
 ["certificate-acquisition","certificate-acquisition-proof-passport.html","certificate-acquisition.md","OPEN","K"]
];
for(const [id,page,md,status,signal] of expanded){
 const claim=data.claims.find(c=>c.id===id);
 assert.ok(claim,"missing claim "+id);
 const body=read("docs/"+page);
 const source=read("research/nightfall/2026-11-active-passports/"+md);
 assert.ok(body.includes('href="active-proof-passport.html#'+id+'"'),id+" reverse ledger link missing");
 assert.ok(body.includes('id="statement"')&&body.includes('id="mechanism"')&&body.includes('id="evidence"')&&body.includes('id="limits"')&&body.includes('id="review"'),id+" incomplete passport sections");
 assert.ok(body.includes("OPEN")||body.includes("open"),id+" no open review gate");
 assert.ok(body.includes(signal),id+" missing differentiating evidence signal");
 assert.ok(body.includes("Original Finding")||body.includes("historical"),id+" missing frozen archive boundary");
 assert.ok(source.includes("Independent adversarial audit")&&source.includes("Provenance"),id+" source note lacks proof/audit chain");
 assert.ok(research.includes('href="'+page+'"'),id+" missing library navigation");
 assert.ok(site.includes('"'+page+'"'),id+" missing lifecycle routing");
 assert.ok(html.includes('href="'+page+'"'),id+" missing active dossier link");
 assert.ok(read("docs/sitemap.xml").includes("/"+page),id+" sitemap missing");
 assert.ok(claim.source.startsWith("research/nightfall/2026-11-active-passports/"),id+" current source not self-contained");
}
const finite=data.claims.find(c=>c.id==="finite-certificate");
assert.ok(finite.status==="lean-kernel-checked-finite-product-scope");
assert.ok(finite.evidence.includes("42929857470")&&finite.evidence.includes("19 named declarations"));
assert.ok(!finite.limitations.every(s=>!s.includes("measurable")),"Missing Lean finite-to-measurable scope gate");
const cubic=data.claims.find(c=>c.id==="cubic-obstruction");
assert.ok(cubic.status==="exact-proof-attacks-cubic-open"&&cubic.claim.includes("OPEN"));
assert.ok(cubic.evidence.includes("#347")&&cubic.evidence.includes("#349"));
assert.ok(cubic.claim.includes("179722/6993")&&cubic.claim.includes("Var(Q)"),"v6.1 cubic scope and exact witness absent");
assert.ok(data.claims.find(c=>c.id==="q2-influence").claim.includes("C₂=(10+2√2)²(1+√3)²"),"Latest proposed v9.2 scalar coefficient missing");
assert.ok(data.claims.find(c=>c.id==="fair-sign-cubic").status.includes("draft-pr"));
assert.ok(data.claims.find(c=>c.id==="universal-spectral").status.includes("conditional"));
assert.ok(html.includes("<strong>12</strong>Active claim records")&&html.includes("<strong>v13</strong>"));
assert.ok(read("docs/discovery-system.html").includes("<dt>12</dt><dd>separate active claim passports</dd>"));
// Finite F16 witness is a new active record but never a globally approved Original Finding.
const phase=data.claims.find(c=>c.id==="phase-block");
assert.ok(phase&&phase.status.includes("priority-open"));
assert.ok(phase.evidence.includes("40995299592")&&phase.claim.includes("81"));
assert.ok(read("docs/phase-block-proof-passport.html").includes("eighty_one_distinct_outputs"));
assert.ok(html.includes('href="phase-block-proof-passport.html"'));
assert.ok(read("docs/sitemap.xml").includes("/phase-block-proof-passport.html"));
assert.ok(read("docs/lean-certificate-provenance.json").includes('"classification": "quarantine"'));
// Preserve the frozen historical registry's exact 11-record purpose.
const historical=read("docs/research-registry.js");
assert.ok(historical.includes('"nightfall-proof-passports-v1"'));
assert.ok(!historical.includes('"q2-influence"'),"Active claims must not be inserted into historical frozen registry");
assert.equal((moon.match(/class="moon-evidence-grid"/g)||[]).length,5,"Five archive objects need the same four evidence fields");
for(const name of ["Result","Evidence","Significance","Limits"])
 assert.equal((moon.match(new RegExp("<dt>"+name+"</dt>","g"))||[]).length,5,"Archive label absent: "+name);
// Prove the educational figure's numerical summary from the actual 16-cell source, not from a handwaved drawing.
const raw=core.match(/const FIXTURE=Object.freeze\(\[([^\]]+)\]\)/);
assert.ok(raw,"Canonical finite fixture missing");
const a=raw[1].split(",").map(x=>Number(x.trim()));
assert.equal(a.length,16);assert.equal(a.reduce((x,y)=>x+y),64);
const D=8,k=3;
const q=a.reduce((s,x,i)=>s+(i-k>=0?x*(D-a[i-k]):0),0);
assert.equal(q,136);
assert.ok(art.includes(a.join(", ")),"SVG must list exact 16-cell fixture in alt description");
assert.ok(art.includes(`${2*q}/${a.length*D*D}`),"SVG rational exact value drifted");
assert.ok(art.includes("unrelated to the separate published 131072-cell witness"));
assert.ok(!/<script\b|<foreignObject\b/i.test(art),"Svg must remain static and inert");
assert.ok(moon.includes('src="media/overlap-16cell-fixture.svg"'),"Archive diagram not visible");
assert.ok(moon.includes("16-cell educational")&&moon.includes("different 131,072-cell witness"),"Fixture must not masquerade as full research result");
console.log("PASS: 12 manual active claim passports, seven detailed dossiers, Kaczmarz source/replay, no historical promotion, 5 provenance-complete archives, exact 16-cell operator fixture");

// Nov 12 scientific updates: preserve twelve active claims and the frozen archives.
const q2data=data.claims.find(c=>c.id==="q2-influence");
const obsdata=data.claims.find(c=>c.id==="q2-observation");
assert.ok(q2data.evidence.includes("#408")&&q2data.limitations.some(x=>x.includes("not end-to-end Lean")),"New source-derived proof receipts must stay scoped");
assert.ok(obsdata.claim.includes("12 C₂")&&obsdata.limitations.some(x=>x.includes("depends on")),"Rank-observer analytic dependency missing");
for (const p of ["quadratic-rank-observability.md","information-costs-identification.md","conditional-section-duality.md","check_addressed_family_independent.cjs"])
 assert.ok(fs.existsSync("research/nightfall/2026-11-active-passports/"+p),"Missing v12 proof evidence "+p);
assert.ok(html.includes("Turturean covers all degrees")&&html.includes("not compiled"),"Public proof-status boundary drifted");
