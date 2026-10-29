/* Browser acceptance test for NIGHTFALL's opt-in ethereal theme.
   Standalone by design: independently validates first-visit behavior and
   persistence across the whole static site, mobile/desktop, and accessibility. */
import assert from "node:assert/strict";
import {createServer} from "node:http";
import {mkdir,readFile} from "node:fs/promises";
import {join,normalize,resolve,sep} from "node:path";
import {chromium} from "playwright-core";

const root=resolve("docs");
const pages=[
  "about.html","adversary.html","agenda.html","atlas.html","claim-lab.html","constellation.html","judgment-provenance.html",
  "desk.html","discovery.html","erdos-paper.html","evidence-practice.html","evidence.html",
  "exact-research.html","findings-20261029.html","frontier.html","index.html",
  "join.html","living-investigation.html","living-paper.html","orchestrator.html",
  "passport.html","referee.html","research.html","review.html","sidon-arity.html"
];
const types={".html":"text/html; charset=utf-8",".css":"text/css; charset=utf-8",".js":"text/javascript; charset=utf-8",".svg":"image/svg+xml"};
const server=createServer(async(req,res)=>{
 try{
  const pathname=decodeURIComponent(new URL(req.url,"http://localhost").pathname);
  const path=resolve(join(root,normalize(pathname).replace(/^\/+/,"")||"index.html"));
  if(path!==root&&!path.startsWith(root+sep)){res.writeHead(403).end();return;}
  const body=await readFile(path);
  res.writeHead(200,{"Content-Type":types[path.slice(path.lastIndexOf("."))]||"application/octet-stream"}).end(body);
 }catch{res.writeHead(404).end("Not found");}
});
await new Promise(resolve=>server.listen(0,"127.0.0.1",resolve));
const origin="http://127.0.0.1:"+server.address().port+"/";
let browser;
try{
 await mkdir("browser-artifacts",{recursive:true});
 browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_BIN||"/usr/bin/chromium",args:["--no-sandbox"]});
 for(const width of [390,1280]){
  const context=await browser.newContext({viewport:{width,height:820}});
  const page=await context.newPage();
  const errors=[];
  page.on("pageerror",e=>errors.push(e.message));
  page.on("response",r=>{if(r.url().startsWith(origin)&&r.status()>=400)errors.push(r.url()+" "+r.status());});
  await page.goto(origin+"index.html",{waitUntil:"load"});
  const toggle=page.locator(".nf-theme-toggle");
  assert.equal(await toggle.count(),1,"One toggle in header");
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),null,"First visit keeps light theme");
  assert.equal(await toggle.getAttribute("aria-pressed"),"false","Light mode accessible state");
  await page.screenshot({path:"browser-artifacts/ethereal-light-"+width+".png",fullPage:false});
  await toggle.click();
  await page.waitForTimeout(350);
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),"dusk","Dusk enabled");
  assert.equal(await toggle.getAttribute("aria-pressed"),"true","Dusk accessible state");
  assert.match(await toggle.getAttribute("aria-label"),/light mode/i);
  assert.equal(await page.evaluate(()=>localStorage.getItem("nightfall.theme.v1")),"dusk","Preference persisted");
  await page.screenshot({path:"browser-artifacts/ethereal-dusk-"+width+".png",fullPage:false});
  for(const file of pages){
   await page.goto(origin+file,{waitUntil:"load"});
   const control=page.locator(".nf-theme-toggle");
   assert.equal(await control.count(),1,file+": one theme control");
   assert.equal(await control.isVisible(),true,file+": visible theme control");
   assert.equal(await page.locator("html").getAttribute("data-nf-theme"),"dusk",file+": theme restored before ready");
   assert.equal(await control.getAttribute("aria-pressed"),"true",file+": control state restored");
   if(file==="claim-lab.html"){
    assert.equal(await page.locator(".topActions .nf-theme-toggle").count(),1,"Theme toggle is in Claim Lab toolbar");
    await page.locator("#newClaimBtn").click();
    await page.locator("#claimTitle").fill("Theme toolbar regression fixture");
    await page.locator("#claimForm button[type=submit]").click({timeout:2500});
    assert.equal(await page.locator(".modalMask.show").count(),0,"Claim Lab submit remains usable with theme control");
   }
   const appearance=await page.evaluate(()=>{
    const s=getComputedStyle(document.body);
    return {color:s.color,image:s.backgroundImage,overflow:document.documentElement.scrollWidth-innerWidth};
   });
   if(["living-paper.html","erdos-paper.html"].includes(file))
    assert.equal(appearance.image,"none",file+": scientific reading deliberately has no starfield");
   else assert.match(appearance.image,/radial-gradient/i,file+": atmospheric starfield loaded");
   if(file==="index.html"){
    const heroButton=await page.locator(".hero-actions .button").first().evaluate(el=>({bg:getComputedStyle(el).backgroundColor,fg:getComputedStyle(el).color}));
    assert.equal(heroButton.bg,"rgb(222, 210, 250)","Dusk primary CTA has light background");
    assert.equal(heroButton.fg,"rgb(20, 25, 45)","Dusk primary CTA has dark text");
    const railLink=await page.locator(".nf-journey-rail a").first().evaluate(el=>getComputedStyle(el).color);
    assert.equal(railLink,"rgb(224, 214, 255)","Journey-rail links legible in dusk");
   }
   assert.ok(appearance.overflow<=4,file+": overflow in dusk at "+width+"px: "+appearance.overflow);
   if(["join.html","discovery.html","claim-lab.html","erdos-paper.html"].includes(file))
    await page.screenshot({path:"browser-artifacts/ethereal-"+file.replace(".html","")+"-"+width+".png",fullPage:false});
  }
  // The star map is real navigation through canonical source claims, not ornament.
  await page.goto(origin+"index.html",{waitUntil:"load"});
  assert.equal(await page.locator("#nf-observatory-field .nf-observatory-node").count(),11,"Canonical graph has six claims and five mechanisms");
  assert.equal(await page.locator(".nf-observatory-edge").count(),13,"Thirteen typed relationships drawn from registry");
  assert.equal(await page.locator(".nf-process-thread a").count(),5,"Five-stage cross-tool research journey");
  assert.equal(await page.locator('.nf-process-thread a[aria-current="step"]').count(),1,"Research journey has one location marker");
  assert.equal(await page.locator(".nf-observatory-path").count(),2,"Two grounded entry routes are visible before a selection");
  await page.locator("#observatory").screenshot({path:"browser-artifacts/ethereal-observatory-overview-"+width+".png"});
  assert.equal(await page.locator('#nf-observatory-lenses [aria-pressed="true"]').count(),1,"One active evidence lens");
  assert.equal(await page.locator('.nf-observatory-lenses [data-lens="all"]').getAttribute("aria-pressed"),"true","All sources is the default lens");
  await page.locator('[data-lens="finite-check"]').click();
  await page.waitForFunction(()=>document.querySelectorAll(".nf-observatory-edge").length===4);
  assert.equal(await page.locator(".nf-observatory-edge").count(),4,"Finite-check lens filters exact documented relationships");
  assert.equal(await page.locator('[data-lens="finite-check"]').getAttribute("aria-pressed"),"true");
  await page.locator('[data-lens="open-premise"]').click();
  await page.waitForFunction(()=>document.querySelectorAll(".nf-observatory-edge").length===3);
  assert.equal(await page.locator(".nf-observatory-edge").count(),3,"Open-premise lens shows three explicitly unresolved relationships");
  assert.match(await page.locator("#nf-observatory-view-status").innerText(),/Unresolved premises/);
  if(width===390){
    const rects=await page.evaluate(()=>({
      inspector:document.querySelector("#nf-observatory-inspector").getBoundingClientRect().top,
      field:document.querySelector("#nf-observatory-field").getBoundingClientRect().top
    }));
    assert.ok(rects.inspector<rects.field,"Mobile inspector precedes catalogue for immediate explanation");
  }
  await page.locator('[data-start="phase"]').click();
  assert.match(page.url(),/\?claim=phase/,"Node selection makes a shareable canonical deep link");
  await page.waitForFunction(()=>document.querySelectorAll(".nf-observatory-edge").length===1);
  assert.equal(await page.locator(".nf-observatory-edge").count(),1,"Selected phase claim has one unresolved source edge");
  await page.reload({waitUntil:"load"});
  assert.equal(await page.locator('.nf-observatory-node[data-node="phase"]').getAttribute("aria-pressed"),"true","Canonical deep link restores selected node");
  assert.match(await page.locator("#nf-observatory-inspector").innerText(),/UNRESOLVED PREMISE/);
  await page.locator('.nf-observatory-node[data-node="phase"]').focus();
  await page.keyboard.press("Escape");
  assert.equal(await page.locator('.nf-observatory-node[data-node="phase"]').getAttribute("aria-pressed"),"false","Escape clears selection");
  assert.ok(!page.url().includes("claim=phase"),"Clearing selection removes stale deep link");
  await page.locator('[data-lens="all"]').click();
  await page.waitForFunction(()=>document.querySelectorAll(".nf-observatory-edge").length===13);
  await page.locator('.nf-observatory-node[data-node="symmetry-reduction"]').click();
  assert.equal(await page.locator('#nf-observatory-inspector a[href="constellation.html?claim=symmetry-reduction"]').count(),1,"Mechanism opens its selected canonical source map");
  await page.locator('.nf-observatory-node[data-node="symmetry-reduction"]').click();
  assert.equal(await page.locator('.nf-observatory-node[data-node="symmetry-reduction"]').getAttribute("aria-pressed"),"false","Clicking selected mechanism clears it");
  await page.waitForFunction(()=>document.querySelectorAll(".nf-observatory-edge").length===13);
  assert.equal(await page.locator(".nf-observatory-edge").count(),13,"All typed relationships restored after switching lenses");

  await page.locator('.nf-observatory-node[data-node="phase"]').click();
  assert.equal(await page.locator('.nf-observatory-node[data-node="phase"]').getAttribute("aria-pressed"),"true","Selected source node accessible");
  assert.match(await page.locator("#nf-observatory-inspector").innerText(),/span-count|span count/i,"Unresolved prerequisite visible");
  assert.equal(await page.locator('#nf-observatory-inspector a[href="passport.html?claim=phase"]').count(),1,"Proof Passport is source-linked");
  assert.match(await page.locator("#nf-observatory-inspector").innerText(),/UNRESOLVED PREMISE/,"Open premise explicitly classified");
  assert.match(await page.locator("#nf-observatory-inspector .nf-observatory-relation-note").first().innerText(),/cannot be promoted without its foundational lemma/i,"Foundational condition is visible in the compact inspector");
  await page.locator('.nf-observatory-node[data-node="phase"]').click();
  await page.locator('.nf-observatory-node[data-node="erdos36"]').click();
  assert.match(await page.locator("#nf-observatory-inspector").innerText(),/16-cell demonstration is distinct from the 131,072-cell archived witness/i,"Small finite control explicitly distinguished from archival witness");
  await page.locator('.nf-observatory-node[data-node="erdos36"]').click();
  await page.waitForFunction(()=>document.querySelectorAll(".nf-observatory-edge").length===13);
  await page.locator("#observatory").screenshot({path:"browser-artifacts/ethereal-observatory-"+width+".png"});
  await page.goto(origin+"living-paper.html",{waitUntil:"load"});
  const paperBg=await page.evaluate(()=>getComputedStyle(document.body).backgroundImage);
  assert.equal(paperBg,"none","Dusk mathematics reading canvas has no stars behind equations");
  await page.goto(origin+"constellation.html",{waitUntil:"load"});
  assert.equal(await page.locator("#co-theme").count(),0,"No competing constellation theme toggle");
  assert.equal(await page.locator("body").getAttribute("data-theme"),"dark","Constellation follows global dusk");
  await page.locator(".nf-theme-toggle").click();
  assert.equal(await page.locator("body").getAttribute("data-theme"),"light","Constellation follows global light");
  await page.locator(".nf-theme-toggle").click();
  assert.equal(await page.locator("body").getAttribute("data-theme"),"dark","Constellation can return to global dusk");
  await page.goto(origin+"index.html",{waitUntil:"load"});
  await page.emulateMedia({reducedMotion:"reduce"});
  assert.equal(await toggle.evaluate(el=>getComputedStyle(el).transitionDuration),"0s","Reduced motion removes toggle transition");
  await toggle.click();
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),null,"Returns to light theme");
  assert.equal(await toggle.getAttribute("aria-pressed"),"false","Restored light accessible state");
  await page.reload({waitUntil:"load"});
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),null,"Light preference persists on reload");
  assert.equal(await page.evaluate(()=>localStorage.getItem("nightfall.theme.v1")),"light","Light stored");
  assert.deepEqual(errors,[],width+"px page errors: "+errors.join("; "));
  await context.close();
 }
 console.log("PASS: light/archive and dusk/observatory, canonical relationships, shared journey, calm papers, 25 pages, mobile/desktop, accessibility and reduced motion");
}finally{
 await browser?.close();
 await new Promise(resolve=>server.close(resolve));
}
