#!/usr/bin/env python3
"""Independent exact regression supporting all-L triangular-torus pair-fiber lemma.

All-L proof is algebraic: for L>=5, [-2,2]^2 embeds in (Z/LZ)^2;
all integer nonzero neighbor differences have at most two ordered lifts.
L=4 is a finite exception checked exhaustively. This program is not a
Lean certificate nor a mathematical priority verdict.
"""
from collections import Counter
from itertools import product

S = ((1,0),(-1,0),(0,1),(0,-1),(1,1),(-1,-1))

def modsub(p,q,L): return ((p[0]-q[0])%L, (p[1]-q[1])%L)

def check_integer_offsets():
    d=Counter((u[0]-v[0],u[1]-v[1]) for u,v in product(S,repeat=2))
    assert d[(0,0)]==6 and max(v for k,v in d.items() if k!=(0,0))==2
    assert all(-2<=x<=2 and -2<=y<=2 for x,y in d)
    print('PASS integer offset lemma: 18 nonzero differences, each with <=2 ordered lifts')

def check_torus(L):
    neighborhood={modsub(u,(0,0),L) for u in S}
    assert len(neighborhood)==6
    multiplicities=Counter(modsub(u,v,L) for u,v in product(S,repeat=2))
    assert multiplicities[(0,0)]==6
    assert max(v for k,v in multiplicities.items() if k!=(0,0))<=2
    # Weight-2 target uv: zero+edge pairs and two-edge u-w-v paths
    vertex_pairs={d:2*multiplicities.get(d,0)+2*int(d in neighborhood)
                  for d in product(range(L),repeat=2) if d!=(0,0)}
    assert max(vertex_pairs.values()) == 6
    if L == 4:
        assert len(multiplicities)==16
        assert all(v==2 for k,v in multiplicities.items() if k!=(0,0))
    return max(vertex_pairs.values())

if __name__ == '__main__':
    check_integer_offsets()
    for L in (4,5,6,7,8,9,10,16,32,64):
        print(f'PASS L={L}: max ordered weight-2 pair fiber={check_torus(L)}')
    print('Weight-4 target <=6 by 3 perfect matchings; hence all-L M2=6.')
