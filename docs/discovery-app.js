"use strict";
(function(){
const C=window.DiscoveryCore,KEY="nightfall.discovery.v1",app=document.getElementById("app");
const E=x=>String(x??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
const id=()=>Date.now().toString(36)+"-"+Math.random().toString(36).slice(2,7);
const now=()=>new Date().toISOString();
function init(){return{version:C.VERSION,tab:"overview",active:"ea36",operator:"multistart",cfg:{n:19,mass:7,seed:42,steps:200},gcfg:{seed:1729,train:12,test:12},projects:C.PROJECTS.map(q=>Object.assign({},q,{contract:{objective:q.goal,assumptions:"Preserve exact hypotheses, feasible set and source scope.",prior:"Verify highest published same-scope benchmark and date.",gap:"Express best construction and best proved bound in same units.",threshold:q.id==="ea36"?"At least 1e-8 certified gain against baseline":"Strict gain beyond matched established baseline",audit:"Quantifiers, rounding, tolerance, edge cases, input hashes, and scoring artifacts.",checker:"Independent implementation and separate source-premise / analytic proof gates.",budget:"200 deterministic toy steps; exploration reserve 20%.",stop:"Three distinct operator families fail; budget exhausted; gap closed.",cheap:"Reproduce a small exact witness, then attack the largest assumption."},representations:[{id:"r0",parent:null,name:q.representation,mechanism:"Seeded from existing public dossier.",assumptions:"Review original source before transfer.",created:"2026-10-28",bits:null}],selectedRep:"r0",runs:[]}))}}
let state;try{state=JSON.parse(localStorage.getItem(KEY));if(!state||state.version!==C.VERSION||!Array.isArray(state.projects)||!state.projects.length)state=init()}catch{state=init()}
if(!state.gcfg)state.gcfg={seed:1729,train:12,test:12};
for(const project of init().projects)if(!state.projects.some(p=>p.id===project.id))state.projects.push(project);
// Earlier locally saved projects remain in browser storage. They are hidden from
// the public preset menu after the originality sweep, without deleting user work.
const allowedPublished=new Set(C.PROJECTS.map(x=>x.id));
const visibleProjects=()=>state.projects.filter(x=>allowedPublished.has(x.id)||x.id.startsWith("custom-"));
if(!allowedPublished.has(state.active)&&!state.active.startsWith("custom-"))state.active="ea36";
const q=()=>visibleProjects().find(x=>x.id===state.active)||visibleProjects()[0];
function save(){try{localStorage.setItem(KEY,JSON.stringify(state))}catch(e){alert("Local storage unavailable: "+e.message)}}
function toast(s,fail){const t=document.getElementById("toast");if(!t)return;t.textContent=s;t.className="toast show"+(fail?" bad":"");setTimeout(()=>t.className="toast",4500)}
const btn=(label,act,cls)=>'<button class="btn '+(cls||"ghost")+'" data-act="'+act+'">'+label+'</button>';
const tag=(s,cls)=>'<span class="tag '+(cls||"pending")+'">'+E(s)+'</span>';
const f=(key,title,value,long,hint)=>'<label class="field"><span>'+E(title)+'</span>'+(hint?'<small>'+E(hint)+'</small>':'')+(long?'<textarea rows="3" data-field="'+key+'">'+E(value)+'</textarea>':'<input data-field="'+key+'" value="'+E(value)+'">')+'</label>';
const tabs=[["overview","Overview","◈"],["contract","Problem contract","01"],["represent","Representations","02"],["operators","Operators","03"],["experiments","Experiment lab","04"],["evidence","Evidence ledger","05"],["package","Package & handoff","06"]];
function sidebar(){return '<aside class="side"><a class="brand" href="./"><span class="brand-mark">N∕F</span><span>NIGHTFALL<small>PHASESHIFT / DISCOVERY</small></span></a><div class="side-label">ENGINE / V1</div><nav aria-label="Discovery workflow">'+tabs.map(t=>'<button class="navitem '+(state.tab===t[0]?"selected":"")+'" data-tab="'+t[0]+'"><em>'+t[2]+'</em>'+t[1]+'</button>').join("")+'</nav><div class="side-label portfolio-label">RESEARCH ENVIRONMENTS <button title="New problem" data-act="new">+</button></div><div class="portfolios">'+visibleProjects().map(a=>'<button class="portfolio '+(a.id===q().id?"active":"")+'" data-project="'+E(a.id)+'"><span class="dot"></span><span>'+E(a.title)+'<small>'+E(a.area)+'</small></span></button>').join("")+'</div><div class="side-bottom"><span class="live-dot"></span> LOCAL WORKSPACE<small>Browser storage. Export for portability.</small></div></aside>'}
function topbar(){return '<header class="top"><div class="tiny">NIGHTFALL / DISCOVERY ENGINE <span class="crumb">/ '+state.tab.toUpperCase()+'</span></div><div class="actions"><span class="saved">● LOCAL SAVE</span>'+btn("Import","import")+btn("Export evidence ↗","export","primary")+'</div></header>'}
function context(){let x=q();return '<section class="context"><div><div class="eyebrow">'+E(x.area)+' <span>·</span> '+E(x.task)+'</div><h1>'+E(x.title)+'</h1><p class="sub">'+E(x.goal)+'</p><div class="meta"><span class="status">'+E(x.status)+'</span><a href="'+E(x.repo)+'" target="_blank" rel="noopener noreferrer">Source dossier ↗</a></div></div><aside class="context-figure"><span>ACTIVE WORKSPACE</span><strong>'+String(x.runs.length).padStart(2,"0")+'</strong><small>registered experiments</small><div class="tiny-line"></div><span>'+String(x.representations.length).padStart(2,"0")+' representations</span></aside></section>'}
function head(n,title,desc){return '<div class="sect-head"><span class="tiny muted">'+n+' / WORKSPACE</span><h2>'+title+'</h2><p>'+desc+'</p></div>'}
function metric(a,b,sub){return '<div class="metric"><span>'+a+'</span><strong>'+E(b)+'</strong><small>'+E(sub)+'</small></div>'}
function recent(){return q().runs.slice(-4).reverse().map(r=>'<div class="run-row"><div><b>'+E(r.id)+'</b><small>'+E(r.operator)+' · '+E(r.created.slice(0,16))+'</small></div><span class="right">'+(r.result?r.result.best_max+"/"+r.result.mass:"QUEUED")+'</span>'+tag(r.result?r.result.verifier:"EXTERNAL",r.result?"passed":"pending")+'</div>').join("")||'<div class="empty">No registered experiments. Freeze the next prediction first.</div>'}
function overview(){let z=q(),k=z.runs.filter(r=>r.result?.verifier==="PASS").length;return head("00","Research command","One problem. A traceable chain of representations, experiments, adversarial checks, and release gates.")+'<div class="metrics">'+metric("REPRESENTATIONS",z.representations.length,"Lineage preserved")+metric("EXPERIMENTS",z.runs.length,"Frozen preregistrations")+metric("FINITE REPLAYS",k,"Dual-path local arithmetic")+metric("PUBLICATION GATES",">= 2","Independent agents + prior art")+'</div><div class="twocol"><section class="panel"><div class="panel-head"><h3>Discovery cycle</h3><span class="tiny muted">01 → 06</span></div><div class="steps">'+[["Define","Scope, feasible set, significance."],["Represent","Transform coordinates and invariants."],["Select","Choose an operator by failure mode."],["Experiment","Preregister falsifiable prediction."],["Falsify","Verify and attack the candidate."],["Transfer","Package evidence and dependencies."]].map((a,i)=>'<button class="step" data-tab="'+tabs[i+1][0]+'"><b>'+String(i+1).padStart(2,"0")+'</b><span><strong>'+a[0]+'</strong><small>'+a[1]+'</small></span><span>↗</span></button>').join("")+'</div></section><section class="panel"><div class="panel-head"><h3>Recent experiments</h3><button class="subtle" data-tab="evidence">Full ledger ↗</button></div>'+recent()+'<div class="aside-note"><span>SCOPE SEPARATION</span><p>A local finite test can pass while analytic transfer, source premises, agent independence, novelty, and record eligibility remain open.</p></div></section></div><div class="feature-panel"><div><span class="tiny accent">NEXT DECISIVE EXPERIMENT</span><h3>'+E(z.contract.cheap)+'</h3><p>'+E(z.contract.threshold)+'</p></div><button class="btn primary" data-tab="experiments">Enter experiment lab ↗</button></div>'}
function contract(){let c=q().contract;return head("01","Problem contract","Record the objective and the tests that could overturn a candidate before the search begins.")+'<section class="panel pad"><div class="panel-head"><h3>Versioned research specification</h3>'+tag("EDITABLE DRAFT")+'</div><div class="form-grid">'+f("objective","Objective",c.objective,true,"Quantified target and optimization direction")+f("assumptions","Assumptions / feasible set",c.assumptions,true,"Exact scope and imported premises")+f("prior","Strongest dated prior art",c.prior,true,"Check same problem and conventions")+f("gap","Construction-to-bound gap",c.gap,true,"Define exact units and mathematical significance")+f("threshold","Significance threshold",c.threshold,false,"Within tolerance counts as a tie")+f("checker","Required certificate / checker",c.checker,true,"Independent verification path")+f("audit","Adversarial verifier audit",c.audit,true,"Arithmetic, thresholds, discretization, scoring exploits")+f("budget","Budget and exploration reserve",c.budget,false,"Compute/time cap")+f("stop","Stop / reopen criteria",c.stop,true,"Research direction switching")+f("cheap","Cheapest decisive experiment",c.cheap,true,"Falsifiable and informative")+'</div><div class="note">Each frozen experiment captures this contract as a full preregistration snapshot, with its own digest.</div></section>'}

function representations(){let x=q();return head("02","Representation studio","Branch, preserve lineage, track assumptions, and seed new searches from old finite candidates.")+'<div class="note"><strong>ADAPTIVE RESOLUTION</strong> · Chunk boundaries are candidate representations. Explore coarse patterns, promote failed exact-check spans to hard boundaries, and certify from the original source. The source-preserving hierarchy now feeds a worker-executable, matched-budget two-domain synthetic study. Training chooses a discrete policy from exact outcomes; a neural end-to-end router remains a research target. <a href="https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/discovery-engine/ARCHITECTURE.md" target="_blank" rel="noopener" style="text-decoration:underline">Read architecture ↗</a></div><div class="rep-grid">'+x.representations.map((r,i)=>'<button class="rep-card '+(x.selectedRep===r.id?"active":"")+'" data-rep="'+E(r.id)+'"><div class="rep-top"><span>R'+String(i).padStart(2,"0")+'</span><span>'+(x.selectedRep===r.id?"● ACTIVE":"○ SELECT")+'</span></div><h3>'+E(r.name)+'</h3><p>'+E(r.mechanism)+'</p><small>Parent '+E(r.parent||"ROOT")+' · '+E(r.created.slice(0,10))+'</small>'+(r.bits?tag("FROZEN FINITE SEED","passed"):"")+'</button>').join("")+'</div><section class="panel pad"><div class="panel-head"><h3>Derive a representation</h3><span class="tiny muted">PARENT '+E(x.selectedRep)+'</span></div><div class="form-grid"><label class="field"><span>Representation name</span><input id="repName" placeholder="New coordinates, quotient, or discretization"></label><label class="field"><span>Transformation / invariant</span><textarea id="repMech" rows="3" placeholder="What changes and what remains mathematically invariant?"></textarea></label><label class="field"><span>Failure mode / new premises</span><textarea id="repFail" rows="3" placeholder="Which assumptions require new proofs?"></textarea></label></div><div class="note">A representation change carries its parent forward. A finite seed remains explicitly scoped.</div>'+btn("Add to representation lineage ↗","rep-add","primary")+'</section>'}
function operators(){return head("03","Search operator registry","Select mechanism before search intensity. Each operator carries a failure model and a cost profile.")+'<div class="op-grid">'+C.FAMILIES.map((f,i)=>'<article class="op '+(state.operator===f.id?"chosen":"")+'"><div class="op-top"><span class="tiny">OP '+String(i+1).padStart(2,"0")+'</span>'+tag(state.operator===f.id?"ACTIVE":"AVAILABLE",state.operator===f.id?"passed":"")+'</div><h3>'+E(f.name)+'</h3><p>'+E(f.mechanism)+'</p><div class="op-fail"><b>FAILURE / LIMIT</b><span>'+E(f.failure)+'</span></div><button class="btn '+(state.operator===f.id?"primary":"ghost")+'" data-operator="'+E(f.id)+'">'+(state.operator===f.id?"Selected ✓":"Use this operator")+'</button></article>').join("")+'</div>'}
const studyMini=(k,min,max)=>'<label class="mini-field"><span>'+k.toUpperCase()+'</span><input type="number" data-studysetting="'+k+'" value="'+E(state.gcfg[k])+'" min="'+min+'" max="'+max+'"></label>';
const mini=(k,min,max)=>'<label class="mini-field"><span>'+k.toUpperCase()+'</span><input type="number" data-setting="'+k+'" value="'+E(state.cfg[k])+'" min="'+min+'" max="'+max+'"></label>';
function experiments(){let x=q(),r=x.representations.find(y=>y.id===x.selectedRep),op=C.FAMILIES.find(y=>y.id===state.operator),toy=x.mode==="toy";return head("04","Experiment lab","Preregister a prediction and a falsification test, then execute the finite local lab or export a scientific run manifest.")+'<div class="twocol wide-left"><section class="panel pad"><div class="panel-head"><h3>Freeze an experiment</h3>'+tag("PREREGISTRATION")+'</div><div class="form-grid"><label class="field"><span>Prediction</span><small>Quantitative expectation whenever possible</small><textarea id="prediction" rows="3" placeholder="Predicted score, gap, or structural transition"></textarea></label><label class="field"><span>Falsifying / distinguishing outcomes</span><small>What explanations would each outcome eliminate?</small><textarea id="discriminator" rows="3" placeholder="Predicted alternative outcomes and decisive failures"></textarea></label><label class="field"><span>Cost and stop</span><input id="cost" value="Bounded finite local run; source audit separate"></label></div><div class="config"><div><span class="tiny muted">SELECTED OPERATOR</span><strong>'+E(op.name)+'</strong><small>'+E(op.failure)+'</small></div><button class="subtle" data-tab="operators">Change ↗</button></div><div class="config"><div><span class="tiny muted">ACTIVE REPRESENTATION</span><strong>'+E(r.name)+'</strong><small>'+E(r.id)+(r.bits?" · finite candidate seed":" · no saved finite seed")+'</small></div><button class="subtle" data-tab="represent">Change ↗</button></div>'+(toy?'<div class="toy-settings"><div class="tiny muted">LOCAL INTEGER CYCLIC-OVERLAP PROXY</div><div class="settings">'+mini("n",5,48)+mini("mass",2,47)+mini("seed",0,4294967295)+mini("steps",1,2000)+'</div><div class="note caution">Proxy only: this discrete cyclic objective differs from EA #36 continuous signed-shift overlap. Local success cannot advance its record.</div></div>':(x.id==="granularity"?'<div class="toy-settings"><div class="tiny muted">HELD-OUT GRANULARITY STUDY / TWO SYNTHETIC DOMAINS</div><div class="settings">'+studyMini("seed",0,4294967295)+studyMini("train",3,32)+studyMini("test",3,32)+'</div><div class="note caution">Training selects discrete boundary-policy parameters using exact training outcomes. The held-out suite compares fixed, adaptive, atomic and trained policies at identical exact replay budgets. Execute the exported manifest with the scientific worker.</div></div>':'<div class="note caution">This project is configured for an external scientific runner. The interface records an immutable-in-ledger plan and packages it for independent execution; no compute backend is connected to this page.</div>'))+btn(toy?"Freeze and execute finite experiment ↗":"Freeze external-run manifest ↗","run","primary wide")+'</section><section class="panel"><div class="panel-head"><h3>Recent experiments</h3><span class="tiny muted">PROJECT SCOPE</span></div>'+recent()+'<div class="aside-note"><span>A / CONSTRUCTOR</span><p>Representation and search operator generate a candidate. Deterministic integer toy runs have exact reproducible seeds.</p></div><div class="aside-note"><span>B / ADVERSARIAL CHECK</span><p>Direct shift-by-shift arithmetic independently recomputes the toy score. A deliberately corrupted claim must fail. External agent independence is a further gate.</p></div></section></div>'}
function chart(r){let trace=r?.trace||[],max=Math.max(1,...trace.map(x=>x.max)),steps=Math.max(1,r.steps_budget),points=trace.map(t=>(14+590*t.step/steps)+","+(110-75*t.max/max)).join(" ");return '<div class="chart"><svg viewBox="0 0 620 126" role="img" aria-label="Best integer toy score by accepted step"><path d="M14 110H604" stroke="#829e87"/><polyline points="'+points+'" fill="none" stroke="#d9ff71" stroke-width="3"/><text x="14" y="16" fill="#b8cbb7" font-size="11">BEST MAX CORRELATION ↓</text></svg></div>'}
function evidence(){
 let rows=q().runs.slice().reverse();
 return head("05","Evidence ledger","Exact checks and independent reviews retain separate status. Referee handoffs replay their original finite inputs; they do not certify a general theorem.")+
 (rows.length?rows.map(r=>{
  const handed=!!r.handoff, measured=!!r.result;
  const label=measured?r.result.claim_label:handed?"LOCAL FINITE REPLAY · REVIEW OPEN":"EXTERNAL RUN PENDING";
  const hashlabel=handed?"SOURCE INPUT SHA-256":"FROZEN PREREGISTRATION SHA-256";
  const hash=handed?r.handoff.sourceSha256:r.prereg_hash||"hash unavailable";
  const outcome=measured?"Integer max "+r.result.best_max+" · lower "+r.result.lower_bound+" · gap "+r.result.gap:
   handed?"Finite "+r.handoff.domain+" · "+r.handoff.localReplayStatus+"; source inputs and attacks matched":"External scientific execution outstanding";
  const scope=measured?r.result.scope_warning:handed?
   r.handoff.scope+" Same-code browser replay; independent external review is still required.":
   "Unexecuted manifest; no mathematical result claimed";
  let actions;
  if(measured){
   actions=chart(r)+'<div class="audit-flags"><span>DIRECT REPLAY '+E(r.result.verifier)+'</span><span>CORRUPTED CLAIM '+E(r.result.negative_control)+'</span><span>EXTERNAL AGENT PENDING</span></div><button class="btn ghost" data-replay="'+E(r.id)+'">Re-run exact verification B</button><button class="btn ghost" data-fork="'+E(r.id)+'">Fork candidate as representation</button>';
  }else if(handed){
   const dest=r.handoff.domain==="weak-sidon-4-5-finite"?"sidon30":"erdos36";
   actions='<div class="audit-flags"><span>INPUT HASH MATCH</span><span>FINITE SOURCE + ATTACK REPLAY</span><span>INDEPENDENT REVIEW OPEN</span></div><a class="btn ghost" href="passport.html?claim='+dest+'">Inspect corresponding Proof Passport ↗</a><button class="btn ghost" data-tab="package">Package source and evidence ↗</button>';
  }else actions='<button class="btn ghost" data-tab="package">Package run manifest ↗</button>';
  return '<article class="panel evidence"><div class="ev-head"><div><span class="tiny muted">'+E(r.created)+'</span><h3>'+E(r.id)+'</h3><small>'+E(r.operator)+' / '+E(r.repId)+'</small></div>'+tag(label,measured?"passed":"pending")+'</div><div class="ev-facts"><div><span>'+hashlabel+'</span><code>'+E(hash)+'</code></div><div><span>PREDICTION</span><p>'+E(r.prediction)+'</p></div><div><span>CHECKED OUTCOME</span><p>'+E(outcome)+'</p></div><div><span>RESEARCH SCOPE</span><p>'+E(scope)+'</p></div></div>'+actions+'</article>';
 }).join(""):'<div class="panel empty">No experiments recorded. Register one in the experiment lab.</div>');
}
function packageView(){let x=q(),last=x.runs[x.runs.length-1];return head("06","Package & handoff","Export a portable research bundle with intact contract, representations, operator registry, experiments, checks, and scope boundaries.")+'<div class="twocol"><section class="panel pad"><div class="panel-head"><h3>Research package</h3>'+tag("LOCAL EXPORT")+'</div><div class="package-files">'+["README.md","problem.json","representations.json","operator-registry.json","experiments.json","verification.json","HANDOFF.md","manifest.json"].map((s,i)=>'<div><span>0'+(i+1)+'</span><b>'+s+'</b><small>✓ included</small></div>').join("")+'</div><div class="notice">ZIP includes per-file SHA-256 digests. A locally created package is distinct from a publicly frozen release.</div>'+btn("Build ZIP research package ↗","export","primary wide")+btn("Export complete workspace JSON","json","ghost wide")+'</section><section class="panel pad"><div class="panel-head"><h3>Independent agent handoff</h3><span class="tiny muted">REPRODUCER / AUDITOR</span></div><p class="bodycopy">Freeze the claim and inputs. A separate reproducer constructs fresh verification code without access to A’s intermediate arrays. An adversarial auditor probes gaps. A formalizer identifies every remaining proof dependency.</p><p class="bodycopy" style="margin-top:16px">External worker: <code>python3 research/nightfall/discovery-engine/runner.py PACKAGE.zip --out receipt.json</code></p><div class="handoff"><b>LATEST EXPERIMENT</b><span>'+E(last?.id||"None")+'</span><b>EVIDENCE STATUS</b><span>'+E(last?.result?.claim_label||"Unverified / external run pending")+'</span><b>NEXT DECISIVE STEP</b><span>'+E(x.contract.cheap)+'</span><b>OPEN GATES</b><span>Independent external replay · imported hypotheses · dated prior art · release signoff</span></div>'+btn("Download readable research handoff","md","ghost wide")+'</section></div>'}
function render(){const views={overview,contract,represent:representations,operators,experiments,evidence,package:packageView};app.innerHTML=sidebar()+'<div id="workspace-content" class="main">'+topbar()+'<div class="main-inner">'+context()+views[state.tab]()+'<footer class="footer">NIGHTFALL PHASESHIFT / DISCOVERY ENGINE <span>PROVENANCE OVER RANKINGS · V1</span></footer></div></div><input type="file" accept=".json,application/json" id="file-import" hidden><div id="toast" class="toast" aria-live="polite" role="status"></div>'}

async function digest(s){if(!globalThis.crypto?.subtle)return"UNAVAILABLE";const a=await crypto.subtle.digest("SHA-256",new TextEncoder().encode(s));return Array.from(new Uint8Array(a)).map(x=>x.toString(16).padStart(2,"0")).join("")}
function plan(){return{schema:C.VERSION,project:q().id,contract:JSON.parse(JSON.stringify(q().contract)),representation:q().selectedRep,operator:state.operator,prediction:document.getElementById("prediction")?.value.trim()||"No numeric prediction specified",discriminator:document.getElementById("discriminator")?.value.trim()||"No discriminating outcome specified",cost:document.getElementById("cost")?.value.trim()||"",config:q().id==="granularity"?{granularity:{...state.gcfg}}:{...state.cfg},created:now()}}
async function run(){const x=q(),pr=plan(),r={id:"exp-"+id(),created:pr.created,operator:pr.operator,repId:pr.representation,prediction:pr.prediction,discriminator:pr.discriminator,cost:pr.cost,plan:pr,prereg_hash:await digest(JSON.stringify(pr)),result:null};x.runs.push(r);save();if(x.mode==="toy"){try{let cfg={...state.cfg,operator:state.operator},rep=x.representations.find(y=>y.id===x.selectedRep);if(rep?.bits?.length===Number(cfg.n)&&rep.bits.reduce((s,z)=>s+z,0)===Number(cfg.mass))cfg.start=rep.bits;r.result=C.runToy(cfg)}catch(e){r.failure=String(e.message||e)}}save();state.tab="evidence";render();toast(r.failure?"Experiment rejected: "+r.failure:r.result?"Finite exact experiment recorded; inspect its scope.":"External experiment preregistered for handoff.",!!r.failure)}
function fork(key){let x=q(),r=x.runs.find(z=>z.id===key);if(!r?.result)return;let rep={id:"r-"+id(),parent:r.repId,name:"Candidate seed · "+r.id,mechanism:"Best finite toy witness from "+r.operator,assumptions:"Finite cyclic objective only; no continuous transfer",created:now(),bits:r.result.best_bits.slice()};x.representations.push(rep);x.selectedRep=rep.id;state.cfg.n=r.result.n;state.cfg.mass=r.result.mass;state.tab="represent";save();render();toast("Candidate forked with provenance.")}
function replay(key){let r=q().runs.find(z=>z.id===key);if(!r?.result)return;const x=r.result,v=C.verify(x.best_bits,{n:x.n,mass:x.mass,max:x.best_max,hist:x.best_hist}),mutation=C.verify(x.best_bits,{n:x.n,mass:x.mass,max:x.best_max+1,hist:x.best_hist});toast(v.pass&&!mutation.pass?"PASS · exact direct-shift recomputation and mutation rejection.":"FAIL · finite archived claim contradicts direct arithmetic.",!v.pass||mutation.pass)}
function download(content,name,type){let b=content instanceof Blob?content:new Blob([content],{type:type||"text/plain"}),url=URL.createObjectURL(b),a=document.createElement("a");a.href=url;a.download=name;a.click();setTimeout(()=>URL.revokeObjectURL(url),4000)}
const json=x=>JSON.stringify(x,null,2)+"\n";
function handoff(x){let lines=["# NIGHTFALL Discovery Engine handoff","","Research problem: "+x.title,"Original dossier: "+x.repo,"Reported status: "+x.status,"","## Frozen problem contract"];for(const[k,v]of Object.entries(x.contract))lines.push(k+": "+v);lines.push("","## Experimental lineage");for(const r of x.runs)lines.push("- "+r.id+" · "+r.operator+" · "+r.created+" · prereg SHA256 "+r.prereg_hash+" · "+(r.result?"finite proxy max "+r.result.best_max+" / lower "+r.result.lower_bound:"external execution required"));lines.push("","## Verification gate","Reproducer: independently reconstruct inputs, code and exact arithmetic.","Adversarial auditor: attack assumptions, scoring, rounding and claim scope.","Formalizer: mark missing lemmas and unproved imported premises.","Dated prior-art comparison and record eligibility require separate verification.","","## Next decisive step",x.contract.cheap,"");return lines.join("\n")}
function crc32(a){let c=0xffffffff;for(let b of a){c^=b;for(let j=0;j<8;j++)c=(c>>>1)^((c&1)?0xedb88320:0)}return(c^0xffffffff)>>>0}
function mkzip(files){let enc=new TextEncoder(),chunks=[],central=[],offset=0;function add(a){chunks.push(a);offset+=a.length}for(let[name,s]of files){let nm=enc.encode(name),bytes=enc.encode(s),size=bytes.length,crc=crc32(bytes),at=offset;let h=new Uint8Array(30+nm.length),v=new DataView(h.buffer);v.setUint32(0,0x04034b50,true);v.setUint16(4,20,true);v.setUint32(14,crc,true);v.setUint32(18,size,true);v.setUint32(22,size,true);v.setUint16(26,nm.length,true);h.set(nm,30);add(h);add(bytes);let d=new Uint8Array(46+nm.length),w=new DataView(d.buffer);w.setUint32(0,0x02014b50,true);w.setUint16(4,20,true);w.setUint16(6,20,true);w.setUint32(16,crc,true);w.setUint32(20,size,true);w.setUint32(24,size,true);w.setUint16(28,nm.length,true);w.setUint32(42,at,true);d.set(nm,46);central.push(d)}let start=offset;central.forEach(add);let end=new Uint8Array(22),v=new DataView(end.buffer);v.setUint32(0,0x06054b50,true);v.setUint16(8,files.length,true);v.setUint16(10,files.length,true);v.setUint32(12,offset-start,true);v.setUint32(16,start,true);add(end);return new Blob(chunks,{type:"application/zip"})}
async function exportZip(){let x=q(),files=[["README.md","# NIGHTFALL Discovery Engine / portable evidence\n\nResearch: "+x.title+"\nStatus: "+x.status+"\nCreated: "+now()+"\n\nLocal verification is restricted to a finite cyclic toy; independent scientific gates remain open.\n"],["problem.json",json({id:x.id,title:x.title,status:x.status,source:x.source,contract:x.contract})],["representations.json",json(x.representations)],["operator-registry.json",json(C.FAMILIES)],["experiments.json",json(x.runs.map(r=>{let{result,...other}=r;return other}))],["verification.json",json(x.runs.map(r=>({id:r.id,prereg_hash:r.prereg_hash,verification:r.result||null,failure:r.failure||null})))],["HANDOFF.md",handoff(x)]];let hashes={};for(let[name,content]of files)hashes[name]=await digest(content);files.push(["manifest.json",json({schema:C.VERSION,created:now(),hash_algorithm:"SHA-256",files:hashes,external_agent_status:"PENDING",public_release:"NO"})]);download(mkzip(files),"NIGHTFALL_Discovery_"+x.id+"_"+now().slice(0,10)+".zip");toast("Portable ZIP with "+files.length+" files and hashes exported.")}
app.addEventListener("click",async ev=>{let b=ev.target.closest("button");if(!b)return;if(b.dataset.tab){state.tab=b.dataset.tab;save();render();return}if(b.dataset.project){state.active=b.dataset.project;state.tab="overview";save();render();return}if(b.dataset.rep){q().selectedRep=b.dataset.rep;save();render();return}if(b.dataset.operator){state.operator=b.dataset.operator;save();render();return}if(b.dataset.replay){replay(b.dataset.replay);return}if(b.dataset.fork){fork(b.dataset.fork);return}switch(b.dataset.act){
case"run":await run();break;
case"rep-add":{let name=document.getElementById("repName").value.trim(),mechanism=document.getElementById("repMech").value.trim(),assumptions=document.getElementById("repFail").value.trim();if(!name||!mechanism){toast("Name and transformation required.",true);break}q().representations.push({id:"r-"+id(),parent:q().selectedRep,name,mechanism,assumptions,created:now(),bits:null});q().selectedRep=q().representations[q().representations.length-1].id;save();render();break}
case"new":{let title=prompt("New research problem title");if(!title?.trim())break;let x=JSON.parse(JSON.stringify(q()));x.id="custom-"+id();x.title=title.trim().slice(0,120);x.status="Unverified new research specification";x.goal="Define target and significance.";x.mode="external";x.repo="https://github.com/d3lefts/d3lefts";x.task="UNASSIGNED";x.source="";x.runs=[];x.representations=[{id:"r0",parent:null,name:"Initial representation",mechanism:"Define starting feasible model.",created:now(),bits:null}];x.selectedRep="r0";x.contract.objective="Specify exact objective";state.projects.push(x);state.active=x.id;state.tab="contract";save();render();break}
case"export":await exportZip();break;
case"json":download(json(state),"NIGHTFALL_Discovery_Workspace.json","application/json");break;
case"md":download(handoff(q()),"NIGHTFALL_Handoff_"+q().id+".md","text/markdown");break;
case"import":document.getElementById("file-import").click();break;
}});
app.addEventListener("change",ev=>{let el=ev.target;if(el.dataset.field){q().contract[el.dataset.field]=el.value;save()}if(el.dataset.setting){state.cfg[el.dataset.setting]=Number(el.value);save()}if(el.dataset.studysetting){state.gcfg[el.dataset.studysetting]=Number(el.value);save()}if(el.id==="file-import"){let file=el.files?.[0];if(!file)return;if(file.size>5000000){toast("JSON import limit is 5 MB.",true);return}file.text().then(s=>{let v=JSON.parse(s);if(v.version!==C.VERSION||!Array.isArray(v.projects)||!v.projects.every(a=>a.id&&a.contract&&Array.isArray(a.representations)&&Array.isArray(a.runs)))throw Error("Incompatible schema");if(!confirm("Replace all local research workspace data?"))return;for(let x of v.projects)if(!/^https:\/\/github\.com\/d3lefts\/d3lefts(?:\/|$)/.test(x.repo||""))x.repo="https://github.com/d3lefts/d3lefts";state=v;save();render();toast("Imported workspace. Review claims and provenance.")}).catch(err=>toast("Import failed: "+err.message,true))}});

// One-shot, explicit user-approved input transfer: Claim Lab to Discovery.
// Re-hash the source and rerun both arithmetic and negative controls locally.
// Same-code browser arithmetic is NEVER an independent external proof review.
async function importRefereeHandoff(){
 if(new URLSearchParams(location.search).get("referee_handoff")!=="1")return;
 try{
  const raw=sessionStorage.getItem("nightfall.discovery.pending.v1");
  sessionStorage.removeItem("nightfall.discovery.pending.v1");
  history.replaceState(null,"",location.pathname);
  if(!raw||raw.length>2000000)throw Error("Missing or oversized handoff receipt");
  const r=JSON.parse(raw),V=window.RefereeCore;
  if(!V||r.format!=="nightfall-referee-receipt-v1"||r.version!==V.VERSION)
   throw Error("Unrecognized verifier or receipt version");
  if(!r.source||!r.result||!r.negativeControls)throw Error("Incomplete receipt");
  if(!["weak-sidon-4-5-finite","continuous-step-overlap"].includes(r.domain))
   throw Error("Unsupported finite domain");
  if(!/^[a-f0-9]{64}$/.test(r.inputSha256||""))throw Error("Missing source fingerprint");
  const canonical=r.domain==="weak-sidon-4-5-finite"
   ?{domain:r.domain,input:r.source,claimedMaximum:r.claimedMaximum}
   :{domain:r.domain,input:r.source,claimedScore:r.claimedScore??null};
  const actual=await digest(JSON.stringify(canonical));
  if(actual!==r.inputSha256)throw Error("Source fingerprint mismatch");
  const local=r.domain==="weak-sidon-4-5-finite"
   ?V.checkSidon(r.source,r.claimedMaximum):V.checkOverlap(r.source,r.claimedScore);
  const attacks=r.domain==="weak-sidon-4-5-finite"
   ?V.sidonAttacks(r.source,r.claimedMaximum):V.overlapAttacks(r.source,local);
  if(JSON.stringify(local)!==JSON.stringify(r.result)||
     JSON.stringify(attacks)!==JSON.stringify(r.negativeControls))
   throw Error("Finite result or adversarial controls differ from the imported receipt");
  const ok=r.domain==="weak-sidon-4-5-finite"
   ?local.status==="FINITE_CHECK_PASSED"&&attacks.understatedMaximumRejected&&attacks.corruptedSubsetRejected
   :local.status==="FINITE_CHECK_PASSED"&&local.dualPathAgreement&&attacks.scoreTamperRejected&&attacks.massPreservingWitnessMutation?.rejected===true;
  const expected=ok?"FINITE_CHECK_PASSED":r.domain==="weak-sidon-4-5-finite"
   ?"REJECTED_OR_INCONCLUSIVE":local.status==="REJECT"?"REJECTED":"INCONCLUSIVE";
  if(r.verdict!==expected)throw Error("Reported verdict contradicts replay");
  if(!confirm("Source SHA-256, finite arithmetic, and negative controls agree on local replay. Record this as a scoped Discovery experiment? Independent external proof review remains OPEN."))return;
  const projectId=r.domain==="weak-sidon-4-5-finite"?"sidon":"ea36";
  const project=state.projects.find(x=>x.id===projectId);
  if(!project)throw Error("Research project unavailable");
  if(project.runs.some(x=>x.handoff?.sourceSha256===actual))
   throw Error("This exact source fingerprint is already recorded");
  project.runs.push({
   id:"exp-referee-"+id(),created:now(),operator:"referee-finite-replay",
   repId:project.selectedRep,prediction:"Previously reported "+r.verdict+" for the supplied finite input",
   discriminator:"Mismatch in source hash, exact arithmetic, or adversarial controls",
   cost:"Local replay; total compute budget unmeasured",
   plan:{schema:C.VERSION,project:projectId,source:"Explicit Referee/Claim Lab handoff",
         source_input_sha256:actual,scope:"Historical input; no prospective preregistration"},
   prereg_hash:null,result:null,
   handoff:{domain:r.domain,sourceSha256:actual,receiptVerdict:r.verdict,
    localReplayStatus:local.status,scope:local.scope,source:r.source,
    claimedValue:r.domain==="weak-sidon-4-5-finite"?r.claimedMaximum:r.claimedScore,
    exactResult:local,negativeControls:attacks,sourceDossier:r.sourceDossier||null,
    independentExternalReplay:false,priorPreregistration:false}
  });
  state.active=projectId;state.tab="evidence";save();render();
  toast("Finite source replayed and recorded. External proof review remains open.");
 }catch(err){toast("Referee handoff rejected: "+err.message,true)}
}

/* A Frontier assignment is a question to investigate, never an imported result.
   Reconstruct exact branch identity from the public frozen core before consent. */
function importFrontierHandoff(){
 if(new URLSearchParams(location.search).get("frontier_handoff")!=="1")return;
 try{
  const raw=sessionStorage.getItem("nightfall.frontier.discovery.v1");
  sessionStorage.removeItem("nightfall.frontier.discovery.v1");
  if(!raw||raw.length>7000)throw Error("Missing or oversized scoped Frontier packet");
  const packet=JSON.parse(raw);
  const adapter=window.NightfallFrontierDiscovery,frontier=window.NFFrontier;
  if(!adapter||!frontier)throw Error("Frozen source-contract verifier unavailable");
  const project=adapter.build(packet,frontier);
  adapter.checkUnique(state.projects,project);
  if(state.projects.length>=64)throw Error("Local research workspace limit reached");
  if(!confirm("Investigate "+packet.assignmentId+" as a new UNVERIFIED Discovery project? The exact interval and source conditions are preserved. No experiment runs or result is certified.")){
   toast("Frontier handoff declined; existing research data preserved.");
   return;
  }
  const backup=localStorage.getItem(KEY);
  const next=structuredClone(state);
  next.projects.push(project);
  next.active=project.id;
  next.tab="contract";
  const serialized=JSON.stringify(next);
  try{
   localStorage.setItem(KEY,serialized);
   if(localStorage.getItem(KEY)!==serialized)throw Error("Storage readback mismatch");
  }catch(e){
   try{if(backup===null)localStorage.removeItem(KEY);else localStorage.setItem(KEY,backup)}catch(_){}
   throw Error("Local research storage failed: "+e.message);
  }
  state=next;
  render();
  toast("Exact Frontier scope imported as an unverified external research project. No experiments inherited.");
 }catch(err){toast("Frontier handoff refused: "+err.message,true)}
 finally{history.replaceState(null,"",location.pathname)}
}

render();
importRefereeHandoff();
importFrontierHandoff();
})();