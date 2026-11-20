#!/usr/bin/env python3
"""Exact finite audit for the short-sum / bent Walsh / frame obstruction.

Only finite cases are checked; Sanders's theorem and all-dimensional
Fourier/pivot proofs remain mathematical dependencies, not machine certificates.
"""
from collections import deque
from itertools import combinations

def fwht(a):
    a=list(a); step=1; n=len(a)
    while step<n:
        for start in range(0,n,2*step):
            for i in range(start,start+step):
                u,v=a[i],a[i+step]; a[i]=u+v; a[i+step]=u-v
        step*=2
    return a

def sign_bent(z,r):
    return -1 if sum(((z>>(2*i))&1)*((z>>(2*i+1))&1)
                     for i in range(r//2))%2 else 1

def verify_walsh():
    for r in (2,4,6,8,10,12):
        F=fwht([sign_bent(z,r) for z in range(1<<r)])
        assert {abs(t) for t in F}=={1<<(r//2)}
        print("FLAT_BENT_WALSH_PASS",r)
        if r==8:
            N=1<<r; v=1<<(r//2)
            maxima={0:abs(F[0])}
            maxima[1]=max(abs(F[0]+s*F[u]) for u in range(1,N)
                          for s in (-1,1))
            seen=set(); worst=0
            for u in range(1,N):
                for w in range(u+1,N):
                    sub=tuple(sorted((u,w,u^w)))
                    if sub in seen:continue
                    seen.add(sub)
                    worst=max(worst,max(abs(F[0]+s*F[u]+t*F[w]+s*t*F[u^w])
                        for s in (-1,1) for t in (-1,1)))
            maxima[2]=worst
            assert len(seen)==10795
            for codim in (0,1,2):
                assert maxima[codim] <= (1<<codim)*v
                print("ALL_AFFINE_FLATS_PASS",codim,maxima[codim],N)

def verify_sumsets():
    for m in range(3,8):
        R=set(range(1,1<<m))
        S={0}
        for _ in range(4):
            S={u^v for u in S for v in R}
        assert S==set(range(1<<m))
        print("DENSE_FOUR_SUMSET_PASS",m)

def basis_frame_minimum(rows,m):
    """Exact all-bases search; h>m+1 forbids any dependent B."""
    N=1<<m
    cost=[N+1]*N; cost[0]=0
    queue=deque([0])
    while queue:
        v=queue.popleft()
        for r in rows:
            z=v^r
            if cost[z]>cost[v]+1:
                cost[z]=cost[v]+1;queue.append(z)
    assert all(c<=m for c in cost)
    best=None; n_bases=0
    for B in combinations(range(1,N),m):
        inverse={0:0}
        for i,b in enumerate(B):
            for v,c in tuple(inverse.items()):
                inverse[v^b]=c^(1<<i)
        if len(inverse)!=N:continue
        n_bases+=1
        c=max(inverse[r].bit_count() for r in rows)
        cp=max(cost[b] for b in B)
        score=c*cp
        if best is None or score<best[0]:
            best=(score,c,cp,B)
    return n_bases,best

def graph_rows(edges):
    return [(0 if a==0 else 1<<(a-1)) ^
            (0 if b==0 else 1<<(b-1)) for a,b in edges]

def verify_frames():
    cycle=graph_rows([(i,(i+1)%6) for i in range(6)])
    grid=[]
    for y in range(2):
        for x in range(3):
            v=3*y+x
            if x<2:grid.append((v,v+1))
            if y<1:grid.append((v,v+3))
    bipart=graph_rows([(i,j) for i in range(2) for j in range(2,5)])
    for name,rows,m,opt in [
      ("C6",cycle,5,5),
      ("grid2x3",graph_rows(grid),5,3),
      ("K2_3",bipart,4,3)
    ]:
        n,best=basis_frame_minimum(rows,m)
        assert best[0]==opt,(name,best)
        print("FRAME_BASIS_EXHAUST_PASS",name,"bases",n,"min",best[:3])

if __name__=="__main__":
    verify_walsh();verify_sumsets();verify_frames()
    print("SHORTSUM_BENT_FRAME_EXACT_FINITE_PASS")
