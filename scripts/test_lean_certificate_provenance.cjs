"use strict";
// Editorial provenance check, NOT a substitute for Lean or a novelty determination.
const fs=require("node:fs"),assert=require("node:assert/strict"),path=require("node:path"),crypto=require("node:crypto");
const m=JSON.parse(fs.readFileSync("docs/lean-certificate-provenance.json","utf8"));
const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(d,e.name)):e.name.endsWith(".lean")?[path.join(d,e.name).replaceAll("\\","/")]:[]);
const real=walk("research/nightfall").sort(),got=m.modules.map(x=>x.path).sort();
assert.equal(m.schema,"nightfall-lean-provenance-v1");
// This manifest is a dated source-matched ledger, not a claim that every
// experimental checkout file is already compiled. Reject removal or mutation
// of registered sources; extra files are *unreviewed*, not new certificates.
const realSet=new Set(real),gotSet=new Set(got);
const missing=got.filter(p=>!realSet.has(p));
assert.deepEqual(missing,[],"Registered Lean source missing from checkout");
const pending=real.filter(p=>!gotSet.has(p));
const allowPending=process.env.NIGHTFALL_ALLOW_UNREVIEWED==="1";
const custodyFile="docs/lean-pending-source-custody.json";
const custody=fs.existsSync(custodyFile)?JSON.parse(fs.readFileSync(custodyFile,"utf8")):{sources:[]};
if(fs.existsSync(custodyFile))assert.equal(custody.schema,"nightfall-lean-pending-source-custody-v1");
assert.ok(Array.isArray(custody.sources));
const custodyPaths=custody.sources.map(r=>r.path);
assert.equal(new Set(custodyPaths).size,custodyPaths.length,"Duplicate pending custody path");
for(const r of custody.sources){
 assert.ok(pending.includes(r.path),"Pending custody path absent or already verified: "+r.path);
 const bytes=fs.readFileSync(r.path);
 const sha=crypto.createHash("sha1").update(Buffer.from(`blob ${bytes.length}\0`)).update(bytes).digest("hex");
 assert.equal(r.source_blob_sha,sha,"Pending Lean source mutated: "+r.path);
 assert.equal(r.classification,"unreviewed-source");
 assert.equal(r.ci_source_match_status,"no-verified-receipt");
 assert.equal(r.historical_run,null);
 assert.equal(r.historical_head,null);
 assert.equal(r.global_priority,"unverified");
}
const untracked=pending.filter(p=>!custodyPaths.includes(p));
assert.ok(allowPending||untracked.length===0,
 "Unregistered Lean sources in protected checkout: "+untracked.join(", "));
for(const p of pending){
 assert.ok(fs.existsSync(p),"Unreviewed Lean source disappeared: "+p);
 assert.ok(!m.modules.some(r=>r.path===p),"Pending source silently promoted: "+p);
}
assert.equal(new Set(got).size,got.length);
assert.equal(m.modules.length,67,"Main Lean source count changed: update manifest and exact hashes");
assert.equal(m.ci_source_match_counts.matched_successful_ci_head,67);
assert.equal(m.ci_source_match_counts.no_direct_receipt_identified,0);
assert.equal(m.modules.filter(x=>x.ci_source_match_status==="same-git-blob-as-successful-ci-head").length,67);
assert.equal(m.modules.filter(x=>x.ci_run===null).length,0);
const joint=m.modules.find(x=>x.path.endsWith('/QuadraticUnifiedFinite.lean'));
assert.equal(joint.ci_run,43115838586,"Direct joint kernel receipt missing");
assert.equal(joint.ci_run_head_sha,"3549b5f5f28d67ae0dff1d5191acce23c568c449");
assert.ok(joint.note.includes("Not the exponent-two variance-squared"),"Overstated quadratic endpoint scope");
const anova=m.modules.find(x=>x.path.endsWith("/ANOVAPosteriorBridge.lean"));
assert.equal(anova.ci_run,43110333296,"ANOVA named-declaration kernel receipt missing");
assert.equal(anova.ci_run_head_sha,"7552fb3d09251c58f34c2f37438ea417d30b5d79");
assert.equal(m.counts.quarantine+m.counts.derived_transfer+m.counts.finite_construction,67);
assert.match(m.source_commit,/^[0-9a-f]{40}$/);
assert.match(m.source_tree_sha,/^[0-9a-f]{40}$/);
const valid=new Set(["quarantine","derived-transfer","finite-construction"]);
for(const r of m.modules){
 assert.ok(valid.has(r.classification),r.path);
 assert.ok(fs.existsSync(r.path),"Missing module "+r.path);
 const bytes=fs.readFileSync(r.path);
 const blob=crypto.createHash("sha1").update(Buffer.from(`blob ${bytes.length}\0`)).update(bytes).digest("hex");
 assert.equal(r.source_blob_sha,blob,"Stale certificate source blob: "+r.path);
 assert.equal(r.global_priority,"unverified",r.path);
 assert.ok(r.note.length>20,r.path);
 if(r.classification!=="quarantine") assert.ok(r.passport&&fs.existsSync("docs/"+r.passport),"Unpassported derived or constructed certificate "+r.path);
 if(r.ci_run!==null)assert.ok(Number.isSafeInteger(r.ci_run)&&r.ci_run>0,"Malformed CI pointer "+r.path);
}
for(const key of ["quarantine","derived-transfer","finite-construction"]){
 const n=m.modules.filter(x=>x.classification===key).length;
 assert.ok(n>0,key+" empty");
 const expected={quarantine:m.counts.quarantine,"derived-transfer":m.counts.derived_transfer,"finite-construction":m.counts.finite_construction}[key];
 assert.equal(n,expected,key+" count drift");
}
const law=m.modules.find(x=>x.path.endsWith("/FiniteLawTransfer.lean"));assert.ok(law&&law.classification==="quarantine"&&law.ci_run===43059618451,"Law-transfer proof scope must remain novelty-quarantined");
const phases=m.modules.filter(x=>x.classification==="finite-construction");
assert.deepEqual(phases.map(x=>x.path),["research/nightfall/formalization/phase_block/PhaseBlock.lean"]);
const page=fs.readFileSync("docs/lean-certificate-provenance.html","utf8");
assert.equal((page.match(/<tr><td>\d\d<\/td>/g)||[] ).length,67,"Missing static site entries");
for(const r of m.modules){
 assert.ok(page.includes(r.source_blob_sha),"Missing source hash in static passport: "+r.path);
 assert.ok(page.includes(r.path.split("/").at(-1)),"Source not visible on site: "+r.path);
 if(r.ci_source_match_status==="same-git-blob-as-successful-ci-head"){
  assert.ok(Number.isSafeInteger(r.ci_run),"Verified source match requires a valid run id");
  assert.match(r.ci_run_head_sha,/^[0-9a-f]{40}$/);
  assert.ok(page.includes(`https://github.com/d3lefts/d3lefts/actions/runs/${r.ci_run}`),"Source-matched receipt not shown: "+r.path);
 }
}
assert.ok(page.includes("Quarantine does not retract kernel compilation"));
assert.ok(page.includes('href="lean-certificate-provenance.json"'));
const source=fs.readFileSync("docs/phase-block-proof-passport.html","utf8");
assert.ok(source.includes("eighty_one_distinct_outputs")&&source.includes("40995299592")&&source.includes("priority"));
const active=fs.readFileSync("docs/active-proof-passport.html","utf8");
assert.ok(active.includes("lean-certificate-provenance.html")&&active.includes('id="phase-block"'));
const site=fs.readFileSync("docs/site.js","utf8");
for(const n of ["phase-block-proof-passport.html","lean-certificate-provenance.html"])assert.ok(site.includes('"'+n+'"'));
const sitemap=fs.readFileSync("docs/sitemap.xml","utf8");
for(const n of ["phase-block-proof-passport.html","lean-certificate-provenance.html"])assert.ok(sitemap.includes("/"+n));

// New quadratic modules are certified only at their exact theorem scopes.
const newQuadratic=["HilbertManyIncrementMoment.lean","ArbitraryLawFourthMoment.lean","HilbertTwoIncrementMoment.lean","QuadraticDiscoveryCore.lean","QuadraticHoeffdingBridge.lean"];
for(const name of newQuadratic){
 const found=m.modules.find(x=>x.path.endsWith("/"+name));
 assert.ok(found,"Unclassified quadratic module "+name);
 assert.equal(found.classification,"quarantine","Incomplete quadratic proof promoted as originality: "+name);
 assert.ok(found.note.length>75,"Insufficient limitation scope: "+name);
 assert.ok(Number.isInteger(found.ci_run),"Missing scoped kernel receipt "+name);
}
const activeClaims=JSON.parse(fs.readFileSync("docs/active-proof-passport.json","utf8"));
assert.equal(activeClaims.claims.find(x=>x.id==="q2-influence").status,"lean-kernel-checked-finite-product-scope");
const closed=m.off_main_certificates;
assert.ok(m.off_main_review_scope.includes("NOT an exhaustive census"));
assert.ok(Array.isArray(closed)&&closed.length===1,"Separate off-main proof custody required");
const a=closed[0];
assert.equal(a.merged_to_main,false);
assert.equal(a.id,"f16-adaptive-27-branch");
assert.equal(a.source_ci,41110673165);
assert.equal(a.candidate_ci,41104093748);
assert.equal(a.full_adaptive_decoder_lean_checked,false);
assert.ok(!real.includes(a.path),"Unmerged source must not masquerade as a main Lean file");
assert.ok(fs.existsSync("docs/"+a.passport),"No scoped companion passport");
assert.ok(fs.existsSync(a.audit_note),"No off-main audit note");
const sidecar=fs.readFileSync("docs/"+a.passport,"utf8");
for(const token of ["CLOSED AND UNMERGED","27","41110673165","k=7","not all formalized","phase-block-proof-passport.html"])
 assert.ok(sidecar.includes(token),"Missing conditional branch custody: "+token);
assert.ok(page.includes('id="nonmain"')&&page.includes(a.passport),"Not visible in provenance");
const siteSitemap=fs.readFileSync("docs/sitemap.xml","utf8");
assert.ok(siteSitemap.includes("/"+a.passport),"Off-main passport missing sitemap");
console.log("PASS: 67 historical source-matched Lean records verified; "+pending.length+" additional checkout sources PENDING (no verified receipt or originality claim); off-main evidence separate.");
