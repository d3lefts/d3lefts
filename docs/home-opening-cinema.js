/* NIGHTFALL / Opening scroll cinematography.
   Decorative only: no scroll interception, never alters evidence or focus.
   Passive scroll + one rAF; intersection and reduced-motion gates. */
(function(){
 "use strict";
 const mount=()=>{
  const hero=document.querySelector("#main > .hero.nf-opening");
  if(!hero || !window.requestAnimationFrame || !window.matchMedia || !window.IntersectionObserver)return;
  const reduce=window.matchMedia("(prefers-reduced-motion: reduce)");
  let visible=false,paused=document.hidden,frame=0,last=-1;
  const clamp=n=>Math.min(1,Math.max(0,n));
  const props=["--nf-open-sky-y","--nf-open-sun-y","--nf-open-ring-turn",
    "--nf-open-constellation-y","--nf-open-trace","--nf-open-stars",
    "--nf-open-gold","--nf-open-tide-y","--nf-open-progress"];
  function paint(){
   frame=0;
   if(paused || reduce.matches || !visible)return;
   const rect=hero.getBoundingClientRect();
   const height=Math.max(1,rect.height-Math.min(window.innerHeight*.25,180));
   const p=clamp(-rect.top/height);
   if(Math.abs(p-last)<.0005)return;
   last=p;
   hero.style.setProperty("--nf-open-progress",p.toFixed(4));
   hero.style.setProperty("--nf-open-sky-y",(-p*55).toFixed(2)+"px");
   hero.style.setProperty("--nf-open-sun-y",(p*145).toFixed(2)+"px");
   hero.style.setProperty("--nf-open-ring-turn",(-19+p*45).toFixed(2)+"deg");
   hero.style.setProperty("--nf-open-tide-y",(p*33).toFixed(2)+"px");
   hero.style.setProperty("--nf-open-gold",(.45+p*.23).toFixed(3));
   hero.style.setProperty("--nf-open-constellation-y",(22-p*67).toFixed(2)+"px");
   hero.style.setProperty("--nf-open-trace",(1-p).toFixed(4));
   hero.style.setProperty("--nf-open-stars",(.18+p*.7).toFixed(3));
  }
  function request(){
   if(!paused && visible && !reduce.matches && !frame)frame=requestAnimationFrame(paint);
  }
  function preference(){
   if(reduce.matches){
    if(frame)cancelAnimationFrame(frame);
    frame=0;last=-1;
    props.forEach(name=>hero.style.removeProperty(name));
    hero.dataset.openingMotion="static";
   }else{
    hero.dataset.openingMotion="active";
    last=-1;request();
   }
  }
  const observer=new IntersectionObserver(entries=>{
   visible=!!entries[0]?.isIntersecting;
   if(visible){last=-1;request();}
  },{threshold:0,rootMargin:"90px 0px 90px 0px"});
  observer.observe(hero);
  document.addEventListener("visibilitychange",()=>{
   paused=document.hidden;
   if(paused && frame){cancelAnimationFrame(frame);frame=0;}
   if(!paused)request();
  });
  window.addEventListener("scroll",request,{passive:true});
  window.addEventListener("resize",()=>{last=-1;request()},{passive:true});
  reduce.addEventListener?.("change",preference);
  window.addEventListener("nightfall-theme-change",()=>{last=-1;request()});
  preference();
 };
 if(document.readyState==="loading")document.addEventListener("DOMContentLoaded",mount,{once:true});
 else mount();
})();