#!/usr/bin/env python3
"""Independent exact finite audit: PFR-cover + dense-coset Bogolyubov -> row frame.

Only tests finite cases. Does not verify PFR or universal Fourier lemma.
Use: python3 -I check_small_doubling_frame.py
"""
import itertools
import random
from collections import Counter

checks = Counter()

def tick(name, cond):
    checks[name] += 1
    if not cond:
        raise AssertionError((name, checks[name]))

def span(gens):
    S = {0}
    for g in gens:
        S |= {x ^ g for x in tuple(S)}
    return S

def rank(xs):
    pivots = {}
    for x in xs:
        while x:
            b = x.bit_length() - 1
            if b in pivots:
                x ^= pivots[b]
            else:
                pivots[b] = x
                break
    return len(pivots)

def coord_map(gens):
    d = {0: 0}
    for i,g in enumerate(gens):
        old = tuple(d.items())
        for h,c in old:
            tick('basis_injectivity',h ^ g not in d)
            d[h ^ g] = c | (1<<i)
    return d

def sum4(A):
    AA = {a^b for a in A for b in A}
    return {x^y for x in AA for y in AA}

def bogolyubov_intrinsic(A, h):
    # A nonempty subset of binary vector space (h coordinates).
    n = 1 << h
    count = len(A)
    assert count and A <= set(range(n))
    heavy = []
    for freq in range(n):
        coeff = sum(1 if (freq & a).bit_count()%2 == 0 else -1 for a in A)
        # (coeff/n)^2 >= (count/n)^3 / 2
        if 2 * n * coeff * coeff >= count**3:
            heavy.append(freq)
    V = {x for x in range(n) if all((x&freq).bit_count()%2==0 for freq in heavy)}
    tick('zero_in_V',0 in V)
    tick('subspace_cardinality',len(V)==1<<rank(V))
    tick('fourfold_containment',V<=sum4(A))
    codim = h - rank(V)
    tick('elementary_bogolyubov_codimension', codim * count**2 <= 2 * n**2)
    tick('heavy_frequency_dimension',rank(heavy)<=len(heavy))
    tick('heavy_bound',len(heavy)*count**2 <= 2*n**2)
    return V, codim

def all_subspaces(m):
    # Exact enumeration only for m<=4; 4R may contain a larger V than found.
    universe = set(range(1<<m))
    result = {frozenset({0})}
    for x in range(1,1<<m):
        result |= {frozenset(V | {v^x for v in V})
                   for V in tuple(result) if x not in V}
    assert all(set(V)<=universe for V in result)
    return tuple(result)

def inspect(R, m, Hgens, all_V=None):
    R=set(R)
    H=span(Hgens)
    if not R or len(H)>len(R):
        return
    coord=coord_map(Hgens)
    tick('H_basis',len(H)==2**len(Hgens))
    # All occupied H cosets; number L is actual minimal coset count for this H.
    cover = {}
    for r in R:
        key=min(r^h for h in H)
        cover.setdefault(key,set()).add(r)
    L=len(cover)
    tick('cover_bound',len(R)<=L*len(H))
    key=max(cover,key=lambda z:len(cover[z]))
    A={coord[r^key] for r in cover[key]}
    tick('coset_density',len(A)*L>=len(H))
    V_intr,codim=bogolyubov_intrinsic(A,len(Hgens))
    V={next(h for h,c in coord.items() if c==x) for x in V_intr}
    V_four=sum4(R)
    tick('V_in_four_R',V<=V_four)
    rkR=rank(R)
    rkV=rank(V)
    tick('rank_gap_cover', rkR<=rkV+L+codim)
    tick('rank_gap_uniform', (rkR-rkV)*len(A)**2 <= (L*len(A)**2 + 2*len(H)**2))
    tick('rank_gap_L',rkR<=rkV+L+2*L**2)
    # B subset of R is always a valid fully independent frame: c=rank, c'=1.
    B=[]
    for r in sorted(R):
        if rank(B+[r])>len(B):
            B.append(r)
    tick('frame_basis_rank',len(B)==rkR)
    for r in R:
        tick('all_rows_in_frame_span',r in span(B))
    tick('full_hwise_independence',len(span(B))==2**len(B))
    if all_V is not None:
        n4=max(rank(Vv) for Vv in all_V if Vv<=V_four)
        tick('N4_bound',rkR<=n4+L+2*L**2)
        tick('obtained_V_below_N4',rkV<=n4)
    return L, rkR, rkV

def run():
    rng=random.Random(20261119)
    examples=0
    # Exhaustive all nonempty sets in F2^3 and all eligible subspaces H.
    for m in [2,3]:
        subs=all_subspaces(m)
        gens_map={}
        for H in subs:
            gen=[]
            for x in sorted(H):
                if x not in span(gen): gen.append(x)
            gens_map[H]=gen
        for mask in range(1,1<<(1<<m)):
            R={x for x in range(1<<m) if (mask>>x)&1}
            for H,gen in gens_map.items():
                if len(H)<=len(R):
                    inspect(R,m,gen,subs)
                    examples+=1
    # Random structured covers in dimensions 4..7 with zero and skewed cosets.
    for m in range(4,8):
        sv=all_subspaces(m) if m==4 else None
        for j in range(220):
            h=rng.randrange(0,min(5,m)+1)
            Hbasis=[]
            for x in rng.sample(list(range(1,1<<m)),(1<<m)-1):
                if len(Hbasis)>=h:break
                if x not in span(Hbasis): Hbasis.append(x)
            H=span(Hbasis)
            out=[r for r in range(1<<m) if r not in H]
            reps=[0]
            while len(reps)<min(1+rng.randrange(3),1<<max(0,m-h)):
                c=rng.choice(out)
                if all(c^r not in H for r in reps):reps.append(c)
            R=set()
            for rep in reps:
                for a in H:
                    if rng.random() < (0.25+0.65*rng.random()):R.add(rep^a)
            if len(R)<len(H):
                R|={reps[0]^a for a in H}
            inspect(R,m,Hbasis,sv)
            examples+=1
    print('PASS',examples,'finite R,H cases with exact integer Fourier/Bogolyubov/frame checks')
    print('COUNTS',dict(sorted(checks.items())))

if __name__=='__main__':run()
