// Original finite exact replay; run node replay-adaptive-instrument.cjs
function replay() {
  const D=16, S=1024;
  const zero=()=>Array.from({length:D},()=>Array(D).fill(0));
  const id=()=>{let A=zero();for(let i=0;i<D;i++)A[i][i]=1;return A;};
  const H=(b)=>{let A=zero();for(let i=0;i<D;i++)if(!(i&b)){let j=i|b;A[i][i]=A[i][j]=A[j][i]=1;A[j][j]=-1;}return A;};
  const oracle=x=>{let A=zero();for(let i=0;i<D;i++){let a=i>>1,y=i&1,s=x[a]||0;let j=s===1?i^1:i;A[j][i]=s===2&&y?-1:1;}return A;};
  const project=(A,p)=>A.map((r,i)=>p(i)?r.slice():Array(D).fill(0));
  const perm=b=>{let A=zero();for(let i=0;i<D;i++)A[i^b][i]=1;return A;};
  function vec(A,v){return A.map(row=>row.reduce((s,a,j)=>s+a*v[j],0));}
  function density(A,R,den){let B=zero(),C=zero();for(let i=0;i<D;i++)for(let j=0;j<D;j++)for(let k=0;k<D;k++)B[i][j]+=A[i][k]*R[k][j];for(let i=0;i<D;i++)for(let j=0;j<D;j++){let z=0;for(let k=0;k<D;k++)z+=B[i][k]*A[j][k];if(z%den)throw Error("not integral");C[i][j]=z/den;}return C;}
  const trace=R=>R.reduce((s,row,i)=>s+row[i],0);
  const accept=i=>(i&4)!==0;
  const terminalV=(v,d)=>{const w=vec(H(4),v);return [w.reduce((s,z,i)=>s+(accept(i)?z*z:0),0)*S/(2*d),w.reduce((s,z)=>s+z*z,0)*S/(2*d)];};
  const terminalR=R=>{let B=density(H(4),R,2);return [B.reduce((s,row,i)=>s+(accept(i)?row[i]:0),0),trace(B)];};
  const states=[Array.from({length:D},(_,i)=>i%2===0?1:0),Array.from({length:D},(_,i)=>i%2?((i&4)?-1:1):0)];
  const K=[project(H(2),i=>!(i&2)),project(H(2),i=>!!(i&2)),zero()];
  const stats={inputs:0,branchComparisons:0,mismatches:0,normalizationFailures:0,nullBranchFailures:0,mixedDifferences:0,nonzeroHighDifferences:0,nonconstantPrograms:0,invalidControlDetected:0,degreeFourWitness:0};
  for(const sizes of [[2,2,2,2,2],[3,2,3,2,2]]){
    const words=[];function gen(a){if(a.length===5){words.push(a);return;}for(let j=0;j<sizes[a.length];j++)gen(a.concat(j));}gen([]);
    const F=new Map();
    for(const x of words){
      const O=oracle(x);let totalV=0,totalR=0,norm=0;
      for(const v of states){
        let R=v.map(a=>v.map(b=>a*b*S/16)); // 1/2 mixture, norm(v)^2=8
        let q=vec(O,v),rho=density(O,R,1);
        for(let h=0;h<3;h++){
          let w=vec(K[h],q),d=32;let B=density(K[h],rho,2);
          if(h===1){w=vec(O,vec(perm(4),vec(H(1),w)));d*=2;B=density(O,density(perm(4),density(H(1),B,2),1),1);}
          const a=terminalV(w,d),b=terminalR(B);stats.branchComparisons++;
          if(a[0]!==b[0]||a[1]!==b[1])stats.mismatches++;
          if(h===2&&(a[1]||b[1]))stats.nullBranchFailures++;
          totalV+=a[0];totalR+=b[0];norm+=b[1];
        }
      }
      if(totalV!==totalR)stats.mismatches++;
      if(norm!==S||totalR<0||totalR>S||!Number.isInteger(totalR))stats.normalizationFailures++;
      F.set(x.join(","),totalR);stats.inputs++;
    }
    if(new Set(F.values()).size>1)stats.nonconstantPrograms++;
    const pairs=[];function boxes(a){if(a.length===5){pairs.push(a);return;}for(let i=0;i<sizes[a.length];i++)for(let j=i+1;j<sizes[a.length];j++)boxes(a.concat([[i,j]]));}boxes([]);
    for(const b of pairs){let delta=0,bad=0;for(let m=0;m<32;m++){const x=b.map((p,i)=>p[(m>>i)&1]);const sign=m.toString(2).replace(/0/g,"").length%2?-1:1;delta+=sign*F.get(x.join(","));bad+=sign*(x.every((v,i)=>v===b[i][1])?S:0);}stats.mixedDifferences++;if(delta)stats.nonzeroHighDifferences++;if(bad)stats.invalidControlDetected++;}
  }
  // Two coherent paths: query x0,x1 along one path, x2,x3 along the other.
  // Hadamard acceptance (1+(-1)^(x0+x1+x2+x3))/2 has nonzero fourth difference.
  let delta4=0;for(let m=0;m<16;m++){let parity=m.toString(2).replace(/0/g,"").length%2;delta4+=(parity?-1:1)*(parity?0:1);}stats.degreeFourWitness=delta4;
  if(stats.mismatches||stats.normalizationFailures||stats.nullBranchFailures||stats.nonzeroHighDifferences||!stats.invalidControlDetected||!stats.nonconstantPrograms||delta4!==8)throw Error(JSON.stringify(stats));
  return stats;
}
console.log(JSON.stringify(replay(),null,2));
