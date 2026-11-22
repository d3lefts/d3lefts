#!/usr/bin/env python3
"""Exact 2D-per-frequency sectors and indefinite centered terminal effect.

Independent rational audit of the quantum T=2 conditional-amplitude
certificate with genuine inter-query mixing. Finite evidence only.
"""
from fractions import Fraction as F
from collections import Counter
Z, O = F(0),F(1)

def rows(L):
    r,w=[1],1
    for _ in range(L):
        r=r+[a<<w for a in r]+[a | (a<<w) for a in r]
        w*=2
    return [0]+r

def chi(a,s):return -1 if (a&s).bit_count()%2 else 1
def dot(x,y):return sum((a*b for a,b in zip(x,y)),Z)

def householder(x, w):
    factor=2*dot(w,x)/dot(w,w)
    return [a-factor*b for a,b in zip(x,w)]

def basis(n,i):return [O if j==i else Z for j in range(n)]

def span(ks):
    W={0}
    for a in ks:W|={a^z for z in list(W)}
    return W

def main():
    D=rows(2); m=len(D); n=2*m
    assert m==10 and n==20
    hv=[F(j+1) for j in range(n)]
    hw=[F(1+2*j) for j in range(n)]
    psi=householder(basis(n,0),[O]*n)
    u=householder(basis(n,0),hv)
    v=householder(basis(n,1),hv)
    assert dot(psi,psi)==dot(u,u)==dot(v,v)==O and dot(u,v)==0
    def oracle(x,s):return [x[i]*chi(D[i//2],s) for i in range(n)]
    states=[]
    for s in range(16):
        y=oracle(householder(oracle(psi,s),hw),s)
        assert dot(y,y)==1
        states.append(y)
    def projection(a,x):
        return [x[i] if i//2==a else Z for i in range(n)]
    # Signed A=1/4 |u><u| - 1/16 |v><v|.
    # F=(1/2 <u,psi_s>,1/4 <v,psi_s>) and J=diag(+,-).
    direct=[(dot(u,y)/2,dot(v,y)/4) for y in states]
    accept=[F(1,2)+f0*f0-f1*f1 for f0,f1 in direct]
    assert len(set(accept))>1 and all(0<=t<=1 for t in accept)
    C={}
    for a in range(m):
        pa=projection(a,psi)
        rotated=householder(pa,hw)
        for b in range(m):
            pb=projection(b,rotated)
            C[a,b]=(dot(u,pb)/2,dot(v,pb)/4)
    for s in range(16):
        f=tuple(sum((C[a,b][k]*chi(D[a]^D[b],s)
                     for a in range(m) for b in range(m)),Z)
                for k in (0,1))
        assert f==direct[s]
    p=[dot(projection(a,psi),projection(a,psi)) for a in range(m)]
    q=[dot(projection(b,u),projection(b,u))/4 +
       dot(projection(b,v),projection(b,v))/16 for b in range(m)]
    t=sum(q)
    assert sum(p)==1 and t==F(5,16)
    eta_a,eta_b=F(1,20),F(1,10000)
    Ha={i for i in range(m) if p[i]>=eta_a}
    Hb={i for i in range(m) if q[i]>=eta_b}
    W=span(D[i] for i in Ha|Hb)
    coeff={}
    for a in range(m):
        for b in range(m):
            z=D[a]^D[b]
            prev=coeff.get(z,(Z,Z))
            coeff[z]=(prev[0]+C[a,b][0],prev[1]+C[a,b][1])
    for z in range(16):
        for k in (0,1):
            brute=sum((direct[s][k]*chi(z,s) for s in range(16)),Z)/16
            assert brute==coeff.get(z,(Z,Z))[k]
    cond=[]
    for s in range(16):
        cond.append(tuple(sum((amp[k]*chi(z,s)
                              for z,amp in coeff.items() if z in W),Z)
                          for k in (0,1)))
    buckets={}
    for s in range(16):
        key=tuple(chi(D[i],s) for i in sorted(Ha|Hb))
        buckets.setdefault(key,[]).append(s)
    for idx in buckets.values():
        avg=tuple(sum((direct[s][k] for s in idx),Z)/len(idx)
                  for k in (0,1))
        assert all(cond[s]==avg for s in idx)
    mse=sum((sum(((direct[s][k]-cond[s][k])**2 for k in (0,1)),Z)
             for s in range(16)),Z)/16
    assert mse==sum((sum((x*x for x in amp),Z)
                     for z,amp in coeff.items() if z not in W),Z)
    M=max(Counter(D[a]^D[b] for a in range(m) for b in range(m) if a!=b).values())
    assert M==6
    pair_energy=sum((sum((x*x for x in C[a,b]),Z)
                     for a in range(m) for b in range(m)
                     if D[a]^D[b] not in W),Z)
    first=sum((sum((x*x for x in C[a,b]),Z)
               for a in range(m) if a not in Ha for b in range(m)),Z)
    second=sum((sum((x*x for x in C[a,b]),Z)
                for b in range(m) if b not in Hb for a in range(m)),Z)
    assert mse<=M*pair_energy and pair_energy<=first+second
    assert first<=eta_a*t and second<=eta_b
    bound=M*(eta_a*t+eta_b)
    assert mse<=bound<1
    for s in range(16):
        g0=F(1,2)+cond[s][0]**2-cond[s][1]**2
        g=max(Z,min(O,g0))
        assert 0<=g<=1
        dist=sum(((direct[s][k]-cond[s][k])**2 for k in (0,1)),Z)
        assert (accept[s]-g)**2 <=4*dist
    assert mse>0
    assert len((Ha|Hb)-{0})==3
    assert mse==F(6035410741,585003171025000)
    assert bound==F(1887,20000)
    print('PASS mixed rank2 sectors, signed A, MSE',mse,'bound',bound,
          'queried original rows',len((Ha|Hb)-{0}),
          'acceptance values',len(set(accept)))
    print('Finite check only; no general T2 theorem certification.')

if __name__=='__main__':main()
