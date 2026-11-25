// Original NIGHTFALL replay over actual Q7 input; Node >=18; no dependencies.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
function replayQ7(data) {
  const edges=[], idx=new Map(), squares=[], incident=Array.from({length:448},()=>[]);
  for(let d=0;d<7;d++)for(let v=0;v<128;v++)if(!(v&(1<<d))){idx.set(v*128+(v|(1<<d)),edges.length);edges.push([v,v|(1<<d)]);}
  for(let a=0;a<7;a++)for(let b=a+1;b<7;b++)for(let v=0;v<128;v++)if(!(v&((1<<a)|(1<<b)))){let u=v|(1<<a),w=v|(1<<b),z=u|(1<<b);const s=[[v,u],[v,w],[u,z],[w,z]].map(([x,y])=>idx.get(x*128+y));squares.push(s);for(const e of s)incident[e].push(s);}
  const lines=data.trim().split(/\r?\n/);if(lines.length!==180||new Set(lines).size!==180||edges.length!==448||squares.length!==672)throw Error("input");
  const stats={orbits:0,pairCases:0,compatible4:0,compatible2:0,k4:0,joint4:0,baselineCalls:0,cachedCalls:0,baselineNodes:0,cachedNodes:0,skipped:0,mismatch:0,brokenExpansionErrors:0,hist:{},k4Expansion5:0,k4Expansion6:0};
  function hit(groups,k,counter) {
    let nodes=0;const chosen=new Set();
    function dfs(left){nodes++;const g=groups.find(g=>!g.some(e=>chosen.has(e)));if(!g)return true;if(!left)return false;for(const e of g){chosen.add(e);const yes=dfs(left-1);chosen.delete(e);if(yes)return true;}return false;}
    const yes=dfs(k);if(counter)stats[counter]+=nodes;return yes;
  }
  function trial(groups,first=4) {
    let neg=Infinity,firstAnswer=false;
    for(let k=first;k>=0;k--){
      const expected=hit(groups,k,"baselineNodes");stats.baselineCalls++;
      let got;if(k<=neg && neg!==Infinity){got=false;stats.skipped++;}else{got=hit(groups,k,"cachedNodes");stats.cachedCalls++;if(!got)neg=k;}
      if(expected!==got)stats.mismatch++;
      if(k===first)firstAnswer=expected;
    }
    // Explicit enlargement: a previous budget-0 failure must not suppress budget 4.
    const enlarged=hit(groups,first);
    if(enlarged)stats.brokenExpansionErrors++;
    return firstAnswer;
  }
  for(const line of lines){
    if(!/^[0-9a-f]{112}$/.test(line))throw Error("format");const bytes=line.match(/../g).map(x=>parseInt(x,16));const mask=edges.map((_,e)=>!!(bytes[e>>3]&(128>>(e&7))));
    if(mask.filter(Boolean).length!==304||squares.some(s=>s.every(e=>mask[e])))throw Error("invalid seed");
    const groups=[];for(let e=0;e<448;e++)if(!mask[e]){const g=incident[e].filter(s=>s.every(x=>x===e||mask[x])).map(s=>s.filter(x=>x!==e));stats.hist[g.length]=(stats.hist[g.length]||0)+1;if(g.length<=4)groups.push(g);}
    const supports=groups.map(g=>new Set(g.flat())),adj=groups.map(()=>new Set());
    for(let i=0;i<groups.length;i++)for(let j=i+1;j<groups.length;j++){
      let common=0;for(const e of supports[i])if(supports[j].has(e))common++;
      if(common<groups[i].length+groups[j].length-4)continue;
      const g=groups[i].concat(groups[j]);stats.pairCases++;
      if(trial(g)){adj[i].add(j);stats.compatible4++;if(hit(g,2))stats.compatible2++;}
    }
    for(let i=0;i<adj.length;i++)for(const j of adj[i])for(const k of adj[j])if(adj[i].has(k))for(const l of adj[k])if(adj[i].has(l)&&adj[j].has(l)){
      const g=groups[i].concat(groups[j],groups[k],groups[l]);stats.k4++;if(trial(g))stats.joint4++;
      if(hit(g,5))stats.k4Expansion5++;
      if(hit(g,6))stats.k4Expansion6++;
    }
    stats.orbits++;
  }
  if(stats.mismatch||stats.compatible4!==20668||stats.compatible2!==0||stats.k4!==105||stats.joint4!==0||stats.brokenExpansionErrors===0||JSON.stringify(stats.hist)!==JSON.stringify({2:129,3:8376,4:10290,5:7125}))throw Error(JSON.stringify(stats));
  return stats;
}
const input=fs.readFileSync(process.argv[2]||path.join(__dirname,'../projects/erdos/q7-180-orbit-20261029/canonical_180.txt'));
const hash=crypto.createHash('sha256').update(input).digest('hex');
if(hash!=='2c4a0bfdcbac0d2751a6d2ab3b8b345cd6d4dd2febe437d63cadc2af960168a1')throw Error('input hash mismatch: '+hash);
console.log(JSON.stringify({input_sha256:hash,...replayQ7(input.toString('ascii'))},null,2));
