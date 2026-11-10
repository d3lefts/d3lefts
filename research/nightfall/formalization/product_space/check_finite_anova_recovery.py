"""Independent exact-rational finite ANOVA / maximal-interaction audit.

Scope: positive atomic product measures, <=3 coordinates. Not a proof of
countable-product selection, infinite products, or historical originality.
"""
from fractions import Fraction as F
from itertools import combinations, product
from math import prod
from random import Random
import json

def powerset(indices):
    t=tuple(indices)
    return [frozenset(s) for k in range(len(t)+1) for s in combinations(t,k)]

def anova(f, sizes, laws):
    n=len(sizes); X=list(product(*(range(s) for s in sizes)))
    subsets=powerset(range(n)); means={}
    for S in subsets:
        means[S]={}
        for x in X:
            means[S][x]=sum((
                f[tuple(x[i] if i in S else y[i] for i in range(n))]
                *prod((laws[i][y[i]] for i in range(n) if i not in S),start=F(1))
                for y in X if all(y[i]==0 for i in S)),F(0))
    terms={S:{x:sum(((-1)**(len(S)-len(T))*means[T][x]
                      for T in subsets if T<=S),F(0)) for x in X}
           for S in subsets}
    return X,subsets,terms

def check(f,sizes,laws):
    X,ss,g=anova(f,sizes,laws)
    n=len(sizes)
    for x in X:
        assert sum((g[S][x] for S in ss),F(0))==f[x],("reconstruction",x)
    for S in ss:
        for i in S:
            for x in X:
                assert sum((laws[i][z]*g[S][tuple(z if j==i else x[j] for j in range(n))]
                    for z in range(sizes[i])),F(0))==0,("centering",S,i,x)
    degree=max((len(S) for S in ss if any(g[S][x] for x in X)),default=0)
    top=[S for S in ss if len(S)==degree and any(g[S][x] for x in X)]
    for S in top:
        if not S:continue
        anchor=X[0]
        energy=sum((prod((laws[i][u[i]] for i in S),start=F(1))*
            g[S][tuple(u[i] if i in S else anchor[i] for i in range(n))]**2
            for u in X if all(u[j]==0 for j in range(n) if j not in S)),F(0))
        assert energy>0
        R=max(f.values())-min(f.values())
        for x in X:
            section=[(f[tuple(u[i] if i in S else x[i] for i in range(n))],
                prod((laws[i][u[i]] for i in S),start=F(1)))
                for u in X if all(u[j]==0 for j in range(n) if j not in S)]
            mean=sum((v*w for v,w in section),F(0))
            variance=sum((w*(v-mean)**2 for v,w in section),F(0))
            changed=sum((w for v,w in section if v!=f[x]),F(0))
            assert variance>=energy,("variance lower bound",S,x,variance,energy)
            assert changed*R*R>=energy,("probability lower bound",S,x,changed,R,energy)
    for A in ss:
        rest=[i for i in range(n) if i not in A]; seen=set()
        for a in X:
            key=tuple(a[i] for i in A)
            if key in seen:continue
            seen.add(key)
            s2=tuple(sizes[i] for i in rest)
            p2=tuple(laws[i] for i in rest)
            ff={z:f[tuple(a[i] if i in A else z[rest.index(i)]
                           for i in range(n))]
                for z in product(*(range(m) for m in s2))}
            X2,sets2,parts2=anova(ff,s2,p2)
            sec_degree=max((len(S) for S in sets2 if any(parts2[S][z] for z in X2)),default=0)
            assert sec_degree<=degree,("section raised degree",A,key,degree,sec_degree)
    return degree

rng=Random(9102026)
cases=0; max_degree=0
families=[
    ((2,2,2),((F(1,2),F(1,2)),)*3,256,(F(0),F(1))),
    ((2,2,2),((F(1,3),F(2,3)),(F(3,5),F(2,5)),(F(1,4),F(3,4))),256,(F(0),F(1))),
    ((2,3,2),((F(1,3),F(2,3)),(F(1,5),F(1,2),F(3,10)),(F(2,5),F(3,5))),240,(F(-1),F(0),F(2)))
]
for sizes,laws,count,palette in families:
    X=list(product(*(range(k) for k in sizes)))
    for k in range(count):
        if len(X)==8:
            f={x:F((k>>j)&1) for j,x in enumerate(X)}
        else:
            f={x:rng.choice(palette) for x in X}
        max_degree=max(max_degree,check(f,sizes,laws));cases+=1
# Four-coordinate genuinely quadratic functions with biased independent bits.
# These force maximal blocks to have nonempty complementary coordinates.
sizes4=(2,2,2,2)
laws4=((F(1,2),F(1,2)),(F(1,3),F(2,3)),(F(3,5),F(2,5)),(F(2,7),F(5,7)))
X4=list(product((0,1),repeat=4))
for trial in range(200):
    linear=[F(rng.randrange(-4,5),rng.randrange(1,5)) for _ in range(4)]
    quadratic={(i,j):F(rng.randrange(-4,5),rng.randrange(1,5))
               for i in range(4) for j in range(i+1,4)}
    f4={x:sum((linear[i]*x[i] for i in range(4)),F(0))+
          sum((quadratic[i,j]*x[i]*x[j] for i in range(4)
               for j in range(i+1,4)),F(0))
        for x in X4}
    degree=check(f4,sizes4,laws4)
    assert degree<=2
    max_degree=max(max_degree,degree);cases+=1
print(json.dumps({"status":"PASS","cases":cases,"maximum_degree_tested":max_degree,
"method":"finite exact rational ANOVA, reconstruction, centering, all sections, maximal variance and resampling bounds",
"limitations":"finite exhaustive 3-bit Boolean + seeded ternary/heterogeneous tests only",
"seed":9102026},indent=2))
