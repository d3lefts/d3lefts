#!/usr/bin/env python3
"""Exact finite posterior-closure and ANOVA-drift attack for rank-2 leaf selectors.

This is a finite rational test, not a proof of the imported l1 quadratic lemma.
"""
from fractions import Fraction as Q
from itertools import product, combinations

DOMAINS = ((-1, 1), (-1, 1), (0, 1, 2), (0, 1, 2))
LAWS = ((Q(2, 3), Q(1, 3)), (Q(3, 4), Q(1, 4)),
        (Q(1, 2), Q(1, 3), Q(1, 6)), (Q(1, 2), Q(1, 4), Q(1, 4)))
FEATURES = (((1, -1, -1), (0, 1, -2)), ((1, -1, -1), (0, 1, -1)))
assert all(sum(p * v for p, v in zip(LAWS[2+k], feature)) == 0
           for k in range(2) for feature in FEATURES[k])


def h(s):
    x, y = s[0], s[1]
    return Q(2 + x - 3*y + 2*x*y, 12)


def coeff(k, a, s):
    x, y = s[0], s[1]
    vals = ((3, 1, 2, -1), (1, -2, 0, 3),
            (-1, 2, 1, 2), (2, 0, -2, 1))
    c, u, v, w = vals[2*k+a]
    return Q(c + u*x + v*y + w*x*y, 12)


def G(k, s):
    return sum((coeff(k, a, s)*FEATURES[k][a][s[2+k]]
                for a in range(2)), Q(0))


def f(s):
    return h(s) + G(0, s) + G(1, s)


JOINT = []
for s in product(*DOMAINS):
    p = Q(1)
    for i, z in enumerate(s):
        p *= LAWS[i][DOMAINS[i].index(z)]
    JOINT.append((s, p, f(s)))
B = max(abs(z) for _, _, z in JOINT)


def posterior(t):
    rows = [(s, p, z) for s, p, z in JOINT
            if all(s[i] == v for i, v in t.items())]
    mass = sum((p for _, p, _ in rows), Q())
    return [(s, p/mass, z) for s, p, z in rows]


def stats(t):
    rows = posterior(t)
    avg = sum((p*z for _, p, z in rows), Q())
    var = sum((p*(z-avg)**2 for _, p, z in rows), Q())
    inf = {}
    for i in range(4):
        if i in t:
            continue
        group = {}
        for s, p, z in rows:
            key = s[:i] + s[i+1:]
            a, b, c = group.get(key, (Q(), Q(), Q()))
            group[key] = (a+p, b+p*z, c+p*z*z)
        inf[i] = sum((c - b*b/a for a, b, c in group.values()), Q())
    return var, inf


def check_structure(t):
    # After leaf observation, its section becomes a degree-2 control term;
    # any remaining leaf term stays in the same fixed 2-d feature span.
    for s, _, z in posterior(t):
        base = h(s) + sum(G(k, s) for k in range(2) if k+2 in t)
        leaves = sum(G(k, s) for k in range(2) if k+2 not in t)
        assert z == base + leaves
        assert abs(base) <= B  # Posterior conditional mean over remaining leaves.


def main():
    transcripts = []
    for mask in range(16):
        obs = [i for i in range(4) if mask & (1 << i)]
        for vals in product(*(DOMAINS[i] for i in obs)):
            transcripts.append(dict(zip(obs, vals)))
    drift_checks = 0
    for t in transcripts:
        check_structure(t)
        var, inf = stats(t)
        assert var >= 0
        T = sum(inf.values(), Q())
        assert var <= T <= 3*var, (t, var, T)
        for i, Ii in inf.items():
            expectation = Q()
            for v, p in zip(DOMAINS[i], LAWS[i]):
                t2 = dict(t)
                t2[i] = v
                _, next_inf = stats(t2)
                expectation += p * sum(next_inf.values(), Q())
            assert expectation == T - Ii, (t, i, T, Ii, expectation)
            drift_checks += 1
    print('PASS: exact posterior-closed rank-two model, transcripts:', len(transcripts))
    print('PASS: exact conditional ANOVA potential drift checks:', drift_checks)
    print('SCOPE: finite algebra, NOT proof of Q2 or universal theorem')


if __name__ == '__main__':
    main()
