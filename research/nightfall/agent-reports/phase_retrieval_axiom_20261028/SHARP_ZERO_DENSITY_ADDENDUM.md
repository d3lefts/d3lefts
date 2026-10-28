# AXIOM second audit: sharp zero-density bound and improved measurement constant

**Date:** 2026-10-28. **Claim label:** theorem manuscript, exact finite validations; expert proof review and originality still open. **Authorial credit:** research owner Devin J. Wright; Axiom mathematical derivation and independent arithmetic checks.

## Sharp polynomial zero-density lemma

Let p be prime, q=p^r with r>=2, x in F_q^k nonzero, and (u,v) outside the one-dimensional line F_q*(x^p,x). Let

    P(a)=sum_i u_i*a_i^p - (sum_i x_i*a_i)^(p-1)*sum_i v_i*a_i.

Then P is a nonzero polynomial, and for uniformly random a in F_q^k:

    Pr[P(a)=0] <= rho_(p,q) = [p*(q-1)+1]/q^2.

This bound is attained for every k>=2: choose x=(1,0,...), u=v=(0,1,0,...). Then P(t,b)=b^p-t^(p-1)b. For t=0 there is one zero b=0; for each t!=0 there are exactly p choices b: zero and the p-1 multiples of t by F_p^*. The exact zero count is 1+p(q-1) out of q^2 inputs.

### Proof of the universal bound

Use a nonsingular coordinate change z_0=t=a·x, z_i=b_i for i>=1. The polynomial becomes

    P=alpha*t^p + sum_i B_i*b_i^p - t^(p-1)*sum_i C_i*b_i.

If some B_i is nonzero, at t=0 the remaining Frobenius-linear functional has exactly 1/q zero probability because it is surjective. At each fixed t!=0, condition on all b variables except b_i: the residual polynomial in b_i has degree p and thus at most p roots, giving conditional zero probability <=p/q. Averaging produces rho.

If all B_i vanish while some C_i is nonzero, the probability is at most (2q-1)/q^2, because the t=0 slice vanishes identically while each t!=0 slice has zero probability 1/q. For every prime p>=2 this is <=rho. If all B_i and C_i vanish, nontriviality forces alpha!=0, and the zero probability is 1/q <=rho. This exhausts cases.

## Uniform all-signals improvement

Repeat the original report's exact union bound using the sharp rho:

    Pr[any nonzero signal has a nontrivial extra kernel vector]
       <= (q^k-1)*(q^(2k)-q)*rho^m.

For F_25, rho=121/625. The exact integer inequality

    11^5882 < 5^8764

is equivalent to

    25^3 * (121/625)^(2941/500) < 1.

And rho<1/5. Therefore the sufficient bound

    m >= ceil(2941*k/500) + s,   s>=1

guarantees simultaneous all-signals recovery with failure probability <5^(-s), via the same elementary Gaussian-elimination decoder. This improves the previous 6k+s sufficient count to **ceil(5.882k)+s**. The limiting union-bound constant is 3*ln(25)/ln(625/121) = approximately 5.881154827759694.

The single-polynomial zero bound is sharp. A deeper improvement requires exploiting dependence among different candidate polynomials rather than tightening their individual zero probabilities.

## Independent exact audit

Updated, independently structured codepaths on this draft PR include an explicit equality witness over F_25, plus fresh exact equality counts over F_9 and F_49. They check respectively 121/625, 25/81, 337/2401. The previous 624 nonzero F_25^2 all-row rank checks still pass. These are finite validations of the algebraic mechanism; they do not establish publication priority or constitute a proof-assistant formalization.

**Next gate:** separately challenge the universal zero bound using arbitrary finite fields, compare the fixed-field approach with the archived earlier extension-field kernel work, and test whether correlated rank-failure events yield a better uniform sample count.
