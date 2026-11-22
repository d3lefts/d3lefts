#!/usr/bin/env python3
"""Exact rational 5x5 finite-template affine-orbit probe certificate for k=5.

The 5 colors on F_2^4 are explicit below. All 16^(d+1) affine maps
F_2^d -> F_2^4 are enumerated, d=3,4. Matrix rank is exact over Q.
This does NOT independently prove the all-k affine-orbit interpolation lemma.
"""
from itertools import combinations
import numpy as np
from sympy import Matrix, Rational

COLORS = [
 [4,4,3,1,3,3,0,0,2,1,1,2,4,4,2,3],
 [1,1,2,4,1,0,4,4,0,4,1,3,2],
 [3,0,4,0,3,2,4,0,4,1,1,3,1,1,0,3],
 [1,3,0,3,1,3,4,3,4,3,0,2,4,4,0,2],
 [4,3,4,2,3,3,4,1,0,1,0,4,2,3,2,4],
]
# The second row below is the complete 16-coordinate coloring, replacing
# the shortened row above.  Guard the literal input before any enumeration.
COLORS[1]=[1,1,2,4,1,0,4,4,0,4,1,2,3,1,3,2]

def configurations(rank):
    # Source rank-3 representative: {0,e1,e2,e1+e2,e3}, a unique 4-circuit.
    # Source rank-4 representative: {0,e1,e2,e3,e4}, affinely independent.
    gr = np.indices([16]*(rank+1),dtype=np.uint8).reshape(rank+1,-1).T
    z,u=gr[:,0],gr[:,1:]
    if rank==3:
        return np.column_stack([z,z^u[:,0],z^u[:,1],z^u[:,0]^u[:,1],z^u[:,2]])
    return np.column_stack([z,z^u[:,0],z^u[:,1],z^u[:,2],z^u[:,3]])

def rows_for_coloring(color, C3, C4):
    color=np.array(color,dtype=np.uint8)
    def orbit_features(C, rank):
        v=color[C]; M=len(v)
        all5=int((v==v[:,0:1]).all(axis=1).sum())
        pair4=pair5=pairall=0
        for i,j in combinations(range(5),2):
            rem=[k for k in range(5) if k not in (i,j)]
            equal=(v[:,i]==v[:,j]) & (v[:,rem[0]]==v[:,rem[1]]) & (v[:,rem[1]]==v[:,rem[2]])
            hits=int(equal.sum())
            pairall+=hits
            if rank==3:
                if 4 in (i,j): pair5+=hits
                else: pair4+=hits
        if rank==3:
            return [Rational(all5,M),Rational(pair4,6*M),Rational(pair5,4*M)]
        return [Rational(all5,M),Rational(pairall,10*M)]
    return orbit_features(C3,3)+orbit_features(C4,4)

if __name__ == '__main__':
    C3,C4=configurations(3),configurations(4)
    assert C3.shape==(65536,5) and C4.shape==(1048576,5)
    M=Matrix([rows_for_coloring(y,C3,C4) for y in COLORS])
    determinant=M.det(method='domain-ge')
    assert determinant==Rational(86986431,9444732965739290427392), determinant
    assert determinant !=0
    print('PASS: 5x5 finite affine probe matrix has exact rank 5')
    print('det=', determinant)
