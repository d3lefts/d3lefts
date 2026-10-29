import assert from "node:assert/strict";
import {createServer} from "node:http";
import {readFile} from "node:fs/promises";
import {join,normalize,resolve,sep} from "node:path";
import {chromium} from "playwright-core";

const root=resolve("docs");
const pages=["index.html","review.html","evidence.html","agenda.html","research.html","exact-research.html","desk.html","frontier.html"];
const types={".html":"text/html; charset=utf-8",".css":"text/css; charset=utf-8",".js":"text/javascript; charset=utf-8",".svg":"image/svg+xml"};
const server=createServer(async (req,res)=>{
 try{
  const pathname=decodeURIComponent(new URL(req.url,"http://localhost").pathname);
  const file=resolve(join(root,normalize(pathname).replace(/^\/+/,"")||"index.html"));
  if(file!==root&&!file.startsWith(root+sep)){res.writeHead(403).end();return;}
  const data=await readFile(file);
  const ext=file.slice(file.lastIndexOf("."));
  res.writeHead(200,{"Content-Type":types[ext]||"application/octet-stream"}).end(data);
 }catch{res.writeHead(404).end("Missing");}
});
await new Promise(resolve=>server.listen(0,"127.0.0.1",resolve));
const port=server.address().port;
const origin="http://127.0.0.1:"+port+"/";
let browser;
try{
 const executablePath=process.env.CHROME_BIN||"/usr/bin/chromium";
 browser=await chromium.launch({headless:true,executablePath,args:["--no-sandbox"]});
 for(const width of [390,768,1024,1280,1440]){
  const page=await browser.newPage({viewport:{width,height:850}});
  const faults=[];
  page.on("pageerror",e=>faults.push(e.message));
  page.on("response",r=>{if(r.url().startsWith(origin)&&r.status()>=400)faults.push(r.url()+" "+r.status());});
  for(const file of pages){
   await page.goto(origin+file,{waitUntil:"load"});
   const menu=page.locator("#menu-button");
   const nav=page.locator("#site-nav");
   assert.equal(await menu.count(),1,file+" missing menu");
   assert.equal(await nav.count(),1,file+" missing nav");
   // The published site stylesheet uses the collapsed nav through 1300px.
   const mobile=width<=1300;
   assert.equal(await menu.isVisible(),mobile,file+" menu visibility at "+width);
   assert.equal(await nav.isVisible(),!mobile,file+" nav visibility at "+width);
   if(mobile){
    await menu.click();
    assert.equal(await menu.getAttribute("aria-expanded"),"true",file+" expand state");
    assert.equal(await nav.isVisible(),true,file+" menu opens");
    const links=nav.locator("a");
    for(let j=0;j<await links.count();j++)
     assert.equal(await links.nth(j).isVisible(),true,file+" hidden menu link "+j);
    await page.keyboard.press("Escape");
    assert.equal(await nav.isVisible(),false,file+" Escape closes menu");
    assert.equal(await menu.getAttribute("aria-expanded"),"false",file+" Escape state");
   }
   const overflow=await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth);
   if(overflow>3){
    const culprits=await page.evaluate(()=>[...document.body.querySelectorAll("*")].map(el=>({el,rect:el.getBoundingClientRect()})).filter(x=>x.rect.right>innerWidth+3&&x.rect.width>0).slice(0,8).map(x=>({tag:x.el.tagName,class:x.el.className?.baseVal??x.el.className,scrollWidth:x.el.scrollWidth,right:Math.round(x.rect.right)})));
    assert.fail(file+" horizontal overflow "+overflow+"px at "+width+"; culprits="+JSON.stringify(culprits));
   }
  }
  if(width===390){
   await page.goto(origin+"frontier.html",{waitUntil:"load"});
   assert.equal(await page.locator(".f-rank").count(),2,"two source-linked finite frontier slices");
   assert.match(await page.locator(".f-rank").first().innerText(),/37/,"transparent deterministic Agent NF rank");
   assert.match(await page.locator("#active-predicate").innerText(),/\[1, 184\]/,"full original N184 branch");
   assert.match(await page.locator("#nf-check-output").innerText(),/Ready for nine integers/);
   await page.locator("#nf-values").fill("1, 2, 3, 4, 5, 6, 7, 8, 9");
   await page.locator("#nf-check").click();
   assert.match(await page.locator("#nf-check-output").innerText(),/Repeated pair sum/,"non-Sidon values rejected");
   await page.locator("#nf-values").fill("1, 2, 6, 13, 26, 28, 36, 42, 45");
   await page.locator("#nf-check").click();
   assert.match(await page.locator("#nf-check-output").innerText(),/not maximal/,"correct finite but nonmaximal controls");
   await page.locator("#nf-near").click();
   await page.locator("#nf-check").click();
   assert.match(await page.locator("#nf-check-output").innerText(),/16, 166/,"source-linked near-candidate remains open");
   await page.locator("#nf-claim").click();
   assert.match(await page.locator("#nf-session-list").innerText(),/CLAIMED/,"local claim recorded");
   await page.locator("#nf-split").click();
   assert.match(await page.locator("#nf-message").innerText(),/Exact partition created/,"split coverage user feedback");
   assert.match(await page.locator("#nf-session-list").innerText(),/\[1, 92\]/,"first exhaustive half");
   assert.match(await page.locator("#nf-session-list").innerText(),/\[93, 184\]/,"second exhaustive half");
   const childLink=await page.locator("#nf-public").getAttribute("href");
   assert(childLink.includes("issues/new")&&childLink.includes("CLAIM%20REQUEST"),"real GitHub request");
   await page.locator("#nf-reference").fill("https://github.com/d3lefts/d3lefts/issues/46");
   await page.locator("#nf-summary").fill("This is a bounded simulated attempt with independent checker absent. It is an unresolved negative research trace.");
   await page.locator("#nf-submit").click();
   assert.match(await page.locator("#nf-submitted").innerText(),/UNREVIEWED/,"no automatic scientific resolution");
   assert.equal(await page.locator("#nf-review-link").isVisible(),true,"review handoff opens");
   const [frontierDownload]=await Promise.all([page.waitForEvent("download"),page.locator("#nf-export").click()]);
   assert.match(frontierDownload.suggestedFilename(),/frontier_local_ledger\.json$/);
   await page.reload({waitUntil:"load"});
   assert.match(await page.locator("#nf-session-list").innerText(),/PROPOSED/,"browser-local reload persists review status");
   const cleanLedger=await page.evaluate(()=>{
     const saved=JSON.parse(localStorage.getItem("nightfall_nf_frontier_local_v1"));
     return {schema:"nightfall-frontier-local-evidence-v1",snapshot:saved.version,reviewStatus:"unreviewed",tasks:saved.tasks};
   });
   const modifiedLedger=structuredClone(cleanLedger);
   modifiedLedger.tasks.find(t=>t.parentId==="NF-156-184-9").lo+=1;
   await page.locator("#nf-import-file").setInputFiles({name:"modified.json",mimeType:"application/json",buffer:Buffer.from(JSON.stringify(modifiedLedger))});
   assert.match(await page.locator("#nf-message").innerText(),/Frontier import refused/);
   assert.match(await page.locator("#nf-progress").innerText(),/2 unresolved leaf obligations/);
   page.once("dialog",d=>d.accept());
   await page.locator("#nf-reset").click();
   assert.match(await page.locator("#nf-session-list").innerText(),/NO LOCAL ASSIGNMENTS/);
   page.once("dialog",d=>d.accept());
   const [preRestoreBackup]=await Promise.all([
      page.waitForEvent("download"),
      page.locator("#nf-import-file").setInputFiles({name:"verified.json",mimeType:"application/json",buffer:Buffer.from(JSON.stringify(cleanLedger))})
   ]);
   assert.match(preRestoreBackup.suggestedFilename(),/frontier_local_ledger\.json$/);
   assert.match(await page.locator("#nf-session-list").innerText(),/PROPOSED/);
   assert.match(await page.locator("#nf-progress").innerText(),/2 unresolved leaf obligations/);

   await page.locator('#nf-tool-links a[href="orchestrator.html"]').click();
   await page.waitForURL(/orchestrator\.html/);
   assert.match(await page.locator("#claim-text").inputValue(),/smallest selected mark in \[1, 184\]/,"exact scope transferred");
   assert.match(await page.locator("#orch-message").innerText(),/editable fields/,"user-reviewed handoff");
   assert.equal(await page.locator("#orch-export").isDisabled(),true,"no autonomous dispatch or proof promotion");
   // Exact Frontier source-to-Claim-Lab user journey, with explicit approval.
   await page.goto(origin+"frontier.html",{waitUntil:"load"});
   assert.match(await page.locator("#nf-progress").innerText(),/2 unresolved leaf obligations/,"split leaf progress survives reload");
   assert.equal(await page.locator("#nf-import").isVisible(),true,"audited backup restore is available");
   const packet=await page.evaluate(()=>window.NFFrontier.packet(window.NFFrontier.split(window.NFFrontier.rootTask(window.NFFrontier.ITEMS[0]))[0]));
   assert.equal(packet.scope,"smallest selected mark in [1, 92]");
   const forged=await page.evaluate(p=>{
     try{window.NFFrontier.validatePacket({...p,hi:p.hi+1});return "accepted"}catch(e){return e.message}
   },packet);
   assert.match(forged,/altered/,"Frontier rejects a forged branch interval");
   page.once("dialog",dialog=>dialog.accept());
   await page.locator('#nf-tool-links a[href="claim-lab.html"]').click();
   await page.waitForURL(/claim-lab\.html/);
   assert.match(await page.locator(".claimCard").filter({hasText:"Frontier /"}).first().innerText(),/Frontier/,"Claim Lab received explicit Frontier transfer");
   assert.match(await page.locator(".claimCard").filter({hasText:"Frontier /"}).first().innerText(),/Conjecture/,"import cannot promote proof tier");
   assert.equal(await page.evaluate(()=>JSON.parse(localStorage.getItem("nightfall_claim_lab_v1")).claims.some(c=>c.frontierId==="NF-156-184-9"&&c.status===0)),true,"Frontier provenance preserved");
   assert.equal(await page.evaluate(()=>sessionStorage.getItem("nightfall.frontier.claimlab.v1")),null,"one-shot handoff consumed");

  }
  await page.goto(origin+"discovery.html",{waitUntil:"load"});
  assert.equal(await page.locator(".context h1").innerText(),"Minimum overlap · EA #36","Discovery Engine initial project");
  await page.locator('[data-tab="experiments"]').first().click();
  await page.locator("#prediction").fill("Finite toy max <= 3");
  await page.locator('[data-act="run"]').first().click();
  assert.equal(await page.locator(".evidence").count(),1,"Discovery experiment saved");
  assert.match(await page.locator(".audit-flags").innerText(),/DIRECT REPLAY PASS/,"Exact second-path replay");
  await page.locator("[data-replay]").first().click();
  await page.locator("[data-tab=package]").first().click();
  const [zipDownload]=await Promise.all([page.waitForEvent("download"),page.locator("[data-act=export]").first().click()]);
  assert.match(zipDownload.suggestedFilename(),/\.zip$/,"Exported ZIP");
  const engineOverflow=await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth);
  assert.ok(engineOverflow<=3,"Discovery overflow: "+engineOverflow+" at "+width);
  await page.locator('[data-project="sidon"]').click();
  await page.locator('[data-tab="experiments"]').first().click();
  await page.locator("#prediction").fill("Sidon original proof certificate should survive independent review");
  await page.locator('[data-act="run"]').first().click();
  assert.equal(await page.locator(".evidence").count(),1,"Sidon external research manifest saved");
  assert.match(await page.locator(".evidence").innerText(),/EXTERNAL RUN PENDING/,"No invented mathematical result");
  assert.equal(await page.locator(".portfolio").count(),3,"Only original research presets shown");
  if(width===390){
   await page.goto(origin+"index.html",{waitUntil:"load"});
   assert.match(await page.locator(".ticker").innerText(),/33/,"homepage current library count");
   assert.equal(await page.locator("#instruments .instrument-workflow span").count(),4,"four instrument workflow stages");
   assert.equal(await page.locator('#instruments a[href="exact-research.html"]').count(),1,"research tools hub CTA");
   assert.equal(await page.locator("#work.sf-library-invite").count(),1,"owner-curated full research library invitation");
   assert.equal(await page.locator('#work a[href="research.html"]').count(),1,"full research library entry");
   assert.equal(await page.locator('#work a[href="passport.html"]').count(),1,"separate original proof passport entry");
  }
  if(width===390){
    await page.goto(origin+"research.html",{waitUntil:"load"});
    assert.equal(await page.locator(".atlas-card:visible").count(),33,"33 curated research entries");
    await page.locator('[data-atlas-filter="quantum"]').click();
    assert.equal(await page.locator(".atlas-card:visible").count(),4,"four distinct quantum source entries");
    await page.locator('[data-atlas-filter="all"]').click();
    await page.locator("#atlas-search").fill("SourceBound evidence prototype");
    assert.equal(await page.locator(".atlas-card:visible").count(),1,"library source search");
    await page.locator("#atlas-search").fill("");
    assert.equal(await page.locator(".atlas-card:visible").count(),33,"33-entry library filter reset");
    await page.locator("#atlas-evidence").selectOption("conditional");
    assert.equal(await page.locator(".atlas-card:visible").count(),6,"conditional evidence-tier filter");
    await page.locator('[data-atlas-filter="quantum"]').click();
    const intersection=await page.locator(".atlas-card:visible").count();
    assert.ok(intersection>0&&intersection<=6,"combined field and evidence filter");
    await page.locator('[data-atlas-filter="all"]').click();
    await page.locator("#atlas-evidence").selectOption("all");
    assert.equal(await page.locator(".atlas-card:visible").count(),33,"evidence tiers reset");
    await page.locator("body").click({position:{x:5,y:5}});
    await page.keyboard.press("/");
    assert.equal(await page.locator("#atlas-search").evaluate(el=>document.activeElement===el),true,"keyboard search focus");
    await page.locator("#atlas-search").fill("no-such-entry");
    assert.equal(await page.locator(".atlas-card:visible").count(),0,"library empty search");
    await page.keyboard.press("Escape");
    assert.equal(await page.locator(".atlas-card:visible").count(),33,"keyboard search reset");
  }
  if(width===390){
    await page.goto(origin+"referee.html",{waitUntil:"load"});
    assert.equal(await page.locator("#run-overlap").count(),1,"Referee overlap verifier controls");
    assert.equal(await page.locator("#run-sidon").count(),1,"Referee Sidon verifier controls");
    await page.locator("#run-overlap").click();
    assert.match(await page.locator("#result").innerText(),/EXACT MAXIMUM|Finite witness survives|Local evidence remains open/i,"Referee bounded exact overlap result");
    assert.ok((await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth))<=3,"Referee mobile overflow");
  }
  if(width===390){
    await page.goto(origin+"claim-lab.html",{waitUntil:"load"});
    assert.equal(await page.locator(".demoNotice").count(),1,"Claim Lab demo explicitly labeled");
    assert.equal(await page.locator('[data-tab="claims"]').count(),1,"Claim Lab standalone navigation");
    await page.locator("#newClaimBtn").click();
    await page.locator("#claimTitle").fill("Owner storage-preservation fixture");
    await page.locator("#claimStatus").selectOption("3");
    await page.locator("#claimForm button[type=submit]").click();
    await page.locator('[data-tab="audit"]').click();
    const auditText=await page.locator("#content").innerText();
    assert.match(auditText,/Missing artifact reference/,"manual label cannot bypass missing artifact");
    assert.match(auditText,/Missing \/ invalid SHA-256 digest/,"missing digest remains flagged");
    assert.match(auditText,/Proof and checker reference missing/,"missing theorem proof remains flagged");
    const beforeReload=await page.evaluate(()=>localStorage.getItem("nightfall_claim_lab_v1"));
    assert.ok(beforeReload?.includes("Owner storage-preservation fixture"),"saved workspace is in localStorage");
    await page.reload({waitUntil:"load"});
    await page.locator('[data-tab="claims"]').click();
    assert.match(await page.locator("#content").innerText(),/Owner storage-preservation fixture/,"saved claim survives reload");
    assert.equal(await page.evaluate(()=>localStorage.getItem("nightfall_claim_lab_v1")),beforeReload,"reload does not rewrite stored workspace");
    const [backup]=await Promise.all([page.waitForEvent("download"),page.locator("#exportBtn").click()]);
    assert.match(backup.suggestedFilename(),/^NIGHTFALL_claim_lab_backup_.*\.json$/,"downloadable JSON backup");
    assert.ok((await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth))<=3,"Claim Lab mobile overflow");
  }
  if(width===390){
    // Genuine user-directed Referee → Claim Lab → Discovery finite-evidence handoff.
    // Browser prompts explicitly authorize each separate transition.
    await page.goto(origin+"referee.html?domain=sidon",{waitUntil:"load"});
    await page.locator("#run-sidon").click();
    await page.waitForFunction(()=>document.querySelector("#send-claim-lab")?.disabled===false);
    await page.locator("#send-claim-lab").click();
    await page.waitForURL(/claim-lab\.html/);
    // Strict Evidence Bridge v0: no native confirm; a separate read-only preview.
    await page.locator("#bridgeMask").waitFor({state:"visible"});
    assert.match(await page.locator("#bridgeMeta").innerText(),/Scientific review: unreviewed/);
    const beforeReceipt=await page.evaluate(()=>localStorage.getItem("nightfall_claim_lab_v1"));
    assert.equal(await page.locator("#sendDiscovery").isDisabled(),true,"No Discovery handoff before consent");
    const [preReceiptBackup]=await Promise.all([
      page.waitForEvent("download"),page.locator("#bridgeApprove").click()
    ]);
    assert.match(preReceiptBackup.suggestedFilename(),/PRE_BRIDGE/);
    const afterReceipt=await page.evaluate(()=>localStorage.getItem("nightfall_claim_lab_v1"));
    assert.notEqual(afterReceipt,beforeReceipt,"Explicit approval creates one new record");
    const parsedReceipt=JSON.parse(afterReceipt);
    assert.equal(parsedReceipt.experiments.at(-1).status,"tested");
    assert.equal(parsedReceipt.experiments.at(-1).claimId,"","Finite receipt remains unassigned");
    assert.match(parsedReceipt.experiments.at(-1).result,/UNREVIEWED/);
    assert.ok(await page.locator("#sendDiscovery").isEnabled());
    await page.locator("#sendDiscovery").click();
    await page.waitForURL(/discovery\.html/);
    await page.waitForFunction(()=>document.querySelector(".panel.evidence")?.textContent?.includes("LOCAL FINITE REPLAY"),{timeout:20000});
    const finiteLedger=await page.locator(".panel.evidence").first().innerText();
    assert.match(finiteLedger,/LOCAL FINITE REPLAY/,"Discovery distinguishes local replay");
    assert.match(finiteLedger,/INPUT HASH MATCH/,"Discovery records exact source fingerprint");
    assert.match(finiteLedger,/INDEPENDENT REVIEW OPEN/,"No external proof promotion");
    const beforeTamper=await page.evaluate(()=>JSON.parse(localStorage.getItem("nightfall.discovery.v1")).projects.find(p=>p.id==="sidon").runs.length);
    await page.evaluate(()=>{
      const fake={format:"nightfall-referee-receipt-v1",version:"1.0.0",domain:"weak-sidon-4-5-finite",
        source:{points:["1","2","3"],subset:["1","2"]},claimedMaximum:2,
        inputSha256:"0".repeat(64),result:{status:"FINITE_CHECK_PASSED"},
        negativeControls:{understatedMaximumRejected:true,corruptedSubsetRejected:true},
        verdict:"FINITE_CHECK_PASSED"};
      sessionStorage.setItem("nightfall.discovery.pending.v1",JSON.stringify(fake));
    });
    await page.goto(origin+"discovery.html?referee_handoff=1",{waitUntil:"load"});
    await page.waitForFunction(()=>document.querySelector("#toast")?.textContent?.includes("rejected"));
    const afterTamper=await page.evaluate(()=>JSON.parse(localStorage.getItem("nightfall.discovery.v1")).projects.find(p=>p.id==="sidon").runs.length);
    assert.equal(afterTamper,beforeTamper,"Forged input SHA-256 must never create a research run");
  }
  if(width===390){
    await page.goto(origin+"agenda.html",{waitUntil:"load"});
    assert.equal(await page.locator("#agenda-list .research-proposal:visible").count(),10,"ten proposals");
    for(const cat of ["mathematics","quantum","super-intelligence","safety","systems"]){
      await page.locator('[data-agenda-filter="'+cat+'"]').click();
      assert.equal(await page.locator("#agenda-list .research-proposal:visible").count(),2,cat+" has two proposed studies");
    }
    await page.locator('[data-agenda-filter="all"]').click();
    await page.locator("#agenda-search").fill("SourceBound");
    assert.equal(await page.locator("#agenda-list .research-proposal:visible").count(),1,"SourceBound search");
    await page.locator("#agenda-search").fill("");
    assert.equal(await page.locator("#agenda-list .research-proposal:visible").count(),10,"agenda search reset");
  }
  if(width===390 || width===1280){
    await page.goto(origin+"passport.html?claim=outdated-claim-id",{waitUntil:"load"});
    assert.equal(await page.locator("#passport-unknown").isVisible(),true,"Unknown proof claim explicitly reported");
    assert.match(await page.locator("#passport-unknown").innerText(),/outdated-claim-id/,"Stale claim identifier shown for diagnosis");
    assert.match(await page.locator("#passport-title").innerText(),/Sidon/i,"Default example is disclosed");
    assert.equal(new URL(page.url()).searchParams.get("claim"),"outdated-claim-id","Stale link remains diagnosable");
    await page.locator("#passport-picker a[href='passport.html?claim=werner']").click();
    assert.equal(await page.locator("#passport-unknown").isVisible(),false,"Valid Passport clears warning");
    assert.match(await page.locator(".pp-coverage").innerText(),/Six canonical Proof Passports, 33 research dossiers/,"Passports explain editorial coverage");
    await page.goto(origin+"index.html",{waitUntil:"load"});
    assert.equal(await page.locator("#lab-jump-nav a").count(),7,"Long laboratory has seven topical jumps");
    assert.equal(await page.locator(".flagship-context").count(),4,"Each flagship explains meaning of headline metric");
    assert.match(await page.locator(".flagship-context").first().innerText(),/maximum overlap/i,"Numerical extremal value interpreted");
    await page.locator('#lab-jump-nav a[href="#research-systems"]').click();
    assert.equal(new URL(page.url()).hash,"#research-systems","Section-index jump works");
    await page.goto(origin+"research.html",{waitUntil:"load"});
    assert.match(await page.locator(".archive-coverage").innerText(),/Thirty-three dossiers.*Six claim passports.*Three original findings/s,"Library explains record hierarchy");
    await page.goto(origin+"atlas.html",{waitUntil:"load"});
    assert.match(await page.locator(".rs-coverage").innerText(),/six claims represent a library of 33 documents/i,"Atlas explains limited canonical graph");
  }
  if(width===390 || width===1280){
    await page.goto(origin+"desk.html?claim=phase",{waitUntil:"load"});
    assert.equal(await page.locator(".desk-claim-button").count(),6,"Six canonical research claims visible");
    assert.match(await page.locator(".desk-detail-heading").innerText(),/finite-field reconstruction/i,"Deep link selects finite-field claim");
    assert.equal(await page.locator(".desk-dimension").count(),4,"Four independently scoped evidence dimensions");
    await page.locator("#desk-filter").selectOption("conditional");
    assert.equal(await page.locator(".desk-claim-button").count(),2,"Conditional proof claims separated");
    await page.locator("#desk-filter").selectOption("all");
    await page.locator("#desk-search").fill("Werner");
    assert.equal(await page.locator(".desk-claim-button").count(),1,"Title search filters");
    await page.locator("#desk-search").fill("");
    await page.locator(".desk-open-row .desk-add").first().click();
    assert.match(await page.locator("#desk-count").innerText(),/1 step/,"Open obligation pinned");
    assert.equal(await page.locator("#desk-session-shortcut").isVisible(),true,"Selected task exposes quick session jump");
    assert.match(await page.locator("#desk-session-shortcut").innerText(),/1 selected check/,"Quick jump counts selected tasks");
    await page.locator("#desk-session-shortcut").click();
    assert.equal(new URL(page.url()).hash,"#session","Quick jump moves to session anchor");
    await page.locator("#desk-notes").fill("Check a source lemma with a second proof path.");
    await page.reload({waitUntil:"load"});
    assert.equal(await page.locator(".desk-queue-row").count(),1,"Local session queue survives reload");
    assert.match(await page.locator("#desk-notes").inputValue(),/second proof path/,"Session notes persist");
    assert.match(await page.locator(".desk-detail-heading").innerText(),/finite-field reconstruction/i,"Deep link remains selected");
    await page.locator(".desk-queue-row input[type=checkbox]").check();
    assert.match(await page.locator("#desk-count").innerText(),/1 marked complete/,"Local completion only");
    const [handoff]=await Promise.all([page.waitForEvent("download"),page.locator("#desk-export-md").click()]);
    assert.equal(handoff.suggestedFilename(),"NIGHTFALL_research_session.md","Markdown research handoff");
    const [receipt]=await Promise.all([page.waitForEvent("download"),page.locator("#desk-export-json").click()]);
    assert.equal(receipt.suggestedFilename(),"NIGHTFALL_research_session.json","Portable JSON session");
    page.once("dialog",dialog=>dialog.accept());
    await page.locator("#desk-clear").click();
    assert.equal(await page.locator(".desk-queue-row").count(),0,"Explicit local session clearing");
    assert.equal(await page.locator("#desk-session-shortcut").isVisible(),false,"Session shortcut hides with an empty queue");
    assert.ok((await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth))<=3,"Research Desk fits viewport");
  }
  if(width===390 || width===1280){
    await page.goto(origin+"exact-research.html#guided-replay",{waitUntil:"load"});
    assert.equal(await page.locator("#guided-replay .rt-stage").count(),4,"Four-stage claim-to-replay journey");
    assert.match(await page.locator("#guided-replay").innerText(),/30-POINT SIDON/,"Original finite scope remains visible");
    assert.ok((await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth))<=3,"Guided research journey fits viewport");
    await page.locator('#guided-replay a[href="referee.html?domain=sidon#workbench"]').first().click();
    await page.waitForURL(/referee\.html\?domain=sidon/);
    assert.equal(await page.locator("#tab-sidon").getAttribute("aria-selected"),"true","Guided replay selects Sidon domain");
    assert.equal(await page.locator("#pane-sidon").isVisible(),true,"Sidon witness editor visible");
    assert.equal(await page.locator("#run-sidon").count(),1,"Witness verifier available");
    await page.goto(origin+"referee.html?domain=unexpected",{waitUntil:"load"});
    assert.equal(await page.locator("#tab-overlap").getAttribute("aria-selected"),"true","Unrecognized domain does not affect default selection");
  }
  if(width===390 || width===1280){
    await page.goto(origin+"exact-research.html",{waitUntil:"load"});
    await page.locator("#sharpness-run").click();
    await page.waitForFunction(()=>document.querySelector("#sharpness-output")?.textContent?.includes("FINITE_EXAMPLE_CHECK_PASSED"));
    assert.match(await page.locator("#sharpness-output").innerText(),/40,920 checked/,"All 33-point four-mark strict difference checks");
    assert.match(await page.locator("#sharpness-output").innerText(),/h\(B ∪ X\) = 19/,"Correct exact sharpness witness bound");
    const [sharpnessReceipt]=await Promise.all([page.waitForEvent("download"),page.locator("#sharpness-export").click()]);
    assert.equal(sharpnessReceipt.suggestedFilename(),"NIGHTFALL_SIDON_SHARPNESS_RECEIPT.json","Evidence scope receipt exported");
    await page.locator("#sharpness-offset").fill("0");
    await page.locator("#sharpness-run").click();
    await page.waitForFunction(()=>document.querySelector("#sharpness-output")?.textContent?.includes("NO_CERTIFICATE_FOR_SELECTED_INPUT"));
    assert.match(await page.locator("#sharpness-output").innerText(),/\(4,5\) four-point condition: FAIL/,"Negative control rejects invalid offset");
    await page.locator("#sharpness-reset").click();
    assert.equal(await page.locator("#sharpness-export").isDisabled(),true,"Reset clears prior evidence");
    await page.locator("#werner-run").click();
    assert.ok((await page.locator("#werner-output").innerText()).includes('"qExact": "-3/16"'),"Rank-three obstruction exact value");
    assert.match(await page.locator("#werner-output").innerText(),/"rankAtMostTwo": false/,"Rank-three scope fence");
    await page.locator("#werner-rank2").click();
    assert.ok((await page.locator("#werner-output").innerText()).includes('"qExact": "7/2"'),"Rank-two Lemnis physical form");
    const [wm]=await Promise.all([page.waitForEvent("download"),page.locator("#werner-export").click()]);
    assert.equal(wm.suggestedFilename(),"NIGHTFALL_werner_exact_receipt.json","Portable exact Werner receipt");
    await page.locator("#field-run").click();
    assert.match(await page.locator("#field-output").innerText(),/"phaseOrbits": 4/,"F25 independent phase ambiguity");
    await page.locator("#field-ambiguous").click();
    assert.match(await page.locator("#field-output").innerText(),/"phaseOrbits": 157/,"Zero-information adversarial control");
    await page.locator("#werner-input").fill("invalid-json");
    await page.locator("#werner-run").click();
    assert.match(await page.locator("#werner-output").innerText(),/Input rejected/,"Malformed witness rejected");
    assert.equal(await page.locator("#werner-export").isDisabled(),true,"Invalid input cannot export stale certificate");
    assert.ok((await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth))<=3,"Exact workbench overflow");
  }
  assert.deepEqual(faults,[],"Browser failures at "+width+": "+faults.join("; "));
  await page.close();
 }
 console.log("PASS: 3 original-portfolio pages plus Discovery Engine × 3 widths, exact experiment and ZIP export");
}finally{
 await browser?.close();
 await new Promise(resolve=>server.close(resolve));
}
