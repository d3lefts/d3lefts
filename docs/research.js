"use strict";
(() => {
 const cards=[...document.querySelectorAll(".atlas-card")];
 const buttons=[...document.querySelectorAll("[data-atlas-filter]")];
 const search=document.getElementById("atlas-search");
 const counter=document.getElementById("atlas-counter");
 const empty=document.getElementById("atlas-empty");
 let category="all";
 function update(){
  const text=(search?.value||"").trim().toLocaleLowerCase();
  let count=0;
  cards.forEach(card=>{
   const show=(category==="all"||card.dataset.domain===category)&&(!text||card.dataset.search.includes(text));
   card.hidden=!show;
   if(show)count++;
  });
  document.querySelectorAll(".atlas-group").forEach(group=>{
   group.hidden=![...group.querySelectorAll(".atlas-card")].some(card=>!card.hidden);
  });
  if(counter)counter.textContent=count+" research line"+(count===1?"":"s")+" shown";
  if(empty)empty.hidden=count!==0;
 }
 buttons.forEach(b=>b.addEventListener("click",()=>{
  category=b.dataset.atlasFilter;
  buttons.forEach(x=>x.setAttribute("aria-pressed",String(x===b)));
  update();
 }));
 search?.addEventListener("input",update);
 update();
})();
