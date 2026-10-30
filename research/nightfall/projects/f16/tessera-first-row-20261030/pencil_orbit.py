#!/usr/bin/env python3
"""Independent orbit-quotient audit of the restricted second-query pencil.

First row (a0;a1..a8)=(0;2,2,3,3,4,4,5,5).
Second row b0 arbitrary GF16, bi∈ai·GF4 (including zero).
For output class index=1 of first cube query, there are 1,224 states.
The row's coefficient choices have 4^8·16=1,048,576 cases, reducible to
10^4·16=160,000 by swapping each pair of equally weighted coordinates.
For every one the second reading has a fiber of size ≥225>216=6^3.

Different schoolbook polynomial arithmetic and pair-orbit representation
from full-row C++ checker. Requires Python standard library only.
"""
from itertools import combinations_with_replacement,product

H=(1,6,7)
A=(2,2,3,3,4,4,5,5)

def gf16_times(a,b):
    p=0
    for i in range(4):
        for j in range(4):
            if (a>>i)&1 and (b>>j)&1:
                p^=1<<(i+j)
    for i in range(6,3,-1):
        if (p>>i)&1:
            p^=19<<(i-4)
    return p

def cube(x):
    return gf16_times(gf16_times(x,x),x)

image=sorted({cube(x) for x in range(16)})
ind={x:i for i,x in enumerate(image)}
assert image==[0,1,8,10,12,15]
S=[]
for eta in product(H,repeat=8):
    y=0
    for a,h in zip(A,eta):
        y^=gf16_times(a,h)
    if ind[cube(y)]==1:
        S.append(eta)
assert len(S)==1224

opts=[(0,*(gf16_times(a,h) for h in H)) for a in A]
choices=list(combinations_with_replacement(range(4),2))
assert len(choices)==10
pair_values=[]
for j in range(4):
    vals=[]
    for u,v in choices:
        row=bytes(
            gf16_times(opts[2*j][u],x[2*j])^
            gf16_times(opts[2*j+1][v],x[2*j+1])
            for x in S
        )
        vals.append(row)
    pair_values.append(vals)

decode=[[ind[cube(x^anchor)] for x in range(16)] for anchor in range(16)]

def run():
    best=100000
    qualifying=0
    best_witness=None
    for a,b,c,d in product(range(10),repeat=4):
        rows=(pair_values[0][a],pair_values[1][b],
              pair_values[2][c],pair_values[3][d])
        counts=[0]*16
        for i in range(len(S)):
            counts[rows[0][i]^rows[1][i]^rows[2][i]^rows[3][i]]+=1
        for anchor in range(16):
            output=[0]*6
            for raw,n in enumerate(counts):
                output[decode[anchor][raw]]+=n
            worst=max(output)
            if worst<=216:
                qualifying+=1
            if worst<best:
                best=worst
                best_witness=(a,b,c,d,anchor,tuple(output))
    assert (best,qualifying)==(225,0),(best,qualifying,best_witness)
    assert best_witness==(5,5,5,5,0,(108,216,225,225,225,225))
    print("PASS 160000 symmetry-quotiented second rows")
    print("PASS 1224-state first-output fiber; worst second fiber ≥225 >216")
    print("PASS optimal witness",best_witness)

if __name__=="__main__":
    run()
