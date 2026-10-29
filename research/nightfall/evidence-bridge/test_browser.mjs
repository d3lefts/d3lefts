/* Real Chromium integration: consent, backup, reload persistence and tamper refusal. */
import assert from "node:assert/strict";
import {readFile} from "node:fs/promises";
import {createServer} from "node:http";
import {resolve,join,sep,extname} from "node:path";
import {chromium} from "playwright-core";
const root=resolve("docs"),types={".html":"text/html;charset=utf-8",".js":"text/javascript",".css":"text/css"};
const server=createServer(async(req,res)=>{
 try{
  const url=new URL(req.url,"http://localhost"),pathname=decodeURIComponent(url.pathname).replace(/^\/+/,"");
  const filename=resolve(join(root,pathname||"index.html"));
  if(filename!==root&&!filename.startsWith(root+sep)){res.writeHead(403).end("Forbidden");return}
  const bytes=await readFile(filename);
  res.writeHead(200,{"Content-Type":types[extname(filename)]||"application/octet-stream"}).end(bytes);
 }catch{res.writeHead(404).end("Missing")}
});
await new Promise(resolve=>server.listen(0,"127.0.0.1",resolve));
const port=server.address().port,origin="http://127.0.0.1:"+port+"/";
const dir=process.env.BRIDGE_FIXTURE_DIR||"/tmp/nightfall-bridge-fixtures";
const load=async name=>({name:name+".json",mimeType:"application/json",buffer:await readFile(join(dir,name+".json"))});
let browser;
try{
 browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_BIN||"/usr/bin/google-chrome",args:["--no-sandbox"]});
 for(const width of [390,1280]){
  const context=await browser.newContext({acceptDownloads:true,viewport:{width,height:850}});
  const page=await context.newPage(),errors=[];
  page.on("pageerror",e=>errors.push(e.message));
  page.on("response",r=>{if(r.url().startsWith(origin)&&r.status()>=400)errors.push("HTTP "+r.status()+" "+r.url())});
  await page.goto(origin+"claim-lab.html",{waitUntil:"load"});
  await page.locator("#newClaimBtn").click();
  await page.locator("#claimTitle").fill("Persistent research test / Ryev");
  await page.locator("#claimStatus").selectOption("3");
  await page.locator("#claimForm button[type=submit]").click();
  const saved=await page.evaluate(()=>localStorage.getItem("nightfall_claim_lab_v1"));
  assert.match(saved,/Persistent research test/,"Claim must save locally");
  const original=JSON.parse(saved),originalClaim=original.claims.find(c=>c.title==="Persistent research test / Ryev");
  assert.equal(originalClaim.status,3,"Preserve user-assigned theorem label without granting validity");
  await page.reload({waitUntil:"load"});
  assert.equal(await page.evaluate(()=>JSON.parse(localStorage.getItem("nightfall_claim_lab_v1")).claims.some(c=>c.title==="Persistent research test / Ryev")),true,"Reload preserves claim");
  for(const name of ["tamperedSidon"]){
   await page.locator("#receiptImportFile").setInputFiles(await load(name));
   await page.getByRole("status").filter({hasText:"Evidence Bridge refused"}).waitFor({state:"visible"});
   assert.equal(await page.evaluate(()=>localStorage.getItem("nightfall_claim_lab_v1")),saved,"Tamper refusal preserves original bytes");
  }
  await page.locator("#receiptImportFile").setInputFiles(await load("sidon"));
  await page.locator("#bridgeMask").waitFor({state:"visible"});
  assert.match(await page.locator("#bridgeMeta").innerText(),/Scientific review: unreviewed/);
  assert.equal(await page.evaluate(()=>localStorage.getItem("nightfall_claim_lab_v1")),saved,"Preview without approval cannot write");
  await page.locator("#bridgeCancel").click();
  assert.equal(await page.evaluate(()=>localStorage.getItem("nightfall_claim_lab_v1")),saved,"Cancel does not write");
  await page.locator("#receiptImportFile").setInputFiles(await load("sidon"));
  await page.locator("#bridgeMask").waitFor({state:"visible"});
  const [download]=await Promise.all([
   page.waitForEvent("download"),
   page.locator("#bridgeApprove").click()
  ]);
  assert.match(download.suggestedFilename(),/PRE_BRIDGE/,"Download recoverable backup before attachment");
  const after=JSON.parse(await page.evaluate(()=>localStorage.getItem("nightfall_claim_lab_v1")));
  assert.equal(after.claims.find(c=>c.id===originalClaim.id).status,3,"Review labels unchanged");
  assert.equal(after.experiments.length,original.experiments.length+1,"Exactly one approved unaudited attachment");
  const exp=after.experiments.at(-1);
  assert.equal(exp.status,"tested");assert.equal(exp.claimId,"");
  assert.match(exp.evidence,/BRIDGE-ID:[0-9a-f]{64}/);
  await page.reload({waitUntil:"load"});
  const reloaded=JSON.parse(await page.evaluate(()=>localStorage.getItem("nightfall_claim_lab_v1")));
  assert.deepEqual(reloaded,after,"Approved experiment and existing claims survive reload");
  await page.locator("#receiptImportFile").setInputFiles(await load("sidon"));
  await page.getByRole("status").filter({hasText:"DUPLICATE"}).waitFor({state:"visible"});
  assert.deepEqual(JSON.parse(await page.evaluate(()=>localStorage.getItem("nightfall_claim_lab_v1"))),after,"Duplicate cannot add a second experiment");
  const overflow=await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth);
  assert.ok(overflow<=3,"Bridge creates horizontal overflow at "+width);
  assert.deepEqual(errors,[],"Browser errors at "+width);
  await context.close();
 }
 console.log("PASS: Claim Lab save/reload, read-only preview, tamper refusal, cancel, downloaded backup, approved attach, durable reload, duplicate refusal, mobile and desktop.");
}finally{await browser?.close();await new Promise(resolve=>server.close(resolve))}
