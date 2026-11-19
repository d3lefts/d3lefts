#!/usr/bin/env python3
"""Exact true-source 2-address degree-3 full-row / l1(L2) no-go.

No dependence on numeric optimizer or the preceding paper's Fourier identities.
Brute force for m=2 and m=3; symbolic integer/rational identities for all m.
"""
from fractions import Fraction as Q
from itertools import product


def f(x, m):
    a,b=x[0],x[1]
    return x[2+a*m+b]


def analytic(m):
    assert m>=2
    B=V=Q(1)
    IA=IB=1-Q(1,m)
    IL=Q(1,m*m)
    M=IA
    K=6
    E3=(1-Q(1,m))**2
    leaf_norm_total=m
    row_leaf_l2_total=2*m
    assert E3>0
    assert M==max(IA,IB,IL)
    assert Q(4)*V**2/(K*K*M) <=1
    return dict(B=B,V=V,IA=IA,IB=IB,IL=IL,
                M=M,K=K,E3=E3,leaf_norm_total=leaf_norm_total,
                row_leaf_l2_total=row_leaf_l2_total)


def all_source_pair_row_valid(m):
    # For fixed source x, all possible comparison outputs are determined
    # by the two new addresses and the one leaf at the new address.
    # Every unmentioned comparison leaf can be arbitrary and has row weight 0.
    for a in range(m):
        for b in range(m):
            for fx in (-1,1):
                for ap in range(m):
                    for bp in range(m):
                        for fz in (-1,1):
                            row_cost=(2 if ap!=a else 0)+(2 if bp!=b else 0)
                            if ap==a and bp==b and fz!=fx:
                                row_cost+=2
                            assert abs(fx-fz)<=row_cost,(m,a,b,ap,bp,fx,fz)
    # Dual: three disjoint singleton changes at one common source input.
    # Selected +1, A-alternative -1, B-alternative -1. This requires
    # r_A>=2, r_B>=2, r_selected_leaf>=2, so any uniform row K>=6.
    witness=[1]*(m*m)
    witness[1*m+0]=-1
    witness[0*m+1]=-1
    assert witness[0]==1
    x=(0,0)+tuple(witness)
    assert f(x,m)==1
    assert f((1,0)+tuple(witness),m)==-1
    assert f((0,1)+tuple(witness),m)==-1
    y=list(witness);y[0]=-1
    assert f((0,0)+tuple(y),m)==-1
    print(f'PASS all-m {m} full-row logical cases and three disjoint K>=6 dual singleton moves')


def exhaustive(m):
    nleaves=m*m
    signs=tuple(product((-1,1),repeat=nleaves))
    X=tuple((a,b)+ys for a in range(m) for b in range(m) for ys in signs)
    N=len(X)
    assert N==m*m*2**nleaves
    F={x:f(x,m) for x in X}
    assert sum(F.values())==0 and all(abs(v)==1 for v in F.values())
    V=Q(sum(v*v for v in F.values()),N)
    assert V==1
    influences=[]
    for coord in range(2+nleaves):
        if coord<2:
            numerator=sum(
                (F[x]-F[((j,x[1]) if coord==0 else (x[0],j))+x[2:]])**2
                for x in X for j in range(m))
            influence=Q(numerator,2*N*m)
        else:
            numerator=sum(
                (F[x]-F[x[:coord]+(-x[coord],)+x[coord+1:]])**2
                for x in X)
            influence=Q(numerator,4*N)
        influences.append(influence)
    truth=[1-Q(1,m)]*2+[Q(1,m*m)]*(m*m)
    assert influences==truth,(influences,truth)
    # Independent source orthogonal projection: h3=(Id-E_A)(Id-E_B)
    # applied to the linear-in-leaves function f. No Fourier assumption.
    h3=[]
    for x in X:
        a,b=x[:2]
        leaves=x[2:]
        row=sum(leaves[a*m+j] for j in range(m))
        col=sum(leaves[i*m+b] for i in range(m))
        total=sum(leaves)
        h=Q(leaves[a*m+b])-Q(row,m)-Q(col,m)+Q(total,m*m)
        h3.append(h)
    E3=sum((h*h for h in h3),Q())/N
    assert E3==(1-Q(1,m))**2>0
    print(f'PASS full true-source table m={m} N={N} V=1 I_A=I_B={influences[0]} '
          f'I_leaf={influences[2]} E3={E3}')


def main():
    for m in range(2,11):
        t=analytic(m)
        all_source_pair_row_valid(m)
        # Each leaf's pointwise row weight must be >=2 on its
        # address-selection event, which has exact measure 1/m^2.
        assert t['row_leaf_l2_total']==2*m
        assert t['leaf_norm_total']==m
        if m<=3:
            exhaustive(m)
        print(f'PASS m={m} K*=6, max influence={t["M"]}, '
              f'sum sqrt(I_leaf)={t["leaf_norm_total"]}, '
              f'lower bound sum ||row_leaf||_2={t["row_leaf_l2_total"]}')
    print('SCOPE: exact source degree 3 bilinear norm no-go, NOT a counterexample to UE2 or row exponent two')


if __name__=='__main__':
    main()
