"use strict";
(() => {
 const cards=[...document.querySelectorAll(".atlas-card")];
 const buttons=[...document.querySelectorAll("[data-atlas-filter]")];
 const search=document.getElementById("atlas-search");
 const counter=document.getElementById("atlas-counter");
 const evidence=document.getElementById("atlas-evidence");
 const empty=document.getElementById("atlas-empty");
 let category="all";
 function update(){
  const text=(search?.value||"").trim().toLocaleLowerCase();
  let count=0;
  cards.forEach(card=>{
   const show=(category==="all"||card.dataset.domain===category)&&(evidence?.value==="all"||card.dataset.evidence===evidence?.value)&&(!text||card.dataset.search.includes(text));
   card.hidden=!show;
   if(show)count++;
  });
  document.querySelectorAll(".atlas-group").forEach(group=>{
   group.hidden=![...group.querySelectorAll(".atlas-card")].some(card=>!card.hidden);
  });
  if(counter)counter.textContent=count+" source document"+(count===1?"":"s")+" shown";
  if(empty)empty.hidden=count!==0;
 }
 buttons.forEach(b=>b.addEventListener("click",()=>{
  category=b.dataset.atlasFilter;
  buttons.forEach(x=>x.setAttribute("aria-pressed",String(x===b)));
  update();
 }));
 evidence?.addEventListener("change",update);
 search?.addEventListener("input",update);
 document.addEventListener("keydown",event=>{
  const target=event.target;
  const editing=target instanceof HTMLElement && (target.isContentEditable || ["INPUT","TEXTAREA","SELECT"].includes(target.tagName));
  if(event.key==="/" && !editing && !event.ctrlKey && !event.altKey && !event.metaKey){
    event.preventDefault();search?.focus();
  }else if(event.key==="Escape" && document.activeElement===search && search?.value){
    event.preventDefault();search.value="";update();
  }
 });
 // Claim identities are explicit in the published library HTML, rather than
 // inferred from headings, which editors may legitimately rename. The Proof
 // Passport registry owns scope and evidence status for these six records.
 const registry=window.NightfallRegistry;
 if(registry){
  for(const card of document.querySelectorAll(".atlas-card[data-claim-id]")){
   const id=card.dataset.claimId,record=registry.claimById(id);
   if(!record||card.querySelector(".atlas-passport-link"))continue;
   const boundary=card.querySelector(".atlas-boundary p");
   if(boundary)boundary.textContent=record.conditions+" Current evidence: "+record.validity.detail;
   const a=document.createElement("a");
   a.href="passport.html?claim="+encodeURIComponent(record.id);
   a.className="atlas-passport-link";
   a.textContent="Inspect four-dimensional Proof Passport ↗";
   card.append(a);
   card.dataset.search+=" "+[record.kind,record.short,record.validity.label,record.originality.label].join(" ").toLocaleLowerCase();
  }
 }
 update();
})();
