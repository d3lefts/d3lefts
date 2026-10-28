import assert from "node:assert/strict";
import {createServer} from "node:http";
import {readFile} from "node:fs/promises";
import {join,normalize,resolve,sep} from "node:path";
import {chromium} from "playwright-core";

const root=resolve("docs");
const pages=["index.html","review.html","evidence.html","agenda.html","research.html"];
const types={".html":"text/html; charset=utf-8",".css":"text/css; charset=utf-8",".js":"text/javascript; charset=utf-8",".svg":"image/svg+xml"};
const server=createServer(async (req,res)=>{
 try{
  const pathname=decodeURIComponent(new URL(req.url,"http://localhost").pathname);
  const file=resolve(join(root,normalize(pathname).replace(/^\/+/,"")||"index.html"));
  if(file!==root&&!file.startsWith(root+sep)){res.writeHead(403).end();return;}
  const data=await readFile(file);
  const ext=file.slice(file.lastIndexOf("."));
  res.writeHead(200,{"Content-Type":types[ext]||"application/octet-stream"}).end(data);
 }catch{res.writeHead(404).end("Missing");}
});
await new Promise(resolve=>server.listen(0,"127.0.0.1",resolve));
const port=server.address().port;
const origin="http://127.0.0.1:"+port+"/";
let browser;
try{
 const executablePath=process.env.CHROME_BIN||"/usr/bin/chromium";
 browser=await chromium.launch({headless:true,executablePath,args:["--no-sandbox"]});
 for(const width of [390,768,1280]){
  const page=await browser.newPage({viewport:{width,height:850}});
  const faults=[];
  page.on("pageerror",e=>faults.push(e.message));
  page.on("response",r=>{if(r.url().startsWith(origin)&&r.status()>=400)faults.push(r.url()+" "+r.status());});
  for(const file of pages){
   await page.goto(origin+file,{waitUntil:"load"});
   const menu=page.locator("#menu-button");
   const nav=page.locator("#site-nav");
   assert.equal(await menu.count(),1,file+" missing menu");
   assert.equal(await nav.count(),1,file+" missing nav");
   const mobile=width<=900;
   assert.equal(await menu.isVisible(),mobile,file+" menu visibility at "+width);
   assert.equal(await nav.isVisible(),!mobile,file+" nav visibility at "+width);
   if(mobile){
    await menu.click();
    assert.equal(await menu.getAttribute("aria-expanded"),"true",file+" expand state");
    assert.equal(await nav.isVisible(),true,file+" menu opens");
    const links=nav.locator("a");
    for(let j=0;j<await links.count();j++)
     assert.equal(await links.nth(j).isVisible(),true,file+" hidden menu link "+j);
    await page.keyboard.press("Escape");
    assert.equal(await nav.isVisible(),false,file+" Escape closes menu");
    assert.equal(await menu.getAttribute("aria-expanded"),"false",file+" Escape state");
   }
   const overflow=await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth);
   if(overflow>3){
    const culprits=await page.evaluate(()=>[...document.body.querySelectorAll("*")].map(el=>({el,rect:el.getBoundingClientRect()})).filter(x=>x.rect.right>innerWidth+3&&x.rect.width>0).slice(0,8).map(x=>({tag:x.el.tagName,class:x.el.className?.baseVal??x.el.className,scrollWidth:x.el.scrollWidth,right:Math.round(x.rect.right)})));
    assert.fail(file+" horizontal overflow "+overflow+"px at "+width+"; culprits="+JSON.stringify(culprits));
   }
  }
  await page.goto(origin+"discovery.html",{waitUntil:"load"});
  assert.equal(await page.locator(".context h1").innerText(),"Minimum overlap · EA #36","Discovery Engine initial project");
  await page.locator('[data-tab="experiments"]').first().click();
  await page.locator("#prediction").fill("Finite toy max <= 3");
  await page.locator('[data-act="run"]').first().click();
  assert.equal(await page.locator(".evidence").count(),1,"Discovery experiment saved");
  assert.match(await page.locator(".audit-flags").innerText(),/DIRECT REPLAY PASS/,"Exact second-path replay");
  await page.locator("[data-replay]").first().click();
  await page.locator("[data-tab=package]").first().click();
  const [zipDownload]=await Promise.all([page.waitForEvent("download"),page.locator("[data-act=export]").first().click()]);
  assert.match(zipDownload.suggestedFilename(),/\.zip$/,"Exported ZIP");
  const engineOverflow=await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth);
  assert.ok(engineOverflow<=3,"Discovery overflow: "+engineOverflow+" at "+width);
  await page.locator('[data-project="sidon"]').click();
  await page.locator('[data-tab="experiments"]').first().click();
  await page.locator("#prediction").fill("Sidon original proof certificate should survive independent review");
  await page.locator('[data-act="run"]').first().click();
  assert.equal(await page.locator(".evidence").count(),1,"Sidon external research manifest saved");
  assert.match(await page.locator(".evidence").innerText(),/EXTERNAL RUN PENDING/,"No invented mathematical result");
  assert.equal(await page.locator(".portfolio").count(),3,"Only original research presets shown");
  if(width===390){
   await page.goto(origin+"index.html",{waitUntil:"load"});
   await page.locator("#project-search").fill("werner");
   assert.equal(await page.locator("#project-list .research-row").count(),0,"original-only catalogue excludes Werner");
   await page.locator("#project-search").fill("");
   assert.equal(await page.locator("#project-list .research-row").count(),3,"three curated original results reset");
  }
  if(width===390){
    await page.goto(origin+"research.html",{waitUntil:"load"});
    assert.equal(await page.locator(".atlas-card:visible").count(),23,"23 curated research entries");
    await page.locator('[data-atlas-filter="quantum"]').click();
    assert.equal(await page.locator(".atlas-card:visible").count(),3,"quantum source entries");
    await page.locator('[data-atlas-filter="all"]').click();
    await page.locator("#atlas-search").fill("SourceBound");
    assert.equal(await page.locator(".atlas-card:visible").count(),1,"library source search");
    await page.locator("#atlas-search").fill("");
    assert.equal(await page.locator(".atlas-card:visible").count(),23,"library filter reset");
  }
  if(width===390){
    await page.goto(origin+"agenda.html",{waitUntil:"load"});
    assert.equal(await page.locator("#agenda-list .research-proposal:visible").count(),10,"ten proposals");
    for(const cat of ["mathematics","quantum","super-intelligence","safety","systems"]){
      await page.locator('[data-agenda-filter="'+cat+'"]').click();
      assert.equal(await page.locator("#agenda-list .research-proposal:visible").count(),2,cat+" has two proposed studies");
    }
    await page.locator('[data-agenda-filter="all"]').click();
    await page.locator("#agenda-search").fill("SourceBound");
    assert.equal(await page.locator("#agenda-list .research-proposal:visible").count(),1,"SourceBound search");
    await page.locator("#agenda-search").fill("");
    assert.equal(await page.locator("#agenda-list .research-proposal:visible").count(),10,"agenda search reset");
  }
  assert.deepEqual(faults,[],"Browser failures at "+width+": "+faults.join("; "));
  await page.close();
 }
 console.log("PASS: 3 original-portfolio pages plus Discovery Engine × 3 widths, exact experiment and ZIP export");
}finally{
 await browser?.close();
 await new Promise(resolve=>server.close(resolve));
}
