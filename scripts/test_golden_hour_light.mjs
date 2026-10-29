/* Rose-parchment light acceptance: functional color, WCAG contrast, and dusk isolation.
   Source/claim evidence is explicitly not part of this decorative test. */
import assert from "node:assert/strict";
import {createServer} from "node:http";
import {readFile,mkdir} from "node:fs/promises";
import {resolve,join,normalize,sep} from "node:path";
import {chromium} from "playwright-core";
const root=resolve("docs");
const typ={".html":"text/html",".css":"text/css",".js":"text/javascript",".svg":"image/svg+xml"};
const server=createServer(async(req,res)=>{
 try{
  const pathname=decodeURIComponent(new URL(req.url,"http://localhost").pathname);
  const fp=resolve(join(root,normalize(pathname).replace(/^\/+/,"")||"index.html"));
  if(fp!==root&&!fp.startsWith(root+sep)){res.writeHead(403).end();return;}
  const b=await readFile(fp);
  res.writeHead(200,{"Content-Type":typ[fp.slice(fp.lastIndexOf("."))]||"application/octet-stream"}).end(b);
 }catch{res.writeHead(404).end("Not found")}
});
const rgb=(s)=>s.match(/\d+(?:\.\d+)?/g)?.slice(0,3).map(Number)||[];
function luminance(x){
 const vals=x.map(t=>{let k=t/255;return k<=.04045?k/12.92:((k+.055)/1.055)**2.4});
 return .2126*vals[0]+.7152*vals[1]+.0722*vals[2];
}
function contrast(a,b){const x=luminance(rgb(a)),y=luminance(rgb(b));return (Math.max(x,y)+.05)/(Math.min(x,y)+.05)}
const pages=["index.html","join.html","constellation.html","living-paper.html","erdos-paper.html",
 "discovery.html","claim-lab.html","desk.html","research.html","review.html"];
await new Promise(resolve=>server.listen(0,"127.0.0.1",resolve));
const origin="http://127.0.0.1:"+server.address().port+"/";
let browser;
try{
 await mkdir("browser-artifacts",{recursive:true});
 browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_BIN||"/usr/bin/chromium",args:["--no-sandbox"]});
 for(const width of [390,1280]){
  const context=await browser.newContext({viewport:{width,height:850}});
  const page=await context.newPage();
  const errors=[];
  page.on("pageerror",e=>errors.push("pageerror: "+e.message));
  // A fresh visitor sees dusk; this suite then explicitly selects light.
  await page.goto(origin+"index.html",{waitUntil:"load"});
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),"dusk","Dusk is the fresh-visit default");
  await page.locator(".nf-theme-toggle").click();
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),null,"Explicit light opt-in activates cocoa archive");
  assert.equal(await page.evaluate(()=>localStorage.getItem("nightfall.theme.v1")),"light","Explicit light choice is persisted");
  page.on("response",r=>{if(r.url().startsWith(origin)&&r.status()>=400)errors.push(r.url()+": "+r.status())});
  for(const name of pages){
   await page.goto(origin+name,{waitUntil:"load"});
   const v=await page.evaluate(()=>{
    const css=getComputedStyle(document.documentElement),body=getComputedStyle(document.body);
    const pick=(q,prop="backgroundColor")=>{const e=document.querySelector(q);return e?getComputedStyle(e)[prop]:null};
    return {theme:document.documentElement.getAttribute("data-nf-theme"),
      paper:css.getPropertyValue("--lf-paper").trim(),
      oxblood:css.getPropertyValue("--lf-oxblood").trim(),
      primary:css.getPropertyValue("--lf-primary").trim(),
      bodyBg:body.backgroundColor,
      nav:pick(".nav-call"),heroAction:pick(".hero-actions .button"),
      coreAction:pick(".co-primary"),joinMethod:pick(".join-method"),
      sidon:pick(".lp-hero-aside"),feature:pick(".feature.lime"),
      system:pick(".nf-home-tool-entry"),observatory:pick(".nf-observatory-field"),
      lens:pick('.nf-observatory-lenses button[aria-pressed="true"]'),
      discoverySidebar:pick("#app .side"),discoveryMark:pick("#app .brand-mark"),
      claimSidebar:pick(".app .sidebar"),claimMark:pick(".app .brandMark"),
      readout:pick(".desk-readout"),raised:pick(".join-result-grid article"),
      epConsole:pick(".ep-console"),overflow:document.documentElement.scrollWidth-innerWidth};
   });
   assert.equal(v.theme,null,name+": saved light choice remains respected");
   assert.equal(v.paper,"#28190f",name+": cocoa archive contract");
   assert.equal(v.oxblood,"#1b100b",name+": oxblood identity");
   assert.equal(v.primary,"#edc16e",name+": sunset action accent");
   assert.equal(v.bodyBg,"rgb(40, 25, 15)",name+": light canvas");
   assert.ok(v.overflow<=4,name+": no "+width+"px horizontal overflow ("+v.overflow+")");
   const expectations={
    "index.html":{nav:"rgb(27, 16, 11)",heroAction:"rgb(237, 193, 110)",
      system:"rgb(27, 16, 11)",lens:"rgb(237, 193, 110)"},
    "constellation.html":{coreAction:"rgb(237, 193, 110)"},
    "join.html":{joinMethod:"rgb(27, 16, 11)",raised:"rgb(59, 40, 29)"},
    "living-paper.html":{sidon:"rgb(27, 16, 11)"},
    "erdos-paper.html":{sidon:"rgb(27, 16, 11)",epConsole:"rgb(59, 40, 29)"},
    "discovery.html":{discoverySidebar:"rgb(51, 33, 22)",discoveryMark:"rgb(237, 193, 110)"},
    "claim-lab.html":{claimSidebar:"rgb(51, 33, 22)"},
    "desk.html":{readout:"rgb(27, 16, 11)"}
   };
   if(name==="index.html"){
    const diagram=await page.evaluate(()=>{
      const svg=document.querySelector(".hero-aside .diagram");
      return {signal:getComputedStyle(svg.querySelector('circle[fill="#d8c38a"]')).fill,
        curve:getComputedStyle(svg.querySelector('path[stroke="#4a1f24"]')).stroke,
        toolbar:document.querySelector('meta[name="theme-color"]')?.content};
    });
    assert.equal(diagram.signal,"rgb(216, 195, 138)","Mathematical hero signal uses muted blackcherry");
    assert.equal(diagram.curve,"rgb(74, 31, 36)","Hero's forest-green path uses oxblood");
    assert.equal(diagram.toolbar,"#28190f","Browser chrome follows cocoa identity");
   }
   for(const [key,target] of Object.entries(expectations[name]||{})){
    assert.equal(v[key],target,name+" "+width+"px "+key+" matches cocoa archive");
   }
   if(["index.html","join.html","constellation.html","living-paper.html","discovery.html","claim-lab.html"].includes(name)){
    await page.screenshot({path:"browser-artifacts/golden-hour-"+name.replace(".html","")+"-"+width+".png",fullPage:false});
   }
  }
  // Contrast on actual computed fills, checked for ordinary 4.5:1 text.
  await page.goto(origin+"index.html",{waitUntil:"load"});
  const comps=await page.evaluate(()=>{
   const styles=q=>{const e=document.querySelector(q),s=getComputedStyle(e);return [s.color,s.backgroundColor]};
   return {nav:styles(".nav-call"),cta:styles(".hero-actions .button"),
     body:styles("body")};
  });
  assert.ok(contrast(...comps.nav)>=4.5,"Cocoa navigation button text meets WCAG AA");
  assert.ok(contrast(...comps.cta)>=4.5,"Golden-hour action text meets WCAG AA");
  assert.ok(contrast(...comps.body)>=7,"Body text on cocoa comfortably exceeds AA");
  const toggle=page.locator(".nf-theme-toggle");
  await toggle.click();
  await page.waitForFunction(()=>document.documentElement.dataset.nfTheme==="dusk");
  await page.waitForFunction(()=>getComputedStyle(document.body).backgroundColor==="rgb(4, 6, 11)",null,{timeout:3500});
  const dark=await page.evaluate(()=>({
    bg:getComputedStyle(document.body).backgroundColor,
    primary:getComputedStyle(document.querySelector(".hero-actions .button")).backgroundColor
  }));
  assert.equal(dark.bg,"rgb(4, 6, 11)","Dusk midnight canvas unchanged");
  assert.equal(dark.primary,"rgb(230, 222, 170)","Dusk champagne CTA unchanged");
  assert.equal(await page.locator('meta[name="theme-color"]').getAttribute("content"),"#04060b","Dusk browser chrome remains midnight navy");
  await toggle.click();
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),null,"Switching back restores cocoa archive");
  await page.waitForFunction(()=>getComputedStyle(document.body).backgroundColor==="rgb(40, 25, 15)",null,{timeout:3500});
  assert.equal(await page.locator('meta[name="theme-color"]').getAttribute("content"),"#28190f","Light browser chrome returns to blackcherry");
  assert.equal(await page.locator("body").evaluate(e=>getComputedStyle(e).backgroundColor),
   "rgb(40, 25, 15)","Cocoa archive survives reversal");
  assert.deepEqual(errors,[],"No missing assets or browser JS errors at "+width+"px");
  await context.close();
 }
 console.log("PASS cocoa archive light: dusk-first, 10 light pages × mobile/desktop, blackcherry action palette, AA contrast, unchanged dusk and reversible state");
}finally{await browser?.close();await new Promise(resolve=>server.close(resolve))}
