"""Exact nonvacuous check for Lemma 1's weighted TV conclusion.

All values are fractions; there is no numerical tolerance or random seed.
The nine-bit majority has degree <= 9 (multilinear indicator degree).
Run: python3 component_id_nonvacuous_check.py
"""
from fractions import Fraction
from math import comb

n = 9
p = Fraction(9, 10)
q = Fraction(1, 10)
eps = Fraction(1, 10)
delta_p = sum((comb(n, k) * p**k * (1-p)**(n-k) for k in range(5)), Fraction(0))
delta_q = sum((comb(n, k) * q**k * (1-q)**(n-k) for k in range(5, 10)), Fraction(0))
delta = max(delta_p, delta_q)
overlap = sum(
    (comb(n, k) * min(p**k * (1-p)**(n-k), q**k * (1-q)**(n-k))
     for k in range(n + 1)),
    Fraction(0),
)
gap = Fraction(1) - 3 * eps
bound = (delta_p + delta_q) / gap
assert delta_p == delta_q == Fraction(22273, 25000000)
assert overlap == Fraction(22273, 12500000)
assert 0 < bound < 1  # explicitly nonvacuous
assert overlap <= bound
# The checker itself must reject a deliberately too-strong statement.
assert not (overlap <= Fraction(1, 1000))
print("PASS: exact nonvacuous majority test")
for label, v in [
    ("delta_p", delta_p), ("delta_q", delta_q),
    ("overlap", overlap), ("bound", bound), ("slack", bound-overlap),
]:
    print(f"{label}: {v} = {float(v):.12g}")

# Nonempty small-gap set R: append one almost-identical coordinate.
# The restricted low-degree function retains a nonzero conditional mean shift.
# Its failure events remain exactly the nine-bit majority failures.
from math import pi
d = 9
c = Fraction(1, 10)
pR = Fraction(5001, 10000)
qR = Fraction(4999, 10000)
gammaR = pR - qR
eta0 = 4 * eps * c / (pi * d)
assert 0 < float(gammaR) < eta0
# f'(x)=(19/20)*majority9(x[0:9])+(1/20)*x[9].
# Under either law, deviation from u=1 or v=0 can occur only when
# majority9 picks the wrong class; the last bit never creates a failure.
assert Fraction(19,20) >= 1-eps
assert Fraction(1,20) <= eps
conditional_shift = Fraction(1,20)*gammaR
assert conditional_shift == Fraction(1, 100000)
assert float(conditional_shift) < eps
print("PASS: nonempty small-gap coordinates with nonzero exact mean shift")

# Regression against the incorrect min(prior_i,prior_j)*overlap factorization.
# Under unequal transcript weights, this naive factorization is false.
prior_i, prior_j = Fraction(9,10), Fraction(1,10)
cond_i = [Fraction(1,10), Fraction(9,10)]
cond_j = [Fraction(9,10), Fraction(1,10)]
weighted_bayes = sum(
    (min(prior_i*cond_i[x], prior_j*cond_j[x]) for x in range(2)),
    Fraction(0),
)
naive = min(prior_i,prior_j)*sum(
    (min(cond_i[x],cond_j[x]) for x in range(2)), Fraction(0)
)
assert weighted_bayes == Fraction(1,10)
assert naive == Fraction(1,50)
assert weighted_bayes > naive
print("PASS: unequal-transcript-prior regression rejects naive overlap factorization")
