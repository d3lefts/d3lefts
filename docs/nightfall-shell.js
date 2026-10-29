/* NIGHTFALL appearance. The existing Join journey owns research context.
   Theme is a local preference; controls occupy document flow, never overlap tools. */
(function(){
"use strict";
const KEY="nightfall.theme.v1",html=document.documentElement;
function read(){try{return localStorage.getItem(KEY)}catch{return null}}
function save(value){try{localStorage.setItem(KEY,value)}catch{}}
let theme=read()==="paper"?"paper":"night";
html.dataset.nfTheme=theme;
function install(){
 if(!document.body||document.querySelector(".nf-shell-controls"))return;
 const wrap=document.createElement("div");wrap.className="nf-shell-controls";
 const toggle=document.createElement("button");toggle.type="button";toggle.className="nf-theme-toggle";
 function paint(){
   toggle.textContent=theme==="night"?"◐ NIGHT":"◑ PAPER";
   toggle.setAttribute("aria-label","Current theme: "+theme+". Switch to "+(theme==="night"?"Paper":"Night")+" theme");
   toggle.setAttribute("aria-pressed",String(theme==="night"));
   toggle.title="Switch NIGHTFALL between Night and Paper; preference saved locally";
 }
 toggle.addEventListener("click",()=>{
   theme=theme==="night"?"paper":"night";html.dataset.nfTheme=theme;save(theme);paint();
 });
 paint();wrap.appendChild(toggle);
 // The existing canonical Join research rail takes precedence where available.
 const rail=document.querySelector(".nf-journey-rail");
 if(rail)rail.appendChild(wrap);
 else {
   const head=document.querySelector("body > header");
   if(head)head.insertAdjacentElement("afterend",wrap);
   else document.body.insertBefore(wrap,document.body.firstChild);
 }
}
if(document.readyState==="loading")document.addEventListener("DOMContentLoaded",install,{once:true});
else install();
})();
