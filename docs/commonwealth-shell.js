"use strict";
/* Commonwealth navigation only. No NIGHTFALL state, analytics, or remote requests. */
(()=>{
  const menu=document.getElementById("menu-button");
  const nav=document.getElementById("site-nav");
  if(!menu||!nav)return;
  const close=()=>{nav.classList.remove("open");menu.setAttribute("aria-expanded","false");menu.textContent="MENU +";};
  menu.addEventListener("click",()=>{
    const open=nav.classList.toggle("open");
    menu.setAttribute("aria-expanded",String(open));menu.textContent=open?"CLOSE −":"MENU +";
  });
  nav.querySelectorAll("a").forEach(link=>link.addEventListener("click",close));
  document.addEventListener("keydown",e=>{if(e.key==="Escape"&&nav.classList.contains("open")){close();menu.focus();}});
  document.addEventListener("click",e=>{if(nav.classList.contains("open")&&!nav.contains(e.target)&&!menu.contains(e.target))close();});
})();
