"use strict";
/* Public-facing proof-scope contract, NOT a Lean or mathematical proof. */
const assert=require("node:assert/strict");
const fs=require("node:fs");
const read=p=>fs.readFileSync(p,"utf8");
const reg=JSON.parse(read("docs/active-proof-passport.json"));
const scope=JSON.parse(read("docs/unrestricted-terminal-proof-scope-20261114.json"));
const html=read("docs/active-proof-passport.html");
const note=read("research/nightfall/2026-11-active-passports/UNRESTRICTED_EFRON_STEIN_PROOF_PASSPORT_20261114.md");
const current=read("research/nightfall/2026-11-active-passports/CURRENT_LEAN_PASSPORT_20261114.md");
assert.equal(reg.schema,"nightfall-active-proof-passports-v1");
assert.equal(reg.claims.length,12);
assert.equal(reg.frozen_historical_registry_unchanged,true);
assert.equal(scope.analytic_theorem.lean_status,"open");
assert.equal(reg.current_named_certificate_scope.unrestricted_efron_stein.full_original_measure_infinite_pi_l2_lean,false);
assert.ok(note.includes("uncountable"));
assert.ok(note.includes("martingale differences"));
assert.ok(note.includes("density")&&note.includes("conditional"));
assert.ok(note.includes("kernel"));
assert.ok(note.includes("YuanheZ/lean-stat-learning-theory"));
assert.ok(current.includes("736.673")&&current.includes("#514")&&current.includes("#512"));
assert.ok(html.includes("arbitrary-index")&&html.includes("remains <strong>OPEN</strong>"));
assert.ok(html.includes("736.673")&&html.includes("1064.958"));
const requirePR=new Map([[498,43633180605],[500,43632243900],[501,43631863039],
 [506,43632637271],[512,43635195844],[514,43635955108]]);
assert.equal(scope.source_certificates.length,requirePR.size);
for(const e of scope.source_certificates){
 assert.equal(requirePR.get(e.pr),e.run,"receipt mismatch for PR "+e.pr);
 assert.ok(e.blob_sha1.match(/^[0-9a-f]{40}$/),"missing exact blob for "+e.pr);
 assert.ok(e.name&&e.source&&fs.existsSync(e.source),"source path absent "+e.pr);
 assert.ok(e.scope&&!/unconditional infinite|all.l2 terminal/i.test(e.scope),"illegal promotion "+e.pr);
}
for(const k of ["actual infinitePi L2 cylinder density","conditional expectation operator commutation",
 "finite Efron-Stein arbitrary measurable alphabets","source-matched resampling contraction",
 "unconditional infinitePi terminal theorem with axiom receipt"])
 assert.ok(scope.analytic_theorem.missing_lean.includes(k));
assert.ok(reg.current_named_certificate_scope.finite_q2.strongest_merged.pr===498);
assert.equal(reg.current_named_certificate_scope.scif.finite_all_degree_changed_law_risk.pr,514);
const structural=scope.structural_source_certificates;
assert.ok(Array.isArray(structural)&&structural.length===2);
for(const e of structural){
 assert.equal(e.pr,520);
 assert.equal(e.run,43637631337);
 assert.ok(e.blob_sha1.match(/^[0-9a-f]{40}$/));
 assert.ok(fs.existsSync(e.source));
 assert.ok(e.name.includes("CountableSupport"));
 assert.ok(!/Efron.Stein.*terminal|all.L2.*kernel/i.test(e.scope));
}
assert.equal(scope.structural_receipt.artifact_id,14131110488);
assert.equal(scope.analytic_theorem.lean_status,"open");
console.log("PASS: exact six-source proof scope; arbitrary-index all-L2 Lean endpoint OPEN");
