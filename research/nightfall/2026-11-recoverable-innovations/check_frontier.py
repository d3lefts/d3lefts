"""Independent all-subset audit of the reconstruction-only physical tree frontier."""
from fractions import Fraction as F
from itertools import combinations
from random import Random
from physical_frontier import maximum_reconstructed_energy
R=Random(15141013)
count=0
for trial in range(700):
    n=R.randint(1,10)
    parent=[-1]+[R.randrange(i) for i in range(1,n)]
    weights=[F(R.randint(0,20),R.choice([1,2,3])) for _ in range(1,n)]
    for budget in range(n+1):
        opt=F(0)
        for j in range(budget+1):
            for S in combinations(range(n),j):
                selected=set(S)
                val=sum((weights[v-1] for v in range(1,n)
                         if v in selected and parent[v] in selected),F(0))
                opt=max(opt,val)
        got,sites=maximum_reconstructed_energy(parent,weights,budget)
        assert got==opt and len(sites)<=budget,(trial,budget,got,opt)
        count+=1

# An unrestricted-physical-observation counterexample: querying endpoints
# of a length-two path reveals their product, even though no edge is
# individually reconstructed. Edge means 1/2, f=(G1+G2)/2.
prob={-1:F(1,4),1:F(3,4)}
mean=sum((p1*p2*F(g1+g2,2) for g1,p1 in prob.items()
          for g2,p2 in prob.items()),F(0))
var=sum((p1*p2*(F(g1+g2,2)-mean)**2 for g1,p1 in prob.items()
         for g2,p2 in prob.items()),F(0))
risk=F(0)
for z in (-1,1):
    rows=[(p1*p2,F(g1+g2,2)) for g1,p1 in prob.items()
          for g2,p2 in prob.items() if g1*g2==z]
    mass=sum((p for p,f in rows),F(0))
    m=sum((p*f for p,f in rows),F(0))/mass
    risk+=sum((p*(f-m)**2 for p,f in rows),F(0))
assert mean==F(1,2) and var==F(3,8) and risk==F(9,40)
assert risk<var
print({"exact_tree_budget_cases":count,
       "full_bayes_counterexample":"9/40 vs 3/8",
       "result":"all exact tests passed"})
