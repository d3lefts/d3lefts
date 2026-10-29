/* Interactive, user-triggered orchestration of the bounded discovery-loop pilot.
   Storage contains locally replayable experiment data, never proof credentials. */
(function(){
"use strict";
const C=window.NightfallDiscoveryLoop,KEY="nightfall.living-investigation.v1";
if(!C)return;
const $=id=>document.getElementById(id);
const escape=s=>String(s??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
let state=C.empty(),warning="";
let selectedTarget="",showAll=false;
try{
 const stored=localStorage.getItem(KEY);
 if(stored){
  const proposed=JSON.parse(stored),audit=C.replay(proposed);
  if(audit.status!=="LOCALLY_REPLAYED")throw Error("Previously saved experiment evidence failed local replay.");
  state=proposed;
 }
}catch(e){warning="Saved state was refused and reset: "+e.message;state=C.empty();}
function save(){
 try{localStorage.setItem(KEY,JSON.stringify(state))}
 catch(e){warning="Local persistence unavailable: "+e.message;}
}
function nextMarkup(next){
 if(!next)return '<p class="question-title">Stop rule reached.</p><p class="question-prose">Twelve bounded experiments were completed. Export the exact finite observations and pursue any general theorem under an independent proof gate.</p>';
 const t=next.target,p=next.prediction,amount=C.choose(t.n-1,t.mass-1);
 const expect=p.gap===null?"Initial observation: no prediction yet":"Predicted lower-bound gap: "+p.gap;
 return '<div class="question-kicker">'+escape(p.kind==="BASELINE"?"INITIAL SEED · TEST THE QUESTION":"HYPOTHESIS · LOCAL TRANSFER")+'</div>'+
  '<p class="question-title">'+t.n+' cyclic positions / '+t.mass+' marks</p>'+
  '<p class="question-prose">'+escape(expect)+'. '+escape(p.explanation)+'</p>'+
  '<p class="question-prose" style="margin-top:11px">'+escape(next.rationale)+'</p>'+
  '<div class="factline"><span>FLOOR ≥ '+C.bound(t.n,t.mass)+'</span><span>'+amount.toLocaleString("en-US")+' SUBSETS TO ENUMERATE</span><span>EXACT INTEGER</span></div>';
}
function renderCandidateControls(){
 const options=C.candidates(state,showAll?C.TARGETS.length:4);
 const selected=options.find(c=>c.target.n+":"+c.target.mass===selectedTarget)||options[0]||null;
 selectedTarget=selected?selected.target.n+":"+selected.target.mass:"";
 const select=$("candidate-choice");
 select.disabled=!options.length;
 select.innerHTML=options.map(c=>'<option value="'+c.target.n+':'+c.target.mass+'">'+
  '#'+c.rank+' · n='+c.target.n+', m='+c.target.mass+' · '+c.anchored_subsets.toLocaleString("en-US")+' checks · '+escape(c.selection_signal)+'</option>').join("");
 if(selected)select.value=selectedTarget;
 select.onchange=()=>{selectedTarget=select.value;render()};
 $("candidate-detail").textContent=selected?
  (selected.rank===1?"Recommended by the fixed heuristic. ":"Human-selected alternative (#"+selected.rank+"). State your scientific reason for redirecting. ")+
  "Predicted gap: "+(selected.prediction.gap===null?"unavailable":selected.prediction.gap)+
  ". Exact checks required: "+selected.anchored_subsets.toLocaleString("en-US")+
  ". Selection signal: "+selected.selection_signal+
  ". Ranking approximates proximity and compute cost, not information gain."
  :"Stop rule reached. Export your complete experiment history.";
 $("run-four").disabled=state.records.length>=C.MAX_STEPS;
 $("run-four").textContent=showAll?"Show top four":"Show all candidates";
 $("run-four").setAttribute("aria-pressed",String(showAll));
 return selected;
}
function renderMetrics(){
 const m=C.metrics(state);
 $("budget-metrics").innerHTML=[
  ["APPROVED EXPERIMENTS",m.user_approved_steps+" / "+C.MAX_STEPS],
  ["EXACT SUBSETS SEARCHED",m.anchored_subsets_checked.toLocaleString("en-US")],
  ["FALSIFIED LOCAL PREDICTIONS",String(m.failed_local_predictions)],
  ["STRICT FINITE GAPS",String(m.strict_finite_gaps)],
  ["HUMAN REDIRECTIONS",String(m.user_redirected_steps)]
 ].map(([label,value])=>'<div class="metric-item"><span>'+escape(label)+'</span><strong>'+escape(value)+'</strong></div>').join("");
}
function renderCoverage(){
 const results=new Map(state.records.map(r=>[r.target.n+":"+r.target.mass,r]));
 let html='<span class="cell label" aria-hidden="true">m / n</span>';
 for(let n=8;n<=16;n++)html+='<span class="cell label" aria-hidden="true">'+n+'</span>';
 for(let m=3;m<=6;m++){
  html+='<span class="cell label" aria-hidden="true">'+m+'</span>';
  for(let n=8;n<=16;n++){
   const r=results.get(n+":"+m),cls=r?(r.result.gap>0?"surprise":"found"):"";
   const desc=r?" exact minimum "+r.result.exact_minimax+", lower bound "+r.result.lower_bound:" unexplored";
   html+='<span class="cell '+cls+'" title="'+escape("n "+n+" m "+m+desc)+'" aria-label="'+escape("n "+n+" m "+m+desc)+'">'+(r?r.result.gap>0?"+"+r.result.gap:"✓":"·")+'</span>';
  }
 }
 $("coverage").innerHTML=html;
}
function renderHistory(){
 if(!state.records.length){$("history").innerHTML='<p class="empty-note">Run the first experiment to generate an evidence trail.</p>';return}
 $("history").innerHTML=state.records.slice().reverse().map(r=>{
  const result=r.result,p=r.prediction;
  return '<article class="history-entry">'+
   '<p class="history-id">STEP '+String(r.index).padStart(2,"0")+' / '+escape(r.verdict)+'</p>'+
   '<strong>n = '+r.target.n+', mass = '+r.target.mass+'</strong>'+
   '<span class="verdict '+(r.surprise?"false":"")+'">'+(r.surprise?"PREDICTION REFUTED":result.gap>0?"STRICT FINITE GAP":"FINITE BOUND SHARP")+'</span>'+
   '<p>Elementary floor: <b>'+result.lower_bound+'</b>. Exact finite minimax: <b>'+result.exact_minimax+'</b>. Gap: <b>'+result.gap+'</b>.</p>'+
   '<p>Anchor-complete subsets: <code>'+result.anchored_subsets.toLocaleString("en-US")+'</code>. One optimal mark set: <code>['+result.one_optimal_set.join(", ")+']</code>.</p>'+
   '<p>Prediction: '+(p.gap===null?"no earlier same-mass measurement":'gap '+p.gap+' from '+escape(p.parent))+
   '. '+escape(result.verification)+'</p>'+
   '<p><b>Selection:</b> '+(r.decision?escape(r.decision.source)+' · UI-recorded approval, rank '+r.decision.rank_at_approval:'LEGACY AUTOMATIC STEP · previously saved v1 research data')+'</p>'+
   (r.decision?.note?'<p><b>Researcher note:</b> '+escape(r.decision.note)+'</p>':'')+'</article>';
 }).join("");
}
function renderResidues(){
 $("residue-count").textContent=state.residues.length+" RESIDUES";
 if(!state.residues.length){$("residues").innerHTML='<p class="empty-note">No deviations recorded yet.</p>';return}
 $("residues").innerHTML=state.residues.slice().reverse().map(r=>'<article class="residue-entry">'+
  '<p class="residue-kind">'+escape(r.kind)+' · STEP '+r.source_step+'</p>'+
  '<strong>'+r.target.n+' positions, '+r.target.mass+' marks</strong>'+
  '<p>'+escape(r.observation)+'</p>'+
  '<p><b>Exact falsifier:</b> '+escape(r.falsifier)+'</p>'+
  '<p><b>Next question:</b> '+escape(r.next_question)+'</p>'+
  '<p><code>'+escape(r.status)+'</code></p></article>').join("");
}
function render(){
 const selected=renderCandidateControls(),audit=C.replay(state);
 $("step-label").textContent=state.records.length+" / "+C.MAX_STEPS;
 $("next-question").innerHTML=nextMarkup(selected)+(warning?'<p class="question-prose" role="alert" style="margin-top:14px;color:#ffe0b1">'+escape(warning)+'</p>':"");
 $("run-one").disabled=!selected;
 $("export").disabled=!state.records.length;
 $("audit-label").textContent=audit.status==="LOCALLY_REPLAYED"?"DETERMINISTIC LOCAL REPLAY PASS":"REPLAY REJECTED";
 renderCoverage();renderHistory();renderMetrics();renderResidues();
}
function step(){
 const previous=state;
 try{
  warning="";
  if(!selectedTarget)throw Error("No untested finite question remains.");
  const [n,mass]=selectedTarget.split(":").map(Number);
  state=C.advance(state,{action:"APPROVE_ONE",target:{n,mass},note:$("review-note").value});
  const audit=C.replay(state);
  if(audit.status!=="LOCALLY_REPLAYED")throw Error("Local replay failed: "+audit.issues.join("; "));
  selectedTarget="";$("review-note").value="";save();render();
 }catch(e){state=previous;warning="Experiment refused: "+e.message;render();}
}
$("run-one").addEventListener("click",step);
$("run-four").addEventListener("click",()=>{showAll=!showAll;render()});
$("reset").addEventListener("click",()=>{
 if(!confirm("Reset all locally saved discovery-loop steps and residues? Export first if you need them."))return;
 state=C.empty();selectedTarget="";showAll=false;$("review-note").value="";warning="Local pilot reset. No external records were changed.";save();render();
});
$("export").addEventListener("click",()=>{
 const audit=C.replay(state);
 if(audit.status!=="LOCALLY_REPLAYED"){warning="Export refused: local evidence replay failed.";render();return}
 const packet={format:C.SCHEMA,exported_from:"NIGHTFALL Living Investigation / local browser pilot",
  caution:"Untrusted browser export; exhaustive finite cyclic proxy only. Independently recompute every claim before attribution.",
  source_code:"https://github.com/d3lefts/d3lefts/blob/main/docs/discovery-loop-core.js",
  audit,state};
 const url=URL.createObjectURL(new Blob([JSON.stringify(packet,null,2)],{type:"application/json"}));
 const a=document.createElement("a");a.href=url;a.download="nightfall-living-investigation-v1.json";
 document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),1000);
});
render();
})();