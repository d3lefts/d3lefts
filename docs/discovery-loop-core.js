/* NIGHTFALL Living Investigation — bounded, local, deterministic research pilot.
   Exhaustive claims are finite cyclic-configuration claims ONLY. No new theorem
   priority, continuous minimum-overlap result, or external independent audit. */
(function(root,factory){
  const api=factory();
  if(typeof module==="object"&&module.exports)module.exports=api;
  else root.NightfallDiscoveryLoop=api;
})(typeof globalThis==="object"?globalThis:this,function(){
"use strict";
const SCHEMA="nightfall-discovery-loop-v1", VERSION="1.0.0";
const TARGETS=[];
for(let n=8;n<=16;n++)for(let mass=3;mass<=6;mass++)TARGETS.push({n,mass});
const MAX_STEPS=12;
function choose(n,k){
 let result=1;
 for(let i=1;i<=k;i++)result=result*(n-k+i)/i;
 return Math.round(result);
}
function bound(n,m){return Math.ceil(m*(m-1)/(n-1));}
function histogram(n,marks){
 const h=Array(n).fill(0);
 for(let i=0;i<marks.length;i++)for(let j=i+1;j<marks.length;j++){
  const d=marks[j]-marks[i];h[d]++;h[n-d]++;
 }
 return h.slice(1);
}
function directHistogram(n,marks){
 const bits=Array(n).fill(0);for(const i of marks)bits[i]=1;
 const counts=[];
 for(let shift=1;shift<n;shift++){
  let count=0;
  for(let i=0;i<n;i++)count+=bits[i]*bits[(i+shift)%n];
  counts.push(count);
 }
 return counts;
}
function enumerate(n,mass){
 if(!Number.isInteger(n)||n<8||n>16||!Number.isInteger(mass)||mass<3||mass>6)
  throw Error("Pilot scope: 8–16 cyclic positions, 3–6 marks.");
 let count=0,best=Infinity,witness=null,dist={},bestCount=0;
 const marks=[0];
 function walk(start,remaining){
  if(remaining===0){
   const max=Math.max(...histogram(n,marks));
   count++;dist[max]=(dist[max]||0)+1;
   if(max<best){best=max;witness=marks.slice();bestCount=1}
   else if(max===best)bestCount++;
   return;
  }
  for(let i=start;i<=n-remaining;i++){
   marks.push(i);walk(i+1,remaining-1);marks.pop();
  }
 }
 walk(1,mass-1);
 const expected=choose(n-1,mass-1);
 if(count!==expected)throw Error("Enumeration count invariant failed");
 const primary=histogram(n,witness),independent=directHistogram(n,witness);
 if(primary.join(",")!==independent.join(",")||primary.reduce((a,b)=>a+b,0)!==mass*(mass-1))
  throw Error("Independent witness calculation disagrees");
 const floor=bound(n,mass);
 return {n,mass,lower_bound:floor,exact_minimax:best,gap:best-floor,
  anchored_subsets:count,expected_anchored_subsets:expected,
  optimal_anchored_subsets:bestCount,one_optimal_set:witness,
  witness_shift_counts:primary,distribution:dist,
  coverage:"All subsets containing position 0. Cyclic translation moves any nonempty subset to one containing 0.",
  verification:"Same-process exhaustive enumeration plus a distinct direct-shift witness replay; independent external audit OPEN",
  scope:"Finite cyclic binary proxy; not the continuous Erdős minimum-overlap benchmark."};
}
function empty(){
 return {schema:SCHEMA,version:VERSION,created:null,updated:null,
  starting_question:"Does the elementary average-correlation lower bound remain attainable when a finite cyclic design grows from 15 positions to 16 with six marks?",
  hypothesis:"Sharpness transfers from n=15 to n=16 at mass 6.",
  step_budget:MAX_STEPS,records:[],residues:[],
  independent_audit:false,peer_review:false,original_finding:false};
}
function assertState(s){
 if(!s||s.schema!==SCHEMA||s.version!==VERSION||!Array.isArray(s.records)||!Array.isArray(s.residues)||s.records.length>MAX_STEPS)throw Error("Invalid pilot state");
 if(s.independent_audit!==false||s.peer_review!==false||s.original_finding!==false||s.step_budget!==MAX_STEPS)throw Error("Unreviewed pilot cannot import upgraded scientific claims or budget changes");
 const seen=new Set();
 for(const r of s.records){
  if(!TARGETS.some(t=>t.n===r.target?.n&&t.mass===r.target?.mass))throw Error("Outside pilot targets");
  const key=r.target.n+":"+r.target.mass;
  if(seen.has(key))throw Error("Repeated pilot target");
  seen.add(key);
 }
 return s;
}
function predictionFor(records,t){
 const matches=records.filter(r=>r.target.mass===t.mass)
  .sort((a,b)=>Math.abs(a.target.n-t.n)-Math.abs(b.target.n-t.n)||a.target.n-b.target.n);
 if(!matches.length)return {kind:"BASELINE",gap:null,
  explanation:"No same-mass observation exists. Test this initial finite design."};
 const nearest=matches[0];
 return {kind:"LOCAL_TRANSFER",gap:nearest.result.gap,
  parent:nearest.target.n+":"+nearest.target.mass,
  explanation:"Predict the exact finite lower-bound gap from the closest previously enumerated design with the same mass; this is a falsifiable heuristic, not a theorem."};
}
/* Candidate policy is inspectable and deterministic. Scores are ordering heuristics,
   not calibrated information gain or predicted mathematical novelty. */
function candidates(s,limit=4){
 assertState(s);
 if(!Number.isInteger(limit)||limit<1||limit>TARGETS.length)throw Error("Candidate limit outside supported scope");
 if(s.records.length>=MAX_STEPS)return [];
 if(!s.records.length){
  const target={n:15,mass:6};
  return [{rank:1,target,prediction:predictionFor([],target),
   rationale:"Seed case selected to test a known mathematical design question. Subsequent targets are selected from observed data.",
   score:null,anchored_subsets:choose(14,5),selection_signal:"PRESELECTED_SEED"}];
 }
 const seen=new Set(s.records.map(r=>r.target.n+":"+r.target.mass));
 const last=s.records[s.records.length-1];
 return TARGETS.filter(t=>!seen.has(t.n+":"+t.mass)).map(t=>{
  const pred=predictionFor(s.records,t),dn=Math.abs(t.n-last.target.n),dm=Math.abs(t.mass-last.target.mass);
  const nearby=dm===0&&dn===1?100:dn===0&&dm===1?82:dm===0?65:dn<=1&&dm<=1?51:0;
  const surprise=last.surprise&&dm===0?16:0;
  const forward=dm===0&&t.n===last.target.n+1?8:0;
  const novelty=pred.kind==="BASELINE"?9:0;
  const complexity=Math.log2(choose(t.n-1,t.mass-1));
  const score=nearby+surprise+forward+novelty-complexity/12;
  const selection_signal=surprise?"FOLLOW_UP_ON_SURPRISE":forward?"ADJACENT_FORWARD_TEST":novelty?"BASELINE_UNTESTED_MASS":"STRUCTURAL_NEIGHBOR";
  return {target:t,prediction:pred,
   rationale:"Selected by deterministic nearby-boundary and surprise-followup priority, with a small enumeration-cost penalty.",
   score,anchored_subsets:choose(t.n-1,t.mass-1),selection_signal};
 }).sort((a,b)=>b.score-a.score||a.target.n-b.target.n||a.target.mass-b.target.mass)
   .map((r,i)=>({...r,rank:i+1})).slice(0,limit);
}
function next(s){
 const c=candidates(s,1)[0];
 return c?{target:c.target,prediction:c.prediction,rationale:c.rationale}:null;
}
function parseDecision(s,input){
 if(!input||input.action!=="APPROVE_ONE"||typeof input.note!=="string"||input.note.length>280)
  throw Error("Human review requires explicit approval and a brief optional note (280-character maximum).");
 if(!input.target||!Number.isInteger(input.target.n)||!Number.isInteger(input.target.mass))
  throw Error("Review target must be an exact finite parameter pair.");
 const match=candidates(s,TARGETS.length).find(x=>x.target.n===input.target.n&&x.target.mass===input.target.mass);
 if(!match)throw Error("Approved target already used, out of scope, or investigation finished.");
 return {choice:match,decision:{action:"APPROVE_ONE",target:{n:match.target.n,mass:match.target.mass},
  note:input.note,source:match.rank===1?"RECOMMENDED":"HUMAN_REDIRECTION",
  rank_at_approval:match.rank}};
}
function advance(snapshot,approval){
 const s=structuredClone(assertState(snapshot));
 let choice,decision=null;
 if(approval===undefined)choice=next(s); // compatibility: previously saved v1 automatic steps
 else{
  const parsed=parseDecision(s,approval);
  choice=parsed.choice;decision=parsed.decision;
 }
 if(!choice)throw Error("Pilot reached its bounded 12-experiment stop rule.");
 const result=enumerate(choice.target.n,choice.target.mass);
 const surprise=choice.prediction.gap!==null&&choice.prediction.gap!==result.gap;
 const record={index:s.records.length+1,target:choice.target,
  prediction:choice.prediction,selection_reason:choice.rationale,
  result,surprise,
  verdict:choice.prediction.gap===null?"INITIAL_MEASUREMENT":surprise?"LOCAL_PREDICTION_FALSIFIED":"LOCAL_PREDICTION_SURVIVED",
  claim_status:"EXACT_FINITE_LOCAL_ENUMERATION / INDEPENDENT_AUDIT_OPEN"};
 if(decision)record.decision=decision;
 s.records.push(record);
 if(surprise||result.gap>0){
  s.residues.push({id:"residue-"+record.index,
   source_step:record.index,target:choice.target,
   kind:surprise?"PREDICTION_FALSIFIED": "STRICT_BOUND_GAP",
   observation:surprise
    ?"Nearest same-mass gap predicted "+choice.prediction.gap+"; exhaustive minimum has gap "+result.gap+"."
    :"Elementary lower bound is unattained in this enumerated finite cyclic scope (gap "+result.gap+").",
   falsifier:"Find a cyclic "+choice.target.n+"-position configuration of mass "+choice.target.mass+" with maximum shift count below "+result.exact_minimax+".",
   next_question:"Does this obstruction persist under neighboring n and mass, and can a structural invariant explain it without enumeration?",
   status:"FINITE_OBSERVATION / GENERALIZATION_UNPROVED"});
 }
 s.updated="local-user-run";
 if(!s.created)s.created="local-user-run";
 return s;
}
function metrics(s){
 assertState(s);
 return {steps:s.records.length,
  anchored_subsets_checked:s.records.reduce((a,r)=>a+r.result.anchored_subsets,0),
  failed_local_predictions:s.records.filter(r=>r.surprise).length,
  strict_finite_gaps:s.records.filter(r=>r.result.gap>0).length,
  user_approved_steps:s.records.filter(r=>r.decision?.action==="APPROVE_ONE").length,
  user_redirected_steps:s.records.filter(r=>r.decision?.source==="HUMAN_REDIRECTION").length,
  independent_external_audit:false};
}
function replay(s){
 assertState(s);const issues=[];
 const fresh=empty();
 for(let i=0;i<s.records.length;i++){
  const expect=advance(fresh,s.records[i].decision?{action:s.records[i].decision.action,target:s.records[i].decision.target,note:s.records[i].decision.note}:undefined);
  const claimed=s.records[i],actual=expect.records[i];
  if(JSON.stringify(claimed)!==JSON.stringify(actual))issues.push("Step "+(i+1)+" differs from deterministic reconstruction");
  fresh.records=expect.records;fresh.residues=expect.residues;
 }
 if(JSON.stringify(s.residues)!==JSON.stringify(fresh.residues))issues.push("Residue ledger differs from deterministic reconstruction");
 return {status:issues.length?"REJECTED":"LOCALLY_REPLAYED",
  issues,steps:s.records.length,independent_external_audit:false,
  scope:"Deterministic exact finite pilot replay in the same implementation; publication evidence remains OPEN."};
}
return {SCHEMA,VERSION,MAX_STEPS,TARGETS,empty,enumerate,choose,bound, histogram,directHistogram,
 predictionFor,candidates,next,advance,replay,metrics,assertState};
});
