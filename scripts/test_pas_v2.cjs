"use strict";
// PAS v2 finite proof-identity checks. Pure integer arithmetic; deterministic,
// separate from real-corpus evaluation and any claims of empirical improvement.
const assert=require("node:assert/strict");
const matrix=n=>Array.from({length:n},()=>Array(n).fill(0));
const identity=n=>{const a=matrix(n);for(let i=0;i<n;i++)a[i][i]=1;return a;};
const plus=(a,b)=>a.map((row,i)=>row.map((v,j)=>v+b[i][j]));
function multiply(a,b){
 const n=a.length, c=matrix(n);
 for(let i=0;i<n;i++)for(let k=0;k<n;k++)if(a[i][k])
  for(let j=0;j<n;j++)c[i][j]+=a[i][k]*b[k][j];
 return c;
}
function pathSum(b){
 const n=b.length; let p=identity(n),r=identity(n);
 for(let k=1;k<n;k++){p=multiply(p,b);r=plus(r,p);}
 return r;
}
// Independent graph traversal; no use of pathSum or matrix multiplication.
function enumeratePaths(b){
 const n=b.length,r=identity(n);
 for(let s=0;s<n;s++){
  function dfs(u,w){
   for(let v=u+1;v<n;v++)if(b[u][v]){
    const weight=w*b[u][v];r[s][v]+=weight;dfs(v,weight);
   }
  }
  dfs(s,1);
 }
 return r;
}
function exposure(r,a,b){
 let total=0;
 for(let i=0;i<a.length;i++)for(let j=0;j<b.length;j++)
  total+=a[i]*r[i][j]*b[j];
 return total;
}
function assertDAG(b){
 for(let i=0;i<b.length;i++)for(let j=0;j<b.length;j++)
  if(j<=i)assert.equal(b[i][j],0,"topological DAG violation");
}
let state=0x9E3779B9;
function pick(k){state=(Math.imul(state,1664525)+1013904223)>>>0;return state%k;}
const cases=128;let edgeChecks=0;
for(let caseId=0;caseId<cases;caseId++){
 const n=3+(caseId%4),b=matrix(n),lo=matrix(n),hi=matrix(n);
 for(let i=0;i<n;i++)for(let j=i+1;j<n;j++){
  b[i][j]=pick(3);
  lo[i][j]=pick(b[i][j]+1);
  hi[i][j]=b[i][j]+pick(3);
 }
 assertDAG(b);assertDAG(lo);assertDAG(hi);
 const r=pathSum(b);
 assert.deepEqual(r,enumeratePaths(b),"path-sum disagrees with direct enumeration");
 const a=Array.from({length:n},()=>pick(3));
 const c=Array.from({length:n},()=>pick(3));
 const E=exposure(r,a,c);
 const Elo=exposure(pathSum(lo),a,c), Ehi=exposure(pathSum(hi),a,c);
 assert(Elo<=E&&E<=Ehi,"nonnegative interval inequality failed");
 for(let i=0;i<n;i++)for(let j=i+1;j<n;j++){
  const t=1+pick(3),changed=b.map(row=>row.slice());
  changed[i][j]+=t;
  const updated=exposure(pathSum(changed),a,c);
  let left=0,right=0;
  for(let k=0;k<n;k++){left+=a[k]*r[k][i];right+=r[j][k]*c[k];}
  assert.equal(updated-E,t*left*right,"exact one-edge identity failed");
  edgeChecks++;
 }
}
console.log("PAS v2 finite integer checker passed:",cases,"DAGs,",edgeChecks,
  "single-edge identities; path enumeration and interval bounds.");
