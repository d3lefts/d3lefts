#!/usr/bin/env python3
"""RYEV: independent F4 quadratic-tower audit of adaptive F16 phase block.

Finite evidence only. All query decisions use measured cubed outputs.
No import of Tessera's arithmetic or decoder. No external referee claim.
"""
from collections import Counter, defaultdict
from itertools import combinations, product
from random import Random
import json

# GF4 = GF2[w]/(w^2+w+1); write a+b*u with u^2=u+w.
def f4(a, b):
    x = ((a & 1) * b) ^ ((a >> 1) * (b << 1))
    if x & 4: x ^= 7
    return x

def times(x, y):
    a,b = x & 3, x >> 2
    c,d = y & 3, y >> 2
    bd = f4(b,d)
    return (f4(a,c) ^ f4(2,bd)) | ((f4(a,d) ^ f4(b,c) ^ bd) << 2)

def power(a,n):
    z=1
    while n:
        if n&1: z=times(z,a)
        a=times(a,a);n>>=1
    return z

M = [[times(a,b) for b in range(16)] for a in range(16)]
C = [power(a,3) for a in range(16)]
INV = {a:next(b for b in range(1,16) if M[a][b]==1) for a in range(1,16)}
ROOT = {c:min(a for a in range(16) if C[a]==c) for c in set(C)}
ROOTS = [a for a in range(16) if power(a,4)^a^1 == 0]
assert len(ROOTS)==4
alpha=ROOTS[0]

def iso(a):
    return __import__('functools').reduce(lambda v,i:v^(power(alpha,i) if a&(1<<i) else 0),range(4),0)
I=tuple(map(iso,range(16)))
assert len(set(I))==16
def polynomial_product(a,b):
    t=0
    for j in range(4):
        if b & (1<<j): t^=a<<j
    for j in (6,5,4):
        if t&(1<<j): t^=0b10011<<(j-4)
    return t
assert all(I[a^b]==I[a]^I[b] and I[polynomial_product(a,b)]==M[I[a]][I[b]]
           for a in range(16) for b in range(16))
assert power(alpha,4)^alpha^1==0
H=(1,2,3)
assert {I[1],I[6],I[7]}==set(H)
assert {a for a in range(1,16) if C[a]==1}==set(H)
assert len(set(C))==6 and {sum(C[a]==c for a in range(16)) for c in set(C)}=={1,3}

# Frozen candidate coefficients expressed in polynomial coordinates; translated via I.
FIRST=tuple(I[v] for v in (1,2,3,4))
BRANCH={I[y]:tuple(I[v] for v in row) for y,row in {
    0:(0,0,0,1), 1:(1,0,2,8), 8:(0,1,4,8),
    10:(0,1,2,4), 12:(0,1,8,4), 15:(0,1,2,4)
}.items()}
assert len(BRANCH)==6 and set(BRANCH)==set(C)

def cubequery(coeff, values):
    total=0
    for a,x in zip(coeff,values): total^=M[a][x]
    return C[total]

def phase_table():
    transcript={}; fibers=defaultdict(list); precubes=defaultdict(list)
    for eta in product(H,repeat=3):
        state=(1,)+eta
        raw=0
        for a,x in zip(FIRST,state):raw^=M[a][x]
        y1=C[raw]
        assert y1 in BRANCH
        y2=cubequery(BRANCH[y1],state)
        assert (y1,y2) not in transcript, (eta, transcript.get((y1,y2)))
        transcript[y1,y2]=eta
        fibers[y1].append(eta)
        precubes[y1].append(raw)
    assert len(transcript)==27
    assert sorted(map(len,fibers.values()))==[1,5,5,5,5,6]
    assert 0 in fibers and len(fibers[0])==1
    return transcript,fibers,precubes

TABLE,FIBERS,PRECUBES=phase_table()
# An unpowered branch is illegal: equivalent raw sums share the same cube.
illegal_raw_branch = next((raw,M[2][raw]) for raw_list in PRECUBES.values() for raw in raw_list
                          if raw and M[2][raw]!=raw and C[M[2][raw]]==C[raw])
assert illegal_raw_branch[0]!=illegal_raw_branch[1]
assert C[illegal_raw_branch[0]]==C[illegal_raw_branch[1]]

# Independent decoder: normalize each coordinate by its chosen cube root.
# Only measured cubes are supplied to choose any query row.
SINGLE={cubequery((1,I[2]),(1,e)):e for e in H}
assert len(SINGLE)==3

def decode(x, skip_zero_branch=False, swapped_branches=False, wrong_exponent=False):
    k=len(x)
    coordinate=[C[v] for v in x]
    active=[j for j,v in enumerate(coordinate) if v]
    if not active:return (0,)*k,k
    base=[ROOT[v] for v in coordinate]
    j0=active[0]
    ratios={j0:1}
    extra=0
    for start in range(1,len(active),3):
        group=active[start:start+3]
        if len(group)==3:
            js=[j0]+group
            def reading(row):
                nonlocal extra
                extra+=1
                y=0
                for a,j in zip(row,js):
                    coeff=M[a][INV[base[j]]]
                    y^=M[coeff][x[j]]
                return power(y,5) if wrong_exponent else C[y]
            y1=reading(FIRST)
            if skip_zero_branch and y1==0: raise ValueError('missing zero-output branch')
            if y1 not in BRANCH: raise ValueError('unrecognized first cubic observation')
            row=BRANCH[y1]
            if swapped_branches and y1==I[10]:row=BRANCH[I[1]]
            y2=reading(row)
            if (y1,y2) not in TABLE:raise ValueError('unrecognized adaptive transcript')
            ratios.update(zip(group,TABLE[y1,y2]))
        else:
            for j in group:
                coeff0=INV[base[j0]]
                coeff1=M[I[2]][INV[base[j]]]
                y=C[M[coeff0][x[j0]]^M[coeff1][x[j]]]
                ratios[j]=SINGLE[y]
                extra+=1
    candidate=tuple(M[ratios[j]][base[j]] if j in ratios else 0 for j in range(k))
    assert any(all(a==M[h][b] for a,b in zip(x,candidate)) for h in H),(x,candidate)
    assert extra==2*((len(active)-1)//3)+(len(active)-1)%3
    return candidate,k+extra

def run():
    # Named negative fixtures must demonstrably fail.
    for label,kw in [('missing_zero',{'skip_zero_branch':True}),
                     ('swapped_branch',{'swapped_branches':True}),
                     ('wrong_power',{'wrong_exponent':True})]:
        failures=0
        for eta in product(H,repeat=3):
            try:decode((1,)+eta,**kw)
            except (ValueError,AssertionError):failures+=1
        assert failures>0,(label,failures)
    assert power(2,5)!=power(1,5) and power(2,3)==power(1,3)
    assert 3**4>6**2
    count=Counter()
    for x in product(range(16),repeat=4):
        _,q=decode(x)
        count[q]+=1
    assert count=={4:61,5:1350,6:64125}, count
    sectors=0
    for s in range(1,8):
        for positions in combinations(range(7),s):
            for eta in product(H,repeat=s-1):
                x=[0]*7
                for j,v in zip(positions,(1,)+eta):x[j]=v
                assert decode(x)[1]<=11
                sectors+=1
    assert sectors==5461
    assert decode((0,)*7)[1]==7
    rng=Random(25030)
    for _ in range(12000):
        assert decode(tuple(rng.randrange(16) for j in range(7)))[1]<=11
    assert 6**5<(16**4-1)//3+1<=6**6
    assert 6**10<(16**7-1)//3+1<=6**11
    print(json.dumps({'status':'PASS_INTERNAL_EXACT','oracle':'full_H_cube_only',
        'branch_outputs':sorted(FIBERS),'branch_fiber_sizes':sorted(map(len,FIBERS.values())),
        'k4_vectors':16**4,'k4_counts':dict(count),'k7_support_phase_sectors':sectors,
        'k7_random_amplitude_vectors':12000,'illegal_raw_branch_witness':illegal_raw_branch,
        'negative_controls':['missing_zero','swapped_branch','wrong_power','hidden_unpowered_branch'],
        'k4_worst':6,'k7_worst':11,'lean_universal_compiled':False,
        'external_review':False,'novelty_cleared':False},sort_keys=True))

if __name__=='__main__':run()
