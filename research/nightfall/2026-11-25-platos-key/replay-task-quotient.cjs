// Exact integer counterexample to inferring geometric synchronization from task-equivalent transfer.
function replay(){
 const eq=(a,b)=>a.every((x,i)=>x===b[i]);
 const mv=(A,x)=>A.map(a=>a.reduce((s,v,i)=>s+v*x[i],0));
 const mm=(A,B)=>A.map(a=>B[0].map((_,j)=>a.reduce((s,v,i)=>s+v*B[i][j],0)));
 const I=[[1,0,0],[0,1,0],[0,0,1]],G=[];
 for(const swap of [false,true])for(const a of [-1,1])for(const b of [-1,1])G.push(swap?[[1,0,0],[0,0,a],[0,b,0]]:[[1,0,0],[0,a,0],[0,0,b]]);
 const same=(A,B)=>A.every((a,i)=>eq(a,B[i]));
 let chains=0,nontrivial=0,checks=0,taskMismatch=0,geometricMismatch=0,secondObserverMismatch=0,orthogonalityFailures=0,anchorFailures=0;
 for(const A of G){if(!same(mm(A,A[0].map((_,j)=>A.map(row=>row[j]))),I))orthogonalityFailures++;if(!eq(mv(A,[1,0,0]),[1,0,0]))anchorFailures++}
 for(const A of G)for(const B of G){
  const C=mm(B,A);chains++;if(!same(C,I))nontrivial++;
  for(let x=-2;x<=2;x++)for(let y=-2;y<=2;y++)for(let z=-2;z<=2;z++){
   const v=[x,y,z],w=mv(C,v),q=mv(B,mv(A,v));if(!eq(w,q))throw Error("composition");
   checks++;if(w[0]!==v[0])taskMismatch++;if(!eq(w,v))geometricMismatch++;if(w[1]!==v[1])secondObserverMismatch++;
  }
 }
 // Independent closed counting: among eight actions, fixed counts on the 5x5 plane
 // are 25 (identity), 1 (each nontrivial quarter/half rotation), 5 (each reflection).
 const expected=8*5*(8*25-(25+3+4*5));
 if(chains!==64||nontrivial!==56||checks!==8000||taskMismatch||geometricMismatch!==expected||orthogonalityFailures||anchorFailures||secondObserverMismatch===0)throw Error("failed control");
 return {maps:G.length,chains,nontrivial,checks,taskMismatch,geometricMismatch,secondObserverMismatch,orthogonalityFailures,anchorFailures,expectedGeometricMismatch:expected};
}
console.log(JSON.stringify(replay(),null,2));
