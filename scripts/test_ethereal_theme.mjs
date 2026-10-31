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
  "exact-research.html","findings-20261029.html","frontier.html",
  "join.html","living-investigation.html","living-paper.html","orchestrator.html",
  "new-moon.html","passport.html","referee.html","research.html","review.html","sidon-arity.html"
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
  assert.equal(await toggle.count(),1,"NULL FIELD has one switch in its header");
  assert.equal(await page.locator("html").getAttribute("data-nf-experience"),"archive","Direct archive route chooses NULL FIELD");
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),null,"Archive is immediately rendered in its dark NULL FIELD palette");
  assert.equal(await toggle.getAttribute("aria-pressed"),"false","Archive switch is accessible");
  assert.equal((await toggle.locator(".nf-theme-word").innerText()).trim(),"NEW MOON","Archive offers the other destination");
  assert.equal(await page.locator(".nf-experience-archive").first().isVisible(),true,"Archive's evidence-led copy is visible");
  assert.equal(await page.locator(".nf-experience-underbelly").count(),0,"Hidden New Moon article fragments were removed from archive");
  assert.equal(await page.locator(".nf-dual-colophon.nf-experience-archive").isVisible(),true,"Archive has its own colophon");
  assert.match(await toggle.getAttribute("aria-label"),/NULL FIELD is active.*NEW MOON.*Warm Night/i);
  await page.screenshot({path:"browser-artifacts/ethereal-light-"+width+".png",fullPage:false});
  await toggle.click();
  await page.waitForURL("**/new-moon.html");
  assert.equal(await page.locator("html").getAttribute("data-nf-experience"),"moon","Switch navigates to a different HTML document");
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),"dusk","New Moon page loads its own atmosphere without a flash");
  assert.equal(await toggle.getAttribute("aria-pressed"),"true","New Moon accessible state");
  assert.equal((await toggle.locator(".nf-theme-word").innerText()).trim(),"NULL FIELD","Moon offers a return to the archive");
  assert.equal(await page.locator("#open-ledger").isVisible(),true,"Distinct active-investigation ledger exists");
  assert.equal(await page.locator("#flagships").count(),0,"Archive-only layout is absent from the night desk");
  assert.match(await toggle.getAttribute("aria-label"),/New Moon is active.*NULL FIELD.*Deep Space/i);
  assert.equal(await page.evaluate(()=>localStorage.getItem("nightfall.theme.v1")),"dusk","Selection persisted after navigation");
  await page.screenshot({path:"browser-artifacts/ethereal-dusk-"+width+".png",fullPage:false});
  await toggle.click();
  await page.waitForURL("**/index.html");
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),null,"Switch back loads NULL FIELD");
  assert.equal(await toggle.getAttribute("aria-pressed"),"false","Archive restored");
  const palette=await page.evaluate(()=>{
    const css=getComputedStyle(document.documentElement);
    return {paper:css.getPropertyValue("--lf-paper").trim(),primary:css.getPropertyValue("--lf-primary").trim()};
  });
  assert.equal(palette.paper,"#020406","NULL FIELD background token");
  assert.equal(palette.primary,"#e46a84","NULL FIELD emphasis token");
  await page.locator(".nf-theme-toggle").click();
  await page.waitForURL("**/new-moon.html");
  assert.equal(await page.evaluate(()=>localStorage.getItem("nightfall.theme.v1")),"dusk","New Moon restored as selected experience");
  for(const file of pages){
   await page.goto(origin+file,{waitUntil:"load"});
   const control=page.locator(".nf-theme-toggle");
   assert.equal(await control.count(),1,file+": one theme control");
   assert.equal(await control.isVisible(),true,file+": visible theme control");
   assert.equal(await page.locator("html").getAttribute("data-nf-theme"),"dusk",file+": theme restored before ready");
   assert.equal(await control.getAttribute("aria-pressed"),"true",file+": control state restored");
   assert.equal((await control.locator(".nf-theme-word").innerText()).trim(),"NULL FIELD",file+": consistent destination label");
   assert.match(await control.getAttribute("aria-label"),/New Moon is active.*NULL FIELD.*Deep Space/i,file+": consistent accessible destination");
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
   // Color is an action and reading affordance, never a substitute for source-status text.
   if(["new-moon.html","join.html","constellation.html","living-paper.html"].includes(file)){
    const tokens=await page.evaluate(()=>{
      const s=getComputedStyle(document.documentElement);
      const body=getComputedStyle(document.body);
      return {gold:s.getPropertyValue("--nf-champagne").trim(),
        brass:s.getPropertyValue("--nf-brass").trim(),
        accent:s.getPropertyValue("--accent").trim(),
        paper:body.backgroundColor};
    });
    assert.equal(tokens.gold,"#e2d28c",file+": moonlit gold token is shared");
    assert.equal(tokens.brass,"#8f865f",file+": brass is reserved for quiet borders");
    assert.equal(tokens.accent,"#e2d28c",file+": dusk action accent inherits moonlight");
   }
   if(file==="new-moon.html"){
    assert.equal(await page.locator("#open-ledger .moon-ledger-row").count(),4,
      "Investigation page presents four source-bound review cases");
    assert.equal(await page.locator("#workbench a[href='constellation.html#map']").count(),1,
      "Night desk links to the full graph without duplicating it");
   }
   if(file==="constellation.html"){
    const action=await page.locator(".co-primary").first().evaluate(el=>({
      bg:getComputedStyle(el).backgroundColor,fg:getComputedStyle(el).color}));
    assert.equal(action.bg,"rgb(226, 210, 140)","Constellation action matches primary moonlight");
    assert.equal(action.fg,"rgb(11, 20, 37)","Constellation action retains navy ink");
   }
   if(file==="discovery.html"){
    const nav=await page.locator(".navitem.selected").first().evaluate(el=>getComputedStyle(el).backgroundColor);
    assert.equal(nav,"rgb(48, 44, 66)","Discovery selected navigation is violet-navy, not moss green");
    const appAccent=await page.evaluate(()=>getComputedStyle(document.body).getPropertyValue("--lime").trim());
    assert.equal(appAccent,"#e2d28c","Discovery's original lime token resolves to moonlight");
    const sourceStatus=await page.locator(".status").first().evaluate(el=>getComputedStyle(el).backgroundColor);
    assert.equal(sourceStatus,"rgb(12, 21, 39)","Discovery source status is no longer green");
   }
   if(file==="claim-lab.html"){
    const brandColor=await page.locator(".brandMark").first().evaluate(el=>getComputedStyle(el).color);
    assert.equal(brandColor,"rgb(226, 210, 140)","Claim Lab emblem carries moonlit gold");
    const toastColor=await page.locator(".toast").first().evaluate(el=>getComputedStyle(el).backgroundColor);
    assert.equal(toastColor,"rgb(40, 46, 68)","Claim Lab toast uses dusk navy, not teal green");
   }
   if(file==="desk.html"){
    const readout=await page.locator(".desk-readout").first().evaluate(el=>getComputedStyle(el).backgroundColor);
    assert.equal(readout,"rgb(27, 38, 59)","Research Desk no longer inherits green readout background");
   }
   if(file==="join.html"){
    const action=await page.locator(".join-choice button").first().evaluate(el=>getComputedStyle(el).backgroundColor);
    assert.equal(action,"rgb(226, 210, 140)","Join task action uses moonlight");
    const panel=await page.locator(".join-choice").first().evaluate(el=>getComputedStyle(el).backgroundColor);
    assert.equal(panel,"rgb(40, 51, 75)","Recommended Join card has the intentional raised navy focus treatment");
   }
   if(file==="new-moon.html"){
    assert.equal(await page.locator(".moon-hero-actions .button").count(),1,
      "Distinct night desk has a primary bounded-investigation call to action");
   }
   assert.ok(appearance.overflow<=4,file+": overflow in dusk at "+width+"px: "+appearance.overflow);
   if(["join.html","discovery.html","claim-lab.html","erdos-paper.html"].includes(file))
    await page.screenshot({path:"browser-artifacts/ethereal-"+file.replace(".html","")+"-"+width+".png",fullPage:false});
  }
   // First-review entry: finite replay before advanced theorem challenges.
   await page.goto(origin+"review.html",{waitUntil:"load"});
   assert.equal(await page.locator(".review-hero a[href='#start-here']").count(),1,"Reviewer entry visible");
   assert.equal(await page.locator("#start-here").isVisible(),true,"Finite review card available");
   assert.match(await page.locator("#start-here pre").innerText(),/verify_sidon30_standalone\.py/);
   assert.match(await page.locator("#start-here").innerText(),/27405|27,405/);
   assert.ok((await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth))<=4,
     "Review starter does not overflow at "+width+"px");
   await page.locator("#start-here").screenshot({path:"browser-artifacts/review-starter-moon-"+width+".png"});
   await page.locator(".nf-theme-toggle").click();
   assert.equal(await page.locator("#start-here").isVisible(),true,"Review remains readable in NULL FIELD");
   assert.ok((await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth))<=4,
     "Archive review starter does not overflow at "+width+"px");
   await page.locator("#start-here").screenshot({path:"browser-artifacts/review-starter-field-"+width+".png"});
   await page.locator(".nf-theme-toggle").click();
   await page.goto(origin+"about.html",{waitUntil:"load"});
   assert.equal(await page.locator('.about-lead a[href="portfolio.html"]').count(),1,
     "Research About directly links to attributed professional work");
   await page.goto(origin+"index.html",{waitUntil:"load"});
   assert.equal(await page.locator('.footer a[href="portfolio.html"]').count(),1,
     "Research homepage footer exposes portfolio without changing primary navigation");
   assert.equal(await page.locator('.footer a[href="review.html#start-here"]').count(),1,
     "Homepage handoff points to runnable first review");

   // The complete source-linked map belongs to Constellation.
   await page.goto(origin+"index.html",{waitUntil:"load"});
   assert.equal(await page.locator(".nf-observatory-edge").count(),0,"No duplicate homepage graph");
   assert.equal(await page.locator("#observatory a[href='constellation.html#map']").count(),1);
   assert.equal(await page.locator(".nf-process-thread").count(),0,"Header owns landing-page navigation");
   await page.locator("#observatory").screenshot({path:"browser-artifacts/ethereal-constellation-handoff-"+width+".png"});
  // The archive route is fixed to NULL FIELD and persists that selection.
  // Restore NEW MOON before testing dusk across the remaining shared pages.
  await page.goto(origin+"new-moon.html",{waitUntil:"load"});
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
  await page.goto(origin+"new-moon.html",{waitUntil:"load"});
  await page.emulateMedia({reducedMotion:"reduce"});
  assert.equal(await toggle.evaluate(el=>getComputedStyle(el).transitionDuration),"0s","Reduced motion removes toggle transition");
  await toggle.click();
  await page.waitForURL("**/index.html");
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),null,"Returns to NULL FIELD page");
  assert.equal(await toggle.getAttribute("aria-pressed"),"false","Restored light accessible state");
  await page.reload({waitUntil:"load"});
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),null,"Light preference persists on reload");
  const lightColor=await page.locator(".hero-actions .button").first().evaluate(el=>getComputedStyle(el).backgroundColor);
  assert.notEqual(lightColor,"rgb(226, 210, 140)","Opt-out restores the original light-theme accent");
  assert.equal(await page.evaluate(()=>localStorage.getItem("nightfall.theme.v1")),"light","Light stored");
  assert.deepEqual(errors,[],width+"px page errors: "+errors.join("; "));
  await context.close();
 }
 console.log("PASS: two separate homepages, persistent switch navigation, canonical evidence routes, 25 shared research pages, mobile/desktop, accessibility and reduced motion");
}finally{
 await browser?.close();
 await new Promise(resolve=>server.close(resolve));
}
