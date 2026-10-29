#!/usr/bin/env python3
"""Exact independent audit: prefix-preserving Sidon construction, 2026-10-29.
No solver or builder imports. Classical Bose-Chowla source, 40 explicit deletions.
NIGHTFALL finite improvement only; not a global/asymptotic Erdős record.
"""
from hashlib import sha256
import json

p = 1009
v = p * p - 1
d = 11
theta = (7, 1)
T = 776570
A = [1, 2, 4, 8, 13]
R = {28,33,39,41,49,52,54,57,72,78,84,91,98,103,121,176,
     310,312,611,691,712,740,801,806,813,849,859,868,878,908,
     943,949,955,961,962,984,991,998,1003,1005}
assert len(R) == 40
assert pow(d, (p - 1) // 2, p) == p - 1

def mul(x, y):
    return ((x[0]*y[0] + d*x[1]*y[1]) % p,
            (x[0]*y[1] + x[1]*y[0]) % p)
def power(x, k):
    result = (1, 0)
    while k:
        if k & 1:
            result = mul(result, x)
        x = mul(x, x)
        k //= 2
    return result

# Prime factors of v = 1008 * 1010: 2,3,5,7,101.
assert all(power(theta, v // factor) != (1, 0)
           for factor in (2,3,5,7,101))
x, y = 1, 0
S = []
for e in range(v):
    if y == 1:
        S.append(e)
    x, y = (7*x + 11*y) % p, (x + 7*y) % p
assert (x,y) == (1,0) and len(S) == p and sorted(S) == S

mod_sums = set()
for i, a in enumerate(S):
    for b in S[i:]:
        s = (a+b) % v
        assert s not in mod_sums, ("modular collision",a,b,s)
        mod_sums.add(s)
assert len(mod_sums) == 509545

B = [T+s for i, s in enumerate(S) if i not in R]
assert len(B) == 969 and min(B) > max(A) and max(B) == 1794091
assert sha256(json.dumps(B,separators=(",",":")).encode()).hexdigest() == (
    "5c7d0e030377f9d441dc1e613a20d0902fe14c84cfccf69b63fc8f5f947bef7d"
)
V = sorted(A+B)
sums = set()
for i, a in enumerate(V):
    for b in V[i:]:
        z = a+b
        assert z not in sums, ("integer collision",a,b,z)
        sums.add(z)
assert len(V) == 974 and len(sums) == 474825
margin = 974**2 * 1794316 - 970**2 * 1794091
assert margin == 14164303716 > 0
print("PASS",len(V),"marks; endpoint",max(V),
      "integer sums",len(sums),"exact squared-density margin",margin)
