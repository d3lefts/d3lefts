"use strict";
/* Bounded local demo: retrieval over a manually curated, deployed evidence graph.
   NO extraction, model inference, semantic entailment, web-scale or ML benchmark. */
(function(root,factory){
  const api=factory();
  if(typeof module==="object"&&module.exports)module.exports=api;
  else root.NightfallPortfolioSearch=api;
})(typeof globalThis!=="undefined"?globalThis:this,function(){
  const stops=new Set(["a","an","and","at","by","do","does","for","from","has","have","in","is","it","of","on","or","our","show","the","there","to","what","which","with","me","claims","claim","research"]);
  const tokenize=value=>String(value||"").normalize("NFKD")
    .toLowerCase().replace(/[\u0300-\u036f]/g,"").replace(/[^a-z0-9]+/g," ").trim()
    .split(/\s+/).filter(x=>x.length>=2&&!stops.has(x)).slice(0,12);
  const norm=x=>tokenize(x).join(" ");
  const fields=entry=>[
    [entry.title,9],[entry.kind,3],[entry.field,4],[entry.short,4],
    [entry.statement,3],[entry.conditions,2],[entry.validityLabel,2],
    [entry.reproducibilityLabel,2],[entry.open,2]
  ];
  function search(view,query,limit=3){
    const q=String(query||"").trim().slice(0,140);
    if(!view||view.ok!==true||!Array.isArray(view.claims))
      return {status:"registry_unavailable",query:q,results:[],total:0};
    const terms=tokenize(q);
    if(!terms.length)return {status:"empty",query:q,results:[],total:0};
    const scored=[];
    for(const entry of view.claims){
      if(!entry||!entry.id||!entry.title)continue;
      const fs=fields(entry).map(([value,weight])=>[norm(value).split(" "),weight]);
      // All informative terms must occur in the canonical claim scope.
      // This precision-oriented rule explicitly abstains on missing terms.
      const perTerm=terms.map(term=>Math.max(0,...fs.map(([words,w])=>words.includes(term)?w:0)));
      if(perTerm.some(x=>!x))continue;
      const edges=(Array.isArray(view.mechanisms)?view.mechanisms:[])
        .flatMap(m=>m.connections.filter(e=>e.claimId===entry.id)
          .map(e=>({title:m.title,relation:e.relation,note:e.note,url:e.url})));
      scored.push({
        id:entry.id,title:entry.title,statement:entry.statement||entry.short||"",
        conditions:entry.conditions||"",open:entry.open,
        validity:entry.validityLabel,reproducibility:entry.reproducibilityLabel,
        originality:entry.originalityLabel,score:perTerm.reduce((a,b)=>a+b,0),
        sources:entry.sources.slice(0,2),mechanisms:edges.slice(0,3)
      });
    }
    // Stable source-registry order resolves equal-score queries. Curated broad
    // overview entries precede narrower derivative passports, so a short
    // search like "Erdos" returns the overview; "dual" selects its subclaim.
    scored.sort((a,b)=>b.score-a.score);
    return {status:scored.length?"matched":"abstain",query:q,total:scored.length,
      results:scored.slice(0,Math.min(5,Math.max(1,Number(limit)||3)))};
  }
  return Object.freeze({search,tokenize});
});
