/* Source-bound finite Sidon investigation, deliberately independent of the
   existing NFFrontier pair-sum + exhaustive add-one checker.
   Browser execution is local, not external review or global UNSAT proof. */
(function(root,factory){
 const api=factory();
 if(typeof module==="object"&&module.exports)module.exports=api;
 else root.NFJoinEvidence=api;
})(typeof globalThis==="object"?globalThis:this,function(){
"use strict";
const FORMAT="nightfall-join-evidence-v1", MAX_RECORDS=12, N=184;
const FIXTURE_COLLISION=[1,2,3,4,5,6,7,8,9];
const FIXTURE_EXTENDABLE=[1,2,6,13,26,28,36,42,45];
function normalize(raw){
 const words=Array.isArray(raw)?raw.map(String):String(raw??"").trim().split(/[\s,;]+/).filter(Boolean);
 if(words.length!==9||words.some(x=>!/^(0|[1-9]\d*)$/.test(x)))throw Error("Exactly nine canonical whole numbers are required.");
 const values=words.map(Number);
 if(values.some(x=>!Number.isSafeInteger(x)||x<1||x>N))throw Error("Marks must lie in [1,184].");
 return values.sort((a,b)=>a-b);
}
function source(task,frontier){
 if(!frontier||typeof frontier.validatePacket!=="function")throw Error("Missing frozen Frontier contract.");
 const v=frontier.validatePacket(task);
 if(v.assignment.rootId!=="NF-156-184-9")throw Error("Only the N=184 maximal-Sidon assignment has this finite checker.");
 return v;
}
function independent(values,packet,frontier){
 source(packet,frontier);
 if(values.length!==9||new Set(values).size!==9)return {status:"INPUT_REJECTED",reason:"Nine distinct marks required."};
 if(values[0]<packet.lo||values[0]>packet.hi)return {status:"INPUT_REJECTED",reason:"Minimum mark outside frozen assignment branch."};
 // Difference uniqueness is equivalent to classical Sidon pair-sum uniqueness.
 // This checker avoids the primary algorithm's pair-sum construction.
 const diffs=new Map();
 for(let j=1;j<9;j++)for(let i=0;i<j;i++){
  const d=values[j]-values[i];
  if(diffs.has(d))return {status:"PAIR_COLLISION",difference:d,first:diffs.get(d),second:[values[i],values[j]]};
  diffs.set(d,[values[i],values[j]]);
 }
 if(diffs.size!==36)throw Error("Finite Sidon difference-count invariant failed.");
 // Different insertion check: one precomputed old pair-sum table, then
 // compare the nine new off-diagonal sums and new diagonal 2z against it.
 const old=new Set();
 for(let i=0;i<9;i++)for(let j=i;j<9;j++)old.add(values[i]+values[j]);
 if(old.size!==45)throw Error("Independent difference/pair-sum invariant disagrees.");
 const present=new Set(values),addable=[];
 for(let z=1;z<=N;z++){
  if(present.has(z))continue;
  if(old.has(2*z))continue;
  let collision=false;
  for(const a of values)if(old.has(z+a)){collision=true;break}
  if(!collision)addable.push(z);
 }
 return addable.length?{status:"EXTENDABLE",addable,addableCount:addable.length,checkedOmissions:N-9}:
  {status:"MAXIMAL_FINITE",addable:[],addableCount:0,checkedOmissions:N-9};
}
function classifyPrimary(p){
 if(p.ok)return "MAXIMAL_FINITE";
 if(/^Repeated pair sum /.test(p.reason||""))return "PAIR_COLLISION";
 if((p.reason||"").includes("not maximal"))return "EXTENDABLE";
 return "INPUT_REJECTED";
}
function check(raw,packet,frontier){
 const t=source(packet,frontier).assignment,values=normalize(raw);
 const a=frontier.checkSidonCandidate(values,N,t);
 const b=independent(values,packet,frontier);
 const primary=classifyPrimary(a);
 const agree=primary===b.status&&(primary!=="EXTENDABLE"||a.addableCount===b.addableCount);
 return {values,primary_status:primary,primary_reason:a.reason,independent_status:b.status,
  independent:b,agreement:agree,claim_status:agree?"LOCAL_FINITE_CHECK / EXTERNAL_REPLAY_OPEN":"INCONCLUSIVE / CHECKER_DISAGREEMENT",
  global_unsat_proved:false,independent_external_review:false};
}
function attack(result,packet,frontier){
 source(packet,frontier);
 if(!result||!Array.isArray(result.values))throw Error("No checked source to attack.");
 const again=check(result.values,packet,frontier);
 if(JSON.stringify(result)!==JSON.stringify(again))throw Error("Candidate check changed since challenge.");
 const root=frontier.packet(frontier.rootTask(frontier.base("NF-156-184-9")));
 const cases=[
  {name:"duplicate-coordinate negative control",values:[1,1,3,4,5,6,7,8,9],expected:"INPUT_REJECTED"},
  {name:"known pair-sum collision control",values:FIXTURE_COLLISION,expected:"PAIR_COLLISION"},
  {name:"known extendable strong Sidon control",values:FIXTURE_EXTENDABLE,expected:"EXTENDABLE"}
 ];
 const controls=cases.map(c=>{
  const v=check(c.values,root,frontier);
  return {name:c.name,expected:c.expected,observed:v.independent_status,primary:v.primary_status,
   rejected_as_expected:v.agreement&&v.primary_status===c.expected};
 });
 const pass=result.agreement&&controls.every(x=>x.rejected_as_expected);
 return {status:pass?"LOCAL_ATTACK_CONTROLS_PASSED":"INCONCLUSIVE",
  controls,actual_candidate_outcome:result.independent_status,
  actual_obstruction:result.independent_status==="PAIR_COLLISION"?"Repeated positive difference; this candidate cannot be classical Sidon.":
   result.independent_status==="EXTENDABLE"?"An addable mark disproves maximality for this particular candidate.":
   result.independent_status==="MAXIMAL_FINITE"?"No single insertion survived the exhaustive bounded scan. Existence beyond this candidate and global negative claims remain open.":
   "Invalid candidate or branch inputs; no mathematical verdict.",
  bounded_falsification_only:true,external_review:false};
}
function receipt(raw,packet,note,frontier){
 const s=source(packet,frontier),comment=String(note??"");
 if(comment.length>4000)throw Error("Research note exceeds 4000 characters.");
 const computed=check(raw,packet,frontier),adversarial=attack(computed,packet,frontier);
 if(!computed.agreement||adversarial.status!=="LOCAL_ATTACK_CONTROLS_PASSED")
  throw Error("Checker disagreement or negative control failure. Evidence preservation refused.");
 return {format:FORMAT,frontier_snapshot:frontier.VERSION,assignment:frontier.packet(s.assignment),
  input:computed.values,calculation:computed,attack:adversarial,author_note:comment,
  human_action:"PRESERVE_FOR_INDEPENDENT_REVIEW",reviewStatus:"unreviewed",
  global_problem_solved:false,independent_external_review:false,novelty_established:false,
  provenance:"Browser-local dual method; source input and calculations are reproducible but not authenticated."};
}
function verify(receiptValue,frontier){
 try{
  const r=receiptValue;
  if(!r||r.format!==FORMAT||r.human_action!=="PRESERVE_FOR_INDEPENDENT_REVIEW"||
    r.reviewStatus!=="unreviewed"||r.global_problem_solved!==false||
    r.independent_external_review!==false||r.novelty_established!==false||
    typeof r.author_note!=="string"||r.author_note.length>4000||
    r.frontier_snapshot!==frontier.VERSION)return {valid:false,reason:"Invalid or promoted receipt metadata"};
  const expected=receipt(r.input,r.assignment,r.author_note,frontier);
  const same=JSON.stringify(expected)===JSON.stringify(r);
  return {valid:same,reason:same?"Finite source and controls recomputed locally":"Receipt does not match deterministic local replay"};
 }catch(e){return {valid:false,reason:String(e.message)}}
}
return Object.freeze({FORMAT,MAX_RECORDS,N,normalize,independent,check,attack,receipt,verify});
});
