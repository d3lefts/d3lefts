"use strict";
(() => {
 const R=window.NightfallRegistry, $=id=>document.getElementById(id);
 if(!R){$("passport-title").textContent="Registry unavailable";return}
 const esc=s=>String(s??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
 const safeUrl=url=>/^(https:\/\/[^\s"<>]+|[a-z0-9][a-z0-9./#?=&_-]*\.html(?:\?[^\s"<>]*)?(?:#[^\s"<>]*)?)$/i.test(url)?url:"#";
 const titleDim={validity:"Validity",reproducibility:"Reproducibility",originality:"Originality",significance:"Significance"};
 const id=new URLSearchParams(location.search).get("claim");
 const claim=R.claimById(id)||R.claimById("sidon30");
 if(id&&!R.claimById(id)){history.replaceState(null,"","passport.html?claim=sidon30")}
 document.title=claim.title+" / Proof Passport — NIGHTFALL";
 $("passport-category").textContent="NIGHTFALL / "+claim.field.toUpperCase()+" / "+claim.id.toUpperCase();
 $("passport-title").textContent=claim.title;
 $("passport-short").textContent=claim.short;
 $("passport-metric").textContent=claim.measurement;
 $("passport-metric-name").textContent=claim.metric.toUpperCase();
 $("passport-metric-note").textContent=claim.kind+" · Scope explicit in the statement below";
 $("passport-statement").textContent=claim.statement;
 $("passport-conditions").textContent=claim.conditions;
 $("passport-meta").innerHTML=[claim.kind,claim.field,"Snapshot "+R.asOf].map(t=>"<span>"+esc(t)+"</span>").join("");
 $("passport-picker").innerHTML=R.claims.map(c=>'<a href="passport.html?claim='+encodeURIComponent(c.id)+'"'+(c.id===claim.id?' aria-current="true"':'')+'>'+esc(c.title)+'</a>').join("");
 $("passport-dimensions").innerHTML=R.dimensions.map((key,i)=>{const x=claim[key];return '<article class="pp-dimension"><span>0'+(i+1)+' / '+titleDim[key].toUpperCase()+'</span><strong>'+esc(x.label)+'</strong><p>'+esc(x.detail)+'</p><span class="pp-badge '+esc(x.level)+'">'+esc(x.level.toUpperCase())+'</span></article>'}).join("");
 const ul=id=>arr=>{$(id).innerHTML=arr.map(x=>"<li>"+esc(x)+"</li>").join("")};ul("passport-assumptions")(claim.assumptions);ul("passport-open")(claim.open);
 $("passport-sources").innerHTML=claim.sources.map(s=>'<a class="pp-source" href="'+safeUrl(s.url)+'"'+(s.url.startsWith("https")?' target="_blank" rel="noopener"':'')+'><span>'+esc(s.label)+'</span><span aria-hidden="true">↗</span></a>').join("");
 $("passport-actions").innerHTML='<a class="rs-btn" href="atlas.html?claim='+encodeURIComponent(claim.id)+'">Trace the mechanism ↗</a>'+claim.tools.map((url,i)=>'<a class="rs-btn light" href="'+safeUrl(url)+'">'+esc(i===0?"Open related research tool":"Open review path")+' ↗</a>').join("");
 $("passport-history").innerHTML=claim.history.slice().sort((a,b)=>b.date.localeCompare(a.date)).map(e=>'<article class="pp-event"><time datetime="'+esc(e.date)+'">'+esc(e.date)+'</time><div><strong>'+esc(e.label)+'</strong><p>'+esc(e.detail)+'</p><a href="'+safeUrl(e.url)+'"'+(e.url.startsWith("https")?' target="_blank" rel="noopener"':'')+'>Inspect source ↗</a></div></article>').join("");
})();
