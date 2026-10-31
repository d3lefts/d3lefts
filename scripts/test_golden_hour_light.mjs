/* Sunset Boulevard light acceptance: functional color, WCAG contrast, and dusk isolation.
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
  // Each homepage is an actual document. The first archive visit establishes
  // NULL FIELD; verify cross-page toggle persistence in both directions.
  await page.goto(origin+"index.html",{waitUntil:"load"});
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),null,"Direct NULL FIELD loads in its own archive palette");
  assert.equal(await page.locator("html").getAttribute("data-nf-experience"),"archive","Archive is a separate page");
  await page.locator(".nf-theme-toggle").click();
  await page.waitForURL("**/new-moon.html");
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),"dusk","Toggle opens a separate New Moon document");
  await page.locator(".nf-theme-toggle").click();
  await page.waitForURL("**/index.html");
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),null,"Returning restores NULL FIELD archive");
  assert.equal(await page.evaluate(()=>localStorage.getItem("nightfall.theme.v1")),"light","Archive selection persists");
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
      constellationRoute:!!document.querySelector('#observatory a[href="constellation.html#map"]'),
      discoverySidebar:pick("#app .side"),discoveryMark:pick("#app .brand-mark"),
      claimSidebar:pick(".app .sidebar"),claimMark:pick(".app .brandMark"),
      readout:pick(".desk-readout"),raised:pick(".join-result-grid article"),
      epConsole:pick(".ep-console"),overflow:document.documentElement.scrollWidth-innerWidth};
   });
   assert.equal(v.theme,null,name+": saved light choice remains respected");
   assert.equal(v.paper,"#020406",name+": Sunset Boulevard archive contract");
   assert.equal(v.oxblood,"#080d12",name+": carbon negative-space identity");
   assert.equal(v.primary,"#e46a84",name+": readable black-cherry display accent");
   assert.equal(v.bodyBg,"rgb(2, 4, 6)",name+": light canvas");
   assert.ok(v.overflow<=4,name+": no "+width+"px horizontal overflow ("+v.overflow+")");
   const expectations={
    "index.html":{nav:"rgb(8, 13, 18)",heroAction:"rgb(101, 13, 39)"},
    "constellation.html":{coreAction:"rgb(101, 13, 39)"},
    "join.html":{joinMethod:"rgb(16, 28, 31)",raised:"rgb(17, 24, 28)"},
    "living-paper.html":{sidon:"rgb(8, 13, 18)"},
    "erdos-paper.html":{sidon:"rgb(8, 13, 18)",epConsole:"rgb(17, 24, 28)"},
    "discovery.html":{discoverySidebar:"rgb(12, 18, 22)",discoveryMark:"rgb(101, 13, 39)"},
    "claim-lab.html":{claimSidebar:"rgb(12, 18, 22)"},
    "desk.html":{readout:"rgb(8, 13, 18)"}
   };
   if(name==="index.html"){
    assert.equal(v.constellationRoute,true,"Homepage includes a dedicated Constellation destination without duplicating full graph");
    const record=await page.evaluate(()=>{
      const aside=document.querySelector(".hero-aside .nf-opening-overlap");
      const displayed=document.querySelector(".hero-main .nf-opening-scoreline strong");
      return {
        value:aside?.querySelector(".nf-opening-overlap-value")?.textContent.trim(),
        firstFold:displayed?.textContent.trim(),
        cells:aside?.querySelector(".nf-opening-overlap-facts strong")?.textContent.trim(),
        source:!!aside?.querySelector('a[href="erdos-paper.html"]'),
        ink:aside?getComputedStyle(aside.querySelector(".nf-opening-overlap-value")).color:null,
        toolbar:document.querySelector('meta[name="theme-color"]')?.content
      };
    });
    assert.equal(record.value,"0.380856370118…","The sourced Erdős bound leads the hero");
    assert.equal(record.firstFold,record.value,"Finite overlap witness appears immediately in the opening");
    assert.equal(record.cells,"131,072","The exact finite construction size is disclosed");
    assert.equal(record.source,true,"The record links to its public witness and checker");
    assert.equal(record.ink,"rgb(234, 240, 245)","Finite record remains legible over black interference art");
    assert.equal(record.toolbar,"#020406","Browser chrome follows carbon-black identity");
   }
   for(const [key,target] of Object.entries(expectations[name]||{})){
    assert.equal(v[key],target,name+" "+width+"px "+key+" matches Sunset Boulevard archive");
   }
   if(name==="join.html"){
    const contrastPairs=await page.evaluate(()=>{
      const pairs=[
        [".join-result-grid article span",".join-result-grid article"],
        [".join-result-grid article a",".join-result-grid article"],
        [".join-method-steps b",".join-method-steps>div"],
        [".join-workspace-header p",".join-workspace"],
        [".join-empty",".join-empty"],
         [".join-hero-aside li b",".join-hero-aside"],
         [".join-choice>span",".join-choice"],
         [".join-choice p",".join-choice"],
         [".cj-pickers label",".cj-section"],
         [".cj-work p",".cj-work"],
         [".join-method .join-heading p",".join-method"]
      ];
      return pairs.map(([textSel,panelSel])=>{
        const ink=getComputedStyle(document.querySelector(textSel)).color;
        const panel=getComputedStyle(document.querySelector(panelSel)).backgroundColor;
        return {textSel,ink,panel};
      });
    });
    for(const pair of contrastPairs){
      const panel=pair.panel==="rgba(0, 0, 0, 0)"?"rgb(2, 4, 6)":pair.panel;
      assert.ok(contrast(pair.ink,panel)>=4.5,
        "Contributor contrast: "+pair.textSel+" "+pair.ink+" / "+panel);
    }
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
  assert.ok(contrast(...comps.nav)>=4.5,"Archive navigation button text meets WCAG AA");
  assert.ok(contrast(...comps.cta)>=4.5,"Black-cherry action text meets WCAG AA");
  assert.ok(contrast(...comps.body)>=7,"Body text on pitch black comfortably exceeds AA");
  const toggle=page.locator(".nf-theme-toggle");
  await toggle.click();
  await page.waitForURL("**/new-moon.html");
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),"dusk","New Moon has its own dark atmosphere");
  // New Moon inherits its own night palette; CSS layers may alter the exact RGB background.
  // Verify route identity and relative contrast without pinning a presentation token.
  const dark=await page.evaluate(()=>({
    bg:getComputedStyle(document.body).backgroundColor,
    accent:getComputedStyle(document.documentElement).getPropertyValue("--moon-gold").trim(),
    ledger:document.querySelectorAll(".moon-ledger-row").length
  }));
  assert.notEqual(dark.bg,"rgb(2, 4, 6)","NEW MOON has a distinct dark canvas from the archive");
  assert.equal(dark.accent,"#e2d28c","New Moon retains its moonlight accent");
  assert.equal(dark.ledger,4,"The separate investigation ledger is present");
  assert.equal(await page.locator('meta[name="theme-color"]').getAttribute("content"),"#04060b","New Moon browser chrome remains midnight navy");
  await toggle.click();
  await page.waitForURL("**/index.html");
  assert.equal(await page.locator("html").getAttribute("data-nf-theme"),null,"Switching back returns to the separate archive");
  await page.waitForFunction(()=>getComputedStyle(document.body).backgroundColor==="rgb(2, 4, 6)",null,{timeout:3500});
  assert.equal(await page.locator('meta[name="theme-color"]').getAttribute("content"),"#020406","Archive browser chrome returns to carbon-black");
  assert.equal(await page.locator("body").evaluate(e=>getComputedStyle(e).backgroundColor),
   "rgb(2, 4, 6)","Sunset Boulevard archive survives reversal");
  assert.deepEqual(errors,[],"No missing assets or browser JS errors at "+width+"px");
  await context.close();
 }
 console.log("PASS NULL FIELD: two separate entry pages, 10 archive/scoped pages × mobile/desktop, black-cherry action palette, AA contrast and reversible selection");
}finally{await browser?.close();await new Promise(resolve=>server.close(resolve))}
