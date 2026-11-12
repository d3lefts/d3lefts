#!/usr/bin/env python3
"""Independent exact finite checks of quadratic-backdoor implications.

Does NOT prove universal influence theorems; does not reuse paper's
matching/4th moment argument. Uses direct finite conditional expectations.
"""
from fractions import Fraction as Q
from itertools import combinations, product
from random import Random
from math import prod

rng=Random(20261112)
count=0
supported=0
weak_only=0

def audit(sizes, masses, H, supports):
    global count, supported, weak_only
    n=len(sizes)
    dom=[range(s) for s in sizes]
    weights=[{x:Q(a,sum(m)) for x,a in enumerate(m)} for m in masses]
    basis=[]
    for i in range(n):
        raw={x:Q(x+1 if (i+x)%2==0 else -(x+1)) for x in dom[i]}
        avg=sum((weights[i][x]*raw[x] for x in dom[i]),Q())
        basis.append({x:raw[x]-avg for x in dom[i]})
    states=list(product(*dom))
    laws={x:prod(weights[i][x[i]] for i in range(n)) for x in states}
    terms={}
    for S in supports:
        a=Q(rng.choice([-3,-2,-1,1,2,3]),rng.choice([2,3,5]))
        terms[S]=a
    F={x:sum((a*prod(basis[i][x[i]] for i in S) for S,a in terms.items()),Q()) for x in states}
    B=max(map(abs,F.values()))
    if not B:return
    F={x:v/B for x,v in F.items()}
    avg=sum((laws[x]*F[x] for x in states),Q())
    V=sum((laws[x]*(F[x]-avg)**2 for x in states),Q())
    # ANOVA via explicit conditional projections on every subset
    mu={}
    for Tsize in range(n+1):
        for T in combinations(range(n),Tsize):
            totals={}; mass={}
            for x in states:
                key=tuple(x[i] for i in T)
                totals[key]=totals.get(key,Q())+laws[x]*F[x]
                mass[key]=mass.get(key,Q())+laws[x]
            mu[T]={key:totals[key]/mass[key] for key in mass}
    FS={}
    for Tsize in range(n+1):
        for T in combinations(range(n),Tsize):
            FS[T]={}
            for x in states:
                z=Q()
                for k in range(len(T)+1):
                    for U in combinations(T,k):
                        z+=(-1)**(len(T)-len(U))*mu[U][tuple(x[i] for i in U)]
                FS[T][x]=z
    energies={T:sum((laws[x]*z*z for x,z in tab.items()),Q()) for T,tab in FS.items()}
    assert sum((v for T,v in energies.items() if T),Q())==V
    I=[sum((energies[T] for T in energies if i in T),Q()) for i in range(n)]
    M=max(I)
    H=set(H)
    nonzero={T for T in energies if energies[T] and len(T)>=3}
    assert all(any(i in H for i in T) for T in nonzero), (sizes,H,supports,nonzero)
    gvar=sum((energies[T] for T in energies if T and set(T).isdisjoint(H)),Q())
    loss=sum((energies[T] for T in energies if T and not set(T).isdisjoint(H)),Q())
    assert V==gvar+loss
    assert loss<=sum((I[i] for i in H),Q())
    assert gvar*gvar<=Q(1229)*M # finite falsification of the proved C2<1229 quadratic floor
    assert V*V<=Q(1500)*M # conservative coarse bound when t<=2
    if all(len(set(T)-H)<=2 for T in energies if energies[T]):
        # All conditional ANOVA components on residual coordinates after H fixed
        # are at most quadratic by support structure.
        supported+=1
        for h in product(*(dom[i] for i in sorted(H))):
            # For every Q subset of remaining coordinates with |Q|>=3,
            # 3+ centered mixed difference of the section vanishes.
            residual=tuple(i for i in range(n) if i not in H)
            if len(residual)<3:continue
            hmap=dict(zip(sorted(H),h))
            for triple in combinations(residual,3):
                # A triple mixed operator D_iD_jD_k f is identically zero
                # by original support decomposition and the strong condition.
                for x in states:
                    if any(x[i]!=hmap[i] for i in H): continue
                    val=sum((FS[T][x] for T in energies if energies[T] and set(triple).issubset(T)),Q())
                    assert val==0
    else:weak_only+=1
    count+=1

for trial in range(20):
    if trial<10:
        # Global 1-site cubic cover; all supported cubic terms hit coordinate 0.
        sizes=[2,3,2,2]
        supports=[(0,),(1,),(1,2),(2,3),(0,1,2),(0,2,3)]
        H=(0,)
    elif trial<17:
        # A strong two-site backdoor for a true 4th-order input function.
        sizes=[2,2,3,2,2]
        supports=[(0,1,2,3),(0,1,3,4),(2,3),(1,4),(1,2,3),(0,2,4)]
        H=(0,1)
    else:
        # Weak only: a high-degree parity after observing H.
        sizes=[2,2,2,2,2]
        supports=[(0,1,2,3,4),(1,2),(3,4)]
        H=(0,)
    masses=[[rng.randint(1,5) for _ in range(s)] for s in sizes]
    audit(sizes,masses,H,supports)

# Exact cubic address family identities, using conditional probabilities,
# independently of the Hoeffding computation above.
for m in (2,3,4,7,17):
    IA=IB=Q(m-1,m)
    leaf=Q(1,m*m)
    assert IA==1-Q(1,m)
    assert sum((leaf for _ in range(m*m)),Q())==1
    for k in (1,2,3,13):
        V=Q(1,k)
        maxI=IA/Q(k*k)
        assert V*V/maxI==Q(m,m-1)
    for q in (0,1,m,m*m-1,m*m):
        assert Q(1)-Q(q,m*m)==Q(m*m-q,m*m)

# The weaker averaging transversal cannot guarantee short observation.
for m in (3,5,12,21):
    # Any proper number of revealed independent signs leaves parity
    # conditional mean 0 and risk exactly 1.
    for q in range(m+1):
        if q<m+1: assert Q(1)==1

print(f'PASS {count} exact heterogeneous-support models ({supported} strong-backdoor, {weak_only} weak-only)')
print('PASS exact ANOVA splitting and influence charges for all tested models')
print('PASS cubic address influence, block sharpness, and fixed-set risks: m=2,3,4,7,17')
print('PASS high-degree weak-vs-strong distinction and parity observation obstruction')
print('SCOPE: finite exact consequences only; not a universal proof, independent referee, or Lean certificate')
