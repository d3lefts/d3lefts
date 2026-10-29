"use strict";
/* Living Paper 001. Exact integer calculations on the frozen 30-point witness.
   This browser exhibit is same-package replay, never independent external review. */
(()=>{
 const core=window.RefereeCore, registry=window.NightfallRegistry;
 const $=id=>document.getElementById(id);
 if(!core||!registry){$("lp-output").textContent="Verifier modules unavailable; consult the linked standalone Python checker.";return}
 const points=core.SIDON_WITNESS.map(Number), subset=core.SIDON_SUBSET.map(Number);
 const indexOf=new Map(points.map((v,i)=>[v,i]));
 const subsetIndices=subset.map(v=>indexOf.get(v));
 const edges=[];
 for(let i=0;i<points.length;i++)for(let j=i+1;j<points.length;j++)for(let k=j+1;k<points.length;k++){
   if(points[i]+points[k]===2*points[j])edges.push([i,j,k]);
 }
 const fullMask=(1<<points.length)-1;
 const edgeMasks=edges.map(e=>e.reduce((m,i)=>m|(1<<i),0));
 const sourceUrl="https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sidon-finite-30/witness_30.txt";
 const sha256="dc4697ce051a57987049199965967cc2b981433816d3daac284454262395978f";
 let mode="subset", current=0, lastAudit=null;
 const pad=n=>String(n).padStart(2,"0");
 const popcount=n=>{let c=0;while(n){n&=n-1;c++}return c};
 function activeIndices(mask){return points.map((_,i)=>i).filter(i=>(mask&(1<<i))===0)}
 function renderPoints(retained,focus=[]){
   const on=new Set(retained), special=new Set(focus), container=$("lp-points"),frag=document.createDocumentFragment();
   points.forEach((n,i)=>{
     const el=document.createElement("div");el.className="lp-point"+(on.has(i)?" is-on":"")+(special.has(i)?" is-edge":"");
     el.setAttribute("role","listitem");
     el.setAttribute("aria-label","Position "+(i+1)+": "+n+(on.has(i)?", retained":", excluded")+(special.has(i)?", selected progression":""));
     const label=document.createElement("strong");label.textContent=pad(i+1);
     const value=document.createElement("span");value.textContent=n.toLocaleString("en-US");
     el.append(label,value);frag.append(el);
   });container.replaceChildren(frag);
 }
 function readout(kicker,title,detail){
   $("lp-readout-kicker").textContent=kicker;
   $("lp-readout-title").textContent=title;
   $("lp-readout-detail").textContent=detail;
 }
 function selectedEdge(){return edges[current]}
 function describeEdge(e){return e.map(i=>pad(i+1)).join(" – ")}
 // Exact finite 12-deletion cover search after omitting one fixed AP.
 // A recovered cover may contain fewer than 12 deletions; fill to 12, then
 // verify from scratch that exactly the omitted AP remains among 18 survivors.
 function deletedEdgeWitness(removedIndex){
   const protectedEdge=edgeMasks[removedIndex];
   const relevant=edgeMasks.filter((_,i)=>i!==removedIndex);
   const failures=new Set();
   function dfs(deleted,left){
     const remaining=relevant.filter(e=>(e&deleted)===0);
     if(!remaining.length)return deleted;
     if(left===0)return null;
     const key=deleted+":"+left;
     if(failures.has(key))return null;
     let used=0,packing=0;
     for(const e of remaining)if((e&used)===0){used|=e;packing++}
     if(packing>left){failures.add(key);return null}
     let best=null,choices=4;
     for(const e of remaining){
       const eligible=e&~protectedEdge&~deleted;
       const count=popcount(eligible);
       if(count<choices){choices=count;best=e}
       if(count===0)break;
     }
     if(choices===0){failures.add(key);return null}
     for(let i=0;i<points.length;i++)if((best&(1<<i))&&!(protectedEdge&(1<<i))){
       const solved=dfs(deleted|(1<<i),left-1);
       if(solved!==null)return solved;
     }
     failures.add(key);return null;
   }
   let deleted=dfs(0,12);
   if(deleted===null)return null;
   for(let i=0;i<points.length&&popcount(deleted)<12;i++){
     if(!(deleted&(1<<i))&&!(protectedEdge&(1<<i)))deleted|=1<<i;
   }
   const survivors=activeIndices(deleted);
   const remainingEdges=edgeMasks.map((m,i)=>({m,i})).filter(x=>(x.m&deleted)===0).map(x=>x.i);
   if(survivors.length!==18||remainingEdges.length!==1||remainingEdges[0]!==removedIndex)return null;
   return {removedIndex,deletedIndices:points.map((_,i)=>i).filter(i=>(deleted&(1<<i))!==0),survivingIndices:survivors,remainingEdges};
 }
 function showSubset(){
   mode="subset";renderPoints(subsetIndices);
   readout("PUBLISHED EXACT WITNESS","17 points retained","The fixed 17-point subset has 153 distinct unordered pair sums. The proof of maximality needs an additional exclusion of all 18-point subsets.");
 }
 function showPreview(){
   mode="preview";
   renderPoints(subsetIndices,selectedEdge());
   const q=selectedEdge().map(i=>points[i]);
   readout("SELECTED THREE-TERM PROGRESSION",describeEdge(selectedEdge()),q[0].toLocaleString("en-US")+" + "+q[2].toLocaleString("en-US")+" = 2 × "+q[1].toLocaleString("en-US")+". Select “Remove this constraint” to construct an 18-point survivor.");
 }
 function showDeletion(){
   const witness=deletedEdgeWitness(current);
   if(!witness){
     $("lp-output").textContent="INCONCLUSIVE: no 12-deletion cover found after removal. No finite claim upgraded.";
     return;
   }
   mode="deletion";renderPoints(witness.survivingIndices,selectedEdge());
   readout("ONE CONSTRAINT DELETED · EXACT COUNTERWITNESS","18 points retained","All 27 other arithmetic-progressions are hit by 12 deleted vertices. The sole remaining progression is positions "+describeEdge(selectedEdge())+". This is an edge-deletion witness, not an 18-point Sidon subset in the original problem.");
   $("lp-output").textContent="EDGE-REMOVAL CHECK PASSED\nDeleted constraint: "+describeEdge(selectedEdge())+"\nSurviving indices (1-based): "+witness.survivingIndices.map(i=>i+1).join(", ")+"\nUncovered progression constraints: 1 of 28.\nScope: one fixed finite witness only.";
 }
 function runExact(){
   $("lp-output").textContent="Running finite exact checks…";
   $("lp-run").disabled=true;
   try{
     const p=core.checkSidon({points:core.SIDON_WITNESS,subset:core.SIDON_SUBSET},17);
     const proofs=edges.map((_,i)=>deletedEdgeWitness(i));
     const allDeletions=proofs.every(Boolean);
     const pass=p.status==="FINITE_CHECK_PASSED"&&p.fourFive.pass&&p.weakSidon.pass&&p.subset.pass&&p.subset.pairSums===153&&p.proof?.status==="PROVED"&&p.proof.arithmeticProgressions===28&&edges.length===28&&allDeletions;
     const attacks=pass?core.sidonAttacks({points:core.SIDON_WITNESS,subset:core.SIDON_SUBSET},17):null;
     const mutation=Boolean(attacks?.understatedMaximumRejected&&attacks?.corruptedSubsetRejected&&attacks?.strengthDistinctionDetected);
     lastAudit={pass:pass&&mutation,datetime:new Date().toISOString(),fourPointTests:p.fourFive.tested,pairSums:p.subset.pairSums,
       progressionCount:edges.length,exactNo18:p.proof.status==="PROVED",proofStates:p.proof.states,
       edgeDeletionWitnesses:proofs.filter(Boolean).length,negativeControlsPassed:mutation,scope:"One fixed 30-coordinate input; browser-local same-package check, not independent referee"};
     $("lp-output").textContent=(lastAudit.pass?"LOCAL FINITE CHECK PASSED":"LOCAL CHECK INCONCLUSIVE")+"\n4-point selections checked: "+p.fourFive.tested+"\nDistinct sums in 17-subset: "+p.subset.pairSums+"\nAP constraints recomputed: "+edges.length+"\nNo 18-point Sidon subset: "+String(lastAudit.exactNo18)+"\n12-deletion proof memo states: "+p.proof.states+"\nEdge-deletion witnesses checked: "+lastAudit.edgeDeletionWitnesses+"/28\nNegative controls: "+(mutation?"passed":"failed")+"\nExternal specialist review: OPEN";
     $("lp-export").disabled=!lastAudit.pass;
     if(lastAudit.pass)readout("FULL FINITE REPLAY PASSED","17 is the exact maximum","The in-browser checker excluded every 18-point Sidon subset, and all 28 constraint deletions admitted a separate 18-point counterwitness. This same-package replay does not establish external peer review.");
   }catch(error){
     lastAudit=null;$("lp-export").disabled=true;
     $("lp-output").textContent="CHECK FAILED CLOSED\n"+String(error?.message||error);
   }finally{$("lp-run").disabled=false}
 }
 function exportEvidence(){
   if(!lastAudit?.pass)return;
   const record={schema:"nightfall-living-paper-local-replay-v1",claim:"sidon30",source:sourceUrl,
     source_witness_sha256_reported:sha256,source_identity_verified_from_bytes:false,
     checker:"referee-core.js + living-paper.js",checker_independent_external:false,
     points:core.SIDON_WITNESS,subset:core.SIDON_SUBSET,local_result:lastAudit,
     publication_status:"Unreviewed browser-local exact replay; external independent review open"};
   const blob=new Blob([JSON.stringify(record,null,2)+"\n"],{type:"application/json"});
   const url=URL.createObjectURL(blob),a=document.createElement("a");
   a.href=url;a.download="nightfall_sidon30_local_replay.json";document.body.append(a);a.click();a.remove();
   setTimeout(()=>URL.revokeObjectURL(url),1000);
 }
 function renderHistory(){
   const claim=registry.claimById("sidon30");
   const frag=document.createDocumentFragment();
   for(const item of claim?.history||[]){
     const row=document.createElement("article"),date=document.createElement("time"),content=document.createElement("div");
     date.dateTime=item.date;date.textContent=item.date;
     const title=document.createElement("strong");title.textContent=item.label;
     const detail=document.createElement("p");detail.textContent=item.detail;
     content.append(title,detail);row.append(date,content);frag.append(row);
   }
   $("lp-history-items").replaceChildren(frag);
 }
 const select=$("lp-edge-select");select.replaceChildren();
 edges.forEach((edge,i)=>{
   const option=document.createElement("option");option.value=String(i);
   option.textContent=pad(i+1)+" / "+describeEdge(edge);
   select.append(option);
 });
 select.addEventListener("change",()=>{current=Number(select.value);showPreview()});
 $("lp-delete").addEventListener("click",showDeletion);
 $("lp-reset").addEventListener("click",showSubset);
 $("lp-run").addEventListener("click",runExact);
 $("lp-export").addEventListener("click",exportEvidence);
 renderHistory();showSubset();
 if(points.length!==30||subset.length!==17||edges.length!==28){
   $("lp-output").textContent="SOURCE INVARIANT MISMATCH: inspect the published witness. Interactive proof is disabled.";
   for(const id of ["lp-run","lp-delete","lp-export"])$(id).disabled=true;
 }
})();
