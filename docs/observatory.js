"use strict";
(() => {
  const ns="http://www.w3.org/2000/svg";
  const q=s=>document.querySelector(s);
  const graph=q("#obs-graph"),inspector=q("#obs-inspector"),cards=q("#obs-items");
  const heading=q("#obs-listing-title"),description=q("#obs-listing-desc");
  const search=q("#obs-search"),discipline=q("#obs-discipline");
  const modeButtons=[...document.querySelectorAll("[data-obs-mode]")];
  const status=q("#obs-load-status");
  if(!graph||!inspector||!cards)return;
  const layout={
    "NF-ERDOS-131072-v1":[125,135,"OVERLAP"],"NF-SIDON30-v1":[155,310,"SIDON 30"],
    "NF-SIDON-CHECK-v1":[300,385,"EXACT CHECK"],"NF-PAS20-v1":[560,405,"PAS 20"],
    "NF-PAS-DOMINANCE-v1":[465,510,"FAILED TEST"],"NF-FIELD-SPAN-v1":[475,85,"FIELD TAIL"],
    "NF-AXIOM-KERNEL-v1":[645,75,"AXIOM"],"NF-WERNER25-v1":[865,165,"WERNER 25"],
    "NF-WERNER6-v1":[785,350,"WERNER 6"],"NF-WEIGHTED-SCHUR-v1":[445,245,"SCHUR"],
    "NF-BLOCK-EXAMPLE-v1":[330,315,"3-BLOCK"],"NF-SPECTRAL-BRIDGE-v1":[320,42,"SPECTRAL"],
    "NF-LEMNIS-EXT-v1":[937,450,"LEMNIS"],"NF-GRAPH-EVAL-v1":[925,60,"GRAPH TEST"]
  };
  const labels={
    scope:["Scope Boundary","The exact claim, the limit of its scope and the missing extension condition."],
    evidence:["Evidence Trace","Pinned source records, internal proof dependencies and reproducibility instructions."],
    transfer:["Transfer Explorer","Five distinct relationship classes. Proposed links stay proposed until certified."],
    failure:["Failure History","Negative results and defeated hypotheses are retained, never silently deleted."],
    frontier:["Research Frontier","Open dependencies ranked by research priority, not asserted scientific impact."]
  };
  const priority=["NF-SPECTRAL-BRIDGE-v1","NF-LEMNIS-EXT-v1","NF-AXIOM-KERNEL-v1","NF-GRAPH-EVAL-v1"];
  let data=null,chosen="NF-WEIGHTED-SCHUR-v1",chosenEdge=null,mode="scope";
  const element=(name,cls,txt)=>{const e=document.createElement(name);if(cls)e.className=cls;if(txt!==undefined)e.textContent=txt;return e;};
  const svg=(name,attrs)=>{const e=document.createElementNS(ns,name);for(const [k,v] of Object.entries(attrs||{}))e.setAttribute(k,String(v));return e;};
  const textRow=(label,value)=>{const dl=element("dl","obs-field");dl.append(element("dt","",label),element("dd","",value));return dl;};
  const itemList=(values,asCode=false)=>{const ul=element("ul");for(const val of values){const li=element("li");li.append(element(asCode?"code":"span","",val));ul.append(li)}return ul;};
  const node=id=>data.nodes.find(x=>x.id===id);
  const relation=id=>data.edges.filter(e=>e.from===id||e.to===id);
  const allowed=n=>(discipline.value==="all"||n.discipline===discipline.value)&&n.title.toLowerCase().includes(search.value.trim().toLowerCase());
  const selectNode=(id)=>{chosen=id;chosenEdge=null;drawGraph();renderInspector();renderCards();};
  const selectEdge=(id)=>{chosenEdge=id;mode="transfer";updateMode();drawGraph();renderInspector();renderCards();};
  function drawGraph(){
    graph.replaceChildren();
    const visible=new Set(data.nodes.filter(allowed).map(x=>x.id));
    for(const e of data.edges){
      const a=layout[e.from],b=layout[e.to];if(!a||!b)continue;
      const group=svg("g",{class:"obs-line-group",tabindex:"0",role:"button","aria-label":e.type+": "+node(e.from).title+" to "+node(e.to).title});
      const on=()=>selectEdge(e.id);
      group.addEventListener("click",on);group.addEventListener("keydown",ev=>{if(ev.key==="Enter"||ev.key===" "){ev.preventDefault();on();}});
      const attrs={x1:a[0],y1:a[1],x2:b[0],y2:b[1]};
      group.append(svg("line",{...attrs,class:"obs-link"+(chosenEdge===e.id?" is-selected":""),"data-type":e.type,opacity:visible.has(e.from)&&visible.has(e.to)?"1":".1"}),svg("line",{...attrs,class:"obs-line-hit"}));
      group.append(svg("title",{}));group.lastChild.textContent=e.statement;
      graph.append(group);
    }
    for(const n of data.nodes){
      const pos=layout[n.id];if(!pos)continue;
      const g=svg("g",{class:"obs-node"+(chosen===n.id?" is-selected":"")+(visible.has(n.id)?"":" is-faded"),"data-status":n.status,tabindex:"0",role:"button","aria-label":"Select "+n.title});
      g.append(svg("circle",{cx:pos[0],cy:pos[1],r:31}));
      const t=svg("text",{x:pos[0],y:pos[1]+4});t.textContent=pos[2];g.append(t);
      const title=svg("title",{});title.textContent=n.title;g.append(title);
      const activate=()=>selectNode(n.id);
      g.addEventListener("click",activate);g.addEventListener("keydown",e=>{if(e.key==="Enter"||e.key===" "){e.preventDefault();activate()}});
      graph.append(g);
    }
    q("#obs-visible-count").textContent=visible.size+" / "+data.nodes.length+" claims in view";
  }
  function updateMode(){
    for(const b of modeButtons)b.setAttribute("aria-pressed",String(b.dataset.obsMode===mode));
    heading.textContent=labels[mode][0];description.textContent=labels[mode][1];
  }
  function renderInspector(){
    inspector.replaceChildren();
    if(chosenEdge){
      const e=data.edges.find(v=>v.id===chosenEdge);
      inspector.append(element("div","obs-panel-eyebrow","RESEARCH RELATION / "+e.id),element("h2","",e.type.replaceAll("-"," ")));
      inspector.append(element("span","obs-status",e.status));
      inspector.append(element("p","",e.statement),textRow("Source claim",node(e.from).title),textRow("Target claim",node(e.to).title),textRow("Required assumptions",e.assumptions),textRow("Decisive experiment",e.experiment));
      const a=element("a","", "Inspect evidence source");a.href=e.provenance_url;a.target="_blank";a.rel="noopener";inspector.append(a);
      return;
    }
    const n=node(chosen);
    if(!n)return;
    inspector.append(element("div","obs-panel-eyebrow",n.discipline.toUpperCase()+" / CLAIM "+n.revision),element("h2","",n.title));
    const badge=element("span","obs-status",n.status.replaceAll("-"," "));badge.dataset.status=n.status;inspector.append(badge);
    inspector.append(element("p","",n.statement));
    inspector.append(textRow("Precise scope",n.scope),textRow("Scope boundary / next proof obligation",n.boundary),textRow("Owner",n.owner));
    const src=element("div","obs-field");src.append(element("dt","", "Versioned source"),element("code","",n.source_key));
    const a=element("a","", "Open source at recorded revision");a.href=n.provenance[0].url;a.target="_blank";a.rel="noopener";src.append(element("p",""),a);inspector.append(src);
    if(mode==="evidence"){
      const digest=element("div","obs-field");digest.append(element("dt","", "Frozen claim SHA-256"),element("code","",n.identity_sha256));inspector.append(digest);
      const deps=element("div","obs-field");deps.append(element("dt","", "Logical dependency chain"),itemList(n.dependencies.map(id=>node(id)?.title||id).length?n.dependencies.map(id=>node(id)?.title||id):["No graph-local proof dependencies; external premises are listed in source."]));inspector.append(deps);
      const commands=element("div","obs-field");commands.append(element("dt","", "Reproduction instructions"),itemList(n.reproduce,true));inspector.append(commands);
    }else{
      const f=element("div","obs-field");f.append(element("dt","", "Explicit failure conditions"),itemList(n.failure_conditions));inspector.append(f);
      if(mode==="transfer")inspector.append(textRow("Related graph edges",relation(n.id).length+" classified relations"));
    }
  }
  const card=(k,title,summary,detail,onClick)=>{const c=element("article","obs-item");c.append(element("span","obs-item-id",k),element("h3","",title),element("p","",summary));if(detail)c.append(element("small","",detail));const b=element("button","", "Inspect in network");b.type="button";b.addEventListener("click",onClick);c.append(b);return c;};
  function renderCards(){
    cards.replaceChildren();
    if(mode==="scope"){
      for(const n of data.nodes.filter(allowed)){
        cards.append(card(n.id,n.title,n.boundary,n.status+" · "+n.owner,()=>selectNode(n.id)));
      }
    } else if(mode==="evidence"){
      const n=node(chosen);const chain=new Set();
      function visit(id){if(chain.has(id))return;chain.add(id);for(const dep of node(id)?.dependencies||[])visit(dep);}
      visit(chosen);
      for(const id of chain){const a=node(id);cards.append(card(a.id,a.title,a.source_key,"SHA-256 "+a.identity_sha256.slice(0,20)+"…",()=>selectNode(id)));}
      cards.append(card("SOURCE INTEGRITY","Proof status follows the claim","External mathematical premises and missing binary archives remain unresolved until reproduced.","Published source links do not establish independent proof.",()=>{window.open("https://github.com/d3lefts/d3lefts/blob/32df9e1b2b0049e0dbc7e27a465957a741843c5a/research/nightfall/observatory/CONSTITUTION.md","_blank","noopener");}));
    } else if(mode==="transfer"){
      for(const e of data.edges){
        const source=node(e.from),target=node(e.to);
        cards.append(card(e.id+" / "+e.type,source.title+" → "+target.title,e.assumptions,e.status+" · NEXT: "+e.experiment,()=>selectEdge(e.id)));
      }
    } else if(mode==="failure"){
      for(const n of data.nodes.filter(x=>x.status==="falsified"||x.status==="withdrawn"||x.status==="empirical-negative")){
        cards.append(card(n.id,n.title,n.boundary,n.status+" · Evidence preserved",()=>selectNode(n.id)));
      }
      for(const e of data.edges.filter(x=>x.type==="falsified-transfer"))cards.append(card(e.id,"Rejected transfer",e.statement,"Falsified · "+e.experiment,()=>selectEdge(e.id)));
    } else if(mode==="frontier"){
      for(const id of priority){const n=node(id);cards.append(card(n.owner.toUpperCase()+" / OPEN",n.title,n.boundary,"NEXT: "+n.reproduce[0],()=>selectNode(id)));}
    }
    q("#obs-results-count").textContent=cards.children.length+" inspectable entries";
  }
  async function start(){
    try{
      const res=await fetch("observatory-data.json",{cache:"no-cache"});
      if(!res.ok)throw Error("data HTTP "+res.status);
      data=await res.json();
      if(!Array.isArray(data.nodes)||!Array.isArray(data.edges))throw Error("invalid graph");
      status.textContent="REGISTRY LOADED / "+data.nodes.length+" CLAIMS / "+data.edges.length+" TYPED RELATIONS";
      search.addEventListener("input",()=>{drawGraph();renderCards()});
      discipline.addEventListener("change",()=>{drawGraph();renderCards()});
      for(const btn of modeButtons)btn.addEventListener("click",()=>{mode=btn.dataset.obsMode;chosenEdge=null;updateMode();drawGraph();renderInspector();renderCards()});
      updateMode();drawGraph();renderInspector();renderCards();
    }catch(err){status.textContent="GRAPH DATA UNAVAILABLE — STATIC EVIDENCE LINKS REMAIN BELOW";q("#obs-results-count").textContent=String(err.message);}
  }
  start();
})();
