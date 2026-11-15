#!/usr/bin/env python3
"""Independent complete-world and policy-tree auditor; all rational.
Does not import solver's posterior/transition algorithms.
"""
from collections import defaultdict
from fractions import Fraction as F
from functools import lru_cache
from itertools import product
from hashlib import sha256
import json
from recert import Solver, Test, joint

COSTS={'noisy_a':1,'noisy_b':1,'read_b':3,'read_u':4,'read_a':3,'gold':7}

def make_worlds(pb1=F(1,3)):
    # Full joint constructed INDEPENDENTLY from recert.joint.
    result={}
    for v in product(range(2),repeat=5):
        b,u,a,n,z=v
        prob=F(1,3) if b else F(2,3)
        if pb1!=F(1,3):prob=pb1 if b else 1-pb1
        prob*= (F(3,4) if u else F(1,4)) if b else (F(1,4) if u else F(3,4))
        prob*= (F(1,4) if a else F(3,4)) if b else (F(3,4) if a else F(1,4))
        prob*= F(1,4) if n else F(3,4)
        prob*= F(3,4) if z==u else F(1,4)
        result[v]=prob
    assert sum(result.values())==1
    return result

def measure(w,action):
    b,u,a,n,z=w
    return {'noisy_a':a^n,'noisy_b':b^n,'read_b':b,'read_u':u,'read_a':a,'gold':int(a==u),'z':z}[action]

def compatible(w,h):
    return all(measure(w,k)==v for k,v in h)

def brute_policy_cost(worlds, tests, cache, delta,eta):
    """Enumerate all deterministic contingent policy trees (not min-Bellman).
    Every subtree cost is an explicit possible strategy; return minimum.
    Small models only: <=3 tests.
    """
    @lru_cache(None)
    def all_costs(h, remaining):
        cells={w:p for w,p in worlds.items() if compatible(w,h)}
        mass=sum(cells.values())
        assert mass>0
        uns=sum(p for w,p in cells.items() if w[1]!=w[2])/mass
        plans=[]
        if uns<=delta:plans.append(F(0))
        if 1-uns<=eta:plans.append(F(0))
        for t in remaining:
            parts=defaultdict(F)
            for w,p in cells.items():parts[measure(w,t)]+=p
            choices=[]
            for o,p in sorted(parts.items()):
                ch=tuple(sorted(h+((t,o),)))
                future=all_costs(ch,tuple(a for a in remaining if a!=t))
                assert future
                choices.append([(p/mass)*x for x in future])
            for tuplecost in product(*choices):
                plans.append(F(COSTS[t])+sum(tuplecost))
        # Set removes duplicate policies with identical expected costs only.
        return tuple(sorted(set(plans)))
    return min(all_costs(tuple(sorted(cache.items())),tuple(sorted(tests))))

def fixed_bundle_min(worlds,cache,delta,eta):
    from itertools import combinations
    names=tuple(COSTS)
    candidates=[]
    for k in range(len(names)+1):
      for sub in combinations(names,k):
        ok=True
        for out in product((0,1),repeat=len(sub)):
          h=tuple(sorted(tuple(cache.items())+tuple(zip(sub,out))))
          cells={w:p for w,p in worlds.items() if compatible(w,h)}
          mass=sum(cells.values())
          if mass==0:continue
          uns=sum(p for w,p in cells.items() if w[1]!=w[2])/mass
          if not (uns<=delta or 1-uns<=eta):ok=False;break
        if ok:candidates.append((sum(F(COSTS[t]) for t in sub),sub))
    return min(candidates)

def main():
    results=[];digest=sha256()
    for pb in (F(1,2),F(1,3)):
      w=make_worlds(pb)
      direct=joint(prior_b_1=pb)
      assert {tuple(x):p for x,p in direct.items()}==w
      for cache in ({},{'z':0},{'z':1}):
        for (delta,eta) in ((F(0),F(0)),(F(1,10),F(1,10)),(F(1,4),F(1,4))):
          for test_names in [('gold','read_a','read_u'),('gold','noisy_a','read_u'),('gold','noisy_b','read_a')]:
            allow=tuple(Test(t,F(COSTS[t]),t) for t in test_names)
            solver=Solver(direct,available=allow,cache=cache,delta=delta,eta=eta)
            v=solver.solve(); solver.check_certificate()
            oracle=brute_policy_cost(w,test_names,cache,delta,eta)
            assert v==oracle,(pb,cache,delta,eta,test_names,v,oracle)
            row=[str(pb),str(cache),str(delta),str(eta),list(test_names),str(v),str(oracle)]
            digest.update((json.dumps(row,separators=(',',':'))+'\n').encode())
            results.append(row)
    # Authentication/message benchmark expectations checked independently.
    new=make_worlds()
    old=make_worlds(F(1,2))
    def u_post(worlds):
        return sum(p for w,p in worlds.items() if w[4]==1 and w[1]==1)/sum(p for w,p in worlds.items() if w[4]==1)
    assert u_post(old)==F(3,4)
    assert u_post(new)==F(15,22)
    # Shared noise: Y_a and Y_b are dependent even after exact (a,b).
    sub={w:p for w,p in new.items() if w[0]==0 and w[2]==0}
    assert sum(p for w,p in sub.items() if measure(w,'noisy_a')==1 and measure(w,'noisy_b')==1)/sum(sub.values()) == F(1,4)
    assert F(1,4)*F(1,4)!=F(1,4)
    print(json.dumps({'status':'PASS','brute_policy_comparisons':len(results),
       'digest':digest.hexdigest(), 'stale_old_posterior':'3/4',
       'correct_new_posterior':'15/22','shared_noise_joint':'1/4',
       'naive_independent_joint':'1/16'},sort_keys=True))

if __name__=='__main__':main()

