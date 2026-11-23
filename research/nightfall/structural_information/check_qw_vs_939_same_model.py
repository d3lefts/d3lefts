#!/usr/bin/env python3
"""Source-exact, same-model coefficient comparison: QW #1154 vs #939 paper.

Both bounds are evaluated on the same finite-alphabet law, degree-2 target,
variance threshold tau and information charge s > C_W(nu) (nats).
Extending #939's log(M) charge to the Wyner remaining-information potential
is an author-side theorem derivation, NOT a kernel-verified new result.

All computations below use Python Decimal (70-digit precision) for reproducible
COMPARISON, not interval-certified real-number proof or Lean certificates.
"""
from decimal import Decimal as D, getcontext

getcontext().prec = 70
pi = D('3.1415926535897932384626433832795028841971693993751058209749445923')
C2 = (2*(1+D(2).sqrt())*D(3).sqrt()+D(11901)/D(6250))**2
d = D(2)

# New author paper QW, PR #1154:
AQW = 16*pi**2*C2
BQW = 2**38*pi**2*C2**3

# PR #939 author paper, equation "Accounting", d=2, with log(M) replaced
# by s as a *paper* extension using PR #970's remaining Info potential:
A939 = 48*pi**4*d**2*(d+1)**4
B939 = (D('525.6')*pi**4)**3*d**6*(d+1)**12

# The old paper has a better exponent but a much larger coefficient.
seed_cross = (AQW/A939)**2
information_cross = (BQW/B939)**(D(2)/D(3))

def compare(tau):
    aq, bq = AQW/tau**2, BQW/tau**6
    ap, bp = A939/tau**(D(3)/2), B939/tau**(D(9)/2)
    # Stronger bound = lower upper estimate, not true query complexity.
    if aq <= ap and bq <= bp:
        verdict = 'QW termwise <= #939 for all s>=0'
    elif ap <= aq and bp <= bq:
        verdict = '#939 termwise <= QW for all s>=0'
    elif aq < ap and bq > bp:
        verdict = 'QW <= #939 only when 0 <= s <= %.12E' % ((ap-aq)/(bq-bp))
    else:
        verdict = '#939 <= QW only when 0 <= s <= %.12E' % ((aq-ap)/(bp-bq))
    return aq/ap, bq/bp, verdict

def run():
    assert D('105') < C2 < D('106')
    assert D('0.00012') < seed_cross < D('0.00013')
    assert D('0.0078') < information_cross < D('0.0079')
    print('C2=',C2)
    print('QW source coefficients A,B=',AQW,BQW)
    print('#939 paper coefficients A,B=',A939,B939)
    print('seed coefficient crossover=',seed_cross)
    print('information coefficient crossover=',information_cross)
    print('QW dominates BOTH terms for tau in [%.12E, 1/4]' % information_cross)
    for text_tau in ('0.25','0.1','0.01','0.005','0.001','0.0001'):
        tau=D(text_tau)
        ra, rb, verdict = compare(tau)
        print('tau=%s seed ratio=%.9f information ratio=%.9f %s'
              % (text_tau, ra, rb, verdict))
    assert compare(D('0.01'))[0] < 1 and compare(D('0.01'))[1] < 1
    assert compare(D('0.001'))[0] < 1 < compare(D('0.001'))[1]
    assert compare(D('0.0001'))[0] > 1 and compare(D('0.0001'))[1] > 1
    print('PASS source-formula arithmetical comparison; proof and priority remain separate')

if __name__ == '__main__':
    run()
