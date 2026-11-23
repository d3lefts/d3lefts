# The Latent-Average Wyner Simulation Theorem (QW+)
**Version 0.3 — 2026-11-22 America/Chicago. Mathematical author-side deduction; NEW full theorem NOT kernel-certified.**

## Scientific contribution

The observation that makes the theory substantially stronger is to *average away the latent component label before invoking product rigidity*. This removes the degree-one label penalty and improves the conditional-information charge exponent from six to three, even for arbitrary finite-alphabet interaction degrees. This paper supersedes the claimed *best* coefficient of the initial QW theorem in PR #1154 but preserves its four-corner alternate proof as a distinct mechanism.

Let \(I\) and \(A\) be finite, \(A\ne\varnothing\), let \(\nu\) be any PMF on \(A^I\), and \(f:A^I\to[0,1]\) have indicator-monomial interaction degree at most \(d\ge1\). For \(\varepsilon>0,\ 0<\tau\le 1/4,\ q\in\mathbb N_{>0}\) and \(s>C_W(\nu)\) (in **nats**, allowing arbitrary conditional-product latent spaces using merged #976), the **paper-level all-degree theorem** constructs a deterministic decision tree of at most \(q\) queries to the ORIGINAL coordinates such that

\[
\boxed{
\Pr_\nu(|f-\widehat f|>\varepsilon)
\le {3\sqrt2\,\pi^6d^6\,\tau^{-3/2}
       +2^{20}\pi^2d^6\,s\,\tau^{-3}\over q}
     +{\tau\over\varepsilon^2}.}\tag{LA-W}
\]

For \(d=2\), the stronger **hybrid quadratic theorem**, applying the already certified finite original-source \(C_2=(2(1+\sqrt2)\sqrt3+11901/6250)^2\) alternative to the same label-averaged function, replaces the numerator by

\[
\boxed{
\min\!\left\{
4\pi^2C_2\,\tau^{-2},\ 
3\sqrt2\,\pi^6 2^6\,\tau^{-3/2}
\right\}
\;+\;
2^{26}\pi^2\,s\,\tau^{-3}.}\tag{QW+}
\]

Thus the *same-source*, fixed-\(\tau\) simulator chooses the more favorable actual original-coordinate query tree. At degree two the quadratic seed term wins for
\(\tau\ge(C_2/(48\sqrt2\pi^4))^2\approx0.00025416\); for smaller \(\tau\), the all-degree increment alternative wins. No label oracle is queried.

The existing certified Route 1 theorem remains independently true. Neither a computational runtime guarantee nor a general quantum-state simulator nor a lower bound on arbitrary quantum algorithms is asserted.

## Proof from precisely identified existing inputs

**Step A: exact posterior source model.** Fix a finite conditional-product representation \(\nu=\sum_\theta w_\theta P_\theta\) with mutual information \(I(\Theta;X)<s\), available by the already certified finite/general Wyner reduction #976. At a positive-probability adaptive-query transcript, let \(v_\theta\) be unnormalized posterior weights, \(V=\sum_\theta v_\theta>0\), and \(\pi_\theta=v_\theta/V\). The residual function \(g:A^I\to[0,1]\) has original degree \(\le d\), and all queried coordinates \(j\in A_0\) are invariant. All remaining conditional component laws are products, allowing zero atoms. Define the posterior coordinate marginals \(q_j=\sum_\theta\pi_\theta P_{\theta j}\).

**Step B: actual finite star and degree preservation.** Merged #970 constructs a finite independent seed product \(\kappa=\bigotimes_j\kappa_j\) and simultaneous component decoders \(X_{\theta j}(u)=u_j.2(\theta)\) with \(X_\theta(U)\sim P_\theta\), and a common reference decoder \(Y_j(U)=u_j.1\) (it is enough that \(Y\) is seed-measurable). Set
\[
 F_\theta(u)=g(X_\theta(u)),\qquad
 H(u)=\sum_\theta\pi_\theta F_\theta(u),\qquad R(u)=g(Y(u)).
\]
The original degree-\(d\) indicator representation of \(g\), pulled back along each coordinatewise component decoding, remains degree \(\le d\); a weighted sum of these representations is still degree \(\le d\). Hence \(H\) is a bounded degree-\(d\) function **on the actual product seed law** \(\kappa\), with no extra latent coordinate. Its mean is exactly \(\mathbb E_\nu g\). Source-bridge PR #1154 modules: QuadraticWynerSeedAverage, QuadraticWynerSeedResampling; this paper does not claim their new Lean terminal has compiled.

**Step C: sharper variance survival.** The squared Key Lemma in merged #970 bounds
\[
 \Delta=\mathbb E_{\theta,U}(F_\theta(U)-R(U))^2
 \le 2K w_0+128d^2\eta,\quad K=\pi^2d^2/2,
\]
when every unqueried coordinate's posterior probability of having TV distance \(>\eta\) from \(q_j\) is \(\le w_0\). The exact conditional-variance identity
\[
 \operatorname{Var}_{\theta,U}F_\theta
 =\operatorname{Var}_{U}H+
  \mathbb E_U\operatorname{Var}_\theta(F_\theta(U)\mid U)
\]
and least-squares optimality of \(H(U)=\mathbb E_\theta[F_\theta(U)\mid U]\) against the **seed-measurable** \(R(U)\) imply
\[
 \operatorname{Var}_{\kappa}(H)
 \ge\operatorname{Var}_{\nu}(g)-\Delta.
\]
Choose \(\eta=\tau/(512d^2)\), \(w_0=\tau/(8K)\), so \(2Kw_0+128d^2\eta=\tau/2\). At a high-variance node \(\operatorname{Var}_\nu(g)>\tau\), the low-dependence case has \(\operatorname{Var}_\kappa H>\tau/2\).

**Step D: genuine original-coordinate influence/increment.** The certified Turturean-style mean-increment theorem on the product *seed law*, with a fractional-certificate row budget \(K\), gives
\[
 (\operatorname{Var}_\kappa H)^3
 \le144K^4\big(L^\kappa_j(H)\big)^2
 \quad\text{for some seed coordinate }j.
\]
Jensen with the SAME latent label retained across the two seed samples proves
\[
 L^\kappa_j(H)
 \le\sum_\theta\pi_\theta L^{P_\theta}_j(g).
\]
Thus an unqueried original coordinate has increment
\[
 \sum_\theta\pi_\theta L^{P_\theta}_j(g)
 >g_a^{\rm MI}:={(\tau/2)^{3/2}\over12K^2}.
\]
For \(d=2\), the already certified source-Q2 inequality on this **same product \(\kappa\)** instead gives some \(j\) with
\[
 \mathrm{Inf}_{\kappa,j}(H)>{\tau^2\over4C_2}.
\]
Squared Jensen and the component-coordinate pushforward give
\(\mathrm{Inf}_{\kappa,j}(H)\le\sum_\theta\pi_\theta\mathrm{Inf}_{P_\theta,j}(g)\), and \(2\mathrm{Inf}_{P_\theta,j}(g)\le L^{P_\theta}_j(g)\) because \(0\le g\le1\). Hence
\[
 \sum_\theta\pi_\theta L^{P_\theta}_j(g)
 >g_a^{\rm Q2}:={\tau^2\over2C_2}.
\]
No artificial reference-product influence, no degree-\(d+1\) lift, no hidden-label query. Source-level all-degree progress attempt: stacked PR #1162 QuadraticWynerMeanIncrementProgress.lean; source Q2 alternative: #1154 QuadraticWynerQuadraticProgress.lean.

**Step E: information alternative.** If the Key Lemma small-mismatch condition fails at unqueried \(j\), then \(\beta_j(\eta)>w_0\). The already certified finite KL/TV inequality gives
\[
 I(\Theta;X_j\mid\text{transcript})
 =\sum_\theta\pi_\theta D_{\rm KL}(P_{\theta j}\Vert q_j)
 \ge \sum_\theta\pi_\theta{\rm TV}(P_{\theta j},q_j)^2
 > \eta^2w_0=:g_b
 ={\tau^3\over2^{21}d^4K}.
\]
This is the **remaining information** charge, not the latent entropy \(H(\Theta)\).

**Step F: original-coordinate adaptive tree.** Invoke the existing certified Route 1 Wyner stopping-tree potential
\(\Phi/g_a+\mathrm{Info}/g_b\), with either available positive \(g_a\) (and for \(d=2\), the larger of the two \(g_a\)'s). A real original coordinate query reduces the potential by at least one in conditional expectation. Its initial value is at most \(K/g_a+s/g_b\), because the row sum is at most \(K\) and initial Info is \(I(\Theta;X)<s\), regardless of the number of mixture components. Truncating after \(q\) coordinate queries and outputting the posterior mean at low-variance leaves yields
\[
\Pr(|f-\widehat f|>\varepsilon)
\le(K/g_a+s/g_b)/q+\tau/\varepsilon^2.
\]
Substitute \(K=\pi^2d^2/2\) and \(g_a^{MI},g_a^{Q2},g_b\); this is (LA-W) and (QW+) with exactly the claimed constants. The source tree's GoodW and positive-posterior invariants must still be formally composed (not assumed).

## Comparators and novelty status

NIGHTFALL merged #939 contains **paper-level** mean-increment + latent-degree-\((d+1)\) optimization with log-mixture charge. On the same \(s>C_W(\nu)\) source budget its matched paper extension has numerator \(48\pi^4d^2(d+1)^4\tau^{-3/2}+(525.6\pi^4)^3d^6(d+1)^{12}s\tau^{-9/2}\). Termwise, (LA-W)'s seed coefficient ratio is
\[
{\sqrt2\pi^2\over16}\left({d\over d+1}\right)^4<1,
\]
and its information coefficient is smaller (positive \(\tau\le1/4,\ d\ge1\)), with stronger exponent \(-3\) instead of \(-9/2\). Thus the new all-degree **candidate** termwise dominates the matched #939 paper estimate uniformly, conditional on the validity of both. This is a substantive same-model quantitative transition; it is **NOT** a certified competitive record or global novelty conclusion. External prior art AA/Turturean, GMNR, HMP and common-information/mixture learning requires statement-level review.

## Adversarial tests, credit and exact certification gate

An independently written Fraction-based exhaustive checker, run locally 2026-11-22/23 UTC, tested all 6,480 two-coordinate Boolean functions under every product-mixture parameter in \(\{0,1/2,1\}^{4}\), five posterior weights, and a common finite maximal-star construction. Results: 6,480 exact passes, 2,304 instances with positive lost label variance; exact ANOVA, fiber \(\le\Delta\), original-seed squared and absolute Jensen checks. Case SHA256: 6255beb764b37909fcf07a12d3fc248559b4bc3a09463da4b3d6df1315df6e76. Negative control: a reference depending on \(\theta\) makes \(\Delta=0\) while latent-fiber variance can be positive, so the seed-measurable-reference requirement is essential. These tests do not prove an infinite family theorem.

Existing Lean kernel-certified dependencies: PRs #776 and #970/#976, original-product mean-increment/row theorem. New pending kernel: PR #1154 source Jensen, seed degree, variance survival, Q2 original source; PR #1161 explicit source/axiom gate; PR #1162 direct physical mean-increment. Missing **end-to-end** gate: a named actual-posterior source-specific information/mean-increment-or-Q2 GoodW theorem; numeric radical coefficients; full generalized Wyner decision tree without any undisclosed assumptions, exact-head lake compilation, independent leanchecker, all-standard-axiom receipt, and independent mathematical audit. No new theorem is automatically promoted because an author paper proof or a finite checker passed.

Credit: retain original #776 quadratic contributor lineage, #970/#976 Route1/Wyner Claude-led theorem contributors, #939 alternative paper author, #1154/#1161 parallel label-projection contributors and #1162 independent mean-increment audit. Published theorems (Aaronson–Ambainis; Turturean; Wyner) are essential antecedents. No external publication/submission or merge authorised by these research artifacts alone.
