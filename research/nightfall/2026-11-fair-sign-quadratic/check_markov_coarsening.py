#!/usr/bin/env python3
"""Exact conditional-expectation coarse-rank certificate and spectral negative control.

Finite full-support arbitrary leaf laws; completely rational arithmetic.
Checks every partial coarse transcript and an explicit L2 orthogonal projection
whose L-infinity norm exceeds one. Does not certify external novelty/Lean.
"""
from fractions import Fraction as Q
from itertools import product

DOM = ((0, 1, 2), (-1, 1), (0, 1, 2, 3), (0, 1, 2, 3))
PROB = (
    (Q(1,2),Q(1,3),Q(1,6)),
    (Q(1,2),Q(1,2)),
    (Q(1,2),Q(1,4),Q(1,8),Q(1,8)),
    (Q(1,3),Q(1,3),Q(1,6),Q(1,6)),
)
COARSE = ((0,0,1,1),(0,1,0,1))

rows=[]
for s in product(*DOM):
    p=Q(1)
    for i,v in enumerate(s):
        p*=PROB[i][DOM[i].index(v)]
    rows.append((s,p))
assert sum((p for s,p in rows),Q()) == 1


def center(k, vals):
    law=PROB[2+k]
    mu=sum((law[i]*vals[i] for i in range(4)),Q())
    return tuple(Q(z)-mu for z in vals)


PHI=(center(0,(2,-1,3,-2)),center(1,(-3,4,0,1)))
PSI=(center(0,(0,3,-2,1)),center(1,(4,-1,2,-3)))


def feature_x(x):
    return (Q(1),Q(-1),Q(-1))[x]


def f(s):
    x,z,y0,y1=s
    u=feature_x(x)
    h=Q(3)+2*u+z-u*z
    a=(Q(2)+u+z+2*u*z, Q(-1)+2*u-2*z+u*z)
    b=(Q(-2)+u-3*z+u*z, Q(4)-u+2*z-u*z)
    return (h+sum((a[k]*PHI[k][s[2+k]]+
                   b[k]*PSI[k][s[2+k]] for k in range(2)),Q()))/Q(30)


def coarse(s):
    return (COARSE[0][s[2]],COARSE[1][s[3]])


def grouped_coarse_mean(s):
    x,z,y0,y1=s
    y0c,y1c=coarse(s)
    acc=den=Q()
    for k0 in range(4):
        if COARSE[0][k0]!=y0c:continue
        for k1 in range(4):
            if COARSE[1][k1]!=y1c:continue
            p=PROB[2][k0]*PROB[3][k1]
            acc+=p*f((x,z,k0,k1))
            den+=p
    return acc/den


VAL={s:f(s) for s,p in rows}
PROJ={s:grouped_coarse_mean(s) for s,p in rows}
B=max(abs(v) for v in VAL.values())
assert max(abs(v) for v in PROJ.values())<=B
assert any(VAL[s]!=PROJ[s] for s,p in rows)

TAIL=sum((p*(VAL[s]-PROJ[s])**2 for s,p in rows),Q())
assert TAIL>0

# Conditional mean and risk decomposition at every partial COARSE transcript.
checks=0
for mask in range(16):
    observed=[i for i in range(4) if mask>>i & 1]
    options=[DOM[i] if i<2 else (0,1) for i in observed]
    for vals in product(*options):
        obs=dict(zip(observed,vals))
        subset=[]
        for s,p in rows:
            signals=(s[0],s[1])+coarse(s)
            if all(signals[i]==v for i,v in obs.items()):
                subset.append((s,p))
        mass=sum((p for s,p in subset),Q())
        assert mass>0
        mean_f=sum((p*VAL[s] for s,p in subset),Q())/mass
        mean_p=sum((p*PROJ[s] for s,p in subset),Q())/mass
        assert mean_f==mean_p,(obs,mean_f,mean_p)
        v_f=sum((p*(VAL[s]-mean_f)**2 for s,p in subset),Q())/mass
        v_p=sum((p*(PROJ[s]-mean_p)**2 for s,p in subset),Q())/mass
        tail=sum((p*(VAL[s]-PROJ[s])**2 for s,p in subset),Q())/mass
        cross=sum((p*(VAL[s]-PROJ[s])*(PROJ[s]-mean_p)
                    for s,p in subset),Q())/mass
        assert cross==0,(obs,cross)
        assert v_f==v_p+tail,(obs,v_f,v_p,tail)
        checks+=1

assert checks==(1+3)*(1+2)*(1+2)*(1+2)==108

# Exact rank-one L2 spectral projector can amplify a bounded function.
P=(Q(1,10000),Q(3333,10000),Q(3333,10000),Q(3333,10000))
phi=(Q(100),Q(1),Q(-1),Q(-100,3333))
g=(Q(1),Q(1),Q(-1),Q(-1))
assert sum((P[i]*phi[i] for i in range(4)),Q())==0
normsq=sum((P[i]*phi[i]**2 for i in range(4)),Q())
coef=sum((P[i]*g[i]*phi[i] for i in range(4)),Q())/normsq
amplification=coef*phi[0]
assert amplification>1 and max(abs(z) for z in g)==1

print("PASS: nonzero Markov-coarsening tail =",TAIL)
print("PASS: exact conditional risks for",checks,"partial coarse transcripts")
print("PASS: rank-one non-Markov L2 spectral projector amplification =",amplification)
print("SCOPE: finite exact identities; universal proof and originality separate")
