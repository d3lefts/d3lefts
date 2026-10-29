#!/usr/bin/env python3
"""Exact F3^n diagonal-phase stabilizer count: counterexample to naive free-orbit transfer."""
from itertools import product
for n in range(1,6):
    G=list(product(range(3),repeat=n))
    for delta in G:
        stabilizer=sum(sum(h[j]*delta[j] for j in range(n))%3==0 for h in G)
        expected=3**n if not any(delta) else 3**(n-1)
        assert stabilizer==expected,(n,delta,stabilizer)
        assert len({sum(h[j]*delta[j] for j in range(n))%3 for h in G})==(1 if not any(delta) else 3)
    print('n=',n,'zero grade stabilizer=',3**n,'nonzero grade stabilizer=',3**(n-1),'grades=',3**n)
print('PASS: nonfree Werner phase orbits block naive F25 quotient transfer')
