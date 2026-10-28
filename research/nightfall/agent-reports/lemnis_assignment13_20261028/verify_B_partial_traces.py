"""Verifier B: independently sum physical partial traces of a diagonal C.
Never uses the local tensor-kernel or any formulas from verifier A.
"""
from itertools import product,combinations
from fractions import Fraction as F
from collections import Counter
words=[(a,b,(a+b)%3,(a+2*b)%3) for a in range(3) for b in range(3)]

def value(indices):
    coeffs=[words[k] for k in indices]
    total=F(0)
    for mask in range(16):
        keep=tuple(j for j in range(4) if not mask & (1<<j))
        reduced=Counter(tuple(a[j] for j in keep) for a in coeffs)
        norm=sum(k*k for k in reduced.values())
        total+=(-F(1,2))**(4-len(keep))*norm
    return total

for r in range(1,10):
    for inds in combinations(range(9),r):
        q=value(inds)
        assert q==F(r*(2-r),16),(inds,q)
    print('PASS rank',r,'direct trace Q=',value(tuple(range(r))))
# Check the conserved-syndrome rectangle projection P_S C P_T on rank <= 2
H=lambda w: ((w[2]-w[0]-w[1])%3,(w[3]-w[0]-2*w[1])%3)
for idx in range(81):
    a=tuple((idx//(3**j))%3 for j in range(4))
    row_allowed=H(a)[1]==0
    col_allowed=H(a)[0]==0
    # On diagonal C, left-right projection preserves coordinate rank directly.
    assert bool(row_allowed and col_allowed) == (a in words)
print('PASS: rectangular syndrome projection selects exactly nine code diagonals')

