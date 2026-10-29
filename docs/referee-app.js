"use strict";
(function(){
const C=window.RefereeCore;
const $=id=>document.getElementById(id);
const E=s=>String(s??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
const tokens=s=>String(s).trim().split(/[\s,;]+/).filter(Boolean);
let tab="overlap",latest=null;
const repo="https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sidon-finite-30/witness_30.txt";
function setTab(t){tab=t;["overlap","sidon"].forEach(x=>{$("tab-"+x).setAttribute("aria-selected",String(x===t));$("pane-"+x).hidden=x!==t});$("result").innerHTML='<div class="idle"><span class="idle-icon">⌁</span><h3>Awaiting a witness.</h3><p>Run the selected domain verifier to produce a scoped evidence report.</p></div>';latest=null;$("export-receipt").disabled=true;}
function overlapInput(){return{denominator:$("overlap-den").value.trim(),heights:tokens($("overlap-heights").value)}}
function sidonInput(){return{points:tokens($("sidon-points").value),subset:tokens($("sidon-subset").value)}}
function resetOverlap(){$("overlap-den").value=C.OVERLAP_DEMO.denominator;$("overlap-heights").value=C.OVERLAP_DEMO.heights.join(", ");$("overlap-claimed").value="";setTab("overlap")}
function resetSidon(){$("sidon-points").value=C.SIDON_WITNESS.join(", ");$("sidon-subset").value=C.SIDON_SUBSET.join(", ");$("sidon-max").value="17";setTab("sidon")}
async function hashInput(x){const b=new TextEncoder().encode(JSON.stringify(x));if(!crypto?.subtle?.digest)return null;const d=await crypto.subtle.digest("SHA-256",b);return Array.from(new Uint8Array(d),x=>x.toString(16).padStart(2,"0")).join("")}
function checkline(ok,label,detail){const cls=ok===true?"":ok===false?" no":" warn";const sym=ok===true?"✓":ok===false?"×":"?";return '<div class="checkline'+cls+'"><span>'+sym+'</span><div><strong>'+E(label)+'</strong><br>'+E(detail)+'</div></div>'}
function metr(label,value){return '<div class="result-metric"><span>'+E(label)+'</span><strong>'+E(value)+'</strong></div>'}
function chart(shifts){const n=shifts.length,nums=shifts.map(x=>Number(x.numerator)),mx=Math.max(...nums,1);const W=990,H=110,barW=Math.max(.7,W/n*.65),bars=shifts.map((r,i)=>{const h=Math.max(0,nums[i]/mx*83);const x=4+i*(W-8)/n;return '<rect x="'+x.toFixed(2)+'" y="'+(96-h).toFixed(2)+'" width="'+barW.toFixed(2)+'" height="'+h.toFixed(2)+'" rx=".4" fill="'+(nums[i]===mx?'#d9ff5e':'#70957b')+'"/>'}).join("");const mid=4+Math.floor(n/2)*(W-8)/n;return '<div class="shiftchart"><header><span>SIGNED-LAG SCAN / VISUAL ONLY</span><span>'+E(n)+' exact lags</span></header><svg viewBox="0 0 990 110" role="img" aria-label="Approximate visual histogram of exact signed-lag overlap numerators"><path d="M4 96H986" stroke="#5b785f"/><path d="M'+mid.toFixed(1)+' 0V100" stroke="#446448" stroke-dasharray="4 5"/>'+bars+'</svg></div>'}
function statusBlock(positive,title,description,warning=false){return '<div class="result-head"><div><span class="micro">EXACT CHECK / REPORT</span><h3>'+E(title)+'</h3><p>'+E(description)+'</p></div><div class="verdict '+(positive?"":warning?"warn":"fail")+'">'+E(positive?"FINITE CHECK PASSED":warning?"INCONCLUSIVE":"REJECTED")+'</div></div>'}
async function runOverlap(){
const source=overlapInput(),claim=$("overlap-claimed").value.trim()||null;
showBusy();
try{
 const result=C.checkOverlap(source,claim);
 const attacks=C.overlapAttacks(source,result);
 const digest=await hashInput({domain:"continuous-step-overlap",input:source,claimedScore:claim});
 const ok=result.status==="FINITE_CHECK_PASSED"&&result.dualPathAgreement&&attacks.scoreTamperRejected&&attacks.massPreservingWitnessMutation.rejected===true;
 const claimed=result.claimMatches===null?"Computed without a supplied score":result.claimMatches?"Claimed fraction matches":"Claimed fraction rejected";
 const report={format:"nightfall-referee-receipt-v1",verifier:"NIGHTFALL Referee",version:C.VERSION,createdAt:new Date().toISOString(),domain:"continuous-step-overlap",source,claimedScore:claim,inputSha256:digest,verdict:ok?"FINITE_CHECK_PASSED":result.status==="REJECT"?"REJECTED":"INCONCLUSIVE",result,negativeControls:attacks,notes:["Same-page arithmetic implementations are independent code paths, not independent external reviewers.","Exact finite uniform-step and signed-lag scope only; does not verify the archived 131072-cell witness.","Graph bars are approximate visualization only. All verdicts derive from exact BigInt."]};
 latest=report;$("export-receipt").disabled=false;
 const score=C.formatOverlap(result);
 const title=result.status==="REJECT"?"Claimed score rejected.":ok?"Finite witness survives.":"Local evidence remains open.";
 const desc="Exact maximum "+score+" · maximizing signed lag"+(result.summary.maxLags.length===1?" ":"s ")+result.summary.maxLags.join(", ")+". "+claimed+".";
 let html=statusBlock(ok,title,desc,result.status!=="REJECT"&&!ok);
 html+='<div class="result-metrics">'+metr("EXACT MAXIMUM",score)+metr("CELLS",result.cellCount)+metr("MAX LAG",result.summary.maxLags.join(", "))+metr("DUAL PATHS",result.dualPathAgreement?"AGREE":"DISAGREE")+'</div>';
 html+='<div class="verification-lists"><div class="verification-list"><h4>RECOMPUTATION / A × B</h4>'+checkline(true,"Exact mass normalization","2ΣAᵢ = nD; cell heights within bounds")+checkline(result.dualPathAgreement,"All signed shifts","Direct-lag sum matches pair-difference accumulation")+checkline(result.claimMatches!==false,"Expected score",claimed)+'</div><div class="verification-list"><h4>ADVERSARIAL NEGATIVE CONTROLS</h4>'+checkline(attacks.scoreTamperRejected,"Tampered score","A deliberately incorrect fraction was rejected")+checkline(attacks.massPreservingWitnessMutation.rejected===true,"Mass-preserving mutation",attacks.massPreservingWitnessMutation.rejected?"One-unit transfer changed exact score; original pinned claim rejected":"No distinguishing one-unit transfer found; unresolved")+'</div></div>';
 html+=chart(result.shifts)+digestLine(digest);
 $("result").innerHTML=html;
}catch(err){showError(err)}
}
async function runSidon(){
const source=sidonInput(),raw=$("sidon-max").value.trim();
showBusy();
try{
 if(!/^\d+$/.test(raw))throw Error("Claimed maximum must be an integer");const claimed=Number(raw);if(!Number.isSafeInteger(claimed))throw Error("Claimed maximum outside safe integer range");
 const result=C.checkSidon(source,claimed);
 const attacks=C.sidonAttacks(source,claimed);
 const digest=await hashInput({domain:"weak-sidon-4-5-finite",input:source,claimedMaximum:claimed});
 const ok=result.status==="FINITE_CHECK_PASSED"&&attacks.understatedMaximumRejected&&attacks.corruptedSubsetRejected;
 const report={format:"nightfall-referee-receipt-v1",verifier:"NIGHTFALL Referee",version:C.VERSION,createdAt:new Date().toISOString(),domain:"weak-sidon-4-5-finite",source,claimedMaximum:claimed,inputSha256:digest,verdict:ok?"FINITE_CHECK_PASSED":"REJECTED_OR_INCONCLUSIVE",result,negativeControls:attacks,sourceDossier:"https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sidon-finite-30/README.md",notes:["Exact finite scope only; no asymptotic bound, priority, or external human validation implied.","Two weak-Sidon formulations and an AP-based exclusion proof run in one browser implementation package.","Search cap yields INCONCLUSIVE, never a proof."]};
 latest=report;$("export-receipt").disabled=false;
 const proof=result.proof||{},title=ok?"Finite Sidon bound survives.":"Finite Sidon claim remains open.";
 const desc=result.cellCount+" points · claimed maximum "+claimed+" · explicit subset size "+result.subsetSize+".";
 let html=statusBlock(ok,title,desc,!ok&&proof.status==="INCONCLUSIVE");
 html+='<div class="result-metrics">'+metr("SUBSET h(B)",result.subsetSize)+metr("WEAK 4-POINT TESTS",result.weakSidonA.tested)+metr("ARITHMETIC PROGRESSIONS",proof.arithmeticProgressions??"—")+metr("PROOF STATES",proof.states??"—")+'</div>';
 html+='<div class="verification-lists"><div class="verification-list"><h4>FINITE CERTIFICATE CHECKS</h4>'+checkline(result.weakSidonA.pass&&result.weakSidonB.pass,"Weak Sidon admissibility","Difference-based A and four-distinct sum-based B checks")+checkline(result.subset.pass,"Explicit Sidon subset",result.subset.pairSums+" distinct unordered pair sums")+checkline(proof.status==="PROVED"&&result.subsetSize===claimed,"Exclusion search",proof.status==="PROVED"?"No Sidon subset of size "+proof.target+"; "+proof.states+" memoized states":(proof.reason||"Exclusion proof unavailable"))+'</div><div class="verification-list"><h4>ADVERSARIAL NEGATIVE CONTROLS</h4>'+checkline(attacks.understatedMaximumRejected,"Understated bound","An upper bound below the explicit witness was rejected")+checkline(attacks.corruptedSubsetRejected,"Corrupted subset","Foreign coordinate was rejected as invalid input")+checkline(result.weakSidonA.pass===result.weakSidonB.pass,"Two formulations","Four-point arithmetic formulations agree")+'</div></div>'+digestLine(digest);
 $("result").innerHTML=html;
}catch(err){showError(err)}
}
function digestLine(d){return '<p class="digest">INPUT SHA-256 · <strong>'+E(d||"UNAVAILABLE — secure browser context required")+'</strong><br>Evidence scope: exact finite in-browser checks; independent external review and proof of global claims remain open.</p>'}
function showBusy(){$("result").innerHTML='<div class="idle"><span class="idle-icon">⌁</span><h3>Running exact arithmetic…</h3><p>Evaluating the finite witness and its deterministic negative controls.</p></div>'}
function showError(e){latest=null;$("export-receipt").disabled=true;$("result").innerHTML='<div class="result-head"><h3>Input rejected.</h3><div class="verdict fail">NO CERTIFICATE</div></div><div class="error-result">'+E(e.message||String(e))+'</div>'}
function exportReceipt(){if(!latest)return;const content=JSON.stringify(latest,null,2)+"\n",blob=new Blob([content],{type:"application/json"}),url=URL.createObjectURL(blob),a=document.createElement("a");a.href=url;a.download="NIGHTFALL_REFEREE_"+latest.domain+"_"+new Date().toISOString().slice(0,10)+".json";document.body.appendChild(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),3000)}
$("tab-overlap").addEventListener("click",()=>setTab("overlap"));$("tab-sidon").addEventListener("click",()=>setTab("sidon"));
$("reset-overlap").addEventListener("click",resetOverlap);$("reset-sidon").addEventListener("click",resetSidon);
$("run-overlap").addEventListener("click",runOverlap);$("run-sidon").addEventListener("click",runSidon);
$("pin-overlap").addEventListener("click",()=>{try{$("overlap-claimed").value=C.formatOverlap(C.checkOverlap(overlapInput()));}catch(e){showError(e)}});
$("sidon-source").addEventListener("click",()=>window.open(repo,"_blank","noopener,noreferrer"));
$("export-receipt").addEventListener("click",exportReceipt);
$("overlap-heights").value=C.OVERLAP_DEMO.heights.join(", ");$("sidon-points").value=C.SIDON_WITNESS.join(", ");$("sidon-subset").value=C.SIDON_SUBSET.join(", ");
// Explicit, allowlisted deep-link for an inspectable source-to-verifier journey.
const requestedDomain = new URLSearchParams(window.location.search).get("domain");
if (requestedDomain === "sidon") setTab("sidon");
$("app-version").textContent="ENGINE V"+C.VERSION+" · BROWSER-LOCAL";
if(new URLSearchParams(location.search).get("domain")==="sidon")setTab("sidon");
})();
