#!/usr/bin/env python3
"""Exact finite checks for the symmetric-law first-chaos budget.

NOT a proof of the universal theorem. Python standard library only.
Independent non-identical symmetric three-point scalar laws:
P(Y=+a)=P(Y=-a)=p/2; P(Y=0)=1-p.
"""
from fractions import Fraction as Q
from itertools import product
from hashlib import sha256

AMPLITUDES = (Q(1, 4), Q(1, 2), Q(1))
ACTIVITIES = (Q(0), Q(1, 4), Q(1, 2), Q(3, 4), Q(1))
SHIFTS = tuple(Q(v, 2) for v in (-4, -2, -1, 0, 1, 2, 4))
LAWS = [(((-a, p/2), (Q(0), 1-p), (a, p/2)), a, p)
        for a in AMPLITUDES for p in ACTIVITIES]

def moments(laws, shift):
    n = len(laws)
    u = Q(0)
    nums = [[Q(0)] * 3 for _ in range(n)]
    for ix in product(range(3), repeat=n):
        prob = Q(1)
        x = shift
        for i, k in enumerate(ix):
            y, p = laws[i][k]
            prob *= p
            x += y
        if prob == 0:
            continue
        s = prob * abs(x)
        u += s
        for i, k in enumerate(ix):
            nums[i][k] += s
    w1 = Q(0)
    for i in range(n):
        conditional_squared = sum(
            (nums[i][k] ** 2 / laws[i][k][1]
             for k in range(3) if laws[i][k][1]), Q(0))
        w1 += conditional_squared - u ** 2
    return u, w1

def main():
    digest = sha256()
    count = 0
    minimum = None
    worst = (Q(0), None)
    for n in (1, 2, 3):
        for choices in product(range(len(LAWS)), repeat=n):
            laws = [LAWS[idx][0] for idx in choices]
            for h in SHIFTS:
                u, w1 = moments(laws, h)
                slack = h ** 2 + u - w1  # c=1
                assert slack >= 0, (n, choices, h, u, w1, slack)
                count += 1
                minimum = slack if minimum is None else min(minimum, slack)
                if h ** 2 + u:
                    ratio = w1 / (h ** 2 + u)
                    if ratio > worst[0]:
                        worst = ratio, (n, choices, h, u, w1)
                digest.update(f"{n}|{choices}|{h}|{u}|{w1}|{slack}\n".encode())
    assert count == 25305
    assert digest.hexdigest() == "03240bfab53d9853b2a50da36187da2fcc19dbf458a7bef3e3bd375310b8d8e0"
    print("cases:", count, "min_slack:", minimum)
    print("max_ratio:", worst, "sha256:", digest.hexdigest())

if __name__ == "__main__":
    main()
