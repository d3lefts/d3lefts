"use strict";
const assert=require("node:assert/strict");
const F=require("../docs/frontier-core.js");
const E=require("../docs/join-evidence-core.js");
const root=F.base("NF-156-184-9"),task=F.rootTask(root),packet=F.packet(task);
const collision=[1,2,3,4,5,6,7,8,9];
const extendable=[1,2,6,13,26,28,36,42,45];
assert.equal(F.validatePacket(packet).assignment.id,task.id);
assert.deepEqual(E.normalize("9,8,7,6,5,4,3,2,1"),collision);
assert.throws(()=>E.normalize("1 2 3"),/nine/);
assert.throws(()=>E.normalize("1 2 3 4 5 6 7 8 185"),/184/);
const c=E.check(collision,packet,F);
assert.equal(c.primary_status,"PAIR_COLLISION");
assert.equal(c.independent_status,"PAIR_COLLISION");
assert.equal(c.agreement,true);
const a=E.check(extendable,packet,F);
assert.equal(a.primary_status,"EXTENDABLE");
assert.equal(a.independent_status,"EXTENDABLE");
assert.equal(a.agreement,true);
assert.ok(a.independent.addableCount>0);
const collisionAttack=E.attack(c,packet,F);
assert.equal(collisionAttack.status,"LOCAL_ATTACK_CONTROLS_PASSED");
assert.equal(collisionAttack.controls.length,3);
assert.ok(collisionAttack.controls.every(x=>x.rejected_as_expected));
const extAttack=E.attack(a,packet,F);
assert.equal(extAttack.status,"LOCAL_ATTACK_CONTROLS_PASSED");
const rawNote="Test repeated sums against the independent difference checker.";
const receipt=E.receipt(collision,packet,rawNote,F);
assert.equal(receipt.reviewStatus,"unreviewed");
assert.equal(receipt.global_problem_solved,false);
assert.equal(receipt.novelty_established,false);
assert.equal(E.verify(receipt,F).valid,true);
assert.equal(E.verify(E.receipt(extendable,packet,"negative candidate",F),F).valid,true);
for(const [tamperIndex,tamper] of [
 x=>x.calculation.primary_status="MAXIMAL_FINITE",
 x=>x.attack.status="INDEPENDENT_CERTIFIED",
 x=>x.attack.controls[0].rejected_as_expected=false,
 x=>x.input[8]=10,
 x=>x.assignment.lo=2,
 x=>x.assignment.question="Altered global question",
 x=>x.global_problem_solved=true,
 x=>x.independent_external_review=true,
 x=>x.novelty_established=true,
 x=>x.reviewStatus="verified",
 x=>x.human_action="AUTO_PUBLISH",
 x=>x.frontier_snapshot="forged"
]){
 const changed=structuredClone(receipt);tamper(changed);
 assert.equal(E.verify(changed,F).valid,false,"Tampered scientific field #"+tamperIndex+" must be rejected.");
}
const branch=F.split(task)[1];
const bp=F.packet(branch);
const out=E.check(collision,bp,F);
assert.equal(out.primary_status,"INPUT_REJECTED");
assert.equal(out.independent_status,"INPUT_REJECTED");
assert.equal(out.agreement,true);
assert.equal(E.verify(E.receipt(collision,bp,"outside branch",F),F).valid,true);
assert.throws(()=>E.receipt(collision,{...packet,lo:100},"no",F),/contract altered/i);
assert.throws(()=>E.receipt(collision,packet,"x".repeat(4001),F),/exceeds/);
// A fixed same-budget, three-case instrument acceptance: controls must distinguish
// malformed, collision, and extendable hypotheses. This is NOT a research-yield trial.
const budget=[{values:[1,1,3,4,5,6,7,8,9],status:"INPUT_REJECTED"},
 {values:collision,status:"PAIR_COLLISION"},
 {values:extendable,status:"EXTENDABLE"}];
const observed=budget.map(x=>E.check(x.values,packet,F));
assert.deepEqual(observed.map(x=>x.independent_status),budget.map(x=>x.status));
assert.ok(observed.every(x=>x.agreement));
console.log("PASS: real unresolved N184 source scope, independent difference/maximality checker, bounded attacks, exact receipt replay, tamper controls and fixed 3-case acceptance budget");