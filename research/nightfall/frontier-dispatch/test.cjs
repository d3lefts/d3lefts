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
