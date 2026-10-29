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
  "about.html","adversary.html","agenda.html","atlas.html","claim-lab.html",
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
   const appearance=await page.evaluate(()=>{
    const s=getComputedStyle(document.body);
    return {color:s.color,image:s.backgroundImage,overflow:document.documentElement.scrollWidth-innerWidth};
   });
   assert.match(appearance.image,/radial-gradient/i,file+": CSS starfield loaded");
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
 console.log("PASS: theme toggle, persistence, no initial override, 23 pages, mobile/desktop, starfield, accessibility and reduced motion");
}finally{
 await browser?.close();
 await new Promise(resolve=>server.close(resolve));
}
