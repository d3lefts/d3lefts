"use strict";
(function(){
 const core=globalThis.NIGHTFALL_FRONTIER;if(!core)return;
 const $=id=>document.getElementById(id),KEY="nightfall_frontier_local_v1";
 const ranked=core.prioritize();
 let state={caseId:ranked[0].id,activeId:ranked[0].parts[0].id,claimed:{},children:[],checks:{}};
 try{
  const saved=JSON.parse(localStorage.getItem(KEY)||"null");
  if(saved&&saved.version===core.VERSION&&ranked.some(x=>x.id===saved.caseId)&&saved.claimed&&typeof saved.claimed==="object"&&Array.isArray(saved.children)&&saved.children.length<=24&&saved.checks&&typeof saved.checks==="object"){
   const next={caseId:saved.caseId,activeId:saved.activeId,claimed:saved.claimed,children:saved.children,checks:saved.checks};
   if(core.workItem(next.caseId,next.activeId,next.children))state=next;
  }
 }catch(_){}
 const status=message=>{$("frontier-claim-status").textContent=message};
 function save(){
  try{localStorage.setItem(KEY,JSON.stringify({...state,version:core.VERSION}));return true}
  catch(e){status("Local storage unavailable; export your evidence file to preserve work.");return false}
 }
 const create=(tag,cls,text)=>{const el=document.createElement(tag);if(cls)el.className=cls;if(text!==undefined)el.textContent=text;return el};
 function selectedCase(){return ranked.find(c=>c.id===state.caseId)||ranked[0]}
 function active(){return core.workItem(state.caseId,state.activeId,state.children)}
 function renderRanking(){
  const host=$("frontier-rankings");host.replaceChildren();
  for(const [i,c] of ranked.entries()){
   const b=create("button","fr-rank");b.type="button";b.setAttribute("aria-pressed",String(c.id===state.caseId));
   const top=create("div","fr-rank-top");top.append(create("span","",String(i+1).padStart(2,"0")+" / "+c.area),create("span","",String(core.score(c))+" POINTS"));
   b.append(top,create("h3","",c.title),create("p","",c.challenge));
   const foot=create("div","fr-rank-bottom");foot.append(create("span","","ISSUE #"+c.issue+" · "+core.SNAPSHOT),create("span","","INSPECT ↗"));b.append(foot);
   b.addEventListener("click",()=>{state.caseId=c.id;state.activeId=c.parts[0].id;save();render();$("work").scrollIntoView({behavior:"smooth",block:"start"});});
   host.append(b);
  }
 }
 function renderBranches(){
  const c=selectedCase(),host=$("frontier-branches");host.replaceChildren();
  host.append(create("h4","","Choose a branch."));
  const items=c.parts.map(x=>({...x,caseId:c.id})).concat(state.children.filter(x=>x.caseId===c.id));
  for(const item of items){
   const b=create("button","fr-branch");b.type="button";b.setAttribute("aria-pressed",String(state.activeId===item.id));
   const left=create("div");left.append(create("strong","",item.title),create("span","",(item.local?"YOUR CHILD / DEPTH "+item.depth:item.kind.toUpperCase())+" · "+(state.claimed[c.id+":"+item.id]?"CLAIMED LOCALLY":"UNCLAIMED")));
   b.append(left,create("span","","↗"));
   b.addEventListener("click",()=>{state.activeId=item.id;save();render();});
   host.append(b);
  }
 }
 function render(){
  const c=selectedCase(),a=active();if(!a)return;
  renderRanking();renderBranches();
  $("frontier-problem-meta").textContent=c.parent+" / OPEN IN SOURCE SNAPSHOT "+core.SNAPSHOT;
  $("problem-head").textContent=c.challenge;
  $("frontier-problem-description").textContent=c.why;
  $("frontier-source").href=c.source;
  $("frontier-issue").href="https://github.com/d3lefts/d3lefts/issues/"+c.issue;
  $("frontier-active-title").textContent=a.title;
  $("frontier-active-claim").textContent=a.claim;
  $("frontier-active-falsifier").textContent="Falsifier: "+a.falsifier;
  const key=a.nodeId,claimed=!!state.claimed[key];
  $("frontier-claim").textContent=claimed?"Release local claim":"Claim locally";
  $("frontier-witness-section").hidden=!(c.id==="NF-156-184"&&a.id==="witness");
  const result=state.checks[key];
  $("frontier-result").textContent=result?(result.message+"\nResult: "+result.status+" · Local exact check only; no global status changed."):
   "No evidence has been attached to this branch. Status: OPEN / UNREVIEWED.";
  status(claimed?"Claimed in this browser only. Publish a GitHub issue to request a public shared assignment.":"Unclaimed. Claiming here does not reserve work for anyone else.");
 }
 function fileDownload(name,obj){
  const blob=new Blob([JSON.stringify(obj,null,2)+"\n"],{type:"application/json"});
  const url=URL.createObjectURL(blob),anchor=document.createElement("a");anchor.href=url;anchor.download=name;
  document.body.append(anchor);anchor.click();anchor.remove();setTimeout(()=>URL.revokeObjectURL(url),2500);
 }
 $("frontier-claim").addEventListener("click",()=>{
  const a=active(),key=a.nodeId;
  if(state.claimed[key])delete state.claimed[key];
  else state.claimed[key]={at:new Date().toISOString(),scope:"browser-local, non-exclusive"};
  save();render();
 });
 $("frontier-near").addEventListener("click",()=>{
  $("frontier-witness").value=core.NEAR.join(", ");$("frontier-result").textContent="Archived N184 nine-mark near-candidate loaded; this is NOT a saturated witness. Run the checker to locate the remaining addable marks.";
 });
 $("frontier-check").addEventListener("click",()=>{
  if(selectedCase().id!=="NF-156-184"||active()?.id!=="witness")return;
  const result=core.verifyNine($("frontier-witness").value);
  const a=active(),key=a.nodeId;
  state.checks[key]={...result,at:new Date().toISOString(),checker:"frontier-core.js / version "+core.VERSION};
  save();render();
 });
 $("frontier-split-form").addEventListener("submit",event=>{
  event.preventDefault();const a=active();
  if(!state.claimed[a.nodeId]){status("Claim this branch locally before adding a descendant.");return;}
  try{
   const child=core.split(state.caseId,state.activeId,$("frontier-child-title").value,$("frontier-child-falsifier").value,state.children);
   state.children.push(child);state.activeId=child.id;save();
   $("frontier-child-title").value="";$("frontier-child-falsifier").value="";
   render();status("Local child created with parent, source and falsifier. Export it or request public GitHub assignment.");
  }catch(e){status("Subdivision refused: "+e.message);}
 });
 function publicIssue(){
  const a=active(),contract=core.contract(a),caseItem=selectedCase();
  const title="[Frontier / "+caseItem.id+"] "+a.title;
  const check=state.checks[a.nodeId];
  const body=[
   "NIGHTFALL FRONTIER / PUBLIC ASSIGNMENT REQUEST",
   "",
   "**Source problem:** "+caseItem.parent,
   "**NIGHTFALL issue:** #"+caseItem.issue,
   "**Branch:** "+contract.id,
   "**Pinned source:** "+contract.source,
   "**Exact claim:** "+contract.claim,
   "**Falsification condition:** "+contract.falsifier,
   "**Browser check:** "+(check?check.status+" — "+check.message:"No local evidence supplied"),
   "**Research status:** Proposed / unreviewed. Do not infer verified proof or unique ownership.",
   "",
   "Deliver exact inputs or proof, independent checker or review, failure observations and source provenance.",
   "Please coordinate duplicate work in the parent issue before assuming exclusive ownership."
  ].join("\n\n");
  const url="https://github.com/d3lefts/d3lefts/issues/new?title="+encodeURIComponent(title)+"&body="+encodeURIComponent(body);
  window.open(url,"_blank","noopener,noreferrer");
  status("Requested a GitHub issue draft in a new tab. If it opens, review and submit there. No public assignment was automatically created.");
 }
 $("frontier-publish").addEventListener("click",publicIssue);
 $("frontier-orchestrate").addEventListener("click",()=>{
  const a=active(),contract=core.contract(a);
  const payload={id:contract.id,claim:contract.claim,source:contract.source,falsifier:contract.falsifier};
  try{
   sessionStorage.setItem("nightfall.frontier.orchestrator.v1",JSON.stringify(payload));
   location.assign("orchestrator.html?frontier_handoff=1");
  }catch(e){status("Handoff unavailable: "+e.message+". Export the contract and paste the values into Orchestrator.");}
 });
 $("frontier-export").addEventListener("click",()=>{
  const a=active();fileDownload("NIGHTFALL_Frontier_"+a.nodeId.replace(/[^\w-]/g,"_")+".json",{
   schema:"nightfall-frontier-local-evidence-v1",exportedAt:new Date().toISOString(),priorityRubric:core.RUBRIC,
   selectedProblem:selectedCase().challenge,contract:core.contract(a),localClaim:state.claimed[a.nodeId]||null,
   checkerResult:state.checks[a.nodeId]||null,children:state.children.filter(c=>c.caseId===state.caseId),
   warning:"Local record only. Neither an export nor a browser check confers public ownership, external review or publication status."
  });
 });
 $("frontier-clear").addEventListener("click",()=>{
  if(!window.confirm("Clear only Frontier's saved local claims, checks and child branches? Other NIGHTFALL tools will remain unchanged."))return;
  try{localStorage.removeItem(KEY)}catch(_){}
  state={caseId:ranked[0].id,activeId:ranked[0].parts[0].id,claimed:{},children:[],checks:{}};
  $("frontier-witness").value="";render();
 });
 render();
})();
