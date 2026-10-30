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
let current=saved();
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
    // Consistent destinations on every route. aria-pressed continues to
    // represent the active New Moon atmosphere; accessible copy names both.
    button.setAttribute("aria-pressed",String(active));
    button.setAttribute("aria-label",active
      ?"New Moon is active. Switch to NULL FIELD — Deep Space, with constellations."
      :"NULL FIELD is active. Switch to NEW MOON — Warm Night, with moonlight.");
    button.title=active
      ?"NULL FIELD / Deep Space · constellations"
      :"NEW MOON / Warm Night · moonlight";
    button.querySelector(".nf-theme-symbol").textContent=active?"✧":"☾";
    button.querySelector(".nf-theme-word").textContent=active?"ARCHIVE":"MOON";
  }
}
apply(current);
function mount(){
  if(document.querySelector(".nf-theme-toggle"))return;
  const button=document.createElement("button");
  button.type="button";
  button.className="nf-theme-toggle";
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
    if(!window.matchMedia?.("(prefers-reduced-motion: reduce)").matches){
      doc.classList.add("nf-theme-transit");
      setTimeout(()=>doc.classList.remove("nf-theme-transit"),780);
    }
    apply(next);
  });
  apply(current);
}
if(document.readyState==="loading")document.addEventListener("DOMContentLoaded",mount,{once:true});
else mount();
window.addEventListener("storage",function(event){
  if(event.key===KEY)apply(event.newValue===LIGHT?LIGHT:DUSK);
});
})();
