#!/usr/bin/env python3
"""Independent finite exact regression for Route1 moment/tail envelopes.

No imports of parent PR #988 checker. Algebraic identities use Fraction;
numerical Hoeffding inequality is only a sampled regression, not a proof.
"""
from fractions import Fraction as F
from math import comb, ceil, exp, log


def law(n, k, conditioned):
    if conditioned and k % 2:
        return F(0)
    return F(comb(n, k), 2 ** (n - int(conditioned)))


def bernstein_step(m, r, z):
    return sum((F(comb(m,j)) * z**j * (1-z)**(m-j)
                for j in range(r,m+1)), F(0))


def moment(n, j, conditioned):
    return sum((law(n,k,conditioned) * F(n-k,n)**(2*j)
                for k in range(n+1)), F(0))


def poly_expectation(n, m, r, conditioned):
    return sum((law(n,k,conditioned) *
                bernstein_step(m,r,F(n-k,n)**2)
                for k in range(n+1)), F(0))


def tail(n, threshold, conditioned, inclusive):
    return sum((law(n,k,conditioned) for k in range(n+1)
                if (F(n-k,n)**2 >= threshold if inclusive
                    else F(n-k,n)**2 > threshold)), F(0))


def run():
    tested=0
    # n=2m+1, independent signs Q versus even-parity conditioned nu:
    # all n-1 marginals agree, so moment orders j<=m of f^2 agree
    # for f = fraction of +1 signs, t=0, interaction degree d=1.
    for m in (1,2,3,4,6,8):
        n=2*m+1
        for j in range(m+1):
            assert moment(n,j,True) == moment(n,j,False)
            tested+=1
        a,g=F(3,10),F(2,5)
        r=ceil(m*(a+g/2))
        assert poly_expectation(n,m,r,True) == poly_expectation(n,m,r,False)
        tested+=1
        for znum in range(33):
            z=F(znum,32)
            p=bernstein_step(m,r,z)
            assert 0 <= p <= 1
            if z <= a:
                assert p <= bernstein_step(m,r,a)
            if z >= a+g:
                assert p >= bernstein_step(m,r,a+g)
            tested+=1
        beta=max(bernstein_step(m,r,a),1-bernstein_step(m,r,a+g))
        assert 0 <= beta < 1
        assert (1-beta)*tail(n,a+g,True,True) <= tail(n,a,False,False)+beta
        tested+=1

    # Sampled high-degree nontrivial Hoeffding envelope (inequality uses floats;
    # equality of source expectations is still checked with exact rationals).
    m=25
    n=2*m+1
    a,g=F(3,10),F(2,5)
    r=ceil(m*(a+g/2))
    assert poly_expectation(n,m,r,True) == poly_expectation(n,m,r,False)
    beta=exp(-float(m*g*g)/2)
    assert beta < F(1,2)
    assert float(tail(n,a+g,True,True)) <= (
        float(tail(n,a,False,False))+beta)/(1-beta)
    tested+=2

    # Fourier Parseval normalization of the fourth-power Dirichlet kernel:
    # A_L/(2pi) = sum_{k=-(L-1)}^{L-1} (L-|k|)^2
    #           = (2L^3+L)/3.
    for L in range(1,51):
        lhs=sum((L-abs(k))**2 for k in range(-L+1,L))
        assert 3*lhs == 2*L**3+L
        tested+=1

    # Theorem's sufficient-moment count comparison is exact for its
    # input rationals, except for ordinary libm evaluation of log.
    eps,eta=F(1,2),F(1,20)
    gamma=F(3,4)*eps*eps
    old=ceil(1/(float(gamma)**2*float(eta)**2))
    improved=ceil(2/float(gamma)**2*log(4/float(eta)))
    assert (old, improved)==(11378,250)
    print(f"PASS: {tested} exact/sampled checks; original m={old}, new m={improved}")


if __name__ == "__main__":
    run()
