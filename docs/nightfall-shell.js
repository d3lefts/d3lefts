/* NIGHTFALL shell: theme preference + opt-in investigation return.
   No claim or proof-status mutation; storage is browser-local and fallible. */
(function(){
 "use strict";
 const THEME="nightfall.theme.v1",SESSION="nightfall.investigation.v1";
 const html=document.documentElement;
 function read(key){try{return localStorage.getItem(key)}catch{return null}}
 function write(key,value){try{localStorage.setItem(key,value)}catch{}}
 let theme=read(THEME)==="paper"?"paper":"night";
 html.dataset.nfTheme=theme;
 function build(){
   if(!document.body||document.querySelector(".nf-shell-controls"))return;
   const controls=document.createElement("div");
   controls.className="nf-shell-controls";
   const toggle=document.createElement("button");
   toggle.type="button";toggle.className="nf-theme-toggle";
   function paint(){
      toggle.textContent=theme==="night"?"◐ NIGHT":"◑ PAPER";
      toggle.setAttribute("aria-label","Current theme: "+theme+". Switch to "+(theme==="night"?"Paper":"Night")+" theme");
      toggle.setAttribute("aria-pressed",String(theme==="night"));
      toggle.title="Toggle NIGHTFALL appearance; browser-local preference";
   }
   toggle.addEventListener("click",()=>{
      theme=theme==="night"?"paper":"night";
      html.dataset.nfTheme=theme;write(THEME,theme);paint();
      document.dispatchEvent(new CustomEvent("nightfall:themechange",{detail:{theme}}));
   });
   paint();controls.appendChild(toggle);
   // Controls consume their own document space; never overlay research form actions.
   const header=document.querySelector("body > header");
   if(header)header.insertAdjacentElement("afterend",controls);
   else document.body.insertBefore(controls,document.body.firstChild);
   if(location.pathname.endsWith("/investigate.html"))return;
   let session;
   try{session=JSON.parse(read(SESSION)||"null")}catch{return}
   if(!session||!["sidon","cycles","audit"].includes(session.id)||!["construct","challenge","verify"].includes(session.role))return;
   const titles={sidon:"SIDON / 9-MARK FRONTIER",cycles:"ERDŐS / CYCLE FRONTIER",audit:"FINITE WITNESS / REPLAY"};
   const a=document.createElement("a");a.className="nf-journey-return";
   a.href="investigate.html";a.setAttribute("aria-label","Return to current NIGHTFALL investigation");
   const strong=document.createElement("strong");strong.textContent="← CONTINUE";
   const span=document.createElement("span");span.textContent=titles[session.id]||"INVESTIGATION";
   a.append(strong,span);controls.insertBefore(a,toggle);
 }
 if(document.readyState==="loading")document.addEventListener("DOMContentLoaded",build,{once:true});
 else build();
})();
