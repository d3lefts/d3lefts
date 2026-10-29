"use strict";
/* Homepage draws claim data from the same versioned source as Proof Passports. */
(() => {
 const R=window.NightfallRegistry,C=window.RefereeCore;
 if(!R)return;
 const $=s=>document.querySelector(s),esc=s=>String(s??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
 const ids=["erdos36","phase","werner","adaptive"];
 [...document.querySelectorAll(".flagship-grid .flagship-card")].forEach((card,i)=>{
   const c=R.claimById(ids[i]);if(!c)return;
   const t=card.querySelector(".flagship-eyebrow"),h=card.querySelector("h3"),v=card.querySelector(".flagship-value"),p=card.querySelector(".flagship-body p"),a=card.querySelector(".flagship-link");
   if(t)t.textContent=c.kind+" · "+c.validity.label;
   if(h)h.textContent=c.title;
   if(v){v.textContent=c.measurement;const note=document.createElement("span");note.textContent=" "+c.metric;v.append(note)}
   if(p)p.textContent=c.short+" "+c.conditions;
   if(a){a.href="passport.html?claim="+encodeURIComponent(c.id);a.removeAttribute("target");a.removeAttribute("rel");a.innerHTML="Inspect Proof Passport <span aria-hidden='true'>↗</span>"}
 });
 const featured=["erdos36","sidon30","pas"];
 [...document.querySelectorAll(".feature-grid > a")].forEach((card,i)=>{
   const c=R.claimById(featured[i]);if(!c)return;
   const h=card.querySelector("h3"),p=card.querySelector(".feature-body p"),tag=card.querySelector(".feature-tag span");
   if(h)h.textContent=c.title;if(p)p.textContent=c.short+" "+c.originality.detail;
   if(tag)tag.textContent=c.kind.toUpperCase();
   card.href="passport.html?claim="+encodeURIComponent(c.id);card.removeAttribute("target");card.removeAttribute("rel")
 });
 const c=R.claimById("sidon30");
 const head=$("#sidon-live-title"),scope=$("#sidon-live-scope"),metric=$("#sidon-live-metric");
 if(head)head.textContent=c.title;if(scope)scope.textContent=c.conditions;if(metric)metric.textContent=c.measurement;
 if(C&&C.SIDON_WITNESS&&$("#sidon-witness")){
  const chosen=new Set(C.SIDON_SUBSET.map(String));
  const group=$("#sidon-witness"),toggle=$("#sidon-toggle");
  group.innerHTML=C.SIDON_WITNESS.map((x,i)=>'<span class="sf-point'+(chosen.has(String(x))?' chosen':'')+'" role="listitem" title="Integer coordinate '+esc(x)+'" aria-label="Point '+(i+1)+', '+esc(x)+(chosen.has(String(x))?', in the explicit 17-point Sidon subset':'')+'">'+String(i+1).padStart(2,"0")+'</span>').join("");
  const render=()=>{const only=toggle?.getAttribute("aria-pressed")==="true";group.classList.toggle("show-subset",only);if(toggle){toggle.disabled=false;toggle.removeAttribute("title");toggle.textContent=only?"Show all 30 points ↺":"Highlight 17-point subset ↗"}};
  toggle?.addEventListener("click",()=>{toggle.setAttribute("aria-pressed",String(toggle.getAttribute("aria-pressed")!=="true"));render()});
  render();
 }
 const events=R.events.slice(0,3),target=$("#home-evidence-history");
 if(target)target.innerHTML=events.map(e=>'<a href="passport.html?claim='+encodeURIComponent(e.claimId)+'"><time datetime="'+esc(e.date)+'">'+esc(e.date)+'</time><span>'+esc(e.claimTitle)+' — '+esc(e.label)+'</span><strong>Inspect ↗</strong></a>').join("");
})();
