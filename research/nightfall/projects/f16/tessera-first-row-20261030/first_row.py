#!/usr/bin/env python3
"""Exact first-query capacity census for the F16/F4 full-subfield CUBE oracle.

All 16^9 possible anchored first rows reduce (for F4* phase-fiber sizes)
to 20,592 pairs (coefficient-direction occupancy, anchor coefficient).
No solver, NumPy, randomness, or external libraries. See THEOREM.md.
"""
from collections import Counter
from itertools import product
from hashlib import sha256

H=(1,6,7)

def multiply(a,b):
    z=0
    for i in range(4):
        if (b>>i)&1: z^=a
        a<<=1
        if a&16: a^=19
    return z&15

def cube(x):
    return multiply(multiply(x,x),x)

def compositions(n,k):
    if k==1:
        yield (n,)
    else:
        for a in range(n+1):
            for tail in compositions(n-a,k-1):
                yield (a,)+tail

def projective_directions():
    unseen=set(range(1,16))
    directions=[]
    while unseen:
        a=min(unseen)
        line=tuple(sorted(multiply(a,h) for h in H))
        assert len(set(line))==3
        directions.append(line)
        unseen-=set(line)
    assert len(directions)==5
    return tuple(directions)

DIRECTIONS=projective_directions()
CUBES=tuple(sorted(set(cube(x) for x in range(16))))
INDEX={v:j for j,v in enumerate(CUBES)}
assert len(CUBES)==6 and Counter(cube(x) for x in range(16))=={0:1,1:3,8:3,10:3,12:3,15:3}
assert {multiply(x,y) for x in H for y in H}==set(H)

def first_row_distribution(occupancy):
    """occupancy = (#zero coefficients, #in each of five F4 lines)."""
    d=[0]*16
    d[0]=3**occupancy[0]
    for line, multiplicity in zip(DIRECTIONS,occupancy[1:]):
        for _ in range(multiplicity):
            nxt=[0]*16
            for x,v in enumerate(d):
                if not v:continue
                for y in line:
                    nxt[x^y]+=v
            d=nxt
    assert sum(d)==3**8
    return d

def bucket_sizes(d,anchor):
    sizes=[0]*6
    for x,v in enumerate(d):
        sizes[INDEX[cube(x^anchor)]]+=v
    return tuple(sizes)

def direct_bucket(row):
    out=Counter()
    for phases in product(H,repeat=8):
        y=row[0]
        for a,eta in zip(row[1:],phases):
            y^=multiply(a,eta)
        out[cube(y)]+=1
    return tuple(out[v] for v in CUBES)

def occupancy_for(row):
    counts=[0]*6
    for a in row[1:]:
        if a==0:
            counts[0]+=1
        else:
            counts[1+next(i for i,line in enumerate(DIRECTIONS) if a in line)]+=1
    return tuple(counts)

def run():
    histogram=Counter()
    minimizers=[]
    minimum=3**8
    viable=0
    enumerated=0
    for occupancy in compositions(8,6):
        distribution=first_row_distribution(occupancy)
        for anchor in range(16):
            sizes=bucket_sizes(distribution,anchor)
            largest=max(sizes)
            histogram[largest]+=1
            enumerated+=1
            if largest<=6**4:
                viable+=1
            if largest<minimum:
                minimum=largest
                minimizers=[(occupancy,anchor,sizes)]
            elif largest==minimum:
                minimizers.append((occupancy,anchor,sizes))
    assert enumerated==20592
    assert minimum==1215 and len(minimizers)==16
    assert viable==15591 and enumerated-viable==5001
    assert ((3,1,1,1,1,1),0,(486,1215,1215,1215,1215,1215)) in minimizers

    # Different oracle is illegal: the raw linear value has 16 output symbols,
    # whereas the cube map has exactly six output symbols. Detect confusion.
    assert len(set(range(16)))==16 and len(CUBES)==6
    assert 6**4==1296 and 3**8==6561
    # Independently enumerate actual anchored phase assignments for 30
    # coefficient rows; verify occupancy compression without using convolution.
    rows=[(0,2,2,3,3,4,4,5,5),(0,0,0,0,1,2,3,4,5)]
    state=1
    for _ in range(28):
        row=[]
        for _ in range(9):
            state=(1103515245*state+12345)&0x7fffffff
            row.append(state%16)
        rows.append(tuple(row))
    for row in rows:
        assert len(row)==9
        distribution=first_row_distribution(occupancy_for(row))
        predicted=bucket_sizes(distribution,row[0])
        literal=direct_bucket(row)
        assert predicted==literal,(row,predicted,literal)
    assert bucket_sizes(first_row_distribution((0,0,2,2,2,2)),0)==(417,1224,1230,1230,1230,1230)

    manifest="|".join(f"{k}:{v}" for k,v in sorted(histogram.items()))
    print("PASS field GF16=F2[z]/(z^4+z+1), full oracle (a.x)^3")
    print("PASS first-row type census",enumerated,
          "minimum worst fiber",minimum,
          "minimizers",len(minimizers))
    print("PASS capacity first-gate feasible",viable,
          "excluded",enumerated-viable)
    print("PASS 30 independent literal 6561-state row checks")
    print("PASS balanced full-incidence example",
          bucket_sizes(first_row_distribution((0,0,2,2,2,2)),0))
    print("HISTOGRAM_SHA256",sha256(manifest.encode()).hexdigest())

if __name__=="__main__": run()
