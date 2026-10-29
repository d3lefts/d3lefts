"use strict";
/* Pure data projection for the unlisted portfolio.
   Claims are *reported* from the canonical Proof Passport registry;
   there is no automatic proof-status promotion or invented score. */
(function(root,factory){
  const api=factory();
  if(typeof module==="object" && module.exports) module.exports=api;
  else root.NightfallPortfolioCore=api;
})(typeof globalThis!=="undefined"?globalThis:this,function(){
  const SCHEMA="nightfall-proof-passports-v1";
  const LEVELS=["finite","conditional","working","empirical","software"];
  const text=(x)=>typeof x==="string"?x.trim():"";
  const validDate=(x)=>/^\d{4}-\d{2}-\d{2}$/.test(x||"")?x:"";
  const safeUrl=(value)=>{
    const s=text(value);
    if(/^https:\/\/[^\s<>"']+$/i.test(s)) return s;
    if(/^(?!\/)(?!\.\.\/)[a-zA-Z0-9_.\/-]+\.html(?:#[a-zA-Z0-9_-]+)?$/.test(s) && !s.includes("..")) return s;
    return "";
  };
  function project(input){
    if(!input || input.schema!==SCHEMA || !Array.isArray(input.claims)) {
      return {ok:false,asOf:"",claims:[],changes:[],error:"Canonical Proof Passport registry unavailable or incompatible."};
    }
    const ids=new Set(),claims=[],changes=[];
    for(const raw of input.claims){
      if(!raw || !text(raw.id) || !text(raw.title) || ids.has(raw.id)
          || !raw.validity || !text(raw.validity.level) || !raw.reproducibility) {
        return {ok:false,asOf:"",claims:[],changes:[],error:"Registry has a missing or duplicate claim identifier / evidence classification."};
      }
      ids.add(raw.id);
      const history=Array.isArray(raw.history)?raw.history:[];
      const dated=history.filter(e=>e && validDate(e.date) && text(e.label));
      const last=dated.reduce((max,e)=>e.date>max?e.date:max,"");
      const links=(Array.isArray(raw.sources)?raw.sources:[]).filter(x=>x&&safeUrl(x.url))
        .slice(0,3).map(x=>({label:text(x.label)||"Primary source",url:safeUrl(x.url)}));
      const validity=text(raw.validity.level);
      const reproducibility=text(raw.reproducibility.level);
      const isPublicFinite=validity==="finite" && reproducibility==="public";
      const open=Array.isArray(raw.open)?raw.open.map(text).filter(Boolean):[];
      claims.push({
        id:raw.id,title:text(raw.title),kind:text(raw.kind),field:text(raw.field),
        short:text(raw.short),measurement:text(raw.measurement),metric:text(raw.metric),
        validityLevel:validity,validityLabel:text(raw.validity.label)||validity,
        reproducibilityLevel:reproducibility,
        reproducibilityLabel:text(raw.reproducibility.label)||reproducibility,
        originalityLabel:text(raw.originality?.label),
        significanceLabel:text(raw.significance?.label),
        publicFinite:isPublicFinite,latest: last,open:open[0]||"No specific obligation recorded.",
        sources:links
      });
      for(const e of dated){
        changes.push({
          id:raw.id,title:text(raw.title),date:e.date,
          kind:text(e.kind),label:text(e.label),
          detail:text(e.detail),url:safeUrl(e.url)
        });
      }
    }

    // Mechanisms and edges are sourced as distinct graph objects. A shared
    // method or analogy is evidence of a recorded relationship, never a
    // transfer theorem or independent mathematical referee decision.
    const graphNodes=Array.isArray(input.mechanisms)?input.mechanisms:[];
    const graphEdges=Array.isArray(input.edges)?input.edges:[];
    const nodeIds=new Set();
    const mechanisms=[];
    for(const m of graphNodes){
      const id=text(m?.id), title=text(m?.title);
      if(!id || !title || nodeIds.has(id)) continue;
      nodeIds.add(id);
      const connected=graphEdges.filter(e=>e && e.to===id && ids.has(e.from)
        && ["finite-check","method","open-premise","analogy"].includes(e.relation))
        .map(e=>({
          claimId:e.from,
          claimTitle:text(claims.find(c=>c.id===e.from)?.title),
          relation:e.relation,
          label:text(e.label),note:text(e.note),
          url:safeUrl(e.source)
        }));
      mechanisms.push({
        id,title,description:text(m.description),kind:text(m.kind),
        scope:text(m.scope),connections:connected
      });
    }
    mechanisms.sort((a,b)=>b.connections.length-a.connections.length || a.title.localeCompare(b.title));
    claims.sort((a,b)=>b.latest.localeCompare(a.latest)||a.id.localeCompare(b.id));
    changes.sort((a,b)=>b.date.localeCompare(a.date)||a.id.localeCompare(b.id)||a.label.localeCompare(b.label));
    return {ok:true,asOf:validDate(input.asOf),claims,changes:changes.slice(0,8),
      publicFiniteCount:claims.filter(c=>c.publicFinite).length,trackedCount:claims.length,mechanisms,
      recognizedLevels:LEVELS};
  }
  return Object.freeze({project,safeUrl});
});
