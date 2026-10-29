"use strict";
/* Source-bound investigation intake, on the same Join page as the frozen Frontier tasks.
 * Never treats a local note as a verified result or hands invented proof payloads to tools. */
(()=>{
 const R=window.NightfallRegistry,C=window.NFClaimJourney,$=id=>document.getElementById(id);
 if(!R||!C){$("cj-empty").textContent="The canonical claim registry is unavailable. Open a Proof Passport to inspect source evidence.";return}
 const parsed=C.parse(R,location.search);
 const rememberFocus=contract=>{
  try{localStorage.setItem("nightfall.active.case.v1",JSON.stringify({
   version:1,kind:"claim",id:contract.claim.id,index:contract.index,at:new Date().toISOString()
  }));}catch{}
  window.dispatchEvent(new Event("nightfall:case-changed"));
 };
 function read(){
  try{return C.sanitize(R,JSON.parse(localStorage.getItem(C.KEY)||"null"))}catch{return C.sanitize(R,null)}
 }
 let state=read(),selected=null,dirty=false;
 const saveState=()=>{
  try{localStorage.setItem(C.KEY,JSON.stringify(state));return true}
  catch{return false}
 };
 const link=(label,url)=>{
  const a=document.createElement("a");a.textContent=label+" ↗";a.href=url;
  if(url.startsWith("https:")){a.target="_blank";a.rel="noopener"}
  return a;
 };
 const selectClaim=$("cj-claim"),selectDuty=$("cj-obligation");
 const showInvalid=text=>{$("cj-invalid").hidden=!text;$("cj-invalid").textContent=text||""};
 R.claims.filter(c=>Array.isArray(c.open)&&c.open.length).forEach(claim=>{
  const option=document.createElement("option");
  option.value=claim.id;option.textContent=claim.title;
  selectClaim.append(option);
 });
 function loadDuties(id){
  selectDuty.replaceChildren();
  const claim=R.claimById(id);
  if(!claim||!C.isClaim(R,id)){
   selectDuty.disabled=true;
   selectDuty.append(new Option("Choose a claim first",""));
   return;
  }
  selectDuty.disabled=false;
  claim.open.forEach((obligation,i)=>selectDuty.append(new Option((i+1)+". "+obligation,String(i))));
 }
 function primary(contract){
  const id=contract.claim.id;
  if(id==="erdos36")return {url:"https://github.com/d3lefts/d3lefts/blob/main/scripts/verify_erdos_independent.py",label:"Inspect the independent exact overlap verifier"};
  if(id==="sidon30")return {url:"referee.html?domain=sidon#workbench",label:"Run the finite Sidon Referee / same witness"};
  return {url:"desk.html?claim="+encodeURIComponent(id),label:"Plan this obligation in the Research Desk"};
 }
 function returnTo(contract){
  const id=contract.claim.id;
  if(id==="erdos36")return "erdos-paper.html#obligations";
  if(id==="sidon30")return "living-paper.html#history-title";
  return C.passport(id);
 }
 function render(){
  $("cj-workspace").hidden=!selected;$("cj-empty").hidden=!!selected;
  if(!selected)return;
  const c=selected.claim,r=state.entries[selected.key];
  $("cj-claim-name").textContent=c.title+" / "+c.id;
  $("cj-statement").textContent=c.statement;
  $("cj-condition").textContent="ASSUMPTIONS / "+c.conditions;
  $("cj-duty").textContent=selected.obligation;
  $("cj-snapshot").textContent="Canonical evidence registry "+R.asOf+" · Obligation "+(selected.index+1)+" / "+c.open.length;
  $("cj-notes").value=r?.note||"";
  dirty=false;
  $("cj-save-status").textContent=r?.savedAt?"Unreviewed draft preserved locally for this exact obligation. No research status has changed.":"No local note preserved. Your current draft requires an explicit save.";
  $("cj-permalink").href=C.url(c.id,selected.index);
  $("cj-passport").href=C.passport(c.id);
  $("cj-return").href=returnTo(selected);
  const next=primary(selected),a=$("cj-primary");
  a.href=next.url;a.textContent=next.label+" ↗";
  if(next.url.startsWith("https:")){a.target="_blank";a.rel="noopener"}
  else{a.removeAttribute("target");a.removeAttribute("rel")}
  $("cj-submit").href=C.issue(selected,r?.note||"");
  const sourceBox=$("cj-sources");sourceBox.replaceChildren();
  c.sources.forEach(s=>{
   if(typeof s.url!=="string"||!(/^(https:\/\/github\.com\/|https:\/\/d3lefts\.github\.io\/|https:\/\/teorth\.github\.io\/)/.test(s.url)||/^(evidence|passport|research|review|atlas|exact-research)\.html(?:[?#][a-z0-9=&#_-]+)?$/.test(s.url)))return;
   sourceBox.append(link(s.label,s.url));
  });
  $("cj-context-status").textContent="Retains the claim and exact open obligation in this browser. Working notes have no proof status.";
 }
 function choose(id,index,{updateURL=true,activate=true}={}){
  const contract=C.get(R,id,index);if(!contract)return false;
  selected=contract;selectClaim.value=id;loadDuties(id);selectDuty.value=String(index);
  state.selected={claimId:id,index};saveState();if(activate)rememberFocus(contract);showInvalid("");
  if(updateURL)history.replaceState(null,"",C.url(id,index));
  render();
  return true;
 }
 selectClaim.addEventListener("change",()=>{
  if(!C.isClaim(R,selectClaim.value)){
   selected=null;state.selected=null;saveState();
   loadDuties(null);history.replaceState(null,"","join.html#claim-investigation");render();return;
  }
  choose(selectClaim.value,0);
 });
 selectDuty.addEventListener("change",()=>choose(selectClaim.value,Number(selectDuty.value)));
 $("cj-notes").addEventListener("input",()=>{
  dirty=true;
  $("cj-save-status").textContent="Draft edited; choose Preserve local note. No proof or verification claim is created.";
  // Do not silently publish or store notes; user must explicitly preserve.
  $("cj-submit").href=C.issue(selected,$("cj-notes").value.slice(0,C.MAX));
 });
 $("cj-save").addEventListener("click",()=>{
  if(!selected)return;
  const note=$("cj-notes").value.slice(0,C.MAX),prior=state.entries[selected.key];
  state.entries[selected.key]={snapshot:selected.snapshot,note,savedAt:new Date().toISOString()};
  if(!saveState()){
   if(prior)state.entries[selected.key]=prior;else delete state.entries[selected.key];
   $("cj-save-status").textContent="Browser storage unavailable. Export your research note before navigating away.";
   return;
  }
  dirty=false;rememberFocus(selected);
  $("cj-save-status").textContent="Unreviewed note saved locally for "+selected.claim.id+" / obligation "+(selected.index+1)+". No scientific claim promoted.";
 });
 $("cj-export").addEventListener("click",()=>{
  if(!selected)return;
  const note=$("cj-notes").value.slice(0,C.MAX);
  const blob=new Blob([C.brief(selected,note)],{type:"text/plain"});
  const url=URL.createObjectURL(blob),a=document.createElement("a");
  a.href=url;a.download="NIGHTFALL_"+selected.claim.id+"_obligation_"+(selected.index+1)+"_UNREVIEWED.txt";
  document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),1000);
 });
 if(parsed.requested&&!parsed.contract){
  // Invalid deep-link claims never silently substitute a different research problem.
  showInvalid(parsed.reason);$("cj-empty").textContent="The supplied claim or obligation was rejected. Choose a source-backed option above; no unrelated assignment has been selected.";
  if(state.selected)selectClaim.value="";
 }else if(parsed.contract)choose(parsed.contract.claim.id,parsed.contract.index,{updateURL:false});
 else if(state.selected)choose(state.selected.claimId,state.selected.index,{updateURL:false,activate:false});
})();
