# Spectral observability v5 — repair of the categorical nonadaptive rate

**Checkpoint:** 10 November 2026 US/Eastern (11 November UTC)  
**Source under review:** NIGHTFALL_Spectral_Observability_Synthesis_v5.pdf, pages 2 and 5–7 (user research Library, not included in this Git tree)  
**Scientific status:** Analytic quantitative repair with independent exact finite tests; *not* a Lean formalization, independent human referee review, or global-priority determination

## 1. Identified exponent mismatch

The printed v5 Theorem 1.2 / Theorem 4.1 chooses

$$
L_{\mathrm{old}}=m+1,\qquad
C_{d,L}=2d^2 3^{d-1}T_{d-1}(L)
$$

and states the nonadaptive conditional-mean squared-risk estimate

$$
R_q\le \tau_r+\frac{C_{d,L}^{\,2}B^2}{4a_r^2q},
\qquad
a_r=\frac{\Gamma(r/2)}{\sqrt\pi\,\Gamma((r+1)/2)}.
$$

With the *printed choice* of L, the Chebyshev factor is of order $m^{d-1}$, so the resulting upper bound on the number of observations is only $O_d(rm^{2d-2}B^2/\eta)$. That formula does **not** establish the printed matching rate $\Theta_d(rm^{d-1}/\eta)$.

## 2. An exact stronger proxy norm bound repairs the exponent

Take a strictly positive finite categorical law $p=(p_s)_{s=1}^m$ with $\sum_s p_s=1$ and independent fair signs $\varepsilon_s$. Define

$$
S=\sum_s\sqrt{p_s}\,\varepsilon_s,\qquad
Z_s=p_s+\sqrt{p_s}\,\varepsilon_s-p_sS.
$$

Direct expansion gives the mass and moment identities

$$
\sum_s Z_s=1,\qquad
\mathbb E Z_s=p_s,\qquad
\mathbb E[Z_sZ_t]=p_s\mathbf1_{\{s=t\}}.
$$

The stronger **pointwise** norm identity is

$$
\sum_s \frac{Z_s^2}{p_s}
 =1+\sum_s(\varepsilon_s-\sqrt{p_s}S)^2
 =1+m-S^2.
$$

Weighted Cauchy–Schwarz therefore proves

$$
\boxed{\|Z\|_1^2
\le\left(\sum_sp_s\right)\!
   \left(\sum_s\frac{Z_s^2}{p_s}\right)
=m+1-S^2\le m+1.}
$$

Hence the same signed proxy satisfies the corrected common extrapolation parameter

$$
\boxed{L_{\mathrm{new}}=\sqrt{m+1}.}
$$

### Why the Jordan/Chebyshev step permits this substitution

For any real signed vector $Z$ with total mass $1$, let $u=\|Z\|_1\le L$, $L>1$, and write its Jordan decomposition $Z=Z^+-Z^-$, with positive-part mass $(u+1)/2$ and negative-part mass $(u-1)/2$. Add to each part the **same** nonnegative vector $R$ of mass $(L-u)/2$. Normalizing the enlarged parts gives probability vectors $q^+,q^-$ satisfying

$$
Z=\frac{1+L}{2}\,q^+-\frac{L-1}{2}\,q^-.
$$

Thus $q(t)=(1+t)q^+/2+(1-t)q^-/2$ is a genuine probability vector for every $t\in[-1,1]$, while $q(L)=Z$. This construction works blockwise with the **same** bound $L$ for all input coordinates.

The v5 Chebyshev step only uses these probability lines, their common endpoint $L$, the degree-at-most-$(d-1)$ of the interpolated section polynomial, and the bound $2d^2B$ for the sum of genuine section norms. It therefore remains valid after replacing $m+1$ by $\sqrt{m+1}$, provided the remaining vector-valued interpolation and scalar moment inequalities hold.

For $x\ge1$ and integer $k\ge0$, $T_k(x)=\cosh(k\,\operatorname{arcosh}x)\le(2x)^k$. Consequently,

$$
C_{d,\mathrm{new}}
=2d^2 3^{d-1}T_{d-1}(\sqrt{m+1})
\le2d^2 6^{d-1}(m+1)^{(d-1)/2}.
$$

The printed squared-risk estimate now implies the explicit corrected bound

$$
\boxed{
R_q\le \tau_r+
\frac{d^4 36^{d-1}(m+1)^{d-1}B^2}{a_r^2q}.
}
$$

Since $a_r^{-2}=\Theta(r)$, this **repairs the categorical upper-bound exponent** to $O_d(rm^{d-1}B^2/\eta)$, conditional on the remainder of v5's proof. The matching lower construction from v5 does not use $L$ and was not independently certified by this note.

**Numerical impact:** At $d=3,m=16$, $T_2(m+1)=577$ and $T_2(\sqrt{m+1})=33$. The squared query-budget coefficient decreases by exactly $332929/1089\approx305.72$.

## 3. Countable-alphabet Rényi effective support: a second correction

If $p_s$ has countable positive support and $h=(\sum_s\sqrt{p_s})^2<\infty$, all signed-proxy sums converge absolutely. For every sign realization,

$$
\|Z\|_1
\le\sum_sp_s+\sum_s\sqrt{p_s}+|S|\sum_sp_s
\le1+2\sum_s\sqrt{p_s}
=\boxed{1+2\sqrt h}.
$$

Thus choose **$L_{\mathrm{new}}=1+2\sqrt h$**, not the printed $1+2h$. For $h\ge1$, $T_{d-1}(1+2\sqrt h)^2=O_d(h^{d-1})$. Subject to the countable proxy and product-measure limiting argument, this also repairs the stated upper order $O_d(rh^{d-1}B^2/\eta)$. The uniform $m$-ary lower construction provides the corresponding order when $h\ge2$ and $m=\lfloor h\rfloor$.

## 4. Exact independent replay

Run:

~~~bash
python3 -I research/nightfall/2026-11-spectral-observability/check_categorical_proxy_v5.py
~~~

The standard-library Fraction checker independently constructs rational positive unit-sphere weights, so every square root of an atom probability is rational. It exhausts **508 sign patterns** over $2\le m\le8$, verifying mass, first and second moments, the quadratic identity, and both stronger norm bounds with exact rational arithmetic. It independently reproduces the original categorical section-influence/second-moment identity in **336** proxy configurations using three-coordinate multilinear test functions. It also checks **231** sorted-influence tail cases and **20** sharp equality cases, including the exact $577/33$ Chebyshev factor ratio. CI records the input hashes and actual checker output.

These finite tests are independent falsification screens, not the proof of the all-law inequality. The proof of the proxy bound is the symbolic expansion and Cauchy–Schwarz argument above.

## 5. Research status and remaining reviewer gates

- **Proved algebraically in this note:** exact signed-proxy identities; improved $\sqrt{m+1}$ and $1+2\sqrt h$ bounds; validity of the Jordan probability-line representation for every allowed signed block.
- **Conditional conclusion:** the source v5 categorical risk argument achieves its claimed matching $m^{d-1}$ and $h^{d-1}$ upper-order exponents with these corrections, **if** the remaining Hilbert norm interpolation, Chebyshev section estimate, approximation, and risk-to-minimax claims pass independent review.
- **Uncertified:** global originality, kernel-checked all-degree categorical theorem, complete uncountable-product extension, computational efficiency, unrestricted degree-three squared-influence theorem, and any publication/competition claim.
- **Attribution:** NIGHTFALL research under Devin J. Wright, with classical hypercontractivity, Chebyshev extrapolation, Hoeffding orthogonality, signed categorical moment matching, and the prior source manuscript as explicit antecedents. No human peer review is invented.
