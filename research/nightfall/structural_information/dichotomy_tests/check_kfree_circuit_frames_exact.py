#!/usr/bin/env python3
"""Independent exact checker: K-free circuit-component frames and basis-only barrier.

No randomized tolerance, solver, analytic PFR import, or claimed unconditional
Conjecture E. Checks finite XOR certificates over F2 from a second implementation.
"""
from itertools import combinations
from random import Random
from fractions import Fraction

rng = Random(20261119)
assertions = 0
cases = 0

def ck(test, message):
    global assertions
    if not test:
        raise AssertionError(message)
    assertions += 1

def xr(values):
    out = 0
    for v in values:
        out ^= v
    return out

def rank(values):
    pivots = {}
    for x in values:
        while x:
            b = x.bit_length() - 1
            if b in pivots:
                x ^= pivots[b]
            else:
                pivots[b] = x
                break
    return len(pivots)

def create_instance(lengths, free=0):
    rows, cycles, isolated = [], [], []
    offset = 0
    for L in lengths:
        assert L >= 3
        idx = tuple(range(len(rows), len(rows)+L))
        cycles.append(idx)
        rows.extend((1 << (offset+i)) ^ (1 << (offset+(i+1) % L))
                    for i in range(L))
        offset += L
    for _ in range(free):
        isolated.append(len(rows))
        rows.append(1 << offset)
        offset += 1
    return rows, cycles, isolated

def frame(rows, cycles, isolated, H):
    B, fwd, rev, bblocks = [], [None]*len(rows), [], []
    for idx in cycles:
        L = len(idx)
        new = []
        if L <= H:
            acc = 0
            for j in range(L-1):
                acc ^= rows[idx[j]]
                new.append(len(B))
                B.append(acc)
                rev.append(tuple(idx[:j+1]))
            fwd[idx[0]] = (new[0],)
            for j in range(1,L-1):
                fwd[idx[j]] = (new[j-1], new[j])
            fwd[idx[-1]] = (new[-1],)
        else:
            for i in idx:
                new.append(len(B))
                B.append(rows[i])
                rev.append((i,))
                fwd[i] = (new[-1],)
        bblocks.append((tuple(new), L <= H, L))
    for i in isolated:
        idx = len(B)
        B.append(rows[i])
        rev.append((i,))
        fwd[i] = (idx,)
        bblocks.append(((idx,), True, 1))
    return B, fwd, rev, bblocks

def audit_frame(lengths, H, free=0):
    global cases
    rows, cycles, isolated = create_instance(lengths,free)
    B, fwd, rev, bblocks = frame(rows,cycles,isolated,H)
    budget = max(1,H-1)
    ck(len(fwd)==len(rows) and all(z is not None for z in fwd),"complete forward words")
    for i,word in enumerate(fwd):
        ck(len(word)<=2 and xr(B[j] for j in word)==rows[i],
           ("forward reconstruction",lengths,H,i))
    for j,word in enumerate(rev):
        ck(len(word)<=budget and xr(rows[i] for i in word)==B[j],
           ("reverse reconstruction",lengths,H,j,budget))
    ck(rank(rows)==rank(B),"same subspace")
    expected_rank=sum(L-1 for L in lengths)+free
    ck(rank(rows)==expected_rank,("original direct sum",lengths,free))
    ck(rank(B)==sum((L-1 if not short else L-1) for _,short,L in bblocks if L>1)+free,
       ("frame direct sum rank",lengths,H))
    # Every short-cycle block B is independent; the sole relation in each
    # long-cycle block is the XOR of all L row generators (and L>H).
    for inds,short,L in bblocks:
        block=[B[j] for j in inds]
        if L==1:
            ck(rank(block)==1,"isolated free row")
        elif short:
            ck(len(block)==L-1 and rank(block)==len(block),
               ("short cycle basis",L,H))
        else:
            ck(len(block)==L and rank(block)==L-1 and xr(block)==0,
               ("long cycle unique relation",L,H))
            for j in range(L):
                ck(rank(block[:j]+block[j+1:])==L-1,
                   ("no smaller long-cycle relation",L,j))
            ck(L>H,("girth threshold",L,H))
    cases += 1

for H in (0,1,2,3,4,5,7,9,12,16,24):
    for L in (3,4,5,6,7,9,12,17,23,30):
        audit_frame([L],H,0)
    for trial in range(40):
        lengths = [rng.choice((3,4,5,6,7,9,11,15,21)) for _ in range(rng.randint(1,5))]
        audit_frame(lengths,H,rng.randrange(4))

# Exact K for t disjoint triangle circuits: R has 3t distinct edge rows,
# 2R has zero, the same 3t rows (two edges within one triangle), and all
# 9 binom(t,2) cross-component sums.
for t in (1,2,3,4,7,12,24,40):
    rows,cycles,free = create_instance([3]*t)
    two={a^b for a in rows for b in rows}
    ck(len(two)==1+3*t+9*t*(t-1)//2,("triangle doubling",t))
    K=Fraction(len(two),len(rows))
    ck(K>=Fraction(3*t-1,2),("growing K",t,K))
    B,fwd,rev,_=frame(rows,cycles,free,10)
    ck(max(map(len,fwd))<=2 and max(map(len,rev))<=2 and rank(B)==2*t,
       ("constant frame despite unbounded doubling",t))

# Unique-relation basis-only obstruction for a *single* cycle of length L.
for L in (3,4,5,6,7,9,13,21,35,64):
    rows,_,_=create_instance([L])
    ck(xr(rows)==0 and rank(rows)==L-1,("one circuit",L))
    for omitted in range(L):
        basis=rows[:omitted]+rows[omitted+1:]
        ck(rank(basis)==L-1 and xr(basis)==rows[omitted],
           ("all row bases require L-1 for omitted row",L,omitted))

# Matroid component extraction from a basis and its fundamental supports.
def fundamental_components(rows):
    basis,coords,pivots=[],[],[]
    # Greedy independent basis (vector rank oracle).
    for r in rows:
        if r and rank(basis+[r])>len(basis):
            basis.append(r)
    d=len(basis)
    parent=list(range(d))
    def root(a):
        while a!=parent[a]:
            parent[a]=parent[parent[a]]
            a=parent[a]
        return a
    def unite(a,b):
        a,b=root(a),root(b)
        if a!=b: parent[b]=a
    def support(r):
        if r==0:return ()
        # Independent verifier: exhaustive subset search on small d only.
        for width in range(d+1):
            for subset in combinations(range(d),width):
                if xr(basis[j] for j in subset)==r:return subset
        raise AssertionError("row not in basis span")
    if d>15:
        return None
    row_support=[support(r) for r in rows]
    for ss in row_support:
        for i in ss[1:]:
            unite(ss[0],i)
    parts={}
    for i in range(d):
        parts.setdefault(root(i),[]).append(i)
    components=list(parts.values())
    for ss in row_support:
        ck(not ss or len({root(i) for i in ss})==1,"one component per row")
    ck(sum(len(z) for z in components)==d,"full independent decomposition")
    return len(components),sum(1 for ss in row_support if len(ss)>1)

for lengths in ([3,3],[4,7],[5],[3,3,3],[4,4,5]):
    rows,_,_=create_instance(lengths)
    result=fundamental_components(rows)
    if result is not None:
        ck(result[0]==len(lengths),("matroid block extraction",lengths,result))

# Grid graph rows, the unsolved overlap case. Its rows all have Hamming
# weight 2, so N_r<=2r by the systematic-pivot argument (paper proof).
for side in (3,4):
    n=side*side
    grid_rows=[]
    for y in range(side):
        for x in range(side):
            i=y*side+x
            if x+1<side:grid_rows.append((1<<i)^(1<<(i+1)))
            if y+1<side:grid_rows.append((1<<i)^(1<<(i+side)))
    ck(all(row.bit_count()==2 for row in grid_rows),"graphic support bound")
    ck(rank(grid_rows)==n-1,"connected grid rank")
    if side==3:
        cc=fundamental_components(grid_rows)
        ck(cc[0]==1 and cc[1]>=2,("interacting circuits remain one core",cc))
print(f'PASS exact XOR certificate: {assertions} assertions across {cases} circuit-frame instances.')
print('Includes unbounded global K, basis-only obstruction, and fundamental-circuit block extraction.')
print('LIMIT: no general connected high-doubling Conjecture E or Lean certification.')
