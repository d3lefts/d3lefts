/* NIGHTFALL Frontier / Agent NF — transparent, local-first research triage. */
(function(root,factory){const api=factory();if(typeof module==="object"&&module.exports)module.exports=api;else root.NIGHTFALL_FRONTIER=api;})(typeof globalThis==="object"?globalThis:this,function(){"use strict";
const VERSION="nightfall-frontier-v1",SNAPSHOT="2026-10-29";
const RUBRIC=Object.freeze({decisive:2,tractable:2,leverage:1,evidence:1});
const CASES=Object.freeze([
 {id:"NF-156-184",title:"Nine marks. One missing decision.",area:"Additive combinatorics",issue:46,
  parent:"Erdős #156 — small maximal Sidon sets",challenge:"Is there an inclusion-maximal Sidon set of exactly nine integers inside [1,184]?",
  why:"Axiom has an exact SAT encoding and a nine-mark near-candidate with only two still-addable points. The N=184, k=9 yes/no decision has no published certificate in the frozen NIGHTFALL snapshot.",
  source:"https://github.com/d3lefts/d3lefts/blob/research/axiom-sidon-20261029/research/nightfall/projects/erdos/sidon-axiom-2026-10-29/sat_exact_184/SAT_N184_K9_AUDIT.md",
  rubric:{decisive:5,tractable:5,leverage:4,evidence:5},
  parts:[
   {id:"witness",title:"Construct an exact nine-mark witness",kind:"construct",claim:"Find nine distinct marks in [1,184] whose unordered pair sums (including diagonal sums) are all distinct and for which every omitted mark creates a repeated sum.",falsifier:"One repeated original pair sum, or one excluded x whose insertion still preserves all pair sums.",tool:"Browser exact witness checker"},
   {id:"unsat",title:"Prove no nine-mark witness exists",kind:"formalize",claim:"Provide a sound, complete and independently replayable UNSAT certificate for the exact N=184, k=9 saturation CNF, if the instance is unsatisfiable.",falsifier:"A valid nine-mark witness, an unsound encoding, or a verifier rejection of the UNSAT proof.",tool:"Orchestrator + separate SAT proof checker"},
   {id:"encoding",title:"Audit the SAT reduction independently",kind:"reproduce",claim:"Prove both directions of the N=184, k=9 encoding, including diagonal sums and a genuine blocker for each omitted mark.",falsifier:"A satisfying assignment with an invalid maximal Sidon set, or a valid witness excluded by the encoding.",tool:"Orchestrator + independent arithmetic oracle"}
  ]},
 {id:"NF-86-Q7",title:"The 305th edge.",area:"Extremal graph theory",issue:48,
  parent:"Erdős #86 — C4-free hypercube",challenge:"Does Q7 contain a C4-free subgraph with at least 305 of its 448 edges?",
  why:"A 304-edge construction is known. NIGHTFALL's five-deletion audit excluded improvements near 180 supplied 304-edge orbit representatives, leaving the global 305-edge question open.",
  source:"https://github.com/d3lefts/d3lefts/pull/70",
  rubric:{decisive:5,tractable:2,leverage:5,evidence:4},
  parts:[
   {id:"candidate",title:"Construct 305 edges",kind:"construct",claim:"Supply 305 distinct edges of the 7-cube with none of its 672 coordinate squares complete.",falsifier:"An invalid cube edge, duplicate selected edge, edge count below 305, or one selected coordinate square.",tool:"Orchestrator + independent Q7 checker"},
   {id:"global",title:"Certify a global upper bound",kind:"formalize",claim:"Produce a checkable global SAT/ILP proof that every C4-free Q7 graph has at most 304 edges.",falsifier:"A 305-edge graph or a gap in the symmetry/solver proof trace.",tool:"Orchestrator + proof-producing solver"},
   {id:"beyond",title:"Leave the five-deletion neighborhood",kind:"explore",claim:"Find an inequivalent Q7 representation whose feasible 305-edge search is not exhausted by 180 known seeds and five deletions.",falsifier:"Reduction back to one of the excluded fixed neighborhoods.",tool:"Research Desk + Orchestrator"}
  ]},
 {id:"NF-36-LOWER",title:"Break the saturated dual.",area:"Continuous optimization",issue:76,
  parent:"Erdős #36 — minimum overlap",challenge:"Find a universal lower-bound operator exceeding the fixed eight-row certificate family.",
  why:"The archived conditional bound is 0.38062747462668, and a proved pointwise ceiling limits further gains from the unchanged eight rows to below 6e-15.",
  source:"https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/agent-reports/ea36_lower_20261028/RESEARCH_NOTE.md",
  rubric:{decisive:2,tractable:1,leverage:5,evidence:4},
  parts:[
   {id:"dual",title:"Construct a new coupled dual",kind:"construct",claim:"Give a universally valid inequality for all admissible densities improving the lower bound by >=1e-8 at the same analytic premises.",falsifier:"A counterexample density, invalid dual feasibility, or failure to improve the baseline.",tool:"Orchestrator + exact arithmetic"},
   {id:"replay",title:"Independently replay Arb premises",kind:"reproduce",claim:"Regenerate outward-rounded central and outer continuum enclosures without relying on archived interval output.",falsifier:"An interval that does not enclose the target expression, a source mismatch, or missing analytic reduction.",tool:"Orchestrator + independent interval tool"},
   {id:"obstruction",title:"Prove a new dual-family obstruction",kind:"formalize",claim:"Determine a sharp ceiling for a mathematically defined enlarged dual family, beyond the eight frozen rows.",falsifier:"One valid dual in the stated family exceeding the proposed ceiling.",tool:"Research Desk + Orchestrator"}
  ]}
]);
const NEAR=[49,50,56,78,93,104,125,139,149];
function score(c){return Object.keys(RUBRIC).reduce((s,k)=>s+RUBRIC[k]*c.rubric[k],0)}
function prioritize(cs=CASES){return cs.slice().sort((a,b)=>score(b)-score(a)||a.id.localeCompare(b.id))}
function verifyNine(input){
 const raw=String(input||"").trim();if(raw.length>1200)return {status:"INVALID_INPUT",message:"Input exceeds the 1200-character limit."};
 const parts=raw.split(/[\s,;]+/).filter(Boolean);
 if(parts.length!==9)return {status:"INVALID_INPUT",message:"Provide exactly nine integer marks; received "+parts.length+"."};
 if(parts.some(x=>!/^\d+$/.test(x)))return {status:"INVALID_INPUT",message:"Marks must be whole decimal integers."};
 const marks=parts.map(Number);
 if(marks.some(x=>!Number.isSafeInteger(x)||x<1||x>184))return {status:"INVALID_INPUT",message:"Each mark must be an integer from 1 through 184."};
 const sorted=marks.slice().sort((a,b)=>a-b);
 if(new Set(sorted).size!==9)return {status:"INVALID_INPUT",message:"All nine marks must be distinct."};
 function pairs(A){
  const seen=new Map();
  for(let i=0;i<A.length;i++)for(let j=i;j<A.length;j++){
    const sum=A[i]+A[j];
    if(seen.has(sum))return {sum,first:seen.get(sum),second:[A[i],A[j]]};
    seen.set(sum,[A[i],A[j]]);
  }
  return null;
 }
 const collision=pairs(sorted);
 if(collision)return {status:"INVALID_SIDON",marks:sorted,collision,
  message:"Repeated unordered pair sum "+collision.sum+" from "+collision.first.join("+")+" and "+collision.second.join("+")+". Diagonal pairs count."};
 const current=new Set(sorted),addable=[];
 for(let x=1;x<=184;x++)if(!current.has(x)&&!pairs(sorted.concat(x)))addable.push(x);
 if(addable.length)return {status:"NOT_MAXIMAL",marks:sorted,addable,checked:175,
  message:"Sidon property holds, yet "+addable.length+" omitted mark(s) can still be inserted: "+addable.join(", ")+". This candidate does not settle N=184."};
 return {status:"FINITE_YES_CHECK_PASSED",marks:sorted,addable:[],checked:175,
  message:"Exact local check passed: 45 distinct unordered pair sums and all 175 omitted marks blocked. This witnesses YES for the finite N=184, k=9 existence question. Independent replay and dated priority review remain separate."};
}
function workItem(caseId,partId,children=[]){
 const c=CASES.find(x=>x.id===caseId);if(!c)return null;
 const base=c.parts.find(x=>x.id===partId);if(base)return {...base,caseId,nodeId:caseId+":"+base.id,source:c.source,issue:c.issue};
 const extra=children.find(x=>x.caseId===caseId&&x.id===partId);
 return extra?{...extra,nodeId:caseId+":"+extra.id,source:c.source,issue:c.issue}:null;
}
function split(caseId,parentId,title,falsifier,children=[]){
 const parent=workItem(caseId,parentId,children);
 if(!parent)throw Error("Choose an existing branch first.");
 const t=String(title||"").trim(),f=String(falsifier||"").trim();
 if(t.length<10||t.length>180||f.length<12||f.length>450)throw Error("Provide a specific 10–180 character question and a 12–450 character falsifier.");
 const depth=(parent.depth||0)+1;
 if(depth>3)throw Error("Subdivision stops at depth three. Export and open a new research issue.");
 if(children.length>=24)throw Error("Local decomposition has reached 24 child branches.");
 const counter=children.filter(x=>x.caseId===caseId).length+1;
 return {id:"child-"+counter,caseId,parentId,parent:caseId+":"+parentId,depth,title:t,falsifier:f,kind:"explore",
 claim:t,tool:"Orchestrator + independent checker",local:true};
}
function contract(item){if(!item)throw Error("Select a work branch.");
 return {schema:"nightfall-frontier-assignment-v1",version:SNAPSHOT,
  id:item.nodeId,issue:item.issue,claim:item.claim,source:item.source,
  falsifier:item.falsifier,scope:"An unresolved finite or analytic subproblem; no global proof status granted.",
  requiredEvidence:["exact statement and assumptions","source commit and SHA-256","construction or proof","independent verifier and negative controls","dated same-scope priority check"],
  status:"OPEN — personal assignment proposal; external assignment requires a public GitHub issue",review:"Pending independent reproduction and mathematical review"};
}
return Object.freeze({VERSION,SNAPSHOT,RUBRIC,CASES,NEAR,score,prioritize,verifyNine,workItem,split,contract});
});
