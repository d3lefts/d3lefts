#!/usr/bin/env python3
"""Exact rational finite checks for a source-coupled two-replica quadratic proxy.

This verifies finite models only. It does NOT prove a universal influence bound.
Usage: python3 -I research/nightfall/flagship-influence/check_poly_d_dyadic_proxy.py
"""
from fractions import Fraction as F
from math import comb


def pop(x): return x.bit_count()


def characters(n, coeff):
    return [sum(F(a) * (-1 if pop(x & s) % 2 else 1) for s, a in coeff.items())
            for x in range(1 << n)]


def fwht(a):
    a = list(a)
    step = 1
    while step < len(a):
        for k in range(0, len(a), 2 * step):
            for j in range(step):
                u, v = a[k + j], a[k + j + step]
                a[k + j], a[k + j + step] = u + v, u - v
        step *= 2
    return [z / len(a) for z in a]


def spectral(n, d, coeff, t):
    u = F(0)
    j = [F(0) for _ in range(n)]
    for s, a in coeff.items():
        order = pop(s)
        if order == 0: continue
        assert order <= d
        u += a*a * (order*t*(1-t)**(order-1)
                    + (comb(order, 2)*t*t*(1-t)**(order-2) if order > 1 else 0))
        for i in range(n):
            if s >> i & 1:
                j[i] += a*a * (t*(1-t)**(order-1)
                    + ((order-1)*t*t*(1-t)**(order-2) if order > 1 else 0))
    return u, j


def direct(n, fvals, t):
    size = 1 << n
    u, j = F(0), [F(0) for _ in range(n)]
    amax = F(0)
    for x in range(size):
        for y in range(size):
            differences = pop(x ^ y)
            weight = t**differences * (1-t)**(n-differences) / size
            if not weight: continue
            gvals = [fvals[(x & z) | (y & ((size-1) ^ z))]
                     for z in range(size)]
            qs = fwht(gvals)
            for s in range(1, size):
                if pop(s) in (1, 2):
                    u += weight * qs[s]*qs[s]
                    for i in range(n):
                        if s >> i & 1: j[i] += weight * qs[s]*qs[s]
            for z in range(size):
                val = sum(qs[s] * (-1 if pop(s & z) % 2 else 1)
                          for s in range(1, size) if pop(s) <= 2)
                amax = max(amax, abs(val))
    return u, j, amax


def model(n, d, coeff):
    fvals = characters(n, coeff)
    B = (max(fvals) - min(fvals)) / 2
    V = sum(a*a for s, a in coeff.items() if s)
    mi = [sum(a*a for s, a in coeff.items() if (s >> i & 1))
          for i in range(n)]
    m = max(1, (d-1).bit_length())
    ubar, jbar = F(0), [F(0) for _ in range(n)]
    A = F(0)
    for k in range(1, m+1):
        t = F(1, 1 << k)
        v, js = spectral(n, d, coeff, t)
        dv, djs, da = direct(n, fvals, t)
        assert (v, js) == (dv, djs), (n, d, k, v, dv, js, djs)
        ubar += v/m
        jbar = [a + b/m for a,b in zip(jbar, js)]
        A = max(A, da)
    assert 6*m*ubar >= V
    assert all(m*jbar[i] <= mi[i] for i in range(n))
    assert 2*A <= d*(d+2)*B
    return {'n':n, 'd':d, 'm':m, 'B':str(B), 'V':str(V),
            'U':str(ubar), 'A':str(A), 'Jmax':str(max(jbar))}


def parity_certificate(d):
    t = F(1,d)
    a = (1-t)**(d-1)
    u = F(3,2)*a
    j = F(2,d)*a
    ratio = u*u/j
    assert ratio == F(9*d,8)*a
    return ratio


if __name__ == '__main__':
    test_cases = [
        (3, 1, {1:F(2),2:F(-1),4:F(3)}),
        (4, 3, {1:F(3),2:F(-1),3:F(2),5:F(1),7:F(-2)}),
        (5, 5, {1:F(2),4:F(-3),3:F(2),21:F(-1),31:F(1)}),
        (5, 5, {31:F(1)}),
    ]
    for n,d,cs in test_cases:
        print('TWO-INDEPENDENT-FORMULAS', model(n,d,cs))
    print('EXACT PARITY SOURCE-COUPLED ANNEALED-Q2 NO-GO:')
    for d in [2,3,4,8,16,32,64,128]:
        ratio=parity_certificate(d)
        print('degree',d,'ratio U^2/(A^2 max J) >=',float(ratio),
              'exact',str(ratio) if d<=8 else '(rational exact, omitted)')
    assert parity_certificate(16) > 6
    print('PASS: finite spectral/direct equality, dyadic bounds, parity obstruction')


# v0.4: independently replay the NEW first-chaos proxy from full source-pair
# selector truth tables (not merely from Fourier/binomial formulas).

def spectral_linear(n, d, coeff, t):
    u = F(0)
    j = [F(0) for _ in range(n)]
    for s, a in coeff.items():
        order = pop(s)
        if not order:continue
        assert order<=d
        vs=t*(1-t)**(order-1)
        u+=a*a*order*vs
        for i in range(n):
            if s >> i & 1:j[i]+=a*a*vs
    return u,j

def direct_linear(n, fvals, t):
    size = 1 << n
    u,j=F(0),[F(0) for _ in range(n)]
    A=F(0)
    for x in range(size):
        for y in range(size):
            ndiff=pop(x^y)
            wt=t**ndiff*(1-t)**(n-ndiff)/size
            if not wt:continue
            vals=[fvals[(x & z) | (y & ((size-1)^z))]
                  for z in range(size)]
            cs=fwht(vals)
            for s in range(1,size):
                if pop(s)==1:
                    q=cs[s]**2
                    u+=wt*q
                    j[s.bit_length()-1]+=wt*q
            # For linear selector polynomials max_sigma abs(L)=sum_i abs(alpha_i).
            A=max(A,sum(abs(cs[1<<i]) for i in range(n)))
    return u,j,A

def test_linear_source_replay():
    cases=[
      (3,1,{1:F(2),2:F(-1),4:F(3)}),
      (4,3,{1:F(3),2:F(-1),3:F(2),5:F(1),7:F(-2)}),
      (5,5,{1:F(2),4:F(-3),3:F(2),21:F(-1),31:F(1)}),
      (5,5,{31:F(1)}),
      (4,2,{3:F(2),12:F(-3)}),
    ]
    matched=0
    for n,d,c in cases:
        vals=characters(n,c)
        B=(max(vals)-min(vals))/2
        V=sum(v*v for s,v in c.items() if s)
        M=[sum(v*v for s,v in c.items() if s>>i&1) for i in range(n)]
        m=max(1,(d-1).bit_length())
        U,Js,A=F(0),[F(0)]*n,F(0)
        for k in range(1,m+1):
            t=F(1,2**k)
            us,js=spectral_linear(n,d,c,t)
            ud,jd,ad=direct_linear(n,vals,t)
            assert (us,js)==(ud,jd),(n,d,k,us,ud,js,jd)
            U+=us/m
            Js=[x+y/m for x,y in zip(Js,js)]
            A=max(A,ad)
            matched+=1
        assert 6*m*U>=V, (n,d,'variance retention')
        assert all(m*Js[i]<=M[i] for i in range(n)),(n,d,'influence cap')
        assert A<=d*B,(n,d,'Bernstein amplitude')
    print('PASS: genuine source (X,Y) selector-table vs spectral first-chaos,',
          matched,'exact independent scale-model identities; dyadic bounds')

if __name__ == '__main__':
    test_linear_source_replay()
