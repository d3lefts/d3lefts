"""Exact exhaustive verifier; independent of Axiom's implementation.
Quadratic field represented by integers a+p*b, alpha**2=D.
Run: python3 checker.py
"""
from itertools import product

class Field:
    def __init__(self,p,D):
        assert pow(D,(p-1)//2,p)==p-1
        self.p,self.D=p,D
    def add(self,x,y):
        p=self.p
        return ((x%p+y%p)%p)+p*((x//p+y//p)%p)
    def mul(self,x,y):
        p,D=self.p,self.D
        return ((x%p*(y%p)+D*(x//p)*(y//p))%p)+p*(((x%p)*(y//p)+(x//p)*(y%p))%p)
    def power(self,x,n):
        out=1
        while n:
            if n&1:out=self.mul(out,x)
            x=self.mul(x,x);n//=2
        return out
    def det(self,x,y):
        p=self.p
        return ((x%p)*(y//p)-(x//p)*(y%p))%p
    def root(self,y):
        if y==0:return 0
        p=self.p
        c,d=y%p,y//p
        return 1 if y==1 else (self.D*d)%p+p*((1-c)%p)

def recover(F,x):
    p=F.p; k=len(x)
    y=[F.power(v,p-1) for v in x]
    roots=[F.root(t) for t in y]
    assert all(F.power(r,p-1)==t for r,t in zip(roots,y))
    support=[j for j,t in enumerate(y) if t]
    if not support:return [0]*k,k
    t=support[0]; out=[0]*k; out[t]=roots[t]; count=k
    for j in support[1:]:
        u,v=roots[t],roots[j]
        c=1 if F.det(u,v) else p
        cv=F.mul(c,v)
        den=F.det(u,cv); assert den
        w=F.power(F.add(x[t],F.mul(c,x[j])),p-1)
        z=F.root(w)
        A=F.det(z,cv)*pow(den,-1,p)%p
        B=F.det(u,z)*pow(den,-1,p)%p
        assert A and B
        eta=B*pow(A,-1,p)%p
        out[j]=F.mul(eta,v)
        count+=1
    return out,count

def check(p,D,k):
    F=Field(p,D)
    n=0; mx=0
    for x in product(range(p*p),repeat=k):
        got,m=recover(F,x)
        assert any(all(F.mul(a,v)==w for v,w in zip(x,got)) for a in range(1,p)),(p,k,x,got)
        assert m<=2*k-1
        n+=1; mx=max(mx,m)
    return (p,D,k,n,mx)

if __name__=="__main__":
    summary=[check(5,2,k) for k in (1,2,3)]+[check(7,3,k) for k in (1,2)]
    assert sum(row[3] for row in summary)==18725
    for p,D,k,n,mx in summary:
        print(f"F_{p*p}: k={k}, tested={n}, worst_queries={mx}")
    print("PASS: 18,725/18,725 exact inputs")
