// Browser acceptance test for the independent Commonwealth *release*, not the NIGHTFALL host.
import assert from "node:assert/strict";
import {createServer} from "node:http";
import {readFile, mkdir} from "node:fs/promises";
import {resolve, join, extname, sep} from "node:path";
import {chromium} from "playwright-core";

const root=resolve(process.argv[2] || "/tmp/commonwealth-repository/site");
const mime={".html":"text/html; charset=utf-8",".js":"text/javascript; charset=utf-8",
  ".mjs":"text/javascript; charset=utf-8",".css":"text/css; charset=utf-8",
  ".svg":"image/svg+xml",".json":"application/json",".xml":"application/xml"};
const server=createServer(async(req,res)=>{
  try{
    const u=new URL(req.url,"http://localhost");
    const relative=decodeURIComponent(u.pathname).replace(/^\/+/,"")||"index.html";
    const absolute=resolve(join(root,relative));
    if(absolute!==root&&!absolute.startsWith(root+sep)){res.writeHead(403).end();return;}
    const bytes=await readFile(absolute);
    res.writeHead(200,{"Content-Type":mime[extname(absolute)]||"application/octet-stream",
      "X-Content-Type-Options":"nosniff"}).end(bytes);
  }catch{res.writeHead(404).end("Not Found");}
});
await new Promise(ok=>server.listen(0,"127.0.0.1",ok));
let browser;
try{
  browser=await chromium.launch({headless:true,
    executablePath:process.env.CHROME_BIN||"/usr/bin/chromium",
    args:["--no-sandbox","--disable-dev-shm-usage"]});
  const origin="http://127.0.0.1:"+server.address().port+"/";
  await mkdir("browser-artifacts",{recursive:true});
  for(const width of [390,1280]){
    const context=await browser.newContext({viewport:{width,height:850},reducedMotion:"reduce"});
    const page=await context.newPage();
    const errors=[];
    page.on("pageerror",error=>errors.push("JS: "+error.message));
    page.on("response",response=>{
      if(response.url().startsWith(origin)&&response.status()>=400)
        errors.push("HTTP "+response.status()+" "+response.url());
    });
    const journeys=[
      ["index.html","A More Informed Republic"],
      ["commonwealth-os.html","Commonwealth"],
      ["commonwealth-intelligence.html","Commonwealth"],
      ["commonwealth-browser/index.html","Commonwealth"],
      ["commonwealth-demos/living-voter.html","Living Voter"]
    ];
    for(const [route,title] of journeys){
      const response=await page.goto(origin+route,{waitUntil:"load",timeout:30000});
      assert.equal(response.status(),200,"Unavailable page "+route);
      assert.match(await page.title(),new RegExp(title,"i"),route+" title");
      assert.ok(await page.locator("main").count()>0,"No main element: "+route);
      assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+4),
        route+" overflows "+width+"px screen");
      await page.waitForTimeout(200);
    }
    await page.goto(origin,{waitUntil:"load"});
    assert.equal(await page.locator('link[href="site.css"],script[src="site.js"]').count(),0,
      "No NIGHTFALL runtime should be loaded");
    assert.equal(await page.locator(".nf-home-route-nav,.nf-journey-rail").count(),0,
      "No research navigation in independent Commonwealth");
    assert.equal(await page.locator("a[href='./']").count()>0,true,"Independent civic home missing");
    if(width===390){
      const menu=page.locator("#menu-button");
      assert.equal(await menu.isVisible(),true,"Mobile menu is unavailable");
      await menu.click();
      assert.equal(await menu.getAttribute("aria-expanded"),"true");
      assert.equal(await page.locator("#site-nav").evaluate(el=>el.classList.contains("open")),true);
      await page.screenshot({path:"browser-artifacts/commonwealth-independent-mobile.png",fullPage:false});
      await menu.click();
      assert.equal(await menu.getAttribute("aria-expanded"),"false");
    }else{
      await page.screenshot({path:"browser-artifacts/commonwealth-independent-desktop.png",fullPage:false});
    }
    assert.deepEqual(errors,[],width+"px browser faults");
    await context.close();
  }
  console.log("PASS: independent Commonwealth root, workbench, Discover, browser and Living Voter at 390/1280px; menu, local resources and no NIGHTFALL chrome");
}finally{
  await browser?.close();
  await new Promise(ok=>server.close(ok));
}
