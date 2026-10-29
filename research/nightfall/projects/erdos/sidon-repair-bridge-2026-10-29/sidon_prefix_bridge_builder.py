#!/usr/bin/env python3
"""Deterministic finite prefix-compatible Sidon witness, not asymptotic #44.

Bose-Chowla field model F_1009[u]/(u^2-11), theta=7+u.
The deletion indices were obtained by MILP; the certificate is independently
verified from exact integer pair sums, not from a solver's success flag.
"""
from hashlib import sha256
import json

P, T, THETA, Q = 1009, 11, (7, 1), 776795
PREFIX = (1, 2, 4, 8, 13)
REMOVED = (1,8,15,18,20,23,24,43,52,55,70,75,87,97,118,122,125,132,133,155,310,312,611,691,712,740,800,806,813,872,914,941,945,962,977,978,979,981,983,988,989,994,1002,1006)


def field_product(x, y):
    return ((x[0]*y[0] + T*x[1]*y[1]) % P,
            (x[0]*y[1] + x[1]*y[0]) % P)


def build():
    order = P*P-1
    element = (1, 0)
    marks = []
    for e in range(order):
        if element[1] == THETA[1]:
            marks.append(e)
        element = field_product(element, THETA)
    assert element == (1, 0) and len(marks) == P
    assert len(set(marks)) == P and marks == sorted(marks)
    removed = set(REMOVED)
    B = [Q+x for i, x in enumerate(marks) if i not in removed]
    M = max(B)
    return {'schema':'nightfall-sidon-prefix-bridge-finite-v1',
            'date':'2026-10-29', 'p':P, 'modulus':order,
            'field_u_squared':T, 'theta':list(THETA),
            'prefix':list(PREFIX), 'translation':Q,
            'removed_sorted_indices':list(REMOVED),
            'size_before':len(marks), 'size_after':len(B),
            'size_with_prefix':len(B)+len(PREFIX), 'endpoint_M':M,
            'two_B_squared_minus_M':2*len(B)**2-M,
            'B_json_sha256':sha256(json.dumps(B,separators=(',',':')).encode()).hexdigest(),
            'scope':'one finite construction; not a record or asymptotic #44 theorem'}


if __name__=='__main__':
    print(json.dumps(build(),indent=2,sort_keys=True))
