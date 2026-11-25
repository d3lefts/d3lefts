// NIGHTFALL standalone finite replay; no dependencies. Node.js: node replay-negative-cache.cjs
function replay() {
  const W=8, N=1<<W;
  function oracle(mask,k) {
    const pattern=(1<<k)-1;
    for(let i=0;i<=W-k;i++) if((mask&(pattern<<i))===(pattern<<i)) return true;
    return false;
  }
  function scanner(mask,k) {
    let run=0,best=0;
    for(let i=0;i<W;i++) {run=(mask&(1<<i))?run+1:0;best=Math.max(run,best);}
    return best>=k;
  }
  const stats={cases:0,baselineQueries:0,cachedQueries:0,skipped:0,falseSuppression:0,mismatches:0,brokenFalseSuppression:0,restrictiveCases:0};
  let witness=null;
  for(let before=0;before<N;before++) for(let after=0;after<N;after++) {
    const restrictive=(after&~before)===0;
    for(let k=1;k<=W;k++) for(let j=1;j<=W;j++) {
      stats.cases++;stats.baselineQueries+=2;
      const expectedFirst=oracle(before,k),expected=oracle(after,j);
      const first=scanner(before,k);
      const skip=restrictive&&!first&&j>=k;
      const actual=skip?false:scanner(after,j);
      stats.cachedQueries+=skip?1:2;
      if(restrictive)stats.restrictiveCases++;
      if(skip){stats.skipped++;if(expected)stats.falseSuppression++;}
      if(first!==expectedFirst||actual!==expected)stats.mismatches++;
      if(!first&&j>=k&&expected){stats.brokenFalseSuppression++;if(!witness)witness={before,after,k,j};}
    }
  }
  if(stats.mismatches||stats.falseSuppression||!stats.brokenFalseSuppression)throw Error(JSON.stringify(stats));
  return {width:W,...stats,brokenWitness:witness};
}
console.log(JSON.stringify(replay(),null,2));
