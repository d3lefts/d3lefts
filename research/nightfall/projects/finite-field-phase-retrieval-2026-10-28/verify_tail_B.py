#!/usr/bin/env python3
"""Independent symbolic and direct-sum check for the refined P11 tail."""
import sympy as S
from math import lgamma, log2, log, exp2, comb
K,N=S.symbols('K N',integer=True,positive=True)
A=S.Rational(4189,10000); C=S.Rational(46374,10000)
logq=S.Rational(369,100)*K+S.Rational(46,5)
E=S.expand(11*(A*(2*N*N-N)+C*N-2)-25+(N-1-12*K)*logq)
assert S.diff(E,N,2)>0
main=S.factor(E.subs(N,2*K))
near=S.factor(E.subs(N,2*K-1)+2*K)
far=S.factor(E.subs(N,12)+2*K)
for expr in (main,near,far):
    derivative=S.diff(expr,K)
    assert derivative.subs(K,12)<0 and S.diff(derivative,K)<0
assert main.subs(K,12)==-S.Rational(120119,1250)
assert near.subs(K,12)<-605 and far.subs(K,12)<-605
def direct_envelope(k):
    a=log2(1/(.999-.501**2))
    c=log2(3.141592653589793*2.718281828459045)+2*log2(1+2**-.5)
    ell=3.69*k+9.2
    terms=[]
    for n in range(12,2*k+1):
        g=11*(a*(2*n*n-n)+c*n-2)-lgamma(12)/log(2)+(n-1-12*k)*ell
        terms.append(log2(comb(2*k,n))+g)
    top=max(terms)
    return top+log2(sum(exp2(x-top) for x in terms))
for k in [12,13,14,16,24,32,48,64]:
    assert direct_envelope(k)<-96,k
print('PASS independent symbolic polynomial and direct-sum envelopes')
print('main:',main)
print('near:',near)
print('far:',far)
