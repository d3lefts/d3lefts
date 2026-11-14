"""Independent exact arithmetic falsification of the sharp edge-observation bound.

This single-file reproducibility check does not call the construction algorithm.
It also tests a strict correlated-star physical Bayes lower example.
Python 3.11+; standard library only.
"""
from fractions import Fraction as F
from itertools import product, combinations
from random import Random
R = Random(104729)
counts = {"random_additive_models": 0, "q_budgets": 0,
          "correlated_star_cases": 0, "physical_transcript_buckets": 0}
for trial in range(500):
    n=R.randint(1,8); a=R.choice([2,3])
    prob=[]; h=[]
    for i in range(n):
        w=[R.randint(0,5) for _ in range(a)]
        if not sum(w): w[0]=1
        prob.append([F(v,sum(w)) for v in w])
        h.append([F(R.randint(-5,5),R.choice([1,2,3])) for _ in range(a)])
    allowed=[x for x in product(range(a),repeat=n)
             if all(prob[i][x[i]] for i in range(n))]
    B=max(abs(sum((h[i][x[i]] for i in range(n)),F(0))) for x in allowed)
    means=[sum((prob[i][g]*h[i][g] for g in range(a)),F(0)) for i in range(n)]
    vars=[sum((prob[i][g]*(h[i][g]-means[i])**2 for g in range(a)),F(0))
          for i in range(n)]
    order=sorted(range(n),key=lambda i:(-vars[i],i))
    for q in range(1,n+1):
        chosen=set(order[:q])
        risk=sum((vars[i] for i in range(n) if i not in chosen),F(0))
        assert risk<=B*B/F(4*q),(trial,n,q,risk,B)
        counts["q_budgets"]+=1
    counts["random_additive_models"]+=1

for q in range(1,5):
    m=2*q
    states=[]
    for root in range(3):
        for g in product((0,1),repeat=m):
            x=(root,)+tuple((root+u)%3 for u in g)
            y=sum((F(1,m)*(1 if u==0 else -1) for u in g),F(0))
            states.append((x,F(1,3*2**m),y))
    for selected in combinations(range(1,m+1),q):
        buckets={}
        for x,p,y in states:
            key=(x[0],)+tuple(x[i] for i in selected)
            buckets.setdefault(key,[]).append((p,y))
        risk=F(0)
        for rows in buckets.values():
            mass=sum((p for p,y in rows),F(0))
            mean=sum((p*y for p,y in rows),F(0))/mass
            risk+=sum((p*(y-mean)**2 for p,y in rows),F(0))
            counts["physical_transcript_buckets"]+=1
        assert risk==F(1,4*q),(q,selected,risk)
        counts["correlated_star_cases"]+=1
print({**counts,"result":"all exact tests passed"})
