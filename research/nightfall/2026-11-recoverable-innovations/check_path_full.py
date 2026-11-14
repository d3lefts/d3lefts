"""Independent exact original-spin enumeration for unrestricted path site reads.

A separate brute Bayes calculation enumerates original root+edge configurations,
compares every nonadaptive set with interval covariance recurrence, and searches
all size-budget subsets. No numerical tolerances or dependence on the formula
in the brute oracle.
"""
from fractions import Fraction as F
from itertools import product,combinations
from random import Random
from path_full_bayes import exact_risk,optimum_nonadaptive_sites,interval_gains
R=Random(1572253)

def brute_risk(means,coeff,selected):
    n=len(means)+1
    buckets={}
    for root in (-1,1):
        for increments in product((-1,1),repeat=n-1):
            p=F(1,2)
            for e,t in enumerate(means):
                p*=F(1+F(t)*increments[e],2)
            if not p:continue
            X=[root]
            for g in increments:X.append(X[-1]*g)
            val=sum((F(c)*g for c,g in zip(coeff,increments)),F(0))
            key=tuple(X[i] for i in selected)
            buckets.setdefault(key,[]).append((p,val))
    risk=F(0)
    for bucket in buckets.values():
        mass=sum((p for p,x in bucket),F(0))
        mean=sum((p*x for p,x in bucket),F(0))/mass
        risk+=sum((p*(x-mean)**2 for p,x in bucket),F(0))
    return risk

counts={'random_path_models':0,'full_bayes_set_comparisons':0,
        'optimized_budget_comparisons':0,'biased_path_counterexample':0,
        'degenerate_edge_models':0}
vals=[F(-1),F(-3,4),F(-1,2),F(0),F(1,4),F(1,2),F(3,4),F(1)]
for trial in range(40):
    n=R.randint(2,8)
    means=[R.choice(vals) for i in range(n-1)]
    coeff=[F(R.randint(-3,3),R.choice((1,2,3))) for i in range(n-1)]
    risks={}
    for k in range(n+1):
        for S in combinations(range(n),k):
            direct=brute_risk(means,coeff,S)
            inferred=exact_risk(means,coeff,S)
            assert inferred==direct,(trial,means,coeff,S,inferred,direct)
            risks[S]=direct
            counts['full_bayes_set_comparisons']+=1
    for budget in range(n+1):
        opt=min(val for S,val in risks.items() if len(S)<=budget)
        value,sites=optimum_nonadaptive_sites(means,coeff,budget)
        assert value==opt,(trial,budget,means,coeff,value,opt)
        assert len(sites)<=budget
        assert exact_risk(means,coeff,sites)==value
        counts['optimized_budget_comparisons']+=1
    counts['random_path_models']+=1
    counts['degenerate_edge_models']+=any(abs(t)==1 for t in means)

m=[F(1,2),F(1,2)];c=[F(1,2),F(1,2)]
assert exact_risk(m,c,())==F(3,8)
assert exact_risk(m,c,(0,2))==F(9,40)
assert interval_gains(m,c)[0][2]==F(3,20)
assert brute_risk(m,c,(0,2))==F(9,40)
counts['biased_path_counterexample']=1
print(counts)
