#!/usr/bin/env python3
"""Literal unordered-sum and insertion oracle; no third-party packages."""
import json
class Field:
    def __init__(self,p,n=1):
        self.p,self.n,self.q=p,n,p**n
        assert n==1 or (p,n)==(3,3)
    def digits(self,x):
        z=[]
        for _ in range(self.n):z.append(x%self.p);x//=self.p
        return z
    def enc(self,z):return sum((v%self.p)*self.p**i for i,v in enumerate(z))
    def add(self,a,b):return self.enc([x+y for x,y in zip(self.digits(a),self.digits(b))])
    def neg(self,a):return self.enc([-x for x in self.digits(a)])
    def sub(self,a,b):return self.add(a,self.neg(b))
    def mul(self,a,b):
        if self.n==1:return a*b%self.p
        A=self.digits(a);B=self.digits(b);C=[0]*5
        for i in range(3):
            for j in range(3):C[i+j]+=A[i]*B[j]
        for d in (4,3):
            v=C[d];C[d]=0;C[d-3]-=v;C[d-2]+=v
        return self.enc(C[:3])
    def pow(self,a,n):
        r=1
        while n:
            if n&1:r=self.mul(r,a)
            a=self.mul(a,a);n>>=1
        return r
    def nonsquare(self):
        return next(x for x in range(2,self.q) if self.pow(x,(self.q-1)//2)!=1)
def plus(a,b,F):return tuple(F.add(x,y) for x,y in zip(a,b))
def source(F,e,mu):
    P={(t,F.pow(t,e),0) for t in range(F.q)}
    C={(0,F.mul(mu,F.pow(u,e)),u) for u in range(F.q)}
    return sorted(P|C)
def check(F,e,mu,expect_sidon=True):
    A=source(F,e,mu);S=set(A);sums={};collision=None
    for i,a in enumerate(A):
        for b in A[i:]:
            c=plus(a,b,F)
            if c in sums:collision=(sums[c],(a,b));break
            sums[c]=(a,b)
        if collision:break
    if not expect_sidon:
        assert collision is not None
        return {'q':F.q,'exponent':e,'mu':mu,'negative_collision':str(collision)}
    assert collision is None
    assert len(A)==2*F.q-1
    blocked=0
    for x in range(F.q):
        for y in range(F.q):
            for z in range(F.q):
                v=(x,y,z)
                if v in S:continue
                bad=plus(v,v,F) in sums or any(plus(v,a,F) in sums for a in A)
                assert bad,('ADDABLE',F.q,e,mu,v)
                blocked+=1
    return {'q':F.q,'exponent':e,'mu':mu,'size':len(A),
            'unordered_sums':len(sums),'blocked_external':blocked,
            'ambient':F.q**3,'pass':True}
def main():
    rows=[]
    for p in (3,5,7,11):
        F=Field(p);mu=F.nonsquare()
        rows.extend((check(F,2,mu),check(F,2,1,False)))
    F=Field(3,3)
    assert all((x**3-x+1)%3 for x in range(3))
    assert len({F.pow(x,26) for x in range(1,27)})==1
    mu=F.nonsquare()
    rows.extend((check(F,4,mu),check(F,4,1,False)))
    assert [r['blocked_external'] for r in rows if r.get('pass')]==[22,116,330,1310,19630]
    print(json.dumps(rows,sort_keys=True,indent=2))
if __name__=='__main__':main()
