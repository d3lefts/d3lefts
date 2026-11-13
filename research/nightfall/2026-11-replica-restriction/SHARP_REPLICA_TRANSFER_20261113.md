# Sharp replica-restriction transfer frontier
**NIGHTFALL / 13 November 2026 / v1.1 / Markdown notation and CI-receipt correction; theorem unchanged**

**Status:** Complete self-contained finite-product proof below; two independent exact-Fraction checkers separately verify finite models and rare-event sharpness. NOT a Lean kernel certificate, independently refereed result, or globally novel theorem. The spectral ingredients are classical; the sharp joint no-go is new **within the NIGHTFALL research record** and worldwide priority is open. Do not advertise as a certified new universal law.

## Problem and hypotheses

Let $n\ge1$, $\Omega=\prod_{i=1}^n A_i$, and $\mu=\bigotimes_{i=1}^n\mu_i$, with arbitrary **finite** alphabets and probability weights (zero atoms allowed). Let $f:\Omega\to H$ be a square-integrable real Hilbert-valued function. Its canonical original-law Hoeffding decomposition is $f=\sum_{S\subseteq[n]}f_S$ with energies $E_S=\mathbb E_\mu\|f_S\|_H^2\ge0$. Define
$V(f)=\sum_{S\ne\varnothing}E_S$ and
$I_i^\mu(f)=\mathbb E\operatorname{Var}(f\mid X_{-i})=\sum_{S\ni i}E_S$, where Hilbert variance is squared-norm error.

For each coordinate, independently draw $r_i\ge1$ iid original-law replicas $U_{i,1},\dots,U_{i,r_i}\sim\mu_i$. Independently choose selector $s_i\in[r_i]$ with a **fixed, possibly nonuniform** probability vector $\pi_i=(\pi_{i,a})_{a=1}^{r_i}$. Conditional on all replica arrays $U$, form the selector-space function
\[
g_U(s_1,\dots,s_n)=f(U_{1,s_1},\dots,U_{n,s_n}).
\]
All influence/variance statistics of $g_U$ use the selector product law $\bigotimes_i\pi_i$. Put
\[
\lambda_i=\sum_{a=1}^{r_i}\pi_{i,a}^2,\qquad q_i=1-\lambda_i.
\]
The parameter $q_i$ is the probability that two independent selectors disagree at coordinate $i$, not a physical source collision probability.

## Theorem (exact spectrum and sharp max-influence distortion)

For **every** such source, function, and selector scheme,
\[
\boxed{\mathbb E_U\operatorname{Var}_\pi(g_U)
=\sum_{S\ne\varnothing}\left(1-\prod_{i\in S}\lambda_i\right)E_S.}\tag{1}
\]
For each original coordinate,
\[
\boxed{\mathbb E_U I_i^\pi(g_U)=q_i I_i^\mu(f).}\tag{2}
\]
Consequently, with $M=\max_i I_i^\mu(f)$,
\[
\boxed{\mathbb E_U\max_i I_i^\pi(g_U)
\le\left(\sum_i q_i\right)M.}\tag{3}
\]
The multiplier $\sum_iq_i$ is **best possible**, as a supremum over all bounded scalar-valued functions and finite product source laws for fixed $n$ and $\pi$. In particular, define
\[
A(\pi)=\sup_{\mu,\,0<M(f)} \frac{\mathbb E_U\max_i I_i^\pi(g_U)}{M(f)},\quad
\beta(\pi)=\inf_{\mu,\,0<V(f)}\frac{\mathbb E_U\operatorname{Var}_\pi(g_U)}{V(f)}.
\]
The extrema run over nontrivial bounded scalar functions on finite product alphabets and hence also lower-bound the corresponding Hilbert scopes. Then
\[
\boxed{A(\pi)=\sum_iq_i,\qquad\beta(\pi)=\min_i q_i,\qquad
A(\pi)\ge n\beta(\pi).}\tag{4}
\]
Equality in the last inequality holds iff all $q_i$ agree (including the all-zero case). For uniform two-replica selectors, $q_i=1/2$, the sharp distortion is **exactly $n/2$**. Every particular realization $g_U$ has Hoeffding degree no larger than that of $f$, since replacing source coordinates by selector-indexed symbols cannot increase the largest support size in the pointwise degree-decomposition.

### Proof (finite product, no imported influence theorem)

1. Pick two conditionally independent selector words $s,t\sim\pi$ against the **same** replica arrays. At coordinate $i$, the indices agree with probability $\lambda_i$. On agreement, both selected source values coincide; on disagreement, they are independent $\mu_i$-draws. This is *exactly* a coordinate-refresh coupling with retention $\lambda_i$, independently across coordinates. Thus
\[
\mathbb E_U\|\mathbb E_s g_U(s)\|^2
=\|\mathbb E f\|^2+\sum_{S\ne\varnothing}
\left(\prod_{i\in S}\lambda_i\right)E_S.
\]
Also $\mathbb E_U\mathbb E_s\|g_U(s)\|^2=\mathbb E_\mu\|f\|^2$. Subtract to obtain (1). The Hoeffding diagonalization is the classical orthogonality of independent centered interaction components, and no zero-mass division occurs.
2. Write resampling influence as half the expected squared difference between two selector words that differ only by independently redrawing coordinate $i$. When the two selected replica indices coincide with probability $\lambda_i$, the difference is zero. Otherwise the two source values at $i$ are independent, and the other selected coordinates have their original independent product distribution. The result is exactly $q_iI_i^\mu(f)$, proving (2).
3. Nonnegativity yields $\max_iI_i(g_U)\le\sum_iI_i(g_U)$. Average and use (2) and $I_i(f)\le M$ for (3).
4. **Sharpness of (3).** Let $X_i\sim\mathrm{Bernoulli}(p)$, independently, and $f_p(x)=n^{-1}\sum_{i=1}^n x_i\in[0,1]$. Then $M(f_p)=p(1-p)/n^2$. For a fixed replica array the selector influence at site $i$ is $n^{-2}\operatorname{Var}_{a\sim\pi_i}(U_{i,a})$. As $p\downarrow0$, all events with two or more nonzero replica samples have probability $O_{\pi,n}(p^2)$, while a unique nonzero replica at slot $(i,a)$ contributes $n^{-2}\pi_{i,a}(1-\pi_{i,a})$ to the maximum. Summing their first-order probabilities gives
\[
\mathbb E_U\max_iI_i(g_U)=
\frac{p}{n^2}\sum_{i,a}\pi_{i,a}(1-\pi_{i,a})+O_{\pi,n}(p^2)
=\frac{p}{n^2}\sum_iq_i+O(p^2).
\]
Division by $M(f_p)$ proves $A(\pi)\ge\sum_iq_i$; (3) gives equality.
5. From (1), $1-\prod_{i\in S}\lambda_i\ge\min_iq_i$ for every nonempty $S$. Thus $\beta\ge\min q_i$. Choose a nonconstant function depending only on a coordinate attaining the minimum to obtain equality. Combine with the formula for $A$ to obtain (4). Since $q_i\ge\min_j q_j$, equality of the sum with $n\min q_i$ occurs exactly when every $q_i$ agrees. QED.

### Meaning and limits

This is a **sharp no-go for a particular attempted proof transfer**. Any coordinatewise independent finite-replica selector family retaining a fixed positive fraction $\beta$ of *every* source function's variance in expectation has worst-case expected maximum-influence distortion at least $n\beta$. Therefore the conventional step
$\mathbb E_U\max_i I_i(g_U)\le C\max_iI_i(f)$
cannot hold with dimension-free $C$ for this family while preserving constant source variance. This does **not** refute Q2, rule out nonlinear/correlated/adaptive restrictions, or say a general Boolean-to-categorical theorem is impossible.

The special two-replica obstruction and max/expectation noncommutation were already in:
- [2026-11-12 Turturean scope audit](../2026-11-information-cost-dissertation/CHAPTER2_TURTUREAN_SCOPE_AUDIT_20261112.md);
- [2026-11-11 two-draw categorical occupancy audit](../2026-11-cubic-hidden-gems/AUDIT_TWO_DRAW_MAX.md).
The new-in-program increment is **arbitrary weighted replica counts plus the exact sharp joint retention/amplification frontier**. Classical ingredients: Hoeffding/Efron–Stein decomposition, product refresh noise, and $\max\le\sum$. A limited dated prior-art search found no identical theorem, **which does not establish originality**. Related primary materials:
- [BKKKL, *The influence of variables in product spaces* (1992)](https://doi.org/10.1007/BF02808010)
- [Mossel–O'Donnell–Oleszkiewicz, *Noise stability of functions with low influences*](https://arxiv.org/abs/math/0503503)
- [O'Donnell–Saks–Schramm–Servedio, *Every decision tree has an influential variable*](https://www.cs.cmu.edu/~odonnell/papers/dt-influences.pdf)

### Reproduction and scope of certification

- `checks/check_replica_restrictions.py`: independent full rational enumeration of product input tables, canonical Hoeffding energies, resampling influences, and every positive-probability replica array. Covers mixed biased alphabets, zero source masses, weighted 2/3-replica selectors, degree three, and degenerate selector entries.
- `checks/check_sharp_frontier.py`: separate exact rational one-hot/rare-Bernoulli enumeration confirming the first-order sharp coefficient $\sum_iq_i$, plus finite-$p$ controls.
- CI: `.github/workflows/nightfall-replica-frontier-exact.yml`; scoped replay passed in [run 43515837487](https://github.com/d3lefts/d3lefts/actions/runs/43515837487). The original v1.0 source hash remains in that receipt; this v1.1 change repairs Markdown without modifying the equations.
- **Analytic proof status:** self-contained author-side theorem; exact examples certified by independent scripts. **No end-to-end Lean proof, external non-author referee review, or world-priority certification.** This note belongs in the site's *research/audits* area, not its approved original discoveries or numerical-record registry.

### Transfer decision

Do **not** run another ordinary independent-replica/max-commutation attack. Change operator family: either prove a source-preserving matching/ownership-to-influence theorem (the live Q2 proof), or study a materially different *correlated* or *history-adaptive* restriction with a precisely costed simulator and a nontrivial dimension-uniform transfer. A future proposition must show a quantitative gain beyond the sharp frontier here to justify reopening the failed family.
