/* NIGHTFALL / FIELD GUIDE
   A source-linked research map, never a mathematical inference engine.
   Every claim, status, premise, mechanism and edge comes from NightfallRegistry.
   No invented evidence, remote calls, or persistent graph state. */
"use strict";
(() => {
 const R=window.NightfallRegistry;
 const field=document.getElementById("nf-observatory-field");
 const pane=document.getElementById("nf-observatory-inspector");
 const controls=document.getElementById("nf-observatory-lenses");
 const summary=document.getElementById("nf-observatory-view-status");
 if(!field||!pane||!controls||!R?.claims?.length||!R?.mechanisms?.length||!Array.isArray(R.edges))return;
 const kinds={"finite-check":"FINITE CHECK","method":"DOCUMENTED METHOD","open-premise":"UNRESOLVED PREMISE","analogy":"UNTESTED ANALOGY"};
 const descriptions={
  all:"All documented relationships · line styles preserve the source classification",
  "finite-check":"Exact finite checks · specific inputs and predicates only",
  method:"Documented practices · shared method is not a theorem transfer",
  "open-premise":"Unresolved premises · assumptions that still require proof or review",
  analogy:"Untested analogies · conceptual similarities without established transfer"
 };
 const labels={all:"All relationships","finite-check":"Finite checks",method:"Methods","open-premise":"Open premises",analogy:"Analogies"};
 const nodes=new Map();
 const svg=document.createElementNS("http://www.w3.org/2000/svg","svg");
 svg.classList.add("nf-observatory-lines");svg.setAttribute("aria-hidden","true");
 const make=(tag,cls,value)=>{
  const element=document.createElement(tag);
  if(cls)element.className=cls;
  if(value!==undefined)element.textContent=String(value);
  return element;
 };
 // Allow canonical local pages and known evidence hosts only. No URL based on untrusted labels.
 const safe=url=>typeof url==="string"&&(
  /^(https:\/\/github\.com\/d3lefts\/d3lefts\/|https:\/\/www\.erdosproblems\.com\/|https:\/\/oeis\.org\/)/.test(url)||
  /^[a-z0-9-]+\.html(?:[?#][a-z0-9?&=_#-]*)?$/i.test(url));
 const link=(title,url)=>{
  if(!safe(url))return null;
  const a=make("a","",title);a.href=url;
  if(url.startsWith("https:")){a.target="_blank";a.rel="noopener noreferrer";}
  return a;
 };
 field.replaceChildren(svg);
 for(const [kind,array] of [["claim",R.claims],["mechanism",R.mechanisms]]){
  array.forEach((rec,i)=>{
   const button=make("button","nf-observatory-node");
   button.type="button";button.dataset.kind=kind;button.dataset.node=rec.id;
   button.style.setProperty("--n-y",(12+i*76/Math.max(1,array.length-1))+"%");
   button.setAttribute("aria-pressed","false");
   button.setAttribute("aria-label",rec.title+". "+(kind==="claim"?rec.validity?.label||"Curated claim":rec.kind==="analogy"?"Untested analogy":"Research mechanism"));
   const label=make("span","nf-observatory-node-text");
   label.append(make("small","",kind==="claim"?"CLAIM / "+(rec.validity?.level||"CURATED").toUpperCase():"MECHANISM / "+(rec.kind==="analogy"?"ANALOGY":"METHOD")),make("strong","",rec.title));
   const star=make("span","nf-observatory-star");star.setAttribute("aria-hidden","true");
   button.append(star,label);field.append(button);
   nodes.set(rec.id,button);button.addEventListener("click",()=>choose(rec.id,true));
  });
 }
 document.getElementById("nf-observatory-count").textContent=R.claims.length+" scoped claims · "+R.mechanisms.length+" mechanisms · "+R.edges.length+" sourced relationships";
 let selected=null,filter="all",frame=0;
 const match=()=>R.edges.filter(e=>(filter==="all"||e.relation===filter)&&(!selected||e.from===selected||e.to===selected));
 const nameOf=id=>R.claimById(id)?.title||R.mechanismById(id)?.title||id;
 const row=(edge)=>{
  const item=make("div","nf-observatory-relation");
  item.dataset.relation=edge.relation;
  item.append(make("b","",kinds[edge.relation]||"SOURCED RELATION"),make("span","",edge.label));
  const counterpart=make("small","nf-observatory-counterpart",nameOf(edge.from)+" → "+nameOf(edge.to));
  item.append(counterpart);
  const source=link("Inspect source ↗",edge.source);
  if(source)item.append(source);
  return item;
 };
 function initial(){
  pane.append(
   make("small","nf-observatory-label","FIELD GUIDE / WHERE TO BEGIN"),
   make("h3","","Follow a claim to its boundary."),
   make("p","","A finite witness is different from a theorem. A shared mechanism is different from a transfer. Select a starting point to trace what survives scrutiny.")
  );
  const paths=make("div","nf-observatory-paths");
  const options=[
   {id:"sidon30",kind:"FINITE WITNESS",title:"Inspect an exact construction",desc:"A published 30-point example with a separately auditable finite check."},
   {id:"phase",kind:"OPEN PROOF GATE",title:"Find the missing premise",desc:"A conditional decoder whose span-count obligation remains open."}
  ];
  for(const choice of options){
   if(!R.claimById(choice.id))continue;
   const button=make("button","nf-observatory-path");
   button.type="button";button.dataset.start=choice.id;
   button.append(make("small","",choice.kind),make("strong","",choice.title),make("span","",choice.desc));
   button.addEventListener("click",()=>choose(choice.id,true));paths.append(button);
  }
  pane.append(paths);
  const map=link("Explore the full source-linked constellation ↗","constellation.html");
  if(map)pane.append(map);
 }
 function inspect(){
  pane.replaceChildren();
  const rec=R.claimById(selected)||R.mechanismById(selected);
  if(!rec){initial();return;}
  const isClaim=!!R.claimById(selected);
  const eyebrow=make("small","nf-observatory-label",isClaim?"SCOPED CLAIM / CANONICAL RECORD":"RESEARCH MECHANISM / SCOPE");
  const close=make("button","nf-observatory-clear","× Clear selection");
  close.type="button";close.setAttribute("aria-label","Clear selected research node");
  close.addEventListener("click",()=>choose(null,true));
  const top=make("div","nf-observatory-selection-top");top.append(eyebrow,close);
  pane.append(top,make("h3","",rec.title),make("p","",rec.short||rec.description||""),
   make("div","nf-observatory-scope",rec.conditions||rec.scope||"Review the canonical statement and scope."));
  if(isClaim){
   const validity=make("p","nf-observatory-validity","Evidence status: "+(rec.validity?.label||"See Proof Passport"));
   pane.append(validity);
  }
  const edges=match(),list=make("div","nf-observatory-relations");
  list.append(make("small","nf-observatory-label",edges.length+" RELATIONSHIP"+(edges.length===1?"":"S")+" IN "+labels[filter].toUpperCase()));
  if(!edges.length)list.append(make("p","nf-observatory-empty","No relationship of this type is recorded for this node. Try another lens."));
  else edges.forEach(edge=>list.append(row(edge)));
  pane.append(list);
  const links=make("div","nf-observatory-actions");
  if(isClaim){
   const p=link("Proof Passport ↗","passport.html?claim="+encodeURIComponent(selected));
   if(p)links.append(p);
  }
  const map=link("Full constellation ↗","constellation.html?claim="+encodeURIComponent(selected));
  if(map)links.append(map);
  pane.append(links);
 }
 function schedule(){if(frame)cancelAnimationFrame(frame);frame=requestAnimationFrame(draw);}
 function draw(){
  frame=0;const box=field.getBoundingClientRect();if(!box.width||!box.height)return;
  svg.setAttribute("viewBox","0 0 "+box.width+" "+box.height);svg.replaceChildren();
  for(const edge of match()){
   const from=nodes.get(edge.from)?.querySelector(".nf-observatory-star");
   const to=nodes.get(edge.to)?.querySelector(".nf-observatory-star");
   if(!from||!to)continue;
   const f=from.getBoundingClientRect(),t=to.getBoundingClientRect();
   const x1=f.left+f.width/2-box.left,y1=f.top+f.height/2-box.top;
   const x2=t.left+t.width/2-box.left,y2=t.top+t.height/2-box.top;
   const bend=(x2-x1)*.41;
   const path=document.createElementNS("http://www.w3.org/2000/svg","path");
   path.setAttribute("d","M "+x1+" "+y1+" C "+(x1+bend)+" "+y1+" "+(x2-bend)+" "+y2+" "+x2+" "+y2);
   path.setAttribute("class","nf-observatory-edge edge-"+edge.relation+(selected?" selected":""));
   svg.append(path);
  }
 }
 function sync(){
  const connected=new Set(match().flatMap(edge=>[edge.from,edge.to]));
  nodes.forEach((button,id)=>{
   button.setAttribute("aria-pressed",String(id===selected));
   button.classList.toggle("is-dim",(!!selected||filter!=="all")&&!connected.has(id)&&id!==selected);
  });
  controls.querySelectorAll("[data-lens]").forEach(button=>{
   button.setAttribute("aria-pressed",String(button.dataset.lens===filter));
  });
  if(summary)summary.textContent=match().length+" of "+R.edges.length+" sourced relationships shown · "+descriptions[filter];
  inspect();schedule();
 }
 function updateUrl(){
  const url=new URL(location.href);
  url.searchParams.delete("claim");url.searchParams.delete("mechanism");
  if(R.claimById(selected))url.searchParams.set("claim",selected);
  else if(R.mechanismById(selected))url.searchParams.set("mechanism",selected);
  // Keep the viewer in place; do not grow browser history for graph interactions.
  history.replaceState(history.state,"",url.pathname+url.search+url.hash);
 }
 function choose(id,user){
  selected=id&&nodes.has(id)?(selected===id?null:id):null;
  if(user)updateUrl();
  sync();
  if(user&&window.matchMedia("(max-width:860px)").matches){
   const reduce=window.matchMedia("(prefers-reduced-motion: reduce)").matches;
   pane.scrollIntoView({behavior:reduce?"instant":"smooth",block:"start"});
  }
 }
 controls.addEventListener("click",e=>{
  const b=e.target.closest("[data-lens]");
  if(!b||!controls.contains(b)||!Object.prototype.hasOwnProperty.call(labels,b.dataset.lens))return;
  filter=b.dataset.lens;sync();
 });
 field.addEventListener("keydown",e=>{
  if(e.key==="Escape"&&selected){e.preventDefault();choose(null,true);}
 });
 pane.addEventListener("keydown",e=>{
  if(e.key==="Escape"&&selected){e.preventDefault();choose(null,true);}
 });
 const params=new URLSearchParams(location.search);
 const fromLink=params.get("claim")||params.get("mechanism");
 if(fromLink&&nodes.has(fromLink))selected=fromLink;
 sync();
 window.addEventListener("resize",schedule,{passive:true});
 window.addEventListener("nightfall-theme-change",schedule);
 if("ResizeObserver" in window)new ResizeObserver(schedule).observe(field);
})();
