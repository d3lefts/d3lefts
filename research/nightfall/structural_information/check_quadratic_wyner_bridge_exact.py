#!/usr/bin/env python3
"""Exact-rational independent finite falsifier for the Q2-to-Wyner coupling bridge.

Reproduces a different finite implementation from the paper proof: direct
mass enumeration for variance/coordinate influences and monotone seed
coupling for squared mismatch Delta. A PASS does NOT certify the universal
math, source-key lemma, full Lean theorem, or global novelty.
"""
from fractions import Fraction as F
from itertools import product, combinations
from random import Random
from math import prod
import hashlib

SEED = 20261122
RNG = Random(SEED)


def pmf(p):
    n = len(p)
    return {x: prod((p[i] if x[i] else 1-p[i]) for i in range(n))
            for x in product((0, 1), repeat=n)}


def variance(prob, f):
    mean = sum((mass*f[x] for x, mass in prob.items()), F(0))
    return sum((mass*(f[x]-mean)**2 for x, mass in prob.items()), F(0))


def influence(prob, p, f, j):
    n = len(p)
    out = F(0)
    for x, mass in prob.items():
        a = list(x); a[j] = 0; y0 = tuple(a)
        a[j] = 1; y1 = tuple(a)
        fm = (1-p[j])*f[y0] + p[j]*f[y1]
        out += mass*(f[x]-fm)**2
    return out


def monotone_pair(p, q):
    # U uniform on [0,1]: X=1{U<p}, Y=1{U<q}.
    cuts = sorted({F(0), F(1), p, q})
    d = {}
    for lo, hi in zip(cuts, cuts[1:]):
        if lo == hi:
            continue
        mid = (lo+hi)/2
        key = (int(mid < p), int(mid < q))
        d[key] = d.get(key, F(0))+(hi-lo)
    assert sum(d.values(), F(0)) == 1
    return d


def coupling_mismatch(p, q, f):
    pairs = [monotone_pair(a, b) for a, b in zip(p, q)]
    ans = F(0)
    for selection in product(*[list(d.items()) for d in pairs]):
        xs = tuple(key[0] for key, pr in selection)
        ys = tuple(key[1] for key, pr in selection)
        mass = prod((pr for key, pr in selection))
        ans += mass*(f[xs]-f[ys])**2
    return ans


def run_case(n, weights, p_list, f):
    q = [sum((weights[t]*p_list[t][j] for t in range(len(weights))), F(0))
         for j in range(n)]
    probs = [pmf(p) for p in p_list]
    nu = {x: sum((weights[t]*probs[t][x] for t in range(len(weights))), F(0))
          for x in product((0, 1), repeat=n)}
    qr = pmf(q)
    delta = sum((weights[t]*coupling_mismatch(p_list[t], q, f)
                 for t in range(len(weights))), F(0))
    vn = variance(nu, f)
    vq = variance(qr, f)
    iq = [influence(qr, q, f, j) for j in range(n)]
    ip = [sum((weights[t]*influence(probs[t], p_list[t], f, j)
               for t in range(len(weights))), F(0)) for j in range(n)]

    # Squared form of |sqrt(vn)-sqrt(vq)|<=sqrt(delta).
    if vn > vq+delta:
        assert (vn-vq-delta)**2 <= 4*vq*delta
    if vq > vn+delta:
        assert (vq-vn-delta)**2 <= 4*vn*delta

    for x, y in zip(iq, ip):
        # sqrt(Iq) <= sqrt(Ip)+sqrt(2 delta).
        if x > y+2*delta:
            assert (x-y-2*delta)**2 <= 8*y*delta, (x, y, delta)
        if delta <= x/8:
            assert y >= x/4, (x, y, delta)
    return vn, vq, delta, iq, ip


def run():
    levels = [F(0), F(1, 8), F(1, 4), F(1, 2), F(3, 4), F(7, 8), F(1)]
    tests = 0
    nonzero = 0
    triggered = 0
    digest = hashlib.sha256()
    for n in (2, 3, 4):
        count = {2: 300, 3: 300, 4: 120}[n]
        coefficient_count = n+n*(n-1)//2
        for case in range(count):
            weights = [F(1, 3), F(2, 3)] if case % 2 else [F(1, 2)]*2
            p_list = [[RNG.choice(levels) for _ in range(n)] for _ in weights]
            coefficients = [RNG.choice([-1, 0, 1]) for _ in range(coefficient_count)]
            if not any(coefficients):
                coefficients[0] = 1
            f = {}
            for x in product((0, 1), repeat=n):
                signs = [2*a-1 for a in x]
                terms = [c*signs[i] for i, c in enumerate(coefficients[:n])]
                k = n
                for i, j in combinations(range(n), 2):
                    terms.append(coefficients[k]*signs[i]*signs[j])
                    k += 1
                f[x] = F(1, 2)+F(sum(terms), 2*(coefficient_count+1))
            assert all(0 <= v <= 1 for v in f.values())
            vn, vq, delta, iq, ip = run_case(n, weights, p_list, f)
            nonzero += int(delta != 0)
            triggered += sum(delta <= x/8 and x > 0 for x in iq)
            digest.update(str((n, case, vn, vq, delta, tuple(iq), tuple(ip))).encode())
            tests += 1
        print("PASS n=", n, "models=", count)

    # Exact radical guards: 100<C2<106 without floats.
    assert F(14143, 10000)**2 > 2 and F(17321, 10000)**2 > 3
    assert F(14142, 10000)**2 < 2 and F(17320, 10000)**2 < 3
    upper = (2*(1+F(14143, 10000))*F(17321, 10000)+F(11901, 6250))**2
    lower = (2*(1+F(14142, 10000))*F(17320, 10000)+F(11901, 6250))**2
    assert F(100) < lower and upper < F(106)
    for tau in (F(1, 4), F(1, 10), F(1, 100)):
        c = F(106); k = F(20)  # rational guards C2<106, K=2pi^2<20
        a = tau*tau/(32*c)
        eta = a/1024
        w0 = a/(4*k)
        ga = tau*tau/(8*c)
        gb = eta*eta*w0
        assert 2*k*w0+512*eta == a
        assert ga == tau*tau/(8*c)
        assert gb == tau**6/(2**37*k*c**3)
        assert 0 < eta < F(1, 2) and 0 < w0 < F(1)
    print("PASS", tests, "exact finite models,", nonzero,
          "nonzero mismatches,", triggered, "small-Delta influence triggers")
    print("PASS 100<C2<106 exact rational radical bounds and threshold identities")
    print("SHA256 exact model outcomes", digest.hexdigest())


if __name__ == "__main__":
    run()
