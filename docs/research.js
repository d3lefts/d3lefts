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
 update();
})();
