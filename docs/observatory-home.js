/* Evidence-linked homepage constellation; navigation only, never proof. */
"use strict";
(() => {
 const R=window.NightfallRegistry,field=document.getElementById("nf-observatory-field"),pane=document.getElementById("nf-observatory-inspector");
 if(!field||!pane)return;
 if(!R?.claims?.length||!R?.mechanisms?.length||!Array.isArray(R.edges))return;
 const nodes=new Map(),svg=document.createElementNS("http://www.w3.org/2000/svg","svg");
 svg.setAttribute("class","nf-observatory-lines");svg.setAttribute("aria-hidden","true");field.replaceChildren(svg);
 const make=(tag,cls,value)=>{const e=document.createElement(tag);if(cls)e.className=cls;if(value!==undefined)e.textContent=value;return e;};
 const safe=(url)=>typeof url==="string"&&(/^(https:\/\/github\.com\/d3lefts\/d3lefts\/|https:\/\/www\.erdosproblems\.com\/|https:\/\/oeis\.org\/)/.test(url)||/^[a-z0-9-]+\.html(?:[?#][a-z0-9?&=_#-]*)?$/i.test(url));
 const a=(title,url)=>{if(!safe(url))return null;const el=make("a","",title);el.href=url;if(url.startsWith("https:")){el.target="_blank";el.rel="noopener noreferrer";}return el;};
 for(const [kind,array] of [["claim",R.claims],["mechanism",R.mechanisms]]){
  array.forEach((rec,i)=>{const b=make("button","nf-observatory-node");b.type="button";b.dataset.kind=kind;b.dataset.node=rec.id;b.style.setProperty("--n-y",(12+i*76/Math.max(1,array.length-1))+"%");b.setAttribute("aria-pressed","false");
   const label=make("span","nf-observatory-node-text");
   label.append(make("small","",kind==="claim"?"CLAIM / "+(rec.validity?.level||"CURATED").toUpperCase():"MECHANISM / "+(rec.kind==="analogy"?"ANALOGY":"METHOD")),make("strong","",rec.title));
   const star=make("span","nf-observatory-star");star.setAttribute("aria-hidden","true");b.append(star,label);field.append(b);nodes.set(rec.id,b);b.addEventListener("click",()=>choose(rec.id));
  });
 }
 document.getElementById("nf-observatory-count").textContent=R.claims.length+" scoped claims · "+R.mechanisms.length+" mechanisms · "+R.edges.length+" sourced relationships";
 let selected=null,frame=0;
 function inspect(){
  const rec=R.claimById(selected)||R.mechanismById(selected);pane.replaceChildren();
  if(!rec){pane.append(make("small","nf-observatory-label","CURATED SCIENTIFIC MEMORY"),make("h3","","Every connection has a condition."),make("p","","Choose any star to inspect its scope, status, and supporting relationships. An untested analogy and an unresolved premise remain visibly distinct from exact finite evidence."));pane.append(a("Open the complete source-linked map ↗","constellation.html"));return;}
  pane.append(make("small","nf-observatory-label",R.claimById(selected)?"SCOPED CLAIM / CANONICAL RECORD":"RESEARCH MECHANISM / SCOPE"),make("h3","",rec.title),make("p","",rec.short||rec.description||""),make("div","nf-observatory-scope",rec.conditions||rec.scope||"Review the published scope."));
  const list=make("div","nf-observatory-relations");
  const edges=R.edges.filter(e=>e.from===selected||e.to===selected);
  list.append(make("small","nf-observatory-label",edges.length+" SOURCED RELATIONSHIPS"));
  const kinds={"finite-check":"FINITE CHECK",method:"DOCUMENTED METHOD",analogy:"UNTESTED ANALOGY","open-premise":"UNRESOLVED PREMISE"};
  edges.forEach(edge=>{const item=make("div","nf-observatory-relation");item.dataset.relation=edge.relation;item.append(make("b","",kinds[edge.relation]||"SOURCED RELATION"),make("span","",edge.label));const source=a("Source ↗",edge.source);if(source)item.append(source);list.append(item);});
  pane.append(list);
  const links=make("div","nf-observatory-actions");
  if(R.claimById(selected))links.append(a("Proof Passport ↗","passport.html?claim="+encodeURIComponent(selected)));
  links.append(a("Full constellation ↗","constellation.html"+(R.claimById(selected)?"?claim="+encodeURIComponent(selected):"")));pane.append(links);
 }
 function draw(){
  frame=0;const box=field.getBoundingClientRect();if(!box.width||!box.height)return;
  svg.setAttribute("viewBox","0 0 "+box.width+" "+box.height);svg.replaceChildren();
  R.edges.filter(e=>!selected||e.from===selected||e.to===selected).forEach(edge=>{
   const from=nodes.get(edge.from)?.querySelector(".nf-observatory-star"),to=nodes.get(edge.to)?.querySelector(".nf-observatory-star");if(!from||!to)return;
   const f=from.getBoundingClientRect(),t=to.getBoundingClientRect(),x1=f.left+f.width/2-box.left,y1=f.top+f.height/2-box.top,x2=t.left+t.width/2-box.left,y2=t.top+t.height/2-box.top,bend=(x2-x1)*.41;
   const path=document.createElementNS("http://www.w3.org/2000/svg","path");path.setAttribute("d","M "+x1+" "+y1+" C "+(x1+bend)+" "+y1+" "+(x2-bend)+" "+y2+" "+x2+" "+y2);
   path.setAttribute("class","nf-observatory-edge edge-"+edge.relation+(selected?" selected":""));svg.append(path);
  });
 }
 function schedule(){if(frame)cancelAnimationFrame(frame);frame=requestAnimationFrame(draw);}
 function choose(id){
  selected=selected===id?null:id;const related=new Set(R.edges.filter(e=>!selected||e.from===selected||e.to===selected).flatMap(e=>[e.from,e.to]));
  nodes.forEach((button,key)=>{button.setAttribute("aria-pressed",String(key===selected));button.classList.toggle("is-dim",!!selected&&!related.has(key));});
  inspect();schedule();
 }
 choose(null);window.addEventListener("resize",schedule,{passive:true});window.addEventListener("nightfall-theme-change",schedule);
 if("ResizeObserver" in window)new ResizeObserver(schedule).observe(field);
})();
