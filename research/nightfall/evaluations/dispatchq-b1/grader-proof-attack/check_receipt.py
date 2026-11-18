#!/usr/bin/env python3
"""Audit public receipt consistency, NOT private scorer execution authenticity."""
from __future__ import annotations
import hashlib
import json
from pathlib import Path

r=json.loads((Path(__file__).with_name('RECEIPT.json')).read_text())
assert r['benchmark']=='NIGHTFALL-DISPATCHQ-B1'
assert r['status']=='internal_source_exact_author_side_not_independently_reviewed'
assert r['model_attempts']==0 and r['independent_human_review'] is False
for key in ('candidate_source_sha256','v01_tests_sha256','v02_tests_sha256','original_archive_sha256','private_v02_archive_sha256'):
    value=r[key]
    assert isinstance(value,str) and len(value)==64 and all(c in '0123456789abcdef' for c in value), key
assert r['tests_v01']==20 and r['tests_v02']==25
assert r['max_points_v01']==r['max_points_v02']==100
assert (r['pre_registered_families'],r['pre_registered_executed'],r['post_registered_executed'])==(12,11,1)
assert len(r['faults'])==12 and len({f['family'] for f in r['faults']})==12
assert len(r['reference_v02_repeats'])==10 and set(r['reference_v02_repeats'])=={100}
assert len(r['defective_starter_v02_repeats'])==10
assert all(type(v) is int and 0<=v<=100 for v in r['defective_starter_v02_repeats'])
for f in r['faults']:
    assert all(type(f[k]) is int and 0<=f[k]<=100 for k in ('v01_score','v02_score'))
assert sum(f['v01_score']==100 for f in r['faults'])==5
assert sum(f['v02_score']==100 for f in r['faults'])==0
assert r['independent_contract_witnesses']['reference_passed']==r['independent_contract_witnesses']['total']==5
assert r['independent_contract_witnesses']['five_surviving_mutants_each_fail_own_witness'] is True
assert 'token_unique' in {f['family'] for f in r['faults']}
print('PASS: 12 fault scores, 5 baseline false passes, 0 v0.2 false passes; receipt consistent (NOT replay attestation).')
