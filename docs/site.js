"use strict";
const root="https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/";
const entries=[
 {"category":"mathematics","name":"Erdős minimum overlap","summary":"Original 131,072-cell rational witness, exact continuous-shift value and independent integer-convolution audit. A distinct finite construction; no global optimality claim.","status":"New explicit finite witness · exact audit","path":"projects/erdos-overlap-paper.md"},
 {"category":"mathematics","name":"30-point Sidon construction","summary":"An explicitly supplied 30-point integer (4,5) set with exact maximum Sidon subset size 17, verified by an exhaustive finite proof. Known 5/9 asymptotics remain prior art.","status":"Original finite witness · no asymptotic record claim","path":"projects/sidon-finite-30/README.md"},
 {"category":"systems","name":"Proof After Scarcity: adverse test","summary":"An original bounded 20-case verification-priority comparison: upstream-first 11/20 against risk-priority 8/20. Archived negative result; no general efficacy claim.","status":"Original limited empirical result · evidence-qualified","path":"projects/pas-overview.md"}
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
 const groups=[{kind:"research",title:"ORIGINAL RESEARCH FINDINGS",detail:"Distinct finite witnesses and a bounded original experiment; prior-art methods are attributed."}];
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

/* Guided entry / return route. Existing scientific instruments keep their own checkers. */
(() => {
 if(location.pathname.endsWith("/join.html")||document.querySelector(".nf-journey-rail"))return;
 const main=document.querySelector("main");if(!main)return;
 let title="";
 try{
   const state=JSON.parse(localStorage.getItem("nightfall.journey.v1")||"null");
   const names={"NF-156-184-9":"Maximal Sidon boundary","NF-Q7-R6":"Q7 graph boundary"};
   if(state&&state.version===1&&Object.prototype.hasOwnProperty.call(names,state.rootId))title=names[state.rootId];
 }catch(_){}
 // One shared stylesheet across otherwise independent research tools.
 if(!document.querySelector('link[data-nf-rail-style]')){
  const sheet=document.createElement("link");
  sheet.rel="stylesheet";sheet.href="journey-rail.css";
  sheet.dataset.nfRailStyle="";document.head.append(sheet);
 }
 const bar=document.createElement("nav");bar.className="nf-journey-rail";bar.setAttribute("aria-label","Guided research navigation");
 const tag=document.createElement("span");tag.textContent=title?"RESUME RESEARCH":"ONE GUIDED PATH";
 const primary=document.createElement("a");primary.href=title?"join.html#workspace":"join.html#results";
 primary.textContent=title?"Return to "+title+" ↗":"Results → process → open problem ↗";
 const gap=document.createElement("span");gap.className="nf-rail-spacer";
 const method=document.createElement("a");method.href="join.html#method";method.textContent="The process";
 const entry=document.createElement("a");entry.href="join.html#assignment";entry.textContent="Find a problem";
 const constellation=document.createElement("a");constellation.href="constellation.html";constellation.textContent="Constellation";\n bar.append(tag,primary,gap,constellation,method,entry);main.before(bar);
})();
