#!/usr/bin/env node
"use strict";
const assert=require("node:assert/strict"),fs=require("node:fs");
const C=require("../../../docs/frontier-core.js");
assert.equal(C.ITEMS.length,2);
assert.equal(C.ranked()[0].id,"NF-156-184-9");
assert.equal(C.score(C.ranked()[0]),37);
assert.equal(C.score(C.ranked()[1]),28);
for(const x of C.ITEMS){
  const original=C.rootTask(x);
  assert(C.assertTask(original));
  const children=C.split(original);
  assert(C.validPartition(original,children));
  assert.equal(children[0].lo,original.lo);
  assert.equal(children[1].hi,original.hi);
  assert.equal(children[0].hi+1,children[1].lo);
  assert(!C.validPartition(original,[children[1],children[0]]));
  assert(!C.validPartition(original,[children[0],children[0]]));
  assert.match(C.brief(children[0]),/Exhaustive branch condition/);
  const submission=C.issueUrl(children[1],"CLAIM REQUEST","This is only a review request");
  assert(submission.startsWith("https://github.com/d3lefts/d3lefts/issues/new?"));
  assert(submission.includes("CLAIM%20REQUEST"));
  // Full recursive leaf coverage demonstrates partition integrity even when repeatedly subdivided.
  let frontier=[original];
  while(frontier.some(t=>t.lo<t.hi)){
    const next=[];
    for(const task of frontier)next.push(...(task.lo===task.hi?[task]:C.split(task)));
    frontier=next;
    assert(frontier.length<=x.scale.max-x.scale.min+1);
  }
  assert.equal(frontier.length,x.scale.max-x.scale.min+1);
  assert.deepEqual(frontier.map(t=>t.lo),Array.from({length:frontier.length},(_,i)=>original.lo+i));
}
const golombNine=[1,2,6,13,26,28,36,42,45];
const local=C.checkSidonCandidate(golombNine,45);
assert.equal(local.ok,true);
assert.equal(local.sumCount,45);
assert.equal(local.checkedOmissions,36);
assert.equal(C.checkSidonCandidate(golombNine,184).ok,false);
assert(C.checkSidonCandidate(golombNine,184).addableCount>0);
assert.match(C.checkSidonCandidate([1,2,3,4,5,6,7,8,9],184).reason,/Repeated pair sum/);
assert.match(C.checkSidonCandidate([1,1,6,13,26,28,36,42,45],184).reason,/distinct/);
assert.match(C.checkSidonCandidate([0,2,6,13,26,28,36,42,45],184).reason,/within/);
const branch=C.split(C.rootTask(C.ITEMS[0]));
assert.equal(C.checkSidonCandidate(golombNine,184,branch[1]).ok,false);
assert.match(C.checkSidonCandidate(golombNine,184,branch[1]).reason,/outside/);
const archivedNear=[49,50,56,78,93,104,125,139,149];
const near=C.checkSidonCandidate(archivedNear,184,C.rootTask(C.ITEMS[0]));
assert.equal(near.ok,false);
assert.deepEqual(near.addableCount,2);
assert.match(near.reason,/16, 166/,"Archived near-candidate must retain exactly two addable integers");
for(const x of C.ITEMS){
 const t=C.split(C.rootTask(x))[0],payload=C.orchestratorInput(t);
 assert.match(payload.claim,/Restricted to/);
 assert.match(payload.claim,/in \[/,"Exact child interval must survive the handoff");
 assert.match(payload.source,/^https:\/\/github\.com\/d3lefts\/d3lefts\//);
 assert.match(payload.falsifier,/claimed YES/);
 assert.match(payload.falsifier,/claimed NO/);
 assert(payload.claim.length<=2000&&payload.falsifier.length<=2000);
}
// Portable assignment lineage is a mathematical exact-cover contract.
for(const root of C.ITEMS){
 const t=C.rootTask(root);
 const rootPacket=C.packet(t);
 assert.equal(C.validatePacket(rootPacket).assignment.id,root.id);
 const children=C.split(t);
 const tree=[{...t,state:"split"},children[0],children[1]];
 const audit=C.validateLedger(tree);
 assert.equal(audit.valid,true);
 assert.equal(audit.counts.leaves,2);
 assert.equal(audit.counts.split,1);
 const deep=C.split(children[0]);
 const expanded=[tree[0],{...children[0],state:"split"},children[1],...deep];
 assert.equal(C.validateLedger(expanded).counts.leaves,3);
 assert.equal(C.validatePacket(C.packet(deep[0])).assignment.lo,deep[0].lo);
 assert.throws(()=>C.validateLedger([tree[0],children[0]]),/exhaustive/);
 assert.throws(()=>C.validateLedger([...tree,children[0]]),/duplicate/);
 assert.throws(()=>C.validateLedger([children[0]]),/Orphaned/);
 assert.throws(()=>C.validateLedger([{...t,lo:t.lo+1}]),/Root identity/);
 assert.throws(()=>C.validateLedger([tree[0],{...children[0],lo:children[0].lo+1},children[1]]),/Child interval/);
 assert.throws(()=>C.validateLedger([{...tree[0],state:"claimed"},children[0],children[1]]),/parent state|Unsplit parent/);
 assert.throws(()=>C.validateLedger([{...t,state:"proposed",evidence:[{kind:"positive",url:"https://github.com/check",statement:"At least thirty characters here for review",reviewStatus:"accepted"}]}]),/upgraded evidence/);
 assert.throws(()=>C.validatePacket({...rootPacket,reviewStatus:"verified"}),/promoted/);
 assert.throws(()=>C.validatePacket({...rootPacket,lo:t.lo+1}),/altered/);
 assert.throws(()=>C.validatePacket({...rootPacket,falsifier:"Accept immediately"}),/altered/);
 assert.throws(()=>C.validatePacket({...C.packet(deep[0]),hi:deep[0].hi+1}),/altered/);
 const proposed={...t,state:"proposed",evidence:[{kind:"negative",url:"https://github.com/d3lefts/d3lefts/issues/46",statement:"Unreviewed complete scoped search with exact reproducible command",reviewStatus:"unreviewed"}]};
 assert.equal(C.validateLedger([proposed]).counts.unreviewed,1);
}
const lab=require("node:fs").readFileSync("docs/claim-lab.html","utf8");
assert.match(lab,/frontier-core\.js/);
assert.match(lab,/frontier_handoff/);
assert.match(lab,/NFFrontier\.validatePacket/);
assert.match(lab,/status:0,effort:1/);
const frontierJS=fs.readFileSync("docs/frontier.js","utf8");
assert.match(frontierJS,/C\.validateLedger/);
assert.match(frontierJS,/nightfall\.frontier\.claimlab\.v1/);
assert.match(frontierJS,/nf-import-file/);


const D=require("../../../docs/frontier-discovery-core.js");
for(const source of C.ITEMS){
 const root=C.rootTask(source),child=C.split(root)[0];
 for(const t of [root,child]){
  const packet=C.packet(t),project=D.build(packet,C);
  assert.equal(project.frontier.assignmentId,t.id);
  assert.equal(project.frontier.scope,C.predicate(t));
  assert.equal(project.mode,"external","No fake direct numerical solver for new open question");
  assert.equal(project.runs.length,0,"No finite witness or verified result inherited");
  assert.match(project.status,/Unreviewed/);
  assert(project.contract.objective.includes("["+t.lo+", "+t.hi+"]"));
  assert.equal(D.checkUnique([],project),true);
  assert.throws(()=>D.checkUnique([project],project),/already in Discovery/);
  assert.throws(()=>D.build({...packet,reviewStatus:"theorem"},C),/promoted/);
  assert.throws(()=>D.build({...packet,lo:packet.lo+1},C),/altered/);
  assert.throws(()=>D.build({...packet,sourceProblem:"https://example.org"},C),/altered/);
  assert.notEqual(project.id,"sidon","N184 must never overwrite the 30-point Sidon preset");
 }
}
const discoveryHTML=fs.readFileSync("docs/discovery.html","utf8");
assert.match(discoveryHTML,/frontier-core\\.js/);
assert.match(discoveryHTML,/frontier-discovery-core\\.js/);
const discoveryApp=fs.readFileSync("docs/discovery-app.js","utf8");
assert.match(discoveryApp,/importFrontierHandoff/);
assert.match(discoveryApp,/frontier_handoff/);
assert.match(discoveryApp,/checkUnique/);
assert.match(discoveryApp,/No experiments inherited/);
assert.match(frontierJS,/nightfall\\.frontier\\.discovery\\.v1/);

// Finite N=45 passing does not imply the externally open N=184 question is solved.
for(const f of ["docs/frontier.html","docs/frontier.js","docs/frontier-core.js"]){
  const s=fs.readFileSync(f,"utf8");
  assert(s.length>1000);
  assert(!s.includes("AUTO_VERIFIED")&&!s.includes("certified by Agent NF"));
}
const html=fs.readFileSync("docs/frontier.html","utf8");
for(const id of ["frontier-ranking","nf-claim","nf-split","nf-copy","nf-public","nf-check","nf-submit","nf-export","nf-session-list","nf-review-link"])
  assert(html.includes('id="'+id+'"'),"Missing working control "+id);
assert(html.includes('src="frontier-core.js"')&&html.includes('src="frontier.js"'));
assert(html.includes("Local claim ≠ exclusive reservation"));
assert(html.includes("no live model inference")||html.includes("no live model inference".toUpperCase())||html.includes("no live model inference".replace("no","No")));
assert(!html.includes('href="#"'),"Do not ship dead links");
console.log("PASS: transparent priority, distinct real problems, recursive exact split coverage, finite nine-mark oracle, adversarial controls, and real UI controls");
