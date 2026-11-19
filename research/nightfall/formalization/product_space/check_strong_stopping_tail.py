#!/usr/bin/env python3
"""Independent cheap finite checker for the paper-level strong-tail attempt.
Exact rational tests, then high-precision coefficient substitution.
These tests are not a universal proof or a Lean certificate.
"""
from fractions import Fraction
from decimal import Decimal, localcontext

def biased_bit_obstruction() -> None:
    p = Fraction(1,100)
    tau = Fraction(1,16)
    epsilon = Fraction(1,4)
    delta = Fraction(1,1000)
    variance = p*(1-p)
    assert variance < tau
    # The variance-stop leaf predicts the conditional mean p.
    assert abs(Fraction(1)-p)>epsilon
    assert abs(Fraction(0)-p)<=epsilon
    failure=p
    assert failure > delta
    print("PASS rare-bit obstruction: degree=1, variance",variance,
          "<tau",tau,"but failure",failure,"> target",delta)

def geometric_tail_test() -> None:
    # A geometric stopping time has uniform conditional remaining mean B.
    q=Fraction(1,17)
    B=Fraction(1,1)/q
    L=2*B
    assert L.denominator==1
    for m in range(1,16):
        # N is number of trials until success: P(N>=k)=(1-q)^(k-1).
        k=int(m*L)
        tail=(1-q)**(k-1)
        upper=Fraction(1,2)**m
        assert tail<=upper,(m,tail,upper)
    print("PASS exact geometric tail: uniform residual mean",B,
          "and P(N>=m ceil(2B))<=2^-m for m=1..15")

def parameter_arithmetic() -> None:
    with localcontext() as ctx:
        ctx.prec=65
        pi=Decimal("3.14159265358979323846264338327950288419716939937510582097494459")
        sqrt2=Decimal(2).sqrt()
        d=Decimal(2); M=Decimal(3)
        epsilon=Decimal("0.25"); delta=Decimal("0.01")
        tau=epsilon**2*delta/2
        a=3*sqrt2*pi**6*d**6*M/(tau*tau.sqrt())
        b=512*d**4*M**4/tau**3
        aa=12*pi**6*d**6*M/(epsilon**3*delta*delta.sqrt())
        bb=4096*d**4*M**4/(epsilon**6*delta**3)
        assert abs(a-aa)/a<Decimal("1e-58")
        assert abs(b-bb)/b<Decimal("1e-58")
        print("PASS Jensen drift coefficient and delta exponents:")
        print(" B(tau)=12 pi^6 d^6 M eps^-3 delta^-3/2 +4096 d^4 M^4 eps^-6 delta^-3")
        print(" The explicit block cap uses ceil(2B).")

if __name__ == "__main__":
    biased_bit_obstruction()
    geometric_tail_test()
    parameter_arithmetic()
