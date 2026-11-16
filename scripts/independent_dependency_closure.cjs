#!/usr/bin/env node
"use strict";
// An independently implemented structural auditor of the frozen JSON contract.
// Different algorithm and runtime from the Python source gate. Not a Lean or
// mathematical proof check, and no claim of blind non-author reproduction.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const source = path.resolve(__dirname,"../research/catalogue/ACTIVE_DEPENDENCY_CLOSURE.json");
const original = JSON.parse(fs.readFileSync(source,"utf8"));

const rootPairs = [
  ["quantum-physical-operator","q-terminal"],
  ["f9-asymptotic-oracle","f-terminal"]
];
const assignedSources = new Map([
  [645,"513bd8f46573e683d8343f8c9a3f619e4daafded"],
  [647,"23e279c25502777fc4f581c1142abd067bc74a05"],
  [655,"339cdeddcda925bc14dc593b950863005d6f6f9c"]
]);
const receipts = new Map([
  ["q-physical-states",["scoped_ci_reported",647,43917859989]],
  ["q-actual-operators",["scoped_ci_reported",647,43917859989]],
  ["q-ghz-support",["scoped_ci_reported",655,43917861968]],
  ["f-conditional-arithmetic",["conditional_ci_reported",645,43811312747]]
]);
const openIds = new Set(["q-born-numerator","q-optimal-povm","q-terminal",
  "f-decoder-bridge","f-nonadaptive-bridge","f-coding-transfer","f-terminal"]);
const requires = new Map([
  ["q-physical-states",[]],
  ["q-actual-operators",["q-physical-states"]],
  ["q-ghz-support",["q-actual-operators"]],
  ["q-born-numerator",["q-actual-operators","q-ghz-support"]],
  ["q-optimal-povm",["q-physical-states","q-ghz-support"]],
  ["q-terminal",["q-born-numerator","q-optimal-povm"]],
  ["f-conditional-arithmetic",[]],
  ["f-decoder-bridge",[]],
  ["f-nonadaptive-bridge",[]],
  ["f-coding-transfer",["f-nonadaptive-bridge"]],
  ["f-terminal",["f-conditional-arithmetic","f-decoder-bridge",
    "f-nonadaptive-bridge","f-coding-transfer"]]
]);
function check(doc) {
  assert.equal(doc.schema,"nightfall.dependency-closure.v1");
  assert.equal(doc.snapshot_utc,"2026-11-16");
  assert.match(doc.meaning,/no status promotion/);
  assert.ok(Array.isArray(doc.frontiers) && doc.frontiers.length===2);
  assert.ok(Array.isArray(doc.nodes) && doc.nodes.length===11);
  const frontiers = new Map(doc.frontiers.map(f=>[f.id,f]));
  assert.equal(frontiers.size,2,"duplicate frontier");
  const nodes = new Map(doc.nodes.map(n=>[n.id,n]));
  assert.equal(nodes.size,11,"duplicate proof component");
  assert.deepEqual([...nodes.keys()].sort(),[...requires.keys()].sort());
  assert.deepEqual([...frontiers.keys()].sort(),rootPairs.map(x=>x[0]).sort());
  const observed = new Map();
  for(const f of doc.frontiers) {
    const terminal = rootPairs.find(x=>x[0]===f.id)?.[1];
    assert.equal(f.terminal,terminal);
    assert.equal(f.priority,f.id==="quantum-physical-operator"?1:2);
    assert.ok(f.scope.length>60 && f.not_claimed.length>=2);
    for(const ref of f.snapshot_prs) {
      assert.equal(ref.head,assignedSources.get(ref.pr),"source drift");
      assert.equal(observed.has(ref.pr),false,"duplicate PR reference");
      observed.set(ref.pr,ref.head);
    }
  }
  assert.deepEqual([...observed.keys()].sort(),[...assignedSources.keys()].sort());

  for(const node of doc.nodes) {
    assert.ok(frontiers.has(node.frontier),"unknown frontier");
    assert.deepEqual(node.deps,requires.get(node.id),"altered exact dependency edge");
    assert.ok(typeof node.claim==="string" && node.claim.length>70);
    assert.ok(node.limitations?.length>0);
    assert.ok(Array.isArray(node.assumptions));
    for(const dep of node.deps)
      assert.equal(nodes.get(dep)?.frontier,node.frontier,"invalid type/target");
    const receipt = receipts.get(node.id);
    if(receipt) {
      assert.equal(node.status,receipt[0],"CI assertion changed");
      assert.deepEqual(node.evidence,{pr:receipt[1],run:receipt[2]});
      assert.equal(node.next_experiment,null);
      assert.equal(node.assumptions.length,receipt[0]==="conditional_ci_reported"?2:0);
    } else {
      assert.ok(openIds.has(node.id),"unexpected unresolved node");
      assert.equal(node.status,"open");
      assert.equal(node.evidence,null);
      assert.equal(node.assumptions.length,0);
      for(const k of ["prediction","alternative","decisive_test","independent_check"])
        assert.ok(node.next_experiment?.[k]?.length>35,"missing preregistration");
    }
  }
  // Independent iterative topological deletion rather than Python recursion.
  // If no unprocessed node becomes eligible, a directed cycle exists.
  const complete = new Set();
  while(complete.size < nodes.size) {
    let progressed = false;
    for(const [id,n] of nodes) {
      if(!complete.has(id) && n.deps.every(dep=>complete.has(dep))) {
        complete.add(id);
        progressed = true;
      }
    }
    assert.ok(progressed,"cyclic or unresolvable proof graph");
  }
  // Reverse fixed-point reachability: every node must feed a terminal.
  for(const [fid, terminal] of rootPairs) {
    const ancestors = new Set([terminal]);
    while(true) {
      const prev = ancestors.size;
      for(const id of [...ancestors])
        for(const dep of nodes.get(id).deps) ancestors.add(dep);
      if(prev===ancestors.size)break;
    }
    assert.deepEqual([...ancestors].sort(),
      [...nodes.values()].filter(n=>n.frontier===fid).map(n=>n.id).sort(),
      "orphaned proof branch");
  }
  assert.equal([...nodes.values()].filter(n=>n.status==="open").length,7);
  return {frontiers:frontiers.size,nodes:nodes.size,open:7};
}
function attack(mutator) {
  const forged=structuredClone(original);
  mutator(forged);
  assert.throws(()=>check(forged),"mutated ledger incorrectly accepted");
}
const data=check(original);
const n=(d,id)=>d.nodes.find(x=>x.id===id);
attack(d=>n(d,"q-terminal").status="conditional_ci_reported");
attack(d=>n(d,"q-actual-operators").deps=[]);
attack(d=>n(d,"q-born-numerator").deps.push("f-decoder-bridge"));
attack(d=>n(d,"q-physical-states").deps.push("q-terminal"));
attack(d=>n(d,"q-ghz-support").evidence.run++);
attack(d=>n(d,"f-terminal").next_experiment.alternative="");
attack(d=>d.frontiers[0].snapshot_prs[0].head="f".repeat(40));
attack(d=>d.nodes.push(structuredClone(d.nodes[0])));
console.log("PASS independent JS structural checker:",JSON.stringify(data),
  "8 adversarial mutations rejected; no mathematical theorem certified");
