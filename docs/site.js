"use strict";
/* NIGHTFALL shared chrome only.
 * Scientific metadata lives in research-registry.js, and the 33-document
 * library owns its filter renderer. No shadow catalogues in global chrome. */
(() => {
 const menu=document.getElementById("menu-button");
 const nav=document.getElementById("site-nav");
 if(menu&&nav){
  const closeMenu=()=>{
   nav.classList.remove("open");
   menu.setAttribute("aria-expanded","false");
   menu.textContent="MENU +";
  };
  menu.addEventListener("click",()=>{
   const open=nav.classList.toggle("open");
   menu.setAttribute("aria-expanded",String(open));
   menu.textContent=open?"CLOSE −":"MENU +";
  });
  nav.querySelectorAll("a").forEach(a=>a.addEventListener("click",closeMenu));
  document.addEventListener("keydown",e=>{
   if(e.key==="Escape"&&nav.classList.contains("open")){closeMenu();menu.focus();}
  });
  document.addEventListener("click",e=>{
   if(nav.classList.contains("open")&&!nav.contains(e.target)&&!menu.contains(e.target))closeMenu();
  });
 }

 const main=document.querySelector("main");
 const page=location.pathname.split("/").pop()||"index.html";
 // Static top-level navigation is complete without JavaScript; app-owned
 // workbenches own their own chrome. Do not inject duplicate journeys.
 if(!main||["index.html","constellation.html","review.html"].includes(page)||
    document.querySelector("#app")||document.querySelector(".app")||main.closest(".app"))return;

 // Single source for the specialist-page route taxonomy. A destination means
 // where a task belongs, never that it is mathematically complete.
 const destinations=[
  {id:"home",label:"01 / Homepage · Results",href:"index.html#flagships"},
  {id:"constellation",label:"02 / Constellation · Connections",href:"constellation.html#map"},
  {id:"review",label:"03 / Independent Review · Challenge",href:"review.html#priority"}
 ];
 const routes={
  "research.html":"home","living-paper.html":"home","erdos-paper.html":"home",
  "findings-20261029.html":"home","agenda.html":"home","about.html":"home",
  "atlas.html":"constellation","join.html":"constellation",
  "frontier.html":"constellation","discovery.html":"constellation","orchestrator.html":"constellation",
  "claim-lab.html":"constellation","exact-research.html":"constellation","living-investigation.html":"constellation",
  "referee.html":"review","adversary.html":"review","evidence.html":"review",
  "evidence-practice.html":"review","passport.html":"review","judgment-provenance.html":"review"
 };
 const createLink=(href,label)=>{
  const a=document.createElement("a");a.href=href;a.textContent=label;return a;
 };
 // The journey rail is an optional specialist-only return path. It reads
 // whitelisted state; unknown IDs, malformed JSON and untrusted HTML never
 // control link destinations. Join hosts the origin workflow, so only its
 // three-destination breadcrumb is needed.
 let rail=document.querySelector(".nf-journey-rail");
 if(page!=="join.html"&&!rail){
  let title="";
  try{
   const state=JSON.parse(localStorage.getItem("nightfall.journey.v1")||"null");
   const names={"NF-156-184-9":"Maximal Sidon boundary","NF-Q7-R6":"Q7 graph boundary"};
   if(state&&state.version===1&&Object.prototype.hasOwnProperty.call(names,state.rootId))title=names[state.rootId];
  }catch(_){}
  let claimReturn=null;
  try{
   const last=JSON.parse(localStorage.getItem("nightfall.claim.journey.v1")||"null");
   const labels={sidon30:"30-point Sidon",erdos36:"Erdős overlap",phase:"Phase retrieval",adaptive:"Adaptive decoder",werner:"Werner states",pas:"Proof After Scarcity"};
   const target=last?.selected;
   if(last?.version===1&&Object.prototype.hasOwnProperty.call(labels,target?.claimId)&&
      Number.isSafeInteger(target.index)&&target.index>=0&&target.index<20){
    claimReturn={title:labels[target.claimId],url:"join.html?claim="+encodeURIComponent(target.claimId)+"&obligation="+target.index+"#claim-investigation"};
   }
  }catch(_){}
  if(!document.querySelector('link[data-nf-rail-style]')){
   const sheet=document.createElement("link");
   sheet.rel="stylesheet";sheet.href="journey-rail.css";
   sheet.dataset.nfRailStyle="";document.head.append(sheet);
  }
  rail=document.createElement("nav");
  rail.className="nf-journey-rail";
  rail.setAttribute("aria-label","Guided research navigation");
  const tag=document.createElement("span");tag.textContent=claimReturn?"RESUME THIS CLAIM":title?"RESUME RESEARCH":"ONE GUIDED PATH";
  const primary=createLink(claimReturn?claimReturn.url:title?"join.html#workspace":"join.html#results",
   claimReturn?"Return to "+claimReturn.title+" / exact obligation ↗":title?"Return to "+title+" ↗":"Results → process → open problem ↗");
  const gap=document.createElement("span");gap.className="nf-rail-spacer";
  rail.append(tag,primary,gap,createLink("constellation.html","Constellation"),
   createLink("join.html#method","The process"),createLink("join.html#assignment","Find a problem"));
  main.before(rail);
 }
 if(document.querySelector(".nf-process-thread"))return;
 const thread=document.createElement("nav");
 thread.className="nf-process-thread";
 thread.setAttribute("aria-label","Three NIGHTFALL destinations: results, connected mechanisms, independent challenge");
 const inferred=routes[page]||"constellation";
 for(const destination of destinations){
  const a=createLink(destination.href,destination.label);
  if(destination.id===inferred)a.setAttribute("aria-current","page");
  thread.append(a);
 }
 if(page==="join.html"){
  const hero=main.querySelector(".join-hero");
  if(hero)hero.insertAdjacentElement("afterend",thread);
  else main.prepend(thread);
 }else if(rail)rail.insertAdjacentElement("afterend",thread);
 else main.before(thread);
})();
