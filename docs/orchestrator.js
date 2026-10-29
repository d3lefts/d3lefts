"use strict";(function(){const core=globalThis.NIGHTFALL_ORCHESTRATOR;const $=id=>document.getElementById(id);if(!core||!$("orch-form"))return;let last=null;$("orch-form").addEventListener("submit",event=>{event.preventDefault();try{last=core.plan({id:$("claim-id").value,claim:$("claim-text").value,source:$("claim-source").value,digest:$("claim-digest").value,falsifier:$("claim-falsifier").value});const lanes=$("orch-lanes");lanes.replaceChildren();for(const task of last.tasks){const el=document.createElement("article");el.className="orch-lane";const h=document.createElement("h3");h.textContent=task.id+" — "+task.role;const p=document.createElement("p");p.textContent=task.brief;el.append(h,p);lanes.append(el);}$("orch-message").textContent="Plan generated locally: "+last.tasks.length+" scoped lanes. Source digest: "+last.frozen.digest+". No task was dispatched.";$("orch-export").disabled=false;}catch(e){last=null;$("orch-export").disabled=true;$("orch-message").textContent="Input rejected: "+e.message;}});$("orch-export").addEventListener("click",()=>{if(!last)return;const blob=new Blob([JSON.stringify(last,null,2)],{type:"application/json"});const url=URL.createObjectURL(blob);const a=document.createElement("a");a.href=url;a.download="NIGHTFALL_orchestrator_plan.json";document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),1000);});$("orch-audit").addEventListener("click",()=>{try{const receipts=JSON.parse($("orch-receipts").value);const report=core.audit(receipts);$("orch-assessment").textContent=report.verdict+" — "+report.scope+(report.issues.length?"\n"+report.issues.join("\n"):"\nAll four receipt schemas complete; review independence and underlying mathematics separately.");}catch(error){$("orch-assessment").textContent="INCONCLUSIVE — invalid receipt input: "+error.message;}});})();
/* Explicit local Frontier → Orchestrator handoff. Populates inputs only; never runs lanes. */
(function(){
 const q=new URLSearchParams(location.search);
 if(q.get("frontier_handoff")!=="1")return;
 try{
  const raw=sessionStorage.getItem("nightfall.frontier.orchestrator.v1");
  sessionStorage.removeItem("nightfall.frontier.orchestrator.v1");
  if(!raw||raw.length>5500)throw Error("Missing or oversized Frontier handoff.");
  const c=JSON.parse(raw);
  for(const key of ["id","claim","source","falsifier"])if(typeof c[key]!=="string"||!c[key].trim()||c[key].length>2000)throw Error("Invalid Frontier assignment field: "+key);
  if(!/^https:\/\/github\.com\/d3lefts\/d3lefts\//.test(c.source))throw Error("Unexpected source host.");
  document.getElementById("claim-id").value=c.id.slice(0,80);
  document.getElementById("claim-text").value=c.claim;
  document.getElementById("claim-source").value=c.source;
  document.getElementById("claim-falsifier").value=c.falsifier;
  document.getElementById("orch-message").textContent="Frontier assignment imported into editable local fields. Inspect the statement and source, then explicitly generate the work plan.";
 }catch(e){document.getElementById("orch-message").textContent="Frontier handoff refused: "+e.message;}
 finally{history.replaceState(null,"",location.pathname);}
})();
