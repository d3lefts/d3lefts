import test from "node:test";
import assert from "node:assert/strict";
import {createServer} from "node:http";
import {readFileSync, mkdirSync} from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {chromium} from "playwright-core";

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),"../docs");
const types={".html":"text/html; charset=utf-8",".css":"text/css; charset=utf-8",
  ".js":"text/javascript; charset=utf-8",".json":"application/json; charset=utf-8",
  ".svg":"image/svg+xml"};
function server(){
 return createServer((req,res)=>{
  const item=decodeURIComponent(new URL(req.url,"http://localhost").pathname).replace(/^\/+/, "");
  const full=path.resolve(root,item||"index.html");
  if(!full.startsWith(root+path.sep)){res.writeHead(403);res.end();return;}
  try{const data=readFileSync(full);res.writeHead(200,{"content-type":types[path.extname(full)]||"application/octet-stream"});res.end(data);}
  catch{res.writeHead(404);res.end();}
 });
}
test("Permission lab is interactive and usable on desktop and mobile Chromium", {timeout:90000}, async ()=>{
 const srv=server();
 await new Promise(resolve=>srv.listen(0,"127.0.0.1",resolve));
 const url="http://127.0.0.1:"+srv.address().port+"/permission-lab.html";
 const browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_BIN||"/usr/bin/google-chrome",
  args:["--no-sandbox","--disable-dev-shm-usage"]});
 try{
  const page=await browser.newPage({viewport:{width:1200,height:800}});
  const errors=[];
  page.on("pageerror",e=>errors.push(e.message));
  await page.goto(url,{waitUntil:"networkidle"});
  await page.locator("#pl-cost-result").waitFor();
  assert.equal(await page.locator('a[href="#practical-advantages"]').count(),1);
  assert.match(await page.locator("#pl-cost-result").innerText(),/26 modeled cost units/);
  assert.match(await page.locator("#pl-worlds").innerText(),/Right-only evidence: sufficient/);
  assert.match(await page.locator("#pl-compare-result").innerText(),/20%/);
  assert.match(await page.locator("#pl-compare-rows").innerText(),/Cannot finish/);
  await page.selectOption("#pl-compare-scenario","ample");
  assert.match(await page.locator("#pl-compare-result").innerText(),/No cost advantage/);
  await page.selectOption("#pl-compare-scenario","privacy");
  assert.match(await page.locator("#pl-compare-rows").innerText(),/15 units/);
  await page.selectOption("#pl-compare-scenario","tight");
  await page.uncheck("#pl-compare-changed");
  assert.match(await page.locator("#pl-compare-result").innerText(),/No cost advantage/);
  await page.check("#pl-compare-changed");
  await page.check("#pl-changed");
  assert.match(await page.locator("#pl-worlds").innerText(),/Right-only evidence: insufficient/);
  assert.match(await page.locator("#pl-proof-result").innerText(),/left \+ right/);
  await page.uncheck("#pl-allow-left");
  await page.uncheck("#pl-allow-direct");
  assert.match(await page.locator("#pl-proof-result").innerText(),/Indeterminate/);
  await page.locator('input[name="rawDisclosure"]').fill("7");
  assert.match(await page.locator("#pl-cost-result").innerText(),/29 modeled cost units/);
  await page.locator('input[name="spentSlots"]').fill("2");
  assert.equal((await page.locator("#pl-cost-result").innerText()).trim(),"NOT FEASIBLE");
  assert.deepEqual(errors,[]);
  mkdirSync("browser-artifacts",{recursive:true});
  await page.screenshot({path:"browser-artifacts/permission-lab-desktop.png",fullPage:true});
  const mobile=await browser.newPage({viewport:{width:375,height:812},deviceScaleFactor:2,isMobile:true,hasTouch:true});
  await mobile.goto(url,{waitUntil:"networkidle"});
  assert.match(await mobile.locator("#pl-cost-result").innerText(),/26 modeled cost units/);
  const sizes=await mobile.evaluate(()=>({viewport:document.documentElement.clientWidth,
    scroll:document.documentElement.scrollWidth}));
  assert.ok(sizes.scroll<=sizes.viewport+2,JSON.stringify(sizes));
  await mobile.screenshot({path:"browser-artifacts/permission-lab-mobile.png",fullPage:true});
  await mobile.close();
  await page.close();
 } finally{
  await browser.close();
  await new Promise(resolve=>srv.close(resolve));
 }
});
