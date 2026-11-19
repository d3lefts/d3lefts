#!/usr/bin/env python3
"""Independent all-world arithmetic audit of the Q2 Bernstein source family.

This checker uses exact Q(sqrt(2)) arithmetic and actual n-bit original
Bernoulli-product worlds. It does NOT reuse the Lean list recursion,
derive its moments from a CLT, or assume the universal upper inequality.
"""
from dataclasses import dataclass
from fractions import Fraction as F
from itertools import product
from math import comb

@dataclass(frozen=True)
class Quadratic:
    # a + b*sqrt(2)
    a: F
    b: F = F(0)

    def __add__(self, other):
        other = as_q(other)
        return Quadratic(self.a+other.a, self.b+other.b)

    __radd__ = __add__

    def __neg__(self):
        return Quadratic(-self.a, -self.b)

    def __sub__(self, other):
        return self + (-as_q(other))

    def __rsub__(self, other):
        return as_q(other) - self

    def __mul__(self, other):
        other = as_q(other)
        return Quadratic(self.a*other.a+2*self.b*other.b,
                         self.a*other.b+self.b*other.a)

    __rmul__ = __mul__

    def __pow__(self, exponent):
        assert isinstance(exponent, int) and exponent >= 0
        result = Quadratic(F(1))
        base = self
        while exponent:
            if exponent % 2:
                result = result * base
            base = base * base
            exponent //= 2
        return result

def as_q(x):
    if isinstance(x, Quadratic):
        return x
    return Quadratic(F(x))

def raw(n, x):
    s = sum(2*v-1 for v in x)
    return 2*s*s-n*n

def audit(n):
    assert 2 <= n <= 10
    p = Quadratic(F(1,2),F(1,4))  # (1 + 1/sqrt(2))/2
    q = 1-p
    mu = Quadratic(F(0),F(1,2))
    v = Quadratic(F(1,2))
    assert mu**2 == as_q(F(1,2))
    assert p*q == as_q(F(1,8))
    cache = [p**k*q**(n-k) for k in range(n+1)]
    words = list(product((0,1),repeat=n))
    assert sum((cache[sum(x)] for x in words), Quadratic(F(0))) == as_q(1)
    mean = sum((cache[sum(x)]*raw(n,x) for x in words), Quadratic(F(0)))
    second = sum((cache[sum(x)]*raw(n,x)**2 for x in words),
                 Quadratic(F(0)))
    variance = second-mean**2
    influences = []
    other_weights = [p**k*q**(n-1-k) for k in range(n)]
    for i in range(n):
        influence = Quadratic(F(0))
        for other in product((0,1),repeat=n-1):
            x0 = other[:i]+(0,)+other[i:]
            x1 = other[:i]+(1,)+other[i:]
            influence += p*q*other_weights[sum(other)]*(raw(n,x1)-raw(n,x0))**2
        influences.append(influence)
    assert len(set(influences)) == 1
    influence = influences[0]
    # Independent centered ANOVA decomposition:
    # f-Ef = 4(n-1)mu*sum_i(Y_i) + 4*sum_{i<j}(Y_i Y_j),
    # E Y_i=0, E Y_i²=v, with mutually orthogonal sectors.
    a = 4*(n-1)*mu
    variance_anova = n*v*a*a+16*comb(n,2)*v*v
    influence_anova = v*a*a+16*(n-1)*v*v
    assert variance == variance_anova
    assert influence == influence_anova
    assert variance == as_q(2*n*(n-1)*(2*n-1))
    assert influence == as_q(4*n*(n-1))
    assert variance.b == 0 and influence.b == 0
    b_actual = F(max(raw(n,x) for x in words)-
                 min(raw(n,x) for x in words),2)
    assert b_actual <= n*n and (b_actual == n*n) == (n % 2 == 0)
    lower = variance.a**2/(n**4*influence.a)
    assert lower == F((n-1)*(2*n-1)**2,n**3)
    assert 0 < lower < 4
    return lower, b_actual

def main():
    for n in range(2,11):
        lower, radius = audit(n)
        print(f"n={n}: C2_lower={lower} ~ {float(lower):.12f}, "
              f"physical_radius={radius}")
    # Analytic obstruction requires a separate all-n proof;
    # verified by the Lean polynomial lemma, not these finite tests.
    print("PASS Q(sqrt(2)) exact full-world product variance/influences")
    print("PASS independent centered ANOVA checks and finite-n ratio")
    print("ALL-DEGREE UPPER CONJECTURE NOT PROVED")

if __name__ == "__main__":
    main()
