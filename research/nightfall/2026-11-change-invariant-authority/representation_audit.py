"""Independent rational coefficient check for the separator posterior representation theorem."""
from fractions import Fraction as F
from random import Random
import json, hashlib


def response_equal_as_polynomials(a,t,a2,t2):
    n=len(a)
    for i in range(n):
        if a[i]*t2[i]!=a2[i]*t[i]:return False
        for j in range(i+1,n):
            if a[i]*t2[j]+a[j]*t2[i]!=a2[i]*t[j]+a2[j]*t[i]:return False
    return True


def characterization(a,t,a2,t2):
    q=[x/y for x,y in zip(a,t)]
    q2=[x/y for x,y in zip(a2,t2)]
    if q!=q2:return False
    return len(set(q))==1 or len(set(y/x for x,y in zip(t,t2)))==1


def run():
    random=Random(155151);ntrials=0;digest=hashlib.sha256();constant=0;nonconstant=0
    for n in range(1,8):
        for _ in range(700):
            t=[F(random.randrange(1,11),random.randrange(1,14)) for i in range(n)]
            q=[F(random.randrange(0,11),10) for i in range(n)]
            a=[x*y for x,y in zip(q,t)]
            t2=[F(random.randrange(1,11),random.randrange(1,14)) for i in range(n)]
            if n>1 and random.randrange(0,3)==0:
                c=F(random.randrange(1,11),random.randrange(1,14))
                t2=[c*x for x in t]
            q2=q[:] if random.randrange(0,4) else [F(random.randrange(0,11),10) for i in range(n)]
            a2=[x*y for x,y in zip(q2,t2)]
            observed=response_equal_as_polynomials(a,t,a2,t2)
            asserted=characterization(a,t,a2,t2)
            assert observed==asserted, (n,a,t,a2,t2)
            if observed:
                if len(set(q))==1:constant+=1
                else:nonconstant+=1
            digest.update(f'{n}|{t}|{q}|{t2}|{q2}|{observed}\n'.encode())
            ntrials+=1
    # Explicit same conditioned risks but unequal separator distributions.
    a=[F(0),F(1)];t=[F(1),F(1)]
    a2=[F(0),F(2)];t2=[F(1),F(2)]
    assert not response_equal_as_polynomials(a,t,a2,t2)
    assert F(1,2)!=F(2,3)
    # Identical q means all priors and even total masses produce the same risk.
    a=[F(1,5),F(2,5)];t=[F(1),F(2)]
    a2=[F(1,5),F(7,5)];t2=[F(1),F(7)]
    assert response_equal_as_polynomials(a,t,a2,t2)
    print(json.dumps({'cases':ntrials,'equal_nonconstant':nonconstant,'equal_constant':constant,'sha256':digest.hexdigest(),'status':'PASS'},sort_keys=True))

if __name__=='__main__':run()
