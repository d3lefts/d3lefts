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

/* A single return path for either canonical claim obligations or frozen Frontier tasks.
 * This pointer contains identifiers only. Source state stays in its own validated workspace. */
(() => {
 const CASE_KEY="nightfall.active.case.v1";
 const frontierNames={"NF-156-184-9":"Maximal Sidon decision","NF-Q7-R6":"Q7 exact graph search"};
 const claimNames={erdos36:"Erdős overlap",sidon30:"30-point Sidon",phase:"Finite-field phase retrieval",
  adaptive:"Adaptive finite-field decoder",werner:"Werner positivity",pas:"Proof After Scarcity"};
 function active(){
  try{
   const obj=JSON.parse(localStorage.getItem(CASE_KEY)||"null");
   if(obj&&obj.version===1&&obj.kind==="frontier"&&Object.hasOwn(frontierNames,obj.id))
    return {name:frontierNames[obj.id],href:"join.html?task="+encodeURIComponent(obj.id)+"#workspace",kind:"FRONTIER"};
   if(obj&&obj.version===1&&obj.kind==="claim"&&Object.hasOwn(claimNames,obj.id)&&
      Number.isSafeInteger(obj.index)&&obj.index>=0&&obj.index<30){
    const R=window.NightfallRegistry;
    if(R&&(!R.claimById(obj.id)||!Array.isArray(R.claimById(obj.id).open)||
       obj.index>=R.claimById(obj.id).open.length))return null;
    return {name:claimNames[obj.id],href:"join.html?claim="+encodeURIComponent(obj.id)+
       "&obligation="+obj.index+"#claim-investigation",kind:"REVIEW"};
   }
   // Legacy local journey gets a usable return path, without promoting evidence.
   const legacy=JSON.parse(localStorage.getItem("nightfall.journey.v1")||"null");
   if(legacy?.version===1&&Object.hasOwn(frontierNames,legacy.rootId))
    return {name:frontierNames[legacy.rootId],href:"join.html?task="+
     encodeURIComponent(legacy.rootId)+"#workspace",kind:"FRONTIER"};
  }catch{}
  return null;
 }
 function updateResume(){
  const data=active(),box=document.getElementById("join-resume");
  if(box){
   box.hidden=!data;
   if(data){
    document.getElementById("join-resume-title").textContent=data.name;
    document.getElementById("join-resume-detail").textContent=
     (data.kind==="REVIEW"?"Canonical claim / unresolved obligation":"Frozen exact research scope")+
     " · only identifiers are shared between instruments; local drafts remain unreviewed.";
    document.getElementById("join-resume-link").href=data.href;
   }
  }
  const tag=document.getElementById("nf-rail-state"),go=document.getElementById("nf-rail-resume");
  if(tag)tag.textContent=data?"RESUME RESEARCH / "+data.kind:"ONE GUIDED PATH";
  if(go){go.href=data?data.href:"join.html#results";
   go.textContent=data?"Return to "+data.name+" ↗":"Results → process → open problem ↗";}
 }
 window.addEventListener("nightfall:case-changed",updateResume);
 if(location.pathname.endsWith("/join.html")){updateResume();return}
 if(document.querySelector(".nf-journey-rail"))return;
 const main=document.querySelector("main");if(!main)return;
 if(!document.querySelector('link[data-nf-rail-style]')){
  const sheet=document.createElement("link");sheet.rel="stylesheet";sheet.href="journey-rail.css";
  sheet.dataset.nfRailStyle="";document.head.append(sheet);
 }
 const bar=document.createElement("nav");bar.className="nf-journey-rail";
 bar.setAttribute("aria-label","Guided research navigation");
 const tag=document.createElement("span");tag.id="nf-rail-state";
 const primary=document.createElement("a");primary.id="nf-rail-resume";
 const gap=document.createElement("span");gap.className="nf-rail-spacer";
 const constellation=document.createElement("a");constellation.href="constellation.html";constellation.textContent="Constellation";
 const method=document.createElement("a");method.href="join.html#method";method.textContent="The process";
 const entry=document.createElement("a");entry.href="join.html#assignment";entry.textContent="Find a problem";
 bar.append(tag,primary,gap,constellation,method,entry);main.before(bar);updateResume();
})();
