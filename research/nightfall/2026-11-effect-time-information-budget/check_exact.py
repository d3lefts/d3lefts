#!/usr/bin/env python3
"""NIGHTFALL independent exact effect-time risk certificate replay.
Finite model / Fractions. A passed replay is NOT Lean or real-world guard proof.
"""
from fractions import Fraction as Q
from itertools import product
from random import Random
import hashlib, json

def certificate(a,s,u,v,L,H,delta,xi,alpha):
    def max_linear(coeff):
        return sum((H[i] if t>=0 else L[i])*t for i,t in enumerate(coeff))
    def min_linear(coeff):
        return sum((L[i] if t>=0 else H[i])*t for i,t in enumerate(coeff))
    c=[(1-delta)*a[i]*u[i]-delta*s[i]*v[i] for i in range(len(a))]
    d=[a[i]*(u[i]-xi) for i in range(len(a))]
    e=[s[i]*(v[i]-alpha) for i in range(len(a))]
    return max_linear(c)<=0,max_linear(d)<=0,min_linear(e)>=0

def oracle(a,s,u,v,L,H,delta,xi,alpha):
    safety=True;false_commit=True;availability=True
    for bits in product((0,1),repeat=len(a)):
        lam=[H[i] if z else L[i] for i,z in enumerate(bits)]
        um=sum((lam[i]*a[i]*u[i] for i in range(len(a))),Q(0))
        sm=sum((lam[i]*s[i]*v[i] for i in range(len(a))),Q(0))
        ua=sum((lam[i]*a[i] for i in range(len(a))),Q(0))
        sa=sum((lam[i]*s[i] for i in range(len(a))),Q(0))
        assert um+sm>0 and ua>0 and sa>0
        safety &= um/(um+sm)<=delta
        false_commit &= um/ua<=xi
        availability &= sm/sa>=alpha
    return safety,false_commit,availability

def policies(rem):
    result=[("defer",),("permit",)]
    for i in rem:
        rem2=tuple(j for j in rem if j!=i)
        for l in policies(rem2):
            for r in policies(rem2):
                result.append(("test",i,l,r))
    return result

def policy_score(t, tests, prior, gu, gs, delta, xi, alpha):
    attempted=[];read=[]
    def go(node,wu,ws):
        if node[0]=="defer":return
        if node[0]=="permit":
            attempted.append((wu,ws));return
        i=node[1];read.append((i,wu,ws))
        cost,pu,ps=tests[i]
        go(node[2],wu*(1-pu),ws*(1-ps))
        go(node[3],wu*pu,ws*ps)
    go(t,Q(1),Q(1))
    for wu,ws in attempted:
        x=prior*wu*gu
        y=(1-prior)*ws*gs
        if x+y and x/(x+y)>delta:return None
    unsafe=sum((wu*gu for wu,ws in attempted),Q(0))
    safe=sum((ws*gs for wu,ws in attempted),Q(0))
    if unsafe>xi or safe<alpha:return None
    cost=sum((tests[i][0]*(prior*wu+(1-prior)*ws) for i,wu,ws in read),Q(0))
    return cost,unsafe,safe

def main():
    rng=Random(20261115);h=hashlib.sha256()
    outcomes=[0,0,0];cases=0
    for n in range(1,7):
        for k in range(100):
            a=[Q(rng.randint(1,8),rng.randint(9,19)) for _ in range(n)]
            s=[Q(rng.randint(1,8),rng.randint(9,19)) for _ in range(n)]
            u=[Q(rng.randint(1,4),4) for _ in range(n)]
            v=[Q(rng.randint(1,4),4) for _ in range(n)]
            L=[Q(rng.choice((1,2,3)),4) for _ in range(n)]
            H=[Q(rng.choice((4,6,8)),4) for _ in range(n)]
            delta=rng.choice((Q(1,10),Q(1,4),Q(1,2),Q(3,4)))
            xi=rng.choice((Q(1,10),Q(1,4),Q(1,2),Q(3,4)))
            alpha=rng.choice((Q(1,10),Q(1,4),Q(1,2),Q(3,4)))
            c=certificate(a,s,u,v,L,H,delta,xi,alpha)
            o=oracle(a,s,u,v,L,H,delta,xi,alpha)
            assert c==o,(n,k,c,o)
            outcomes=[outcomes[j]+int(c[j]) for j in range(3)]
            h.update(f"{n}|{k}|{c}\n".encode());cases+=1
            # The selection-bound inequality is also independently checked.
            p=Q(rng.randint(1,99),100)
            al=Q(rng.randint(1,100),100)
            u0=Q(rng.randint(0,100),100)
            v0=al+(1-al)*Q(rng.randint(0,100),100)
            post=p*u0/(p*u0+(1-p)*v0)
            assert post<=p/(p+(1-p)*al)
    assert cases==600
    # Exact failure of naive risk transfer and proof of corrected policy choice.
    p=Q(1,10);gu=Q(1);gs=Q(1,2)
    assert p*gu/(p*gu+(1-p)*gs)==Q(2,11)>p
    assert (Q(1,10)*Q(1,4))/(Q(1,10)*Q(1,4)+Q(9,10)*Q(3,4)*Q(1,2))==Q(2,29)
    ts=((Q(1),Q(1,4),Q(3,4)),(Q(3),Q(1,10),Q(9,10)))
    plans=policies((0,1))
    feasible=[(policy_score(t,ts,p,gu,gs,Q(1,10),Q(1,4),Q(7,20)),repr(t))
              for t in plans]
    feasible=[(a,b) for a,b in feasible if a is not None]
    assert len(plans)==74 and len(feasible)==7
    winner=min(feasible)
    assert winner[0]==(Q(1),Q(1,4),Q(3,8))
    print(json.dumps(dict(status="PASS",exact_models=cases,
          risk_false_commit_availability_pass_counts=outcomes,
          deterministic_policies=len(plans),feasible_policies=len(feasible),
          optimal_evidence_cost=str(winner[0][0]),sha256=h.hexdigest()),indent=2))
if __name__=="__main__":
    main()
