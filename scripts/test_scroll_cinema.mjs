/* Verify NULL FIELD's static finite-witness cinema and the independent
   NEW MOON investigation page at five widths. No scroll animation. */
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
  if(p!==root&&!p.startsWith(root+sep)){res.writeHead(403).end();return;}
  const bytes=await readFile(p);
  res.writeHead(200,{"Content-Type":types[p.slice(p.lastIndexOf("."))]||"application/octet-stream"}).end(bytes);
 }catch{res.writeHead(404).end("Missing");}
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
  const faults=[],assets=[];
  page.on("pageerror",err=>faults.push(err.message));
  page.on("response",r=>{
   if(r.url().startsWith(origin)&&r.status()>=400)faults.push(r.status()+" "+r.url());
   if(r.url().includes("deep-space.svg"))assets.push({url:r.url(),status:r.status()});
  });
  const checkViewport=async()=>{
   const v=await page.evaluate(()=>({
    overflow:document.documentElement.scrollWidth-innerWidth,
    menu:document.querySelector("#menu-button")?.getBoundingClientRect().height,
    toggle:document.querySelector(".nf-theme-toggle")?.getBoundingClientRect().height
   }));
   assert.ok(v.overflow<=4,width+"px no horizontal overflow: "+v.overflow);
   if(width<=900){
    assert.ok(v.menu>=43.5,width+"px minimum mobile menu touch target");
    assert.ok(v.toggle>=43.5,width+"px minimum switch touch target");
   }
  };
  await page.goto(origin+"index.html",{waitUntil:"load"});
  assert.equal(await page.locator("html").getAttribute("data-nf-experience"),"archive");
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),null);
  assert.equal(await page.locator("#nf-scroll-cinema").count(),1,"NULL FIELD owns the static source-bound cinema");
  assert.equal(await page.locator("#nf-scroll-cinema").getAttribute("data-motion"),"static");
  assert.equal(await page.locator(".nf-cinema-world--archive").isVisible(),true);
  assert.equal(await page.locator(".nf-cinema-world--night").count(),0,"Hidden night narrative not duplicated");
  assert.equal(await page.locator("script[src='scroll-cinema.js']").count(),0,"No scroll-driven controller");
  assert.equal(await page.locator("script[src='home-opening-cinema.js']").count(),0,"No parallax controller");
  const archive=await page.evaluate(()=>{
   const q=s=>document.querySelector(s);
   const scene=q("#nf-scroll-cinema"),world=q(".nf-cinema-world--archive"),hero=q(".nf-opening-sky--gold");
   const token=getComputedStyle(document.documentElement).getPropertyValue("--nf-tile-rule-width").trim();
   return {background:getComputedStyle(world).backgroundImage,
    hero:getComputedStyle(hero).backgroundImage,
    stage:getComputedStyle(q(".nf-cinema-stage")).position,
    value:q(".nf-cinema-record-value")?.textContent?.trim(),
    steps:scene.querySelectorAll(".nf-cinema-proof-path li").length,
    source:!!q('.nf-cinema-record a[href="erdos-paper.html"]'),
    challenge:!!q('.nf-cinema-record a[href="review.html#erdos"]'),
    token,progress:scene.style.getPropertyValue("--nf-progress")
   };
  });
  assert.match(archive.background,/null-field-deep-space\.svg/);
  assert.match(archive.hero,/null-field-deep-space\.svg/);
  assert.equal(archive.stage,"relative","Cinema is static, not sticky");
  assert.equal(archive.value,"0.380856370118…");
  assert.equal(archive.steps,3);
  assert.equal(archive.source,true);
  assert.equal(archive.challenge,true);
  assert.equal(archive.progress,"");
  assert.equal(archive.token,".5px","Signature hairline token survives");
  await page.locator("#nf-scroll-cinema").scrollIntoViewIfNeeded();
  await page.evaluate(()=>window.scrollTo({top:document.getElementById("nf-scroll-cinema").offsetTop+300,behavior:"instant"}));
  assert.equal(await page.locator("#nf-scroll-cinema").getAttribute("data-motion"),"static");
  await checkViewport();
  if([390,1280].includes(width))await page.screenshot({path:"browser-artifacts/scroll-cinema-archive-"+width+".png",fullPage:false});
  assert.ok(assets.some(a=>a.url.endsWith("null-field-deep-space.svg")&&a.status===200),"Archive art is self-hosted");
  await page.locator(".nf-theme-toggle").click();
  await page.waitForURL("**/new-moon.html");
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),"dusk");
  assert.equal(await page.locator("html").getAttribute("data-nf-experience"),"moon");
  assert.equal(await page.locator("#nf-scroll-cinema").count(),0,"Night has a separate editorial composition");
  assert.equal(await page.locator(".moon-sky").count(),1);
  assert.equal(await page.locator(".moon-disc").count(),1);
  assert.equal(await page.locator("#open-ledger .moon-ledger-row").count(),4);
  assert.equal(await page.locator('#open-ledger a[href="review.html#erdos"]').count(),1);
  assert.equal(await page.locator('a[data-nf-route="moon"][aria-current="page"]').count(),1);
  await checkViewport();
  if([390,1280].includes(width))await page.screenshot({path:"browser-artifacts/scroll-cinema-moon-"+width+".png",fullPage:false});
  if(width<=900){
   await page.evaluate(()=>window.scrollTo({top:0,behavior:"instant"}));
   await page.locator("#menu-button").click();
   assert.equal(await page.locator("#site-nav").isVisible(),true,"Mobile menu opens on the New Moon page");
   await page.keyboard.press("Escape");
   assert.equal(await page.locator("#site-nav").isVisible(),false,"Mobile menu closes with Escape");
  }
  await page.locator(".nf-theme-toggle").click();
  await page.waitForURL("**/index.html");
  assert.equal(await page.locator("html").getAttribute("data-nf-experience"),"archive");
  assert.equal(await page.locator("#nf-scroll-cinema").getAttribute("data-motion"),"static");
  await checkViewport();
  assert.deepEqual(faults,[],width+"px browser faults: "+faults.join("; "));
  await context.close();
 }
 const reduced=await browser.newContext({viewport:{width:390,height:740},reducedMotion:"reduce"});
 const page=await reduced.newPage();
 await page.goto(origin+"index.html",{waitUntil:"load"});
 assert.equal(await page.locator("#nf-scroll-cinema").getAttribute("data-motion"),"static");
 assert.equal(await page.locator(".nf-cinema-stage").evaluate(el=>getComputedStyle(el).position),"relative");
 await page.locator(".nf-theme-toggle").click();
 await page.waitForURL("**/new-moon.html");
 assert.equal(await page.locator("#open-ledger").isVisible(),true);
 await reduced.close();
 for(const path of ["new-moon-nightscape.svg","null-field-deep-space.svg"]){
  const raw=await readFile(join(root,"media",path),"utf8");
  assert.match(raw,/viewBox="0 0 2560 1440"/,path+": independent source SVG has high-resolution composition");
  assert.doesNotMatch(raw,/<(?:text|script|foreignObject)\b/i,path+": decorative SVG contains no executable content");
 }
 console.log("PASS: separate archive cinema and moon investigation pages, 5 viewport widths, evidence sources, mobile menu, reduced motion and static art");
}finally{await browser?.close();await new Promise(done=>server.close(done));}
