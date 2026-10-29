/* Browser-only exact research replay. No remote input, registry mutation or status promotion. */
"use strict";
(function(){
 const C=globalThis.RefereeCore,S=globalThis.NightfallSidonSharpness;
 const $=id=>document.getElementById(id);
 if(!C||!S||!$("sharpness-run"))return;
 const button=$("sharpness-export"),out=$("sharpness-output");
 let latest=null;
 async function sha(text){
  if(!globalThis.crypto?.subtle)throw Error("Secure-browser SHA-256 unavailable.");
  const bytes=new TextEncoder().encode(text);
  const raw=await crypto.subtle.digest("SHA-256",bytes);
  return Array.from(new Uint8Array(raw),v=>v.toString(16).padStart(2,"0")).join("");
 }
 async function run(){
  latest=null;button.disabled=true;
  out.textContent="Recomputing the exact four-point conditions and B30 exclusion…";
  try{
   const v=S.check(C,$("sharpness-spacing").value,$("sharpness-offset").value);
   const sourceHash=await sha(C.SIDON_WITNESS.join(",")+"\n");
   const hashOk=sourceHash===S.WITNESS_SHA;
   const receipt={...v,sourceSha256:sourceHash,sourceMatchesFrozen:hashOk,
      verdict:hashOk?v.verdict:"REJECTED_SOURCE_MISMATCH",
      independentReplay:"https://github.com/d3lefts/d3lefts/pull/72",
      externalReview:"PENDING"};
   const checks=receipt.checks;
   out.textContent=
      "VERDICT / "+receipt.verdict+"\n"+
      "B30 exact maximum: "+(checks.oldExactMaximum.pass?"17 / verified in-browser":"UNCONFIRMED")+"\n"+
      "Frozen original SHA-256: "+(hashOk?"MATCH":"FAIL")+"\n"+
      "(4,5) four-point condition: "+(checks.fourFive.pass?"PASS":"FAIL")+
        " / "+checks.fourFive.quadruplesTested+" of 40,920 checked\n"+
      "Weak Sidon: "+(checks.weakSidon.pass?"PASS":"FAIL")+"\n"+
      "Explicit 19-mark Sidon subset: "+(checks.explicitSidon19.pass?"PASS":"FAIL")+
        " / "+(checks.explicitSidon19.distinctPairSums??"—")+" unique pair sums\n"+
      "Three added marks form an AP: "+(checks.threeNewInArithmeticProgression?"YES":"NO")+"\n"+
      "New marks: "+receipt.data.newPoints.join(", ")+"\n\n"+
      (receipt.verdict==="FINITE_EXAMPLE_CHECK_PASSED"?
        "Exact conclusion: h(B ∪ X) = 19. Three new marks form one AP, so at most two can enter any Sidon subset; B has h(B)=17. The explicit 19-set attains the upper bound.":
        "No theorem was certified for these selected integers. Inspect the failed condition; restore the frozen example to reproduce the 33-point claim.")+
      "\n\nIndependent Python replay and external mathematical review are separate gates.";
   latest=receipt;button.disabled=false;
  }catch(e){out.textContent="NO CERTIFICATE / "+String(e.message||e)}
 }
 $("sharpness-run").addEventListener("click",run);
 $("sharpness-reset").addEventListener("click",()=>{
   $("sharpness-spacing").value="40000000";$("sharpness-offset").value="1";
   out.textContent="Frozen demonstration ready. Run the exact replay.";latest=null;button.disabled=true;
 });
 button.addEventListener("click",()=>{
   if(!latest)return;
   const bytes=JSON.stringify(latest,null,2)+"\n",url=URL.createObjectURL(new Blob([bytes],{type:"application/json"}));
   const a=document.createElement("a");a.href=url;a.download="NIGHTFALL_SIDON_SHARPNESS_RECEIPT.json";
   document.body.appendChild(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),3000);
 });
})();
