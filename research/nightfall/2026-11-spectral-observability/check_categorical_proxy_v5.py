#!/usr/bin/env python3
"""Independent exact-fraction audit of the v5 categorical proxy rate repair.

No third-party packages. Exhaustive fair-sign orientations for positive
rational probability laws with exact rational square roots. All arithmetic
claims checked below are equality or inequality over Fraction.
Finite tests do not certify the manuscript's analytic Chebyshev extension.
"""
from fractions import Fraction as Q
from itertools import product
import json


def positive_rational_sphere(m):
    """Stereographic rational point: w_i>0 and sum(w_i**2)=1."""
    assert m >= 2
    t = [Q(1, m + 1)] * (m - 1)
    norm = sum((a*a for a in t), Q(0))
    w = [2*a/(1+norm) for a in t] + [(1-norm)/(1+norm)]
    assert all(a > 0 for a in w)
    assert sum((a*a for a in w), Q(0)) == 1
    return w


def signed_proxy(w, eps):
    p = [a*a for a in w]
    S = sum((a*e for a, e in zip(w, eps)), Q(0))
    Z = [pi + a*e - pi*S for pi, a, e in zip(p, w, eps)]
    return S, Z


def finite_moment_audit(m):
    w = positive_rational_sphere(m)
    p = [a*a for a in w]
    mean = [Q(0)] * m
    second = [[Q(0)] * m for _ in range(m)]
    count = 0
    for eps in product((-1, +1), repeat=m):
        S, Z = signed_proxy(w, eps)
        assert sum(Z, Q(0)) == 1
        weighted_square = sum((z*z/pi for z, pi in zip(Z, p)), Q(0))
        assert weighted_square == 1 + m - S*S
        l1 = sum((abs(z) for z in Z), Q(0))
        assert l1*l1 <= weighted_square
        assert l1 <= 1 + 2*sum(w, Q(0))
        for i in range(m):
            mean[i] += Z[i]
            for j in range(m):
                second[i][j] += Z[i]*Z[j]
        count += 1
    assert count == 2**m
    assert all(mean[i]/count == p[i] for i in range(m))
    assert all(second[i][j]/count == (p[i] if i == j else 0)
               for i in range(m) for j in range(m))
    return count


def categorical_multilinear_audit(m):
    """Directly compare genuine I_0 to proxy E||H_0(Z_1,Z_2)||_2^2."""
    w = positive_rational_sphere(m)
    p = [a*a for a in w]
    al = list(range(m))
    def f(a, b, c):
        return Q(1 + 2*a + 3*b + 5*c + 4*a*b - 2*a*c +
                 b*c + a*b*c, 17 + 3*m)
    diff = {}
    for a, b, c in product(al, repeat=3):
        avg = sum((p[a2]*f(a2,b,c) for a2 in al), Q(0))
        diff[a,b,c] = f(a,b,c)-avg
    genuine = sum((p[b]*p[c]*sum((p[a]*diff[a,b,c]**2 for a in al),Q(0))
                   for b,c in product(al,repeat=2)), Q(0))
    z_all = [signed_proxy(w,eps)[1] for eps in product((-1,+1),repeat=m)]
    proxy_sum = Q(0)
    for zb, zc in product(z_all, repeat=2):
        squared = Q(0)
        for a in al:
            section = sum((zb[b]*zc[c]*diff[a,b,c]
                           for b,c in product(al,repeat=2)),Q(0))
            squared += p[a]*section*section
        proxy_sum += squared
    assert genuine == proxy_sum/len(z_all)**2
    return len(z_all)**2


def sorted_tail_audit():
    count=0
    for n in range(2,23):
        weights=sorted([Q(1+((17*i*i+7*n)%37), 100+3*n)
                        for i in range(n)],reverse=True)
        A=sum(weights,Q(0))
        for q in range(1,n):
            residual=sum((b*b for b in weights[q:]),Q(0))
            assert residual <= A*A/(4*q)
            count+=1
    for q in range(1,21):
        b=Q(1,2*q)
        weights=[b]*(2*q)
        A=sum(weights,Q(0))
        assert sum((x*x for x in weights[q:]),Q(0)) == A*A/(4*q)
    return count


def main():
    patterns=sum(finite_moment_audit(m) for m in range(2,9))
    multilinear=sum(categorical_multilinear_audit(m) for m in range(2,5))
    tails=sorted_tail_audit()
    # T_2(x)=2*x^2-1: exact d=3, m=16 improvement.
    old=2*(16+1)**2-1
    corrected=2*(16+1)-1
    assert (old, corrected)==(577,33)
    assert old**2 > 300*corrected**2
    print(json.dumps({
        "status":"PASS",
        "signed_proxy_patterns":patterns,
        "multilinear_proxy_orientations":multilinear,
        "sorted_tail_instances":tails,
        "sharp_equal_tail_cases":20,
        "old_T2_m16":old,
        "corrected_T2_m16":corrected,
        "squared_budget_ratio_exact":str(Q(old*old,corrected*corrected)),
        "scope":"independent exact finite falsification, not all-law proof"
    },indent=2))


if __name__=="__main__":
    main()
