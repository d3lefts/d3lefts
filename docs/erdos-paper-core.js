"use strict";
/* Exact finite educational overlap geometry; this is NOT the 131,072-cell witness.
 * Independent rectangle intersection checks certify the 16-cell exercise only. */
(function(root){
 const VERSION="1.0.0";
 const FIXTURE=Object.freeze([6,7,5,8,6,2,5,5,6,2,1,3,3,2,1,2]);
 const D=8, N=FIXTURE.length;
 function validate(a){
  if(!Array.isArray(a)||a.length!==N||a.some(x=>!Number.isSafeInteger(x)||x<0||x>D))
   throw Error("Expected exactly 16 integer heights from 0 to 8");
  if(a.reduce((x,y)=>x+y,0)!==N*D/2)throw Error("Mass normalization failed: heights must sum to 64");
  return a.slice();
 }
 function transfer(source,from,to){
  const a=validate(source);
  if(!Number.isInteger(from)||!Number.isInteger(to)||from<0||to<0||from>=N||to>=N||from===to)throw Error("Select two different valid cells");
  if(a[from]===0||a[to]===D)throw Error("Transfer blocked: donor empty or receiver full");
  a[from]--;a[to]++;
  return validate(a);
 }
 // Discrete correlation, with zero extension for both functions.
 function profile(source){
  const a=validate(source),data=[];
  for(let k=-(N-1);k<=N-1;k++){
   let q=0n;
   for(let i=0;i<N;i++){
    const j=i-k;
    if(j>=0&&j<N)q+=BigInt(a[i])*BigInt(D-a[j]);
   }
   data.push({lag:k,raw:q});
  }
  const largest=data.reduce((m,x)=>x.raw>m?x.raw:m,0n);
  const winning=data.filter(x=>x.raw===largest).map(x=>x.lag);
  return {points:data,maxRaw:largest,winners:winning,numerator:2n*largest,denominator:BigInt(N*D*D)};
 }
 // Independent geometric oracle. Each original cell occupies two half-cell units.
 // g(x-s) is shifted by sHalf half-cell units, integer arithmetic throughout.
 function geometry(source,sHalf){
  const a=validate(source);
  if(!Number.isInteger(sHalf)||Math.abs(sHalf)>2*N)throw Error("Half-cell lag out of range");
  let q=0n;
  for(let i=0;i<N;i++)for(let j=0;j<N;j++){
   const overlap=Math.max(0,Math.min(2*i+2,2*j+sHalf+2)-Math.max(2*i,2*j+sHalf));
   if(overlap)q+=BigInt(overlap)*BigInt(a[i])*BigInt(D-a[j]);
  }
  // One half-cell has width 1/N; exact overlap is q/(N D²).
  return q;
 }
 function audit(source){
  const a=validate(source),p=profile(a),map=new Map(p.points.map(x=>[x.lag,x.raw]));
  let verified=0;
  for(let k=-(N-1);k<=N-1;k++){
   if(geometry(a,2*k)!==2n*map.get(k))throw Error("Integer-shift geometry and correlation disagree");
   verified++;
   if(k<N-1){
    const atHalf=geometry(a,2*k+1);
    if(atHalf!==map.get(k)+map.get(k+1))throw Error("Half-shift affine geometry mismatch");
    verified++;
   }
  }
  return {status:"EXACT_TOY_CHECK_PASSED",cells:N,denominator:D,mass:a.reduce((s,v)=>s+v,0),
    shifts:p.points.length,rectangleIntersections:verified,maximumNumerator:String(p.numerator),
    maximumDenominator:String(p.denominator),winningLags:p.winners,
    scope:"16-cell educational fixture; exhaustive exact local grid and half-grid checks, no evaluation of the 131072-cell witness"};
 }
 function decimal(n,d,places=9){
  n=BigInt(n);d=BigInt(d);
  if(d<=0n)throw Error("Positive denominator required");
  const sign=n<0n?"-":"";if(n<0n)n=-n;
  const integer=n/d;let r=n%d,s="";
  for(let i=0;i<places;i++){r*=10n;s+=String(r/d);r%=d;}
  return sign+integer.toString()+(places?"."+s:"");
 }
 const api={VERSION,FIXTURE,D,N,validate,transfer,profile,geometry,audit,decimal};
 if(typeof module!=="undefined"&&module.exports)module.exports=api;else root.ErdosPaperCore=api;
})(typeof window!=="undefined"?window:null);
