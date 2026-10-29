import assert from "node:assert/strict";
import {createServer} from "node:http";
import {readFile} from "node:fs/promises";
import {join,normalize,resolve,sep} from "node:path";
import {chromium} from "playwright-core";

const root=resolve("docs");
const pages=["index.html","review.html","evidence.html","agenda.html","research.html","exact-research.html","desk.html"];
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
   assert.match(await page.locator(".ticker").innerText(),/32/,"homepage current library count");
   assert.equal(await page.locator("#instruments .instrument-workflow span").count(),4,"four instrument workflow stages");
   assert.equal(await page.locator('#instruments a[href="exact-research.html"]').count(),1,"research tools hub CTA");
   assert.equal(await page.locator("#work.sf-library-invite").count(),1,"owner-curated full research library invitation");
   assert.equal(await page.locator('#work a[href="research.html"]').count(),1,"full research library entry");
   assert.equal(await page.locator('#work a[href="passport.html"]').count(),1,"separate original proof passport entry");
  }
  if(width===390){
    await page.goto(origin+"research.html",{waitUntil:"load"});
    assert.equal(await page.locator(".atlas-card:visible").count(),32,"32 owner-curated research entries");
    await page.locator('[data-atlas-filter="quantum"]').click();
    assert.equal(await page.locator(".atlas-card:visible").count(),4,"four distinct quantum source entries");
    await page.locator('[data-atlas-filter="all"]').click();
    await page.locator("#atlas-search").fill("SourceBound evidence prototype");
    assert.equal(await page.locator(".atlas-card:visible").count(),1,"library source search");
    await page.locator("#atlas-search").fill("");
    assert.equal(await page.locator(".atlas-card:visible").count(),32,"32-entry library filter reset");
    await page.locator("#atlas-evidence").selectOption("conditional");
    assert.equal(await page.locator(".atlas-card:visible").count(),6,"conditional evidence-tier filter");
    await page.locator('[data-atlas-filter="quantum"]').click();
    const intersection=await page.locator(".atlas-card:visible").count();
    assert.ok(intersection>0&&intersection<=6,"combined field and evidence filter");
    await page.locator('[data-atlas-filter="all"]').click();
    await page.locator("#atlas-evidence").selectOption("all");
    assert.equal(await page.locator(".atlas-card:visible").count(),32,"evidence tiers reset");
    await page.locator("body").click({position:{x:5,y:5}});
    await page.keyboard.press("/");
    assert.equal(await page.locator("#atlas-search").evaluate(el=>document.activeElement===el),true,"keyboard search focus");
    await page.locator("#atlas-search").fill("no-such-entry");
    assert.equal(await page.locator(".atlas-card:visible").count(),0,"library empty search");
    await page.keyboard.press("Escape");
    assert.equal(await page.locator(".atlas-card:visible").count(),32,"keyboard search reset");
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
    await page.goto(origin+"desk.html?claim=phase",{waitUntil:"load"});
    assert.equal(await page.locator(".desk-claim-button").count(),5,"Five canonical research claims visible");
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
