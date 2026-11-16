"use strict";
/* Practical advantages: exact synthetic comparisons and separately sourced fixed empirical observations. */
(function(){
const core=window.NFPermissionEvidence;
const form=document.querySelector("#pl-compare-form");
if(!core||!form)return;
const scenario=document.querySelector("#pl-compare-scenario"),changed=document.querySelector("#pl-compare-changed");
const rows=document.querySelector("#pl-compare-rows"),summary=document.querySelector("#pl-compare-result");
const evidence=document.querySelector("#pl-compare-evidence"),context=document.querySelector("#pl-compare-context");
const count=document.querySelector("#pl-compare-count"),slots=document.querySelector("#pl-compare-slots");
const oracle=document.querySelector("#pl-compare-oracle");
function cell(tr,value,cls){const td=document.createElement("td");td.textContent=value;if(cls)td.className=cls;tr.appendChild(td);}
function render(){
try{
const x=core.preset(scenario.value,changed.checked),p=x.model;
context.textContent=x.description;
count.textContent=p.R+" of "+p.N+" need fresh certificates";
slots.textContent=p.K+" slots remain";
rows.replaceChildren();
const priced=p.strategies.filter(s=>s.feasible).map(s=>s.cost);
const max=Math.max(1,...priced);
for(const entry of p.strategies){
const tr=document.createElement("tr");
if(entry.id==="hybrid")tr.className="pl-compare-highlight";
cell(tr,entry.label);
const c=document.createElement("td");
if(entry.feasible){
 const bar=document.createElement("div");bar.className="pl-compare-bar";
 const fill=document.createElement("span");fill.style.width=(100*entry.cost/max).toFixed(1)+"%";
 bar.appendChild(fill);c.appendChild(bar);
 const number=document.createElement("strong");number.textContent=entry.cost+" units";
 c.appendChild(number);
}else{c.textContent="Cannot finish";c.className="pl-compare-denied";}
tr.appendChild(c);
cell(tr,entry.feasible?entry.paired+" pairs + "+entry.direct+" direct checks":
  entry.reason+" ("+entry.slots+" slots required)");
rows.appendChild(tr);
}
const closer=[p.direct,p.paired].filter(z=>z.feasible).sort((a,b)=>a.cost-b.cost)[0];
const full=p.full;
let result;
if(!p.hybrid.feasible){result="No admissible full-batch schedule. Trusted guard and slot constraints fail closed.";}
else if(closer&&p.hybrid.cost<closer.cost){
 const saved=closer.cost-p.hybrid.cost;
 result="Exact modeled gain: "+saved+" evidence-cost units ("+
 (100*saved/Math.max(1,closer.cost)).toFixed(0)+
 "%) versus the best simple impact-aware comparator.";}
else if(closer){result="No cost advantage over the strongest simple comparator in this scenario. The theorem matches its cost; it does not outperform it.";}
else{result="An exact mixed strategy is feasible; the simple comparator policies are blocked by capacity.";}
if(!full.feasible&&p.hybrid.feasible)result+=" Full direct refresh cannot certify the whole legitimate batch by deadline.";
summary.textContent=result;
evidence.textContent="Current evidence price: paired raw reads "+p.pairCost+
 " units per obligation; predicate-only direct "+p.dp+" units. Shared guard and facility fees are excluded from all strategy differences.";
oracle.textContent="Independent finite dynamic-programming optimum: "+
 (x.reference===null?"not feasible":x.reference+" units")+
 ". NIGHTFALL analytic result: "+(p.hybrid.cost===null?"not feasible":p.hybrid.cost+" units")+
 ". "+(x.reference===p.hybrid.cost?"Exact agreement.":"DISAGREEMENT: do not use this result.");
}catch(e){summary.textContent="Invalid benchmark: "+e.message;rows.replaceChildren();}
}
form.addEventListener("change",render);
render();
})();
