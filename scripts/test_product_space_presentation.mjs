// Site owner's November 2026 final QA: publication-scope fidelity,
// visual layout, local dependencies, keyboard paths and responsive overflow.
// Checks the currently published dossier, not the mathematical conjectures.
import assert from "node:assert/strict";
import { createServer } from "node:http";
import { readFile, mkdir } from "node:fs/promises";
import { extname, join, normalize, resolve, sep } from "node:path";
import { chromium } from "playwright-core";

const root = resolve("docs");
const mime = {".html":"text/html; charset=utf-8",".css":"text/css; charset=utf-8",
              ".js":"text/javascript; charset=utf-8",".svg":"image/svg+xml"};
const server = createServer(async (req,res) => {
  try {
    const url=new URL(req.url,"http://localhost");
    const name=decodeURIComponent(url.pathname).replace(/^\/+/, "") || "index.html";
    const file=resolve(join(root,normalize(name)));
    if(file!==root && !file.startsWith(root+sep)){res.writeHead(403).end();return;}
    res.writeHead(200,{"Content-Type":mime[extname(file)]||"application/octet-stream"});
    res.end(await readFile(file));
  } catch {res.writeHead(404).end("Missing");}
});
await new Promise(ok => server.listen(0,"127.0.0.1",ok));
const base="http://127.0.0.1:"+server.address().port+"/";
let browser;
try{
  await mkdir("browser-artifacts",{recursive:true});
  browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_BIN||"/usr/bin/chromium",args:["--no-sandbox"]});
  for(const width of [390,768,1280]){
    const ctx=await browser.newContext({viewport:{width,height:840},reducedMotion:"reduce"});
    const page=await ctx.newPage();
    const failures=[];
    page.on("pageerror",e=>failures.push("script: "+e.message));
    page.on("response",r=>{if(r.url().startsWith(base) && r.status()>=400)failures.push("asset "+r.status()+" "+r.url());});
    await page.goto(base+"product-space-influence.html",{waitUntil:"load"});
    assert.equal(await page.locator("h1").count(),1,"one document heading");
    assert.equal(await page.locator(".ps-ledger-row").count(),3,"all three formal proof groups remain");
    assert.equal(await page.locator(".ps-formula").count(),2,"both proposed mathematical claims remain explicitly labeled");
    assert.equal(await page.locator('link[href="product-space.css"]').count(),1,"scoped stylesheet must load");
    const layout=await page.evaluate(()=>{
      const el=document.querySelector(".ps-ledger-row");
      const eq=document.querySelector(".ps-formula");
      return {
        grid:getComputedStyle(el).display,
        columns:getComputedStyle(el).gridTemplateColumns.split(" ").length,
        ruled:getComputedStyle(el).borderTopStyle,
        equationBorder:getComputedStyle(eq).borderLeftStyle,
        overflow:document.documentElement.scrollWidth-innerWidth,
      };
    });
    const readability=await page.evaluate(()=>{
      const intro=getComputedStyle(document.querySelector(".atlas-hero-bottom>p")).color;
      const bodyInk=getComputedStyle(document.body).color;
      const emphasis=getComputedStyle(document.querySelector(".atlas-hero h1 em")).color;
      const marker=document.createElement("span");
      marker.style.color="var(--accent)";
      document.body.append(marker);
      const accent=getComputedStyle(marker).color;
      marker.remove();
      return {intro,bodyInk,emphasis,accent};
    });
    assert.equal(readability.intro,readability.bodyInk,"hero introduction must use readable foreground ink");
    // Both skies intentionally permit different serif highlight colors.
    // Check readability instead of forcing an identical palette token.
    const rgb=str=>str.match(/\d+/g).slice(0,3).map(Number);
    const luminance=vals=>vals.map(v=>{v/=255;return v<=0.04045?v/12.92:((v+0.055)/1.055)**2.4;})
      .reduce((s,v,i)=>s+[.2126,.7152,.0722][i]*v,0);
    const contrast=(a,b)=>{
      const x=luminance(rgb(a)),y=luminance(rgb(b));
      return (Math.max(x,y)+.05)/(Math.min(x,y)+.05);
    };
    const minEmphasisContrast=Math.min(...["rgb(2,4,6)","rgb(4,6,11)","rgb(16,23,39)"]
      .map(bg=>contrast(readability.emphasis,bg)));
    assert.ok(minEmphasisContrast>=4.5,
      "serif highlight must be legible on both dark canvases: "+JSON.stringify(readability));
    assert.equal(layout.grid,"grid","formalization is styled as a grid, not raw body text");
    assert.equal(layout.ruled,"solid","evidence rows have visual boundaries");
    assert.equal(layout.equationBorder,"solid","proposed formula has a clear evidence boundary");
    assert.ok(layout.overflow<=3,"no horizontal overflow at "+width+"px: "+JSON.stringify(layout));
    if(width===390)assert.equal(layout.columns,1,"mobile formalization stacks");
    const text=await page.locator("main").innerText();
    for(const value of ["not a certified general theorem","not yet a Lean theorem","reciprocal all-pairs","Global novelty","source hashes"]){
      assert.ok(text.toLowerCase().includes(value.toLowerCase()),"publication boundary missing: "+value);
    }
    for(const anchor of ["claims-title","formalization","open-proof-obligations","source-credit"]){
      const link=page.locator('.ps-quick-nav a[href="#'+anchor+'"]');
      assert.equal(await link.count(),1,"quick navigation "+anchor);
      assert.equal(await page.locator("#"+anchor).count(),1,"anchor destination "+anchor);
    }
    if(width===390){
      const menu=page.locator("#menu-button");
      assert.equal(await menu.isVisible(),true,"mobile menu is accessible");
      await menu.click();
      assert.equal(await menu.getAttribute("aria-expanded"),"true");
      await page.keyboard.press("Escape");
      assert.equal(await menu.getAttribute("aria-expanded"),"false");
    }
    await page.screenshot({path:"browser-artifacts/product-space-dossier-"+width+".png",fullPage:false});
    await page.locator("#formalization").screenshot({path:"browser-artifacts/product-space-proofs-"+width+".png"});
    assert.deepEqual(failures,[],"no local network errors or page script faults at "+width);
    await ctx.close();
  }
  console.log("PASS product-space dossier: 3 widths, 3 proof groups, 2 explicit proposed inequalities, proof-scope disclosures, navigation, visual tokens, readable text and no overflow");
} finally {
  if(browser)await browser.close();
  server.close();
}
