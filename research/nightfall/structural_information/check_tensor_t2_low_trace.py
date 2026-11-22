#!/usr/bin/env python3
"""Exact rational audit of low-trace two-query amplitude truncation.

Independent finite checks for rank-one and rank-two final projectors with
genuinely mixing intermediate unitaries. Not a general quantum proof.
"""
from fractions import Fraction as F
from collections import Counter


def rows(L):
    r, width = [1], 1
    for _ in range(L):
        r = r + [v << width for v in r] + [v | (v << width) for v in r]
        width *= 2
    return [0] + r


def rotate(v, i, j):
    z = v[:]
    z[i] = F(3, 5)*v[i] - F(4, 5)*v[j]
    z[j] = F(4, 5)*v[i] + F(3, 5)*v[j]
    return z


def orthobasis(n, offset):
    cols = [[F(i == j) for i in range(n)] for j in range(n)]
    seq = list(range(n-1)) + list(range(n-2, -1, -1))
    for z in seq:
        i = (z+offset) % n
        j = (i+1) % n
        cols = [rotate(col, i, j) for col in cols]
    assert all(sum(a*b for a, b in zip(x,y)) == F(i == j)
               for i,x in enumerate(cols) for j,y in enumerate(cols))
    return cols


def dot(x,y):
    return sum((a*b for a,b in zip(x,y)), F(0))


def chi(a,s):
    return -1 if ((a&s).bit_count() % 2) else 1


def gf2_span(rows_):
    W = {0}
    for r in rows_:
        W |= {x ^ r for x in tuple(W)}
    return W


def audit(L, rank):
    D = rows(L)
    n = len(D)
    Ucols = orthobasis(n, 1)
    psi = orthobasis(n, 2)[0]
    w = orthobasis(n, 3)[:rank]
    p = [v*v for v in psi]
    q = [sum(v[b]*v[b] for v in w) for b in range(n)]
    assert sum(p) == 1 and sum(q) == rank
    c = [[[w[k][b]*Ucols[a][b]*psi[a] for b in range(n)]
          for a in range(n)] for k in range(rank)]
    # Deliberately coarse thresholds keep a nonzero tail at L=2.
    theta_a = F(1,5)
    theta_b = F(1,5)
    Ha = {a for a in range(n) if p[a] >= theta_a}
    Hb = {b for b in range(n) if q[b] >= theta_b}
    H = gf2_span([D[j] for j in Ha | Hb])
    M = max(Counter(D[a] ^ D[b] for a in range(n)
                    for b in range(n) if a != b).values())
    assert M == 2*L+2
    num_secrets = 2**(2**L)
    values = {}
    for s in range(num_secrets):
        z = [sum((c[k][a][b]*chi(D[a]^D[b],s)
                  for a in range(n) for b in range(n)),F(0))
             for k in range(rank)]
        # An independent direct-circuit calculation, no Fourier expansion.
        initial = [psi[a]*chi(D[a],s) for a in range(n)]
        transformed = [sum((Ucols[a][b]*initial[a]
                            for a in range(n)),F(0))
                       for b in range(n)]
        queried = [transformed[b]*chi(D[b],s) for b in range(n)]
        direct = [dot(w[k],queried) for k in range(rank)]
        assert z == direct
        values[s] = z
        assert sum(x*x for x in z) <= 1
    coef = {}
    for k in range(rank):
        arr = {}
        for a in range(n):
            for b in range(n):
                zz = D[a]^D[b]
                arr[zz] = arr.get(zz,F(0))+c[k][a][b]
        coef[k] = arr
        # Independent Walsh transform over every hidden secret.
        for zz in range(2**(2**L)):
            brute = sum((values[s][k]*chi(zz,s)
                         for s in range(num_secrets)),F(0))/num_secrets
            assert brute == arr.get(zz,F(0))
    amps = {}
    for s in range(num_secrets):
        amps[s] = [sum((v*chi(zz,s) for zz,v in coef[k].items()
                        if zz in H),F(0)) for k in range(rank)]
    # Recompute conditional expectation by explicit matching observations.
    groups = {}
    for s in range(num_secrets):
        key = tuple(chi(D[i],s) for i in sorted(Ha|Hb))
        groups.setdefault(key,[]).append(s)
    for idxs in groups.values():
        cond = [sum((values[s][k] for s in idxs),F(0))/len(idxs)
                for k in range(rank)]
        assert all(amps[s] == cond for s in idxs)
    mean_sq = sum((sum((x-y)**2 for x,y in zip(values[s],amps[s]))
                   for s in values),F(0))/num_secrets
    parseval = sum((v*v for k in range(rank)
                    for z,v in coef[k].items() if z not in H),F(0))
    assert mean_sq == parseval
    pair_energy = sum((c[k][a][b]**2 for k in range(rank)
                       for a in range(n) for b in range(n)
                       if D[a]^D[b] not in H),F(0))
    assert mean_sq <= M*pair_energy
    first_light = sum((c[k][a][b]**2 for k in range(rank)
                       for a in range(n) if a not in Ha
                       for b in range(n)),F(0))
    second_light = sum((c[k][a][b]**2 for k in range(rank)
                        for a in range(n) for b in range(n)
                        if b not in Hb),F(0))
    assert first_light <= theta_a*rank
    assert second_light <= theta_b
    assert pair_energy <= first_light + second_light
    assert pair_energy <= theta_a*rank + theta_b
    for s,z in amps.items():
        assert sum(x*x for x in z) <= 1
        f = sum(x*x for x in values[s])
        g = sum(x*x for x in z)
        assert 0 <= f <= 1 and 0 <= g <= 1
        assert (f-g)**2 <= 4*sum((x-y)**2
                                  for x,y in zip(values[s],z))
    if L == 2:
        assert mean_sq > 0
    print("PASS", {"L": L, "rank": rank, "rows": n-1,
                   "queried_rows": len(Ha|Hb)-int(0 in Ha|Hb),
                   "M": M, "secrets": num_secrets,
                   "amplitude_mse": str(mean_sq),
                   "bound": str(M*(theta_a*rank+theta_b))})


if __name__ == "__main__":
    for L in (1,2):
        for k in (1,2):
            audit(L,k)
