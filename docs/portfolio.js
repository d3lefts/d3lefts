"use strict";
/* Read-only portfolio projection. Updates with the same deployed registry as
   Proof Passports; contains no write path or user-generated status transition. */
(function(){
  const host=document.getElementById("pf-live-records");
  const events=document.getElementById("pf-live-events");
  const summary=document.getElementById("pf-live-summary");
  const stamp=document.getElementById("pf-live-stamp");
  const engine=window.NightfallPortfolioCore;
  if(!host||!events||!engine)return;
  const view=engine.project(window.NightfallRegistry);
  const node=(tag,cls,value)=>{
    const n=document.createElement(tag);
    if(cls)n.className=cls;
    if(value!==undefined)n.textContent=value;
    return n;
  };
  const link=(entry,label)=>{
    if(!entry || !engine.safeUrl(entry.url))return null;
    const a=node("a","pf-ledger-link",label || entry.label || "Source");
    a.href=engine.safeUrl(entry.url);
    return a;
  };
  if(!view.ok){
    summary.textContent=view.error;
    host.replaceChildren(node("p","pf-live-error","Registry unavailable. Static case studies remain, and claim status must be checked at its primary source."));
    events.replaceChildren();
    return;
  }
  summary.textContent=view.trackedCount+" canonical records · "+view.publicFiniteCount+
    " public finite-evidence records · exact claim statuses retained";
  if(stamp)stamp.textContent=view.asOf?"Registry dated "+view.asOf:"Registry date unspecified";
  const cards=document.createDocumentFragment();
  for(const entry of view.claims){
    const article=node("article","pf-ledger-card");
    article.dataset.claimId=entry.id;
    const top=node("div","pf-ledger-card-head");
    top.append(node("span","pf-ledger-date",entry.latest?"Last recorded "+entry.latest:"No recorded revision"));
    top.append(node("span","pf-ledger-scope",entry.publicFinite?"Public finite evidence · external review may remain open":"Tracked · "+entry.validityLabel));
    article.append(top,node("h3","",entry.title),node("p","pf-ledger-desc",entry.short||entry.kind));
    const facts=node("dl","pf-ledger-facts");
    for(const [key,value] of [
      ["Validity",entry.validityLabel],["Reproducibility",entry.reproducibilityLabel],
      ["Originality",entry.originalityLabel||"Unspecified"],
      ["Significance",entry.significanceLabel||"Unspecified"]]){
      const pair=node("div","");
      pair.append(node("dt","",key),node("dd","",value));
      facts.append(pair);
    }
    article.append(facts);
    const remaining=node("p","pf-ledger-open");
    remaining.append(node("strong","","Open: "),document.createTextNode(entry.open));
    article.append(remaining);
    const sources=node("div","pf-ledger-sources");
    entry.sources.forEach(s=>{const a=link(s,s.label+" ↗");if(a)sources.append(a)});
    article.append(sources);
    cards.append(article);
  }
  host.replaceChildren(cards);
  const items=document.createDocumentFragment();
  for(const change of view.changes){
    const li=node("li","");
    const date=node("time","",change.date);
    date.dateTime=change.date;
    const b=node("strong","",change.title+" — "+change.label);
    li.append(date,b);
    if(change.detail)li.append(node("p","",change.detail));
    const source=link(change,"Source ↗");
    if(source)li.append(source);
    items.append(li);
  }
  events.replaceChildren(items);

  // The mechanism atlas shares exactly the registry used by Proof Passports.
  // Method, finite check, open premise and analogy remain different edge types.
  const mechanismHost=document.getElementById("pf-mechanism-list");
  const mechanismTotal=document.getElementById("pf-mechanism-total");
  if(mechanismHost){
    const fragment=document.createDocumentFragment();
    for(const mechanism of view.mechanisms){
      const article=node("article","pf-mechanism");
      const head=node("div","pf-mechanism-head");
      head.append(node("span","pf-mechanism-kind",mechanism.kind==="analogy"?"Analogy / untested transfer":"Recorded research method"),
        node("span","pf-mechanism-count",mechanism.connections.length+" sourced links"));
      article.append(head,node("h3","",mechanism.title),
        node("p","pf-mechanism-description",mechanism.description),
        node("p","pf-mechanism-scope",mechanism.scope));
      const connections=node("ul","pf-mechanism-connections");
      for(const edge of mechanism.connections){
        const li=node("li","");
        li.append(node("strong","",edge.claimTitle),
          node("span","pf-edge-type",edge.relation.replaceAll("-"," ")));
        if(edge.note)li.append(node("p","",edge.note));
        const a=link({url:edge.url,label:"Evidence"},"Inspect source ↗");
        if(a)li.append(a);
        connections.append(li);
      }
      article.append(connections);
      fragment.append(article);
    }
    mechanismHost.replaceChildren(fragment);
    if(mechanismTotal)mechanismTotal.textContent=view.mechanisms.length+
      " canonical mechanisms · relation types preserved";
  }
})();
