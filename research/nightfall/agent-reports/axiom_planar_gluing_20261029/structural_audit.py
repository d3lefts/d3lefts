#!/usr/bin/env python3
"""Independent tuple-field planarity, spectra, constructive witness oracle."""
import json
class K:
    def __init__(self,p,n):
        self.p=p;self.n=n;self.zero=(0,)*n;self.one=(1,)+(0,)*(n-1)
        self.elts=[self.from_int(i) for i in range(p**n)]
    def from_int(self,i):
        a=[]
        for _ in range(self.n):a.append(i%self.p);i//=self.p
        return tuple(a)
    def add(self,a,b):return tuple((x+y)%self.p for x,y in zip(a,b))
    def neg(self,a):return tuple((-x)%self.p for x in a)
    def sub(self,a,b):return self.add(a,self.neg(b))
    def mul(self,a,b):
        if self.n==1:return ((a[0]*b[0])%self.p,)
        c=[0]*5
        for i,x in enumerate(a):
            for j,y in enumerate(b):c[i+j]+=x*y
        c[2]+=c[4];c[1]-=c[4]
        c[1]+=c[3];c[0]-=c[3]
        return tuple(x%self.p for x in c[:3])
    def power(self,a,k):
        v=self.one
        for _ in range(k):v=self.mul(v,a)
        return v
    def tripleadd(self,a,b):return tuple(self.add(x,y) for x,y in zip(a,b))
    def triplesub(self,a,b):return tuple(self.sub(x,y) for x,y in zip(a,b))
def check(p,n,e,mu_int):
    Kf=K(p,n);Z=Kf.zero;mu=Kf.from_int(mu_int)
    f=lambda x:Kf.power(x,e)
    g=lambda x:Kf.mul(mu,f(x))
    P=lambda x:(x,f(x),Z)
    C=lambda x:(Z,g(x),x)
    allx=Kf.elts
    for a in allx[1:]:
        df={Kf.sub(f(Kf.add(x,a)),f(x)) for x in allx}
        dg={Kf.sub(g(Kf.add(x,a)),g(x)) for x in allx}
        assert len(df)==len(allx)==len(dg)
    Rf={Kf.add(f(t),f(Kf.neg(t))) for t in allx[1:]}
    Rg={Kf.add(g(t),g(Kf.neg(t))) for t in allx[1:]}
    assert len(Rf)==len(Rg)==(len(allx)-1)//2
    assert Rf.isdisjoint(Rg) and Rf|Rg==set(allx[1:])
    A={P(x) for x in allx}|{C(x) for x in allx}
    assert len(A)==2*len(allx)-1
    count=0
    for a in allx:
        for b in allx:
            for c in allx:
                x=(a,b,c)
                if x in A:continue
                if a!=Z:
                    target=Kf.sub(b,g(c))
                    ws=[w for w in allx if Kf.sub(f(Kf.add(w,a)),f(w))==target]
                    assert len(ws)==1
                    w=ws[0];u=C(c);v=P(Kf.add(w,a));t=P(w)
                elif c!=Z:
                    vs=[v for v in allx if Kf.sub(g(Kf.add(v,c)),g(v))==b]
                    assert len(vs)==1
                    v=vs[0];u=P(Z);v1=C(Kf.add(v,c));t=C(v);v=v1
                else:
                    h=Kf.one;target=Kf.sub(f(h),b)
                    ss=[s for s in allx if Kf.sub(f(Kf.add(s,h)),f(s))==target]
                    assert len(ss)==1
                    s=ss[0];u=P(h);v=P(s);t=P(Kf.add(s,h))
                assert t!=u and t!=v
                assert Kf.triplesub(Kf.tripleadd(u,v),t)==x
                count+=1
    if p==3:
        fbad=lambda x:Kf.power(x,3)
        bad={Kf.sub(fbad(Kf.add(x,Kf.one)),fbad(x)) for x in allx}
        assert len(bad)==1
    assert Rf & Rf
    return {'p':p,'degree':n,'q':len(allx),'exponent':e,'mu':mu_int,
            'planar_derivatives':2*(len(allx)-1),'reflection_half':len(Rf),
            'constructive_blockers':count,'pass':True}
def main():
    rows=[check(p,1,2,mu) for p,mu in ((3,2),(5,2),(7,3),(11,2))]
    rows.append(check(3,3,4,2))
    assert [r['constructive_blockers'] for r in rows]==[22,116,330,1310,19630]
    print(json.dumps(rows,indent=2,sort_keys=True))
if __name__=='__main__':main()
