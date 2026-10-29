/* NIGHTFALL Constellation Protocol. Curated source graph, not a scientific inference engine.
 * No network service, automatic publication, or remote assignment mutation. */
"use strict";
(() => {
 const R=window.NightfallRegistry,F=window.NFFrontier,$=id=>document.getElementById(id);
 if(!R||!F){$("co-nodes").textContent="The source registry is unavailable. Read the published Mechanism Atlas directly.";return;}
 const kinds={"finite-check":"DOCUMENTED FINITE CHECK","method":"DOCUMENTED RESEARCH METHOD","open-premise":"UNRESOLVED PREMISE","analogy":"UNTESTED ANALOGY"};
 const ink={"finite-check":"#d9ff73","method":"#87ccb0","open-premise":"#e2b475","analogy":"#9abed5"};
 const claims=R.claims,methods=R.mechanisms,edges=R.edges;
 const doc=(tag,cls,value)=>{const e=document.createElement(tag);if(cls)e.className=cls;if(value!==undefined)e.textContent=String(value);return e;};
 const safeLink=(href)=>typeof href==="string"&&(/^(https:\/\/github\.com\/|https:\/\/www\.erdosproblems\.com\/|https:\/\/oeis\.org\/)/.test(href)||/^[a-z0-9-]+\.html(?:\?claim=[a-z0-9_-]+)?(?:#[a-z0-9-]+)?$/i.test(href))?href:null;
 function link(label,href){const safe=safeLink(href);if(!safe)return null;const a=doc("a","",label);a.href=safe;if(safe.startsWith("https:")){a.target="_blank";a.rel="noopener noreferrer"}return a;}
 const filterButtons=[...document.querySelectorAll("[data-co-filter]")];
 let type="all",selected=null,raf=0;
 const query=new URLSearchParams(location.search).get("claim");
 if(R.claimById(query)||R.mechanismById(query))selected=query;
 $("co-count-claims").textContent=claims.length.toString().padStart(2,"0");
 $("co-count-methods").textContent=methods.length.toString().padStart(2,"0");
 $("co-count-edges").textContent=edges.length.toString().padStart(2,"0");
 const nodeContainer=$("co-nodes"),nodes=new Map();
 [...claims.map((x,i)=>({x,i,side:0,count:claims.length})),...methods.map((x,i)=>({x,i,side:1,count:methods.length}))].forEach(({x,i,side,count})=>{
  const b=doc("button","co-node");b.type="button";b.dataset.node=x.id;
  b.style.left=(side?79:21)+"%";b.style.top=(14+(i*74/Math.max(1,count-1)))+"%";
  const meta=doc("small","",side?(x.kind==="analogy"?"CONCEPTUAL / UNPROVED":"RESEARCH MECHANISM"):x.validity.label.toUpperCase());
  const title=doc("strong","",x.title);b.append(meta,title);
  b.addEventListener("click",()=>{selected=selected===x.id?null:x.id;const url=new URL(location.href);
   if(selected&&R.claimById(selected))url.searchParams.set("claim",selected);else url.searchParams.delete("claim");
   history.replaceState(null,"",url);update();
  });
  nodes.set(x.id,b);nodeContainer.append(b);
 });
 nodeContainer.querySelector("p")?.remove();
 function matching(){return edges.filter(e=>(type==="all"||e.relation===type)&&(!selected||e.from===selected||e.to===selected));}
 function describe(){
  const n=R.claimById(selected)||R.mechanismById(selected);
  $("co-inspector-kind").textContent=n?(R.claimById(selected)?"SELECTED CLAIM / SCOPE GATED":"SELECTED MECHANISM / SCOPE GATED"):"CURATED SCIENTIFIC MEMORY";
  $("co-inspector-title").textContent=n?n.title:"Every edge needs evidence.";
  $("co-inspector-description").textContent=n?(n.short||n.description):"Select any node to inspect what it establishes, the relevant evidence, and what still needs independent verification.";
  $("co-inspector-scope").textContent=n?(n.conditions||n.scope):"An analogy remains unproved; a local finite checker is limited to its stated input and predicate.";
  const box=$("co-inspector-links");box.replaceChildren();
  if(n&&R.claimById(selected)){
   const a=link("Open this Proof Passport ↗","passport.html?claim="+encodeURIComponent(selected));
   // Passport target is assembled only from canonical IDs.
   if(a)box.append(a);
  }
  const atlas=link("Detailed Mechanism Atlas ↗","atlas.html"+(R.claimById(selected)?"?claim="+encodeURIComponent(selected):""));
  if(atlas)box.append(atlas);
  if(n&&R.claimById(selected)&&n.sources?.length){
   const first=link("Primary source ↗",n.sources[0].url);if(first)box.append(first);
  }
 }
 function renderDetails(){
  describe();
  const list=matching(),box=$("co-relations");box.replaceChildren();
  $("co-relationship-count").textContent=list.length+" of "+edges.length+" typed edges";
  if(!list.length){box.append(doc("p","co-empty","No relationships match this node and filter. Choose another filter to inspect other sources."));return;}
  const limit=selected?list.length:6;
  for(const e of list.slice(0,limit)){
   const card=doc("article","co-relation");
   card.append(doc("small","",kinds[e.relation]||"CURATED RELATIONSHIP"));
   card.append(doc("strong","",(R.claimById(e.from)?.title||e.from)+" → "+(R.mechanismById(e.to)?.title||e.to)));
   card.append(doc("p","",e.label+". "+e.note));
   const s=link("Read supporting source ↗",e.source);if(s)card.append(s);
   box.append(card);
  }
  if(list.length>limit)box.append(doc("p","co-empty","Showing "+limit+" representative edges of "+list.length+". Choose a node or relationship filter to inspect each connection."));
 }
 function drawLines(){
  const root=$("co-sky"),svg=$("co-lines");
  const bounds=root.getBoundingClientRect();
  if(!bounds.width||!bounds.height)return;
  svg.replaceChildren();svg.setAttribute("viewBox","0 0 "+bounds.width+" "+bounds.height);
  for(const e of matching()){
   const a=nodes.get(e.from),b=nodes.get(e.to);if(!a||!b)continue;
   const ra=a.getBoundingClientRect(),rb=b.getBoundingClientRect();
   const x1=ra.right-bounds.left,y1=(ra.top+ra.bottom)/2-bounds.top;
   const x2=rb.left-bounds.left,y2=(rb.top+rb.bottom)/2-bounds.top;
   const curve=Math.max(15,Math.abs(x2-x1)*.44);
   const path=document.createElementNS("http://www.w3.org/2000/svg","path");
   path.setAttribute("d","M "+x1+" "+y1+" C "+(x1+curve)+" "+y1+" "+(x2-curve)+" "+y2+" "+x2+" "+y2);
   path.setAttribute("stroke",ink[e.relation]||"#a9c2ac");path.setAttribute("fill","none");
   path.setAttribute("stroke-width",selected?"2":"1.4");path.setAttribute("stroke-opacity",selected?".85":".58");
   if(e.relation==="analogy"||e.relation==="open-premise")path.setAttribute("stroke-dasharray",e.relation==="analogy"?"7 7":"2 5");
   svg.append(path);
  }
 }
 function update(){
  const matched=matching(),relevant=new Set(matched.flatMap(e=>[e.from,e.to]));
  for(const [id,b] of nodes){b.setAttribute("aria-pressed",String(id===selected));b.classList.toggle("is-muted",!relevant.has(id)&&!!(selected||type!=="all"));}
  for(const b of filterButtons)b.setAttribute("aria-pressed",String(b.dataset.coFilter===type));
  renderDetails();
  window.dispatchEvent(new CustomEvent("nightfall:claim-selected",{detail:{claimId:R.claimById(selected)?selected:null}}));
  if(raf)cancelAnimationFrame(raf);raf=requestAnimationFrame(drawLines);
 }
 filterButtons.forEach(b=>b.addEventListener("click",()=>{type=b.dataset.coFilter;update();}));
 window.addEventListener("nightfall:trace-request",e=>{
  const id=e?.detail?.claimId;
  if(!R.claimById(id))return;
  selected=id;
  const url=new URL(location.href);url.searchParams.set("claim",selected);
  history.replaceState(null,"",url);update();
 });
 window.addEventListener("resize",()=>{if(raf)cancelAnimationFrame(raf);raf=requestAnimationFrame(drawLines)},{passive:true});
 if(typeof ResizeObserver!=="undefined"){const observer=new ResizeObserver(()=>{if(raf)cancelAnimationFrame(raf);raf=requestAnimationFrame(drawLines)});observer.observe($("co-sky"));}
 // Curated history events: editorial snapshot, not GitHub synchronization.
 const hist=$("co-history");
 for(const ev of R.events.slice(0,3)){
  const el=doc("article");const time=doc("time","",ev.date);time.dateTime=ev.date;
  el.append(time,doc("h3","",ev.claimTitle+" / "+ev.label),doc("p","",ev.detail));
  const a=link("Read record ↗",ev.url);if(a)el.append(a);hist.append(el);
 }
 // Read-only resume pointer. Local notes and finite receipts remain within the guided workspace.
 try{
  const s=JSON.parse(localStorage.getItem("nightfall.journey.v1")||"null");
  const r=s&&s.version===1&&typeof s.rootId==="string"?F.base(s.rootId):null;
  if(r){
   const root=F.rootTask(r);
   $("co-work-tag").textContent="RESUME / LOCAL UNREVIEWED";
   $("co-work-name").textContent=r.title;
   $("co-work-question").textContent=r.question;
   $("co-work-scope").textContent="Frozen root / "+F.predicate(root)+". Your chosen sub-branch and locally saved working notes remain in the guided workspace. This is not an exclusive public assignment.";
   $("co-work-action").textContent="Resume this investigation ↗";
   $("co-work-action").href="join.html#workspace";
   $("co-work-source").textContent="Standing source-linked assignment ↗";
   $("co-work-source").href=r.issue;$("co-work-source").target="_blank";$("co-work-source").rel="noopener noreferrer";
  }
 }catch(_){/* Invalid storage never changes the canonical graph. */}
 // Appearance is controlled by the shared, persistent NIGHTFALL theme toggle.
 document.body.dataset.theme=document.documentElement.dataset.nfTheme==="dusk"?"dark":"light";
 update();
})();
