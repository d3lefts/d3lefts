#!/usr/bin/env python3
"""Exact Z[t] certificate: 9 optimal adaptive F_(p²)^5 queries for every prime p>=7."""
from math import comb
import json
def classes(p):
 return 1+sum(p**j for j in range(10))
def transcripts(p):
 return (p+2)**8
# Coefficient of t^j in N(7+t)-(9+t)^8. Integer identities only.
coefficients=[
 sum(comb(k,j)*7**(k-j) for k in range(j,10))
 + int(j==0)
 - (comb(8,j)*9**(8-j) if j<=8 else 0)
 for j in range(10)
]
expected=[4032488,21145725,18454080,7608378,1839258,
          281982,27966,1749,63,1]
assert coefficients==expected
assert all(v>0 for v in coefficients)
p=7
assert classes(p)==47079209
assert transcripts(p)==43046721
assert classes(p)-transcripts(p)==4032488
for p in (7,11,13,17,19,29,101):
 t=p-7
 assert classes(p)-transcripts(p)==sum(c*t**j for j,c in enumerate(coefficients))
 assert classes(p)>transcripts(p)
print(json.dumps({'verdict':'PASS','fieldFamily':'F_(p^2), exponent p-1, all primes p>=7',
 'dimension':5,'adaptiveQueryOptimum':9,'unrestrictedDecisionTreeLowerBound':9,
 'priorUpperBound':'Axiom coordinate-first 2k-1 adaptive protocol',
 'globalLowerBoundCertificate':{'expansionVariable':'t=p-7','coefficientsAscending':coefficients,
 'allCoefficientsStrictlyPositive':True,'p7Classes':classes(7),'p7EightQueryOutputs':transcripts(7)},
 'scope':'Exact mathematical corollary; external publication priority audit open.'},indent=2))
