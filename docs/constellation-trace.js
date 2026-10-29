/* NIGHTFALL claim trace: read-only, source-bound view of canonical registry.
 * No inferred proof status, no automatic publication, no remote or local mutations.
 * Requires research-registry.js; map coordination is optional. */
"use strict";
(() => {
 const R=window.NightfallRegistry, root=document.getElementById("trace");
 if(!root)return;
 const $=id=>document.getElementById(id);
 const doc=(tag,cls,value)=>{
  const e=document.createElement(tag);
  if(cls)e.className=cls;
  if(value!==undefined)e.textContent=String(value);
  return e;
 };
 const safeLink=url=>typeof url==="string"&&
  (/^https:\/\/[^\s"'<>]+$/.test(url)||/^[a-z0-9-]+\.html(?:\?claim=[a-z0-9_-]+(?:&obligation=0)?)?(?:#[a-z0-9-]+)?$/i.test(url));
 const anchor=(label,url)=>{
  if(!safeLink(url))return null;
  const a=doc("a","",label);a.href=url;
  if(url.startsWith("https://")){a.target="_blank";a.rel="noopener noreferrer";}
  return a;
 };
 const picker=$("co-trace-picker"),grid=$("co-trace-grid");
 if(!R||!Array.isArray(R.claims)||!R.claims.length){
  $("co-trace-summary").textContent="Canonical Proof Passport registry unavailable. The research review portal remains available.";
  grid.replaceChildren();return;
 }
 const exists=id=>typeof id==="string"&&R.claimById(id);
 const fromQuery=new URLSearchParams(location.search).get("claim");
 let selected=exists(fromQuery)?fromQuery:(exists("erdos36")?"erdos36":R.claims[0].id);
 const chooser=new Map();
 picker.replaceChildren();
 for(const c of R.claims){
  const button=doc("button","",c.title);button.type="button";
  button.dataset.claim=c.id;
  button.addEventListener("click",()=>{
   render(c.id);
   window.dispatchEvent(new CustomEvent("nightfall:trace-request",{detail:{claimId:c.id}}));
  });
  picker.append(button);chooser.set(c.id,button);
 }
 function cell(number,label,head,body){
  const el=doc("article","co-trace-cell");
  el.append(doc("small","",number+" / "+label),doc("h4","",head),doc("p","",body));
  return el;
 }
 function render(id){
  const c=exists(id);if(!c)return false;
  selected=c.id;
  for(const [key,button] of chooser)button.setAttribute("aria-pressed",String(key===id));
  const passport="passport.html?claim="+encodeURIComponent(c.id);
  const pass=$("co-trace-passport");pass.href=passport;
  $("co-trace-summary").textContent=c.title+" · "+c.kind+" · Registry "+R.asOf+
   " · Validity: "+c.validity.label;
  grid.replaceChildren();
  const statement=cell("01","EXACT CLAIM",c.title,c.statement);
  statement.append(doc("p","co-trace-conditions","Conditions: "+c.conditions));
  grid.append(statement);
  const evidence=cell("02","REPRODUCTION","What has been checked?",c.reproducibility.detail);
  const src=c.sources?.[0];
  if(src){const a=anchor("Primary listed source: "+src.label+" ↗",src.url);if(a)evidence.append(a);}
  evidence.append(doc("p","co-trace-conditions",
   "Recorded evidence label: "+c.reproducibility.label+". Inspect the full Passport for all sources and assumptions."));
  grid.append(evidence);
  const obligations=Array.isArray(c.open)?c.open:[];
  const first=obligations[0];
  const gate=cell("03","UNRESOLVED GATE","What could still fail?",
   first||"No outstanding review obligation is listed in this dated snapshot. This is not an external approval.");
  if(first){
   const work=anchor("Take this specific review obligation ↗",
    "join.html?claim="+encodeURIComponent(c.id)+"&obligation=0#claim-investigation");
   if(work)gate.append(work);
   gate.append(doc("p","co-trace-conditions",obligations.length+
    " unresolved obligation(s) listed in the Passport; only the first is displayed here."));
  }
  const premise=R.edges.find(e=>e.from===c.id&&e.relation==="open-premise");
  if(premise){
   gate.append(doc("p","co-trace-dependency","Linked open premise: "+premise.label+". "+premise.note));
   const a=anchor("Inspect linked premise source ↗",premise.source);if(a)gate.append(a);
  }
  grid.append(gate);
  const levels=cell("04","PUBLICATION BOUNDARY","Four separate decisions",
   "Validity: "+c.validity.label+". Reproducibility: "+c.reproducibility.label+
   ". Originality: "+c.originality.label+". Significance: "+c.significance.label+".");
  levels.append(doc("p","co-trace-conditions",
   "Internal exact checks do not grant external mathematical review, novelty priority or human publication approval."));
  const full=anchor("Inspect full evidence dimensions and historical changes ↗",passport);
  if(full)levels.append(full);
  grid.append(levels);
  const last=(c.history||[]).slice().sort((a,b)=>b.date.localeCompare(a.date))[0];
  $("co-trace-footnote").textContent=last?
   "Latest listed evidence event: "+last.date+" — "+last.label+
   ". This is a dated editorial snapshot; source history and release gates remain authoritative.":
   "This is a dated editorial snapshot, not an automatic approval workflow.";
  return true;
 }
 window.addEventListener("nightfall:claim-selected",event=>{
  if(exists(event?.detail?.claimId))render(event.detail.claimId);
 });
 render(selected);
})();
