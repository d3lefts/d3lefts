# Classical Chebyshev sharp degree-penalty obstruction: k >= 2

Checkpoint 2026-11-17 Eastern. Analytical derivation, exact rational finite checker. This is **not a proof of N-UE2(2) or N-UE2(6)**, and the construction is classical, not claimed as original.

## Construction, exact source convention

Let d be a positive multiple of 4 and n=d². Let X_1,...,X_n be independent fair signs, and define
\[
 f_d(X)=T_d\left(\frac1n\sum_{j=1}^n X_j\right),
\]
where T_d(cos theta)=cos(d theta) is the first-kind Chebyshev polynomial. Then |f_d|<=1 and its multilinear Fourier degree is **exactly d**. The highest-degree Walsh coefficient on each set of d distinct coordinates is 2^(d-1) d!/n^d, which is nonzero. Define B_d=(max f_d - min f_d)/2, the essential centered radius, not the uncentered sup norm.

For k=0,...,n put v_k=T_d((2k-n)/n) and q_k=binom(n,k)/2^n. All coordinates have the same **original-law resampling influence**
\[
 V_d=\sum_{k=0}^n q_k(v_k-\sum_jq_jv_j)^2,\quad
 M_d=\frac{1}{4\,2^{n-1}}\sum_{k=0}^{n-1}\binom{n-1}{k}(v_{k+1}-v_k)^2.
\]
This formula uses conditional variance, equivalently **one quarter** of mean squared fair-bit flip differences. In particular, the denominator of the single binomial sum is 2^(n+1). These exact formulas are independently checked in check_ue2_chebyshev.py by the conditional-expectation identity and complete truth-table enumeration for d<=3.

## Rigorous Gaussian limit

Write Z_d=(sum_j X_j)/d, so Z_d converges in law to a standard Gaussian Z by the classical central limit theorem. Uniformly for bounded z,
\[
 d\arccos(z/d)=\pi d/2-z+O_z(d^{-2}).
\]
On d divisible by 4, T_d(Z_d/d) converges in law to cos Z. The functions are bounded by 1, so
\[
 V_d\to\operatorname{Var}(\cos Z)=\tfrac12(1-e^{-1})^2.
\]

Let S be the sum of the other n-1 signs and set
\[
 D_d=\frac d2\left[T_d((S+1)/d^2)-T_d((S-1)/d^2)\right].
\]
Then **exactly** d² M_d=E[D_d²]. On every event |S|<=d²/2-1, the derivative bound |T'_d(x)|<=d/sqrt(1-x²) (valid for |x|<1) and the mean-value theorem give |D_d|<=2. Outside, the global Chebyshev Markov bound |T'_d(x)|<=d² on [-1,1] gives |D_d|<=d, while Hoeffding's tail bound yields P(|S|>d²/2-1)<=2exp(-c d²); therefore the exceptional contribution to E[D_d²] vanishes.

On every fixed compact set for S/d, the preceding arccos expansion and the derivative identity
\[
 T'_d(x)=d\frac{\sin(d\arccos x)}{\sqrt{1-x^2}}
\]
show D_d converges uniformly to -sin(S/d). The central limit theorem plus the uniform central bound and negligible tails imply
\[
 d^2 M_d=E[D_d^2]\to E[\sin^2 Z]=\tfrac12(1-e^{-2}).
\]

Finally B_d->1. Indeed T_d(1)=1, and the feasible mesh for S/d is 2/d. Pick an integer-lattice S with S/d within O(1/d) of pi; then T_d(S/d²)->-1. The range remains inside [-1,1]. Consequently
\[
 \boxed{\lim_{d\to\infty,\;4\mid d}
 \frac{V_d^2}{B_d^2\,M_d\,d^2}
 =\frac{(1-e^{-1})^4}{2(1-e^{-2})}
 \approx0.0923255552445978>0.}
\]

Hence for any fixed exponent k<2, the ratio V_d²/(B_d² M_d d^k) diverges. **The degree exponent must satisfy k>=2** in any all-degree variance-squared influence bound. This does not show that k=2 suffices.

## Computational replay, scope, controls

The exact rational checker evaluates the binomial finite sums with no normal approximations. For d=8,12,16 its ratio divided by d² is approximately 0.09477890218, 0.09333548128, 0.09288124380, and tends to the displayed Gaussian limit. It separately checks original conditional-variance formulas against full fair-cube enumeration for d=1,2,3 and computes true half-range radii. Finite replay is not a proof of the limit.

Historical comparison: the previously filed tribes witness establishes only k>=1, a correct but superseded lower-bound strength. The elementary additive fair-sign average forces the *variance* exponent alpha>=2 at d=1. Thus both conjectured exponents 2 are individually necessary, and neither universal conjecture is yet proved.

**Certificate status:** author-side CLT proof with explicit derivative tail estimate; exact finite Fraction checker; no Lean kernel proof, non-author mathematical review, or global novelty priority. Credited Chebyshev / CLT / Khintchine classical mathematics. The unrestricted cubic exponent-two gate remains the source-consistent annealed quadratic inequality of merged PR #799, not the retired coefficient-one spike-tail shortcut of PR #802.
