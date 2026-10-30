#!/usr/bin/env python3
"""Axiom independent exact four-qutrit collision checker.
Enumerates all 72 omitted sector pairs and all 81x81 matrix-unit crossings;
uses a 16-subset inclusion-exclusion formula, not Vesper's local tensor product.
Finite arithmetic only; imported nine-word positivity remains unaudited.
"""
import itertools
from collections import Counter
F=range(3)
words=list(itertools.product(F,repeat=4))
labels=list(itertools.product(F,repeat=2))
def H(w):return ((w[2]-w[0]-w[1])%3,(w[3]-w[0]-2*w[1])%3)
cosets={s:[w for w in words if H(w)==s] for s in labels}
S={(0,0),(1,0),(2,0)}
T={(0,0),(0,1),(0,2)}
old={(s,t) for s in S for t in T}
def diff(s,t):return ((s[0]-t[0])%3,(s[1]-t[1])%3)
by_diff={diff(s,t):(s,t) for s,t in old}
assert len(by_diff)==9
def scaled_cross(a,b,c,d):
    matches=[int(a[j]==c[j] and b[j]==d[j]) for j in range(4)]
    diag=[int(a[j]==b[j] and c[j]==d[j]) for j in range(4)]
    total=0
    for flags in itertools.product((0,1),repeat=4):
        v=(-1)**sum(flags)*2**(4-sum(flags))
        for j in range(4):v*=diag[j] if flags[j] else matches[j]
        total+=v
    return total
hist=Counter(); sample=None
for new in itertools.product(labels,repeat=2):
    if new in old:continue
    prev=by_diff[diff(*new)]
    best=0; witness=None
    for a in cosets[prev[0]]:
        for b in cosets[prev[1]]:
            for c in cosets[new[0]]:
                for d in cosets[new[1]]:
                    q=scaled_cross(a,b,c,d)
                    if abs(q)>best:
                        best=abs(q);witness=(a,b,c,d,q)
    assert best>=4
    hist[best]+=1
    if sample is None:sample=(new,prev,witness)
assert hist==Counter({4:16,8:56}),hist
# P_U(C)=P_S C P_T, so rank(P_U(C))<=rank(C) by rank(ABC)<=rank(B).
a=b=(0,0,0,0);c=(1,1,1,1);d=(2,2,2,2)
assert H(a) in S and H(b) in T and not (H(c) in S and H(d) in T)
assert (scaled_cross(a,b,a,b),scaled_cross(c,d,c,d),scaled_cross(a,b,c,d))==(1,16,0)
print({"status":"PASS","72_sector_crossings":dict(hist),"sample":sample,
       "Q_of_rank_two_outside_old":"17/16",
       "open_gate":"imported nine-word rank-two positivity"})
