"use strict";
/* All answer text and links come from the deployed Proof Passport registry. */
(function(){
 const form=document.getElementById("pf-search-form");
 const input=document.getElementById("pf-search-query");
 const status=document.getElementById("pf-search-status");
 const output=document.getElementById("pf-search-output");
 const engine=window.NightfallPortfolioSearch;
 const source=window.NightfallPortfolioCore;
 if(!form||!input||!status||!output||!engine||!source)return;
 const view=source.project(window.NightfallRegistry);
 const el=(tag,cls,value)=>{const x=document.createElement(tag);if(cls)x.className=cls;
   if(value!==undefined)x.textContent=value;return x};
 const href=(url,title)=>{const u=source.safeUrl(url);if(!u)return null;
   const a=el("a","pf-search-link",title);a.href=u;return a};
 function run(){
   const found=engine.search(view,input.value);
   const frag=document.createDocumentFragment();
   if(found.status==="registry_unavailable"){
     status.textContent="Canonical evidence registry unavailable; no answer can be produced.";
     output.replaceChildren(el("p","", "Source registry missing: fail closed."));return;
   }
   if(found.status==="empty"){
     status.textContent="Enter a project name or an evidence term.";
     output.replaceChildren();return;
   }
   if(found.status==="abstain"){
     status.textContent="ABSTAIN · No canonical record contains every requested search term.";
     frag.append(el("p","pf-search-empty","No sourced match. This interface does not invent an answer or search the open web."));
   }else{
     status.textContent="MATCHED · "+found.total+" canonical record(s). Source scope and open obligations follow.";
     for(const item of found.results){
       const article=el("article","pf-search-result");
       const head=el("div","pf-search-result-head");
       head.append(el("h4","",item.title),el("span","",item.validity));
       article.append(head);
       article.append(el("p","pf-search-statement",item.statement));
       const repro=el("p","pf-search-evidence");
       repro.append(el("strong","","Reproduction: "),document.createTextNode(item.reproducibility));
       article.append(repro);
       if(item.conditions){
         const conditions=el("p","pf-search-evidence");
         conditions.append(el("strong","","Conditions: "),document.createTextNode(item.conditions));
         article.append(conditions);
       }
       const open=el("p","pf-search-open");
       open.append(el("strong","","Unresolved: "),document.createTextNode(item.open));
       article.append(open);
       const links=el("div","pf-search-links");
       for(const x of item.sources){const a=href(x.url,x.label+" ↗");if(a)links.append(a)}
       article.append(links);
       if(item.mechanisms.length){
         const kinds=el("p","pf-search-mechanisms","Recorded edges: ");
         kinds.append(document.createTextNode(item.mechanisms
           .map(x=>x.title+" ["+x.relation+"]").join(" · ")));
         article.append(kinds);
       }
       frag.append(article);
     }
   }
   output.replaceChildren(frag);
 }
 form.addEventListener("submit",e=>{e.preventDefault();run()});
 document.querySelectorAll("[data-pf-query]").forEach(button=>button.addEventListener("click",()=>{
   input.value=button.dataset.pfQuery||"";run();input.focus();
 }));
 run();
})();
