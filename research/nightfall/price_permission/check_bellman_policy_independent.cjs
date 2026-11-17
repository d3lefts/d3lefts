'use strict';
/*
 * Independent finite-world budget-decision oracle for NIGHTFALL Bellman
 * policy certificates. It never loads a submitted value table to decide
 * feasibility: each budget is solved as a separate yes/no game by direct
 * source-world enumeration, validating both optimum and infeasible budget-1.
 * Exact rational costs are handled by integer scaling (LCM denominators).
 */
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');
const FILE = path.join(__dirname, 'bellman_two_source_policy_certificate.json');

const canon = x => Array.isArray(x) ? x.map(canon)
  : x && typeof x === 'object' ? Object.fromEntries(
      Object.keys(x).sort().map(k => [k, canon(x[k])])) : x;
const hash = x => crypto.createHash('sha256').update(JSON.stringify(canon(x))).digest('hex');
function gcd(a,b) { while(b){const t=a%b;a=b;b=t} return a }
function lcm(a,b) {return a / gcd(a,b) * b}
function q(s){
  if(typeof s!=='string'|| !/^(0|[1-9][0-9]*)(\/[1-9][0-9]*)?$/.test(s))throw Error('noncanonical rational');
  const [a,b='1']=s.split('/');
  return [Number(a),Number(b)];
}
function verify(obj) {
  assert.equal(obj.schema,'nightfall-semantic-bellman-certificate/v1');
  const s=obj.source_model, c=obj.certificate;
  assert.equal(s.kind,'nightfall-complete-bitcube-evidence/v1');
  assert.equal(s.change_history,'complete-baseline-to-final-xor');
  assert.equal(hash(s),c.source_sha256);
  const n=s.sources;
  assert.ok(Number.isInteger(n)&&n>=1&&n<=5);
  const baseline=s.baseline_worlds, unsafe=new Set(s.unsafe_worlds);
  assert.ok(Array.isArray(baseline)&&baseline.length&&baseline.length<=7);
  assert.equal(new Set(baseline).size,baseline.length);
  for(const w of [...baseline,...unsafe])assert.ok(Number.isInteger(w)&&w>=0&&w<2**n);
  for(const w of baseline)assert.ok(!unsafe.has(w));
  assert.equal(s.read_costs.length,n);
  assert.equal(s.guard_costs.length,n);
  const rc=s.read_costs.map(q),gc=s.guard_costs.map(q);
  const denominator=[...rc,...gc].reduce((v,p)=>lcm(v,p[1]),1);
  assert.ok(denominator>0 && Number.isSafeInteger(denominator));
  const rd=rc.map(p=>p[0]*(denominator/p[1]));
  const gr=gc.map(p=>p[0]*(denominator/p[1]));
  assert.ok(rd.every(x=>Number.isSafeInteger(x)&&x>0)&&gr.every(x=>Number.isSafeInteger(x)&&x>0));
  const root=baseline.reduce((a,w)=>a|(1<<w),0);
  assert.equal(c.root_belief,root);
  const expectedStates=[];
  for(let sub=1;sub<=root;sub++)if((sub &~root)===0)expectedStates.push(sub);
  assert.deepEqual(Object.keys(c.states).map(Number).sort((a,b)=>a-b),expectedStates);
  const isGuard=(belief,J)=> baseline.every(b=> !(belief&(1<<b)) ||
    [...unsafe].every(u=>((b^u)&J)!==0));
  const guardCost=(J)=>gr.reduce((v,c,i)=>v+((J>>i)&1)*c,0);
  const split=(belief,i)=>{
    const low=baseline.reduce((v,b)=>v|(((belief&(1<<b)) && !(b&(1<<i))) ? (1<<b):0),0);
    return [low,belief^low];
  };
  // Independent bounded decision recursion: no numerical Bellman value
  // table, no policy generator, no matrix or dual input, only raw worlds.
  function possible(belief,budget,memo) {
    if(budget<0) return false;
    const key=belief+':'+budget;
    if(memo.has(key))return memo.get(key);
    let ok=false;
    for(let J=0;J<2**n&&!ok;J++)
      if(isGuard(belief,J)&&guardCost(J)<=budget) ok=true;
    for(let i=0;i<n&&!ok;i++){
      const [low,high]=split(belief,i);
      if(low&&high&&rd[i]<=budget&&
          possible(low,budget-rd[i],memo)&&possible(high,budget-rd[i],memo)) ok=true;
    }
    memo.set(key,ok);
    return ok;
  }
  let decisions=0;
  for(const mask of expectedStates) {
    const val=c.states[String(mask)].value;
    const [a,b]=q(val);
    assert.equal((a*denominator)%b,0, 'value not representable in exact check units');
    const target=a*(denominator/b);
    assert.ok(Number.isSafeInteger(target)&&target>=0);
    assert.ok(possible(mask,target,new Map()),'no matching valid action policy');
    assert.equal(possible(mask,target-1,new Map()),false,'lower budget is feasible');
    decisions+=2;
  }
  assert.equal(c.claimed_optimal_cost,c.states[String(root)].value);
  return {status:'PASS',source_bound:true,optimum:c.claimed_optimal_cost,beliefs:expectedStates.length,
    decision_queries:decisions,source_sha256:hash(s)};
}
function selfTest(x){
  const clone=z=>JSON.parse(JSON.stringify(z));
  const cases=[
    m=>m.certificate.source_sha256='0'.repeat(64),
    m=>m.certificate.states['7'].value='4',
    m=>m.certificate.states['7'].value='6',
    m=>m.certificate.states['6'].value='4',
    m=>m.certificate.states['1'].value='3',
    m=>m.certificate.claimed_optimal_cost='4',
    m=>m.source_model.read_costs[0]='5',
    m=>m.source_model.unsafe_worlds.push(0),
    m=>m.source_model.change_history='unknown',
    m=>delete m.certificate.states['6'],
    m=>m.certificate.root_belief=3
  ];
  cases.forEach((fn,i)=>{
    const a=clone(x);fn(a);
    assert.throws(()=>verify(a),undefined,'accepted independent checker mutation '+i);
  });
  return cases.length;
}
if(require.main===module){
  const x=JSON.parse(fs.readFileSync(FILE,'utf8'));
  const res=verify(x);
  const negatives=selfTest(x);
  console.log('PASS: independent direct-world budget oracle; '+res.beliefs+
    ' beliefs, '+res.decision_queries+' feasibility/infeasibility queries; cost='+res.optimum+
    '; '+negatives+' negative controls');
}
module.exports={verify,selfTest};
