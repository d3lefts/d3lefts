import assert from "node:assert/strict";
import {createServer} from "node:http";
import {readFile} from "node:fs/promises";
import {extname,resolve,join,sep} from "node:path";
import {chromium} from "playwright-core";

const root=resolve("docs");
const mime={".html":"text/html; charset=utf-8",".js":"text/javascript; charset=utf-8",".css":"text/css; charset=utf-8",".svg":"image/svg+xml"};
const server=createServer(async(req,res)=>{
 try{
  const raw=new URL(req.url,"http://localhost").pathname;
  const file=resolve(join(root,decodeURIComponent(raw).replace(/^\/+/, "")||"index.html"));
  if(file!==root&&!file.startsWith(root+sep)){res.writeHead(403).end();return;}
  const bytes=await readFile(file);
  res.writeHead(200,{"Content-Type":mime[extname(file)]||"text/plain"}).end(bytes);
 }catch(e){res.writeHead(404).end("Missing");}
});
await new Promise(resolve=>server.listen(0,"127.0.0.1",resolve));
const url="http://127.0.0.1:"+server.address().port;
let browser;
try{
 browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_BIN||"/usr/bin/chromium",args:["--no-sandbox"]});
 for(const width of [390,1280]){
  const page=await browser.newPage({viewport:{width,height:850}});
  const faults=[];
  page.on("pageerror",e=>faults.push(e.message));
  page.on("response",r=>{if(r.url().startsWith(url)&&r.status()>=400)faults.push(r.url()+": "+r.status());});
  await page.goto(url+"/frontier.html",{waitUntil:"load"});
  assert.equal(await page.locator(".fr-rank").count(),3,"three sourced issues ranked");
  assert.match(await page.locator("#frontier-rankings").innerText(),/Nine marks/,"N184 ranks first");
  assert.match(await page.locator("#frontier-claim-status").innerText(),/Unclaimed/);
  await page.locator("#frontier-near").click();
  await page.locator("#frontier-check").click();
  assert.match(await page.locator("#frontier-result").innerText(),/16, 166/,"Two exact near-candidate blockers");
  assert.match(await page.locator("#frontier-result").innerText(),/NOT_MAXIMAL/);
  await page.locator("#frontier-claim").click();
  assert.match(await page.locator("#frontier-claim-status").innerText(),/Claimed in this browser only/);
  await page.locator("#frontier-child-title").fill("Classify the two remaining insertion blockers");
  await page.locator("#frontier-child-falsifier").fill("One valid nine-mark maximal Sidon witness in the full interval.");
  await page.locator("#frontier-split-form button[type=submit]").click();
  assert.match(await page.locator("#frontier-active-title").innerText(),/Classify the two remaining/);
  assert.equal(await page.locator(".fr-branch").count(),4,"Child kept in dependency tree");
  const payload=await page.evaluate(()=>JSON.parse(localStorage.getItem("nightfall_frontier_local_v1")));
  assert.equal(payload.children.length,1);assert.equal(payload.children[0].parent,"NF-156-184:witness");
  await page.reload({waitUntil:"load"});
  assert.equal(await page.locator(".fr-branch").count(),4,"Local child survives reload");
  await page.locator("#frontier-orchestrate").click();
  await page.waitForURL(/orchestrator\.html/);
  assert.match(await page.locator("#claim-text").inputValue(),/Classify the two remaining/);
  assert.match(await page.locator("#orch-message").innerText(),/editable local fields/);
  assert.equal(await page.locator("#orch-export").isDisabled(),true,"Handoff cannot dispatch plan or certify claim");
  await page.goto(url+"/frontier.html",{waitUntil:"load"});
  await page.locator(".fr-rank").nth(1).click();
  assert.match(await page.locator("#problem-head").innerText(),/Q7/);
  assert.equal(await page.locator("#frontier-witness-section").isHidden(),true,"Checker is domain scoped");
  await page.locator(".fr-rank").nth(2).click();
  assert.match(await page.locator("#problem-head").innerText(),/lower-bound operator/);
  const overflow=await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth);
  assert.ok(overflow<=3,"No horizontal overflow at width "+width+": "+overflow);
  assert.deepEqual(faults,[],"No browser exception or failed local asset");
  await page.close();
 }
 console.log("PASS Frontier triage, finite replay, local claim, child decomposition, persistence, Orchestrator handoff, mobile/desktop layout");
}finally{await browser?.close();await new Promise(resolve=>server.close(resolve));}
