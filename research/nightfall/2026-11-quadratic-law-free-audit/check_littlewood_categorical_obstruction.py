#!/usr/bin/env python3
"""Exact independent falsifier: naive mixed-Littlewood transfer to categorical products.

X_0,...,X_{n-1} independent fair signs, Y independent uniform [n].
g(X,Y) = X_Y - (1/n)sum_i X_i.  This is a bounded Efron-Stein degree-2
observable with interaction stars centered in both source coordinates.

The false claimed extension would be:
    sum_i sqrt(E[h_{iY}**2]) <= sqrt(2) * ||g||_infty
The left side is sqrt(n-1), while the right side stays <=2sqrt(2).
This does NOT refute the Q2 inequality: I_Y=Var(g)=1-1/n.
"""
from fractions import Fraction as Q
from itertools import product

def audit(n):
    zero = Q(0)
    total = zero
    total_sq = zero
    max_abs = zero
    IY = zero
    IX = [zero] * n
    for signs in product((-1, 1), repeat=n):
        mean = Q(sum(signs), n)
        values = [Q(signs[y])-mean for y in range(n)]
        ev = sum(values,Q(0))/n
        varY = sum((v-ev)**2 for v in values)/n
        IY += varY / 2**n
        for y in range(n):
            prob = Q(1, n * 2**n)
            v=values[y]
            total += prob*v
            total_sq += prob*v*v
            max_abs=max(max_abs,abs(v))
            for i in range(n):
                IX[i] += prob*(Q(int(y==i))-Q(1,n))**2
    var = total_sq-total**2
    assert total == 0
    assert var == Q(n-1,n), (n,var)
    assert max_abs == Q(2*(n-1),n), (n,max_abs)
    assert IY == Q(n-1,n)
    assert all(z==Q(n-1,n*n) for z in IX)
    assert sum(IX,Q(0))==var
    # Compare after squaring, avoiding floating-point square roots.
    # (sum_i sqrt(E[h_iY²]))²=n-1; (sqrt(2)||g||∞)²=2B².
    failed_mixed_Littlewood = Q(n-1) > 2*max_abs**2
    return failed_mixed_Littlewood

if __name__=='__main__':
    for n in range(2,9):
        flag=audit(n)
        print(f"n={n} exact audit passed; naive mixed-Littlewood false={flag}")
    assert any(audit(n) for n in range(2,9))
    for n in (9,16,32,128,1024):
        assert Q(n-1) > Q(8*(n-1)**2,n*n)
    print("PASS: exact finite source model; unbounded categorical mixed-norm obstruction")
