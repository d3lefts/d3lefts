from itertools import product
from fractions import Fraction as F
from random import Random
from math import prod
rng=Random(20261125)

def check(C, alph, deps, E, D, t, components):
    n=len(C[0]); k=(len(C)-1).bit_length(); assert len(C)==2**k
    d=min(sum(a!=b for a,b in zip(x,y)) for x in C for y in C if x!=y)
    assert 2*t<d
    Z=list(product(*alph)); valid={}
    for z in Z:
        candidates=[x for x in C if D(x)==z and sum(a!=b for a,b in zip(E(z),x))<=t]
        assert len(candidates)<=1
        if candidates: valid[z]=candidates[0]
    high=[i for i in range(len(alph)) if sum(i in S for S in deps)>=d-2*t]
    low=[i for i in range(len(alph)) if i not in high]
    Q={z:F(0) for z in Z}; union=set()
    for weight, ps in components:
        mode=[max(range(len(p)),key=lambda j:p[j]) for p in ps]
        masses={z:prod(ps[i][a] for i,a in enumerate(z)) for z in Z}
        off=sum(masses[z] for z in valid if any(z[i]!=mode[i] for i in low))
        outside=sum(masses[z] for z in Z if z not in valid)
        assert off<=outside,(C,high,low,off,outside)
        ls={x for z,x in valid.items() if all(z[i]==mode[i] for i in low)}
        # Exact list capacity using actual high-coordinate decoder image sizes.
        cap=prod(len({D(x)[i] for x in C}) for i in high)
        assert len(ls)<=cap
        union.update(ls)
        for z in Z: Q[z]+=weight*masses[z]
    assert sum(Q.values())==1
    # Maximum good-event probability over all couplings of Q to uniform C.
    success=sum(min(F(1,len(C)),sum(Q[z] for z in valid if valid[z]==x)) for x in C)
    eta=1-success
    assert F(len(union),len(C))>=1-2*eta
    assert F(len(components)*cap,len(C))>=1-2*eta
    return eta< F(1,2) and cap<len(C)

def marginal(a):
    w=[rng.randrange(5) for _ in a]
    if not sum(w): w[0]=1
    return [F(v,sum(w)) for v in w]

cases=nontrivial=0
for _ in range(700):
    n=rng.randrange(2,7); m=rng.randrange(1,5)
    # Random code of size two or four, not necessarily linear.
    C=rng.sample(list(product(range(2),repeat=n)),rng.choice([2,4]))
    dist=min(sum(a!=b for a,b in zip(x,y)) for x in C for y in C if x!=y)
    t=rng.randrange((dist-1)//2+1)
    alph=[range(rng.choice([2,3])) for _ in range(m)]
    deps=[tuple(sorted(rng.sample(range(m),rng.randrange(m+1)))) for _ in range(n)]
    tabs=[{v:rng.randrange(2) for v in product(*(alph[i] for i in S))} for S in deps]
    def E(z): return tuple(tab[tuple(z[i] for i in S)] for tab,S in zip(tabs,deps))
    # Arbitrary adaptive depth-two decoder represented by first bit and branch-specific second bit.
    qs=[tuple(rng.randrange(n) for _ in range(3)) for _ in alph]
    vals=[[rng.randrange(len(a)) for _ in range(4)] for a in alph]
    def D(x): return tuple(tab[2*x[a]+x[b if x[a]==0 else c]] for (a,b,c),tab in zip(qs,vals))
    K=rng.randrange(1,5); comps=[(F(1,K),[marginal(a) for a in alph]) for _ in range(K)]
    assert all(len({D(x)[i] for x in C})<=4 for i in range(m))
    nontrivial+=check(C,alph,deps,E,D,t,comps);cases+=1
# Structured parity and repetition-block codes, including deliberately distorted encoders.
for n in range(2,8):
    for repeat in (1,3):
        C=[tuple(v for x in z for v in [x]*repeat) for z in product(range(2),repeat=n) if sum(z)%2==0]
        m=n; alph=[range(2)]*m; deps=[(i,) for i in range(n) for j in range(repeat)]
        for t in range(repeat):
            def E(z): return tuple(z[i]^(j<t and i==0) for i in range(n) for j in range(repeat))
            def D(x): return tuple(x[i*repeat] for i in range(n))
            atoms=[(F(1,len(C)),[[F(int(a==v)) for a in range(2)] for v in D(x)]) for x in C]
            for leak in (F(0),F(1,10),F(1,3),F(1,2)):
                comps=[(w*(1-leak),p) for w,p in atoms]+[(leak,[[F(1,2)]*2]*m)]
                nontrivial+=check(C,alph,deps,E,D,t,comps); cases+=1
print(f'PASS {cases} exact model/mixture cases; {nontrivial} nontrivial positive lower-bound cases')
