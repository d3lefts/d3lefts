#!/usr/bin/env python3
"""Exact certificate: generically, ordered triple heat-bath residuals on 4 dependent binary sites annihilate only constants.

No external packages. Certification is via a polynomial identity checked at 73
integer nodes, using a separate rational-probability formulation for spot audits.
The file is a reproducible author-side checker, not a Lean theorem or a novelty claim.
"""
from fractions import Fraction

N = 4
EDGES = ((0, 1), (1, 2), (2, 3))
ROWS = (
    *((0, 1, 2, a) for a in (0, 2, 4, 6, 8, 10, 12, 14)),
    (0, 1, 3, 0), (0, 1, 3, 2),
    (0, 2, 1, 0), (0, 2, 3, 0),
    (1, 2, 3, 0), (2, 1, 0, 0), (3, 2, 1, 0),
)
assert len(ROWS) == 15
assert sum(sum(i in (1, 2) for i in (a,b,c)) for a,b,c,_ in ROWS) == 27

def spin(state, i):
    return 1 if state & (1 << i) else -1

def c(i, state, r):
    s = spin(state, i)
    if i == 0:
        return 1 - r * s * spin(state, 1)
    if i == 3:
        return 1 - r * s * spin(state, 2)
    return 1 + r*r - r*s*(spin(state, i-1)+spin(state,i+1))

def make_row(triple, state, r):
    """Row of A_i A_j A_k, with A_end=2R_end, A_inner=2(1+r^2)R_inner."""
    row = {state: 1}
    for i in triple:
        nxt = {}
        for s, v in row.items():
            w = v * c(i,s,r)
            nxt[s] = nxt.get(s,0)+w
            t=s^(1<<i)
            nxt[t] = nxt.get(t,0)-w
        row = {s:v for s,v in nxt.items() if v}
    assert sum(row.values()) == 0
    return [row.get(s,0) for s in range(1,16)]

def determinant_bareiss(matrix):
    """Fraction-free exact determinant with row swaps."""
    a=[list(row) for row in matrix]
    n=len(a); sign=1; prev=1
    for k in range(n-1):
        if not a[k][k]:
            match=next((j for j in range(k+1,n) if a[j][k]),None)
            if match is None:return 0
            a[k],a[match]=a[match],a[k];sign=-sign
        p=a[k][k]
        for i in range(k+1,n):
            for j in range(k+1,n):
                val=a[i][j]*p - a[i][k]*a[k][j]
                assert val%prev==0, (k,i,j,prev,val)
                a[i][j]=val//prev
            a[i][k]=0
        prev=p
    return sign*a[-1][-1]

def determinant_closed(r):
    return -(2**26)*(r**17)*((1+r*r)**9)*((r-1)**18)*((r+1)**5)

def exact_polynomial_certificate():
    # Each selected row has degree <=3 + number of interior residuals;
    # determinant degree <=45+27=72. 73 distinct evaluations certify identity.
    for r in range(-36,37):
        got=determinant_bareiss([make_row(t[:3],t[3],r) for t in ROWS])
        want=determinant_closed(r)
        assert got==want,(r,got,want)
    print('PASS: exact integer polynomial identity at 73 distinct nodes; degree bound <=72')
    print('det H(r) = -2^26*r^17*(1+r^2)^9*(r-1)^18*(r+1)^5')

def weight(state, r):
    p=Fraction(1,16)
    for i,j in EDGES:
        p*=1+r*spin(state,i)*spin(state,j)
    return p

def direct_Q_residual_row(i, state, r):
    """Independently derive conditional residuals from the joint 16-atom law."""
    flip=state^(1<<i)
    p=weight(state,r); q=weight(flip,r)
    assert p>0 and q>0
    factor=q/(p+q)
    return {state:factor, flip:-factor}

def direct_product_row(triple, state, r):
    row={state:Fraction(1)}
    for i in triple:
        nxt={}
        for s, v in row.items():
            for t, coef in direct_Q_residual_row(i,s,r).items():
                nxt[t]=nxt.get(t,Fraction(0))+v*coef
        row={s:v for s,v in nxt.items() if v}
    return [row.get(s,Fraction(0)) for s in range(1,16)]

def direct_audit():
    from math import lcm
    for r in [Fraction(1,2),Fraction(1,3),Fraction(-1,2),Fraction(1,100)]:
        assert sum(weight(s,r) for s in range(16))==1
        for i in range(4):
            for state in range(16):
                p=direct_Q_residual_row(i,state,r)[state]
                assert p==Fraction(c(i,state,r),2*(1+r*r if i in (1,2) else 1))
        M=[direct_product_row((i,j,k),a,r) for i,j,k,a in ROWS]
        den=1
        for row in M:
            for q in row:den=lcm(den,q.denominator)
        direct_det=Fraction(determinant_bareiss([[int(q*den) for q in row] for row in M]),den**15)
        expected=Fraction(-r**17*(1-r)**18*(1+r)**5,2**19*(1+r*r)**18)
        assert direct_det==expected,(r,direct_det,expected)
        assert direct_det!=0
        print('PASS independent joint-law determinant r=',r,'det=',direct_det)
    assert determinant_closed(0)==0

if __name__=='__main__':
    exact_polynomial_certificate()
    direct_audit()
    print('RESULT: for all -1<r<1 except r=0, D2 space = constants (4 spins).')
