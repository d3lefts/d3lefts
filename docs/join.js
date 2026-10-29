/* NIGHTFALL contributor workspace: local context only; never an assignment server or proof authority. */
"use strict";
(() => {
 const C=window.NFFrontier,$=id=>document.getElementById(id);
 if(!C){$("join-choices").textContent="The frozen assignment registry could not be loaded. Use Frontier Dispatch or the research archive.";return;}
 const KEY="nightfall.journey.v1",LEDGER="nightfall_nf_frontier_local_v1";
 const ROOTS=C.ranked();
 const INTERESTS={
  proof:{preferred:"NF-156-184-9",reason:"Recommended: the nine-mark maximal Sidon decision has explicit existence and impossibility proof obligations."},
  compute:{preferred:"NF-Q7-R6",reason:"Recommended: the bounded Q7 graph search defines an exact finite configuration and independent four-cycle checks."},
  audit:{preferred:"NF-156-184-9",reason:"Recommended: audit the nine-mark existence encoding and its claimed complete UNSAT certificate. The Q7 branch is also available."}
 };
 const empty=()=>({version:1,rootId:null,assignmentId:null,interest:"proof",notes:{}});
 function load(){
  try{const x=JSON.parse(localStorage.getItem(KEY)||"null");
   if(!x||x.version!==1||typeof x.notes!=="object"||x.notes===null)return empty();
   const root=C.base(x.rootId),interest=INTERESTS[x.interest]?x.interest:"proof";
   return {version:1,rootId:root?root.id:null,assignmentId:typeof x.assignmentId==="string"?x.assignmentId:null,
    interest,notes:Object.fromEntries(ROOTS.map(r=>[r.id,typeof x.notes[r.id]==="string"?x.notes[r.id].slice(0,4000):""]))};
  }catch{return empty()}
 }
 const state=load(); let checkedResult=null,saveIssue="";
 function save(){try{localStorage.setItem(KEY,JSON.stringify(state));return true}catch{return false}}
 function task(){
  const root=C.base(state.rootId);if(!root)return null;
  try{const data=JSON.parse(localStorage.getItem(LEDGER)||"null");
   if(data?.version===C.VERSION&&Array.isArray(data.tasks)){
    C.validateLedger(data.tasks);
    const hit=data.tasks.find(x=>x.id===state.assignmentId&&x.rootId===root.id);
    if(hit&&C.assertTask(hit))return hit;
   }
  }catch{/* invalid local data never crosses scientific boundary */}
  return C.rootTask(root);
 }
 function elem(tag,cls,content){const el=document.createElement(tag);if(cls)el.className=cls;if(content!==undefined)el.textContent=content;return el}
 function elink(label,url){const a=elem("a","",label);a.href=url;if(url.startsWith("https:")){a.target="_blank";a.rel="noopener"}return a}
 function drawChoices(){
  const box=$("join-choices");box.replaceChildren();
  const pref=INTERESTS[state.interest];
  $("join-match-reason").textContent=pref.reason+" Matching is editorial, not a live AI evaluation.";
  const ordered=ROOTS.slice().sort((a,b)=>(b.id===pref.preferred)-(a.id===pref.preferred));
  for(const x of ordered){
   const card=elem("article","join-choice");card.dataset.recommended=String(x.id===pref.preferred);
   if(state.rootId===x.id)card.setAttribute("aria-current","true");
   card.append(elem("span","",x.parent+" · "+(x.id===pref.preferred?"RECOMMENDED FOR YOUR FOCUS":"ALTERNATE OPEN QUESTION")),
    elem("h3","",x.title),elem("p","",x.question),elem("p","",x.why));
   const btn=elem("button","",state.rootId===x.id?"Selected — resume question ↗":"Work on this question ↗");
   btn.type="button";
   btn.addEventListener("click",()=>{state.rootId=x.id;state.assignmentId=x.id;checkedResult=null;save();render();$("workspace").scrollIntoView({behavior:"smooth",block:"start"})});
   card.append(btn);box.append(card);
  }
 }
 function sourceLinks(root){
  const box=$("join-source-links");box.replaceChildren();
  for(const [label,url] of [["Original problem",root.source],["Published data",root.data],["NIGHTFALL evidence",root.evidence],["Standing assignment",root.issue]])
   box.append(elink(label+" ↗",url));
 }
 function drawActive(){
  const t=task(),x=t&&C.base(t.rootId),has=!!x;
  $("join-active").hidden=!has;$("join-active-empty").hidden=has;
  if(!has){$("join-active-intro").textContent="Choose an assignment above to enter the workbench.";return}
  $("join-active-intro").textContent=x.parent+" · "+t.id+" · Frozen 29 October 2026";
  $("join-question").textContent=x.question;
  $("join-why").textContent=x.why;
  $("join-scope").textContent="CURRENT BOUNDED SCOPE / "+C.predicate(t);
  $("join-yes").textContent=x.closureYes;
  $("join-no").textContent=x.closureNo;
  $("join-stop").textContent=x.stop;
  $("join-frontier-link").href="frontier.html?task="+encodeURIComponent(t.id)+"#active-title";
  $("join-notes").value=state.notes[x.id]||"";
  const sidon=x.id==="NF-156-184-9";
  $("join-sidon-starter").hidden=!sidon;$("join-q7-starter").hidden=sidon;
  $("join-starter-title").textContent=sidon?"Challenge a nine-mark candidate":"Frame a six-deletion search";
  $("join-starter-description").textContent=sidon?
   "This exact browser check tests pair-sum uniqueness and maximality across all 175 omitted marks. It does not certify a negative existence claim, and a passing candidate still needs independent replay.":
   "There is no Q7 proof oracle on this page. Record the representative, six deletions, seven insertions, and the precise four-cycle falsifier; the source checker handles the exact graph tests.";
  $("join-q7-source").href=x.issue;
  $("join-check-output").textContent=checkedResult||"No calculation run in this session.";
  $("join-next-action").textContent=sidon?"Continue to Discovery with this exact scope ↗":"Design a scoped experiment in Discovery ↗";
  $("join-github").href=C.issueUrl(t,"ASSIGNMENT REQUEST","I would like to work on this source-linked unresolved branch. Proposed approach:\n"+(state.notes[x.id]||"To be specified."));
  sourceLinks(x);
 }
 function render(){drawChoices();drawActive()}
 function route(stage){
  const t=task();if(!t){return}
  let dest,storage,payload;
  try {
   if(stage==="frame"||stage==="challenge"){
    dest="orchestrator.html?frontier_handoff=1";storage="nightfall.frontier.orchestrator.v1";payload=C.orchestratorInput(t);
   }else if(stage==="explore"){
    dest="discovery.html?frontier_handoff=1";storage="nightfall.frontier.discovery.v1";
    payload=C.packet(t);C.validatePacket(payload);
   }else if(stage==="record"){
    dest="claim-lab.html?frontier_handoff=1";storage="nightfall.frontier.claimlab.v1";
    payload=C.packet(t);C.validatePacket(payload);
   }else{return}
   sessionStorage.setItem(storage,JSON.stringify(payload));
   // The selected branch remains an unreviewed input. Each instrument must validate it itself.
   save();location.assign(dest);
  }catch(e){$("join-save").textContent="Handoff unavailable ("+e.message+"). Export the research brief and transfer it manually."}
 }
 function exportBrief(){
  const t=task();if(!t)return;
  const root=C.base(t.rootId);
  const s=C.brief(t)+"\n\nWORKING NOTES (AUTHOR-SUPPLIED, UNREVIEWED)\n"+(state.notes[root.id]||"No notes yet.")+
  "\n\nSTATUS: Research input only. No independent verification and no automatic claim promotion.\n";
  const url=URL.createObjectURL(new Blob([s],{type:"text/plain"}));
  const a=elem("a");a.href=url;a.download="NIGHTFALL_"+t.rootId+"_research_brief.txt";
  document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),1000);
 }
 const query=new URLSearchParams(location.search).get("task");
 if(C.base(query)){state.rootId=query;state.assignmentId=query;save()}
 $("join-interest").value=state.interest;
 $("join-interest").addEventListener("change",e=>{state.interest=INTERESTS[e.target.value]?e.target.value:"proof";save();drawChoices()});
 $("join-notes").addEventListener("input",e=>{
  if(!state.rootId)return;state.notes[state.rootId]=e.target.value.slice(0,4000);
  const persisted=save();$("join-save").textContent=persisted?"Saved locally; still unreviewed.":"Storage unavailable; export a brief before leaving.";
  const t=task();if(t)$("join-github").href=C.issueUrl(t,"ASSIGNMENT REQUEST","I would like to work on this source-linked unresolved branch. Proposed approach:\n"+state.notes[state.rootId]);
 });
 $("join-run-check").addEventListener("click",()=>{
  const t=task();if(!t||t.rootId!=="NF-156-184-9")return;
  const raw=$("join-values").value.trim();
  if(!/^\d+(?:[\s,]+\d+)*$/.test(raw)){checkedResult="Enter nine whole numbers separated by spaces or commas.";drawActive();return}
  const input=raw.split(/[\s,]+/).map(Number);
  try{const v=C.checkSidonCandidate(input,184,t);
   checkedResult=(v.ok?"LOCAL EXACT CHECK PASSED — INDEPENDENT REPLAY REQUIRED":"CANDIDATE REJECTED / NO GLOBAL CONCLUSION")+"\n"+v.reason;
  }catch(e){checkedResult=e.message}
  $("join-check-output").textContent=checkedResult;
  $("join-save").textContent="Checker output is not appended to your notes automatically. Record the input and result above to preserve it.";
 });
 document.querySelectorAll("[data-stage]").forEach(b=>b.addEventListener("click",()=>route(b.dataset.stage)));
 $("join-next-action").addEventListener("click",()=>route("explore"));
 $("join-export").addEventListener("click",exportBrief);
 render();
})();
