#!/usr/bin/env python3
"""Exact rational checks for a terminating measured-loop *subfamily*.

At each step a single oracle call occurs; the classical control then accepts
with probability a_x, rejects with b_x, or repeats with c_x=1-a_x-b_x.
This checks stochastic cost and truncation, NOT coherent quantum polynomial
degree or unrestricted instrument semantics.
"""
from fractions import Fraction as F
import json

cases = [(F(1,4), F(1,2), F(1,2), F(1,4)),
         (F(1,3), F(1,3), F(1,5), F(2,5))]
rows = []
for a0,b0,a1,b1 in cases:
    row = {}
    for x,(a,b) in enumerate(((a0,b0),(a1,b1))):
        c = 1-a-b
        assert 0 <= c < 1
        expectation = 1/(a+b)
        eventual_accept = a/(a+b)
        for K in range(1,13):
            truncated_accept = a*sum((c**i for i in range(K)),F(0))
            tail = c**K
            assert eventual_accept-truncated_accept == eventual_accept*tail
            assert tail <= expectation/F(K)
            assert 0 <= truncated_accept <= 1
        row[str(x)] = {
            "expected_queries":str(expectation),
            "eventual_accept":str(eventual_accept),
            "continue_probability":str(c),
            "truncation_error_K12":str(eventual_accept*c**12)}
    rows.append(row)
print(json.dumps({
    "scope":"exact rational classical-control loop subfamily; not general coherent quantum theorem",
    "cases":rows,"K_values_checked":12,"checks":len(cases)*2*12},indent=2))
