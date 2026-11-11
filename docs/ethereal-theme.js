/* Named dark atmospheres. Keep historical light/dusk storage values for compatibility. */
(function(){
"use strict";
const KEY="nightfall.theme.v1";
const LIGHT="light", DUSK="dusk";
const doc=document.documentElement;
const meta=document.querySelector('meta[name="theme-color"]');
const originalMeta=meta ? meta.content : null;
function saved(){
  try {return localStorage.getItem(KEY)===LIGHT?LIGHT:DUSK;}
  catch (_) {return DUSK;}
}
function persist(value){
  try {localStorage.setItem(KEY,value);} catch (_) {}
}
const experience=doc.getAttribute("data-nf-experience");
let current=experience==="archive"?LIGHT:experience==="moon"?DUSK:saved();
if(experience)persist(current);
function apply(value){
  current=value===DUSK?DUSK:LIGHT;
  if(current===DUSK)doc.setAttribute("data-nf-theme",DUSK);
  else doc.removeAttribute("data-nf-theme");
  if(meta)meta.content=current===DUSK?"#04060b":"#020406";
  if(document.body?.classList.contains("co-page"))document.body.dataset.theme=current===DUSK?"dark":"light";
  window.dispatchEvent(new Event("nightfall-theme-change"));
  const button=document.querySelector(".nf-theme-toggle");
  if(button){
    const active=current===DUSK;
    // On the two entrances this navigates between research roles. On shared
    // pages it only changes palette; evidence status never changes.
    button.setAttribute("aria-pressed",String(active));
    const onHome=experience==="archive"||experience==="moon";
    button.setAttribute("aria-label",active
      ?onHome?"NEW MOON is active. Open NULL FIELD — Active research homepage.":"Warm Night palette is active. Switch to Deep Space palette on this page."
      :onHome?"NULL FIELD is active. Open NEW MOON — Archived breakthroughs homepage.":"Deep Space palette is active. Switch to Warm Night palette on this page.");
    button.title=active
      ?onHome?"Open NULL FIELD / Active research":"Use Deep Space palette · stay on this page"
      :onHome?"Open NEW MOON / Archived research":"Use Warm Night palette · stay on this page";
    button.querySelector(".nf-theme-symbol").textContent=active?"✧":"☾";
    button.querySelector(".nf-theme-word").textContent=active?"NULL FIELD":"NEW MOON";
  }
}
apply(current);
function mount(){
  if(document.querySelector(".nf-theme-toggle"))return;
  const button=document.createElement("button");
  button.type="button";
  button.className="nf-theme-toggle";
  // On shared documents this is a palette control, not the experience
  // selector; the dedicated destination nav chooses separate homepages.
  button.dataset.nfControl=experience==="archive"||experience==="moon"?"experience":"palette";
  button.innerHTML='<span class="nf-theme-symbol" aria-hidden="true"></span><span class="nf-theme-word" aria-hidden="true"></span>';
  const header=document.querySelector(".header-inner");
  const menu=header && header.querySelector("#menu-button");
  const toolActions=document.querySelector(".topActions");
  if(header)header.insertBefore(button,menu||header.querySelector(".nav")||null);
  else if(toolActions)toolActions.prepend(button);
  else {
    button.classList.add("nf-theme-floating");
    document.body.append(button);
  }
  button.addEventListener("click",function(){
    const next=current===DUSK?LIGHT:DUSK;
    persist(next);
    if(experience==="archive"||experience==="moon"){
      window.location.assign(next===DUSK?"new-moon.html":"index.html");
      return;
    }
    if(!window.matchMedia?.("(prefers-reduced-motion: reduce)").matches){
      doc.classList.add("nf-theme-transit");
      setTimeout(()=>doc.classList.remove("nf-theme-transit"),780);
    }
    apply(next);
  });
  apply(current);
  document.querySelectorAll(".nf-home-route-nav [data-nf-route]").forEach(function(link){
    link.addEventListener("click",function(){
      persist(link.getAttribute("data-nf-route")==="moon"?DUSK:LIGHT);
    });
  });
}
if(document.readyState==="loading")document.addEventListener("DOMContentLoaded",mount,{once:true});
else mount();
window.addEventListener("storage",function(event){
  if(event.key===KEY&&!experience)apply(event.newValue===LIGHT?LIGHT:DUSK);
});
})();
