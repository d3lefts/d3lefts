#!/usr/bin/env python3
"""Fail-closed source/status audit for two prime-zeta paper theorem promotions.

This script is NOT a Lean kernel checker, independent proof review, or proof of
analytic continuation. It rejects promotion metadata that overstates evidence.
Run: python scripts/check_prime_zeta_paper_theorem_promotions.py --self-test
"""
import argparse
import copy
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parent.parent
LEDGER=ROOT/'docs/recent-research.json'
THEOREM=ROOT/'research/nightfall/structural_information/PRIME_ZETA_FIRST_STRIP_BOUNDARY_PAPER_THEOREMS_20261122.md'
RECORDS={
 'prime-zeta-first-strip-paper-theorem':
   ROOT/'research/nightfall/2026-11-recent-passports/prime-zeta-first-strip-paper-theorem.md',
 'prime-zeta-natural-boundary-paper-theorem':
   ROOT/'research/nightfall/2026-11-recent-passports/prime-zeta-natural-boundary-paper-theorem.md',
}

def check(data, files=True):
    assert data['schema']=='nightfall.recent-research-passports.v1'
    assert data['frozen_legacy_registry_unchanged'] is True
    assert data['status_definitions']['analytic']=='Paper or exact-test candidate'
    assert len({x['id'] for x in data['claims']})==len(data['claims'])
    assert len(data['claims'])>=27
    for name,passport in RECORDS.items():
        record=next((r for r in data['claims'] if r['id']==name), None)
        assert record is not None, f'missing {name}'
        assert record['tier']=='analytic', f'unsafe tier {name}'
        assert record['pr']==1043, f'wrong source PR {name}'
        assert record['run'] is None and not record['head'] and not record['receipt'], f'fake analytic formal replay {name}'
        assert 'Paper theorem' in record['status_label'], name
        assert 'NOT Lean' in record['declaration'], name
        assert 'not' in record['limit'].lower() and ('novel' in record['limit'].lower() or 'priority' in record['limit'].lower())
        assert '1035' in record['certificate'], name
        assert '1040' in record['next'], name
        assert '/blob/main/research/nightfall/2026-11-recent-passports/' in record['passport']
        if files:
            s=passport.read_text(encoding='utf-8')
            assert len(s)>900 and 'Proof Passport' in s
            assert 'not' in s.lower() and ('Lean' in s or 'kernel' in s)
            assert '1040' in s
    if files:
        source=THEOREM.read_text(encoding='utf-8')
        for text in ('## Theorem 1', '## Theorem 2', 'P\'(w)', 'natural boundary', 'Fröberg'):
            assert text.lower() in source.lower(), f'missing theorem input: {text}'
        assert (ROOT/'scripts/rigidity_to_certificate_exact_audit.py').exists()
    return True

def self_test(data):
    check(data)
    cases=0
    for id in RECORDS:
        for field,value in [('tier','merged-lean'),('run',999999),('status_label','Certified / Novel'),('head','deadcafe')]:
            d=copy.deepcopy(data)
            r=next(x for x in d['claims'] if x['id']==id)
            r[field]=value
            try:check(d,files=False)
            except AssertionError:cases+=1
            else:raise AssertionError(f'unsafe promotion escaped guard: {id}.{field}')
    d=copy.deepcopy(data)
    d['claims']=[x for x in d['claims'] if x['id']!='prime-zeta-first-strip-paper-theorem']
    try:check(d,files=False)
    except AssertionError:cases+=1
    else:raise AssertionError('missing passport escaped')
    assert cases==9
    print('PASS: 9 adversarial metadata mutations rejected')

if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--self-test',action='store_true')
    args=parser.parse_args()
    d=json.loads(LEDGER.read_text(encoding='utf-8'))
    check(d)
    print('PASS: first-strip and natural-boundary paper passports are source linked; no fake formal/novel upgrade')
    if args.self_test:self_test(d)
