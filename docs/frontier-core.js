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
      tools:["orchestrator.html","discovery.html","claim-lab.html","desk.html"],
      toolHint:"Orchestrator plans independent lanes; Discovery imports this exact branch as a separate unverified project; Claim Lab tracks proposals. The 30-point finite Referee does not certify maximal Sidon sets.",
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
      tools:["orchestrator.html","discovery.html","claim-lab.html","atlas.html"],
      toolHint:"Orchestrator freezes independent lanes, Discovery keeps this six-deletion scope separate from published finite examples, and Claim Lab tracks proposed evidence. Use the Q7 source checker for exact four-cycle tests.",
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
  function orchestratorInput(t){
    const x=base(t&&t.rootId);
    if(!x||!assertTask(t))throw Error("Invalid frozen Frontier assignment.");
    return {
      id:t.id.slice(0,80),
      claim:x.question+" Restricted to "+predicate(t)+".",
      source:x.evidence+" | Agent NF snapshot "+VERSION,
      falsifier:"A claimed YES fails if any positive-certificate requirement is violated: "+x.closureYes+" A claimed NO fails if a valid witness survives, an assigned branch is omitted, or the complete proof cannot be replayed. Required negative certificate: "+x.closureNo
    };
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

  // Research state is an assignment tree, not a bag of user-editable records.
  // Verify the entire chain before consuming exported data from another browser.
  const STATES=new Set(["open","claimed","split","proposed"]);
  const EVIDENCE=new Set(["positive","negative","obstruction"]);
  function validateLedger(items) {
    if(!Array.isArray(items)||items.length>250)throw Error("Ledger must contain at most 250 assignments.");
    const seen=new Map(),errors=[];
    for(const t of items){
      if(!t||!assertTask(t)||!STATES.has(t.state)||typeof t.id!=="string"||t.id.length>160||seen.has(t.id)){
        errors.push("Malformed or duplicate task");continue;
      }
      if(!Number.isInteger(t.depth)||t.depth<0||t.depth>16||!Array.isArray(t.evidence)||t.evidence.length>8){
        errors.push("Malformed task depth or evidence");continue;
      }
      if(t.claimedAt!==null&&t.claimedAt!==undefined&&(typeof t.claimedAt!=="string"||t.claimedAt.length>50))
        errors.push("Invalid local claim date");
      for(const e of t.evidence){
        if(!e||!EVIDENCE.has(e.kind)||typeof e.url!=="string"||e.url.length>700||
           !/^https:\/\/[^\s<>"']+$/.test(e.url)||typeof e.statement!=="string"||
           e.statement.length<30||e.statement.length>1800||e.reviewStatus!=="unreviewed")
          errors.push("Malformed or upgraded evidence metadata");
      }
      if(t.evidence.length>0&&t.state!=="proposed")errors.push("Evidence state mismatch");
      seen.set(t.id,t);
    }
    if(errors.length)throw Error(errors[0]);
    for(const t of seen.values()){
      if(t.parentId===null){
        const root=base(t.rootId),canonical=root&&rootTask(root);
        if(!canonical||t.id!==canonical.id||t.depth!==0||t.lo!==canonical.lo||t.hi!==canonical.hi)
          throw Error("Root identity or interval changed");
      }else{
        const parent=seen.get(t.parentId);
        if(!parent||parent.state!=="split"||parent.rootId!==t.rootId||t.depth!==parent.depth+1)
          throw Error("Orphaned child or parent state mismatch");
        const expected=split(parent);
        if(!expected.some(x=>x.id===t.id&&x.lo===t.lo&&x.hi===t.hi))
          throw Error("Child interval or canonical identity changed");
      }
      if(t.state==="split"){
        const expected=split(t);
        if(expected.some(child=>!seen.has(child.id))||
           !validPartition(t,expected))
          throw Error("Split parent lacks an exhaustive pair of children");
      }else if([...seen.values()].some(x=>x.parentId===t.id)){
        throw Error("Unsplit parent has an unexpected child");
      }
    }
    return {valid:true,counts:summarizeLedger(items)};
  }
  function summarizeLedger(items){
    const counts={total:items.length,open:0,claimed:0,split:0,proposed:0,unreviewed:0,leaves:0};
    for(const t of items){
      if(STATES.has(t.state))counts[t.state]++;
      if(t.state!=="split")counts.leaves++;
      counts.unreviewed+=Array.isArray(t.evidence)?t.evidence.length:0;
    }
    return counts;
  }
  const PACKET_SCHEMA="nightfall-frontier-assignment-v1";
  function packet(t){
    if(!assertTask(t))throw Error("Invalid assignment for transfer");
    const x=base(t.rootId);
    const reconstructed=t.parentId===null?rootTask(x):null;
    if(t.parentId===null&&(t.id!==reconstructed.id||t.lo!==reconstructed.lo||t.hi!==reconstructed.hi))
      throw Error("Root scope mismatch");
    if(t.parentId!==null&&!/^NF-(?:156-184-9|Q7-R6)(?:\/\d+-\d+)+$/.test(t.id))
      throw Error("Invalid branch identity");
    return {schema:PACKET_SCHEMA,snapshot:VERSION,assignmentId:t.id,rootId:t.rootId,
      lo:t.lo,hi:t.hi,parentId:t.parentId,depth:t.depth,scope:predicate(t),
      question:x.question,source:x.evidence,sourceProblem:x.source,
      positive:x.closureYes,negative:x.closureNo,falsifier:"A verified counterexample to the proposed YES or NO, under "+predicate(t),
      reviewStatus:"unreviewed"};
  }
  function validatePacket(p){
    if(!p||p.schema!==PACKET_SCHEMA||p.snapshot!==VERSION||
       typeof p.assignmentId!=="string"||p.assignmentId.length>160||
       p.reviewStatus!=="unreviewed")throw Error("Unsupported or promoted Frontier packet");
    const x=base(p.rootId);
    if(!x||!Number.isSafeInteger(p.lo)||!Number.isSafeInteger(p.hi)||
       p.lo<x.scale.min||p.hi>x.scale.max||p.lo>p.hi||
       !Number.isInteger(p.depth)||p.depth<0||p.depth>16)
      throw Error("Invalid Frontier scope");
    let current=rootTask(x);
    if(p.parentId!==null){
      const chunks=p.assignmentId.split("/");
      if(chunks[0]!==x.id||chunks.length!==p.depth+1)throw Error("Branch lineage mismatch");
      for(const chunk of chunks.slice(1)){
        const children=split(current);
        const match=children.find(c=>c.id===current.id+"/"+chunk);
        if(!match)throw Error("Invalid branch partition lineage");
        current=match;
      }
      if(current.parentId!==p.parentId)throw Error("Branch parent mismatch");
    }else if(p.depth!==0)throw Error("Invalid root depth");
    if(current.id!==p.assignmentId||current.lo!==p.lo||current.hi!==p.hi||
       p.scope!==predicate(current)||p.question!==x.question||
       p.source!==x.evidence||p.sourceProblem!==x.source||
       p.positive!==x.closureYes||p.negative!==x.closureNo||
       p.falsifier!=="A verified counterexample to the proposed YES or NO, under "+predicate(current))
      throw Error("Frontier contract altered during transfer");
    return {assignment:current,root:x};
  }

  return Object.freeze({VERSION,ITEMS,WEIGHTS,score,ranked,base,rootTask,assertTask,split,validPartition,predicate,brief,issueUrl,orchestratorInput,checkSidonCandidate,validateLedger,summarizeLedger,packet,validatePacket});
});
