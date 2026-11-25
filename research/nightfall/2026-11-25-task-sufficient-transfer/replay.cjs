'use strict';
function replay(){
 const dot=(a,x)=>((a&x)&1)^(((a&x)>>1)&1);
 const mv=(A,x)=>dot(A&3,x)|(dot(A>>2,x)<<1);
 const compose=(A,B)=>{const a=mv(A,mv(B,1)),b=mv(A,mv(B,2));return (a&1)|((b&1)<<1)|((a&2)<<1)|((b&2)<<2)};
 const image=A=>new Set([0,1,2,3].map(x=>mv(A,x)));
 const rank=A=>Math.log2(image(A).size);
 let cases=0,feasible=0,comparisons=0,rankErrors=0,criterionErrors=0,nonlinearErrors=0;
 for(let B=0;B<16;B++)for(let C=0;C<16;C++)for(let F=0;F<16;F++){
   cases++;
   const imC=image(C);
   const predicted=[0,1,2,3].every(x=>(mv(B,x)!==0||mv(F,x)===0)&&imC.has(mv(F,x)));
   let best=Infinity;
   for(let T=0;T<16;T++){comparisons++;if(compose(C,compose(T,B))===F)best=Math.min(best,rank(T));}
   if(predicted!==(best<Infinity))criterionErrors++;
   if(best<Infinity){feasible++;if(best!==rank(F))rankErrors++;}
   // Independent enumeration of every arbitrary map on the image of B (including nonzero origin).
   const input=[...image(B)];let exists=false;
   for(let code=0;code<4**input.length&&!exists;code++){
     const table=input.map((_,i)=>(code>>(2*i))&3);
     exists=[0,1,2,3].every(x=>mv(C,table[input.indexOf(mv(B,x))])===mv(F,x));
   }
   if(exists!==predicted)nonlinearErrors++;
 }
 let completions=0,improved=0,psdErrors=0,zeroDefect=0,sharpControls=0;
 for(let b=-4;b<=4;b++)for(let c=-4;c<=4;c++)for(let d=-4;d<=4;d++){
   completions++;const t2=d*d+Math.max(b*b,c*c),den=t2-d*d||1,num=-b*d*c;
   // M=[num/den,b;c,d]. Check exact PSD of den²(t² I-MᵀM).
   const a=t2*den*den-num*num-c*c*den*den;
   const z=(t2-b*b-d*d)*den*den;
   const off=-(num*b*den+c*d*den*den);
   if(a<0||z<0||a*z-off*off<0)psdErrors++;
   if(t2===0)zeroDefect++;
   const aa=t2-c*c,zz=t2-b*b-d*d,oo=-c*d;
   if(aa<0||zz<0||aa*zz-oo*oo<0)improved++;
   if(a*z-off*off===0)sharpControls++;
 }
 // F2 switched system: closed reachable observer row span vs word enumeration.
 const span=rows=>{const s=new Set([0]);for(const r of rows)for(const x of [...s])s.add(x^r);return s};
 const rowmul=(w,A)=>((w&1)?(A&3):0)^((w&2)?(A>>2):0);
 let systems=0,trajectoryChecks=0,closureErrors=0,delayed=0;
 for(let A=0;A<16;A++)for(let B=0;B<16;B++)for(let w=0;w<4;w++){
   systems++;
   const closed=span([w,rowmul(w,A),rowmul(w,B)]);
   let rows=[w],all=[w];
   for(let h=1;h<=5;h++){rows=rows.flatMap(r=>[rowmul(r,A),rowmul(r,B)]);all.push(...rows);}
   for(let x=0;x<4;x++){trajectoryChecks++;const short=[...closed].every(r=>dot(r,x)===0),long=all.every(r=>dot(r,x)===0);if(short!==long)closureErrors++;if(dot(w,x)===0&&!long)delayed++;}
 }
 const out={cases,feasible,comparisons,criterionErrors,rankErrors,nonlinearErrors,completions,improved,psdErrors,zeroDefect,sharpControls,systems,trajectoryChecks,closureErrors,delayed};
 if(criterionErrors||rankErrors||nonlinearErrors||psdErrors||closureErrors||sharpControls!==completions)throw Error(JSON.stringify(out));return out;
}
console.log(JSON.stringify(replay(),null,2));
