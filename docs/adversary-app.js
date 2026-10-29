"use strict";
(function(){
const C=window.ImaginaryAdversaryCore,$=id=>document.getElementById(id);
const esc=s=>String(s??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
let latest=null;
$("engine-version").textContent="ENGINE "+C.VERSION+" · BROWSER-LOCAL";
const domainInput=$("domain"),result=$("result");
function switchDomain(){
 const d=domainInput.value;
 ["sidon","overlap","general"].forEach(x=>$(x+"-fields").hidden=x!==d);
 $("referee-link").href="referee.html?domain="+(d==="overlap"?"overlap":"sidon")+"#workbench";
 $("send-to-referee").disabled=d==="general";
 $("export-attack").disabled=true;$("copy-brief").disabled=true;latest=null;
 result.innerHTML='<span>ATTACK CONTRACT READY</span><h3>Run the bounded falsifier.</h3><p>Claims of universal reach stay open after finite checks.</p>';
}
function inputs(){
 return{domain:domainInput.value,reach:$("reach").value,statement:$("statement").value,
 assumptions:$("assumptions").value,source:$("source").value,baseline:$("baseline").value,
 property:$("property").value,points:$("points").value,
 denominator:$("denominator").value,heights:$("heights").value,claimedUpper:$("claimed-upper").value};
}
function details(data){
 const p=data.probe;if(!p)return'<article><small>REVIEW LIMIT</small><strong>No executable finite falsifier selected</strong><p>The proposed attack questions are advisory prompts.</p></article>';
 if(p.domain==="sidon")return'<article><small>FINITE PREDICATE</small><strong>'+esc(p.property)+'</strong><p>'+esc(p.pointCount)+' marks; '+esc(p.tested)+' enumerated units of the selected test.</p></article>'+
 '<article><small>COUNTEREXAMPLE</small><strong>'+(p.counterexample?"FOUND":"NONE IN THIS INSTANCE")+'</strong><pre>'+esc(p.counterexample?JSON.stringify(p.counterexample,null,2):"No counterexample in the supplied set.")+'</pre></article>';
 return'<article><small>EXACT SIGNED-LAG MAXIMUM</small><strong>'+esc(p.exactMaximum)+'</strong><p>Maximizing lag(s): '+esc(p.maximizingLags.join(", "))+(p.suppliedUpper?'; supplied upper bound '+esc(p.suppliedUpper):'')+'.</p></article>'+
 '<article><small>FINITE PERTURBATION ATTACK</small><strong>'+esc(p.neighbor.movesTested)+' legal transfers tested</strong><p>'+(p.neighbor.best?'Strict improvement:':'No strict improvement found among tested transfers.')+'</p><pre>'+esc(p.neighbor.best?JSON.stringify(p.neighbor.best,null,2):"Local probe has no global-optimality consequence.")+'</pre></article>';
}
function render(data){
 const status=data.status,failed=status==="COUNTEREXAMPLE_FOUND",q=data.contract.questions;
 let html='<span class="'+(failed?"bad":"good")+'">LOCAL STATUS / '+esc(status)+'</span><h3>'+(failed?"A finite claim has been falsified.":status==="INCONCLUSIVE"?"A proof challenge, awaiting evidence.":"No refutation within the tested scope.")+'</h3><p>'+esc(data.interpretation)+'</p>';
 html+='<div class="ia-result-grid">'+details(data)+'</div>';
 if(data.contract.omissions.length)html+='<h3>Missing defenses</h3><ol class="ia-questions">'+data.contract.omissions.map(o=>'<li>'+esc(o)+'</li>').join("")+'</ol>';
 html+='<h3>Questions a critic should ask</h3><ol class="ia-questions">'+q.map(o=>'<li><b>'+esc(o.lane.toUpperCase())+'</b>'+esc(o.question)+'</li>').join("")+'</ol>';
 html+='<p><strong>Scope:</strong> '+esc(data.probe?.checkedScope||data.trustBoundary)+'</p>';
 result.innerHTML=html;
}
async function fingerprint(x){
 if(!(window.crypto&&window.crypto.subtle))return null;
 const b=new TextEncoder().encode(JSON.stringify(x));
 const digest=await window.crypto.subtle.digest("SHA-256",b);
 return [...new Uint8Array(digest)].map(x=>x.toString(16).padStart(2,"0")).join("");
}
async function run(){
 const source=inputs();
 $("run-attack").disabled=true;
 try{
  const data=C.attack(source);
  const inputSha256=await fingerprint(source);
  latest={...data,source,createdAt:new Date().toISOString(),inputSha256,
   sourceNote:"Local browser input fingerprint only, not a signed research certificate."};
  render(data);$("export-attack").disabled=false;$("copy-brief").disabled=false;
 }catch(e){
  latest=null;$("export-attack").disabled=true;$("copy-brief").disabled=true;
  result.innerHTML='<span class="bad">INVALID INPUT</span><h3>The proposed attack cannot run.</h3><p>'+esc(e.message)+'</p>';
 }finally{$("run-attack").disabled=false}
}
function fixture(){
 const d=domainInput.value;
 if(d==="sidon"){
  $("property").value="four-five";$("points").value="1, 2, 3, 5";
  $("statement").value="Every four-point subset has five distinct pairwise distances.";
  $("assumptions").value="Exactly four distinct integer coordinates; (4,5) means at least five distinct absolute differences.";
 }else if(d==="overlap"){
  $("denominator").value="2";$("heights").value="1, 1";$("claimed-upper").value="0";
  $("statement").value="The exact continuous signed-shift overlap maximum is at most zero.";
  $("assumptions").value="Two equal-width cells on [0,2], rational heights with unit mass.";
 }else{
  $("reach").value="universal";$("statement").value="The finite result implies an unrestricted theorem.";
  $("assumptions").value="";
 }
 result.innerHTML='<span>DELIBERATE NEGATIVE CONTROL LOADED</span><h3>Run the attack to check this false claim.</h3><p>No claim has been checked yet.</p>';
 latest=null;$("export-attack").disabled=true;$("copy-brief").disabled=true;
}
function exportJSON(){
 if(!latest)return;
 const blob=new Blob([JSON.stringify(latest,null,2)+"\n"],{type:"application/json"});
 const url=URL.createObjectURL(blob),a=document.createElement("a");
 a.href=url;a.download="nightfall-imaginary-adversary-v1.json";document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),1000);
}
function brief(){
 if(!latest)return"";
 const r=latest;
 return["NIGHTFALL / IMAGINARY ADVERSARY · UNREVIEWED ATTACK BRIEF",
  "Claim: "+r.contract.statement,
  "Scope: "+r.contract.reach+" / "+r.contract.domain,
  "Assumptions: "+r.contract.assumptions,"Evidence: "+r.contract.source,"Closest baseline: "+r.contract.baseline,
  "Local status: "+r.status,
  "Exact bounded probe: "+JSON.stringify(r.probe),
  "Unresolved defenses: "+r.contract.omissions.join(" | "),
  "Independent attack questions:",...r.contract.questions.map(x=>"- "+x.lane+": "+x.question),
  "Input fingerprint: "+(r.inputSha256||"unavailable"),
  "LIMIT: finite local test; independent proof/priority/publication review outstanding."].join("\n");
}
domainInput.addEventListener("change",switchDomain);
$("run-attack").addEventListener("click",run);
$("load-fixture").addEventListener("click",fixture);
$("export-attack").addEventListener("click",exportJSON);
$("copy-brief").addEventListener("click",async()=>{
 try{
  await navigator.clipboard.writeText(brief());
  const b=$("copy-brief");b.textContent="Brief copied ✓";setTimeout(()=>b.textContent="Copy adversarial brief",1800);
 }catch(e){$("result").insertAdjacentHTML("beforeend",'<p>Clipboard unavailable. Export the JSON receipt and copy from the saved record.</p>');}
});

const Companion=window.NightfallCompanionHandoff;
$("send-to-referee").addEventListener("click",()=>{
 const note=$("handoff-note");
 try{
  const source=inputs();
  if(source.domain==="general")throw Error("The general proof planner has no compatible finite Referee model.");
  if(source.domain==="sidon"&&source.property!=="four-five")throw Error("Referee tests the (4,5) property plus h(B), not the selected weak/classical Sidon predicate. Keep this attack as its own JSON brief.");
  const input=source.domain==="sidon"?{points:source.points}:{denominator:source.denominator,heights:source.heights,claimedUpper:source.claimedUpper};
  const packet=Companion.build("adversary","referee",source.domain,input);
  sessionStorage.setItem(Companion.KEY,JSON.stringify(packet));
  location.assign("referee.html?domain="+source.domain+"&companion_handoff=1#workbench");
 }catch(e){note.hidden=false;note.textContent="COMPANION TRANSFER REFUSED: "+e.message;}
});
const query=new URLSearchParams(location.search);
if(["sidon","overlap","general"].includes(query.get("domain")))domainInput.value=query.get("domain");
switchDomain();
if(query.get("companion_handoff")==="1"){
 const note=$("handoff-note");
 try{
  const raw=sessionStorage.getItem(Companion.KEY);sessionStorage.removeItem(Companion.KEY);
  const packet=Companion.parse(raw,"adversary");
  domainInput.value=packet.domain;switchDomain();
  $("reach").value="finite";
  $("source").value="Referee editor input (unverified transfer)";
  $("baseline").value="";
  if(packet.domain==="sidon"){
   $("property").value="four-five";$("points").value=packet.input.points.join(", ");
   $("statement").value="Every four-point subset of these exact marks has at least five distinct pairwise distances.";
   $("assumptions").value="Finite (4,5) predicate on these supplied distinct integer marks; does not assert h(B) or global optimality.";
  }else{
   $("denominator").value=packet.input.denominator;
   $("heights").value=packet.input.heights.join(", ");
   $("claimed-upper").value=packet.input.claimedUpper;
   $("statement").value=packet.input.claimedUpper
    ?"The exact continuous signed-shift maximum of the supplied rational step function is at most "+packet.input.claimedUpper+"."
    :"Compute the exact continuous maximum of the supplied rational step function and test legal one-unit mass-preserving improvements.";
   $("assumptions").value="Finite equal-width cells on [0,2] with exact unit mass; one-unit perturbations are a bounded local search.";
  }
  note.hidden=false;
  note.textContent="INPUT ONLY · UNREVIEWED · Referee editor inputs were transferred for a distinct adversarial attack. No Referee arithmetic verdict, negative-control result or proof status was imported. Click Run Devil's Advocate.";
 }catch(e){note.hidden=false;note.textContent="COMPANION IMPORT REFUSED: "+e.message;}
 history.replaceState(null,"",location.pathname+(location.hash||""));
}
})();
