"use strict";
(async()=>{
 const grid=document.getElementById("nr-grid"), search=document.getElementById("nr-search"), summary=document.getElementById("nr-summary");
 if(!grid)return;
 let data;try{const res=await fetch("recent-research.json",{cache:"no-store"});if(!res.ok)throw new Error("HTTP "+res.status);data=await res.json();}catch(e){summary.textContent="The machine ledger could not be loaded. Open the JSON registry directly.";return;}
 const tiers=new Set(["merged-lean","branch-lean","analytic","pending"]);let active="all";
 const el=(tag,cls,txt)=>{const x=document.createElement(tag);if(cls)x.className=cls;if(txt!==undefined)x.textContent=txt;return x;};
 const link=(txt,url)=>{const a=el("a","nr-link",txt);a.href=url;a.rel="noopener noreferrer";return a;};
 const cards=(data.claims||[]).filter(c=>tiers.has(c.tier));
 function update(){const q=(search?.value||"").trim().toLowerCase();grid.replaceChildren();let n=0;
  for(const c of cards){if(active!=="all"&&c.tier!==active)continue;if(q&&![c.title,c.claim,c.scope,c.mechanism,c.limit,c.id].join(" ").toLowerCase().includes(q))continue;n++;
   const article=el("article","nr-card");article.id=c.id;
   const top=el("div","nr-card-top");top.append(el("span","nr-state nr-"+c.tier,c.status_label),el("span","nr-id",c.id));article.append(top,el("h2","",c.title),el("p","nr-claim",c.claim));
   const facts=el("dl","nr-facts");for(const [key,value] of [["Scope",c.scope],["Mechanism",c.mechanism],["Evidence",c.certificate],["Limit",c.limit],["Next decisive audit",c.next]]){const item=el("div");item.append(el("dt","",key),el("dd","",value));facts.append(item);}article.append(facts);
   const links=el("div","nr-links");links.append(link("Proof Passport",c.passport),link("Source PR #"+c.pr,c.source));if(c.receipt)links.append(link("Pinned Lean run",c.receipt));article.append(links);grid.append(article);
  }
  summary.textContent=n+" of "+cards.length+" source-scoped claims displayed";if(!n)grid.append(el("p","nr-empty","No claims match these filters."));
 }
 document.querySelectorAll("[data-nr-filter]").forEach(b=>b.addEventListener("click",()=>{active=b.dataset.nrFilter;document.querySelectorAll("[data-nr-filter]").forEach(x=>x.setAttribute("aria-pressed",String(x===b)));update();}));
 search?.addEventListener("input",update);update();
})();
