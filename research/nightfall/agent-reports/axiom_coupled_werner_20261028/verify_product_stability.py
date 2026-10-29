#!/usr/bin/env python3
"""Exact rational independent physical-partial-trace test of Axiom's product-state stability.
No numpy, no imported NIGHTFALL code.
"""
from fractions import Fraction as F
from collections import defaultdict
from itertools import product
from math import prod
import json

def outer(u,v):return {(a,b):z*w.conjugate() for a,z in u.items() for b,w in v.items()}
def n2(vec):return sum(int(z.real)**2+int(z.imag)**2 for z in vec.values())
def partial_norms(X,n):
    ans=[]
    for mask in range(1<<n):
        drop=[j for j in range(n) if mask>>j & 1]
        keep=[j for j in range(n) if not (mask>>j & 1)]
        A=defaultdict(complex)
        for (a,b),z in X.items():
            if all(a[j]==b[j] for j in drop):
                A[(tuple(a[j] for j in keep),tuple(b[j] for j in keep))]+=z
        ans.append(sum(int(v.real)**2+int(v.imag)**2 for v in A.values()))
    return ans

checks=[]
for amp in (4,8,16,32):
    u={(0,0):complex(amp),(1,1):1+0j}
    v=u
    n=2;ts=[F(1,2),F(1,2)]
    X=outer(u,v)
    scores=partial_norms(X,n)
    A2=n2(u)*n2(v)
    L=F(1,4)
    gap=F(1,2)
    Q=sum((prod((-ts[j] for j in range(n) if mask>>j & 1),start=F(1))*v for mask,v in enumerate(scores)),F(0))
    defect=Q-L*A2
    eps=defect/(gap*A2)
    assert defect>=0
    symmass=F(sum(scores),2**n*A2)
    assert 1-symmass<=eps
    # full-swap overlap and each 1-site overlap against their swap bounds
    assert F(scores[3],A2)>=1-2*eps
    for j in range(n):
        assert F(scores[1<<j],A2)>=1-2*eps
    # Top product eigenvector is |00>, with fidelity amp²/(amp²+1).
    product_fidelity=F(amp*amp,amp*amp+1)
    assert product_fidelity>=max(F(0),1-4*n*eps)
    checks.append({'amp':amp,'defect':str(defect),'epsilon':str(eps),'product_fidelity':str(product_fidelity),'lower_bound':str(max(F(0),1-8*eps))})

# Mutation/falsifier: 100x spectral gap would incorrectly certify this input.
amp=8
eps=F(256,4225)
actual=F(64,65)
false_bound=1-F(8,100)*eps
assert false_bound>actual
print(json.dumps({'status':'PASS','exact_two_site_controls':checks,'gap_mutation':'100x gap rejected','no_external_dependencies':True},indent=2))
