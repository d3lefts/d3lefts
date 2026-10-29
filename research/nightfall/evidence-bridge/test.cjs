#!/usr/bin/env node
"use strict";
/* RYEV Evidence Bridge: strict schema, finite replay, tamper rejection, no-mutation contract. */
const assert=require("node:assert/strict"),crypto=require("node:crypto"),fs=require("node:fs"),path=require("node:path");
const bridge=require("./core.js"),C=require("../../../docs/referee-core.js"),X=require("../../../docs/research-tools-core.js");
const canonHash=x=>crypto.createHash("sha256").update(JSON.stringify(x)).digest("hex");
const status=(result,attacks,domain)=>domain==="weak-sidon-4-5-finite"?
  result.status==="FINITE_CHECK_PASSED"&&attacks.understatedMaximumRejected&&attacks.corruptedSubsetRejected?"FINITE_CHECK_PASSED":"REJECTED_OR_INCONCLUSIVE":
  result.status==="FINITE_CHECK_PASSED"&&result.dualPathAgreement&&attacks.scoreTamperRejected&&attacks.massPreservingWitnessMutation.rejected===true?"FINITE_CHECK_PASSED":
  result.status==="REJECT"?"REJECTED":"INCONCLUSIVE";
function refereeReceipt(domain,src,claim){
 const sidon=domain==="weak-sidon-4-5-finite";
 const result=sidon?C.checkSidon(src,claim):C.checkOverlap(src,claim);
 const negativeControls=sidon?C.sidonAttacks(src,claim):C.overlapAttacks(src,result);
 const canonical=sidon?{domain,input:src,claimedMaximum:claim}:{domain,input:src,claimedScore:claim};
 return{
  format:"nightfall-referee-receipt-v1",verifier:"NIGHTFALL Referee",version:C.VERSION,
  createdAt:"2026-10-28T23:26:00.000Z",domain,source:src,
  ...(sidon?{claimedMaximum:claim}:{claimedScore:claim}),
  inputSha256:canonHash(canonical),verdict:status(result,negativeControls,domain),
  result,negativeControls,notes:["Exact finite scope only; no independent human reviewer."]
 }
}
const sidon=refereeReceipt("weak-sidon-4-5-finite",{
 points:C.SIDON_WITNESS.map(String),subset:C.SIDON_SUBSET.map(String)
},17);
const overlap=refereeReceipt("continuous-step-overlap",C.OVERLAP_DEMO,C.scoreText(C.checkOverlap(C.OVERLAP_DEMO).summary.score));
const exactWerner={format:"nightfall-exact-local-receipt-v1",createdAt:"2026-10-28T23:26:00.000Z",
 computedBy:"local browser arithmetic; no independent signoff",
 input:[["0000","0000",4],["0000","1111",1],["1000","2121",1],["0000","0121",1]]
};
exactWerner.result=X.werner(exactWerner.input);
const exactField={format:"nightfall-exact-local-receipt-v1",createdAt:"2026-10-28T23:26:00.000Z",
 computedBy:"local browser arithmetic; no independent signoff",
 input:{rows:[[[0,0],[0,0]]],signal:[[1,0],[1,0]]}
};
exactField.result=X.f25(exactField.input);
const clone=o=>JSON.parse(JSON.stringify(o));
async function reject(r,code,reason,seenInputHashes){
 let error;try{await bridge.preview(r,{seenInputHashes})}catch(e){error=e}
 assert.ok(error,"Expected rejection for "+reason);
 assert.equal(error.code,code,reason+": "+error.message);
 assert.ok(error.message.length>15,reason+": missing human-readable refusal");
 return{case:reason,code,message:error.message};
}
async function run(){
 const positive=[];
 for(const [family,r] of [["sidon",sidon],["overlap",overlap],["werner",exactWerner],["f25",exactField]]){
  const original=JSON.stringify(r);
  const p=await bridge.preview(r);
  assert.equal(JSON.stringify(r),original,"Preview must never mutate imported receipt");
  assert.equal(p.promotionAllowed,false);
  assert.equal(p.reviewStatus,"unreviewed");
  assert.deepEqual(p.claimsTouched,[]);
  assert.equal(p.proposedExperiment.status,"tested");
  assert.ok(p.receiptId===p.inputSha256);
  assert.ok(p.proposedExperiment.evidence.includes("BRIDGE-ID:"+p.receiptId));
  assert.equal(typeof p.receiptSha256,"string");
  positive.push({family,inputSha256:p.inputSha256,receiptSha256:p.receiptSha256,reviewStatus:p.reviewStatus,scope:p.scope});
 }
 const rejected=[];
 let x=clone(sidon);x.source.points[8]=String(Number(x.source.points[8])+1);
 rejected.push(await reject(x,"INPUT_HASH","one-character changed witness with stale digest"));
 x=clone(sidon);x.independently_checked=true;
 rejected.push(await reject(x,"AUTHORITY_SPOOF","forged independently checked label"));
 x=clone(sidon);x.claimedAsymptoticBound="0.55";
 rejected.push(await reject(x,"AUTHORITY_SPOOF","finite Sidon recipe illicitly claiming global asymptotic improvement"));
 x=clone(sidon);x.format="nightfall-referee-receipt-v2";
 rejected.push(await reject(x,"VERSION","unsupported receipt format version"));
 x=clone(sidon);x.version="1.0.1";
 rejected.push(await reject(x,"CODE_VERSION","mismatched producer code version"));
 x=clone(sidon);x.receiptId="a".repeat(64);
 rejected.push(await reject(x,"RECEIPT_ID","mismatched canonical receipt identifier"));
 x=clone(sidon);x.result.proof.states+=1;
 rejected.push(await reject(x,"RESULT_REPLAY","forged successful finite proof counter"));
 x=clone(sidon);x.negativeControls.corruptedSubsetRejected=false;
 rejected.push(await reject(x,"NEGATIVE_CONTROLS","forged negative control"));
 x=clone(sidon);x.verdict="THEOREM_PROVED";
 rejected.push(await reject(x,"VERDICT","forged proof verdict"));
 x=clone(sidon);x.verifier="External Certified Referee";
 rejected.push(await reject(x,"SOURCE_METADATA","forged canonical Referee producer identity"));
 x=clone(sidon);x.sourceDossier="https://attacker.invalid/research/false-proof";
 rejected.push(await reject(x,"SOURCE_METADATA","tampered source dossier metadata"));
 x=clone(sidon);x.notes=["Externally verified and peer reviewed"]; 
 rejected.push(await reject(x,"AUTHORITY_SPOOF","forged scientific review claim hidden in source notes"));
 x=clone(sidon);x.result.reviewed=true;
 rejected.push(await reject(x,"AUTHORITY_SPOOF","nested forged reviewer authority"));
 x=clone(exactWerner);x.result.engine="exact-four-qutrit-werner-v7";
 rejected.push(await reject(x,"CODE_VERSION","mismatched exact-calculator code version"));
 x=clone(exactField);x.result.phaseOrbits=42;
 rejected.push(await reject(x,"RESULT_REPLAY","tampered exact F25 enumeration"));
 const id=(await bridge.preview(sidon)).receiptId;
 rejected.push(await reject(sidon,"DUPLICATE","duplicate finite input fingerprint",new Set([id])));
 // Confirm preview is pure; no browser storage API in the bridge library, nor writes to the experiment ledger.
 assert.ok(!require("node:fs").readFileSync(require.resolve("./core.js"),"utf8").includes("localStorage"),
   "Preview-only adapter must have zero localStorage access");
 const receipt2=await bridge.preview(sidon);
 assert.equal(receipt2.reviewStatus,"unreviewed");
 if(process.env.BRIDGE_FIXTURE_DIR){
  const dir=process.env.BRIDGE_FIXTURE_DIR;fs.mkdirSync(dir,{recursive:true});
  for(const [name,obj] of Object.entries({sidon,overlap,exactWerner,exactField,tamperedSidon:(()=>{const y=clone(sidon);y.source.points[8]=String(Number(y.source.points[8])+1);return y})()}))
   fs.writeFileSync(path.join(dir,name+".json"),JSON.stringify(obj,null,2)+"\n");
  fs.writeFileSync(path.join(dir,"refusals.json"),JSON.stringify(rejected,null,2)+"\n");
  fs.writeFileSync(path.join(dir,"accepted.json"),JSON.stringify(positive,null,2)+"\n");
 }
 console.log("PASS Evidence Bridge: "+positive.length+" finite/exact receipt previews; "+rejected.length+" strict negative controls.");
 console.log("PASS: canonical hash matches; input/result/negative-control replay; authority forgery and theorem promotion rejected.");
 console.log("PASS: preview is read-only; reviewStatus unreviewed; original receipts unchanged.");
}
run().catch(e=>{console.error(e.stack);process.exitCode=1});
