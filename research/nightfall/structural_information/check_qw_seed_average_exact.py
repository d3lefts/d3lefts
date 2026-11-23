#!/usr/bin/env python3
"""Independent exact rational test of the stronger label-average QW mechanism.

Tests each n-variable quadratic f on a two-latent Bernoulli mixture with
common-reference maximal coordinate couplings encoded as discrete seeds.
The seed product U is independent; reference Q and component P_theta have
exact true marginals, including p=0,1. The tests exercise:
  Var_{theta,U}(f_theta) = Var_U(E_theta f_theta) + E_U Var_theta(f_theta)
  0 <= the residual <= the existing reference coupling error Delta.
  Inf_U,j(E_theta f_theta) <= E_theta Inf_{P_theta,j}(f).
  L_U,j(E_theta f_theta) <= E_theta L_{P_theta,j}(f).
These are finite falsifiers, not a proof of source-quantified QW or Lean.
"""
from fractions import Fraction as F
from itertools import product, combinations
from math import prod
from random import Random
from hashlib import sha256

R = Random(20261123)
LEVELS = (F(0), F(1,4), F(1,2), F(3,4), F(1))

def seed_law(q, pp):
    # Monotone maximal coupling of each Bernoulli component to q.
    cuts = sorted({F(0), F(1), q, *pp})
    out = {}
    for a, b in zip(cuts, cuts[1:]):
        if a >= b:
            continue
        mid = (a+b)/2
        key = (int(mid < q), *(int(mid < p) for p in pp))
        out[key] = out.get(key, F(0)) + b-a
    assert sum(out.values()) == 1
    return out

def f_poly(x, co):
    n = len(x)
    score = sum(co[i] * (2*x[i]-1) for i in range(n))
    for k, (i,j) in enumerate(combinations(range(n),2), n):
        score += co[k] * (2*x[i]-1) * (2*x[j]-1)
    return F(1,2) + F(score, 2*(len(co)+1))

def variance(w, f):
    m = sum((p*f(x) for x,p in w.items()), F(0))
    return sum((p*(f(x)-m)**2 for x,p in w.items()), F(0))

def increment(w, law_j, f, j, squared):
    ans = F(0)
    for x,p in w.items():
        for a,r in law_j.items():
            y = list(x)
            y[j] = a
            diff = f(x) - f(tuple(y))
            ans += p*r*(diff*diff/2 if squared else abs(diff))
    return ans

def case(n, weights, pp, co):
    qm = [sum((weights[t]*pp[t][j] for t in range(2)), F(0)) for j in range(n)]
    kernels = [seed_law(qm[j], [pp[t][j] for t in range(2)]) for j in range(n)]
    words = list(product((0,1),repeat=n))
    original = [{x:prod((pp[t][j] if x[j] else 1-pp[t][j] for j in range(n)))
                 for x in words} for t in range(2)]
    mixture = {x:sum((weights[t]*original[t][x] for t in range(2)),F(0))
               for x in words}
    seed = {u:prod((kernels[j][u[j]] for j in range(n)))
            for u in product(*[tuple(k.keys()) for k in kernels])}
    assert sum(seed.values()) == 1
    f = lambda x: f_poly(x,co)
    mean = lambda u: sum((weights[t]*f(tuple(u[j][t+1] for j in range(n)))
                          for t in range(2)),F(0))
    delta = sum((mass*weights[t] *
                 (f(tuple(u[j][t+1] for j in range(n))) -
                  f(tuple(u[j][0] for j in range(n))))**2
                 for u,mass in seed.items() for t in range(2)),F(0))
    mixvar, avgvar = variance(mixture,f), variance(seed,mean)
    residual = sum((mass*sum((weights[t]*
                (f(tuple(u[j][t+1] for j in range(n)))-mean(u))**2
                 for t in range(2)),F(0)) for u,mass in seed.items()),F(0))
    assert mixvar == avgvar + residual
    assert 0 <= residual <= delta
    for j in range(n):
        ip = sum((weights[t]*increment(original[t],
                    {0:1-pp[t][j],1:pp[t][j]},f,j,True) for t in range(2)),F(0))
        lp = sum((weights[t]*increment(original[t],
                    {0:1-pp[t][j],1:pp[t][j]},f,j,False) for t in range(2)),F(0))
        assert increment(seed,kernels[j],mean,j,True) <= ip
        assert increment(seed,kernels[j],mean,j,False) <= lp
    return mixvar,avgvar,delta,residual

def run():
    digest = sha256()
    total, mismatch, coordinate_checks = 0,0,0
    for n, count in ((2,200),(3,250),(4,40)):
        for k in range(count):
            weights = (F(1,2),F(1,2)) if R.randrange(2) else (F(1,3),F(2,3))
            pp = tuple(tuple(R.choice(LEVELS) for _ in range(n)) for _ in range(2))
            co = tuple(R.choice((-1,0,1)) for _ in range(n+n*(n-1)//2))
            if not any(co):
                co = (1,) + co[1:]
            vals = case(n,weights,pp,co)
            digest.update(str((n,k,weights,pp,co,vals)).encode())
            mismatch += vals[2] > 0
            total += 1
            coordinate_checks += n*2
        print('PASS n =',n,'cases =',count)
    assert total == 490 and coordinate_checks == 2620
    print('PASS',total,'independent exact mixture tests,',mismatch,
          'nonzero Delta,',coordinate_checks,'quadratic/Jensen coordinate checks')
    print('SHA256 audit outcomes',digest.hexdigest())

if __name__ == "__main__":
    run()
