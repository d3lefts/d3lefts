"use strict";
/* Living Paper 002.
 * A 16-cell exact educational model is strictly separated from the frozen
 * 131,072-cell research witness. No remote calls or status promotion. */
(()=>{
 const core=window.ErdosPaperCore, referee=window.RefereeCore, registry=window.NightfallRegistry;
 const $=id=>document.getElementById(id);
 if(!core||!referee){$("ep-output").textContent="Exact local modules unavailable. The published command-line checker remains accessible.";return;}
 const FULL_SHA="a574c280f8839503c90076507a27f4c819455fb2512fae6a43b6a17f6a784b8e";
 const FULL_SCORE="34788888032212764146872525963225147703298526879/91343852333181432387730302044767688728495783936";
 let a=core.FIXTURE.slice(),lag=0,lastAudit=null;
 const denom=BigInt(core.N*core.D*core.D);
 const svgNS="http://www.w3.org/2000/svg";
 const makeBars=(id,values)=>{
  const frag=document.createDocumentFragment();
  values.forEach(v=>{
   const el=document.createElement("span");
   const n=Math.max(0,Math.min(1,v));
   el.style.height=(100*n).toFixed(3)+"%";
   frag.append(el);
  });
  $(id).replaceChildren(frag);
 };
 function flagLatestStale(){lastAudit=null;$("ep-export").disabled=true}
 function show(){
  const p=core.profile(a),q=p.points[lag+core.N-1];
  const g=a.map((_,i)=>{const j=i-lag;return j>=0&&j<core.N?core.D-a[j]:0});
  makeBars("ep-f",a.map(v=>v/core.D));
  makeBars("ep-g",g.map(v=>v/core.D));
  makeBars("ep-product",a.map((v,i)=>(v*g[i])/(core.D*core.D)));
  $("ep-lag").value=String(lag);
  $("ep-lag-value").textContent="k = "+(lag>0?"+":"")+lag+" · s = "+(2*lag)+"/16";
  $("ep-selected").textContent=core.decimal(2n*q.raw,denom,9);
  $("ep-maximum").textContent=core.decimal(p.numerator,p.denominator,9);
  $("ep-winner").textContent="max at k = "+p.winners.join(", ");
  // All SVG data are generated from integer values in the frozen small fixture.
  const xy=(item,index)=>[22+index*22.5,200-Number(item.raw)/300*160];
  const path=p.points.map((item,i)=>{const [x,y]=xy(item,i);return (i===0?"M":"L")+x.toFixed(2)+" "+y.toFixed(2)}).join(" ");
  const [sx,sy]=xy(q,lag+core.N-1);
  const maxCircles=p.points.filter(t=>t.raw===p.maxRaw).map(t=>{
   const [x,y]=xy(t,t.lag+core.N-1);return '<circle cx="'+x.toFixed(2)+'" cy="'+y.toFixed(2)+'" r="6" fill="#274d2c" stroke="#b9dca0" stroke-width="2"/>';
  }).join("");
  $("ep-curve").innerHTML='<line x1="20" y1="200" x2="704" y2="200" stroke="#a7bba3"/>'+
   '<line x1="20" y1="40" x2="704" y2="40" stroke="#cbd9c8" stroke-dasharray="4 6"/>'+
   '<path d="'+path+'" fill="none" stroke="#51795b" stroke-width="3"/>'+
   '<line x1="'+sx.toFixed(2)+'" x2="'+sx.toFixed(2)+'" y1="36" y2="201" stroke="#829d6b" stroke-dasharray="4 5"/>'+
   maxCircles+'<circle cx="'+sx.toFixed(2)+'" cy="'+sy.toFixed(2)+'" r="5" fill="#d6ec71" stroke="#1c3f28" stroke-width="2"/>'+
   '<text x="18" y="218" font-size="11" fill="#48654e">−15</text><text x="352" y="218" font-size="11" fill="#48654e">0</text><text x="678" y="218" font-size="11" fill="#48654e">+15</text>';
  const rawSum=a.reduce((s,x)=>s+x,0);
  $("ep-message").textContent="Exact mass Σ Aᵢ = "+rawSum+"; integral = 2ΣAᵢ/(16×8) = 1. This 16-cell score is not the full witness bound.";
 }
 function message(text){$("ep-message").textContent=text}
 function check(){
  try{
   const model=core.audit(a);
   const result=referee.checkOverlap({heights:a.map(String),denominator:String(core.D)});
   const left=BigInt(result.summary.score.numerator)*BigInt(model.maximumDenominator);
   const right=BigInt(result.summary.score.denominator)*BigInt(model.maximumNumerator);
   if(left!==right||result.dualPathAgreement!==true||JSON.stringify(result.summary.maxLags)!==JSON.stringify(model.winningLags))
    throw Error("Referee and independent geometric maximum disagree");
   const attacks=referee.overlapAttacks({heights:a.map(String),denominator:String(core.D)},result);
   if(!attacks.scoreTamperRejected)throw Error("Mutated claimed score was accepted");
   let invalidMassRejected=false;
   try{core.audit(a.map((v,i)=>i===0?v+1:v))}catch(_){invalidMassRejected=true}
   if(!invalidMassRejected)throw Error("Malformed-mass negative control was accepted");
   lastAudit={status:"LOCAL_EXACT_EXERCISE_PASSED",timestamp:new Date().toISOString(),fixture:a.slice(),
    eventShifts:model.shifts,rectangleIntersectionShifts:model.rectangleIntersections,
    exactMaximumNumerator:model.maximumNumerator,exactMaximumDenominator:model.maximumDenominator,
    maximizingLags:model.winningLags,refereeDualPathAgreement:result.dualPathAgreement,
    alteredScoreRejected:attacks.scoreTamperRejected,invalidMassRejected,
    scope:model.scope,independentExternalReview:false};
   $("ep-output").textContent="LOCAL EXACT EXERCISE PASSED\nMass: 1 (exact integer normalization)\nGrid-shift correlations: 31 / 31\nIndependent rectangle geometry: 61 / 61 integer and half shifts\nDual arithmetic paths: PASS\nTampered score: REJECTED\nMass-violating input: REJECTED\nExact maximum: "+model.maximumNumerator+"/"+model.maximumDenominator+"\nMaximizing k: "+model.winningLags.join(", ")+"\n131072-cell archival witness: NOT REPLAYED HERE\nExternal mathematical review: OPEN";
   $("ep-export").disabled=false;
  }catch(e){
   flagLatestStale();$("ep-output").textContent="LOCAL CHECK INCONCLUSIVE / FAILED CLOSED\n"+String(e.message||e);
  }
 }
 function exportReceipt(){
  if(lastAudit?.status!=="LOCAL_EXACT_EXERCISE_PASSED")return;
  const receipt={schema:"nightfall-erdos-living-paper-local-exercise-v1",problem:"Erdos minimum overlap",
   research_witness_verified:false,research_witness_file_hash_verified:false,
   fixture_is_research_witness:false,checker_version:core.VERSION,
   public_research_witness_sha256_expected:FULL_SHA,local_result:lastAudit};
  const blob=new Blob([JSON.stringify(receipt,null,2)+"\n"],{type:"application/json"});
  const url=URL.createObjectURL(blob),link=document.createElement("a");
  link.href=url;link.download="nightfall_erdos_16cell_local_exercise.json";
  document.body.append(link);link.click();link.remove();
  setTimeout(()=>URL.revokeObjectURL(url),1000);
 }
 function saveSelects(){
  ["ep-from","ep-to"].forEach((id,i)=>{
   const select=$(id),frag=document.createDocumentFragment();
   a.forEach((height,j)=>{
    const opt=document.createElement("option");
    opt.value=String(j);opt.textContent=""+(j+1).toString().padStart(2,"0")+" · "+height+"/8";
    frag.append(opt);
   });
   const old=select.value;select.replaceChildren(frag);
   select.value=(old!==""&&Number.isInteger(Number(old))&&Number(old)>=0&&Number(old)<16)?old:(i===0?"1":"10");
  });
 }
 async function verifyFile(){
  const file=$("ep-file").files?.[0];if(!file){$("ep-hash-output").textContent="Select a witness file first.";return;}
  const btn=$("ep-hash-button");btn.disabled=true;
  $("ep-hash-output").textContent="Computing SHA-256 locally…";
  try{
   if(!window.crypto?.subtle)throw Error("Secure-context Web Crypto unavailable");
   const bytes=await file.arrayBuffer(),hash=await window.crypto.subtle.digest("SHA-256",bytes);
   const got=Array.from(new Uint8Array(hash),x=>x.toString(16).padStart(2,"0")).join("");
   if(got===FULL_SHA){
    $("ep-hash-output").textContent="BYTE IDENTITY MATCH · SHA-256 "+got+"\nThe provided bytes match the published file identity. No numerical overlap arithmetic was performed.";
   }else{
    $("ep-hash-output").textContent="BYTE IDENTITY MISMATCH · SHA-256 "+got+"\nExpected "+FULL_SHA+". The file was not accepted as the frozen witness.";
   }
  }catch(e){$("ep-hash-output").textContent="CHECK UNAVAILABLE / "+String(e.message||e)}
  finally{btn.disabled=false}
 }
 const file=$("ep-file");
 file.addEventListener("change",()=>{
  $("ep-hash-button").disabled=!(file.files?.length);
  $("ep-hash-output").textContent="File selected. Choose Verify to compute a local SHA-256; no bytes leave this device.";
 });
 $("ep-hash-button").addEventListener("click",verifyFile);
 $("ep-lag").addEventListener("input",()=>{lag=Number($("ep-lag").value);show()});
 $("ep-transfer").addEventListener("click",()=>{
  try{
   a=core.transfer(a,Number($("ep-from").value),Number($("ep-to").value));
   flagLatestStale();saveSelects();show();
   $("ep-output").textContent="Fixture changed. Previous check invalidated; run a fresh exact audit.";
  }catch(e){message("TRANSFER REJECTED: "+String(e.message||e)+". No heights changed.")}
 });
 $("ep-reset").addEventListener("click",()=>{a=core.FIXTURE.slice();lag=0;flagLatestStale();saveSelects();show();$("ep-output").textContent="Original 16-cell educational fixture restored. No current audit."});
 $("ep-audit").addEventListener("click",check);
 $("ep-export").addEventListener("click",exportReceipt);
 saveSelects();show();
 // Explicit, immutable cross-check against published local manifest data.
 const manifest=registry?.claimById?.("erdos36");
 if(!manifest||!manifest.conditions.includes("2^70")||FULL_SCORE.length<100){
  $("ep-output").textContent="RESEARCH METADATA UNAVAILABLE / Site registry source invariant failed; inspect the public manifest.";
 }
})();
