"use strict";
(function(){
  const C=window.NFFrontier;
  if(!C)return;
  const KEY="nightfall_nf_frontier_local_v1";
  const $=id=>document.getElementById(id);
  const messages=$("nf-message"),tasks=[];
  let selectedId=C.ranked()[0].id;
  function inform(text){messages.textContent=text;$("nf-session-state").textContent=text;}
  function safeLoad(){
    try{
      const o=JSON.parse(localStorage.getItem(KEY)||"null");
      if(!o||o.version!==C.VERSION||!Array.isArray(o.tasks))throw Error("Unsupported saved snapshot");
      C.validateLedger(o.tasks);
      for(const item of o.tasks){
        tasks.push({id:item.id,rootId:item.rootId,lo:item.lo,hi:item.hi,parentId:item.parentId||null,
          depth:Number.isInteger(item.depth)?item.depth:0,state:item.state,claimedAt:item.claimedAt||null,
          evidence:Array.isArray(item.evidence)?item.evidence.slice(0,8).filter(x=>x&&typeof x.url==="string"):[]});
      }
    }catch(e){inform("Stored assignment data was rejected ("+e.message+"). Export your original backup before resetting; no public work was affected.")}
  }
  function store(){
    try{C.validateLedger(tasks);localStorage.setItem(KEY,JSON.stringify({version:C.VERSION,snapshotDate:"2026-10-29",tasks}));return true}
    catch(e){inform("Browser storage unavailable. Export your local record to preserve it.");return false}
  }
  const taskById=id=>tasks.find(t=>t.id===id)||null;
  function selectedTask(){
    return taskById(selectedId)||C.rootTask(C.base(selectedId)||C.base(selectedId.split("/")[0])||C.ranked()[0]);
  }
  function active(){
    const t=selectedTask(),root=C.base(t.rootId);
    $("active-tag").textContent=root.parent+" / "+(t.depth?"SUBQUESTION "+t.depth:"ROOT SLICE");
    $("active-title").textContent=root.title;
    $("active-why").textContent=root.why;
    $("active-predicate").textContent=C.predicate(t);
    $("active-yes").textContent=root.closureYes;
    $("active-no").textContent=root.closureNo;
    $("active-parent").textContent=root.question;
    $("active-stop").textContent=root.stop;
    $("nf-source").href=root.source;$("nf-data").href=root.data;$("nf-evidence").href=root.evidence;
    $("nf-public").href=C.issueUrl(t,"CLAIM REQUEST","I request assignment coordination for this exact bounded case.");
    $("nf-claim").textContent=t.state==="claimed"?"Claimed in this browser":"Claim in this browser";
    $("nf-claim").disabled=t.state==="split"||t.state==="proposed";
    $("nf-split").disabled=t.lo===t.hi||t.state==="split"||t.state==="proposed";
    $("nf-tool-hint").textContent=root.toolHint;
    const list=$("nf-tool-links");list.replaceChildren();
    for(const url of root.tools){
      const a=document.createElement("a");a.href=url;a.textContent=url==="orchestrator.html"?"Orchestrator / independent lanes ↗":url==="discovery.html"?"Discovery / investigate this branch ↗":url==="claim-lab.html"?"Claim Lab / evidence register ↗":url==="desk.html"?"Research Desk ↗":"Mechanism Atlas ↗";
      if(url==="orchestrator.html")a.addEventListener("click",event=>{
        event.preventDefault();
        try{
          const payload=C.orchestratorInput(selectedTask());
          sessionStorage.setItem("nightfall.frontier.orchestrator.v1",JSON.stringify(payload));
          location.assign("orchestrator.html?frontier_handoff=1");
        }catch(e){inform("Orchestrator handoff unavailable: "+e.message+". Copy the frozen research brief.");}
      });
      if(url==="discovery.html")a.addEventListener("click",event=>{
        event.preventDefault();
        try{
          const payload=C.packet(selectedTask());
          C.validatePacket(payload);
          sessionStorage.setItem("nightfall.frontier.discovery.v1",JSON.stringify(payload));
          location.assign("discovery.html?frontier_handoff=1");
        }catch(e){inform("Discovery handoff refused: "+e.message+". Copy the frozen research brief instead.");}
      });
      if(url==="claim-lab.html")a.addEventListener("click",event=>{
        event.preventDefault();
        try{
          const payload=C.packet(selectedTask());
          sessionStorage.setItem("nightfall.frontier.claimlab.v1",JSON.stringify(payload));
          location.assign("claim-lab.html?frontier_handoff=1");
        }catch(e){inform("Claim Lab handoff rejected: "+e.message+". Export the research brief instead.");}
      });
      list.appendChild(a);
    }
    const sidon=t.rootId==="NF-156-184-9";
    $("nf-check").disabled=!sidon;$("nf-near").disabled=!sidon;$("nf-values").disabled=!sidon;
    $("nf-check-output").textContent=sidon?"Ready for nine integers. Every omitted mark will be tested.":"Exact browser oracle unavailable for Q7; use the independent cube and square checker in the cited research files.";
    $("nf-review-link").hidden=true;
    $("nf-review-link").style.display="none";
    return t;
  }
  function rankList(){
    const list=$("frontier-ranking");list.replaceChildren();
    for(const root of C.ranked()){
      const b=document.createElement("button");b.type="button";b.className="f-rank";b.setAttribute("aria-pressed",String(selectedTask().rootId===root.id));b.setAttribute("aria-label","Open "+root.title);
      const top=document.createElement("div");top.className="f-rank-top";
      const id=document.createElement("span");id.textContent=root.code;
      const value=document.createElement("span");value.className="f-score";value.textContent=C.score(root);
      top.append(id,value);
      const tag=document.createElement("span");tag.className="f-rank-tag";tag.textContent=root.parent+" / EXACT FINITE DECISION";
      const title=document.createElement("strong");title.textContent=root.title;
      const why=document.createElement("small");why.textContent=root.question;
      b.append(top,tag,title,why);
      b.addEventListener("click",()=>{selectedId=root.id;paint();inform("Selected "+root.parent+" under the frozen Agent NF priority snapshot.");});
      list.appendChild(b);
    }
  }
  function listTasks(){
    const box=$("nf-session-list");box.replaceChildren();
    const stats=C.summarizeLedger(tasks);
    $("nf-progress").textContent=stats.total+" scoped assignments · "+stats.leaves+" unresolved leaf obligations · "+stats.proposed+" proposals awaiting review · "+stats.unreviewed+" unreviewed evidence entries. None are certified by this interface.";
    if(!tasks.length){
      const el=document.createElement("div");el.className="f-session-item";
      const d=document.createElement("div"),h=document.createElement("strong"),p=document.createElement("p");
      h.textContent="NO LOCAL ASSIGNMENTS YET";p.textContent="Claim a question or divide it into smaller mathematically exhaustive branches.";
      d.append(h,p);el.append(d);box.append(el);return;
    }
    for(const t of tasks){
      const item=document.createElement("article");item.className="f-session-item";
      const content=document.createElement("div");
      const h=document.createElement("strong");h.textContent=(t.parentId?"↳ ":"")+t.id;
      const p=document.createElement("p");p.textContent=C.predicate(t)+" · "+t.state.toUpperCase()+" · "+t.evidence.length+" unreviewed local proposal(s)";
      const meta=document.createElement("small");meta.textContent=t.state==="split"?"PARENT RETAINED / NO CLOSURE":t.state==="proposed"?"AWAITING INDEPENDENT REVIEW":"SOURCE SCOPE FROZEN";
      content.append(h,p,meta);
      const b=document.createElement("button");b.type="button";b.textContent="Inspect ↗";
      b.addEventListener("click",()=>{selectedId=t.id;paint();$("active-title").scrollIntoView({behavior:"smooth",block:"start"});});
      item.append(content,b);box.append(item);
    }
  }
  function paint(){active();rankList();listTasks();}
  function ensureStored(){
    let t=taskById(selectedId);
    if(t)return t;
    const b=C.base(selectedId);
    if(!b)throw Error("Selected root assignment is unavailable.");
    t=C.rootTask(b);tasks.push(t);return t;
  }
  $("nf-claim").addEventListener("click",()=>{
    const t=ensureStored();
    if(t.state==="split"||t.state==="proposed")return;
    t.state="claimed";t.claimedAt=t.claimedAt||new Date().toISOString();
    store();paint();inform("Claimed locally: "+t.id+". For a shared assignment, submit the public request via GitHub.");
  });
  $("nf-split").addEventListener("click",()=>{
    const t=ensureStored();
    if(t.state==="split"||t.state==="proposed")return;
    let children;try{children=C.split(t)}catch(e){inform(e.message);return;}
    if(!C.validPartition(t,children))throw Error("Internal partition invariant failed.");
    if(tasks.length+children.length>250){inform("Demo branch budget reached (250). Export and review before further division.");return;}
    t.state="split";tasks.push(...children);selectedId=children[0].id;
    store();paint();
    inform("Exact partition created: ["+children[0].lo+","+children[0].hi+"] and ["+children[1].lo+","+children[1].hi+"]. Their union is the parent; neither child is solved.");
  });
  $("nf-copy").addEventListener("click",async()=>{
    const payload=C.brief(selectedTask());
    try{
      if(!navigator.clipboard?.writeText)throw Error("Clipboard unavailable");
      await navigator.clipboard.writeText(payload);inform("Copied the frozen research contract. Paste it into your AI research session.");
    }catch(e){window.prompt("Copy this exact research contract:",payload);inform("Research brief ready for manual copying.");}
  });
  $("nf-near").addEventListener("click",()=>{
    const t=selectedTask();
    if(t.rootId!=="NF-156-184-9")return;
    $("nf-values").value="49, 50, 56, 78, 93, 104, 125, 139, 149";
    $("nf-check-output").textContent="Archived N=184 nine-mark near-candidate loaded from Axiom PR #55. Run the exact finite checker: insertion at 16 and 166 remains possible, so this is an unresolved example.";
  });
  $("nf-check").addEventListener("click",()=>{
    const t=selectedTask();
    if(t.rootId!=="NF-156-184-9")return;
    const raw=$("nf-values").value.trim();
    if(!raw||!/^\d+(?:[\s,]+\d+)*$/.test(raw)){
      $("nf-check-output").textContent="Enter nine whole numbers separated by spaces or commas.";return;
    }
    const nums=raw.split(/[\s,]+/).map(Number);
    const result=C.checkSidonCandidate(nums,184,t);
    $("nf-check-output").textContent=(result.ok?"LOCAL EXACT CHECK PASSED / EXTERNAL REVIEW REQUIRED\n":"REJECTED OR UNRESOLVED\n")+result.reason;
    if(result.ok){
      $("nf-outcome").value="positive";
      $("nf-summary").value="Candidate: "+result.values.join(", ")+". Browser check: 45 unique unordered sums and "+result.checkedOmissions+" omitted values individually reject insertion. Reproduce using an independent full integer oracle before scientific acceptance.";
      inform("A nine-mark positive candidate passed local arithmetic. It can be submitted for independent replay; no public claim was automatically promoted.");
    }
  });
  $("nf-submit").addEventListener("click",()=>{
    const url=$("nf-reference").value.trim(),note=$("nf-summary").value.trim(),type=$("nf-outcome").value;
    if(!/^https:\/\/[^\s<>"']+$/i.test(url)){inform("A public HTTPS evidence URL is required for a scientific submission.");return;}
    if(note.length<30){inform("State the exact claim, reproducibility and limitation (at least 30 characters).");return;}
    const t=ensureStored();
    if(t.state==="split"){inform("A divided parent cannot be directly closed. Work on a child, then submit a separate parent synthesis.");return;}
    t.evidence.push({kind:type,url,statement:note,createdAt:new Date().toISOString(),reviewStatus:"unreviewed"});
    if(t.evidence.length>8)t.evidence.shift();
    t.state="proposed";store();paint();
    const link=C.issueUrl(t,"UNREVIEWED "+type.toUpperCase(),url+"\n"+note);
    const a=$("nf-review-link");a.href=link;a.hidden=false;a.style.display="block";
    $("nf-submitted").textContent="Recorded locally / UNREVIEWED. Scientific closure requires independent checking of the exact certificate. Export the record, then use the public review link below.";
    inform("Evidence proposal stored locally; no public proof status or parent problem state has changed.");
  });
  function exportLedger(){
    C.validateLedger(tasks);
    const payload={schema:"nightfall-frontier-local-evidence-v1",snapshot:C.VERSION,exportedAt:new Date().toISOString(),
      source:"https://d3lefts.github.io/d3lefts/frontier.html",reviewStatus:"unreviewed",tasks:tasks.map(t=>({...t,scope:C.predicate(t)}))};
    const data=new Blob([JSON.stringify(payload,null,2)],{type:"application/json"}),url=URL.createObjectURL(data);
    const a=document.createElement("a");a.href=url;a.download="NIGHTFALL_frontier_local_ledger.json";
    document.body.appendChild(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),1200);
    inform("Local evidence ledger exported. It does not constitute a verified certificate.");
  }
  $("nf-export").addEventListener("click",exportLedger);
  $("nf-import").addEventListener("click",()=>$("nf-import-file").click());
  $("nf-import-file").addEventListener("change",async event=>{
    const file=event.target.files?.[0];if(!file)return;
    try{
      if(file.size>500000)throw Error("Import exceeds 500 KB");
      const payload=JSON.parse(await file.text());
      if(payload.schema!=="nightfall-frontier-local-evidence-v1"||payload.snapshot!==C.VERSION||payload.reviewStatus!=="unreviewed")throw Error("Unsupported or upgraded ledger snapshot");
      const report=C.validateLedger(payload.tasks);
      if(!confirm("Import "+report.counts.total+" assignments? Existing browser assignments will be exported before replacement. No public claims change."))return;
      exportLedger();
      const prev=tasks.slice();const oldSelected=selectedId;
      tasks.splice(0,tasks.length,...payload.tasks.map(t=>({id:t.id,rootId:t.rootId,lo:t.lo,hi:t.hi,parentId:t.parentId,depth:t.depth,state:t.state,claimedAt:t.claimedAt,evidence:t.evidence.map(e=>({kind:e.kind,url:e.url,statement:e.statement,createdAt:e.createdAt,reviewStatus:"unreviewed"}))})));
      selectedId=C.ranked()[0].id;
      if(!store()){tasks.splice(0,tasks.length,...prev);selectedId=oldSelected;throw Error("Browser storage failed; existing state restored");}
      paint();inform("Validated "+report.counts.total+" assignments and restored exact branch lineage; every evidence entry stays unreviewed.");
    }catch(e){inform("Frontier import refused: "+e.message);}
    finally{event.target.value="";}
  });
  $("nf-reset").addEventListener("click",()=>{
    if(!window.confirm("Reset this browser's NF Frontier demo assignments? Export your ledger first if you need it."))return;
    tasks.splice(0,tasks.length);selectedId=C.ranked()[0].id;
    try{localStorage.removeItem(KEY)}catch(e){/* no persistent storage available */}
    $("nf-reference").value="";$("nf-summary").value="";$("nf-values").value="";
    paint();inform("Local demo reset. No public GitHub assignments or evidence have been changed.");
  });
  safeLoad();paint();
})();
