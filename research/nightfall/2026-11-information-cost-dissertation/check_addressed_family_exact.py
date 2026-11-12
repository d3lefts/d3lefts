#!/usr/bin/env python3
"""Exact finite falsification for the n=2 addressed family (not universal proof).

Enumerates every 3-valued function on 2*2^2=8 full inputs, computing the
optimal distance to all proper f_theta and the two-sample rejection probability
by literal enumeration, not by substituting the analytic m_k formula.
Only Python standard library is used. No random seed.
"""

from fractions import Fraction
from itertools import product


def main() -> None:
    n = 2
    signs = (-1, 1)
    domain = [(k, z) for k in range(n) for z in product(signs, repeat=n)]
    assert len(domain) == 8
    proper = []
    for theta in product(signs, repeat=n):
        proper.append(tuple(theta[k] * z[k] for k, z in domain))

    cases = 0
    failures = 0
    min_slack = None
    ties = 0
    for values in product((-1, 0, 1), repeat=len(domain)):
        val = dict(zip(domain, values))
        distance = min(
            sum((val[x] - g[i]) ** 2 for i, x in enumerate(domain))
            * Fraction(1, len(domain))
            for g in proper
        )
        # literal direct sum over K, Z and independently sampled Z'
        reject = Fraction(0)
        for k in range(n):
            zs = list(product(signs, repeat=n))
            for z in zs:
                for zp in zs:
                    g = z[k] * val[(k, z)]
                    gp = zp[k] * val[(k, zp)]
                    if g * gp < 1:
                        reject += Fraction(1, n * len(zs) ** 2)

        slack = 4 * reject - distance
        cases += 1
        failures += slack < 0
        if min_slack is None or slack < min_slack:
            min_slack, ties = slack, 1
        elif slack == min_slack:
            ties += 1
    assert cases == 3 ** len(domain) == 6561
    assert failures == 0, f"found {failures} tester counterexamples"
    assert min_slack == 0
    print(
        "PASS addressed-two-sample n=2 "
        f"trivalent_models={cases} violations={failures} "
        f"minimum_exact_slack={min_slack} equality_cases={ties}"
    )


if __name__ == "__main__":
    main()
