#!/usr/bin/env python3
"""Independent exact rational Simon_N / iid_N certificate audit for K <= 4.
This finite checker is NOT a universal proof or a Lean certificate.
"""
from fractions import Fraction as F
from itertools import combinations, permutations, product
from math import comb

def raw4(y):
    a,b,c,d=y
    A=int(a==b==c==d)
    T=sum(int(y[i]==y[j]==y[k]) for i,j,k in combinations(range(4),3))
    P=sum(int(y[i]==y[j]) for i,j in combinations(range(4),2))
    B=(int(a==b and c==d)+int(a==c and b==d)+int(a==d and b==c))
    return A,T,P,B

def kernels(y,N):
    A,T,P,B=raw4(y)
    return (F(A)-F(T,N)+F(P,N*N)-F(3,N**3),
            F(B)-F(P,N)+F(3,N*N))

def linear_map_values(m,r,matrix,offset):
    N=1<<m
    return [offset ^ sum((((x&mask).bit_count()%2)<<j) for j,mask in enumerate(matrix)) for x in range(N)]

def orbit_avg(y, dependent):
    N=len(y)
    ss=[S for S in combinations(range(N),4) if ((S[0]^S[1]^S[2]^S[3])==0)==dependent]
    p=[kernels([y[i] for i in S],N) for S in ss]
    return [sum(z[j] for z in p)/len(p) for j in range(2)]

def affine_probe(m,r):
    N=1<<m
    total=[F(0)]*4
    num=0
    for mm in product(range(N),repeat=r):
        for off in range(1<<r):
            vals=linear_map_values(m,r,mm,off)
            dep=orbit_avg(vals,True)
            ind=orbit_avg(vals,False)
            total=[s+v for s,v in zip(total,[*dep,*ind])]
            num+=1
    return [s/num for s in total]

def af(c,N,dep=False):
    t=F(1,N)
    return F(1,c**2 if dep else c**3)-F(4,c*c)*t+F(6,c)*t*t-3*t*t*t

def bf(c,N,dep=False):
    t=F(1,N)
    return (F(3,c) if dep else F(3,c*c))-F(6,c)*t+3*t*t

def main():
    for m in [2,3]:
        N=1<<m
        types=([True] if N==4 else [True,False])
        count=0
        total={typ:[F(0),F(0)] for typ in types}
        for s in range(1,N):
            pairs=[];used=set()
            for a in range(N):
                if a not in used:
                    b=a^s;used.update([a,b]);pairs.append((a,b))
            for labs in permutations(range(N),N//2):
                y=[0]*N
                for (a,b),v in zip(pairs,labs): y[a]=y[b]=v
                for typ in types:
                    d=orbit_avg(y,typ)
                    total[typ]=[z+q for z,q in zip(total[typ],d)]
                count+=1
        for typ in types:
            got=[z/count for z in total[typ]]
            ex=[F(3*(N+1),N**3*(N-1)),
                (F(3*(N*N-N-1),N*N*(N-1)) if typ else -F(3*(N+1),N*N*(N-1)))]
            assert got==ex, (N,typ,got,ex)
        print('N=',N,'Simon tables=',count,'orbit expectations pass')
        if N==8:
            t=F(1,N)
            got1=affine_probe(m,1)
            exp1=[af(2,N,True),bf(2,N,True),af(2,N),bf(2,N)]
            assert got1==exp1,(got1,exp1)
            got2=affine_probe(m,2)
            exp2=[af(4,N,True),bf(4,N,True),af(4,N),bf(4,N)]
            assert got2==exp2,(got2,exp2)
            print('  r=1,2 affine probes exact; 4 orbit entries each')
            p=F(1,N-1)
            E=p*F((N-1)**2,N*N)+(1-p)*F(1,N*N)
            gamma_lower=E/F((N-1)**2,N*N)
            assert gamma_lower==F(N*N-N-1,(N-1)**3)
            print('  Gamma_4 lower=', gamma_lower, ' <= upper 18/N=',F(18,N))
        g2=F(1,(N-1)**2)
        g3=F(N+2,(N-1)**2*(N-2))
        print('  Exact Gamma_1=0, Gamma_2=',g2,'Gamma_3=',g3)
    print('PASS: exhaustive finite Simon laws and affine probe certificates')

if __name__=='__main__':
    main()
