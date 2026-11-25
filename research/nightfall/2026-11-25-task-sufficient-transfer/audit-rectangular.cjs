'use strict';
function audit(){
 const tr=A=>Array.from({length:A[0].length},(_,j)=>A.map(r=>r[j]));
 const mm=(A,B)=>A.map(r=>B[0].map((_,j)=>r.reduce((s,x,i)=>s+x*B[i][j],0n)));
 const eye=n=>Array.from({length:n},(_,i)=>Array.from({length:n},(_,j)=>i===j?1n:0n));
 const sub=(A,B)=>A.map((r,i)=>r.map((x,j)=>x-B[i][j]));
 const scale=(A,k)=>A.map(r=>r.map(x=>x*k));
 const diag=(a)=>a.map((x,i)=>a.map((_,j)=>i===j?x:0n));
 const cat=(A,B)=>A.map((r,i)=>r.concat(B[i]));
 const det=A=>A.length===0?1n:A[0].reduce((s,x,j)=>s+(j%2?-1n:1n)*x*det(A.slice(1).map(r=>r.filter((_,k)=>k!==j))),0n);
 let minors=0;
 function psd(A){for(let mask=1;mask<(1<<A.length);mask++){const inds=Array.from({length:A.length},(_,i)=>i).filter(i=>mask&(1<<i));minors++;if(det(inds.map(i=>inds.map(j=>A[i][j])))<0n)return false;}return true;}
 function maps(m,n){const a=[];function go(rows,used){if(rows.length===m){a.push(rows);return;}go([...rows,Array(n).fill(0n)],used);for(let j=0;j<n;j++)if(!(used&(1<<j)))for(const s of [-1n,1n])go([...rows,Array.from({length:n},(_,k)=>k===j?s:0n)],used|(1<<j));}go([],0);return a;}
 // Independently verify row/column and completed block via all principal minors.
 // Common denominator five; K,L signed coordinate partial isometries (including zeros).
 let cases=0,rectangular=0,singular=0,sharp=0,failed=0,wrongZero=0;
 for(const [d,delta,gamma] of [
 [[[5n,0n,0n],[0n,3n,0n]],[0n,4n,5n],[0n,4n]],
 [[[0n,0n,0n],[0n,4n,0n]],[5n,3n,5n],[5n,3n]],
 [[[3n,0n],[0n,5n],[0n,0n]],[4n,0n],[4n,0n,5n]],
 [[[0n,0n],[0n,0n]],[5n,5n],[5n,5n]]
 ]){
  const q=d[0].length,p=d.length;
  for(const K of maps(2,q))for(const L of maps(p,2)){
   const e=mm(K,diag(delta)),g=mm(diag(gamma),L),x=scale(mm(mm(K,tr(d)),L),-1n);
   const R=[...cat(x,e),...cat(g,d)],row=cat(g,d),col=[...e,...d];
   const gram=A=>mm(tr(A),A);
   const ok=psd(sub(scale(eye(row.length),25n),mm(row,tr(row))))&&psd(sub(scale(eye(q),25n),gram(col)))&&psd(sub(scale(eye(q+2),25n),gram(R)));
   cases++;if(q!==p)rectangular++;if(delta.includes(0n)||gamma.includes(0n))singular++;if(!ok)failed++;
   if(det(sub(scale(eye(q+2),25n),gram(R)))===0n)sharp++;
   const Z=[...cat([[0n,0n],[0n,0n]],e),...cat(g,d)];
   if(!psd(sub(scale(eye(q+2),25n),gram(Z))))wrongZero++;
  }
 }
 if(failed)throw Error("completion certificate failure");
 return {cases,rectangular,singular,sharpAtUnitBound:sharp,zeroBlockViolations:wrongZero,principalMinorsChecked:minors,failed};
}
console.log(JSON.stringify(audit(),null,2));
