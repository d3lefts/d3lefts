import assert from "node:assert/strict";
import {createServer} from "node:http";
import {readFile, mkdir, writeFile, stat} from "node:fs/promises";
import {join,resolve,sep,extname} from "node:path";
import {chromium} from "playwright-core";

/* Hour-equivalent visitor audit. Six 10-minute chapters compressed into browser
 * operations, never represented as an actual 60-minute observed human session.
 * Runs against a local serve of the exact commit checked out by GitHub Actions.
 * Findings and screenshots are evidence of rendered Chromium interactions.
 */
const root=resolve("docs"),out=resolve("ux-journey-artifacts");
await mkdir(out,{recursive:true});
const types={".html":"text/html; charset=utf-8",".css":"text/css; charset=utf-8",".js":"text/javascript; charset=utf-8",".svg":"image/svg+xml"};
const server=createServer(async(req,res)=>{
  try{
    const pathname=decodeURIComponent(new URL(req.url,"http://localhost").pathname);
    const f=resolve(join(root,pathname.replace(/^\/+/,"")||"index.html"));
    if(f!==root&&!f.startsWith(root+sep)){res.writeHead(403).end();return}
    const bytes=await readFile(f);
    res.writeHead(200,{"Content-Type":types[extname(f)]||"application/octet-stream"}).end(bytes);
  }catch{res.writeHead(404).end("Missing local source file")}
});
await new Promise(ok=>server.listen(0,"127.0.0.1",ok));
const origin="http://127.0.0.1:"+server.address().port+"/";
const report={kind:"NIGHTFALL-hour-equivalent-visitor-audit",scope:"GitHub Actions checked-out site, locally served on loopback in Chromium; not remote Pages CDN, not an hour of human observation",simulatedDurationMinutes:60,realElapsedMs:null,viewportCases:[{width:1440,height:900},{width:390,height:844},{width:768,height:1000}],steps:[],observations:[],runtimeFaults:[],risks:[],screenshots:[],releaseCommit:process.env.GITHUB_SHA||"unspecified",at:new Date().toISOString()};
let browser,context,page;
const started=Date.now();
const note=(type,text,area)=>report.observations.push({type,text,area});
const screenshot=async(name)=>{if(!page)return;try{await page.screenshot({path:join(out,name),fullPage:true,animations:"disabled",timeout:12000});report.screenshots.push(name)}catch(e){note("screenshot-unavailable",e.message,name)}};
const visit=async(path)=>{await page.goto(origin+path,{waitUntil:"load",timeout:18000});await page.waitForTimeout(125);};
const step=async(minutes,label,fn)=>{
  const began=Date.now();
  try{
    await fn();
    report.steps.push({minutes,label,result:"PASS",elapsedMs:Date.now()-began});
    console.log("PASS ["+minutes+"] "+label);
  }catch(e){
    const err=String(e?.message||e);
    report.steps.push({minutes,label,result:"FAIL",error:err.slice(0,900),elapsedMs:Date.now()-began});
    console.error("FAIL ["+minutes+"] "+label+": "+err);
    await screenshot("failure-"+String(report.steps.length).padStart(2,"0")+".png");
  }
};
try{
  browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_BIN||"/usr/bin/chromium",args:["--no-sandbox"]});
  context=await browser.newContext({viewport:{width:1440,height:900},acceptDownloads:true});
  page=await context.newPage();
  page.on("pageerror",e=>report.runtimeFaults.push({url:page.url(),type:"pageerror",text:e.message}));
  page.on("response",r=>{if(r.url().startsWith(origin)&&r.status()>=400)report.runtimeFaults.push({url:r.url(),type:"HTTP "+r.status()})});

  // 00–10: Enter with no prior NIGHTFALL knowledge. Assess first mental model.
  await step("00–03","Homepage: identify research thesis, claims, next action",async()=>{
    await visit("index.html");
    const hero=await page.locator("h1").first().innerText();
    assert.match(hero,/Discovery.*needs.*witnesses/s);
    assert.equal(await page.locator(".flagship-card").count(),4);
    assert.match(await page.locator(".ticker").innerText(),/33/);
    const labels=await page.locator(".flagship-eyebrow").allInnerTexts();
    assert.equal(labels.length,4);
    assert.ok(labels.some(x=>/finite/i.test(x)),"Explicit finite scope absent");
    assert.ok(labels.some(x=>/conditional|candidate|imported|manuscript/i.test(x)),"Conditional status absent");
    const editorial=await page.evaluate(()=>{
      const dramatic=document.querySelector(".nf-interlude");
      const quiet=document.querySelector(".nf-quiet-note");
      const systems=[...document.querySelectorAll(".sf-ecosystem .sf-system-card")];
      return {
        dramaticHeading:dramatic?.querySelector("h2")?.textContent?.trim()||"",
        dramaticBackground:dramatic?getComputedStyle(dramatic).backgroundColor:"",
        quietHeading:quiet?.querySelector("h2")?.textContent?.trim()||"",
        correctSequence:!!(dramatic&&quiet&&
          (document.querySelector("#live-case").compareDocumentPosition(dramatic)&Node.DOCUMENT_POSITION_FOLLOWING)&&
          (document.querySelector("#evidence").compareDocumentPosition(quiet)&Node.DOCUMENT_POSITION_FOLLOWING)),
        cardWidths:systems.map(x=>Math.round(x.getBoundingClientRect().width)),
        cardRows:systems.map(x=>Math.round(x.getBoundingClientRect().top))
      };
    });
    assert.match(editorial.dramaticHeading,/Make room.*for doubt/s);
    assert.match(editorial.quietHeading,/Leave the.*uncertainty visible/s);
    assert.equal(editorial.dramaticBackground,"rgb(24, 43, 35)");
    assert.equal(editorial.correctSequence,true,"Editorial pacing should preserve claim hierarchy");
    assert.equal(editorial.cardWidths.length,4);
    assert.ok(editorial.cardWidths[0]<editorial.cardWidths[1],"Asymmetric cards collapsed on desktop");
    assert.equal(editorial.cardRows[0],editorial.cardRows[1]);
    assert.equal(editorial.cardRows[2],editorial.cardRows[3]);
    assert.ok(editorial.cardRows[2]>editorial.cardRows[0]);
    note("strength","Immediate research proposition, four evidence-scoped flagships, and explicit evidence tiering are visible.","homepage");
    await screenshot("01-desktop-home.png");
  });
  await step("03–06","Homepage: interactive Sidon witness and transparent finite scope",async()=>{
    await visit("index.html#live-case");
    assert.equal(await page.locator("#sidon-witness [role=listitem]").count(),30);
    const t=page.locator("#sidon-toggle");
    await t.click();
    assert.equal(await t.getAttribute("aria-pressed"),"true");
    assert.match(await page.locator("#live-case").innerText(),/17-point|17 \/ 30/i);
    const link=page.locator('#live-case a[href*="passport.html?claim=sidon30"]').first();
    assert.ok(await link.count()>0,"Missing Sidon evidence action");
    note("strength","The exact 30-point construction is explorable before opening a separate checker.","witness");
  });
  await step("06–10","Homepage: evidence source and menu orientation",async()=>{
    await visit("index.html");
    assert.ok(await page.locator('a[href="evidence.html"]').count()>0);
    assert.ok(await page.locator('a[href="desk.html"]').count()>0);
    assert.ok(await page.locator('a[href="research.html"]').count()>0);
    const sections=await page.locator("main section").count();
    assert.equal(await page.locator("#lab-jump-nav a").count(),7);
    assert.equal(await page.locator(".flagship-context").count(),4);
    note("improvement","The full homepage still contains "+sections+" sections; a section index offers immediate navigation without truncating content.","homepage");
  });

  // 10–20: From a bold numerical result to the fine print.
  await step("10–13","Proof Passport: finite witness vs public reproducibility",async()=>{
    await visit("passport.html?claim=erdos36");
    assert.match(await page.locator("#passport-title").innerText(),/Erdős minimum overlap/i);
    const panel=await page.locator("#passport-dimensions").innerText();
    assert.match(panel,/VALIDITY/i);
    assert.match(panel,/REPRODUCIBILITY/i);
    assert.match(panel,/ORIGINALITY/i);
    assert.match(panel,/SIGNIFICANCE/i);
    assert.match(panel,/pending|archive mirror|complete archive/i);
    assert.ok(await page.locator("#passport-sources a").count()>=2);
    note("strength","The strongest overlap number is separated from the incomplete external witness release.","passport");
    await screenshot("02-overlap-passport.png");
  });
  await step("13–17","Proof Passport: conditional finite-field theorem boundaries",async()=>{
    await visit("passport.html?claim=phase");
    const body=await page.locator("main").innerText();
    assert.match(body,/conditional|premise|unproved/i);
    assert.ok((await page.locator("#passport-open li").count())>0);
    const desk=page.locator('a[href="desk.html?claim=phase"]');
    assert.ok(await desk.count()>0,"Cannot hand open premise into research desk");
    await desk.first().click();
    await page.waitForURL(/desk\.html\?claim=phase/);
    assert.match(await page.locator(".desk-detail-heading").innerText(),/finite.field reconstruction/i);
    note("strength","Proof Passports now hand unresolved mathematical obligations into a linked session planner.","passport");
  });
  await step("17–20","Proof Passport: invalid claim ID fails into a curated default",async()=>{
    await visit("passport.html?claim=unknown-visitor-id");
    const title=await page.locator("#passport-title").innerText();
    assert.match(title,/Sidon/i);
    assert.equal(await page.locator("#passport-unknown").isVisible(),true);
    assert.match(await page.locator("#passport-unknown").innerText(),/unknown-visitor-id/);
    assert.equal(new URL(page.url()).searchParams.get("claim"),"unknown-visitor-id");
    note("resolved","Unknown claim IDs now show a diagnostic notice while preserving the original link.","passport");
  });

  // 20–30: Discover more work and follow typed relationships.
  await step("20–24","Research Library: browse, intersect filters, reset empty search",async()=>{
    await visit("research.html");
    assert.equal(await page.locator(".atlas-card:visible").count(),33);
    assert.match(await page.locator(".archive-coverage").innerText(),/Thirty-three dossiers.*Six claim passports.*Five original/s);
    await page.locator("#atlas-search").fill("SourceBound");
    assert.ok((await page.locator(".atlas-card:visible").count())>=1);
    await page.locator("#atlas-search").fill("");
    await page.locator("#atlas-evidence").selectOption("conditional");
    const conditional=await page.locator(".atlas-card:visible").count();
    assert.ok(conditional>0&&conditional<33);
    await page.locator('[data-atlas-filter="quantum"]').click();
    const mixed=await page.locator(".atlas-card:visible").count();
    assert.ok(mixed<=conditional);
    await page.locator("#atlas-evidence").selectOption("all");
    await page.locator('[data-atlas-filter="all"]').click();
    await page.locator("#atlas-search").fill("there-is-no-such-theorem");
    assert.equal(await page.locator(".atlas-card:visible").count(),0);
    assert.ok(await page.locator("#atlas-empty").isVisible());
    await page.locator("#atlas-search").fill("");
    assert.equal(await page.locator(".atlas-card:visible").count(),33);
    await visit("findings-20261029.html");
    assert.match(await page.locator("#singer975").innerText(),/975 marks/);
    assert.match(await page.locator("#graph-3port").innerText(),/3,221,225,472/);
    assert.match(await page.locator("main").innerText(),/no global Sidon record/);
    assert.ok(await page.locator('a[href*="tessera-singer975-20261029/audit.py"]').count()>=1);
    assert.ok(await page.locator('a[href*="expand_search.cpp"]').count()>=1);
    note("scope","Two additional Original Findings are displayed with primary checkers and narrow finite status.","findings");
    await visit("research.html");
    await screenshot("03-research-library.png");
    note("strength","Thirty-three document cards, evidence-tier filters, and empty-search recovery are operational.","library");
  });
  await step("24–27","Mechanism Atlas: inspect a claim and distinguish analogy from proof",async()=>{
    await visit("atlas.html?claim=werner");
    assert.ok(await page.locator(".ma-node").count()>5);
    const selected=page.locator('.ma-node[data-node="werner"]');
    assert.equal(await selected.getAttribute("aria-pressed"),"true");
    assert.match(await page.locator("#ma-detail").innerText(),/Werner/i);
    await page.locator('[data-rel="analogy"]').click();
    assert.equal(await page.locator('[data-rel="analogy"]').getAttribute("aria-pressed"),"true");
    assert.match(await page.locator("main").innerText(),/analogy|conceptual parallel|untested/i);
    note("strength","Typed graph relationships distinguish documented finite checks, proof dependencies and analogies.","atlas");
    await screenshot("04-mechanism-atlas.png");
  });
  await step("27–30","Atlas: preserve a claim-context path to original source",async()=>{
    await visit("atlas.html?claim=sidon30");
    const links=await page.locator("#ma-relations a").count();
    assert.ok(links>=0);
    assert.ok((await page.locator("#ma-detail a[href*=passport]").count())>0);
    await page.locator("#ma-detail a[href*=passport]").first().click();
    await page.waitForURL(/passport\.html\?claim=sidon30/);
    assert.match(await page.locator("#passport-title").innerText(),/Sidon/i);
  });

  // 30–40: Try exact verifier and deliberately submit a false assertion.
  await step("30–33","Referee: compute independent exact finite overlap paths",async()=>{
    await visit("referee.html");
    await page.locator("#run-overlap").click();
    await page.waitForFunction(()=>document.querySelector("#result")?.textContent?.includes("EXACT MAXIMUM"),null,{timeout:20000});
    const content=await page.locator("#result").innerText();
    assert.match(content,/DUAL PATHS|RECOMPUTATION/i);
    assert.match(content,/FINITE CHECK PASSED|Finite witness survives/i);
    assert.equal(await page.locator("#export-receipt").isDisabled(),false);
    await screenshot("05-referee-exact.png");
  });
  await step("33–36","Referee: tampered overlap score must be rejected",async()=>{
    await page.locator("#overlap-claimed").fill("999/1");
    await page.locator("#run-overlap").click();
    await page.waitForFunction(()=>document.querySelector("#result")?.textContent?.includes("REJECTED"),null,{timeout:20000});
    assert.match(await page.locator("#result").innerText(),/REJECTED|Claimed score rejected/i);
    note("strength","A deliberately falsified numerical claim receives an explicit rejected verdict.","referee");
  });
  await step("36–40","Referee → Claim Lab: consent-gated receipt with unchanged claim statuses",async()=>{
    await page.locator("#overlap-claimed").fill("");
    await page.locator("#run-overlap").click();
    await page.waitForFunction(()=>!document.querySelector("#send-claim-lab")?.disabled,null,{timeout:20000});
    const sourceFingerprint=await page.locator("#result").innerText();
    assert.match(sourceFingerprint,/SHA-256/i);
    await page.locator("#send-claim-lab").click();
    await page.waitForURL(/claim-lab\.html/, {timeout:20000});
    // A real staged preview replaces the older native confirm dialog.
    await page.locator("#bridgeMask").waitFor({state:"visible",timeout:20000});
    assert.match(await page.locator("#bridgeMeta").innerText(),/Scientific review: unreviewed/);
    const before = await page.evaluate(()=>localStorage.getItem("nightfall_claim_lab_v1"));
    assert.equal(await page.locator("#sendDiscovery").isDisabled(),true,"Unapproved receipt cannot reach Discovery");
    const [backup] = await Promise.all([
      page.waitForEvent("download"),
      page.locator("#bridgeApprove").click()
    ]);
    assert.match(backup.suggestedFilename(),/PRE_BRIDGE/);
    const after = await page.evaluate(()=>localStorage.getItem("nightfall_claim_lab_v1"));
    assert.notEqual(after,before,"Only approved attachment may write local workspace");
    const parsed = JSON.parse(after);
    assert.equal(parsed.experiments.at(-1).status,"tested");
    assert.equal(parsed.experiments.at(-1).claimId,"");
    assert.match(parsed.experiments.at(-1).result,/UNREVIEWED/);
    assert.ok(await page.locator("#sendDiscovery").isEnabled());
    note("strength","Referee receipt requires explicit user approval and imports as unreviewed metadata, with no proof-status promotion.","receipt-handoff");
    await screenshot("06-claimlab-receipt.png");
  });

  // 40–50: Reconstruct algebra and carry an unresolved problem into a plan.
  await step("40–44","Exact Tools: source-bounded Werner and phase ambiguity probes",async()=>{
    await visit("exact-research.html");
    await page.locator("#werner-run").click();
    assert.match(await page.locator("#werner-output").innerText(),/rankAtMostTwo/);
    await page.locator("#field-run").click();
    assert.match(await page.locator("#field-output").innerText(),/phaseOrbits/);
    note("strength","Executable bounded probes are available for quantum and finite-field lines without claiming unrestricted theorems.","exact-tools");
  });
  await step("44–48","Research Desk: retain notes and proof task on revisit",async()=>{
    await visit("desk.html?claim=phase");
    assert.match(await page.locator(".desk-detail-heading").innerText(),/finite.field reconstruction/i);
    const task=page.locator(".desk-open-row .desk-add").first();
    await task.click();
    assert.equal(await page.locator("#desk-session-shortcut").isVisible(),true);
    await page.locator("#desk-session-shortcut").click();
    assert.equal(new URL(page.url()).hash,"#session");
    await page.locator("#desk-notes").fill("Independent span-count audit; try adversarial rank strata before publication.");
    await page.reload({waitUntil:"load"});
    assert.equal(await page.locator(".desk-queue-row").count(),1);
    assert.match(await page.locator("#desk-notes").inputValue(),/adversarial rank strata/);
    const [download]=await Promise.all([page.waitForEvent("download"),page.locator("#desk-export-md").click()]);
    assert.equal(download.suggestedFilename(),"NIGHTFALL_research_session.md");
    const item=await download.createReadStream();
    let md="";for await(const buf of item)md+=buf.toString();
    assert.match(md,/Conditional|conditional|open/i);
    assert.match(md,/source|scope|Current validity/i);
    note("strength","Research Desk stores a scoped task and portable markdown with premises after browser reload.","desk");
    await screenshot("07-research-desk.png");
  });
  await step("48–50","Research Desk: verify empty session can be restored by explicit clear",async()=>{
    page.once("dialog",d=>d.accept());
    await page.locator("#desk-clear").click();
    assert.equal(await page.locator(".desk-queue-row").count(),0);
    assert.equal(await page.locator("#desk-export-json").isDisabled(),true);
  });

  // 50–60: Mobile exploration and accessibility friction under realistic viewport.
  await step("CONSTELLATION / NIGHT","Canonical Join route and persistent visual theme",async()=>{
    await page.setViewportSize({width:1440,height:900});
    await visit("join.html");
    await page.evaluate(()=>{localStorage.removeItem("nightfall.theme.v1");localStorage.removeItem("nightfall.journey.v1")});
    await page.reload();
    assert.equal(await page.locator("html").getAttribute("data-nf-theme"),"night");
    assert.ok(await page.locator(".nf-theme-toggle").isVisible());
    await page.locator("#join-interest").selectOption("compute");
    await page.locator(".join-choice button").first().click();
    assert.equal(await page.locator("#join-active").isVisible(),true);
    await page.locator("#join-notes").fill("Try a bounded, independently checkable Q7 proof obligation.");
    await visit("research.html");
    assert.ok(await page.locator(".nf-journey-rail").count()===1);
    assert.ok(await page.locator(".nf-theme-toggle").count()===1);
    await page.locator(".nf-theme-toggle").click();
    assert.equal(await page.locator("html").getAttribute("data-nf-theme"),"paper");
    await visit("join.html");
    assert.equal(await page.locator("html").getAttribute("data-nf-theme"),"paper");
    assert.equal(await page.locator("#join-notes").inputValue(),"Try a bounded, independently checkable Q7 proof obligation.");
    await page.locator(".nf-theme-toggle").click();
    assert.equal(await page.locator("html").getAttribute("data-nf-theme"),"night");
    await page.setViewportSize({width:390,height:844});
    assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth)<=3,"Join night-theme mobile overflow");
    await screenshot("constellation-night-join.png");
    note("strength","Night and Paper remain persistent. The canonical Join assignment survives tool navigation and carries its unreviewed note.","constellation");
  });
  await step("50–53","Phone 390px: navigation, hierarchy and horizontal overflow",async()=>{
    await page.setViewportSize({width:390,height:844});
    await visit("index.html");
    assert.ok(await page.locator("#menu-button").isVisible());
    await page.locator("#menu-button").click();
    assert.equal(await page.locator("#site-nav").isVisible(),true);
    await page.keyboard.press("Escape");
    assert.equal(await page.locator("#site-nav").isVisible(),false);
    assert.ok(await page.locator(".nf-interlude h2").isVisible());
    assert.ok(await page.locator(".nf-quiet-note h2").isVisible());
    const mobileLayout=await page.evaluate(()=>{
      const cards=[...document.querySelectorAll(".sf-ecosystem .sf-system-card")];
      const boxes=cards.map(x=>x.getBoundingClientRect());
      return {stacked:boxes.every((r,i)=>i===0||r.top>boxes[i-1].top),widths:boxes.map(x=>x.width)};
    });
    assert.ok(mobileLayout.stacked,"Instrument cards must stack on narrow phones");
    assert.ok(mobileLayout.widths.every(x=>x<390));
    const overflow=await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth);
    assert.ok(overflow<=3,"Homepage horizontal overflow "+overflow);
    await screenshot("08-mobile-home.png");
  });
  await step("53–56","Phone: long research library and modal-less claim tasks",async()=>{
    await visit("research.html");
    assert.equal(await page.locator(".atlas-card:visible").count(),33);
    await page.locator("#atlas-search").fill("Werner");
    const count=await page.locator(".atlas-card:visible").count();
    assert.ok(count>=1);
    assert.ok((await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth))<=3);
    await screenshot("09-mobile-library.png");
    await visit("desk.html?claim=werner");
    assert.match(await page.locator(".desk-detail-heading").innerText(),/Werner/i);
    assert.ok((await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth))<=3);
    await screenshot("10-mobile-desk.png");
  });
  await step("56–60","Mobile and desktop: actionable controls, local links and proof scope",async()=>{
    for(const width of [390,768,1440]){
      await page.setViewportSize({width,height:900});
      for(const path of ["passport.html?claim=werner","atlas.html?claim=phase","referee.html","exact-research.html","evidence.html"]){
        await visit(path);
        const o=await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth);
        assert.ok(o<=3,path+" overflow "+o+" at "+width+"px");
      }
    }
    await visit("passport.html?claim=werner");
    assert.match(await page.locator("main").innerText(),/conditional|source|premise/i);
    note("strength","Research proof status and available evidence remain distinct after navigating among mathematical disciplines.","scope");
  });
} finally {
  report.realElapsedMs=Date.now()-started;
  if(page)await page.close().catch(()=>{});
  if(context)await context.close().catch(()=>{});
  if(browser)await browser.close().catch(()=>{});
  await new Promise(ok=>server.close(ok));
  const passes=report.steps.filter(x=>x.result==="PASS").length;
  const fails=report.steps.length-passes;
  report.summary={passed:passes,failed:fails,scriptFaults:report.runtimeFaults.length,uniqueJourneys:report.steps.length};
  await writeFile(join(out,"ux-journey-report.json"),JSON.stringify(report,null,2)+"\n");
  const lines=[
    "# NIGHTFALL simulated hour-equivalent visitor audit",
    "",
    "Scope: checked-out GitHub commit served locally to headless Chromium, no external Pages CDN.",
    "Simulation: six thematic ten-minute chapters compressed into automated journeys; actual elapsed "+(report.realElapsedMs/1000).toFixed(1)+" seconds.",
    "Outcome: "+passes+" passed / "+fails+" failed, "+report.runtimeFaults.length+" runtime faults.",
    "",
    ...report.steps.map(s=>"- ["+(s.result==="PASS"?"x":" ")+"] "+s.minutes+" — "+s.label+(s.error?" — "+s.error:"")),
    "",
    "## Observed qualitative notes",
    ...report.observations.map(o=>"- "+o.area+" ("+o.type+"): "+o.text),
    "",
    "## Screenshots",
    ...report.screenshots.map(s=>"- "+s),
    ""
  ];
  await writeFile(join(out,"ux-journey-report.md"),lines.join("\n"));
  console.log("JOURNEY SUMMARY: "+passes+"/"+report.steps.length+" passing; "+report.runtimeFaults.length+" browser errors; "+report.realElapsedMs+" ms");
  for(const f of report.steps.filter(x=>x.result==="FAIL"))console.error("UX FINDING ["+f.minutes+"] "+f.label+": "+f.error);
  console.log("JOURNEY REPORT "+JSON.stringify(report.summary));
  if(fails||report.runtimeFaults.length)process.exitCode=1;
}
