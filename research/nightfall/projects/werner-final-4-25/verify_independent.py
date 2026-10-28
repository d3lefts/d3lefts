#!/usr/bin/env python3
"""Independent rational replay for the final Werner 24/25-copy certificates.

Run construct_A.py first. Standard-library only. This script reconstructs
binomial coefficients with Pascal rows and block margins from closed form.
"""
from pathlib import Path
from fractions import Fraction as F
from math import factorial
import json,csv

ROOT=Path(__file__).resolve().parent
def margin(k):
    q,r=divmod(k,3)
    return F(4**q*(2 if r==2 else 1),3**k)
def pascal(k):
    row=[1]
    for _ in range(k):
        nxt=[1]*(len(row)+1)
        for i in range(1,len(row)): nxt[i]=row[i-1]+row[i]
        row=nxt
    return row
def response(k,t):
    d=t-F(1,3)
    c=pascal(k)
    return 3*k*d+sum((F(2*c[j])*d**j/margin(j) for j in range(3,k+1,2)),F(0))

data=json.loads((ROOT/'certificate.json').read_text())
with (ROOT/'COPY4_TO_25.csv').open() as fp:
    rows=list(csv.DictReader(fp))
assert [int(r['k']) for r in rows]==list(range(4,26))
for row in rows:
    k=int(row['k'])
    t=F(row['best_final_t'])
    prior=F(row['archive_best_t'])
    assert t>=prior>=F(row['archive_theorem_only_t'])
    assert F(row['gain_vs_archive'])==t-prior
    assert response(k,F(row['new_3block_analytic_sup_t_1e9']))<1
for k,expect in [(24,F(8659,25000)),(25,F(4323,12500))]:
    z=data[str(k)]
    assert F(z['t'])==expect==F(rows[k-4]['best_final_t'])
    assert F(z['delta'])==expect-F(1,3)
    assert F(z['b'])==margin(k)
    r=response(k,expect)
    assert r==F(z['R'])<1
    assert 1-r==F(z['relative_slack'])>0
    assert margin(k)*(1-r)==F(z['margin'])>0
c=F(31,100)
head=3*c+sum((F(2)*c**j/F(factorial(j))/margin(j) for j in range(3,19,2)),F(0))
tail=2*(3*c)**19/F(factorial(19))/(1-(3*c)**2/F(20*21))
assert head+tail==F(data['uniform_k_ge_3']['explicit_upper_R'])<1
assert 1-head-tail==F(data['uniform_k_ge_3']['lower_slack'])>0
print('PASS exact 24/25 margins, 4-25 ledger and every-finite-k tail certificate')
