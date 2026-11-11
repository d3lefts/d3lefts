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

### Independent reconstruction of the finite-product mixed-influence bound

The sharpened parameter is not just a heuristic substitution. The finite-alphabet part of the source proof can be reconstructed from two standard external inequalities, **Bonami hypercontractivity on fair signs** and **Markov's derivative inequality for bounded polynomials**:

1. **Moment transport.** Extend $f$ to products of signed coordinate mass vectors by multilinearity. Let $H_i(z_{-i})\in L^2(p_i)$ be its centered section in coordinate $i$. Because $\deg f\le d$, the section has block-degree at most $d-1$. Independence and $\mathbb E[Z_sZ_t]=p_s\mathbf1_{\{s=t\}}$ imply the *exact* identity
   $
   I_i(f)=\mathbb E_Z\|H_i(Z_{-i})\|_{L^2(p_i)}^2.
   $
   Indeed, each term after squaring uses at most the second moment of every proxy block.

2. **Vector-valued hypercontractivity.** For any finite-dimensional real Hilbert-valued fair-sign polynomial $P$ of degree at most $k$, scalar Bonami applied to each component and Cauchy–Schwarz across component pairs give $\|P\|_{L^4(H)}\le3^{k/2}\|P\|_{L^2(H)}$. Interpolation yields
   $
   \|P\|_{L^2(H)}\le3^k\|P\|_{L^1(H)}.
   $
   Consequently $\sqrt{I_i(f)}\le3^{d-1}\mathbb E_Z\|H_i(Z_{-i})\|$.

3. **Pointwise section-oscillation budget.** Fix any product tuple of genuine coordinate probability vectors $q_i$. In the $i$th coordinate, choose a symbol maximizing the section and independently move every $q_i$ toward its maximizer by a common parameter $t\in[0,1]$. The resulting expectation is a polynomial of degree at most $d$ bounded by $B$. Its derivative at $t=0$ sums all increases, so endpoint Markov bounds that sum by $2d^2B$. Repeating with minimizers bounds the total sum of section ranges by $4d^2B$. Each $L^2(p_i)$ centered section norm is at most half its range. Thus
   $
   \sum_i\|H_i(q_{-i})\|_{L^2(p_i)}\le2d^2B.
   $

4. **Common Chebyshev extrapolation.** Fix a proxy realization $(Z_i)$ and construct each probability line $q_i(t)$ as above, with all $q_i(L)=Z_i$ for the same $L=\sqrt{m+1}$. Select a unit functional $u_i$ that norms $H_i(Z_{-i})$. The scalar polynomial
   $
   P(t)=\sum_i\langle u_i,H_i(q_{-i}(t))\rangle
   $
   has degree at most $d-1$ and magnitude at most $2d^2B$ on $[-1,1]$. Chebyshev extremality gives
   $
   \sum_i\|H_i(Z_{-i})\|\le2d^2B\,T_{d-1}(\sqrt{m+1}).
   $
   Combining with step 2 gives the finite scalar theorem
   $
   \boxed{\sum_i\sqrt{I_i(f)}
   \le2d^2 3^{d-1}B\,T_{d-1}(\sqrt{m+1}).}
   $

5. **Rank lift and optimal tail selection.** For covariance rank $r$, apply the scalar result to $\langle u,F\rangle$ over uniform unit output directions $u$. The elementary spherical inequality $\mathbb E_u\sqrt{u^\top A_i u}\ge a_r\sqrt{\operatorname{tr}A_i}$ yields $\sum_i\sqrt{I_i(F)}\le C_{d,\mathrm{new}}B/a_r$. For the $q$ largest numbers $b_i=\sqrt{I_i(F)}$, write $A=\sum_i b_i$ and $u=b_{q+1}$. The residual Hoeffding variance after observing those coordinates is bounded by
   $
   \sum_{i>q}b_i^2\le u(A-qu)\le\frac{A^2}{4q}.
   $
   A projection onto the top $r$ output-covariance directions adds at most $\tau_r$.

**Audit classification:** This is a complete finite-product proof reconstruction using named classical analytic inputs and explicit algebraic identities. It has independent exact finite replay, but **no external nonauthor referee or Lean kernel certification**. Infinite/countable-product limiting arguments are further claims, not part of this finite proof.

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
