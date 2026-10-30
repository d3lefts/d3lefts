/* NIGHTFALL / computed palette regression.
   Only checks large visible painted surfaces, not historical CSS source,
   proof-status colors, SVG data marks or mathematical semantics. */
import assert from "node:assert/strict";
import {createServer} from "node:http";
import {readFile} from "node:fs/promises";
import {join,resolve,normalize,sep} from "node:path";
import {chromium} from "playwright-core";
const root=resolve("docs");
const paths=[
  "about.html","adversary.html","agenda.html","atlas.html","claim-lab.html",
  "constellation.html","desk.html","discovery.html","erdos-paper.html",
  "evidence-practice.html","evidence.html","exact-research.html","findings-20261029.html",
  "frontier.html","index.html","join.html","judgment-provenance.html",
  "living-investigation.html","living-paper.html","orchestrator.html",
  "passport.html","portfolio.html","referee.html","research.html","review.html",
  "sidon-arity.html"
];
const types={".html":"text/html; charset=utf-8",".css":"text/css; charset=utf-8",
  ".js":"text/javascript; charset=utf-8",".svg":"image/svg+xml"};
const server=createServer(async(req,res)=>{
 try{
  const pathname=decodeURIComponent(new URL(req.url,"http://localhost").pathname);
  const p=resolve(join(root,normalize(pathname).replace(/^\/+/,"")||"index.html"));
  if(p!==root&&!p.startsWith(root+sep)){res.writeHead(403).end();return}
  const data=await readFile(p);
  res.writeHead(200,{"Content-Type":types[p.slice(p.lastIndexOf("."))]||"application/octet-stream"}).end(data);
 }catch{res.writeHead(404).end("Missing")}
});
await new Promise(resolve=>server.listen(0,"127.0.0.1",resolve));
const origin="http://127.0.0.1:"+server.address().port+"/";
const deprecated=[
  "rgb(244, 231, 223)","rgb(244, 238, 237)","rgb(252, 243, 234)",
  "rgb(238, 223, 214)","rgb(245, 244, 238)","rgb(231, 210, 197)",
  "rgb(231, 198, 179)","rgb(238, 209, 189)"
];
let browser;
const allSurfaceLeaks=[];
const allCanvasLeaks=[];
try{
 browser=await chromium.launch({
  headless:true,executablePath:process.env.CHROME_BIN||"/usr/bin/chromium",
  args:["--no-sandbox"]
 });
 for(const width of [390,1280]){
  for(const mode of ["dusk","light"]){
   const context=await browser.newContext({viewport:{width,height:850}});
   const page=await context.newPage();
   const faults=[];
   page.on("pageerror",e=>faults.push(e.message));
   page.on("response",r=>{
    if(r.url().startsWith(origin)&&r.status()>=400)faults.push(r.status()+" "+r.url());
   });
   await page.goto(origin+"index.html",{waitUntil:"load"});
   if(mode==="light")await page.locator(".nf-theme-toggle").click();
   for(const p of paths){
    await page.goto(origin+p,{waitUntil:"load"});
    const summary=await page.evaluate(colors=>{
      const obsolete=new Set(colors),leaks=[];
      const total=document.querySelectorAll("body *").length;
      const all=[document.body,...document.querySelectorAll("body *")];
      for(const e of all){
       if(e instanceof SVGElement || e.closest("svg"))continue;
       const r=e.getBoundingClientRect();
       if(r.width*r.height<1500||r.height<8||r.width<25)continue;
       const s=getComputedStyle(e);
       if(s.display==="none"||s.visibility==="hidden"||Number(s.opacity)===0)continue;
       if(obsolete.has(s.backgroundColor)){
        const path=e.id?"#"+e.id:e.className&&typeof e.className==="string"?"."+e.className.trim().split(/\s+/).slice(0,2).join("."):e.tagName.toLowerCase();
        leaks.push({el:path,parent:e.parentElement?.className||e.parentElement?.tagName,bg:s.backgroundColor,size:Math.round(r.width*r.height),sample:e.outerHTML.slice(0,140)});
       }
      }
      const html=getComputedStyle(document.documentElement);
      return {leaks:leaks.slice(0,20),total,
       bg:getComputedStyle(document.body).backgroundColor,
       theme:document.documentElement.dataset.nfTheme||"light",
       legacyBloodToken:html.getPropertyValue("--nf-oxblood-rare").trim(),
       moonlight:html.getPropertyValue("--nf-champagne").trim(),
       golden:html.getPropertyValue("--nf-goldenhour").trim(),
       overflow:document.documentElement.scrollWidth-innerWidth};
    },deprecated);
    const expected=mode==="dusk"?"rgb(4, 6, 11)":"rgb(36, 26, 52)";
    if(summary.bg!==expected)allCanvasLeaks.push({page:p,mode,width,bg:summary.bg,expected});
    assert.equal(summary.theme,mode,p+" expected mode");
    assert.ok(summary.overflow<=4,p+" "+mode+" "+width+"px overflow "+summary.overflow);
    if(summary.leaks.length)allSurfaceLeaks.push({page:p,mode,width,leaks:summary.leaks});
    if(mode==="dusk"){
      assert.equal(summary.legacyBloodToken,"",p+" no generic New Moon oxblood token");
      assert.equal(summary.moonlight,"#e2d28c",p+" moonlight remains primary");
      if(p==="index.html"){
        const accents=await page.evaluate(()=>{
          const style=selector=>{
            const el=document.querySelector(selector);
            if(!el)return null;
            const css=getComputedStyle(el);
            return {fill:css.fill,borderTop:css.borderTopColor,borderImage:css.borderImageSource,
              background:css.backgroundImage};
          };
          return {
            opening:style(".nf-opening-constellation .nf-opening-node--oxblood"),
            cinema:style(".nf-cinema-world--night"),
            flagship:style("#main>.flagships>.section-head"),
            colophon:style(".nf-experience-underbelly.nf-dual-colophon")
          };
        });
        for(const [name,value] of Object.entries(accents))assert.ok(value,"Expected New Moon element: "+name);
        assert.equal(accents.opening.fill,"rgb(167, 173, 215)","Opening node becomes moonlit lavender");
        assert.ok(accents.cinema.background.includes("rgba(74, 31, 36, 0.21)"),"Keep one admired oxblood cinematic gradient");
        assert.doesNotMatch(accents.flagship.borderImage,/74, 31, 36|167, 101, 115/,"Flagship divider is lavender to gold");
        assert.equal(accents.colophon.borderTop,"rgb(75, 86, 114)","Night colophon uses indigo, not oxblood");
      }
    }else assert.equal(summary.golden,"#e7b768",p+" Golden Hour accent remains primary");
   }
   assert.deepEqual(faults,[],mode+" "+width+"px no browser errors");
   await context.close();
  }
 }
 assert.deepEqual(allCanvasLeaks,[],"Unexpected theme canvases: "+JSON.stringify(allCanvasLeaks));
 assert.deepEqual(allSurfaceLeaks,[],"Visible obsolete surfaces "+allSurfaceLeaks.length+" pages: "+JSON.stringify(allSurfaceLeaks.slice(0,45)));
 const css=await readFile(join(root,"two-skies.css"),"utf8");
 assert.ok(!css.includes("--nf-oxblood-rare"),"Remove general-purpose oxblood design token from New Moon");
 assert.ok(!css.includes("--nf-oxblood-lit"),"Remove oxblood edge token from New Moon");
 assert.ok(!css.toLowerCase().includes("#4a1f24")&&!css.toLowerCase().includes("#a76573"),"No wine-red solid accents remain in shared theme");
 assert.equal(css.split("rgba(74,31,36,.21)").length-1,1,
   "Exactly one atmospheric oxblood gradient survives");
 console.log("PASS palette: 26 pages × two themes × two viewports; one cinematic blood gradient, lunar-gold controls, no overflow");
}finally{await browser?.close();await new Promise(resolve=>server.close(resolve))}
