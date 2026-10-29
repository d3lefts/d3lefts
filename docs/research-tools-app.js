/* Offline research workbench browser bindings; all result insertion uses textContent. */
"use strict";
(function () {
  const core = globalThis.NIGHTFALL_EXACT;
  if (!core) return;
  const $ = id => document.getElementById(id);
  const rankTwo = [["0000","0000",4],["0000","1111",1],["1000","2121",1],["0000","0121",1]];
  const zeroInformation = {rows:[[[0,0],[0,0]]],signal:[[1,0],[1,0]]};
  let lastWerner = null, lastField = null;
  function print(id, fn) {
    const out = $(id + "-output");
    try {
      const value = fn(JSON.parse($(id + "-input").value));
      out.textContent = JSON.stringify(value, null, 2);
      out.classList.remove("error");
      $(id + "-export").disabled = false;
      if (id === "werner") lastWerner = {input:JSON.parse($(id+"-input").value),result:value};
      else lastField = {input:JSON.parse($(id+"-input").value),result:value};
    } catch (error) {
      out.textContent = "Input rejected: " + error.message;
      out.classList.add("error");
      $(id + "-export").disabled = true;
      if (id === "werner") lastWerner = null; else lastField = null;
    }
  }
  function exportReceipt(id, payload) {
    if (!payload) return;
    const receipt = {format:"nightfall-exact-local-receipt-v1",createdAt:new Date().toISOString(),
      computedBy:"local browser arithmetic; no independent signoff",...payload};
    const file = new Blob([JSON.stringify(receipt,null,2)],{type:"application/json"});
    const u = URL.createObjectURL(file), a = document.createElement("a");
    a.href=u; a.download="NIGHTFALL_"+id+"_exact_receipt.json";
    document.body.appendChild(a); a.click(); a.remove();
    setTimeout(() => URL.revokeObjectURL(u),1000);
  }
  $("werner-run").addEventListener("click",()=>print("werner",core.werner));
  $("field-run").addEventListener("click",()=>print("field",core.f25));
  $("werner-rank2").addEventListener("click",()=>{ $("werner-input").value=JSON.stringify(rankTwo,null,2);print("werner",core.werner); });
  $("field-ambiguous").addEventListener("click",()=>{ $("field-input").value=JSON.stringify(zeroInformation,null,2);print("field",core.f25); });
  $("werner-export").addEventListener("click",()=>exportReceipt("werner",lastWerner));
  $("field-export").addEventListener("click",()=>exportReceipt("f25",lastField));
  for (const id of ["werner","field"]) $(""+id+"-input").addEventListener("input",()=>{
    $(id+"-export").disabled=true; if(id==="werner")lastWerner=null; else lastField=null;
  });
})();