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



ROUNDED_LOW_BASE = Q(2919, 2944)


def rounded_window_probe(t, precision=90):
    """Choose integer k=floor(5t/4), test mass outside prescribed [t,3t/2]."""
    assert isinstance(t, Q) and t >= 10
    k = (Q(5, 4)*t).numerator // (Q(5, 4)*t).denominator
    assert k >= 1
    assert Q(8,7)*t <= k <= Q(5,4)*t
    # e^(1/8) <= 417/368; (7/8)*(417/368) = 2919/2944.
    q=Q(1,8)
    assert 1+q+(q*q/2)/(1-q/3) == Q(417,368)
    assert Q(7,8)*Q(417,368) == ROUNDED_LOW_BASE < 1
    with localcontext() as ctx:
        ctx.prec=precision
        lo = Decimal(t.numerator)/Decimal(t.denominator)
        hi = Decimal(3)*lo/Decimal(2)
        def survival(x):
            term=Decimal(1)
            total=term
            for i in range(1,k):
                term *= x/Decimal(i)
                total += term
            return (-x).exp()*total
        outside = 1-survival(lo)+survival(hi)
        rational = ROUNDED_LOW_BASE**k + HIGH_BASE**k
        bound=Decimal(rational.numerator)/Decimal(rational.denominator)
        assert 0 <= outside <= bound, (t,k,outside,bound)
        return k, format(outside,'.12g'), format(bound,'.12g')


def main():
    a,b=constant_audit()
    print('PASS: exact exponential brackets:',a,'<= exp(1/5) <=',b)
    for k in [1,2,5,10,20,50,100,250]:
        print('PROBE k=%d: mass outside=%s; certified algebraic upper base=%s'%independent_probe(k))
    print('PASS: 8 high-precision finite-sum probes; the written analytic argument is the proof, not the probes')
    for t in [Q(10),Q(41,4),Q(11),Q(20),Q(101,4),Q(80),Q(100)]:
        print('ROUNDED t=%s: k=%s; mass outside=%s; bound=%s'%(t,*rounded_window_probe(t)))
    print('PASS: 7 prescribed-window integer-rounding probes and exact rational constant identities')


if __name__=='__main__':
    main()
