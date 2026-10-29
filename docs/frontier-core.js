/* NF Frontier Dispatch: frozen, deterministic editorial priorities; no server-side agent. */
"use strict";
(function (root,factory) {
  const api=factory();
  if (typeof module!=="undefined" && module.exports) module.exports=api;
  else root.NFFrontier=api;
})(typeof globalThis!=="undefined"?globalThis:this,function () {
  const VERSION="nf-frontier-snapshot-20261029-v1";
  const ROOT="https://github.com/d3lefts/d3lefts";
  const ITEMS=[
    {
      id:"NF-156-184-9",code:"01 / ADDITIVE COMBINATORICS",parent:"Erdős #156",
      title:"Nine marks at the first uncharted boundary",
      question:"Does [1,184] contain a maximal Sidon set with exactly nine integers?",
      why:"The independently published finite table runs through N=183. NIGHTFALL's N=184, k=9 SAT encoding is available; a time-limited solve supplied neither a witness nor a proof of impossibility.",
      source:"https://www.erdosproblems.com/156",
      data:"https://oeis.org/A382397",
      evidence:ROOT+"/pull/55",
      issue:ROOT+"/issues/46",
      tools:["orchestrator.html","claim-lab.html","desk.html"],
      toolHint:"Use Orchestrator to freeze hypotheses and independent lanes. Claim Lab tracks attempts. The general-purpose Referee does not certify maximal Sidon sets.",
      scale:{name:"smallest selected mark",min:1,max:184},
      closureYes:"Nine distinct integers in [1,184]; all 45 unordered sums distinct, including diagonal sums; every omitted integer makes a repeated unordered sum when inserted.",
      closureNo:"Complete UNSAT proof for the fixed nine-element existence encoding, checked by an independent proof verifier; a solver timeout is inconclusive.",
      priority:{decisiveness:5,leverage:4,evidence:4,urgency:4,cost:3},
      stop:"After three distinct failed solver/structural operators, record an exact no-go restriction and change encoding rather than repeat timeouts."
    },
    {
      id:"NF-Q7-R6",code:"02 / EXTREMAL GRAPH THEORY",parent:"Erdős #86",
      title:"Search beyond the five-deletion wall",
      question:"Can six deletions and seven insertions improve one of 180 published 304-edge Q7 representatives to a C4-free 305-edge graph?",
      why:"NIGHTFALL has an internally reproduced five-deletion exclusion for the 180 supplied seed masks. Six-deletion improvements in this precise seed family remain unresolved in the current project evidence.",
      source:"https://www.erdosproblems.com/86",
      data:"https://github.com/minamominamoto/c4free-hypercube",
      evidence:ROOT+"/pull/70",
      issue:ROOT+"/issues/48",
      tools:["orchestrator.html","claim-lab.html","atlas.html"],
      toolHint:"Use Orchestrator for a bounded six-deletion operator, Claim Lab for evidence, and the Q7 source checker in the research PR for exact four-cycle testing.",
      scale:{name:"published representative index",min:0,max:179},
      closureYes:"Exact edge list with 305 selected cube edges, independently rebuilt on 128 vertices / 448 edges / 672 coordinate squares, with verified six-deletion lineage.",
      closureNo:"An independently checked exhaustive exclusion of all six-deletion/seven-insertion configurations over the specified representative indices.",
      priority:{decisiveness:4,leverage:4,evidence:4,urgency:3,cost:5},
      stop:"Stop local edits after complete exact obstruction, then switch to noncatalogue seeds or global proof-producing SAT."
    }
  ];
  const WEIGHTS=Object.freeze({decisiveness:3,leverage:3,evidence:2,urgency:2,cost:-2});
  function score(x){return Object.keys(WEIGHTS).reduce((v,k)=>v+WEIGHTS[k]*x.priority[k],0)}
  function ranked(){return ITEMS.slice().sort((a,b)=>score(b)-score(a)||a.id.localeCompare(b.id))}
  function base(id){return ITEMS.find(x=>x.id===id)||null}
  function rootTask(x){return {id:x.id,rootId:x.id,lo:x.scale.min,hi:x.scale.max,parentId:null,depth:0,state:"open",evidence:[],claimedAt:null};}
  function assertTask(t){
    const root=base(t&&t.rootId);
    return !!(root&&Number.isSafeInteger(t.lo)&&Number.isSafeInteger(t.hi)&&t.lo>=root.scale.min&&t.hi<=root.scale.max&&t.lo<=t.hi&&typeof t.id==="string");
  }
  function split(t){
    if(!assertTask(t)||t.lo>=t.hi)throw Error("The selected range cannot be divided further.");
    const mid=Math.floor((t.lo+t.hi)/2);
    const parts=[
      {id:t.id+"/"+t.lo+"-"+mid,rootId:t.rootId,lo:t.lo,hi:mid,parentId:t.id,depth:t.depth+1,state:"open",evidence:[],claimedAt:null},
      {id:t.id+"/"+(mid+1)+"-"+t.hi,rootId:t.rootId,lo:mid+1,hi:t.hi,parentId:t.id,depth:t.depth+1,state:"open",evidence:[],claimedAt:null}
    ];
    if(!validPartition(t,parts))throw Error("Split failed exact-cover validation.");
    return parts;
  }
  function validPartition(parent,parts){
    return assertTask(parent)&&Array.isArray(parts)&&parts.length===2&&parts.every(assertTask)&&parts.every(x=>x.rootId===parent.rootId&&x.parentId===parent.id)&&parts[0].lo===parent.lo&&parts[0].hi+1===parts[1].lo&&parts[1].hi===parent.hi;
  }
  function predicate(t){
    const x=base(t.rootId);
    if(!x||!assertTask(t))return "Invalid frozen scope";
    return x.scale.name+" in ["+t.lo+", "+t.hi+"]";
  }
  function brief(t){
    const x=base(t.rootId);
    if(!x||!assertTask(t))throw Error("Invalid assignment");
    return [
      "NIGHTFALL / NF FRONTIER DISPATCH / "+VERSION,
      "Assignment ID: "+t.id,
      "Parent open problem: "+x.parent,
      "Precisely scoped question: "+x.question,
      "Exhaustive branch condition: "+predicate(t),
      "Baseline and unresolved gap: "+x.why,
      "Positive closure certificate: "+x.closureYes,
      "Negative closure certificate: "+x.closureNo,
      "Independent review: required for either closure claim; a timeout is inconclusive.",
      "Stop/switch rule: "+x.stop,
      "Sources: "+x.source+" | "+x.data,
      "NIGHTFALL provenance: "+x.evidence+" | "+x.issue,
      "Tool route: "+x.tools.join(", "),
      "Report a reproducible proof/witness, an explicit obstruction, or two exhaustive disjoint child branches.",
      "A report is a claim awaiting review, never an automatic promotion."
    ].join("\n");
  }
  function issueUrl(t,kind,details){
    const x=base(t.rootId);
    if(!x)throw Error("Invalid assignment");
    const title="[NF Dispatch / "+kind+"] "+t.id+" — "+predicate(t);
    const body=brief(t)+"\n\nSubmission kind: "+kind+"\nEvidence / approach:\n"+String(details||"(to be supplied)")+"\n\nReview request: independently check statement, source version and exact scope.";
    return ROOT+"/issues/new?title="+encodeURIComponent(title)+"&body="+encodeURIComponent(body);
  }
  function checkSidonCandidate(values,N,task){
    if(!Array.isArray(values)||!Number.isSafeInteger(N)||N<1)throw Error("Invalid finite input.");
    if(values.length!==9)return {ok:false,reason:"The assignment requires exactly nine integers."};
    if(values.some(v=>!Number.isSafeInteger(v)||v<1||v>N)||new Set(values).size!==values.length)
      return {ok:false,reason:"Every selected value must be distinct and within [1,"+N+"]."};
    const A=values.slice().sort((a,b)=>a-b);
    if(task&&(!assertTask(task)||task.rootId!=="NF-156-184-9"||A[0]<task.lo||A[0]>task.hi))
      return {ok:false,reason:"The candidate lies outside the assigned minimum-mark branch."};
    function uniqueSums(list){
      const seen=new Map();
      for(let i=0;i<list.length;i++)for(let j=i;j<list.length;j++){
        const s=list[i]+list[j];
        if(seen.has(s))return {ok:false,sum:s,first:seen.get(s),second:[list[i],list[j]]};
        seen.set(s,[list[i],list[j]]);
      }
      return {ok:true,count:seen.size};
    }
    const sums=uniqueSums(A);
    if(!sums.ok)return {ok:false,reason:"Repeated pair sum "+sums.sum+": ("+sums.first.join(",")+") and ("+sums.second.join(",")+").",values:A};
    const members=new Set(A),addable=[];
    for(let z=1;z<=N;z++)if(!members.has(z)&&uniqueSums(A.concat(z)).ok)addable.push(z);
    if(addable.length)return {ok:false,reason:"Sidon condition passes; the set is not maximal. Addable marks: "+addable.slice(0,18).join(", ")+(addable.length>18?" …":""),values:A,addableCount:addable.length,sumCount:sums.count};
    return {ok:true,reason:"Exact finite checks pass: 45 distinct unordered pair sums and all "+(N-9)+" omitted marks block insertion. Independent reproduction remains required.",values:A,sumCount:sums.count,checkedOmissions:N-9};
  }
  return Object.freeze({VERSION,ITEMS,WEIGHTS,score,ranked,base,rootTask,assertTask,split,validPartition,predicate,brief,issueUrl,checkSidonCandidate});
});
