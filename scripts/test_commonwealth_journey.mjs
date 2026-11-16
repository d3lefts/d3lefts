// End-to-end reproducible Commonwealth demos: browser session, historical coverage, and evidence export.
import assert from "node:assert/strict";
import {createServer} from "node:http";
import {readFile,writeFile,mkdir} from "node:fs/promises";
import {extname,resolve,join,normalize,sep} from "node:path";
import {chromium} from "playwright-core";
const root=resolve("docs"),output=resolve("browser-artifacts");
const mime={".html":"text/html;charset=utf-8",".js":"text/javascript;charset=utf-8",
".mjs":"text/javascript;charset=utf-8",".css":"text/css;charset=utf-8",".json":"application/json"};
const server=createServer(async(req,res)=>{
 try{
  const p=decodeURIComponent(new URL(req.url,"http://localhost").pathname).slice(1);
  const file=resolve(join(root,normalize(p||"index.html")));
  if(!file.startsWith(root+sep)){res.writeHead(403).end();return;}
  res.writeHead(200,{"Content-Type":mime[extname(file)]||"application/octet-stream"});
  res.end(await readFile(file));
 }catch(e){res.writeHead(404).end("Not found");}
});
await new Promise(done=>server.listen(0,"127.0.0.1",done));
const base="http://127.0.0.1:"+server.address().port+"/";
let browser;
try{
 browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_BIN||"/usr/bin/chromium",args:["--no-sandbox"]});
 await mkdir(output,{recursive:true});
 const directional=[1,1,1,-1,-1,1,-1,1,-1,1,1,-1,-1,-1,1,1,1,-1,-1,-1];
 for(const width of [390,1280]){
  const context=await browser.newContext({viewport:{width,height:850},reducedMotion:"reduce",acceptDownloads:true});
  const page=await context.newPage(),errors=[];
  page.on("pageerror",e=>errors.push(e.message));
  page.on("response",response=>{if(response.url().startsWith(base)&&response.status()>=400) errors.push(response.status()+" "+response.url());});
  await page.goto(base+"commonwealth-intelligence.html",{waitUntil:"load"});
  assert.equal(await page.locator("section.cw-section").first().getAttribute("id"),"discover");
  assert.equal(await page.locator("[data-cw-guide-link]").count(),5);
  await page.locator("#cw-start-quiz").click();
  assert.equal(await page.locator("#cw-quiz-back").isDisabled(),true);
  await page.locator('[data-quiz-choice="1"]').click();
  assert.match(await page.locator("#cw-quiz-number").innerText(),/Question 2/);
  await page.locator("#cw-quiz-back").click();
  assert.match(await page.locator("#cw-quiz-number").innerText(),/Question 1/);
  for(let i=0;i<20;i++)await page.locator('[data-quiz-choice="skip"]').click();
  assert.match(await page.locator("#cw-quiz-archetype").innerText(),/Insufficient information/);
  assert.equal(await page.locator("#cw-apply-archetype").isDisabled(),true);
  await page.locator("#cw-quiz-again").click();
  for(const x of directional)await page.locator('[data-quiz-choice="'+x+'"]').click();
  assert.equal(await page.locator("#cw-apply-archetype").isEnabled(),true);
  await page.locator("#cw-apply-archetype").click();
  assert.match(await page.locator("#cw-profile-insight").innerText(),/archetype/i);
  assert.match(await page.locator("#cw-profile-status").innerText(),/Unanswered/);
  await page.locator('[data-choice="SUPPORT"]').click();
  assert.equal((await page.locator("#cw-profile-status").innerText()).trim(),"Support");
  await page.locator("#cw-clear-preferences").click();
  assert.match(await page.locator("#cw-profile-insight").innerText(),/No quiz result added/);
  assert.match(await page.locator("#cw-profile-status").innerText(),/Unanswered/);
  await page.locator("#cw-issue").selectOption("fx-issue-riverfront");
  await page.locator("#cw-exact").check();
  assert.match(await page.locator("#cw-history-summary").innerText(),/4 linked proceeding/);
  await page.locator("#cw-issue").selectOption("fx-issue-transit");
  assert.match(await page.locator("#cw-history-summary").innerText(),/0 linked proceeding/);
  await page.reload({waitUntil:"load"});
  assert.match(await page.locator("#cw-profile-insight").innerText(),/No quiz result added/);
  assert.match(await page.locator("#cw-profile-status").innerText(),/Unanswered/);
  const overflow=await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth);
  assert.ok(overflow<=3,"Intelligence lab overflow: "+width+"px "+overflow);
  await page.screenshot({path:join(output,"cw-guided-"+width+".png"),fullPage:true});
  await page.goto(base+"commonwealth-browser/index.html",{waitUntil:"load"});
  await page.locator("#run").click();
  assert.match(await page.locator("#result").innerText(),/NOT OFFICIAL/);
  const [download]=await Promise.all([page.waitForEvent("download"),page.locator("#download").click()]);
  const exportFile=join(output,"cw-passport-"+width+".json");
  await download.saveAs(exportFile);
  await page.locator("#verify-input").setInputFiles(exportFile);
  await page.locator("#verify").click();
  assert.match(await page.locator("#verify-result").innerText(),/^MATCH:/);
  const json=JSON.parse(await readFile(exportFile,"utf8"));
  json.payload.profileId="TAMPERED";
  const altered=join(output,"cw-passport-tampered-"+width+".json");
  await writeFile(altered,JSON.stringify(json,null,2));
  await page.locator("#verify-input").setInputFiles(altered);
  await page.locator("#verify").click();
  assert.match(await page.locator("#verify-result").innerText(),/^MISMATCH:/);
  assert.deepEqual(errors,[],"No runtime failures or missing local assets");
  await context.close();
  console.log("PASS guided Discover, private profile, exact-source history and Passport verifier at "+width+"px");
 }
}finally{
 if(browser)await browser.close();
 await new Promise(done=>server.close(done));
}
