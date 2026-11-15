#!/usr/bin/env python3
"""Separate algebraic/dual validation of NIGHTFALL's exact model receipt.

Reads a printed artifact, not constructor functions. The dual bound and
piecewise closed form are independently derived from the model parameters.
A local checker is not a non-author, peer-reviewed mathematical referee.
"""
from fractions import Fraction as Q
from pathlib import Path
import hashlib, json, sys


def f(x):return Q(x)
def inner(a,b):return sum((x*y for x,y in zip(a,b)),Q(0))


def formula(r):
    if r<=Q(1,159):
        return Q(9,10)-Q(4,5)-Q(1,5)*(1-159*r)/(199-159*r)
    return Q(9,10)-Q(8,5)/(1+159*r)


def check(obj):
    assert obj['status']=='exact_verified_locally'
    assert obj['min_safe_admission']=='9/10'
    assert obj['max_unsafe_admission']=='1/100'
    assert obj['indistinguishable_baseline_cost_units']=='89'
    assert obj['fixed_screen_nominal_cost_units']=='1970/199'
    assert f(obj['nominal_savings_fraction'])==Q(15741,17711)
    assert obj['source_calibration'].startswith('hypothetical')
    s=(Q(4,5),Q(1,5));t0=(Q(1,200),Q(199,200))
    rows=obj['robust_contamination_frontier']
    assert len(rows)==7 and rows[0]['rho']=='0' and rows[-1]['rho']=='1'
    last=Q(-1)
    for row in rows:
        r=f(row['rho']); assert Q(0)<=r<=1
        tt=tuple((1-r)*t0[i]+r*s[i] for i in (0,1))
        u=tuple(map(f,row['unaudited_probabilities']))
        a=tuple(map(f,row['audited_probabilities']))
        assert all(0<=u[i] and 0<=a[i] and u[i]+a[i]<=1 for i in (0,1))
        assert inner(s,tuple(u[i]+a[i] for i in (0,1)))>=Q(9,10)
        assert inner(t0,u)<=Q(1,100) and inner(tt,u)<=Q(1,100)
        q=inner(s,a)
        assert q==f(row['min_paid_audit_probability'])
        assert q*100==f(row['min_paid_audit_cost_units'])
        # Independent closed form = certifying upper bound on unaudited
        # grants, attained by the reported feasible policy.
        assert q==formula(r)
        assert f(row['max_unaudited_safe'])==Q(9,10)-q
        assert q>=last
        last=q
    return {'verifier':'PASS','frontier_rows':len(rows),
            'verified_nominal_audit_probability':'197/1990',
            'verified_10pct_mimic_audit_probability':str(formula(Q(1,10))),
            'verified_full_mimic_audit_probability':'89/100'}


def main():
    src=Path(sys.argv[1]).read_text()
    raw,hexdigest=src.rsplit('\nresult_sha256=',1)
    raw=raw.strip()
    assert hashlib.sha256(raw.encode()).hexdigest()==hexdigest.strip()
    obj=json.loads(raw)
    report=check(obj)
    # Negative controls: change a reported cost and false-admit an unsafe
    # attack; the checker must reject both even if source hash is recomputed.
    bad=json.loads(json.dumps(obj))
    bad['robust_contamination_frontier'][0]['min_paid_audit_cost_units']='0'
    try:check(bad)
    except AssertionError:pass
    else:raise AssertionError('tampered cost was not rejected')
    bad=json.loads(json.dumps(obj))
    bad['robust_contamination_frontier'][0]['unaudited_probabilities'][1]='1'
    try:check(bad)
    except AssertionError:pass
    else:raise AssertionError('unsafe grant was not rejected')
    report['negative_controls']=2
    print(json.dumps(report,indent=2,sort_keys=True))

if __name__=='__main__':main()