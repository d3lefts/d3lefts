/* Independent mobile + scroll-cinema acceptance.
   Fails on stuck progress, missing mode artwork, 320px overflow,
   inaccessible menu controls, or reduced-motion regression. */
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
  const p=resolve(join(root,normalize(name).replace(/^\/+/,"")||"index.html"));
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
  const page=await context.newPage();
  const faults=[];
  page.on("pageerror",err=>faults.push(err.message));
  page.on("response",r=>{if(r.url().startsWith(origin)&&r.status()>=400)faults.push(r.status()+" "+r.url())});
  await page.goto(origin+"index.html",{waitUntil:"load"});
  const scene=page.locator("#nf-scroll-cinema");
  assert.equal(await scene.count(),1,"One cinematic story per page");
  assert.equal(await scene.getAttribute("data-motion"),"active","Active scroll scene when motion enabled");
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),"dusk","Night stays the default");
  const targetCheck=async()=>{
   const layout=await page.evaluate(()=>{
    const rect=q=>document.querySelector(q)?.getBoundingClientRect();
    return {viewport:innerWidth,excess:document.documentElement.scrollWidth-innerWidth,
      header:rect(".header-inner"),title:rect(".hero-title:not([hidden])"),
      menu:rect("#menu-button"),toggle:rect(".nf-theme-toggle")};
   });
   assert.ok(layout.excess<=3,width+": viewport must not overflow "+layout.excess);
   if(width<=900){
    assert.ok(layout.menu?.height>=43.5,"Minimum 44px menu target at "+width);
    assert.ok(layout.toggle?.height>=43.5,"Minimum 44px theme target at "+width);
   }
  };
  await targetCheck();
  for(const [mode,expectedBg,visibleArt] of [
   ["dusk","rgb(4, 6, 11)",".nf-cinema-world--night"],
   ["light","rgb(2, 4, 6)",".nf-cinema-world--archive"]
  ]){
   if(mode==="light")await page.locator(".nf-theme-toggle").click();
   assert.equal(await page.locator("html").getAttribute("data-nf-theme"),mode==="dusk"?"dusk":null,"Theme selector restores correct narrative");
   await page.waitForFunction(expected=>getComputedStyle(document.body).backgroundColor===expected,expectedBg,{timeout:4000});
   const bg=await page.locator("body").evaluate(el=>getComputedStyle(el).backgroundColor);
   assert.equal(bg,expectedBg,"Correct palette canvas "+mode);
   assert.equal(await page.locator(visibleArt).isVisible(),true,mode+" illustration visible");
   assert.equal(await page.locator(mode==="dusk"?".nf-cinema-world--archive":".nf-cinema-world--night").isVisible(),false,mode+" other sky hidden");
   await page.evaluate(()=>{
    document.documentElement.style.scrollBehavior="auto";
    const el=document.getElementById("nf-scroll-cinema");
    window.scrollTo({top:el.getBoundingClientRect().top+window.scrollY+(el.offsetHeight-innerHeight)*.52,behavior:"instant"});
   });
   await page.waitForFunction(()=>{
    const el=document.getElementById("nf-scroll-cinema");
    return Number.parseFloat(el.style.getPropertyValue("--nf-progress"))>.35
      && Number.parseFloat(el.style.getPropertyValue("--nf-progress"))<.73;
   });
   const mid=await scene.evaluate(el=>({
    p:Number.parseFloat(el.style.getPropertyValue("--nf-progress")),
    dash:Number.parseFloat(el.style.getPropertyValue("--nf-trace")),
    stageTop:el.querySelector(".nf-cinema-stage").getBoundingClientRect().top,
    chapter:el.dataset.chapter,
    scrollHeight:el.offsetHeight
   }));
   assert.ok(mid.p>.35&&mid.p<.73,mode+" midpoint scroll mapped into progress");
   assert.ok(Math.abs(mid.dash-(1-mid.p))<.01,mode+" progressive path evidence drawing");
   assert.equal(mid.chapter,"2",mode+" middle chapter revealed");
   assert.ok(Math.abs(mid.stageTop)<=3,mode+" sticky stage remains pinned, got "+mid.stageTop);
   assert.ok(mid.scrollHeight>800,"Scrollable scene has genuine progress travel");
   await targetCheck();
   if([390,1280].includes(width))
    await page.screenshot({path:"browser-artifacts/scroll-cinema-"+mode+"-"+width+".png",fullPage:false});
   await page.evaluate(()=>{
    const el=document.getElementById("nf-scroll-cinema");
    window.scrollTo({top:el.getBoundingClientRect().top+window.scrollY+(el.offsetHeight-innerHeight)*.9,behavior:"instant"});
   });
   await page.waitForFunction(()=>document.getElementById("nf-scroll-cinema").dataset.chapter==="3");
   await targetCheck();
  }
  if(width<=900){
   await page.evaluate(()=>window.scrollTo({top:0,behavior:"instant"}));
   await page.locator("#menu-button").click();
   assert.equal(await page.locator("#site-nav").isVisible(),true,"Mobile navigation opens after story");
   await page.keyboard.press("Escape");
   assert.equal(await page.locator("#site-nav").isVisible(),false,"Mobile navigation dismisses after story");
  }
  assert.deepEqual(faults,[],width+"px unexpected JavaScript or HTTP errors");
  await context.close();
 }
 const reduced=await browser.newContext({viewport:{width:390,height:740},reducedMotion:"reduce"});
 const page=await reduced.newPage();
 await page.goto(origin+"index.html",{waitUntil:"load"});
 assert.equal(await page.locator("#nf-scroll-cinema").getAttribute("data-motion"),"static","Reduced motion disables scroll work");
 assert.equal(await page.locator(".nf-cinema-stage").evaluate(el=>getComputedStyle(el).position),"relative","Reduced motion removes sticky animation");
 assert.equal(await page.locator("#nf-scroll-cinema").evaluate(el=>el.style.getPropertyValue("--nf-progress")),"","Reduced motion has no animated progress variable");
 await page.locator(".nf-theme-toggle").click();
 assert.equal(await page.locator("#nf-scroll-cinema").getAttribute("data-motion"),"static","Reduced-motion remains respected after theme switch");
 await reduced.close();
 console.log("PASS: two scroll-driven skies × 5 widths (320–1280), pinned progress, path drawing, 44px controls, overflow, menus, reduced motion and zero HTTP/JS faults");
}finally{await browser?.close();await new Promise(resolve=>server.close(resolve))}
