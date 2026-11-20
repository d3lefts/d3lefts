#!/usr/bin/env python3
"""Exact-fraction falsifier/replayer for the proposed pointwise FUR lemma.

Proof remains the one-variable Markov argument in the companion note.
This script tests finite binary quadratic examples, the t-polynomial
degree drop (n to 2d), and the failure of max/expectation interchange.
No floating-point tolerance is used in passing/failing assertions.
"""
from __future__ import annotations
from fractions import Fraction as Q
from itertools import product, combinations
from random import Random
from math import comb
import hashlib
import json


def eval_poly(coeff: tuple[Q, ...], t: Q) -> Q:
    return sum((v*t**i for i, v in enumerate(coeff)), Q(0))


def multiply(left: tuple[Q, ...], right: tuple[Q, ...]) -> tuple[Q, ...]:
    out = [Q(0)] * (len(left)+len(right)-1)
    for i, a in enumerate(left):
        for j, b in enumerate(right):
            out[i+j] += a*b
    return tuple(out)


def bounded_quadratic(n: int, seed: int) -> dict[tuple[int, ...], Q]:
    rng = Random(seed)
    coeff = {
        subset: Q(rng.randrange(-5,6))
        for k in range(3) for subset in combinations(range(n), k)
    }
    raw = {}
    for bits in product((0,1), repeat=n):
        raw[bits] = sum((
            coef * Q(1 if sum(bits[i] for i in subset) % 2 == 0 else -1)
            for subset, coef in coeff.items()
        ), Q(0))
    low, high = min(raw.values()), max(raw.values())
    if low == high:
        return {x: Q(0) for x in raw}
    return {x: (v-low)/(high-low) for x, v in raw.items()}


def couple_coeffs(p: Q, diagonal_one: Q, off01: Q):
    """Four pair outcomes with affine-in-t probabilities."""
    if not (0 <= p <= 1 and 0 <= diagonal_one <= 1 and 0 <= off01 <= 1):
        raise ValueError("out-of-range coupling parameters")
    return {
        (0,0): (Q(1)-diagonal_one, -p*(Q(1)-diagonal_one)),
        (1,1): (diagonal_one, -p*diagonal_one),
        (0,1): (Q(0), p*off01),
        (1,0): (Q(0), p*(Q(1)-off01)),
    }


def moment_poly(f: dict[tuple[int, ...],Q], pairlaws) -> tuple[Q, ...]:
    n = len(pairlaws)
    ans = [Q(0)]*(n+1)
    for pairs in product(*[tuple(law) for law in pairlaws]):
        a = tuple(w[0] for w in pairs)
        b = tuple(w[1] for w in pairs)
        sq = (f[a]-f[b])**2
        if sq == 0:
            continue
        coeff = (Q(1),)
        for j,w in enumerate(pairs):
            coeff = multiply(coeff, pairlaws[j][w])
        for j,v in enumerate(coeff):
            ans[j] += sq*v
    return tuple(ans)


def direct_moment(f, pairlaws, t: Q) -> Q:
    ans = Q(0)
    for pairs in product(*[tuple(law) for law in pairlaws]):
        mass = Q(1)
        for j,w in enumerate(pairs):
            mass *= eval_poly(pairlaws[j][w],t)
        if mass < 0:
            raise AssertionError("not a bona fide coupling at test t")
        a = tuple(w[0] for w in pairs)
        b = tuple(w[1] for w in pairs)
        ans += mass*(f[a]-f[b])**2
    return ans


def trial(n: int, seed: int) -> dict:
    rng=Random(seed+50000)
    f=bounded_quadratic(n,seed)
    # eta <=1/128 ensures 32 eta <=1/4, making the bound nonvacuous.
    ps=tuple(Q(rng.randint(1,4),512) for _ in range(n))
    eta=max(ps)
    pairlaws=[
        couple_coeffs(ps[i], Q(rng.randrange(0,5),4),
                      Q(rng.randrange(0,5),4))
        for i in range(n)
    ]
    P=moment_poly(f,pairlaws)
    if P[0] != 0:
        raise AssertionError("P(0) must vanish on diagonal law")
    if any(P[i]!=0 for i in range(5,len(P))):
        raise AssertionError("squared degree-two polynomial must have t-degree<=4")
    L=1/eta
    for t in (Q(0), Q(1), L/4, L/2, 3*L/4,L):
        direct=direct_moment(f,pairlaws,t)
        if direct!=eval_poly(P,t):
            raise AssertionError("exact convolution does not match direct enumeration")
        if not (Q(0)<=direct<=Q(1)):
            raise AssertionError("moment escaped [0,1] on stretched interval")
    value=eval_poly(P,Q(1))
    assert Q(0)<=value<=min(Q(1), 32*eta)
    return {
        "n":n, "seed":seed, "max_pair_mismatch":str(eta),
        "p1":str(value), "degree":max(i for i,v in enumerate(P) if v) if any(P) else 0,
        "markov_cap":str(32*eta),
        "all_above_degree_4_zero":True,
    }


def one_hot_max_obstruction(n: int) -> dict:
    if n<2:
        raise ValueError("one-hot obstruction requires n>=2")
    # For independent uniform labels theta,theta', pair maximum TV is one
    # exactly if theta != theta', and zero otherwise.
    max_pairwise=Q(n-1,n)
    # Every fixed coordinate marginal is Ber(1/n); its entropy is h(1/n).
    fixed_coordinate_mass=Q(1,n)
    # The averaged *squared* pair TV for one fixed i is 2(n-1)/n^2.
    fixed_sq=Q(2*(n-1),n*n)
    assert max_pairwise>=Q(1,2)
    assert fixed_sq < Q(2,n)
    return {"n":n, "expected_max_pair_tv":str(max_pairwise),
            "per_coordinate_second_moment_tv":str(fixed_sq),
            "per_coordinate_bernoulli_mass":str(fixed_coordinate_mass),
            "note":"I(theta;X_i)=h(1/n) nats; max/average cannot be interchanged. NOT a FUR counterexample."}


def audit() -> dict:
    results=[trial(n, seed) for n in (2,3,4,5) for seed in range(4)]
    witness=[one_hot_max_obstruction(n) for n in (4,16,64,256)]
    return {
        "schema":"nightfall.fur.pointwise.exact.v1",
        "status":"finite-exact-tests-pass",
        "independent_formal_proof":False,
        "complete_FUR":False,
        "num_quadratic_trials":len(results),
        "trials":results,
        "one_hot_obstruction":witness,
        "claim":"Finite exact audit only. General PF(d) proof in companion Markdown uses Markov brothers inequality.",
    }


if __name__=="__main__":
    print(json.dumps(audit(),indent=2,sort_keys=True))
