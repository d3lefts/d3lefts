"use strict";
const root="https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/";
const entries=[
 {category:"ai-safety",name:"AI safety theorem-and-evidence series (Oct 28)",summary:"September oversight theorems, corrected claim registry, 27,740 finite checks, and a separate SourceBound evaluation protocol.",status:"Peer-review edition · external audit requested",path:"projects/ai-safety-peer-review-2026-10-28/README.md"},
 {category:"mathematics",name:"Erdős minimum overlap",summary:"Exact rational upper-bound witness; 131,072 cells and all signed correlations. The platform's rejected oversized submission is recorded separately.",status:"Exact finite witness · review requested",path:"projects/erdos-overlap-paper.md"},
 {category:"quantum",name:"Werner-state undistillability",summary:"Exact dual multipliers and separable spectators for six to nine qutrit copies. Dependent on imported lower-copy inequalities.",status:"Exact conditional constructions",path:"projects/werner-direct-margin/README.md"},
 {category:"mathematics",name:"Finite-field phase retrieval",summary:"Uniform fourth-power sensing and lattice decoding. The original manuscript awaits independent proof analysis.",status:"Manuscript proof · audit pending",path:"projects/finite-field-retrieval-handoff-excerpt.txt"},
 {category:"mathematics",name:"Affine source rigidity",summary:"September prime-zeta source-collision theorem and local shifted-series expansion; analytically distinct from global critical-line claims.",status:"Mathematical manuscript",path:"2026-09-affine-source-rigidity/README.md"},
 {category:"mathematics",name:"Involution shadow codes",summary:"Sharp finite-group translation-code distance and view-allocation formulas; direct independent small-group checker published.",status:"Exact finite checks · manuscript",path:"projects/involution-shadow-codes/README.md"},
 {category:"ai-safety",name:"Agent safety under abstraction",summary:"Information sufficiency, enforcement collateral, provenance automata, history, and system composition.",status:"Theorem manuscript · review open",path:"projects/agent-safety-under-abstraction/README.md"},
 {category:"ai-safety",name:"Counterfactual authorization gap",summary:"Capabilities induced by combining grants; reference-class escape and complexity of auditing.",status:"Original LaTeX published · review open",path:"2026-09-counterfactual-authorization/README.md"},
 {category:"ai-safety",name:"Three ceilings on oversight",summary:"Information, computation, and trusted evidence as relative limits on oversight guarantees.",status:"Revised scope · review open",path:"2026-09-three-ceilings/README.md"},
 {category:"systems",name:"SourceBound",summary:"Restricted evidence-to-triple admission boundary with browser checks, synthetic fixtures, and adversarial mutation tests.",status:"Reproducible prototype · held-out study open",path:"projects/sourcebound/CLAIM_EVIDENCE_LEDGER.md"},
 {category:"systems",name:"Proof After Scarcity",summary:"Proof-dependency graphs, provenance-preserving verification policy, and negative stress tests.",status:"Model & research prototype",path:"projects/pas-overview.md"},
 {category:"mathematics",name:"Sidon finite constructions",summary:"A thirty-point (4,5) configuration with maximum Sidon subset size 17, supported by finite exact checking.",status:"Finite certificate · scoped",path:"projects/sidon-finite-30/README.md"},
 {category:"mathematics",name:"SAT tensor-network encoding",summary:"Exact degree-three Boolean graph compiler; asymptotic complexity transfer depends on an external published theorem.",status:"Exact reduction · conditional runtime",path:"projects/sat-network-compression.md"},
 {category:"mathematics",name:"Xi spectral investigations",summary:"Fixed-rank reciprocal-semigroup results and isolated-zero certificates; global all-degree positivity remains an open proof gate.",status:"Partial regime · global question open",path:"projects/xi-dossier.md"},
 {category:"quantum",name:"Prime-frequency quantum geometry",summary:"Finite prime-state Fisher information calculations and a countermodel to symmetry-only zero confinement.",status:"Derived identities · spectral bridge open",path:"projects/quantum-prime-geometry/README.md"}
];
const list=document.getElementById("project-list");
const search=document.getElementById("project-search");
const filters=Array.from(document.querySelectorAll("[data-filter]"));
let filter="all", query="";
function render(){
 if(!list)return;
 const matches=entries.filter(x=>(filter==="all"||x.category===filter)&&
   [x.name,x.summary,x.status].join(" ").toLocaleLowerCase().includes(query.trim().toLocaleLowerCase()));
 const frag=document.createDocumentFragment();
 matches.forEach((entry)=>{
  const a=document.createElement("a");
  a.className="research-row";
  a.href=root+entry.path;
  a.target="_blank";
  a.rel="noopener";
  a.setAttribute("aria-label","Open source dossier: "+entry.name);
  const cells=[
   ["span","number",String(entries.indexOf(entry)+1).padStart(2,"0")],
   ["h3","research-title",entry.name],
   ["p","research-desc",entry.summary],
   ["span","research-status",entry.status],
   ["span","research-arrow","↗"]
  ];
  cells.forEach(([tag,cls,value])=>{const el=document.createElement(tag);el.className=cls;el.textContent=value;a.appendChild(el)});
  frag.appendChild(a);
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
 nav.querySelectorAll("a").forEach(a=>a.addEventListener("click",()=>{
  nav.classList.remove("open");menu.setAttribute("aria-expanded","false");menu.textContent="MENU +";
 }));
}
