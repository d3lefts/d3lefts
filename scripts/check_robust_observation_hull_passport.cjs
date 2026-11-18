'use strict';
/**
 * NIGHTFALL source-bound robust observation hull Proof Passport.
 * No automatic promotion to physical permission, independent refereeing,
 * a Lean evaluation of the JSON instance, or novelty certification.
 */
const fs=require('node:fs'), path=require('node:path'),crypto=require('node:crypto');
const child=require('node:child_process'),assert=require('node:assert/strict');
const ROOT=path.resolve(__dirname,'..');
const DIR='research/nightfall/price_permission/robust_observation_hull/';
const MODEL=DIR+'source_bound_hull_witness.json';
const EXACT=DIR+'check_hull_exact.py';
const INDEPENDENT=DIR+'check_hull_independent.cjs';
const LOCALITY=DIR+'check_quadratic_gain_locality.py';
const CONTRACT=DIR+'lean_type_contract.json';
const LEAN='research/nightfall/formalization/permission/RobustObservationHull.lean';
const WORKFLOW='.github/workflows/nightfall-robust-observation-hull-lean.yml';
const canonical=x=>Array.isArray(x)?x.map(canonical):
  x&&typeof x==='object'?Object.fromEntries(Object.keys(x).sort().map(k=>[k,canonical(x[k])])):x;
const sha=x=>crypto.createHash('sha256').update(JSON.stringify(canonical(x))).digest('hex');
function abs(rel){
  assert.ok(typeof rel==='string'&&rel&&!path.isAbsolute(rel)&&
    rel.split('/').every(seg=>seg&&seg!=='.'&&seg!=='..'),'untrusted path');
  const p=path.resolve(ROOT,rel);
  assert.ok(p.startsWith(ROOT+path.sep)&&fs.statSync(p).isFile(),'missing file '+rel);
  assert.ok(fs.realpathSync(p).startsWith(ROOT+path.sep),'symlink escaped');
  return p;
}
const read=p=>fs.readFileSync(abs(p));
const blob=p=>{const b=read(p);return crypto.createHash('sha1').update('blob '+b.length+'\0').update(b).digest('hex')};
const json=p=>JSON.parse(read(p));
function run(cmd,args){
  const x=child.spawnSync(cmd,args,{cwd:ROOT,encoding:'utf8',timeout:45000,maxBuffer:1024000});
  assert.equal(x.status,0,'local exact checker failed: '+(x.stderr||x.stdout));
  return x.stdout;
}
function verifyRecord(r,{replay=true}={}){
  assert.equal(r.id,'permission-robust-observation-hull-v1');
  assert.equal(r.programme,'NIGHTFALL Q2 / SCIF / Price of Permission intermediate');
  assert.equal(r.status,'source_matched_scoped_named_lean_receipt');
  assert.equal(r.complete_certification,false);
  assert.equal(r.external_novelty_verified,false);
  assert.equal(r.physical_permission_certified,false);
  assert.equal(r.original_model.path,MODEL);
  assert.equal(r.original_model.embedded_key,'source_model');
  assert.equal(r.original_model.completeness,'synthetic_original_table_only');
  assert.equal(r.derived_instance.embedded_key,'certificate.response_gram');
  assert.equal(r.derived_instance.reconstruction,'original_model_centered_conditional_response_inner_products');
  assert.equal(r.proof_object.embedded_key,'certificate');
  assert.equal(r.proof_object.format,'nightfall.robust-observation-hull.v1');
  assert.equal(r.proof_object.robust_before,'1/6');
  assert.equal(r.proof_object.robust_after,'2/3');
  assert.equal(r.proof_object.source_influence,'2/3');
  assert.equal(r.proof_object.one_to_two_sensor_transition,'exact_fixed_bundle_only');
  assert.equal(r.checker.exact,EXACT);
  assert.equal(r.checker.independent,INDEPENDENT);
  assert.equal(r.checker.locality,LOCALITY);
  assert.equal(r.checker.exact_negative_controls,18);
  assert.equal(r.checker.independent_negative_controls,10);
  assert.equal(r.lean.source,LEAN);
  assert.equal(r.lean.contract,CONTRACT);
  assert.equal(r.lean.compiler_lock,'docs/lean-compiler-lock.json');
  const lock=json('docs/lean-compiler-lock.json');
  assert.deepEqual([...r.lean.axioms].sort(),[...lock.allowed_axioms].sort());
  for(const [file,old] of [
    [MODEL,r.original_model.git_blob_sha1],
    [EXACT,r.checker.exact_blob_sha1],
    [INDEPENDENT,r.checker.independent_blob_sha1],
    [LOCALITY,r.checker.locality_blob_sha1],
    [CONTRACT,r.lean.contract_blob_sha1],
    [LEAN,r.lean.source_blob_sha1]
  ]){
    assert.match(old,/^[0-9a-f]{40}$/);
    assert.equal(blob(file),old,'exact source custody mismatch '+file);
  }
  const obj=json(MODEL);
  assert.equal(obj.schema,'nightfall.robust-observation-hull.v1');
  assert.equal(obj.source_model.kind,'finite-product-original-response/v1');
  assert.equal(sha(obj.source_model),r.original_model.sha256);
  assert.equal(obj.certificate.source_sha256,r.original_model.sha256);
  assert.equal(sha(obj.certificate.response_gram),r.derived_instance.sha256);
  assert.equal(obj.certificate.robust_unobserved_gain,r.proof_object.robust_before);
  assert.equal(obj.certificate.robust_observed_gain,r.proof_object.robust_after);
  assert.equal(obj.certificate.coordinate_influence_y,r.proof_object.source_influence);
  assert.deepEqual(obj.certificate.minimizer_law,['1/2','1/2']);
  const type=json(CONTRACT), lean=read(LEAN).toString();
  assert.equal(type.schema,'nightfall-theorem-contract/v1');
  assert.equal(type.source,LEAN);
  assert.deepEqual(type.targets.map(z=>z.declaration),r.lean.declarations);
  assert.equal(type.targets.length,2);
  for(const t of type.targets){
    assert.ok(t.expected_type.includes('Fin n')&&t.expected_type.includes('ℚ')&&t.expected_type.includes('lam'));
    assert.ok(lean.includes('theorem '+t.declaration.split('.').at(-1)));
  }
  const wf=read(WORKFLOW).toString();
  for(const f of [MODEL,EXACT,INDEPENDENT,LOCALITY,LEAN,CONTRACT]){
    assert.ok(wf.includes(f),'workflow missing source '+f);
  }
  for(const name of r.lean.declarations)assert.ok(wf.includes('--decl '+name));
  assert.ok(wf.includes('--contract '+CONTRACT));
  const evidence=r.evidence;
  assert.equal(evidence.pr,793);
  assert.equal(evidence.exact_head,'f0fa0ea201bc8ffd5c6368b3c25d62b9ed19e1ab');
  assert.equal(evidence.run_id,44210111162);
  assert.equal(evidence.artifact_id,14385218800);
  assert.equal(evidence.ci_url,'https://github.com/d3lefts/d3lefts/actions/runs/44210111162');
  assert.equal(evidence.named_lean_result,'pinned_compiled_exact_types_standard_axioms');
  assert.equal(evidence.independent_lake_check,'not_run');
  assert.equal(evidence.external_human_review,'none');
  assert.equal(r.gates.original_source_model,'finite_reconstructed_and_exactly_checked');
  assert.equal(r.gates.generic_rational_hull_soundness,'pinned_named_lean_pass');
  assert.equal(r.gates.q2_gain_locality,'exact_original_world_finite_audit_not_lean');
  assert.equal(r.gates.json_instance_lean,'not_connected');
  assert.equal(r.gates.zero_error_permission,'not_entailed');
  assert.equal(r.gates.prior_art_novelty,'unresolved');
  assert.ok(r.limitations.some(s=>s.includes('source law')));
  assert.ok(r.limitations.some(s=>s.includes('safety')));
  if(replay){
    const out=JSON.parse(run('python3',['-I',EXACT,MODEL,'--self-test']).split('\n').slice(1).join('\n'));
    assert.equal(out.status,'PASS');
    assert.equal(out.robust_gain_without_changed_source,'1/6');
    assert.equal(out.robust_gain_after_changed_source,'2/3');
    assert.match(run('node',[INDEPENDENT]),/10 negative controls rejected/);
    assert.match(run('python3',['-I',LOCALITY]),/PASS: original-world quadratic unlock\/locality/);
  }
  return true;
}
function selfTest(r){
  const clone=x=>JSON.parse(JSON.stringify(x));
  const tests=[
    x=>x.original_model.sha256='0'.repeat(64),
    x=>x.original_model.git_blob_sha1='0'.repeat(40),
    x=>x.derived_instance.sha256='0'.repeat(64),
    x=>x.checker.exact_blob_sha1='0'.repeat(40),
    x=>x.checker.independent_blob_sha1='0'.repeat(40),
    x=>x.checker.locality_blob_sha1='0'.repeat(40),
    x=>x.lean.contract_blob_sha1='0'.repeat(40),
    x=>x.lean.source_blob_sha1='0'.repeat(40),
    x=>x.lean.declarations[0]='Nightfall.RobustObservationHull.not_real',
    x=>x.complete_certification=true,
    x=>x.external_novelty_verified=true,
    x=>x.physical_permission_certified=true,
    x=>x.gates.json_instance_lean='completed',
    x=>x.gates.zero_error_permission='certified',
    x=>x.evidence.independent_lake_check='passed',
    x=>x.evidence.external_human_review='reviewed',
    x=>x.proof_object.robust_before='2/3',
    x=>x.evidence.exact_head='0'.repeat(40)
  ];
  tests.forEach((mut,i)=>{const t=clone(r);mut(t);
    assert.throws(()=>verifyRecord(t,{replay:false}),undefined,'forgery accepted '+i)});
  return tests.length;
}
if(require.main===module){
  const m=json('docs/proof-object-passport.json');
  const rec=m.records.find(x=>x.id==='permission-robust-observation-hull-v1');
  assert.ok(rec,'Proof Passport record missing');
  verifyRecord(rec);
  const n=selfTest(rec);
  console.log('PASS: source-bound robust observation-hull Proof Passport; '+
    n+' metadata and scope attacks rejected (generic Lean, NOT JSON-in-Lean or physical safety)');
}
module.exports={verifyRecord,selfTest};
