from collections import Counter
from fractions import Fraction as F
from functools import lru_cache
from itertools import product

# Exact formal logarithm vectors: log(p/q) = sum exponent_l log(l).
def factor(n):
    out=Counter(); p=2
    while p*p<=n:
        while n%p==0: out[p]+=1; n//=p
        p+=1
    if n>1: out[n]+=1
    return out

def vecadd(*vs):
    out=Counter()
    for v in vs:
        for k,x in v.items():out[k]+=x
    return {k:x for k,x in out.items() if x}
def scale(v,a):return {k:a*x for k,x in v.items() if a*x}
@lru_cache(None)
def logvec(q):
    return vecadd(factor(q.numerator),scale(factor(q.denominator),-1))
def entropy(ps):return vecadd(*(scale(logvec(p),-p) for p in ps if p))
def mutual(law, keys):
    # law = {(theta,x): probability}; keys is a projection of x.
    a=Counter(); b=Counter(); ab=Counter()
    for (t,x),p in law.items():
        k=keys(x); a[t]+=p; b[k]+=p; ab[t,k]+=p
    return vecadd(entropy(a.values()),entropy(b.values()),scale(entropy(ab.values()),-1))

def meanvar(law,f):
    m=sum(p*f(x) for (_,x),p in law.items())
    return m,sum(p*(f(x)-m)**2 for (_,x),p in law.items())
def cond(law,j,b):
    mass=sum(p for (_,x),p in law.items() if x[j]==b)
    return mass,{(t,x):p/mass for (t,x),p in law.items() if x[j]==b and mass and p}
def energy(law,f,j):
    a=Counter(); b=Counter()
    for (t,x),p in law.items(): a[t]+=p; b[t,x[j]]+=p
    return sum(p*(b[t,1-x[j]]/a[t])*(f(x)-f(x[:j]+(1-x[j],)+x[j+1:]))**2/2 for (t,x),p in law.items() if p)
def tv2(law,j):
    a=Counter(); b=Counter(); q=F(0)
    for (t,x),p in law.items(): a[t]+=p; b[t,x[j]]+=p; q+=p*x[j]
    return sum(p*(b[t,1]/p-q)**2 for t,p in a.items() if p)

def make_law(p0,p1,w):
    law={}
    for t,ps,pt in [(0,p0,w),(1,p1,1-w)]:
        for x in product((0,1),repeat=len(ps)):
            p=pt
            for bit,q in zip(x,ps): p*=q if bit else 1-q
            if p: law[t,x]=p
    assert sum(law.values())==1
    return law

A=F(1,106); B=F(1,14580*2**6)
COUNTS=Counter()

def phase(law,read,released,f,levels):
    # Returns a distribution over terminal histories with their cost,
    # and separately checks exact private and shared drift at every node.
    def rec(law,read,lev,n):
        m,v=meanvar(law,f)
        while lev<len(levels) and v<=levels[lev]:lev+=1
        if lev==len(levels):return [(F(1),law,read,n,m)]
        unread=[j for j in released if j not in read]
        assert unread and v>levels[lev]
        e={j:energy(law,f,j) for j in unread}
        assert sum(e.values())<=2*v
        i=next((j for j in unread if e[j]>=A*v*v),None)
        if i is None:
            i=next((j for j in unread if 2*tv2(law,j)>=B*v**3),None)
            assert i is not None
            COUNTS['information']+=1
        else:COUNTS['energy']+=1
        COUNTS['nodes']+=1
        children=[(p,ch) for b in (0,1) for p,ch in [cond(law,i,b)] if p]
        J=mutual(law,lambda x:tuple(x[j] for j in range(len(x)) if j not in read))
        Jnext=vecadd(*(scale(mutual(ch,lambda x:tuple(x[j] for j in range(len(x)) if j not in read|{i})),p) for p,ch in children))
        assert vecadd(J,scale(Jnext,-1))==mutual(law,lambda x:x[i])
        pnext=sum(p*sum(energy(ch,f,j) for j in unread if j!=i) for p,ch in children)
        assert sum(e.values())-pnext==e[i]
        assert sum(p*meanvar(ch,f)[1] for p,ch in children)<=v
        out=[]
        for p,ch in children:
            for p2,final,r,n2,m2 in rec(ch,read|{i},lev,n+1):out.append((p*p2,final,r,n2,m2))
        return out
    return rec(law,read,0,0)


def check_policy(law):
    # Two actual release stages; second task chosen from the first output.
    levels=(F(1,8),F(1,16))
    f1=lambda x:F(x[0]+x[1],2)
    first=phase(law,set(),(0,1),f1,levels)
    assert sum(p for p,*_ in first)==1
    risk1=sum(p*meanvar(ch,f1)[1] for p,ch,*_ in first)
    assert risk1<=levels[-1]
    total=F(0); risk2=F(0); final=[]
    for p,ch,read,n,m in first:
        if m>=F(1,2):f2=lambda x:F(x[0]+x[2]*x[3],2)
        else:f2=lambda x:F(x[1]+x[2]+x[3],3)
        for p2,ch2,r,n2,m2 in phase(ch,read,(0,1,2,3),f2,levels):
            total+=p*p2*(n+n2); risk2+=p*p2*meanvar(ch2,f2)[1]; final.append((p*p2,n+n2))
    assert risk2<=levels[-1]
    assert sum(p for p,n in final)==1
    assert total<=4 and all(n<=4 for p,n in final)
    for m in range(5):assert sum(p for p,n in final if n>m)*(m+1)<=total
    COUNTS['models']+=1


def check_feedback():
    # Independent direct recursion with signed local estimation errors.
    # s'=a*s+b*u+c*xi, pi(s)=k*s; no clipping is needed for this algebra test.
    for a,b,k in product((F(0),F(1,4),F(1,2)),repeat=3):
        rho=a+b*k; c=F(1,8)
        for xis in product((F(0),F(1)),repeat=4):
            for errs in product((F(-1,16),F(0),F(1,16)),repeat=4):
                s=z=F(0); bound=F(0)
                for xi,err in zip(xis,errs):
                    est=z+err
                    assert abs(est-s)<=abs(err)+bound
                    s1=a*s+b*k*s+c*xi
                    z1=a*z+b*k*est+c*xi
                    bound=rho*bound+b*k*abs(err)
                    assert abs(z1-s1)<=bound
                    s,z=s1,z1
                    COUNTS['feedback_steps']+=1

if __name__=='__main__':
    vals=(F(0),F(1,2),F(1))
    for p0,p1 in product(((F(0),F(1,2),F(1),F(1,2)),(F(1),F(0),F(1,2),F(1)),(F(1,2),)*4, (F(1,4),F(3,4),F(1,4),F(3,4))),repeat=2):
        for w in vals:check_policy(make_law(p0,p1,w))
    # A pure common-label source forces an actual information-type query.
    check_policy(make_law((F(0),)*4,(F(1),)*4,F(1,2)))
    check_feedback()
    assert COUNTS['information']>0 and COUNTS['energy']>0
    print(dict(COUNTS))
