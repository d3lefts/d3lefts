/* NIGHTFALL / scroll cinema controller, v1.
   One bounded section, one rAF at most per frame, passive listeners.
   Read scroll position; write compositor-friendly CSS variables only.
   Hidden/reduced-motion pages incur no animation work. */
(function(){
 "use strict";
 const mount=()=>{
  const scene=document.getElementById("nf-scroll-cinema");
  if(!scene || !window.requestAnimationFrame)return;
  const reduce=window.matchMedia("(prefers-reduced-motion: reduce)");
  const narrow=window.matchMedia("(max-width: 760px)");
  let active=false,frame=0,visible=false,stopped=false,last=-1;
  const clamp=x=>Math.max(0,Math.min(1,x));
  const update=()=>{
   frame=0;
   if(!active || stopped || !visible)return;
   const rect=scene.getBoundingClientRect();
   const travel=Math.max(1,rect.height-window.innerHeight);
   const p=clamp(-rect.top/travel);
   if(Math.abs(p-last)<.00035)return;
   last=p;
   scene.style.setProperty("--nf-progress",p.toFixed(4));
   scene.style.setProperty("--nf-sun-descent",(p*34).toFixed(2)+"vh");
   scene.style.setProperty("--nf-orbit-turn",(-24+p*67).toFixed(2)+"deg");
   scene.style.setProperty("--nf-aurora-rise",(-p*(narrow.matches?48:90)).toFixed(1)+"px");
   scene.style.setProperty("--nf-trace",(1-p).toFixed(4));
   scene.style.setProperty("--nf-trace-opacity",clamp((p-.12)/.7).toFixed(4));
   const chapter=p<.32?"1":p<.68?"2":"3";
   if(scene.dataset.chapter!==chapter)scene.dataset.chapter=chapter;
   const number=scene.querySelector(".nf-cinema-step-number");
   if(number && number.textContent!==chapter+"/03")number.textContent=chapter+"/03";
  };
  const schedule=()=>{
   if(active && visible && !stopped && !frame)frame=requestAnimationFrame(update);
  };
  const observation=new IntersectionObserver(entries=>{
   visible=!!entries[0]?.isIntersecting;
   if(visible)schedule();
  },{rootMargin:"100px 0px 100px 0px",threshold:0});
  const applyPreference=()=>{
   active=!reduce.matches;
   scene.dataset.motion=active?"active":"static";
   if(!active){
    if(frame)cancelAnimationFrame(frame);
    frame=0;
    scene.style.removeProperty("--nf-progress");
    scene.style.removeProperty("--nf-sun-descent");
    scene.style.removeProperty("--nf-orbit-turn");
    scene.style.removeProperty("--nf-aurora-rise");
    scene.style.removeProperty("--nf-trace");
    scene.style.removeProperty("--nf-trace-opacity");
    scene.dataset.chapter="1";
    const number=scene.querySelector(".nf-cinema-step-number");
    if(number)number.textContent="01/03";
   }else{last=-1;schedule()}
  };
  observation.observe(scene);
  document.addEventListener("visibilitychange",()=>{
   stopped=document.hidden;
   if(stopped && frame){cancelAnimationFrame(frame);frame=0}
   else schedule();
  },{passive:true});
  window.addEventListener("scroll",schedule,{passive:true});
  window.addEventListener("resize",()=>{last=-1;schedule()},{passive:true});
  narrow.addEventListener?.("change",()=>{last=-1;schedule()});
  reduce.addEventListener?.("change",applyPreference);
  window.addEventListener("nightfall-theme-change",()=>{last=-1;schedule()});
  applyPreference();
 };
 if(document.readyState==="loading")document.addEventListener("DOMContentLoaded",mount,{once:true});
 else mount();
})();
