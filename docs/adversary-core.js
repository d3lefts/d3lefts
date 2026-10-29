/* Imaginary Adversary / Devil's Advocate v1: bounded exact falsification, never proof promotion. */
(function(root,factory){
  const api=factory();
  if(typeof module==="object"&&module.exports)module.exports=api;
  else root.ImaginaryAdversaryCore=api;
})(typeof globalThis==="object"?globalThis:this,function(){
"use strict";
const VERSION="1.0.0", MAX_POINTS=40, MAX_CELLS=64, MAX_MOVES=256;
function fail(msg){throw Error(msg)}
function readTokens(v){
  if(Array.isArray(v))return v.map(String);
  return String(v??"").trim().split(/[\s,;]+/).filter(Boolean);
}
function integer(s,cap=1000000000){
  const z=String(s);
  if(!/^-?(0|[1-9]\d*)$/.test(z))fail("Expected canonical integer: "+z.slice(0,25));
  const n=Number(z);
  if(!Number.isSafeInteger(n)||Math.abs(n)>cap)fail("Integer exceeds supported bound: "+z.slice(0,25));
  return n;
}
function pointsFrom(v){
  const xs=readTokens(v).map(x=>integer(x));
  if(xs.length<4||xs.length>MAX_POINTS)fail("Provide 4–40 distinct integer coordinates.");
  if(new Set(xs).size!==xs.length)fail("Coordinates must be distinct.");
  return xs.sort((a,b)=>a-b);
}
function disjoint(a,b){return a[0]!==b[0]&&a[0]!==b[1]&&a[1]!==b[0]&&a[1]!==b[1]}
function pairsFailure(xs,weak){
  const seen=new Map();
  for(let i=0;i<xs.length;i++)for(let j=weak?i+1:i;j<xs.length;j++){
    const sum=BigInt(xs[i])+BigInt(xs[j]),key=String(sum),prev=seen.get(key);
    if(prev&&(!weak||disjoint(prev,[i,j])))
      return{sum:key,first:[xs[prev[0]],xs[prev[1]]],second:[xs[i],xs[j]],kind:weak?"four distinct marks":"unordered pairs, diagonal allowed"};
    if(!prev)seen.set(key,[i,j]);
  }
  return null;
}
function fourFiveFailure(xs){
  let tested=0;
  for(let a=0;a<xs.length-3;a++)for(let b=a+1;b<xs.length-2;b++)
   for(let c=b+1;c<xs.length-1;c++)for(let d=c+1;d<xs.length;d++){
    tested++;
    const v=[xs[a],xs[b],xs[c],xs[d]],distances=new Set();
    for(let i=0;i<4;i++)for(let j=i+1;j<4;j++)distances.add(v[j]-v[i]);
    if(distances.size<5)return{tested,counterexample:{points:v,distinctDistances:[...distances].sort((p,q)=>p-q),count:distances.size}};
   }
  return{tested,counterexample:null};
}
function sidon(raw){
  const xs=pointsFrom(raw.points),property=raw.property||"four-five";
  if(!["four-five","weak-sidon","strong-sidon"].includes(property))fail("Unknown Sidon predicate.");
  const total=property==="four-five"?fourFiveFailure(xs):null;
  const collision=property==="four-five"?null:pairsFailure(xs,property==="weak-sidon");
  const counterexample=property==="four-five"?total.counterexample:collision;
  const status=counterexample?"COUNTEREXAMPLE_FOUND":"FINITE_TEST_SURVIVED";
  return{domain:"sidon",property,status,points:xs,pointCount:xs.length,
    tested:total?total.tested:xs.length*(xs.length+1)/2,
    counterexample,
    checkedScope:"Only the supplied finite coordinates; no global extremality, asymptotic claim, or publication priority.",
    method:property==="four-five"?"Exhaustive 4-subsets; count distinct six pairwise distances":property==="weak-sidon"?"Enumerate pairs of distinct marks and detect a repeated sum across four distinct marks":"Enumerate all unordered pair sums including repeated coordinates"};
}
function gcd(a,b){while(b!==0n){const t=a%b;a=b;b=t}return a<0n?-a:a}
function fraction(n,d){
  if(d<=0n)fail("Fraction denominator must be positive.");
  const g=gcd(n<0n?-n:n,d);return(n/g).toString()+"/"+(d/g).toString();
}
function parseFraction(value){
  const m=String(value??"").trim().match(/^(\d{1,22})(?:\/(\d{1,22}))?$/);
  if(!m)fail("Upper bound must be nonnegative integer or p/q.");
  const n=BigInt(m[1]),d=BigInt(m[2]||"1");if(d===0n)fail("Upper bound denominator must be positive.");
  return{n,d};
}
function rawOverlap(xs,D){
  const n=xs.length;let best=-1n,lags=[];
  for(let lag=1-n;lag<n;lag++){
    let sum=0n;
    for(let i=0;i<n;i++){
      const j=i-lag;
      if(j>=0&&j<n)sum+=BigInt(xs[i])*BigInt(D-xs[j]);
    }
    if(sum>best){best=sum;lags=[lag]}else if(sum===best)lags.push(lag);
  }
  return{numerator:2n*best,denominator:BigInt(n)*BigInt(D)*BigInt(D),lags};
}
function heightsFrom(v){
  const xs=readTokens(v).map(x=>integer(x,1000000));
  if(xs.length<2||xs.length>MAX_CELLS)fail("Provide 2–64 integer cell heights.");
  return xs;
}
function overlap(raw){
  const D=integer(raw.denominator,1000000),xs=heightsFrom(raw.heights);
  if(D<1)fail("Denominator must be positive.");
  if(xs.some(x=>x<0||x>D))fail("All heights must satisfy 0 ≤ A[i] ≤ D.");
  if(2*xs.reduce((a,b)=>a+b,0)!==xs.length*D)fail("Mass constraint violated: 2 Σ A[i] = n D.");
  const baseline=rawOverlap(xs,D);
  const baseScore=fraction(baseline.numerator,baseline.denominator);
  const claimed=String(raw.claimedUpper??"").trim();
  let upper=null,violated=false;
  if(claimed){
    const f=parseFraction(claimed);
    upper=fraction(f.n,f.d);
    violated=baseline.numerator*f.d>f.n*baseline.denominator;
  }
  let attempts=0,best=null; // bounded candidate-search; exactly 256 lexicographic legal transfers at most
  outer:for(let i=0;i<xs.length;i++)for(let j=0;j<xs.length;j++){
    if(i===j||xs[i]===0||xs[j]===D)continue;
    if(attempts>=MAX_MOVES)break outer;
    attempts++;
    const ys=xs.slice();ys[i]--;ys[j]++;
    const candidate=rawOverlap(ys,D);
    const cur=best?best.score:baseline;
    if(candidate.numerator*cur.denominator<cur.numerator*candidate.denominator){
      best={from:i,to:j,heights:ys,score:candidate};
    }
  }
  return{domain:"overlap",status:violated?"COUNTEREXAMPLE_FOUND":"FINITE_TEST_SURVIVED",
    input:{denominator:D,heights:xs},exactMaximum:baseScore,maximizingLags:baseline.lags,
    suppliedUpper:upper,upperViolated:violated,
    counterexample:violated?{computedMaximum:baseScore,suppliedUpper:upper,maximizingLags:baseline.lags}:null,
    neighbor:{movesTested:attempts,cap:MAX_MOVES,strictImprovementFound:!!best,
      best:best?{decrementIndex:best.from,incrementIndex:best.to,heights:best.heights,exactMaximum:fraction(best.score.numerator,best.score.denominator)}:null},
    checkedScope:"Equal-width rational step functions at 2–64 cells. Exact signed integer lag scan and piecewise-linear interpolation; 256 legal mass-preserving one-unit transfers at most. Finite probe only: no global minimality, certified record, or independent referee.",
    method:"BigInt signed-lag maximum; bounded deterministic one-unit mass transfer search"};
}
function questions(domain){
  const shared=[
   {lane:"Scope attack",question:"Which exact quantifiers, exceptional cases, and model assumptions does the claim require?"},
   {lane:"Dependency attack",question:"Which conclusion depends on an inherited theorem or unverified numerical input?"},
   {lane:"Adversarial reproduction",question:"Can a distinct implementation regenerate a failure witness from primary inputs?"},
   {lane:"Priority attack",question:"Which dated closest reference establishes the comparison under the same definitions?"}
  ];
  if(domain==="sidon")return [
    {lane:"Definition split",question:"Does the argument confuse classical Sidon pair-sum uniqueness with weak Sidon or the (4,5) distance condition?"},
    {lane:"Boundary extension",question:"Do cross-block old/new sums survive every proposed extension, not solely the existing finite set?"},
    ...shared];
  if(domain==="overlap")return[
    {lane:"Translation scope",question:"Are all signed real shifts covered via an exact piecewise-linear interpolation argument?"},
    {lane:"Mass-preserving perturbation",question:"Can a single legal one-unit transfer lower the exact maximum? What structural plateau follows?"},
    ...shared];
  return shared;
}
function contract(raw){
  const domain=raw.domain||"sidon",reach=raw.reach||"finite",statement=String(raw.statement??"").trim();
  if(!["sidon","overlap","general"].includes(domain))fail("Unknown attack domain.");
  if(!["finite","universal"].includes(reach))fail("Unknown claim reach.");
  const omissions=[];
  if(!statement)omissions.push("Missing explicit mathematical claim.");
  if(!String(raw.assumptions??"").trim())omissions.push("Assumptions and definitions are unstated.");
  if(!String(raw.source??"").trim())omissions.push("No primary source or immutable evidence identifier supplied.");
  if(!String(raw.baseline??"").trim())omissions.push("Closest same-scope baseline / prior work missing.");
  if(reach==="universal")omissions.push("Universal claim: bounded finite experiments cannot establish the stated quantifier.");
  return{statement,domain,reach,assumptions:String(raw.assumptions??"").trim(),source:String(raw.source??"").trim(),baseline:String(raw.baseline??"").trim(),omissions,questions:questions(domain)};
}
function attack(raw){
  const audit=contract(raw);
  const probe=audit.domain==="sidon"?sidon(raw):audit.domain==="overlap"?overlap(raw):null;
  const status=probe?.status==="COUNTEREXAMPLE_FOUND"?"COUNTEREXAMPLE_FOUND":probe?"NO_COUNTEREXAMPLE_IN_TESTED_SCOPE":"INCONCLUSIVE";
  return{format:"nightfall-imaginary-adversary-receipt-v1",version:VERSION,status,contract:audit,probe,
    scientificStatus:"UNREVIEWED LOCAL ATTACK — NEVER A THEOREM OR PUBLICATION VERDICT",
    interpretation:status==="COUNTEREXAMPLE_FOUND"?"An explicit counterexample rejects the tested finite predicate/upper bound under the stated input.":status==="NO_COUNTEREXAMPLE_IN_TESTED_SCOPE"?"The bounded test found no refutation of the selected finite predicate/upper bound; this proves no universal assertion.":"No executable finite predicate selected; attack questions are review prompts, not a proof.",
    trustBoundary:"Deterministic browser-local attack planning with exact bounded arithmetic; no independent external review, no public priority search, no automatic claim promotion."};
}
return{VERSION,MAX_POINTS,MAX_CELLS,MAX_MOVES,attack,sidon,overlap,contract,questions};
});
