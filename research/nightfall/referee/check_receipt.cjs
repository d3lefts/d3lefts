#!/usr/bin/env node
"use strict";
/* Independent command-line replay entrypoint for a browser Referee receipt.
   Reuses the declared reference core; this is a replay, not outside review. */
const fs=require("node:fs"),crypto=require("node:crypto"),path=require("node:path");
const C=require("../../../docs/referee-core.js");
function canonicalHash(x){return crypto.createHash("sha256").update(JSON.stringify(x)).digest("hex")}
function insist(cond,msg){if(!cond)throw Error(msg)}
function audit(r){
 insist(r?.format==="nightfall-referee-receipt-v1","Unknown receipt format");
 insist(r.version===C.VERSION,"Verifier version mismatch");
 let canon,calculated,attacks,verdict;
 if(r.domain==="continuous-step-overlap"){
  canon={domain:r.domain,input:r.source,claimedScore:r.claimedScore};
  calculated=C.checkOverlap(r.source,r.claimedScore);
  attacks=C.overlapAttacks(r.source,calculated);
  verdict=calculated.status==="FINITE_CHECK_PASSED"&&calculated.dualPathAgreement&&attacks.scoreTamperRejected&&attacks.massPreservingWitnessMutation.rejected===true?"FINITE_CHECK_PASSED":calculated.status==="REJECT"?"REJECTED":"INCONCLUSIVE";
 }else if(r.domain==="weak-sidon-4-5-finite"){
  canon={domain:r.domain,input:r.source,claimedMaximum:r.claimedMaximum};
  calculated=C.checkSidon(r.source,r.claimedMaximum);
  attacks=C.sidonAttacks(r.source,r.claimedMaximum);
  verdict=calculated.status==="FINITE_CHECK_PASSED"&&attacks.understatedMaximumRejected&&attacks.corruptedSubsetRejected?"FINITE_CHECK_PASSED":"REJECTED_OR_INCONCLUSIVE";
 }else throw Error("Unsupported verification domain");
 insist(r.inputSha256===canonicalHash(canon),"SHA-256 input fingerprint mismatch");
 insist(JSON.stringify(calculated)===JSON.stringify(r.result),"Recomputed result differs from receipt");
 insist(JSON.stringify(attacks)===JSON.stringify(r.negativeControls),"Negative controls differ from receipt");
 insist(verdict===r.verdict,"Receipt verdict misrepresents recomputation");
 return{status:"REPLAY_PASS",domain:r.domain,verdict,digest:r.inputSha256,scope:"Exact finite same-codebase replay only; not an independent external referee"};
}
if(require.main===module){
 try{const fn=process.argv[2];if(!fn)throw Error("Usage: node research/nightfall/referee/check_receipt.cjs RECEIPT.json");const report=JSON.parse(fs.readFileSync(path.resolve(fn),"utf8"));console.log(JSON.stringify(audit(report),null,2))}
 catch(e){console.error("REPLAY_REJECTED:",e.message);process.exitCode=1}
}
module.exports={audit,canonicalHash};
