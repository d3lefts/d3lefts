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
