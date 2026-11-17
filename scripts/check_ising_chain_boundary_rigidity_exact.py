#!/usr/bin/env python3
"""Exact polynomial certificates for all four-spin Ising-chain boundary types.
Combined with finite 4-block conditioning, yields all-length Ising chain rigidity.
Requires only the local stdlib determinant implementation, not SymPy.
"""
from check_dependent_degree_collapse_exact import ROWS, spin, determinant_bareiss

def coef(i, state, r, left, right):
    x = spin(state, i)
    if i == 0:
        if not left:
            return 1 - r*x*spin(state,1)
        return (1-left*r*x)*(1-r*x*spin(state,1))*(1-left*r*r*spin(state,1))
    if i == 3:
        if not right:
            return 1 - r*x*spin(state,2)
        return (1-right*r*x)*(1-r*x*spin(state,2))*(1-right*r*r*spin(state,2))
    return 1 + r*r - r*x*(spin(state,i-1)+spin(state,i+1))

def poly_row(triple, state, r, left, right):
    row = {state:1}
    for i in triple:
        new = {}
        for a, v in row.items():
            c = v*coef(i,a,r,left,right)
            new[a] = new.get(a,0)+c
            b=a^(1<<i)
            new[b]=new.get(b,0)-c
        row={a:v for a,v in new.items() if v}
    assert sum(row.values()) == 0
    return [row.get(a,0) for a in range(1,16)]

def expected_det(r,left,right):
    base=-(2**26)*r**17
    if (left,right)==(0,0):
        return base*(1+r*r)**9*(r-1)**18*(r+1)**5
    if (left,right)==(1,0):
        return base*(1+r*r)**16*(r-1)**24*(r+1)**23
    if (left,right)==(1,1):
        return base*(1+r*r)**19*(r-1)**26*(r+1)**28
    if (left,right)==(1,-1):
        return base*(1+r*r)**16*(r-1)**32*(r+1)**28
    raise AssertionError('unexpected representative')

def certify(left,right):
    # A_i=2 R_i for absent-boundary endpoints, 2(1-r^4) R_i for
    # endpoints with boundary; interiors 2(1+r^2) R_i. All scalars
    # are nonzero on |r|<1. Endpoint entry degrees rise from 1 to 4.
    times0=sum(0 in row[:3] for row in ROWS)
    times3=sum(3 in row[:3] for row in ROWS)
    bound=72+3*(times0 if left else 0)+3*(times3 if right else 0)
    # bound+1 integer evaluations of an integer polynomial of degree <=bound.
    for r in range(-bound//2,(bound+1)//2+1):
        got=determinant_bareiss([poly_row(row[:3],row[3],r,left,right) for row in ROWS])
        want=expected_det(r,left,right)
        assert got==want,(left,right,r,got,want)
    print(f'PASS boundary ({left},{right}) degree<={bound}, {bound+1} polynomial nodes')

if __name__=='__main__':
    for pair in [(0,0),(1,0),(1,1),(1,-1)]:
        certify(*pair)
    print('Consequence: four-site conditional rigidity for every boundary sign, 0<|r|<1.')
    print('The all-n>=4 Ising-chain theorem then follows by four-consecutive-site conditioning.')
