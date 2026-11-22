#!/usr/bin/env python3
"""Exact rational constants and independent numerical probes for the gamma window.

NOT a formal proof or an RH/GRH certificate. Proof is in GAMMA_WINDOW_LOCALIZATION.md.
"""
from fractions import Fraction as Q
from decimal import Decimal, localcontext

LOW_BASE = Q(171, 175)
HIGH_BASE = Q(60, 61)


def constant_audit():
    t = Q(1, 5)
    exp_lower = 1 + t + t*t/2
    exp_upper = 1 + t + (t*t/2)/(1-t/3)
    assert exp_lower == Q(61, 50)
    assert exp_upper == Q(171, 140)
    assert Q(4,5)*exp_upper == LOW_BASE
    assert Q(6,5)/exp_lower == HIGH_BASE
    assert 0 < LOW_BASE < 1 and 0 < HIGH_BASE < 1
    return exp_lower, exp_upper


def independent_probe(k, precision=90):
    """Gamma(k,1) tails via finite Poisson sum, not integration or a model fit."""
    with localcontext() as ctx:
        ctx.prec=precision
        xlo = Decimal(4*k)/Decimal(5)
        xhi = Decimal(6*k)/Decimal(5)
        def tail(x):
            term=Decimal(1)
            summation=term
            for i in range(1,k):
                term *= x/Decimal(i)
                summation += term
            return (-x).exp()*summation
        # P(Z<=4k/5) plus P(Z>=6k/5).
        lower = Decimal(1)-tail(xlo)
        upper = tail(xhi)
        total = lower+upper
        rational = LOW_BASE**k + HIGH_BASE**k
        bound = Decimal(rational.numerator)/Decimal(rational.denominator)
        assert total >=0 and total <= bound, (k,total,bound)
        return k,format(total,'.12g'),format(bound,'.12g')


def main():
    a,b=constant_audit()
    print('PASS: exact exponential brackets:',a,'<= exp(1/5) <=',b)
    for k in [1,2,5,10,20,50,100,250]:
        print('PROBE k=%d: mass outside=%s; certified algebraic upper base=%s'%independent_probe(k))
    print('PASS: 8 high-precision finite-sum probes; the written analytic argument is the proof, not the probes')


if __name__=='__main__':
    main()
