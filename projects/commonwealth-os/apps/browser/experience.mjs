/* Progressive enhancement for the synthetic Commonwealth Experience.
 * Answers are kept only in this page's JS memory; no network, storage, telemetry.
 */
import {ROLES,RESPONSES,FICTIONAL_ISSUE,FICTIONAL_VIEWPOINTS,FICTIONAL_STEPS,
  fictionalTotal,chooseResponse,validateRole,stepAt} from "./experience-core.mjs";
const root=document.getElementById("cwexp");
if (root) {
  let selected=null;
  let revealed=false;
  let step=0;
  const get=id=>document.getElementById(id);
  function switchRole(role) {
    validateRole(role);
    for (const button of root.querySelectorAll("[data-cwexp-role]"))
      button.setAttribute("aria-pressed",String(button.dataset.cwexpRole===role));
    for (const panel of root.querySelectorAll("[data-cwexp-panel]"))
      panel.hidden=panel.dataset.cwexpPanel!==role;
    get("cwexp-role-status").textContent="Showing "+role+" pathway. All examples are fictional.";
  }
  function showResults() {
    revealed=true;
    get("cwexp-perspectives").hidden=false;
    get("cwexp-reveal-context").textContent=selected
      ? "Your illustrative choice: "+selected.label+". It is not included in the fictional totals."
      : "You can inspect the fictional perspectives without submitting an answer.";
    get("cwexp-viewpoint-total").textContent=String(fictionalTotal(FICTIONAL_VIEWPOINTS));
    for (const item of FICTIONAL_VIEWPOINTS) {
      const n=get("cwexp-group-"+item.id);
      if(n) n.textContent=String(item.count);
    }
  }
  function recordChoice(choice) {
    selected=chooseResponse(choice);
    for (const button of root.querySelectorAll("[data-cwexp-answer]"))
      button.setAttribute("aria-pressed",String(button.dataset.cwexpAnswer===choice));
    get("cwexp-answer-status").textContent="Selected: "+selected.label+
      ". Stored in page memory only; no real vote or public submission.";
    showResults();
  }
  function resetChoice() {
    selected=null; revealed=false;
    for (const button of root.querySelectorAll("[data-cwexp-answer]"))
      button.setAttribute("aria-pressed","false");
    get("cwexp-answer-status").textContent="No preference selected. Unknown is distinct from No preference.";
    get("cwexp-perspectives").hidden=true;
  }
  function showStep(index) {
    step=Number(index);
    const data=stepAt(step);
    for (const button of root.querySelectorAll("[data-cwexp-step]"))
      button.setAttribute("aria-pressed",String(Number(button.dataset.cwexpStep)===step));
    get("cwexp-step-heading").textContent=data.title;
    get("cwexp-step-narrative").textContent=data.narrative;
    get("cwexp-step-evidence").textContent=data.evidence;
    get("cwexp-story-progress").textContent="STEP "+(step+1)+" OF "+FICTIONAL_STEPS.length;
  }
  for (const button of root.querySelectorAll("[data-cwexp-role]"))
    button.addEventListener("click",()=>switchRole(button.dataset.cwexpRole));
  for (const button of root.querySelectorAll("[data-cwexp-answer]"))
    button.addEventListener("click",()=>recordChoice(button.dataset.cwexpAnswer));
  for (const button of root.querySelectorAll("[data-cwexp-step]"))
    button.addEventListener("click",()=>showStep(button.dataset.cwexpStep));
  get("cwexp-reveal-button").addEventListener("click",showResults);
  get("cwexp-clear-button").addEventListener("click",resetChoice);
  get("cwexp-next-step").addEventListener("click",()=>showStep((step+1)%FICTIONAL_STEPS.length));
  // The DOM contains the explanatory scenario; the model supplies only safe text labels.
  get("cwexp-source-status").textContent=FICTIONAL_ISSUE.sourceStatus;
  switchRole(ROLES[0]);
  showStep(0);
}
