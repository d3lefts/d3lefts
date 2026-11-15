#!/usr/bin/env python3
"""Exact rational asymmetric first-chaos budget falsification audit (NOT a universal proof).

Each independent scalar Yi has values -a_i, 0, +b_i with
P(-a_i)=theta_i*b_i/(a_i+b_i), P(0)=1-theta_i,
P(+b_i)=theta_i*a_i/(a_i+b_i).
These laws are centered and bounded by c=1.
"""
from fractions import Fraction as Q
from itertools import product
from hashlib import sha256

A = (Q(1, 2), Q(1))
T = (Q(1, 2), Q(1))
H = (Q(-1), Q(-1, 2), Q(0), Q(1, 2), Q(1))
LAWS = [
    ((-a, t*b/(a+b)), (Q(0), 1-t), (b, t*a/(a+b)))
    for a, b, t in product(A, A, T)
]

def test(laws, h):
    n = len(laws)
    totals = [[Q(0)]*3 for _ in range(n)]
    u = Q(0)
    for idx in product((0, 1, 2), repeat=n):
        mass, s = Q(1), h
        for i, k in enumerate(idx):
            value, pr = laws[i][k]
            mass *= pr
            s += value
        if mass == 0:
            continue
        weight = mass*abs(s)
        u += weight
        for i, k in enumerate(idx):
            totals[i][k] += weight
    w1 = Q(0)
    for i in range(n):
        w1 += sum((
            totals[i][k]**2 / laws[i][k][1]
            for k in range(3) if laws[i][k][1]
        ), Q(0)) - u**2
    return u, w1

def main():
    count, min_slack = 0, None
    max_ratio = (Q(0), None)
    digest = sha256()
    for n in (1, 2, 3, 4):
        for key in product(range(len(LAWS)), repeat=n):
            laws = [LAWS[i] for i in key]
            for h in H:
                u, w1 = test(laws, h)
                slack = h*h + u - w1
                assert slack >= 0, (n, key, h, u, w1, slack)
                min_slack = slack if min_slack is None else min(min_slack, slack)
                if h*h + u and w1/(h*h + u) > max_ratio[0]:
                    max_ratio = (w1/(h*h + u), (n, key, h, u, w1))
                count += 1
                digest.update(f"{n}|{key}|{h}|{u}|{w1}|{slack}\n".encode())
    assert count == 23400
    assert digest.hexdigest() == "dc0ecaa84ba211849546624778343bf2f9e6cb35187b8d365d994ab96a5ce093"
    print("tested", count, "min_slack", min_slack,
          "max_ratio", max_ratio, "SHA256", digest.hexdigest())

if __name__ == "__main__":
    main()
