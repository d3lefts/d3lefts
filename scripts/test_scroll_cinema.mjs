/* Static visual studies acceptance: image assets, native evidence, no scroll work.
   Test 320px–1280px, both atmospheres, source links, mobile nav, reduced motion. */
import assert from "node:assert/strict";
import {createServer} from "node:http";
import {mkdir,readFile} from "node:fs/promises";
import {resolve,join,normalize,sep} from "node:path";
import {chromium} from "playwright-core";
const root=resolve("docs");
const types={".html":"text/html; charset=utf-8",".js":"text/javascript; charset=utf-8",".css":"text/css; charset=utf-8",".svg":"image/svg+xml"};
const server=createServer(async(req,res)=>{
 try{
  const name=decodeURIComponent(new URL(req.url,"http://localhost").pathname);
  const p=resolve(join(root,normalize(name).replace(/^\\/+/, "")||"index.html"));
  if(p!==root&&!p.startsWith(root+sep)){res.writeHead(403).end();return}
  const bytes=await readFile(p);
  res.writeHead(200,{"Content-Type":types[p.slice(p.lastIndexOf("."))]||"application/octet-stream"}).end(bytes);
 }catch{res.writeHead(404).end("Missing")}
});
await new Promise(done=>server.listen(0,"127.0.0.1",done));
const origin="http://127.0.0.1:"+server.address().port+"/";
let browser;
try{
 await mkdir("browser-artifacts",{recursive:true});
 browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_BIN||"/usr/bin/chromium",args:["--no-sandbox"]});
 for(const width of [320,375,390,768,1280]){
  const context=await browser.newContext({viewport:{width,height:800},reducedMotion:"no-preference"});
  const page=await context.newPage();const faults=[],assets=[];
  page.on("pageerror",err=>faults.push(err.message));
  page.on("response",r=>{
   if(r.url().startsWith(origin)&&r.status()>=400)faults.push(r.status()+" "+r.url());
   if(r.url().includes("nightscape.svg")||r.url().includes("deep-space.svg"))assets.push({url:r.url(),status:r.status()});
  });
  await page.goto(origin+"index.html",{waitUntil:"load"});
  const scene=page.locator("#nf-scroll-cinema");
  assert.equal(await scene.count(),1,"One static visual study per page");
  assert.equal(await scene.getAttribute("data-motion"),"static","No scroll animation even when motion is allowed");
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),"dusk","NEW MOON remains the first-visit default");
  assert.equal(await page.locator('script[src="scroll-cinema.js"]').count(),0,"Remove old frame-by-frame scroll controller");
  assert.equal(await page.locator('script[src="home-opening-cinema.js"]').count(),0,"Remove hero parallax controller");
  const targetCheck=async()=>{
   const layout=await page.evaluate(()=>{
    const rect=q=>document.querySelector(q)?.getBoundingClientRect();
    return {excess:document.documentElement.scrollWidth-innerWidth,menu:rect("#menu-button"),toggle:rect(".nf-theme-toggle")};
   });
   assert.ok(layout.excess<=3,width+": viewport must not overflow "+layout.excess);
   if(width<=900){
    assert.ok(layout.menu?.height>=43.5,width+": minimum 44px menu target");
    assert.ok(layout.toggle?.height>=43.5,width+": minimum 44px theme target");
   }
  };
  await targetCheck();
  for(const [mode,expectedBg,visibleArt,asset] of [
   ["dusk","rgb(4, 6, 11)",".nf-cinema-world--night","new-moon-nightscape.svg"],
   ["light","rgb(2, 4, 6)",".nf-cinema-world--archive","null-field-deep-space.svg"]
  ]){
   if(mode==="light")await page.locator(".nf-theme-toggle").click();
   assert.equal(await page.locator("html").getAttribute("data-nf-theme"),mode==="dusk"?"dusk":null);
   await page.waitForFunction(expected=>getComputedStyle(document.body).backgroundColor===expected,expectedBg);
   assert.equal(await page.locator(visibleArt).isVisible(),true,mode+": matching image layer");
   assert.equal(await page.locator(mode==="dusk"?".nf-cinema-world--archive":".nf-cinema-world--night").isVisible(),false,mode+": inactive image hidden");
   const still=await scene.evaluate((el,filename)=>{
     const art=el.querySelector(".nf-cinema-world:not([style*='hide'])");
     const world=el.querySelector(filename.includes("new-moon")?".nf-cinema-world--night":".nf-cinema-world--archive");
     const hero=document.querySelector(filename.includes("new-moon")?".nf-opening-sky--night":".nf-opening-sky--gold");
     return {backdrop:getComputedStyle(world).backgroundImage,hero:getComputedStyle(hero).backgroundImage,
       stagePosition:getComputedStyle(el.querySelector(".nf-cinema-stage")).position,
       evidence:el.querySelector(".nf-cinema-record-value")?.textContent?.trim(),
       steps:[...el.querySelectorAll(".nf-cinema-proof-path li")].map(n=>n.innerText.trim()),
       progress:el.style.getPropertyValue("--nf-progress"),
       source:!!el.querySelector('.nf-cinema-record a[href="erdos-paper.html"]'),
       challenge:!!el.querySelector('.nf-cinema-record a[href="review.html#erdos"]')};
   },asset);
   assert.ok(still.backdrop.includes(asset),mode+": matching self-hosted cinematic asset");
   assert.ok(still.hero.includes(asset),mode+": matching first-fold still asset");
   assert.equal(still.stagePosition,"relative",mode+": scene no longer sticky");
   assert.equal(still.progress,"",mode+": no progress variables");
   assert.equal(still.evidence,"0.380856370118…",mode+": source-bound finite overlap unchanged");
   assert.equal(still.steps.length,3,"All evidence-review steps available together");
   assert.equal(still.source,true,"Public mathematical witness link remains");
   assert.equal(still.challenge,true,"Independent review link remains");
   await page.locator("#nf-scroll-cinema").scrollIntoViewIfNeeded();
   await targetCheck();
   if([390,1280].includes(width))
    await page.screenshot({path:"browser-artifacts/scroll-cinema-"+mode+"-"+width+".png",fullPage:false});
   await page.evaluate(()=>window.scrollTo({top:document.getElementById("nf-scroll-cinema").offsetTop+400,behavior:"instant"}));
   assert.equal(await scene.getAttribute("data-motion"),"static",mode+": scrolling does not activate parallax");
   assert.equal(await scene.evaluate(el=>el.style.getPropertyValue("--nf-progress")),"",mode+": still no generated progress");
   await targetCheck();
  }
  assert.ok(assets.some(r=>r.url.endsWith("new-moon-nightscape.svg")&&r.status===200),width+": NEW MOON artwork delivered");
  assert.ok(assets.some(r=>r.url.endsWith("null-field-deep-space.svg")&&r.status===200),width+": NULL FIELD artwork delivered");
  if(width<=900){
   await page.evaluate(()=>window.scrollTo({top:0,behavior:"instant"}));
   await page.locator("#menu-button").click();
   assert.equal(await page.locator("#site-nav").isVisible(),true,"Mobile navigation opens");
   await page.keyboard.press("Escape");
   assert.equal(await page.locator("#site-nav").isVisible(),false,"Mobile navigation dismisses");
  }
  assert.deepEqual(faults,[],width+"px: no browser exceptions or missing assets");
  await context.close();
 }
 const reduced=await browser.newContext({viewport:{width:390,height:740},reducedMotion:"reduce"});
 const page=await reduced.newPage();
 await page.goto(origin+"index.html",{waitUntil:"load"});
 assert.equal(await page.locator("#nf-scroll-cinema").getAttribute("data-motion"),"static");
 assert.equal(await page.locator(".nf-cinema-stage").evaluate(el=>getComputedStyle(el).position),"relative");
 await page.locator(".nf-theme-toggle").click();
 assert.equal(await page.locator("#nf-scroll-cinema").getAttribute("data-motion"),"static");
 await reduced.close();
 for(const path of ["new-moon-nightscape.svg","null-field-deep-space.svg"]){
  const raw=await readFile(join(root,"media",path),"utf8");
  assert.match(raw,/viewBox="0 0 2560 1440"/,path+": resolution-independent 2560x1440 composition");
  assert.doesNotMatch(raw,/<(?:text|script|foreignObject)\\b/i,path+": no text, JS or HTML baked into imagery");
 }
 console.log("PASS: two self-hosted 2560x1440 static skies × 5 widths, live evidence, source links, responsive crops, reduced motion and no scroll animation");
}finally{await browser?.close();await new Promise(resolve=>server.close(resolve))}
