"use strict";
(function(){
  const core=window.NFPermissionCore;
  const f=document.querySelector("#pl-cost-form");
  if(!core || !f) return;
  const numeric={};
  for (const el of f.querySelectorAll("input[data-number]")) numeric[el.name]=el;
  const result=document.querySelector("#pl-cost-result");
  const detail=document.querySelector("#pl-cost-detail");
  const worldsOut=document.querySelector("#pl-worlds");
  const proofOut=document.querySelector("#pl-proof-result");
  const options=["left","right","direct"];
  const toText=(value)=>new Intl.NumberFormat("en-US").format(value);
  function recalc(){
    try {
      const input={};
      for(const name in numeric) input[name]=numeric[name].value;
      const p=core.price(input);
      result.textContent=p.feasible?toText(p.total)+" modeled cost units":"NOT FEASIBLE";
      detail.textContent=p.feasible?
        "Fresh obligations R="+p.R+"; remaining slots K="+p.K+
        "; paired checks="+p.paired+"; predicate-only checks="+p.direct+
        "; evidence cost="+toText(p.evidence)+
        "; facility/guard cost="+toText(p.installation)+
        "; sunk cost="+toText(p.sunkCost)+
        "; difference vs all-direct="+toText(p.savingsAgainstAllDirect)+"."
        :p.reason+". R="+p.R+"; K="+p.K+". The model denies full timely admission.";
    } catch(error) {
      result.textContent="INVALID INPUT";
      detail.textContent=error.message;
    }
    try {
      const changed=document.querySelector("#pl-changed").checked;
      const enabled=Object.fromEntries(options.map(n=>[n,document.querySelector("#pl-allow-"+n).checked]));
      const costs={left:4,right:4,direct:9};
      const p=core.leastDisclosure(changed,enabled,costs);
      worldsOut.textContent="Possible worlds: "+p.worlds.join(", ")+
        ". Nominal permitted world: 00. Right-only evidence: "+
        (p.validRightOnly?"sufficient":"insufficient")+
        (p.rightOnlyIndistinguishable.length?" (unsafe indistinguishable world(s): "+p.rightOnlyIndistinguishable.join(", ")+").":".");
      proofOut.textContent=p.best?
        "Least-cost sufficient observation: "+(p.best.channels.length?p.best.channels.join(" + "):"none")+
        " · cost "+p.best.cost+". Status: "+p.status+"."
        :"Indeterminate: no enabled observation distinguishes the nominal permitted world from every possible unsafe world. Do not authorize.";
    } catch(error) {
      proofOut.textContent="INVALID FINITE MODEL: "+error.message;
    }
  }
  f.addEventListener("input",recalc);
  document.querySelector("#pl-world-form").addEventListener("change",recalc);
  recalc();
})();
