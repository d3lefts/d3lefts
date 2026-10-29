#!/usr/bin/env node
"use strict";
const assert=require("node:assert/strict"),crypto=require("node:crypto");
const C=require("../../../docs/referee-core.js");
const {audit,canonicalHash}=require("./check_receipt.cjs");
function expectThrows(fn){assert.throws(fn)}
function receipt(domain,source,claimed){
 let result,attacks,canon,verdict;
 if(domain==="continuous-step-overlap"){
  result=C.checkOverlap(source,claimed);attacks=C.overlapAttacks(source,result);canon={domain,input:source,claimedScore:claimed};verdict=result.status==="FINITE_CHECK_PASSED"&&result.dualPathAgreement&&attacks.scoreTamperRejected&&attacks.massPreservingWitnessMutation.rejected===true?"FINITE_CHECK_PASSED":result.status==="REJECT"?"REJECTED":"INCONCLUSIVE";
 }else{
  result=C.checkSidon(source,claimed);attacks=C.sidonAttacks(source,claimed);canon={domain,input:source,claimedMaximum:claimed};verdict=result.status==="FINITE_CHECK_PASSED"&&attacks.understatedMaximumRejected&&attacks.corruptedSubsetRejected?"FINITE_CHECK_PASSED":"REJECTED_OR_INCONCLUSIVE";
 }
 return{format:"nightfall-referee-receipt-v1",version:C.VERSION,domain,source,inputSha256:canonicalHash(canon),verdict,result,negativeControls:attacks,...(domain==="continuous-step-overlap"?{claimedScore:claimed}:{claimedMaximum:claimed})}
}
const a=C.OVERLAP_DEMO;
assert.equal(a.heights.length,16);
let x=C.checkOverlap(a);
assert.equal(x.status,"FINITE_CHECK_PASSED");assert.equal(x.dualPathAgreement,true);
assert.equal(C.overlapInput(a).a.reduce((p,v)=>p+v,0n),64n);
assert.equal(x.shifts.length,31);assert.equal(x.shifts[0].lag,-15);assert.equal(x.shifts.at(-1).lag,15);
assert.equal(C.overlapAttacks(a,x).scoreTamperRejected,true);
assert.equal(C.overlapAttacks(a,x).massPreservingWitnessMutation.rejected,true);
assert.equal(C.checkOverlap(a,C.scoreText(x.summary.score)).claimMatches,true);
assert.equal(C.checkOverlap(a,"0/1").status,"REJECT");
expectThrows(()=>C.checkOverlap({...a,heights:a.heights.slice(1)}));
expectThrows(()=>C.checkOverlap({...a,heights:a.heights.map(()=>"-1")}));
expectThrows(()=>C.checkOverlap({...a,heights:Array(257).fill("4")}));
const ra=receipt("continuous-step-overlap",a,C.scoreText(x.summary.score));
assert.equal(audit(ra).status,"REPLAY_PASS");
expectThrows(()=>audit({...ra,inputSha256:"0".repeat(64)}));
expectThrows(()=>audit({...ra,result:{...ra.result,summary:{...ra.result.summary,maxNumerator:"999"}}}));
expectThrows(()=>audit({...ra,verdict:"COMPETITIVE_RECORD"}));
const sidonInput={points:C.SIDON_WITNESS.map(String),subset:C.SIDON_SUBSET.map(String)};
const expectedHash=crypto.createHash("sha256").update(C.SIDON_WITNESS.join(",")+"\n").digest("hex");
assert.equal(expectedHash,"dc4697ce051a57987049199965967cc2b981433816d3daac284454262395978f");
const y=C.checkSidon(sidonInput,17);
assert.equal(y.status,"FINITE_CHECK_PASSED");
assert.equal(y.weakSidonA.pass,true);assert.equal(y.weakSidonA.tested,27405);assert.equal(y.fourFive.pass,true);assert.equal(y.weakSidon.pass,true);
assert.equal(y.weakSidonB.pass,true);assert.equal(y.subset.pairSums,153);
assert.equal(y.proof.arithmeticProgressions,28);
assert.equal(y.proof.status,"PROVED");
assert.equal(y.proof.states,7801);
const atk=C.sidonAttacks(sidonInput,17);
assert.equal(atk.understatedMaximumRejected,true);assert.equal(atk.corruptedSubsetRejected,true);assert.equal(atk.strengthDistinctionDetected,true);
assert.notEqual(C.checkSidon(sidonInput,16).status,"FINITE_CHECK_PASSED");
const ry=receipt("weak-sidon-4-5-finite",sidonInput,17);
assert.equal(audit(ry).status,"REPLAY_PASS");
expectThrows(()=>audit({...ry,negativeControls:{...ry.negativeControls,corruptedSubsetRejected:false}}));
expectThrows(()=>C.checkSidon({...sidonInput,points:[...sidonInput.points,"9"]},17));
const small={points:["0","1","3","7"],subset:["0","1","3","7"]};
assert.equal(C.checkSidon(small,4).status,"FINITE_CHECK_PASSED");
const weak={points:["0","1","2","3"],subset:["0","1","2"]};
assert.notEqual(C.checkSidon(weak,3).status,"FINITE_CHECK_PASSED");
// The two checks are NOT equivalent. This fixture is weak Sidon and fails (4,5).
const strictCounterexample={points:["1","2","3","5"],subset:["1","2","5"]};
const scoped=C.checkSidon(strictCounterexample,3);
assert.equal(scoped.weakSidon.pass,true);
assert.equal(scoped.fourFive.pass,false);
assert.equal(scoped.status,"REJECT_OR_INCONCLUSIVE");
assert.equal(C.sidonAttacks(strictCounterexample,3).strengthDistinctionDetected,true);

if(process.env.REFEREE_FIXTURE_DIR){
 const fs=require("node:fs"),path=require("node:path"),dir=process.env.REFEREE_FIXTURE_DIR;
 fs.mkdirSync(dir,{recursive:true});
 fs.writeFileSync(path.join(dir,"overlap.json"),JSON.stringify(ra,null,2)+"\n");
 fs.writeFileSync(path.join(dir,"sidon.json"),JSON.stringify(ry,null,2)+"\n");
}
console.log("PASS: overlap signed lags / exact dual paths / normalization / score tamper / mutation / receipt replay");
console.log("PASS: frozen Sidon 30 / 27,405 quadruples / 28 progressions / 7,801-state proof / negative controls / receipt replay");
console.log("PASS: input rejection / forged digest / forged verdict / forged check / scope limitation");
