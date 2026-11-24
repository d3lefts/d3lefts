"""Physical-query simulator. Promise: y(b)y(b xor h)=(-1)^q(b), q quadratic."""
from fractions import Fraction
from random import Random
from statistics import median

def parity(v): return v.bit_count() & 1

def solve(rows):
    piv={}
    for a,b in rows:
        while a:
            i=a.bit_length()-1
            if i not in piv:
                piv[i]=(a,b); break
            c,d=piv[i]; a^=c; b^=d
        else:
            if b: raise ValueError('inconsistent linear equations')
    x=0
    for i,(a,b) in sorted(piv.items()):
        if parity(a&x)^b: x|=1<<i
    return x

class Simulator:
    def __init__(self,n,h,y):
        self.n=n; self.h=h
        def q(b): return int(y(b)!=y(b^h))
        c=q(0); e=[q(1<<i)^c for i in range(n)]; cols=[0]*n
        for i in range(n):
            for j in range(i):
                if q((1<<i)^(1<<j))^e[i]^e[j]^c:
                    cols[i]|=1<<j; cols[j]|=1<<i
        def apply(v):
            out=0
            while v:
                bit=v&-v; out^=cols[bit.bit_length()-1]; v^=bit
            return out
        def polar(u,v): return parity(apply(u)&v)
        lin=sum(bit<<i for i,bit in enumerate(e))
        def qbar(v):
            a=parity(lin&v)
            while v:
                bit=v&-v; v^=bit
                a^=parity(cols[bit.bit_length()-1]&v)
            return a
        basis=[1<<i for i in range(n)]; pairs=[]
        while True:
            pair=next(((i,j) for i in range(len(basis)) for j in range(i) if polar(basis[i],basis[j])),None)
            if pair is None: break
            i,j=pair; p,t=basis[i],basis[j]; pairs.append((p,t,qbar(p),qbar(t)))
            basis=[v^(p if polar(v,t) else 0)^(t if polar(v,p) else 0) for l,v in enumerate(basis) if l not in (i,j)]
        self.r=len(pairs); self.s=1<<self.r
        self.k=solve((v,qbar(v)) for v in basis)
        self.L=[apply(v) for p,t,_,_ in pairs for v in (p,t)]
        self.pairs=pairs; self.c=c
    def sign(self,k):
        a=self.c
        for p,t,alpha,beta in self.pairs:
            a^=(alpha^parity(k&p))&(beta^parity(k&t))
        return 1-2*a
    def draw_L(self,rng):
        mask=rng.getrandbits(len(self.L)); out=0
        for i,b in enumerate(self.L):
            if mask>>i&1: out^=b
        return out
    def trial(self,x,rng):
        u=rng.getrandbits(self.n)
        left=[u^self.draw_L(rng) for _ in range(self.s)]
        right=[u^self.k^self.draw_L(rng) for _ in range(self.s)]
        a=[x(i) for i in left]; b=[x(j)*(1-2*parity(self.h&j)) for j in right]
        return Fraction(sum(ai*bj*self.sign(i^j) for i,ai in zip(left,a) for j,bj in zip(right,b)),self.s)
    def estimate(self,x,rng,group_size,groups):
        return median([sum((self.trial(x,rng) for _ in range(group_size)),Fraction(0))/group_size for _ in range(groups)])

if __name__=='__main__':
    from itertools import product
    from random import Random
    rng=Random(721)
    n=64; r=3; h=1<<(n-1); m=(1<<r)-1; calls={'x':0,'y':0}
    def y(b):
        calls['y']+=1
        q=parity((b&m)&(b>>r))^((b>>(2*r))&1)
        return -1 if b&h and q else 1
    def x(b):
        calls['x']+=1
        return -1 if b&(1<<(2*r)) and b&h else 1
    sim=Simulator(n,h,y)
    assert sim.r==r
    assert calls['y']==2*(1+n+n*(n-1)//2)
    mean=sim.estimate(x,rng,128,9)
    assert calls['x']==2*(1<<r)*128*9
    assert abs(mean-1)<Fraction(1,4)
    print(f'n={n}, rank={2*r}, estimate={mean}, exact=1, physical queries={calls}')
