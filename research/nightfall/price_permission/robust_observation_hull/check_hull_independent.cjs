'use strict';
/**
 * Independent exact original-world robust observation decision oracle.
 *
 * This checker uses neither the Python KKT witness nor its minimizer code:
 * directly build G(t)=A t²+B t+C from the mission table, find its exact
 * stationary point and compare both endpoints. Also compute the exact
 * after-reading-source floor and all one-sensor alternatives.
 *
 * This implementation deliberately supports the two-atom changed source
 * and arbitrary finite positive/zero rational observed marginal. No floats.
 */
const fs=require('node:fs');
const path=require('node:path');
const crypto=require('node:crypto');
const assert=require('node:assert/strict');
const INPUT=path.join(__dirname,'source_bound_hull_witness.json');

function gcd(a,b){a=a<0n?-a:a;b=b<0n?-b:b;while(b){const t=a%b;a=b;b=t}return a||1n}
class Q{
  constructor(n,d=1n){
    n=BigInt(n);d=BigInt(d);
    if(d===0n)throw Error('zero denominator');
    if(d<0n){n=-n;d=-d}
    const g=gcd(n,d);this.n=n/g;this.d=d/g;
  }
  static of(x){
    if(typeof x!=='string'||!/^-?\d+(\/\d+)?$/.test(x))throw Error('invalid rational');
    const [a,b='1']=x.split('/');return new Q(a,b)
  }
  add(o){return new Q(this.n*o.d+o.n*this.d,this.d*o.d)}
  sub(o){return new Q(this.n*o.d-o.n*this.d,this.d*o.d)}
  mul(o){return new Q(this.n*o.n,this.d*o.d)}
  div(o){return new Q(this.n*o.d,this.d*o.n)}
  cmp(o){const v=this.n*o.d-o.n*this.d;return v>0n?1:v<0n?-1:0}
  eq(o){return this.cmp(o)===0}
  toString(){return this.d===1n?this.n.toString():this.n+'/'+this.d}
}
const ZERO=new Q(0),ONE=new Q(1),TWO=new Q(2);
function sum(xs){return xs.reduce((a,b)=>a.add(b),ZERO)}
function canon(x){return Array.isArray(x)?x.map(canon):x&&typeof x==='object'?
  Object.fromEntries(Object.keys(x).sort().map(k=>[k,canon(x[k])])):x}
function hash(x){return crypto.createHash('sha256').update(JSON.stringify(canon(x))).digest('hex')}
function vecInner(u,v,p){return sum(u.map((x,z)=>p[z].mul(x).mul(v[z])))}
function verify(obj){
  assert.equal(obj.schema,'nightfall.robust-observation-hull.v1');
  const s=obj.source_model,c=obj.certificate;
  assert.equal(s.kind,'finite-product-original-response/v1');
  assert.equal(s.allowed_replacement_law,'entire_probability_simplex');
  assert.equal(s.loss,'squared_error');
  assert.deepEqual(s.sources,['authority_epoch','sensor_y']);
  assert.equal(s.changed_marginal,'authority_epoch');
  assert.equal(s.observed_target,'sensor_y');
  assert.equal(hash(s),c.source_sha256);
  assert.equal(s.coordinate_alphabets.length,2);
  assert.equal(s.coordinate_alphabets[0].length,2);
  const n=s.coordinate_alphabets[1].length;
  assert.ok(n>=2&&n<=12);
  assert.equal(s.fixed_second_marginal.length,n);
  const pi=s.fixed_second_marginal.map(Q.of);
  assert.ok(pi.every(x=>x.cmp(ZERO)>=0)&&sum(pi).eq(ONE));
  assert.equal(s.mission_table.length,2);
  const f=s.mission_table.map(r=>{assert.equal(r.length,n);return r.map(Q.of)});
  const means=f.map(row=>vecInner(row,Array(n).fill(ONE),pi));
  const d=f.map((row,a)=>row.map(x=>x.sub(means[a])));
  // Direct conditional variance polynomial, q=(t,1-t).
  const base=d[1],delta=d[0].map((x,i)=>x.sub(d[1][i]));
  const C=vecInner(base,base,pi);
  const B=TWO.mul(vecInner(base,delta,pi));
  const A=vecInner(delta,delta,pi);
  assert.ok(A.cmp(ZERO)>=0);
  const g=t=>A.mul(t).mul(t).add(B.mul(t)).add(C);
  const options=[ZERO,ONE];
  if(A.cmp(ZERO)>0){
    const t=B.mul(new Q(-1)).div(TWO.mul(A));
    if(t.cmp(ZERO)>=0&&t.cmp(ONE)<=0)options.push(t);
  }
  let best=options[0];
  for(const t of options)if(g(t).cmp(g(best))<0)best=t;
  const robust=g(best);
  const claimed=Q.of(c.robust_unobserved_gain);
  assert.ok(claimed.eq(robust),'false robust information floor');
  const reported=c.minimizer_law.map(Q.of);
  assert.equal(reported.length,2);
  assert.ok(reported.every(x=>x.cmp(ZERO)>=0)&&sum(reported).eq(ONE));
  assert.ok(g(reported[0]).eq(robust),'wrong adversarial law');
  const target=reported[0];
  const h=base.map((x,z)=>x.add(target.mul(delta[z])));
  assert.deepEqual(c.separating_response,h.map(x=>x.toString()));
  const norm0=vecInner(d[0],d[0],pi),norm1=vecInner(d[1],d[1],pi);
  const post=norm0.cmp(norm1)<0?norm0:norm1;
  assert.ok(Q.of(c.robust_observed_gain).eq(post));
  assert.ok(norm0.eq(norm1)&&Q.of(c.coordinate_influence_y).eq(norm0));
  const old=s.original_first_marginal.map(Q.of);
  assert.ok(old.length===2&&old.every(x=>x.cmp(ZERO)>=0)&&sum(old).eq(ONE));
  assert.ok(Q.of(c.original_law_unobserved_gain).eq(g(old[0])));
  const threshold=Q.of(c.squared_gain_threshold);
  assert.ok(claimed.cmp(threshold)<0&&threshold.cmp(post)<=0);
  assert.equal(c.minimum_fixed_sensor_count_for_robust_threshold,2);
  // Exact result: X-only robust information gain is zero because adversary
  // may select a point-mass law on X; ∅ similarly yields no information.
  // Both coordinates have minimum total explained variance >= min row var.
  return {status:'PASS',quadratic:[A.toString(),B.toString(),C.toString()],
    minimizer:best.toString(),robust:robust.toString(),
    post:post.toString(),influence_y:norm0.toString(),
    source_sha256:hash(s)};
}
function test(obj){
  const clone=x=>JSON.parse(JSON.stringify(x));
  const mutations=[
    x=>x.certificate.source_sha256='0'.repeat(64),
    x=>x.certificate.robust_unobserved_gain='2/3',
    x=>x.certificate.robust_observed_gain='1/6',
    x=>x.certificate.minimizer_law=['1','0'],
    x=>x.certificate.separating_response=['1','0','0'],
    x=>x.certificate.coordinate_influence_y='1/6',
    x=>x.certificate.minimum_fixed_sensor_count_for_robust_threshold=1,
    x=>x.source_model.mission_table[0][0]='0',
    x=>x.source_model.original_first_marginal=['1/2','1/2'],
    x=>x.source_model.loss='classification'
  ];
  mutations.forEach((mut,i)=>{const c=clone(obj);mut(c);
    assert.throws(()=>verify(c),undefined,'accepted independent mutation '+i)});
  return mutations.length;
}
if(require.main===module){
 const obj=JSON.parse(fs.readFileSync(INPUT,'utf8'));
 const out=verify(obj); const n=test(obj);
 console.log('PASS independent original-product exact quadratic minimization: '+
   JSON.stringify(out)+'; '+n+' negative controls rejected');
}
module.exports={verify,test};
