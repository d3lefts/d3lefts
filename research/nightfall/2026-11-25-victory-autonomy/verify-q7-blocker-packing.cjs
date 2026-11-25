// Source-independent face-coordinate audit for the Q7 packing certificates.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
function checkSource(data,cert) {
  const masks=data.trim().split(/\r?\n/);
  const seen=new Set(),entries=[];
  const edge=(d,v)=>64*d+(v%(2**d))+Math.floor(v/(2**(d+1)))*2**d;
  const faces=[];
  for(let a=0;a<7;a++)for(let b=a+1;b<7;b++)for(let v=0;v<128;v++)if(!(v&(1<<a))&&!(v&(1<<b)))faces.push({a,b,v,edges:[edge(a,v),edge(b,v),edge(b,v+(1<<a)),edge(a,v+(1<<b))]});
  if(faces.length!==672)throw Error("face count");
  for(const r of cert.records){
    const line=masks[r.orbit];if(!/^[0-9a-f]{112}$/.test(line))throw Error("mask");
    const bytes=line.match(/../g).map(s=>parseInt(s,16));let mask=0n;
    for(let e=0;e<448;e++)if(bytes[e>>3]&(128>>(e&7)))mask|=1n<<BigInt(e);
    const has=e=>!!(mask&(1n<<BigInt(e)));
    const key=r.orbit+":"+r.missing.join(",");
    if(seen.has(key)||r.missing.length!==4||new Set(r.missing).size!==4||r.missing.some(has)||r.groups.length!==8)throw Error(key);
    seen.add(key);
    const used=new Set();const fs=[];
    for(const g of r.groups){
      if(!r.missing.includes(g.missing)||g.blocker.length!==3||g.blocker.some(e=>used.has(e)||!has(e)))throw Error("invalid blocker");
      const es=new Set([g.missing,...g.blocker]);
      const matches=faces.filter(f=>f.edges.every(e=>es.has(e)));
      if(matches.length!==1)throw Error("not a unique square");
      g.blocker.forEach(e=>used.add(e));fs.push({...matches[0],missing:g.missing});
    }
    if(used.size!==24)throw Error("not disjoint");
    entries.push({orbit:r.orbit,mask:mask.toString(),missing:r.missing,faces:fs});
  }
  if(entries.length!==105)throw Error("record count");
  return entries;
}
const raw=fs.readFileSync(path.join(__dirname,'../projects/erdos/q7-180-orbit-20261029/canonical_180.txt'));
if(crypto.createHash('sha256').update(raw).digest('hex')!=='2c4a0bfdcbac0d2751a6d2ab3b8b345cd6d4dd2febe437d63cadc2af960168a1')throw Error('source hash mismatch');
const entries=checkSource(raw.toString('ascii'),JSON.parse(fs.readFileSync(path.join(__dirname,'q7-eight-blocker-certificates.json'),'utf8')));
const lean=fs.readFileSync(path.join(__dirname,'../formalization/product_space/AdaptiveInstrumentQ7Source.lean'),'utf8');
for(const [i,r] of entries.entries()){
 const line='def entry'+i+' : Entry := ⟨'+r.mask+', {'+r.missing.join(', ')+'}, !['+r.faces.map(f=>'⟨'+[f.a,f.b,f.v,f.missing].join(', ')+'⟩').join(', ')+'], record'+i+'⟩';
 if(!lean.includes(line))throw Error('Lean source mismatch '+i);
}
console.log(JSON.stringify({records:entries.length,tightFaces:entries.length*8,sourceAndLeanDataMatch:true}));
