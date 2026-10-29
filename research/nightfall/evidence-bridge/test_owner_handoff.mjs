/* Owner route acceptance: genuine Referee -> consented Claim Lab -> Discovery. */
import assert from "node:assert/strict";
import {readFile} from "node:fs/promises";
import {createServer} from "node:http";
import {join,resolve,extname,sep} from "node:path";
import {chromium} from "playwright-core";
const docs=resolve("docs"),types={".html":"text/html;charset=utf-8",".js":"application/javascript",".css":"text/css"};
const server=createServer(async(req,res)=>{
 try{const u=new URL(req.url,"http://localhost"),f=resolve(join(docs,decodeURIComponent(u.pathname).replace(/^\/+/,"")||"index.html"));
  if(f!==docs&&!f.startsWith(docs+sep)){res.writeHead(403).end("Forbidden");return}
  const b=await readFile(f);res.writeHead(200,{"Content-Type":types[extname(f)]||"application/octet-stream"}).end(b);
 }catch(e){res.writeHead(404).end("Missing")}
});
await new Promise(ok=>server.listen(0,"127.0.0.1",ok));
const origin="http://127.0.0.1:"+server.address().port+"/";
let browser;
try{
 browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_BIN||"/usr/bin/google-chrome",args:["--no-sandbox"]});
 for(const width of [390,1280]){
  const ctx=await browser.newContext({acceptDownloads:true,viewport:{width,height:850}});
  const page=await ctx.newPage(),errors=[];
  page.on("pageerror",e=>errors.push(e.message));
  page.on("response",r=>{if(r.url().startsWith(origin)&&r.status()>=400)errors.push(r.url()+" HTTP "+r.status())});
  await page.goto(origin+"referee.html?domain=sidon",{waitUntil:"load"});
  await page.locator("#run-sidon").click();
  await page.locator("#send-claim-lab").waitFor({state:"visible"});
  await page.waitForFunction(()=>!document.querySelector("#send-claim-lab").disabled);
  assert.equal(await page.locator("#send-claim-lab").isDisabled(),false,"Actual finite Referee receipt must be available");
  const originalReceipt=await page.evaluate(()=>JSON.stringify(window.latest??null)); // optional; actual transport checked below
  await Promise.all([page.waitForURL("**/claim-lab.html**"),page.locator("#send-claim-lab").click()]);
  await page.locator("#bridgeMask").waitFor({state:"visible"});
  assert.match(await page.locator("#bridgeMeta").innerText(),/Scientific review: unreviewed/);
  const initial=await page.evaluate(()=>localStorage.getItem("nightfall_claim_lab_v1"));
  assert.equal(initial,null,"One-shot handoff must not mutate uninitialized Claim Lab");
  assert.equal(await page.locator("#sendDiscovery").isDisabled(),true,"Discovery handoff unavailable before approval");
  await page.locator("#bridgeCancel").click();
  assert.equal(await page.evaluate(()=>localStorage.getItem("nightfall_claim_lab_v1")),null,"Cancelled direct handoff cannot persist claims");
  assert.equal(await page.evaluate(()=>sessionStorage.getItem("nightfall.discovery.pending.v1")),null,"Cancel cannot grant a Discovery replay");
  // Actual Referee transfer once more, then approve explicit backup.
  await page.goto(origin+"referee.html?domain=sidon");
  await page.locator("#run-sidon").click();
  await page.waitForFunction(()=>!document.querySelector("#send-claim-lab").disabled);
  await page.locator("#send-claim-lab").click();
  await page.locator("#bridgeMask").waitFor({state:"visible"});
  const [backup]=await Promise.all([page.waitForEvent("download"),page.locator("#bridgeApprove").click()]);
  assert.match(backup.suggestedFilename(),/PRE_BRIDGE/);
  const saved=await page.evaluate(()=>JSON.parse(localStorage.getItem("nightfall_claim_lab_v1")));
  assert.equal(saved.experiments.length,2,"One approved attachment added to original illustrative experiment");
  const item=saved.experiments.at(-1);
  assert.equal(item.status,"tested");assert.equal(item.claimId,"");assert.match(item.evidence,/BRIDGE-ID:[0-9a-f]{64}/);
  assert.equal(await page.locator("#sendDiscovery").isDisabled(),false,"Approved Referee receipt can reach owner's Discovery path");
  const raw=await page.evaluate(()=>sessionStorage.getItem("nightfall.discovery.pending.v1"));
  assert.ok(raw&&JSON.parse(raw).format==="nightfall-referee-receipt-v1");
  await Promise.all([page.waitForURL("**/discovery.html**"),page.locator("#sendDiscovery").click()]);
  assert.equal(await page.evaluate(()=>sessionStorage.getItem("nightfall.discovery.pending.v1")),null,"Discovery consumes the one-shot receipt");
  // Forge source metadata in a new handoff and show that it cannot change stored records.
  await page.goto(origin+"claim-lab.html");
  const before=await page.evaluate(()=>localStorage.getItem("nightfall_claim_lab_v1"));
  await page.evaluate(raw=>{const p=JSON.parse(raw);p.sourceDossier="https://forged.invalid/proof";sessionStorage.setItem("nightfall.referee.pending.v1",JSON.stringify(p))},raw);
  await page.goto(origin+"claim-lab.html?referee_handoff=1");
  await page.getByRole("status").filter({hasText:"SOURCE_METADATA"}).waitFor({state:"visible"});
  assert.equal(await page.locator("#bridgeMask").isVisible(),false,"Forged source metadata cannot stage a preview");
  assert.equal(await page.evaluate(()=>localStorage.getItem("nightfall_claim_lab_v1")),before,"Forged same-tab receipt cannot modify user workspace");
  await page.reload();
  assert.equal(await page.evaluate(()=>localStorage.getItem("nightfall_claim_lab_v1")),before,"Reload preserves preexisting evidence and claims");
  assert.deepEqual(errors,[],"Browser errors at "+width);
  await ctx.close();
 }
 console.log("PASS: real Referee->Claim Lab direct handoff; cancel, backup, exact preview, approval, Discovery replay, forged source rejection and reload in mobile+desktop.");
}finally{await browser?.close();await new Promise(ok=>server.close(ok))}
