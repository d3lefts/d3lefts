#!/usr/bin/env python3
"""Independent direct-state brute-force lower bound and cross-posterior estimator audit.
No import from local-influences checker. Exact Fraction only.
"""
from fractions import Fraction as Q
from itertools import product, combinations
import json
A=0

def prove(v, tag):
 global A
 A+=1
 if not v:raise AssertionError(tag)

def star(r,m):
 # each of r channels has m pairs, each ± sign independent (encoded as Z_3 innovations 0/1)
 N=2*r*m
 possibilities=list(product((-1,1),repeat=N))
 # root z is revealed for free. Physical leaf x=z+u mod3 is a bijection for fixed z
 assert len(possibilities)==2**N
 return possibilities

def squared_residual_exact(values,subset,r,m):
 N=2*r*m
 # Directly condition the distribution on every possible observed coordinate pattern
 subsets={}
 for x in values:
  key=tuple(x[i] for i in subset)
  subsets.setdefault(key,[]).append(x)
 outcome=Q(0)
 for xs in subsets.values():
  size=len(xs)
  means=[]
  for c in range(r):
   means.append(Q(sum(sum(x[2*(c*m+j)]*x[2*(c*m+j)+1] for j in range(m)) for x in xs),m*size))
  for x in xs:
   for c in range(r):
    val=Q(sum(x[2*(c*m+j)]*x[2*(c*m+j)+1] for j in range(m)),1)
    outcome+=(val-Q(m)*means[c])**2/Q(r*m*m*len(values))
 return outcome

def expected_risk_formula(subset,r,m):
 incomplete=0
 for c in range(r):
  for j in range(m):
   i=2*(c*m+j)
   if i not in subset or i+1 not in subset: incomplete+=1
 return Q(incomplete,r*m*m)

def posterior_estimator_direct(p):
 # innovation U=(x,y) fair signs, f_theta(U)=theta*x*y, independent thetas with P(theta=1)=p
 eps=[(-1,1-p),(1,p)]
 terms=[]
 for x,y,xp in product((-1,1),repeat=3):
  for t1,w1 in eps:
   for t2,w2 in eps:
    d=x*y-xp*y
    z=Q(t1*t2*d*d,2)
    terms.append((z,Q(1,8)*w1*w2))
 mean=sum((z*w for z,w in terms),Q(0))
 v=sum((w*(z-mean)**2 for z,w in terms),Q(0))
 true=(2*p-1)**2
 return mean,v,true

def main():
 models=0; subsets=0
 for r,m in [(1,1),(1,2),(1,3),(2,1),(2,2)]:
  states=star(r,m);n=2*r*m
  for size in range(n+1):
   for s in combinations(range(n),size):
    S=set(s)
    exact=squared_residual_exact(states,S,r,m)
    theory=expected_risk_formula(S,r,m)
    prove(exact==theory,'full Bayes physical leaf posterior vs incomplete pair formula')
    prove(exact >= Q(1,m)-Q(size,2*r*m*m),'state-read lower')
    if exact<=Q(1,2*m):prove(size>=r*m,'matching read lower')
    subsets+=1
  models+=1
 for p in [Q(0),Q(1,4),Q(1,2),Q(3,4),Q(1)]:
  E,V,I=posterior_estimator_direct(p)
  prove(E==I,'cross-posterior unbiased influence')
  prove(V>=0,'variance nonnegative')
  if p==Q(1,2):prove(V==2,'zero-actionable influence nonzero estimator variance')
 # Z3 star: with root uniform 0,1,2 and innovations 0,1 fair, each leaf uniform but shared-root dependent
 joint_equal=Q(0)
 for z in (0,1,2):
  for u,v in product((0,1),repeat=2):
   if (z+u)%3==(z+v)%3:joint_equal+=Q(1,12)
 prove(joint_equal==Q(1,2),'genuine dependent physical leaves')
 prove(joint_equal!=Q(1,3),'not independently uniform physical leaves')
 print(json.dumps({'status':'PASS','rank_pair_models':models,'observation_subsets':subsets,
                   'exact_assertions':A,'posterior_cases':5,'dependent_star_equal_probability':str(joint_equal),
                   'scope':'full physical-site Bayes risk with root given freely, independent cross-model estimator'}))
if __name__=='__main__':main()
