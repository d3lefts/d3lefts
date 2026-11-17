"""Independent rational and randomized checks for continuity obstruction.

A checker is a finite audit, never a proof. The Lean source verifies
the universal intermediate-value theorem (no sampling assumptions).
Stdlib only; deterministic seed.
"""
from fractions import Fraction
from random import Random

def poly(cs, t):
    return sum(c * t**i for i, c in enumerate(cs))

def exact_rational_tests():
    count = 0
    for p in range(1, 15):
        for q in range(-p+1, 20):
            t = Fraction(1,2)
            a = Fraction(p)+Fraction(q)*t
            b = Fraction(p)+Fraction(q)*(1-t)
            for c in range(-7,8):
                x = (t, -(1-t), Fraction(1))
                y = (-t, 1-t, Fraction(1))
                row = (a,b,Fraction(c))
                assert all(xi*xi == yi*yi for xi,yi in zip(x,y))
                assert x != y and x != tuple(-v for v in y)
                assert sum(row[i]*x[i] for i in range(3)) == c
                assert sum(row[i]*y[i] for i in range(3)) == c
                count += 1
    return count

def bisection(f):
    lo, hi = 0.0,1.0
    assert f(lo) < 0 < f(hi)
    for _ in range(80):
        t = (lo+hi)/2
        if f(t) <= 0:
            lo = t
        else:
            hi = t
    return (lo+hi)/2

def polynomial_stress_tests(N=2500, seed=1137):
    rng = Random(seed)
    max_error = 0.0
    used = 0
    for _ in range(N):
        aa = [rng.randrange(-5,6) for _ in range(4)]
        bb = [rng.randrange(-5,6) for _ in range(4)]
        cc = [rng.randrange(-5,6) for _ in range(4)]
        if poly(aa,1.0)==0 or poly(bb,0.0)==0: continue
        u = lambda t: t * poly(aa,t)
        v = lambda t: (1-t) * poly(bb,t)
        f = lambda t: u(t)**2-v(t)**2
        t = bisection(f)
        assert 0<t<1
        a,b,c=poly(aa,t),poly(bb,t),poly(cc,t)
        if abs(u(t)-v(t))<=abs(u(t)+v(t)):
            x,y=(t,-(1-t),1.0),(-t,(1-t),1.0)
        else:
            x,y=(t,(1-t),1.0),(-t,-(1-t),1.0)
        assert all(abs(xi*xi-yi*yi)<1e-15 for xi,yi in zip(x,y))
        assert x != y and x != tuple(-v for v in y)
        dx = a*x[0]+b*x[1]+c
        dy = a*y[0]+b*y[1]+c
        err=abs(dx*dx-dy*dy)
        assert err<1e-9, (aa,bb,cc,t,err)
        max_error=max(max_error,err)
        used += 1
    return used,max_error

if __name__ == "__main__":
    e=exact_rational_tests()
    n,error=polynomial_stress_tests()
    print(f"exact rational witnesses: {e}; randomized polynomial trials: {n}; max abs squared-output discrepancy: {error:.3g}")
