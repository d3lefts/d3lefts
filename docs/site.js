"use strict";
const root="https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/";
const entries=[
 {category:"mathematics",name:"Erdős minimum overlap",summary:"Exact rational upper-bound witness; 131,072 cells and all signed correlations. The platform's rejected oversized submission is recorded separately.",status:"Exact finite witness · review requested",path:"projects/erdos-overlap-paper.md"},
 {category:"quantum",name:"Werner-state undistillability",summary:"Full three-column 4–20 Werner registry, separate 21–24 refinements, and explicit 1–100 symbolic continuation.",status:"Exact conditional ledger · independent review open",path:"projects/werner-atlas/README.md"},
 {category:"mathematics",name:"Finite-field phase retrieval",summary:"Uniform fourth-power sensing and lattice decoding. The original manuscript awaits independent proof analysis.",status:"Manuscript proof · audit pending",path:"projects/finite-field-retrieval-handoff-excerpt.txt"},
 {category:"mathematics",name:"Affine source rigidity",summary:"September prime-zeta source-collision theorem and local shifted-series expansion; analytically distinct from global critical-line claims.",status:"Mathematical manuscript",path:"2026-09-affine-source-rigidity/README.md"},
 {category:"mathematics",name:"Involution shadow codes",summary:"Sharp finite-group translation-code distance and view-allocation formulas; direct independent small-group checker published.",status:"Exact finite checks · manuscript",path:"projects/involution-shadow-codes/README.md"},
 {category:"safety",name:"Agent safety under abstraction",summary:"Information sufficiency, enforcement collateral, provenance automata, history, and system composition.",status:"Theorem manuscript · review open",path:"projects/agent-safety-under-abstraction/README.md"},
 {category:"safety",name:"Counterfactual authorization gap",summary:"Capabilities induced by combining grants; reference-class escape and complexity of auditing.",status:"Original LaTeX published · review open",path:"2026-09-counterfactual-authorization/README.md"},
 {category:"super-intelligence",name:"Three ceilings on oversight",summary:"Information, computation, and trusted evidence as relative limits on oversight guarantees.",status:"Revised scope · review open",path:"2026-09-three-ceilings/README.md"},
 {category:"systems",name:"SourceBound",summary:"Restricted evidence-to-triple admission boundary with browser checks, synthetic fixtures, and adversarial mutation tests.",status:"Reproducible prototype · held-out study open",path:"projects/sourcebound/CLAIM_EVIDENCE_LEDGER.md"},
 {category:"systems",name:"Proof After Scarcity",summary:"Proof-dependency graphs, provenance-preserving verification policy, and negative stress tests.",status:"Public metadata freeze · graph prereg pending",path:"projects/pas-overview.md"},
 {category:"mathematics",name:"Sidon finite constructions",summary:"A thirty-point (4,5) configuration with maximum Sidon subset size 17, supported by finite exact checking.",status:"Finite certificate · scoped",path:"projects/sidon-finite-30/README.md"},
 {category:"mathematics",name:"SAT tensor-network encoding",summary:"Exact degree-three Boolean graph compiler; asymptotic complexity transfer depends on an external published theorem.",status:"Exact reduction · conditional runtime",path:"projects/sat-network-compression.md"},
 {category:"safety",name:"AI safety theorem-and-evidence series (Oct 28)",summary:"September oversight theorems, corrected claim registry, 27,740 finite checks, and a separate SourceBound evaluation protocol.",status:"Peer-review edition · external audit requested",path:"projects/ai-safety-peer-review-2026-10-28/README.md"},

 {kind:"proposal",code:"P01",category:"mathematics",name:"Finite-to-infinite positivity transfer",summary:"Seek a uniform bound on the off-diagonal Hankel tail that could carry finite positivity into a genuine all-rank theorem.",status:"Research proposal · untested",path:"projects/discovery-proposals-2026-10-28/README.md#p01-finite-to-infinite-positivity-transfer"},
 {kind:"proposal",code:"P02",category:"mathematics",name:"Active-contact minimax for minimum overlap",summary:"Explore new worst-shift contact patterns; require an exact signed-lag witness improving the archived bound by at least 10⁻⁸.",status:"Research proposal · untested",path:"projects/discovery-proposals-2026-10-28/README.md#p02-active-contact-minimax-for-minimum-overlap"},
 {kind:"proposal",code:"P03",category:"quantum",name:"Symmetry-reduced Werner certificates",summary:"Search representation-adapted rational dual witnesses at five, six, and eight copies, with every imported premise explicit.",status:"Research proposal · untested",path:"projects/discovery-proposals-2026-10-28/README.md#p03-symmetry-reduced-finite-copy-werner-certificates"},
 {kind:"proposal",code:"P04",category:"quantum",name:"Compositional Werner copy transfer",summary:"Derive a rigorously checked tensor recurrence that transfers finite-copy witnesses to larger copy counts with controlled slack.",status:"Research proposal · untested",path:"projects/discovery-proposals-2026-10-28/README.md#p04-compositional-transfer-across-werner-copy-counts"},
 {kind:"proposal",code:"P05",category:"super-intelligence",name:"Verification-capacity frontier",summary:"Determine information, compute, and evidence budgets needed to verify increasingly capable agent systems; formalize scoped lower bounds.",status:"Research proposal · untested",path:"projects/discovery-proposals-2026-10-28/README.md#p05-the-verification-capacity-frontier"},
 {kind:"proposal",code:"P06",category:"super-intelligence",name:"Self-improving discovery policies",summary:"Train a research-agent operator selector and test certified discovery gains on held-out problem families under equal compute.",status:"Research proposal · untested",path:"projects/discovery-proposals-2026-10-28/README.md#p06-self-improving-scientific-discovery-policies"},
 {kind:"proposal",code:"P07",category:"safety",name:"Composed-authority closure",summary:"Model privileges across tools and delegated agents; construct exact counterexamples and test history-aware policy guards.",status:"Research proposal · untested",path:"projects/discovery-proposals-2026-10-28/README.md#p07-composed-authority-closure-in-agent-toolchains"},
 {kind:"proposal",code:"P08",category:"safety",name:"SourceBound natural-web trial",summary:"Run a blinded held-out evaluation of unsupported published claims against factual recall and abstention on real web tasks.",status:"Research proposal · untested",path:"projects/discovery-proposals-2026-10-28/README.md#p08-sourcebound-natural-web-provenance-trial"},
 {kind:"proposal",code:"P09",category:"systems",name:"Proof-carrying research releases",summary:"Build a claim-to-witness release gate that detects changed bytes, dependencies, and status claims in clean-environment replay.",status:"Research proposal · untested",path:"projects/discovery-proposals-2026-10-28/README.md#p09-proof-carrying-research-releases"},
 {kind:"proposal",code:"P10",category:"systems",name:"Budget-aware experiment scheduling",summary:"Compare certificate-aware research scheduling with fixed round-robin baselines under equal budgets and leakage-safe evaluation.",status:"Research proposal · untested",path:"projects/discovery-proposals-2026-10-28/README.md#p10-budget-aware-experiment-scheduling"},
];
const list=document.getElementById("project-list");
const search=document.getElementById("project-search");
const filters=Array.from(document.querySelectorAll("[data-filter]"));
let filter="all", query="";
function render(){
 if(!list)return;
 const term=query.trim().toLocaleLowerCase();
 const matches=entries.filter(x=>(filter==="all"||x.category===filter)&&
   [x.name,x.summary,x.status,x.category].join(" ").toLocaleLowerCase().includes(term));
 const frag=document.createDocumentFragment();
 const groups=[
  {kind:"research",title:"RESEARCH ARCHIVE",detail:"Existing investigations with evidence-specific statuses."},
  {kind:"proposal",title:"NEW RESEARCH PROPOSALS",detail:"Two proposed experiments in each discipline · untested."}
 ];
 groups.forEach(group=>{
  const items=matches.filter(x=>(x.kind||"research")===group.kind);
  if(!items.length)return;
  const heading=document.createElement("div");
  heading.className="index-subhead";
  const title=document.createElement("strong");
  title.textContent=group.title;
  const detail=document.createElement("span");
  detail.textContent=group.detail;
  heading.append(title,detail);
  frag.appendChild(heading);
  items.forEach(entry=>{
   const a=document.createElement("a");
   a.className="research-row"+(entry.kind==="proposal"?" research-proposal":"");
   a.href=root+entry.path;
   a.target="_blank";
   a.rel="noopener";
   a.setAttribute("aria-label",(entry.kind==="proposal"?"Read research proposal: ":"Open source dossier: ")+entry.name);
   const cells=[
    ["span","number",entry.kind==="proposal"?entry.code:String(entries.indexOf(entry)+1).padStart(2,"0")],
    ["h3","research-title",entry.name],
    ["p","research-desc",entry.summary],
    ["span","research-status",entry.status],
    ["span","research-arrow","↗"]
   ];
   cells.forEach(([tag,cls,value])=>{const el=document.createElement(tag);el.className=cls;el.textContent=value;a.appendChild(el)});
   frag.appendChild(a);
  });
 });
 if(!matches.length){const p=document.createElement("p");p.className="empty";p.textContent="No entries match this search. Try a different topic.";frag.appendChild(p)}
 list.replaceChildren(frag);
}
filters.forEach((button)=>button.addEventListener("click",()=>{
 filter=button.dataset.filter;
 filters.forEach(x=>x.setAttribute("aria-pressed",String(x===button)));
 render();
}));
if(search)search.addEventListener("input",()=>{query=search.value;render()});
render();
const menu=document.getElementById("menu-button"),nav=document.getElementById("site-nav");
if(menu&&nav){
 menu.addEventListener("click",()=>{
  const open=nav.classList.toggle("open");
  menu.setAttribute("aria-expanded",String(open));
  menu.textContent=open?"CLOSE −":"MENU +";
 });
 const closeMenu=()=>{nav.classList.remove("open");menu.setAttribute("aria-expanded","false");menu.textContent="MENU +";};
 nav.querySelectorAll("a").forEach(a=>a.addEventListener("click",closeMenu));
 document.addEventListener("keydown",e=>{if(e.key==="Escape"&&nav.classList.contains("open")){closeMenu();menu.focus();}});
 document.addEventListener("click",e=>{if(nav.classList.contains("open")&&!nav.contains(e.target)&&!menu.contains(e.target))closeMenu();});
}
