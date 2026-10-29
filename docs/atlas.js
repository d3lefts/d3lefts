"use strict";
(()=>{
 const R=window.NightfallRegistry, $=id=>document.getElementById(id);
 if(!R)return;
 const esc=s=>String(s??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
 const safeUrl=url=>/^(https:\/\/[^\s"<>]+|[a-z0-9][a-z0-9./#?=&_-]*\.html(?:\?[^\s"<>]*)?(?:#[^\s"<>]*)?)$/i.test(url)?url:"#";
 const names={"finite-check":"Finite check","method":"Documented method","open-premise":"Open premise","analogy":"Analogy only"};
 const colors={"finite-check":"#d9ff5e","method":"#83bea1","open-premise":"#dbb471","analogy":"#92b6c9"};
 let type="all",selected=null,resizeRaf=0;
 const query=new URLSearchParams(location.search).get("claim");
 if(R.claimById(query))selected=query;
 $("atlas-count").textContent=R.claims.length+" claims · "+R.mechanisms.length+" mechanisms\n"+R.edges.length+" source-linked relationships";
 function renderNodes(){
   $("ma-claims").innerHTML="<h3>RESEARCH CLAIMS</h3>"+R.claims.map(c=>'<button class="ma-node" type="button" data-node="'+esc(c.id)+'" aria-pressed="'+(selected===c.id)+'"><small>'+esc(c.field.toUpperCase())+'</small><strong>'+esc(c.title)+'</strong><span>'+esc(c.validity.label)+'</span></button>').join("");
   $("ma-mechanisms").innerHTML="<h3>METHODS &amp; OPEN BRIDGES</h3>"+R.mechanisms.map(m=>'<button class="ma-node'+(m.kind==="analogy"?" analog":"")+'" type="button" data-node="'+esc(m.id)+'" aria-pressed="'+(selected===m.id)+'"><small>'+esc(m.kind==="analogy"?"CONCEPTUAL PARALLEL":"RESEARCH METHOD")+'</small><strong>'+esc(m.title)+'</strong><span>'+esc(m.scope)+'</span></button>').join("");
   document.querySelectorAll(".ma-node").forEach(btn=>btn.addEventListener("click",()=>{selected=selected===btn.dataset.node?null:btn.dataset.node;const u=new URL(location.href);if(R.claimById(selected))u.searchParams.set("claim",selected);else u.searchParams.delete("claim");history.replaceState(null,"",u);update()}));
 }
 function filterEdges(){return R.edges.filter(e=>(type==="all"||e.relation===type)&&(!selected||e.from===selected||e.to===selected))}
 function update(){
   document.querySelectorAll(".ma-node").forEach(b=>b.setAttribute("aria-pressed",String(b.dataset.node===selected)));
   document.querySelectorAll("[data-rel]").forEach(b=>b.setAttribute("aria-pressed",String(b.dataset.rel===type)));
   const n=R.claimById(selected)||R.mechanismById(selected),edges=filterEdges();
   const headline=n?.title||"Every link carries evidence.";
   const desc=n?(n.short||n.description):"Choose a claim or mechanism to see precisely what it connects to, then open the primary source supporting that relationship.";
   const scope=n?(n.conditions||n.scope):"Five curated claims, five reusable mechanisms and explicitly typed relationships. This snapshot cannot infer new transfer theorems.";
   $("ma-detail").innerHTML='<div><span class="rs-kicker">'+esc(selected?(R.claimById(selected)?"SELECTED CLAIM":"SELECTED MECHANISM"):"RESEARCH GRAPH")+'</span><h3>'+esc(headline)+'</h3><p>'+esc(desc)+'</p>'+(R.claimById(selected)?'<a class="rs-btn" style="margin-top:18px" href="passport.html?claim='+encodeURIComponent(selected)+'">Open Proof Passport ↗</a>':"")+'</div><div><span class="rs-kicker">EXACT SCOPE</span><p>'+esc(scope)+'</p><p style="margin-top:16px">'+edges.length+' visible source-linked relationship'+(edges.length===1?"":"s")+'.</p>'+(selected?'<button class="rs-btn light" id="clear-selection" type="button" style="margin-top:18px">Show all nodes ↺</button>':"")+'</div>';
   $("clear-selection")?.addEventListener("click",()=>{selected=null;history.replaceState(null,"","atlas.html");update()});
   $("ma-relations").innerHTML=edges.length?edges.map(e=>{const c=R.claimById(e.from),m=R.mechanismById(e.to);return '<article class="ma-relation"><div><strong>'+esc(c.title)+' → '+esc(m.title)+'</strong><p>'+esc(e.label)+'. '+esc(e.note)+'</p><a href="'+safeUrl(e.source)+'"'+(e.source.startsWith("https")?' target="_blank" rel="noopener"':'')+'>Read source ↗</a> · <a href="passport.html?claim='+encodeURIComponent(c.id)+'">Claim Passport ↗</a></div><small>'+esc(names[e.relation])+'</small></article>'}).join(""):'<div class="empty">No documented connections match this combination of node and relationship type.</div>';
   if(resizeRaf)cancelAnimationFrame(resizeRaf);
   resizeRaf=requestAnimationFrame(drawLines);
 }
 function drawLines(){
   const root=$("ma-canvas"),svg=$("ma-lines"),r=root.getBoundingClientRect();
   if(!r.width||!r.height)return;
   const nodes=new Map([...root.querySelectorAll("[data-node]")].map(b=>[b.dataset.node,b]));
   const curve=filterEdges().map(e=>{
     const a=nodes.get(e.from),b=nodes.get(e.to);if(!a||!b)return"";
     const x=a.getBoundingClientRect(),y=b.getBoundingClientRect(),x1=x.right-r.left,y1=x.top+x.height/2-r.top,x2=y.left-r.left,y2=y.top+y.height/2-r.top;
     const bend=Math.max(12,(x2-x1)*.45),c=colors[e.relation],dash=e.relation==="analogy"?' stroke-dasharray="5 8"':e.relation==="open-premise"?' stroke-dasharray="2 5"':"";
     return '<path d="M'+x1+' '+y1+' C'+(x1+bend)+' '+y1+' '+(x2-bend)+' '+y2+' '+x2+' '+y2+'" fill="none" stroke="'+c+'" stroke-width="'+(selected?2.1:1.45)+'" stroke-opacity="'+(selected?0.9:0.65)+'"'+dash+'/>';
   }).join("");
   svg.setAttribute("viewBox","0 0 "+r.width+" "+r.height);svg.innerHTML=curve;
 }
 $("ma-history").innerHTML=R.events.map(e=>'<article class="ma-history-row"><time datetime="'+esc(e.date)+'">'+esc(e.date)+'</time><div><strong>'+esc(e.claimTitle)+': '+esc(e.label)+'</strong><p>'+esc(e.detail)+'</p></div><a href="'+safeUrl(e.url)+'"'+(e.url.startsWith("https")?' target="_blank" rel="noopener"':'')+'>Primary source ↗</a></article>').join("");
 document.querySelectorAll("[data-rel]").forEach(b=>b.addEventListener("click",()=>{type=b.dataset.rel;update()}));
 window.addEventListener("resize",()=>{if(resizeRaf)cancelAnimationFrame(resizeRaf);resizeRaf=requestAnimationFrame(drawLines)},{passive:true});
 if(typeof ResizeObserver!=="undefined"){const observer=new ResizeObserver(()=>{if(resizeRaf)cancelAnimationFrame(resizeRaf);resizeRaf=requestAnimationFrame(drawLines)});observer.observe($("ma-canvas"))}
 renderNodes();update();
})();
