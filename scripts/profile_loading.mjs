/* NIGHTFALL repeatable synthetic page-load profile.
 * Run: CHROME_BIN="$(which google-chrome)" node scripts/profile_loading.mjs
 * Optional PERF_ORIGIN=https://d3lefts.github.io/d3lefts/ (public deployment)
 * Captures measured CDP encoded transfer, lab timings, Web Vitals observers,
 * resource waterfalls, and a bounded scroll-animation sample. Not field RUM. */
import assert from "node:assert/strict";
import {createServer} from "node:http";
import {readFile,mkdir,writeFile} from "node:fs/promises";
import {resolve,join,normalize,sep,extname} from "node:path";
import {chromium} from "playwright-core";

const profiles=[
 {id:"mobile",width:390,height:844,cpu:4,rtt:110,down:1_600_000/8},
 {id:"desktop",width:1440,height:900,cpu:1,rtt:0,down:0}
];
const routes=["index.html","constellation.html","review.html"];
const themes=["dusk","light"];
const repeats=Math.max(1,Math.min(5,Number(process.env.PERF_REPEATS||2)));
const root=resolve("docs");
const types={".html":"text/html; charset=utf-8",".css":"text/css; charset=utf-8",".js":"text/javascript; charset=utf-8",".svg":"image/svg+xml",".json":"application/json; charset=utf-8",".txt":"text/plain; charset=utf-8",".woff2":"font/woff2"};
let server;
if(!process.env.PERF_ORIGIN){
 server=createServer(async(req,res)=>{
  try{
   const pathname=decodeURIComponent(new URL(req.url,"http://localhost").pathname);
   const file=resolve(join(root,normalize(pathname).replace(/^\/+/, "")||"index.html"));
   if(file!==root&&!file.startsWith(root+sep)){res.writeHead(403).end();return;}
   const data=await readFile(file);
   res.writeHead(200,{"Content-Type":types[extname(file)]||"application/octet-stream","Cache-Control":"no-store"}).end(data);
  }catch{res.writeHead(404).end("Missing");}
 });
 await new Promise(resolve=>server.listen(0,"127.0.0.1",resolve));
}
const origin=(process.env.PERF_ORIGIN||"http://127.0.0.1:"+server.address().port+"/").replace(/\/*$/,"/");
const machine={source:process.env.PERF_ORIGIN?"public-live-host":"local-static-http",protocol:"cold cache each navigation; HTTP RTT and CPU emulation on mobile; content unchanged",chrome:process.env.CHROME_BIN||"/usr/bin/chromium",repeats,dates:new Date().toISOString(),origin:process.env.PERF_ORIGIN?origin:"127.0.0.1 ephemeral port"};
const round=(x,d=1)=>Number(Number(x??0).toFixed(d));
const median=(xs,d=1)=>{const s=[...xs].sort((a,b)=>a-b);return round(s.length%2?s[(s.length-1)/2]:(s[s.length/2-1]+s[s.length/2])/2,d)};
const samples=[],grouped={};
let browser;
try{
 await mkdir("browser-artifacts",{recursive:true});
 browser=await chromium.launch({headless:true,executablePath:machine.chrome,args:["--no-sandbox"]});
 for(const profile of profiles)for(const theme of themes)for(const route of routes)for(let n=0;n<repeats;n++){
  const context=await browser.newContext({viewport:{width:profile.width,height:profile.height},deviceScaleFactor:profile.id==="mobile"?2:1});
  await context.addInitScript(value=>{try{localStorage.setItem("nightfall.theme.v1",value)}catch{}},theme);
  await context.addInitScript(()=>{
   window.__nfVitals={lcp:0,cls:0,longTasks:[],fcp:0};
   if(!window.PerformanceObserver)return;
   const o=window.__nfVitals;
   for(const [type,handler] of [
    ["largest-contentful-paint",e=>{o.lcp=Math.max(o.lcp,e.startTime)}],
    ["layout-shift",e=>{if(!e.hadRecentInput)o.cls+=e.value}],
    ["longtask",e=>o.longTasks.push({start:Math.round(e.startTime),ms:Math.round(e.duration)})],
    ["paint",e=>{if(e.name==="first-contentful-paint")o.fcp=e.startTime}]
   ])try{new PerformanceObserver(l=>{for(const e of l.getEntries())handler(e)}).observe({type,buffered:true})}catch{}
  });
  const page=await context.newPage();
  const cdp=await context.newCDPSession(page);
  await cdp.send("Network.enable");
  await cdp.send("Network.setCacheDisabled",{cacheDisabled:true});
  await cdp.send("Performance.enable");
  await cdp.send("Emulation.setCPUThrottlingRate",{rate:profile.cpu});
  if(profile.rtt)await cdp.send("Network.emulateNetworkConditions",{offline:false,latency:profile.rtt,downloadThroughput:profile.down,uploadThroughput:100_000,connectionType:"cellular4g"});
  const reqs=new Map(),errors=[];
  cdp.on("Network.responseReceived",e=>reqs.set(e.requestId,{url:e.response.url,status:e.response.status,type:e.type,mime:e.response.mimeType,encoded:0,cache:e.response.fromDiskCache||e.response.fromServiceWorker}));
  cdp.on("Network.loadingFinished",e=>{const q=reqs.get(e.requestId);if(q)q.encoded=e.encodedDataLength||0;});
  page.on("pageerror",e=>errors.push(String(e.message).slice(0,170)));
  page.on("response",r=>{if(r.url().startsWith(origin)&&r.status()>=400)errors.push(r.url()+" "+r.status())});
  await page.goto(origin+route,{waitUntil:"load",timeout:60_000});
  await page.waitForTimeout(650);
  const perf=await page.evaluate(()=>{
   const nav=performance.getEntriesByType("navigation")[0];
   const paint=performance.getEntriesByType("paint").find(e=>e.name==="first-contentful-paint");
   const v=window.__nfVitals||{};
   return {ttfb:nav?.responseStart||0,domReady:nav?.domContentLoadedEventEnd||0,
    load:nav?.loadEventEnd||0,fcp:paint?.startTime||v.fcp||0,lcp:v.lcp||0,cls:v.cls||0,
    longTasks:v.longTasks||[],currentTheme:document.documentElement.getAttribute("data-nf-theme")||"light"};
  });
  const assets=[...reqs.values()].filter(x=>x.url.startsWith(origin));
  const total=round(assets.reduce((sum,x)=>sum+x.encoded,0),0);
  const byType={};for(const a of assets){
   const ext=extname(new URL(a.url).pathname)||"document";
   byType[ext]=(byType[ext]||0)+a.encoded;
  }
  Object.keys(byType).forEach(k=>byType[k]=round(byType[k],0));
  let scroll=null;
  if(route==="index.html"&&n===0){
   const before=Object.fromEntries((await cdp.send("Performance.getMetrics")).metrics.map(x=>[x.name,x.value]));
   const frames=await page.evaluate(async()=>{
    const gaps=[];let old=0;
    const max=Math.max(1,document.documentElement.scrollHeight-innerHeight);
    await new Promise(resolve=>{
     let i=0;
     function next(t){
      if(old)gaps.push(t-old);old=t;
      scrollTo(0,max*i/75);
      if(++i<76)requestAnimationFrame(next);else resolve();
     }requestAnimationFrame(next);
    });
    return {medianFrameMs:gaps.sort((a,b)=>a-b)[Math.floor(gaps.length/2)]||0,
     framesOver50:gaps.filter(x=>x>50).length,frameCount:gaps.length};
   });
   const after=Object.fromEntries((await cdp.send("Performance.getMetrics")).metrics.map(x=>[x.name,x.value]));
   scroll={...frames,
    scriptCpuMs:round(1000*((after.ScriptDuration||0)-(before.ScriptDuration||0))),
    styleCpuMs:round(1000*((after.RecalcStyleDuration||0)-(before.RecalcStyleDuration||0))),
    layoutCpuMs:round(1000*((after.LayoutDuration||0)-(before.LayoutDuration||0)))};
  }
  assert.equal(errors.length,0,route+" "+profile.id+" "+theme+" browser errors: "+errors);
  assert.equal(perf.currentTheme,theme,"theme mismatch "+route);
  assert.ok(assets.length>=3,route+" must load real assets");
  const sample={profile:profile.id,theme,route,repeat:n+1,requests:assets.length,encodedBytes:total,types:byType,
   ttfbMs:round(perf.ttfb),domReadyMs:round(perf.domReady),loadMs:round(perf.load),
   fcpMs:round(perf.fcp),lcpMs:round(perf.lcp),cls:round(perf.cls,4),
   longTaskCount:perf.longTasks.length,longTaskBlockingMs:round(perf.longTasks.reduce((s,x)=>s+Math.max(0,x.ms-50),0)),
   topAssets:assets.sort((a,b)=>b.encoded-a.encoded).slice(0,7).map(x=>({file:new URL(x.url).pathname.split("/").at(-1),bytes:round(x.encoded,0)})),
   scroll};
  samples.push(sample);
  const key=[profile.id,theme,route].join("|");(grouped[key]??=[]).push(sample);
  console.log("PROFILE",key+" #"+(n+1),"requests="+sample.requests,"encodedKB="+round(sample.encodedBytes/1024),"FCP="+sample.fcpMs,"LCP="+sample.lcpMs,"CLS="+sample.cls,"scrollCPU="+(scroll?round(scroll.scriptCpuMs+scroll.styleCpuMs+scroll.layoutCpuMs):"-"));
  await context.close();
 }
 const summary=Object.fromEntries(Object.entries(grouped).map(([key,rows])=>[key,{
  runs:rows.length,requests:median(rows.map(x=>x.requests)),encodedBytes:median(rows.map(x=>x.encodedBytes)),
  fcpMs:median(rows.map(x=>x.fcpMs)),lcpMs:median(rows.map(x=>x.lcpMs)),
  cls:median(rows.map(x=>x.cls),4),ttfbMs:median(rows.map(x=>x.ttfbMs)),
  loadMs:median(rows.map(x=>x.loadMs)),longTaskBlockingMs:median(rows.map(x=>x.longTaskBlockingMs)),
  types:rows[0].types,topAssets:rows[0].topAssets,scroll:rows[0].scroll
 }]));
 const result={schema:"nightfall-synthetic-loading-v1",method:machine,summary,samples};
 await writeFile("browser-artifacts/loading-profile.json",JSON.stringify(result,null,2)+"\n");
 for(const [key,stats] of Object.entries(summary))console.log("MEDIAN",key,JSON.stringify({requests:stats.requests,encodedKB:round(stats.encodedBytes/1024),fcpMs:stats.fcpMs,lcpMs:stats.lcpMs,cls:stats.cls,loadMs:stats.loadMs,blockingMs:stats.longTaskBlockingMs,scroll:stats.scroll}));
 console.log("PROFILE_ARTIFACT browser-artifacts/loading-profile.json");
}finally{await browser?.close();await new Promise(resolve=>server?server.close(resolve):resolve());}
