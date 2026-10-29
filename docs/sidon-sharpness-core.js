/* NIGHTFALL / Sidon sharpness replay — bounded exact finite arithmetic.
 * Reuses Referee's already-tested core, not an independent external verifier.
 */
(function(root,factory){
  const api=factory();
  if(typeof module==="object"&&module.exports)module.exports=api;
  else root.NightfallSidonSharpness=api;
})(typeof globalThis==="object"?globalThis:this,function(){
  "use strict";
  const WITNESS_SHA="dc4697ce051a57987049199965967cc2b981433816d3daac284454262395978f";
  function integer(s,name,positive=false){
    const v=String(s).trim();
    if(!/^-?\d{1,15}$/.test(v))throw Error(name+" must be an exact bounded integer.");
    const n=BigInt(v);
    if(positive&&n<=0n)throw Error(name+" must be positive.");
    return n;
  }
  function check(C,spacing,offset){
    if(!C||!Array.isArray(C.SIDON_WITNESS)||!Array.isArray(C.SIDON_SUBSET))throw Error("Referee core unavailable.");
    const M=integer(spacing,"Spacing",true),t=integer(offset,"Offset");
    const old=C.SIDON_WITNESS.map(BigInt);
    const newPoints=[M+t,2n*M+t,3n*M+t];
    const original=C.checkSidon({
      points:C.SIDON_WITNESS.map(String),subset:C.SIDON_SUBSET.map(String)
    },17);
    const disjoint=newPoints.every(x=>!old.includes(x))&&new Set(newPoints.map(String)).size===3;
    const combined=old.concat(newPoints);
    const strict=C.sidonWeakA(combined);
    const weak=C.sidonWeakB(combined);
    const subset=C.sidonSubset(C.SIDON_SUBSET.map(BigInt).concat(newPoints.slice(0,2)));
    const progression=newPoints[0]+newPoints[2]===2n*newPoints[1];
    const boundary=disjoint&&strict.pass&&weak.pass&&progression&&subset.pass&&original.status==="FINITE_CHECK_PASSED";
    return Object.freeze({
      schema:"nightfall-finite-sidon-sharpness-replay-v1",
      scope:"The displayed 33-point example only. No new asymptotic bound, priority claim, or external referee acceptance.",
      verdict:boundary?"FINITE_EXAMPLE_CHECK_PASSED":"NO_CERTIFICATE_FOR_SELECTED_INPUT",
      data:{spacing:String(M),offset:String(t),newPoints:newPoints.map(String),
        baseSize:30,baseMaxSidon:original.status==="FINITE_CHECK_PASSED"?17:null,
        combinedSize:33,claimedCombinedMax:19,expectedBaseSha256:WITNESS_SHA},
      checks:{
        sourceLength:old.length,
        sourceOrder:old.every((x,i)=>i===0||old[i-1]<x),
        distinctNewMarks:disjoint,
        fourFive:{pass:strict.pass,quadruplesTested:strict.tested,firstFailedIndices:strict.failedIndices||null},
        weakSidon:{pass:weak.pass,orderedComparisonCount:weak.checked,firstFailedIndices:weak.failedIndices||null},
        oldExactMaximum:{pass:original.status==="FINITE_CHECK_PASSED",states:original.proof?.states??null},
        explicitSidon19:{pass:subset.pass,distinctPairSums:subset.pairSums??null},
        threeNewInArithmeticProgression:progression,
        upperBoundReason:"At most 17 original marks plus at most two of the three new marks (one AP)."
      },
      statusGate:"Same-package browser arithmetic is a reproducible finite test. Independent Python replay and mathematical novelty review are separate gates."
    });
  }
  return Object.freeze({check,WITNESS_SHA});
});
