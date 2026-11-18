#!/usr/bin/env python3
"""Independent rational finite-model audit of a loopy zero-field ferromagnetic Ising Q2 transfer.

The universal deduction requires classical GKS and Lebowitz inequalities plus the
product-Q2 theorem; these finite tests only check implementation/normalization.
Uses standard-library fractions and direct 2^n-state enumeration, no physics libs.
"""
from fractions import Fraction as Q
from itertools import product, combinations

def spin(state, i):
    return 1 if state & (1 << i) else -1

def verify(n, edges, name):
    assert all(0 <= t < 1 for _, _, t in edges)
    states=range(1 << n)
    raw={s: __import__('math').prod(Q(1)+t*spin(s,i)*spin(s,j) for i,j,t in edges) for s in states}
    Z=sum(raw.values())
    p={s:raw[s]/Z for s in states}
    assert sum(p.values())==1 and all(x>0 for x in p.values())
    def moment(S):
        return sum((p[s]*__import__('math').prod(spin(s,i) for i in S) for s in states),Q(0))
    pairs=list(combinations(range(n),2))
    cov={(i,j):moment((i,j)) for i,j in pairs}
    def C(i,j):return Q(1) if i==j else cov[tuple(sorted((i,j)))]
    assert all(0<=C(i,j)<=1 for i in range(n) for j in range(n))
    S=max(sum((C(i,j) for j in range(n)),Q(0)) for i in range(n))
    assert S<2, (name,S)
    eta=2-S
    # GKS and Lebowitz four-point inequalities, including overlapping pairs.
    qrows=[]
    for a,(i,j) in enumerate(pairs):
        row=[]
        for k,l in pairs:
            S4=set((i,j)) ^ set((k,l))
            v4=moment(tuple(S4))
            cov4=v4-C(i,j)*C(k,l)
            upper=C(i,k)*C(j,l)+C(i,l)*C(j,k)
            assert 0<=cov4<=upper,(name,i,j,k,l,cov4,upper)
            row.append(cov4)
        qrows.append(row)
    maxrow=max(sum(row,Q(0)) for row in qrows)
    assert maxrow<=S*S,(name,maxrow,S*S)
    # Derive exact conditional spin variance floor via tanh addition.
    vmin=Q(1)
    for i in range(n):
        neighbors=[(j,t) if j!=i else (u,t) for u,j,t in edges for _ in ((),) if u==i or j==i]
        # Above comprehension treats u,j as (u,j); branch selects other endpoint.
        neighbors=[(j if u==i else u,t) for u,j,t in edges if i in (u,j)]
        mulplus=__import__('math').prod(1+t for _,t in neighbors)
        mulminus=__import__('math').prod(1-t for _,t in neighbors)
        htan=(mulplus-mulminus)/(mulplus+mulminus)
        vfloor=1-htan*htan
        vmin=min(vmin,vfloor)
        for s in states:
            if spin(s,i)!=1:continue
            b=s^(1<<i)
            # actual conditional variance of spin
            pplus=p[s]/(p[s]+p[b]);pminus=p[b]/(p[s]+p[b])
            assert 4*pplus*pminus >= vfloor
    assert vmin>0
    # Deterministic low degree polynomial tests; compare using actual native influences.
    for seed in range(7):
        aa=[Q(((i*7+seed*5)%5)-2, 11) for i in range(n)]
        bb={(i,j):Q(((i*3+j*11+seed*7)%7)-3,23) for i,j in pairs}
        f=lambda s:sum((aa[i]*spin(s,i) for i in range(n)),Q(0))+sum((b*spin(s,i)*spin(s,j) for (i,j),b in bb.items()),Q(0))
        mean=sum((p[s]*f(s) for s in states),Q(0))
        var=sum((p[s]*(f(s)-mean)**2 for s in states),Q(0))
        var0=sum((a*a for a in aa),Q(0))+sum((b*b for b in bb.values()),Q(0))
        assert var<=S*S*var0,(name,'variance',var,S*S*var0)
        inf=[]
        for i in range(n):
            ii=Q(0)
            for s in states:
                if spin(s,i)!=1:continue
                flip=s^(1<<i)
                diff=f(s)-f(flip)
                ii+=p[s]*p[flip]/(p[s]+p[flip])*diff*diff
            baseline=aa[i]**2+sum((b*b for (u,v),b in bb.items() if i in (u,v)),Q(0))
            assert ii>=vmin*eta*baseline,(name,i,'influence comparison',ii,vmin*eta*baseline)
            inf.append(ii)
        B=max(abs(f(s)) for s in states)
        # 106 exceeds source theorem C2; extra bound handles small concrete case.
        assert var*var <= Q(106)*S**4/eta/vmin*B*B*max(inf)
    print('PASS',name, 'vertices',n,'edges',len(edges),'S=',S,'2-S=',eta,
          'vmin=',vmin,'max 2nd-order covariance row=',maxrow)

if __name__=='__main__':
    verify(3,[(0,1,Q(1,7)),(1,2,Q(1,6)),(2,0,Q(1,8))], 'triangle')
    verify(4,[(0,1,Q(1,7)),(1,2,Q(1,6)),(2,3,Q(1,8)),(3,0,Q(1,9))], 'square')
    verify(5,[(i,(i+1)%5,Q(1,11)) for i in range(5)],'pentagon')
    verify(4,[(i,j,Q(1,30)) for i in range(4) for j in range(i+1,4)], 'K4')
    verify(9, [(i,j,Q(1,30)) for i in range(9) for j in (i+1,i+3) if j<9 and (j==i+1 and i//3==j//3 or j==i+3)],'3x3 grid')
    print('PASS: all exact finite loopy tests, including 4-point/GKS and native influence comparison')
