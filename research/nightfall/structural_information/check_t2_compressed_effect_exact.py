#!/usr/bin/env python3
"""Exact rational audit of centered compressed-effect two-query certificate.

Validates a high-rank *projective* terminal effect whose compression onto
attainable final states has constant trace-norm distance from a scalar.
Finite source-level evidence only, not a proof of a universal theorem.
"""
from fractions import Fraction as F
from collections import Counter

Z, ONE = F(0), F(1)
A = F(9,25)
B = F(7,25)
DILATE = F(12,25)
RHO = F(7,50)


def rows(level):
    r, width = [1], 1
    for _ in range(level):
        r = r + [x << width for x in r] + [x | (x << width) for x in r]
        width *= 2
    assert len(set(r)) == 3**level
    return [0] + r


def chi(mask, s):
    return -1 if (mask&s).bit_count() & 1 else 1


def projector(level):
    n = len(rows(level))
    C = [A+B] + [A]*(n-1)
    # w=e_0: the two N by N diagonal blocks are diagonal;
    # both off-diagonal blocks are (12/25)I.
    P = [[Z for _ in range(2*n)] for _ in range(2*n)]
    for i in range(n):
        P[i][i] = C[i]
        P[n+i][n+i] = ONE-C[i]
        P[i][n+i] = P[n+i][i] = DILATE
    assert sum((P[i][i] for i in range(2*n)), Z) == n
    for i in range(n):
        assert C[i]*(ONE-C[i]) == DILATE*DILATE
        assert C[i]*C[i] + DILATE*DILATE == C[i]
        assert (ONE-C[i])**2 + DILATE*DILATE == ONE-C[i]
    if n <= 10:  # independent brute-force matrix product
        assert all(sum((P[i][k]*P[k][j] for k in range(2*n)), Z)
                   == P[i][j] for i in range(2*n) for j in range(2*n))
    return P


def final_state(level, s):
    D = rows(level)
    n = len(D)
    psi = [F(3,5),F(4,5)] + [Z]*(n-2)
    x = [psi[i]*chi(D[i],s) for i in range(n)]
    c,sn = F(3,5), F(4,5)
    x[0],x[1] = c*x[0]-sn*x[1], sn*x[0]+c*x[1]
    x = [x[i]*chi(D[i],s) for i in range(n)]
    assert sum((v*v for v in x), Z) == ONE
    return x + [Z]*n


def check(level):
    D = rows(level)
    n = len(D)
    P = projector(level)
    assert n == 3**level+1
    counts = Counter(a^b for a in D for b in D if a!=b)
    M = max(counts.values())
    assert M == 2*level+2
    vals = []
    full = []
    for s in range(1 << (1 << level)):
        x = final_state(level,s)
        amplitude = x[0]
        direct = sum((x[i]*P[i][j]*x[j]
                      for i in (0,1) for j in (0,1)), Z)
        scalar_plus = A+B*amplitude*amplitude
        signed = F(1,2) + RHO*(x[0]**2-x[1]**2)
        assert direct == scalar_plus == signed
        assert direct == (F(5968,15625) if chi(D[1],s)==1
                          else F(16,25))
        vals.append(direct)
        full.append(x)
    # The two input parity cases span exactly e_0,e_1, hence
    # compressed P has eigenvalues 16/25, 9/25.
    assert { (x[0],x[1]) for x in full } == {
        (-F(7,25),F(24,25)), (ONE,Z)
    }
    eigen = (F(16,25),F(9,25))
    theta = min((sum((abs(v-lam) for v in eigen),Z)
                 for lam in (A,F(1,2),A+B)))
    assert theta == B and abs(eigen[0]-F(1,2)) == RHO
    assert abs(eigen[1]-F(1,2)) == RHO
    assert sum((P[i][i] for i in range(2*n)), Z) == n
    assert theta < n
    # Test signed estimator after conditioning on NO parities.
    # F is sqrt(rho)*(x0,x1): exact rational squared norms suffice.
    mean = [sum((x[i] for x in full),Z)/len(full) for i in (0,1)]
    assert mean == [F(9,25),F(12,25)]
    mse = sum((RHO*sum(((x[i]-mean[i])**2 for i in (0,1)),Z)
               for x in full),Z)/len(full)
    assert mse == F(56,625)
    # Independent Walsh coefficient calculation (nonzero character).
    coeff = [sum((full[s][i]*chi(D[1],s) for s in range(len(full))),Z)
             /len(full) for i in (0,1)]
    assert coeff == [-F(16,25), F(12,25)]
    assert mse == RHO*sum((u*u for u in coeff), Z)
    # Signed quadratic predictor is valid, Lipschitz error per secret.
    g = F(1,2) + RHO*(mean[0]**2-mean[1]**2)
    assert Z <= g <= ONE
    for f,x in zip(vals,full):
        sd = (f-g)**2
        vec = RHO*sum(((x[i]-mean[i])**2 for i in (0,1)),Z)
        assert sd <= 4*vec
    # First/second sector weights are light: nonzero-tail zero-query test.
    p0,p1 = F(9,25),F(16,25)
    q0=q1=RHO
    eta_a,eta_b=F(2,3), F(1,6)
    assert max(p0,p1) < eta_a and q0 < eta_b
    first_light = second_light = RHO
    assert first_light <= eta_a*theta
    assert second_light <= eta_b
    bound = M*(eta_a*theta+eta_b)
    assert mse <= bound
    print('PASS L=%d rows=%d high_rank=%d theta=%s trace_ratio=%s '
          'nonconstant_f=%d amplitude_mse=%s M=%d' %
          (level,n-1,n,theta,n/theta,len(set(vals)),mse,M))


if __name__ == '__main__':
    for level in (1,2,3):
        check(level)
    print('Exact tests only. No all-circuit theorem or novelty certified.')
