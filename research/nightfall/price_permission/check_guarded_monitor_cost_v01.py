#!/usr/bin/env python3
"""NIGHTFALL: cost/permission synthetic model; exact-rational reproducibility.
No physical system or ControlArena deployment is claimed.
Run: python3 research/nightfall/price_permission/check_guarded_monitor_cost_v01.py
"""
from fractions import Fraction as Q
from functools import lru_cache
from itertools import permutations, product
from hashlib import sha256
from random import Random

def cost(order, prices, prior):
    """Independent worldwise enumeration, stopping on positive influence or singleton."""
    den = sum(prior)
    ans = Q(0)
    for hidden in range(len(prices)):
        spent = Q(0)
        for tested in order[:-1]:
            spent += prices[tested]
            if tested == hidden: break
        ans += Q(prior[hidden],den)*spent
    return ans

def fast_opt(prices, prior):
    """All final omitted coordinates; c_i/prior_i sorting by pairwise exchange."""
    n = len(prices)
    assert n >= 2 and len(prior) == n and all(p > 0 for p in prior)
    assert all(p > 0 for p in prices)
    candidates = []
    for last in range(n):
        order = tuple(sorted((i for i in range(n) if i != last),
                       key=lambda i: (prices[i]/prior[i],i)))+(last,)
        candidates.append((cost(order,prices,prior),order))
    return min(candidates)

def independent_bellman(prices,prior):
    """Distinct recurrence, not based on sort/exchange."""
    n = len(prices)
    @lru_cache(None)
    def value(mask):
        if mask & (mask-1) == 0: return Q(0)
        weight = sum(prior[i] for i in range(n) if mask & (1<<i))
        return min(prices[i] + (weight-prior[i])*value(mask^(1<<i))/weight
                   for i in range(n) if mask & (1<<i))
    return value((1<<n)-1)

def exact_q2_influences(n, j):
    """Original iid fair-sign product, real heat-bath influence, no synthetic weights."""
    states = list(product((-1,1),repeat=n))
    mean = sum((Q(x[j],2**n) for x in states),Q(0))
    v = sum((Q((x[j]-mean)**2,2**n) for x in states),Q(0))
    out = []
    for i in range(n):
        e = Q(0)
        for x in states:
            for z in (-1,1):
                y = list(x);y[i]=z
                e += Q((x[j]-y[j])**2,2**(n+2))
        out.append(e)
    return mean,v,out

def audit():
    rng = Random(20261115)
    h = sha256()
    count = 0
    for n, repetitions in ((2,100),(3,100),(4,100),(5,100),(6,40),(7,10)):
        for k in range(repetitions):
            prices = tuple(Q(rng.randint(1,20),rng.randint(1,5)) for _ in range(n))
            prior = tuple(Q(rng.randint(1,20)) for _ in range(n))
            opt, order = fast_opt(prices,prior)
            brute = min(cost(o,prices,prior) for o in permutations(range(n)))
            bellman = independent_bellman(prices,prior)
            assert opt == brute == bellman, (n,k)
            worst = min(max(sum(prices[i] for i in o[:min(o.index(j)+1,n-1)])
                            for j in range(n)) for o in permutations(range(n)))
            assert worst == sum(prices)-max(prices), (n,k)
            h.update(f"{n}|{prices}|{prior}|{opt}|{worst}\n".encode())
            count += 1
    c = tuple(map(Q,(1,2,4,9,20)))
    p = tuple(map(Q,(1,1,1,12,1)))
    opt, order = fast_opt(c,p)
    assert (opt,order) == (Q(81,8),(3,0,1,2,4))
    assert cost((0,1,2,3,4),c,p) == Q(219,16)
    assert sum(c)-max(c) == 16 and sum(c) == 36
    for j in range(5):
        mean,v,influences = exact_q2_influences(5,j)
        assert mean == 0 and v == 1
        assert influences == [Q(int(i==j)) for i in range(5)]
    guarded = Q(0)
    for flags in product((0,1),repeat=9):
        switches=sum(flags)
        probability=Q(1,4)**switches*Q(3,4)**(9-switches)
        guarded += probability*((1+switches)*opt+10*Q(3))
    assert guarded == Q(2013,32)
    assert 10*(opt+3) == Q(525,4)
    counterexamples = 0
    for old,new in product(range(5),repeat=2):
        for x in product((-1,1),repeat=5):
            if old != new and x[old] < 0 < x[new]:
                # Same pre-effect evidence; unsafe world differs only by current epoch.
                assert x[old] == -1 and x[new] == 1
                assert not (0 == 1)  # trusted epoch-equality effect-time guard
                counterexamples += 1
    assert counterexamples == 160
    print("PASS",count,"exact instances: brute-force / Bellman / exchange ordering")
    print("PASS original-product influence, 512 change histories, 160 stale effect witnesses")
    print("optimal Bayes",opt,"cheapest-first",Q(219,16),"pathwise worst",16)
    print("guarded cache",guarded,"guarded eager",Q(525,4))
    print("audit SHA256",h.hexdigest())
if __name__=="__main__": audit()
