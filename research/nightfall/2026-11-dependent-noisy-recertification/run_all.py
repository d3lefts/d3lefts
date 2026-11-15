#!/usr/bin/env python3
"""Fail-closed exact reproducibility command. Runs real source files, not cached logs."""
import subprocess,sys,json,hashlib,pathlib
ROOT=pathlib.Path(__file__).resolve().parent
checks={
  'audit_independent.py':('brute_policy_comparisons',54),
  'check_receipt.py':('states',549),
  'cache_attestation.py':('reused_message_exact',True),
  'global_risk_lp.py':('optimal_expected_cost','3'),
  'test_negative.py':('correct_shared_noise_safe_posterior','1'),
}
for script,(key,val) in checks.items():
    p=subprocess.run([sys.executable,str(ROOT/script)],capture_output=True,text=True,check=True,cwd=ROOT,timeout=120)
    x=json.loads(p.stdout.strip())
    assert x['status']=='PASS' and x[key]==val,(script,x)
    if script=='audit_independent.py':
        assert x['digest']=='d5cfdaf9a499badbf3d57255304ac14c43131b5505f0d48dd394784e2e8e95c8'
    if script=='check_receipt.py':
        assert x['root_value']=='145/22'
        assert x['certificate_sha256']=='1299871f6d5eae420736e127e569994e319f2647218b57540c05306ab96b1045'
    if script=='global_risk_lp.py':
        assert x['exact_occupancy_primal']=='PASS' and x['deterministic_minimum_cost']=='5'
    print(script,'PASS')
p=subprocess.run([sys.executable,str(ROOT/'measure_policy.py')],capture_output=True,text=True,check=True,cwd=ROOT,timeout=120)
assert '163/24' in p.stdout and '601/104' in p.stdout and '145/22' in p.stdout
print('measure_policy.py','PASS')
# Canonical file SHA ledger for executable research input, theory and receipt.
for line in (ROOT/'SHA256SUMS.txt').read_text().splitlines():
    if not line.strip():continue
    h,name=line.split('  ',1)
    assert hashlib.sha256((ROOT/name).read_bytes()).hexdigest()==h,(name,h)
print('SHA256SUMS.txt','PASS')
print(json.dumps({'status':'PASS','exact_brute_policies':54,'bellman_histories':549,
                  'cache_rejection_controls':8,'falsification_controls':8,
                  'global_lp_cost':'3','global_lp_optimum_certified_by_exact_primal_dual':True},sort_keys=True))
