/* NIGHTFALL contributor workspace: local context only; never an assignment server or proof authority. */
"use strict";
(() => {
 const C=window.NFFrontier,E=window.NFJoinEvidence,$=id=>document.getElementById(id);
 if(!C||!E){$("join-choices").textContent="The frozen assignment or finite evidence checker could not be loaded. Use Frontier Dispatch or the research archive.";return;}
 const KEY="nightfall.journey.v1",LEDGER="nightfall_nf_frontier_local_v1";
 const ROOTS=C.ranked();
 const INTERESTS={
  proof:{preferred:"NF-156-184-9",reason:"Recommended: the nine-mark maximal Sidon decision has explicit existence and impossibility proof obligations."},
  compute:{preferred:"NF-Q7-R6",reason:"Recommended: the bounded Q7 graph search defines an exact finite configuration and independent four-cycle checks."},
  audit:{preferred:"NF-156-184-9",reason:"Recommended: audit the nine-mark existence encoding and its claimed complete UNSAT certificate. The Q7 branch is also available."}
 };
 const empty=()=>({version:1,rootId:null,assignmentId:null,interest:"proof",notes:{},evidence:{}});
 function load(){
  try{const x=JSON.parse(localStorage.getItem(KEY)||"null");
   if(!x||x.version!==1||typeof x.notes!=="object"||x.notes===null)return empty();
   const root=C.base(x.rootId),interest=INTERESTS[x.interest]?x.interest:"proof";
   const evidence={};let invalid=0;
   for(const r of ROOTS){
    const arr=x.evidence?.[r.id];
    if(arr===undefined){evidence[r.id]=[];continue}
    if(!Array.isArray(arr)||arr.length>E.MAX_RECORDS||
       arr.some(item=>item?.assignment?.rootId!==r.id||!E.verify(item,C).valid)){
      evidence[r.id]=[];invalid++;continue;
    }
    evidence[r.id]=arr;
   }
   return {version:1,rootId:root?root.id:null,assignmentId:typeof x.assignmentId==="string"?x.assignmentId:null,
    interest,notes:Object.fromEntries(ROOTS.map(r=>[r.id,typeof x.notes[r.id]==="string"?x.notes[r.id].slice(0,4000):""])),
    evidence,evidenceWarning:invalid?"Rejected "+invalid+" altered or oversized local evidence ledger(s). Re-enter exact inputs.":""};
  }catch{return empty()}
 }
 const state=load(); let checkedResult=null,saveIssue=state.evidenceWarning||"",lastCheck=null,lastAttack=null,lastPacket=null;
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
   btn.addEventListener("click",()=>{state.rootId=x.id;state.assignmentId=x.id;checkedResult=null;lastCheck=null;lastAttack=null;lastPacket=null;save();render();$("workspace").scrollIntoView({behavior:"smooth",block:"start"})});
   card.append(btn);box.append(card);
  }
 }
 function sourceLinks(root){
  const box=$("join-source-links");box.replaceChildren();
  for(const [label,url] of [["Original problem",root.source],["Published data",root.data],["NIGHTFALL evidence",root.evidence],["Standing assignment",root.issue]])
   box.append(elink(label+" ↗",url));
 }
 function drawEvidence(){
  const t=task(),root=t&&C.base(t.rootId);
  if(!root||root.id!=="NF-156-184-9")return;
  const list=state.evidence[root.id]||[];
  $("join-run-attack").disabled=!lastCheck;
  $("join-save-evidence").disabled=!lastCheck||!lastAttack||list.length>=E.MAX_RECORDS;
  $("join-export-evidence").disabled=!list.length;
  $("join-evidence-count").textContent=list.length+" preserved local candidate tests (maximum "+E.MAX_RECORDS+").";
  $("join-evidence-status").textContent=saveIssue||
    (lastAttack?"Local exact negative controls ran. Save this bounded record only after reviewing it.": 
     lastCheck?"Candidate checked. Run independent challenge before preserving evidence.":"No unreviewed result is yet preserved.");
  const history=$("join-evidence-history");history.replaceChildren();
  for(const [index,r] of list.entries()){
   const el=elem("p","join-evidence-record",(index+1)+". "+r.calculation.independent_status+
    " · min "+r.input[0]+" · exact "+r.input.join(", ")+" · local dual check and controls reproduced");
   history.append(el);
  }
  if(!list.length)history.textContent="No preserved tests yet. All outcomes, including rejected candidates, may be recorded.";
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
  $("join-attack-output").textContent=lastAttack?"LOCAL ATTACK: "+lastAttack.status+"\n"+lastAttack.actual_obstruction+"\n"+lastAttack.controls.map(c=>c.name+": "+(c.rejected_as_expected?"PASS":"FAIL")).join("\n"):"Check a candidate first. Exact attack controls have not run.";
  drawEvidence();
  $("join-next-action").textContent=sidon?"Continue to Discovery with this exact scope ↗":"Design a scoped experiment in Discovery ↗";
  document.querySelector('[data-stage="challenge"] strong').textContent=sidon?"Run exact attacks on this candidate ↗":"Plan proof and checker attacks ↗";
  document.querySelector('[data-stage="record"] strong').textContent=sidon?"Preserve a source-bound evidence packet ↗":"Carry unreviewed contract to Claim Lab ↗";
  $("join-github").href=C.issueUrl(t,"ASSIGNMENT REQUEST","I would like to work on this source-linked unresolved branch. Proposed approach:\n"+(state.notes[x.id]||"To be specified."));
  sourceLinks(x);
 }
 function render(){drawChoices();drawActive()}
 function route(stage){
  const t=task();if(!t){return}
  let dest,storage,payload;
  try {
   if(stage==="challenge"&&t.rootId==="NF-156-184-9"){
    if(lastCheck)runAttack();else saveIssue="First run the exact finite check on a candidate.";
    drawEvidence();$("join-evidence-panel").scrollIntoView({behavior:"smooth",block:"center"});return;
   }
   if(stage==="record"&&t.rootId==="NF-156-184-9"){
    saveIssue=lastAttack?"Review the source-bound result, then explicitly preserve it for external review.":"First run an exact check and the attack controls before preserving evidence.";
    drawEvidence();$("join-evidence-panel").scrollIntoView({behavior:"smooth",block:"center"});return;
   }
   if(stage==="frame"||stage==="challenge"){
    dest="orchestrator.html?frontier_handoff=1";storage="nightfall.frontier.orchestrator.v1";payload=C.orchestratorInput(t);
   }else if(stage==="explore"){
    dest="discovery.html?frontier_handoff=1";storage="nightfall.frontier.discovery.v1";
    payload=C.packet(t);C.validatePacket(payload);
   }else if(stage==="claimlab"||stage==="record"){
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
 $("join-values").addEventListener("input",()=>{
  lastCheck=null;lastAttack=null;lastPacket=null;checkedResult=null;saveIssue="Input changed. Run the exact check again; earlier computed results cannot follow edited data.";
  $("join-check-output").textContent="Source modified — run exact finite check.";
  $("join-attack-output").textContent="Challenge cleared because the source input changed.";
  drawEvidence();
 });
 $("join-run-check").addEventListener("click",()=>{
  const t=task();if(!t||t.rootId!=="NF-156-184-9")return;
  lastCheck=null;lastAttack=null;lastPacket=null;
  try{
   const packet=C.packet(t);C.validatePacket(packet);
   const r=E.check($("join-values").value,packet,C);
   lastCheck=r;lastPacket=packet;
   checkedResult=(r.primary_status==="MAXIMAL_FINITE"?"LOCAL EXACT CHECK PASSED — INDEPENDENT REPLAY REQUIRED":"CANDIDATE REJECTED / NO GLOBAL CONCLUSION")+
    "\nPrimary: "+r.primary_status+" / "+r.primary_reason+
    "\nIndependent difference method: "+r.independent_status+
    "\nDual-method agreement: "+(r.agreement?"PASS":"FAIL");
   saveIssue=r.agreement?"Two local arithmetic methods agree. Challenge controls remain open.":"LOCAL CHECKER DISAGREEMENT — do not use as evidence.";
  }catch(e){checkedResult="Candidate input rejected: "+e.message;saveIssue="Finite input refused; preserve no scientific conclusion.";}
  $("join-check-output").textContent=checkedResult;
  $("join-attack-output").textContent="Run the separate challenge step on this exact input.";
  drawEvidence();
 });
 function runAttack(){
  const t=task();
  if(!t||t.rootId!=="NF-156-184-9"||!lastCheck||!lastPacket)return;
  try{
   lastAttack=E.attack(lastCheck,lastPacket,C);
   saveIssue=lastAttack.status==="LOCAL_ATTACK_CONTROLS_PASSED"?
    "Exact negative controls pass; the result still requires independent external verification.":
    "Attack controls inconclusive. Evidence preservation blocked.";
  }catch(e){lastAttack=null;saveIssue="Attack refused: "+e.message;}
  $("join-attack-output").textContent=lastAttack?"LOCAL ATTACK: "+lastAttack.status+
   "\n"+lastAttack.actual_obstruction+
   "\n"+lastAttack.controls.map(c=>c.name+": "+(c.rejected_as_expected?"PASS":"FAIL")).join("\n"):
   "Attacks need the unchanged exact source input.";
  drawEvidence();
 }
 $("join-run-attack").addEventListener("click",runAttack);
 $("join-save-evidence").addEventListener("click",()=>{
  const t=task(),root=t&&C.base(t.rootId);
  if(!root||root.id!=="NF-156-184-9"||!lastCheck||!lastAttack||!lastPacket)return;
  try{
   if(lastAttack.status!=="LOCAL_ATTACK_CONTROLS_PASSED")throw Error("The bounded challenge has not passed.");
   const proof=E.receipt(lastCheck.values,lastPacket,state.notes[root.id]||"",C);
   const list=state.evidence[root.id]||[];
   if(list.length>=E.MAX_RECORDS)throw Error("Twelve source-bound records reached; export the ledger.");
   if(list.some(e=>e.assignment.assignmentId===proof.assignment.assignmentId&&e.input.join(",")===proof.input.join(",")))
    throw Error("This exact source and assignment were already preserved.");
   state.evidence[root.id]=list.concat(proof);
   if(!save())throw Error("Local evidence storage failed — export is recommended.");
   saveIssue="Source, exact result, attack controls and your unreviewed note preserved locally; no theorem claim promoted.";
  }catch(e){saveIssue="Evidence preservation refused: "+e.message}
  drawEvidence();
 });
 $("join-export-evidence").addEventListener("click",()=>{
  const t=task(),root=t&&C.base(t.rootId);if(!root||root.id!=="NF-156-184-9")return;
  const list=state.evidence[root.id]||[];
  if(!list.length||list.some(r=>!E.verify(r,C).valid)){saveIssue="Export refused: source evidence failed independent local replay.";drawEvidence();return}
  const packet={format:"nightfall-join-evidence-bundle-v1",reviewStatus:"unreviewed",
    parent_problem:t.rootId,entries:list,claim:"Local finite candidate tests only; N=184 global decision open.",
    checker:"docs/join-evidence-core.js",external_review:false};
  const url=URL.createObjectURL(new Blob([JSON.stringify(packet,null,2)],{type:"application/json"}));
  const a=elem("a");a.href=url;a.download="NIGHTFALL_N184_source_bound_evidence.json";
  document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),1000);
 });
 document.querySelectorAll("[data-stage]").forEach(b=>b.addEventListener("click",()=>route(b.dataset.stage)));
 $("join-next-action").addEventListener("click",()=>route("explore"));
 $("join-claimlab-link").addEventListener("click",()=>route("claimlab"));
 $("join-export").addEventListener("click",exportBrief);
 render();
})();
