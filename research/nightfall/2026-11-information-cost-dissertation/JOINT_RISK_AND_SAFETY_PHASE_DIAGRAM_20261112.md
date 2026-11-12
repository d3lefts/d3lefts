# NIGHTFALL — A scoped joint information-cost theorem

**Research checkpoint:** 12 November 2026. **Status:** self-contained finite-product mathematics and exact finite checks; ingredients largely classical, **no novelty claim** and **no full quadratic exponent-two Lean certificate**. This note advances the information-access dissertation; it does not supplant the central quadratic influence manuscript.

## Goal and prior-art boundary

Relate (a) learning an unknown model from full-input evaluations, (b) observing a fresh state of a known or partially learned model, and (c) checking an exact safety property. Make the assumptions governing the transition explicit. The strongest external comparator checked this session is the Ore–DeMillo–Lipton–Schwartz–Zippel support bound, stated for Boolean grids in Amireddy–Behera–Srinivasan–Sudan, ICALP 2025, DOI 10.4230/LIPIcs.ICALP.2025.11. Bayesian orthogonal risk splitting is a law-of-total-variance argument; exact interpolation and generalized binary search are classical. Neither the individual ingredients nor their packaging is established as globally new.

### Operators and costs

- A **model query** requests the exact value of an unknown \(f_\theta(x)\) at a chosen complete input \(x\).
- A **fresh-state query** reveals one coordinate \(X_i\), not an arbitrary value \(f_\theta(x)\).
- A **passive behavioral query** draws \(X\sim\mu\) and returns \(f_\theta(X)\).
- The model transcript \(D\) is completed before the fresh \(X\) is drawn, unless a different online oracle model is explicitly stated.
- A **safety property** must be specified: equality to a known reference, nonnegativity, and unrestricted pointwise safety have different costs.
- Query count ignores time required to construct/query length-\(n\) inputs and solve interpolation systems. Exact real-valued answers are assumed.

## Theorem A — exact model/state Bayes-risk splitting

Let \(\Theta\) be a random model parameter, \(X\sim\mu\) an **independent** fresh state on a finite product, and \(f_\Theta(X)\) square-integrable in a real Hilbert space. A possibly adaptive/noisy model-query transcript \(D\) is collected without access to \(X\). Set
\[
m_D(x)=\mathbb E[f_\Theta(x)\mid D],
\quad
U(D)=\mathbb E_{X}\mathbb E_{\Theta\mid D}\|f_\Theta(X)-m_D(X)\|^2.
\]
A state-query policy then chooses coordinates of \(X\) based on \(D\) and already revealed coordinates, yielding transcript \(T\). The optimal estimator is \(\hat f=\mathbb E[m_D(X)\mid D,T]\). It satisfies the **exact identity**
\[
\boxed{\mathbb E\|f_\Theta(X)-\hat f\|^2
=\mathbb E_D U(D)
+\mathbb E\|m_D(X)-\mathbb E[m_D(X)\mid D,T]\|^2.}\tag{A}
\]
Thus **even full state revelation cannot improve below \(\mathbb E_DU(D)\)**. The second term is precisely state-observation Bayes risk for the known posterior-mean model \(m_D\).

**Proof.** Given \(D\), the parameter posterior and fresh state remain independent. Write \(f_\Theta(X)=m_D(X)+e\), where \(\mathbb E[e\mid D,X]=0\). Since \(T\) is a function of \(D,X\) and independent policy coins, \(\mathbb E[e\mid D,T]=0\). Orthogonality in \(L^2\) kills the cross term between \(e\) and \(m_D(X)-\mathbb E[m_D(X)\mid D,T]\), proving (A). For non-finite state spaces the same proof holds under regular conditional distributions/conditional expectation assumptions.

**Structure inheritance.** If every \(f_\theta\) is uniformly bounded by \(B\) and has product Hoeffding interaction degree \(\le d\), the posterior mean \(m_D\) has the same bounds and degree, by linearity/conditional averaging. Consequently *any valid known-model observation theorem* applies to \(m_D\), not necessarily to an identified \(f_\theta\). Conditional on the still-analytic rank-\(r\) quadratic observation theorem, for \(d\le2\) this yields
\[
R_{\mathrm{joint}}\le \mathbb E U(D)+\mathbb E\tau_r(m_D)+\eta
\]
with \(q_{\rm state}\le\min(n,\lceil12C_2rB^2/\eta\rceil)\), \(C_2=(10+2\sqrt2)^2(1+\sqrt3)^2\). This **conditional corollary is not an independent validation** of the quadratic theorem.

**Causal boundary.** If the model oracle is available *after observing the fresh address*, (A) with the pre-observation \(D\) no longer describes the available information. For the signed-address family \(f_\theta(K,Z)=\theta_KZ_K\), one online model query at address \(K\) together with reads of \(K,Z_K\) predicts exactly; one pre-observation model query leaves risk \(1-1/m\) under iid fair prior on \(\theta\).

## Theorem B — support degree controls behavioral equality testing

Let \(\Omega=\prod_{i=1}^n A_i\) with independent finite laws \(\mu_i\), each supported atom having probability at least \(\alpha>0\), \(\alpha\le1\). Let real \(h\) be a *nonzero function on the support* with Hoeffding interaction degree at most \(d\ge0\). Then
\[
\boxed{\Pr_\mu[h(X)\ne0]\ge \alpha^{d}.}\tag{B}
\]
For uniform Boolean coordinates, \(\alpha=1/2\), and equality is attained by a conjunction of \(d\) prescribed bits. In particular, if \(f,g\) are both **promised** degree \(\le d\), then either \(f=g\) everywhere on the product support or they disagree with probability at least \(\alpha^d\). The exact-value passive equality tester that samples \(q\) independent inputs therefore rejects every unequal pair with probability at least \(1-\delta\) if
\[
q\ge \left\lceil \alpha^{-d}\ln(1/\delta)\right\rceil.
\]
It has no false rejection when \(f=g\). Acceptance is a bounded-error assurance, **not a deterministic certificate of equality**.

**Proof by induction on \(d\).** For \(d=0\), \(h\) is a nonzero constant, so its support has probability one. For \(d>0\), if \(h\) is constant we are done. Otherwise choose a coordinate \(i\) and two positively supported symbols \(a,b\) such that the section difference
\(g(y)=h(a,y)-h(b,y)\) is nonzero. Since every Hoeffding component of \(h\) depends on at most \(d\) coordinates and the components not involving \(i\) cancel, \(g\) has interaction degree at most \(d-1\). By induction \(g\ne0\) on a subset of the remaining product of mass at least \(\alpha^{d-1}\). At each such \(y\), at least one of \(h(a,y)\), \(h(b,y)\) is nonzero, occupying conditional mass at least \(\alpha\). Integrate to obtain (B). This is a product-grid polynomial-distance argument, not a novel replacement for Schwartz–Zippel/Reed–Muller bounds.

**Scope.** The atom floor is essential for a uniform rate. For a one-coordinate rare-atom indicator \(h=1_{\{X_1=a\}}\), degree \(1\) but support can have arbitrarily small mass. For continuous factors no distribution-free positive atom floor exists. The degree promise must hold for **the violation function** \(h\) or the *difference* \(f-g\), not merely for an unrelated numerical safety score.

**Sharp contrast with bias-independent state observation.** Let \(X_1\) be Bernoulli with \(\Pr(X_1=1)=\alpha\ll1\), and put \(h(X)=1_{\{X_1=1\}}\). This is bounded and degree one. Predicting zero with **no fresh-state queries** incurs squared error \(\alpha\) (or \(\alpha(1-\alpha)\) using the optimal constant predictor), which tends to zero. But a **passive** independent-sample inspector distinguishing \(h\equiv0\) from this h with probability \(1-\delta\) needs \(q\ge \ln\delta/\ln(1-\alpha)\sim\alpha^{-1}\ln(1/\delta)\). A **chosen full-input query** at \(X_1=1\) finds the exception immediately if that coordinate/symbol is known. Thus any purported transfer from bias-free *state-prediction* budgets to bias-free *passive exact-safety* budgets is false, even for degree one. The distinction is one of loss, predicate, and access model rather than a contradiction.

## Theorem C — a finite-product exact-query phase diagram

Let every \(A_i\) be finite with full support, \(|A_i|=a_i\), and \(\mathcal H_d\) the real functions of Hoeffding degree \(\le d\). The dimension is
\[
\boxed{D_d=\dim\mathcal H_d=
\sum_{S\subseteq[n],\,|S|\le d}\prod_{i\in S}(a_i-1).}\tag{C}
\]
For a **bounded** class \(\{f\in\mathcal H_d:\|f\|_\infty\le B\}\) with \(B>0\), deterministic exact identification from chosen full-input value queries has worst-case complexity **exactly \(D_d\)**, where query computation is free.

**Proof.** The Hoeffding spaces are independent tensor products of one-dimensional constants and \((a_i-1)\)-dimensional centered coordinate contrast spaces, hence the dimension formula. Evaluation functionals from all points span the dual of \(\mathcal H_d\), so \(D_d\) chosen evaluation rows can be selected to form an invertible matrix: the resulting values identify every \(f\). Conversely, on the all-zero answer transcript for any deterministic adaptive method making \(q<D_d\) queries, the evaluation map has a nonzero kernel \(h\in\mathcal H_d\). Scaling \(h\) yields a distinct bounded function with all the same answers. Therefore \(D_d\) queries are necessary.

The same kernel argument shows that **deterministic zero-error certification of nonnegativity** \(f(x)\ge0\ \forall x\) on this bounded class requires \(D_d\) chosen evaluations in the worst case: after fewer than \(D_d\) zero answers, select a nonzero nullspace \(h\), choose a sign that is negative somewhere, and rescale it to obey \(\|h\|_\infty\le B\). The \(D_d\)-query interpolation upper bound matches.

This differs from **randomized high-confidence equality testing**: by (B), testing the exact condition \(f\equiv0\) under the trusted degree-\(d\) promise takes \(O(\alpha^{-d}\ln(1/\delta))\) random samples, even when \(D_d\) grows as \(n^d\).

### A completely explicit common class: affine Boolean systems

On \(X\in\{-1,+1\}^n\) uniform, consider bounded affine \(f(x)=c+\sum_i a_ix_i\), \(\|f\|_\infty\le B\).

1. **TEST degree one:** The two-group four-corner difference tester has one-sided \(\epsilon\)-far detection probability at least \(\epsilon/(8B^2)\) per trial (squared \(L^2\) distance). Four full-input evaluations per trial; query complexity \(O(B^2\epsilon^{-1}\ln(1/\delta))\), independent of \(n\).
   **Derivation:** Color coordinates independently with two equiprobable colors and evaluate the alternating four-corner difference from two independent product inputs. ANOVA orthogonality yields
   \(\mathbb E[\Delta_2f]^2=4\sum_{|S|\ge2}(1-2^{1-|S|})\|f_S\|_2^2\ge 2W_2(f)\),
   where \(W_2(f)=\mathrm{dist}_{L^2}(f,\mathcal H_1)^2\). Since \(|\Delta_2f|\le4B\), a nonzero difference occurs with probability \(\ge W_2(f)/(8B^2)\). This is a one-sided proximity test, not exact-class-membership proof.
2. **IDENTIFY exactly:** \(n+1\) chosen model evaluations, necessary and sufficient by (C).
3. **OBSERVE state approximately:** because \(\sum_i|a_i|\le B\), reveal the \(q\) coordinates with largest \(|a_i|\). The conditional-mean squared error is \(\sum_{\rm unrevealed}a_i^2\le B^2/(4q)\). Hence \(O(B^2/\eta)\) fixed-coordinate reads suffice, independent of \(n\). The order is tight for the family \(f=n^{-1}\sum_i X_i\) at \(\eta=1/(2n)\).
4. **CHECK exact equality \(f\equiv0\) with high confidence:** any nonzero affine function is nonzero on at least half the cube, so \(q=\lceil\log_2(1/\delta)\rceil\) passive samples suffice.
5. **CERTIFY nonnegativity with deterministic certainty:** \(n+1\) chosen evaluations, necessary and sufficient.
6. **RARE violation despite degree one:** \(f_n(x)=\bigl(1+\frac{2}{n}\sum_i x_i\bigr)/3\) is bounded in \([-1/3,1]\), is negative at the all-minus state by the fixed margin \(1/3\), yet
\(\Pr(f_n(X)<0)=2^{-n}\sum_{k<n/4}\binom nk\le e^{-n/8}\). Thus no dimension-independent *passive* sample count certifies this inequality guarantee over the bounded degree-one class.

**Important:** The low-degree *score* \(f_n\) does not imply a low-degree violation indicator \(1_{\{f_n<0\}}\). The safety predicate changes the relevant structural degree.

**Exact threshold degree blow-up.** The claim can be made algebraically sharp. Write \(K(x)=|\{i:x_i=+1\}|\), \(t=\lfloor(n-1)/4\rfloor\), and \(u_n(x)=1_{\{f_n(x)<0\}}=1_{\{K(x)\le t\}}\). Its full-order Fourier/Hoeffding coefficient on the uniform cube is
\[
\widehat u_n([n])
=2^{-n}\sum_{k=0}^{t}(-1)^{n-k}{n\choose k}
=(-1)^{n+t}2^{-n}{n-1\choose t}\ne0.
\]
The second equality is the exact alternating-binomial partial-sum identity. Hence \(\deg_{\rm ES}(u_n)=n\) **although \(\deg_{\rm ES}(f_n)=1\), \(\|f_n\|_\infty\le1\), and \(f_n(-1,\ldots,-1)=-1/3\)**. This is a dimension-growing, mathematically exact obstruction to inferring low violation-event complexity from low numerical-score interaction degree. It is a standard symmetric-threshold/Fourier mechanism, not a priority claim.

### Approximate structure is not an exact certificate

For \(N=2^n\) and uniform Boolean inputs, let \(g=0\) and \(h_z=1_{\{x=z\}}\). The squared \(L^2\) distance to \(\mathcal H_d\), for any \(d\ge0\), is at most \(1/N\) because \(g\in\mathcal H_d\). However \(h_z\not\equiv0\). Under an unknown uniformly hidden \(z\), \(q\) adaptive classical full-input queries detect the violation with probability at most \(q/N\). The trusted **exact** low-degree promise in (B) cannot be replaced by an \(\epsilon\)-closeness statement. Coherent quantum search changes the \(N\)-dependence to \(\Theta(\sqrt N)\) under its separate access model.

## What is established and what is not

- **Analytic/proved by elementary arguments here:** (A) Bayesian risk orthogonality under the pre-observation information constraint, (B) support-degree minimum mass for finite product laws, (C) exact interpolation dimension and deterministic decision lower bound, affine phase diagram, near-class needle counterexample.
- **Exact small-instance falsification:** the accompanying checker tests rational heterogeneous product supports, boolean evaluation ranks, random low-degree support, rare-inequality probabilities, and addressed-model posterior risk decomposition.
- **Established antecedents:** law of total variance / Bayesian epistemic uncertainty decomposition; polynomial-distance/Reed–Muller and Ore–DeMillo–Lipton–Schwartz–Zippel bounds; linear-algebra interpolation; property testing and generalized binary search. The novelty lies at most in the organized cross-task scope and possible future transfers, not in a proven new general mathematical law.
- **Still open:** an independently justified interaction-based condition guaranteeing *efficient model-query splitting* or better-than-interpolation identification; full end-to-end Lean compilation of the quadratic \(V^2\) influence theorem; categorical Grothendieck priority comparison.
- **No Lean claim:** nothing in (A)–(C) has been compiled as a joint new theorem in this checkpoint. Existing finite all-degree Lean receipts and PR #416 scoped quadratic integration have separate statuses.

**Cheapest decisive next experiment:** Try to convert a certified low-degree promise on a numerical safety score into a finite-degree bound on its thresholded violation indicator. The affine \(f_n\) above already falsifies any dimension-independent degree bound for that transfer: the violation indicator is a rare Boolean threshold depending on all \(n\) coordinates. A viable transfer requires a stronger *predicate-specific* structural certificate.

## References checked

- Prashanth Amireddy, Amik Raj Behera, Srikanth Srinivasan and Madhu Sudan (2025), [A Near-Optimal Polynomial Distance Lemma over Boolean Slices](https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ICALP.2025.11), discussion of classical cube distance \(\ge2^{-d}\).
- David Turturean (2026), [A proof of the Aaronson–Ambainis conjecture](https://arxiv.org/abs/2611.09773), all-degree influence (external).
- Uma Girish, Kunal Mittal, Barak Nehoran and Ran Raz (2026), [Distributional Variants of the Aaronson–Ambainis Conjecture](https://arxiv.org/abs/2609.35327), equivalence under fixed bias and slices.
- [NIGHTFALL quadratic degree-two manuscript and certificate scope](../formalization/observability/QUADRATIC_E2E_CERTIFICATION_STATUS.md).
- [NIGHTFALL addressed-family exact separation](CHAPTER5_FOUR_COSTS_v1.md).
