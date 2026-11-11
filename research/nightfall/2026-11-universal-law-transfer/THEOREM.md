# Universal Observation Beyond Product Laws: Sharp Exact/Approximate Transport Across Arbitrary Correlations

**NIGHTFALL Constellation · Devin J. Wright · theorem-transfer research note v0.1 · 11 November 2026 (UTC)**

**Status: NEW CONDITIONAL ANALYTIC SYNTHESIS, NOT A CERTIFIED ORIGINAL WORLD THEOREM.** The law-transfer inequalities in this note are proven by standard measure theory and the classical Neyman–Pearson/hockey-stick variational principle. The source adaptive observer is exactly the already published **Paper A/Paper B** repository statement; the full arbitrary-product source is **not** end-to-end Lean certified or independently refereed. The new finite Lean file certifies only a stated bounded-loss dual upper inequality and a finite support-transfer implication after its own CI succeeds. The 2,760 exact rational tests below are finite falsification, not universal proof. This note neither reclaims classical primitives as original nor promotes the source theorem.

## Research objective and inputs

The existing bridge establishes adaptive observation **under an independent source law** \(\mu=\bigotimes_{i\in I}\mu_i\). This note asks what happens when the **actual data-generating law** \(\nu\) is arbitrary, including strongly correlated or partially singular measures. We do **not** assume Hoeffding degree under \(\nu\) or conditional independence under \(\nu\). Instead, retain the concrete structural input \(F\) and the original product reference \(\mu\); reuse exactly the same precomputed \(\mu\)-observation policy.

The quantitative question is whether a \(\mu\)-risk guarantee \(e\) implies an optimal \(\nu\)-risk guarantee **without a bounded density ratio**. The exact-recovery question is whether the same whole-coordinate policy remains zero-error under the changed law.

## Theorem 1. Universal law-shift observation transfer (analytic)

Let \((\Omega,\mathcal A)\) carry a reference independent product probability \(\mu\), and let \(\nu\) be **any** probability measure on the same measurable space. Take its Lebesgue decomposition
\[
\nu = w\mu+\nu_s,\qquad w\ge0,\ \int w\,d\mu=1-\theta,\quad \nu_s(\Omega)=\theta\in[0,1],
\]
with \(\nu_s\) singular with respect to \(\mu\). For \(t\in[0,1]\), set
\[
\boxed{\Psi_w(t)=\inf_{a\ge0}\left[a\,t+\int (w-a)_+\,d\mu\right].}\tag{T1}
\]
This is the Neyman–Pearson / sharp bounded-loss transfer modulus: \(\Psi_w(0)=0\), \(\Psi_w(1)=1-\theta\), and \(\Psi_w(t)\to0\) as \(t\downarrow0\).

**(A) Exact recovery, including arbitrary correlations.** Suppose a deterministic adaptive whole-coordinate observer \(\mathcal O\) outputs a measurable finite-palette \(f\) correctly \(\mu\)-almost surely in at most \(D\) queries. The *same unmodified policy*, with a fixed measurable default on source-null transcripts, satisfies
\[
\boxed{\Pr_\nu[\mathcal O(X)\ne f(X)]\le\theta.}\tag{T2}
\]
For every \(\nu\ll\mu\), \(\theta=0\) and exact recovery is retained **with no density-ratio, independence, or mixing assumptions on \(\nu\)**. In particular, apply Paper A to a source-product finite-range \(f\) of Hoeffding degree \(d\), real palette \(q\), range \(R\), minimum gap \(\Delta\); the resulting cost is
\[
D\le d\left\lfloor d^2\min\{(q-1)^2,2R/\Delta\}\right\rfloor,
\]
and the same reference-built observer is exact under *every* \(\nu\ll\mu\). The finite vector-palette extension transfers identically.

**(B) Hilbert prediction under correlated or singular laws.** Let \(F:\Omega\to H\) be a strongly measurable **pointwise bounded** function into a real Hilbert space, \(\|F(x)\|\le B\) for *all* \(x\in\Omega\). Suppose an adaptive observer of at most \(N\) whole-coordinate queries, constructed under \(\mu\), has a measurable reference conditional-mean predictor \(\hat F_\mu\) with reference MSE
\[
e_\mu=\mathbb E_\mu\|F-\hat F_\mu\|^2\le e.
\]
Extend or project \(\hat F_\mu\) into the closed Hilbert ball of radius \(B\) everywhere (without changing its \(\mu\)-risk). Then the *same reference-law policy and predictor* satisfy
\[
\boxed{
\mathbb E_\nu\|F-\hat F_\mu\|^2
\le4B^2\left[\theta+\Psi_w\left(\min\{1,e/(4B^2)\}\right)\right].
}\tag{T3}
\]
The **\(\nu\)-optimal posterior conditional mean given the same observed transcript** has MSE no larger than the right-hand side. Thus this is also an admissible upper bound on Bayes risk if the target law \(\nu\) happens to be known, though the policy itself need not know it.

Substituting Paper B with \(e=\tau_{r,\mu}+\eta\) and
\[
N=\left\lceil\frac{40}{3}U\log(1+4U)\right\rceil,\qquad
U=\frac{d^7B^3r^{3/2}}{c_*\eta^{3/2}},\quad
c_*=\frac{\sqrt{3/12500}}{\pi^6},
\]
gives dimension-free adaptive prediction under an **arbitrary correlated target law**, with the sharp *bounded-loss transfer penalty* \(\theta+\Psi_w\). The interaction-degree condition is with respect to \(\mu\), **not** the possibly correlated \(\nu\). No correlated-law influence inequality is claimed.

**(C) Sharpness for the transfer problem.** For the class of all measurable losses \(0\le L\le1\) with \(\mathbb E_\mu L\le t\),
\[
\boxed{\sup_L\mathbb E_\nu L=\theta+\Psi_w(t).}\tag{T4}
\]
Consequently the singular penalty \(\theta\) cannot be removed from a *law-transfer theorem based only on a source-null error set*. The modulus \(\Psi_w\) is the smallest possible universal quantitative penalty for bounded loss at fixed reference-law risk. This is **not** a statement that the resulting Bayes prediction risk bound is always attained by an observability task.

### Proof

For any \(a\ge0\) and \(0\le L\le1\),
\[
wL=(a+(w-a))L\le aL+(w-a)_+.
\]
Integrate under \(\mu\), use \(\mathbb E_\mu L\le t\), and note \(\int L\,d\nu_s\le\theta\). Taking infimum over \(a\) proves the bound in (T4). Equality follows from the classical Neyman–Pearson threshold rule \(L=1_{\{w>a\}}+\lambda 1_{\{w=a\}}\) on the absolutely continuous part, with a boundary fraction \(0\le\lambda\le1\) chosen to exhaust the admissible \(\mu\)-budget, and \(L=1\) on a \(\mu\)-null support of \(\nu_s\). On general probability spaces this can equivalently be expressed with the decreasing rearrangement \(w^\downarrow\):
\[
\Psi_w(t)=\int_0^t w^\downarrow(s)\,ds,
\]
using a fractional boundary level as needed. If \(w\equiv0\), take \(L=1\) on the singular support and obtain \(\Psi_w\equiv0\). Dominated convergence proves \(\Psi_w(t)\to0\) as \(t\to0\): for fixed \(a\), the tail integral tends to zero as \(a\to\infty\), while the term \(at\) tends to zero for each fixed \(a\).

For (A), let \(E=\{x:\mathcal O(x)\ne f(x)\}\). Since \(\mu(E)=0\), \(\int_E w\,d\mu=0\); hence \(\nu(E)=\nu_s(E)\le\theta\). This is a **single fixed** policy: its source-null bad set is null for *all* dominated targets simultaneously. Absolute continuity need not be bounded.

For (B), use the pointwise bound \(\|F-\hat F_\mu\|\le2B\) and set \(L(x)=\|F(x)-\hat F_\mu(x)\|^2/(4B^2)\in[0,1]\). Its source mean is at most \(e/(4B^2)\). Apply (T4). For target Bayes risk, conditional expectation under \(\nu\) is the orthogonal \(L^2(\nu;H)\) projection onto the transcript sigma field, so it does no worse than the fixed reference-based predictor \(\hat F_\mu\). \(\square\)

### Important sharpness distinction

(T4) is exactly sharp **among all bounded measurable losses**. It does *not* certify that every extremizing loss can be represented as squared error of a low-degree adaptive observer. Such an identification would need additional construction and proof. The singular-mass exact error penalty is attained for source-null modifications such as \(f(x)=1_{\{x=0\}}\) under uniform \(x\in[0,1]\), when the source observer predicts zero and the target puts mass \(\theta\) at \(x=0\), supplemented by arbitrary absolutely continuous mass.

## Theorem 2. Necessary and sufficient uniform-transfer condition (classical equivalence + observer consequence)

Let \(\mathcal Q\) be a family of target probability laws with \(\nu\ll\mu\) for all \(\nu\in\mathcal Q\), and let \(w_\nu=d\nu/d\mu\). The following are equivalent:

1. **Uniform bounded-loss transfer:** \(\lim_{t\downarrow0}\sup_{\nu\in\mathcal Q}\Psi_{w_\nu}(t)=0\).
2. **Uniform integrability:** \(\{w_\nu:\nu\in\mathcal Q\}\) is uniformly integrable in \(L^1(\mu)\).
3. **Uniform absolute continuity:** for every \(\varepsilon>0\), there exists \(\delta>0\) such that \(\mu(A)<\delta\) implies \(\sup_{\nu\in\mathcal Q}\nu(A)<\varepsilon\).

Consequently, exactly this classical condition suffices for the *same Paper B reference-built observer* to have a common dimension-free quantitative approximation guarantee for **all** target laws in \(\mathcal Q\), expressed via the uniform envelope \(\sup_{\nu}\Psi_{w_\nu}\). This does not claim that uniform integrability is necessary for the performance of every particular fixed function or policy.

**Proof sketch with explicit quantifiers.** Uniform integrability gives \(\sup_\nu\int(w_\nu-a)_+\,d\mu\to0\) as \(a\to\infty\); for such a fixed \(a\), \(\Psi_{w_\nu}(t)\le at+\int(w_\nu-a)_+\,d\mu\), uniformly, proving 1. Conversely, for each \(a>0\), the set \(A_{\nu,a}=\{w_\nu>a\}\) has \(\mu\)-mass at most \(1/a\), so
\[
\int_{\{w_\nu>a\}}w_\nu\,d\mu
=\nu(A_{\nu,a})\le\Psi_{w_\nu}(1/a).
\]
Thus 1 forces the tails uniformly to zero, giving 2. Conditions 2 and 3 are the standard uniform-integrability characterization on a probability space, and follow by thresholding density tails and using the same sets. \(\square\)

**Failure without uniformity.** On \([0,1]\) with reference Lebesgue \(\mu\), let \(\nu_n\) be \(\mu\) conditioned on \([0,1/n]\) and \(L_n=1_{[0,1/n]}\). Each \(\nu_n\ll\mu\), yet \(\mathbb E_\mu L_n=1/n\to0\) and \(\mathbb E_{\nu_n}L_n=1\). There is no uniform rate over all dominated target laws. This is a **classical change-of-measure obstruction**, not a counterexample to Paper B.

## Theorem 3. Universal invariance of exact adaptive and fixed observation complexity under equivalent laws

Let \(\mathcal P\) be **any** specified class of measurable exact-observation policies—adaptive decision trees, fixed coordinate sets, or another precisely defined observation model—and let \(c:\mathcal P\to\mathbb N\) assign a worst-case whole-coordinate query cost to each policy. Let \(f\) be a fixed measurable target. For a law \(\rho\), set
\[
D_{\mathcal P,\rho}(f)=\inf\{c(\pi):\pi\in\mathcal P,\;\Pr_\rho[\pi(X)=f(X)]=1\},
\]
with infimum of an empty set equal to \(+\infty\).

**If \(\nu\sim\mu\) (mutual absolute continuity), then**
\[
\boxed{D_{\mathcal P,\nu}(f)=D_{\mathcal P,\mu}(f)
\quad\text{for every fixed policy family }\mathcal P.}\tag{T5}
\]

In particular, **both** exact deterministic adaptive depth and exact fixed-nonadaptive coordinate-query complexity, and hence their separation, are invariant under any equivalent law change. Neither law need be product: one reference may be a product, while the other has arbitrarily strong correlations. No bounded likelihood ratio is required. Under one-way domination \(\nu\ll\mu\) only the inequality \(D_{\mathcal P,\nu}(f)\le D_{\mathcal P,\mu}(f)\) holds generally.

**Proof.** For each fixed \(\pi\), its measurable error event \(E_\pi=\{x:\pi(x)\ne f(x)\}\) is \(\mu\)-null if and only if it is \(\nu\)-null when the laws are equivalent. Thus the feasible policies at **every** integer budget are identical. Their achievable cost sets and infima coincide. Apply separately to adaptive and nonadaptive policy classes. \(\square\)

**Infinite-gap corollary.** Under the product reference law of the degree-two address function \(f(K,(Z_j))=Z_K\), where \(K\) ranges over all positive integers with strictly positive probabilities and \((Z_j)\) are nondegenerate independent bits, exact adaptive depth is \(2\), whereas no finite fixed coordinate set determines \(f\) almost surely. For **every** correlated target \(\nu\sim\mu\), both complexities are *unchanged*. For instance the positive, bounded likelihood tilt \(d\nu_\lambda/d\mu\propto\exp(\lambda\,1_{\{Z_K=1\}})\) makes the address and individual fixed leaves (for example, K and Z_1) statistically dependent for arbitrarily large finite \(\lambda\), yet the exact adaptive/fixed gap persists.

**Lean formal scope.** The named declaration \`Nightfall.UniversalLawTransfer.every_policy_budget_invariant_under_equivalence\` quantifies over arbitrary measurable spaces, arbitrary abstract policy types, arbitrary prediction functions, an arbitrary cost map to natural numbers and every query budget; it proves the equivalence of feasible-budget existential statements under two mutual absolute-continuity premises. Only **this classical measure-transfer implication** is kernel certified if the pinned CI succeeds. The declaration does not formalize degree-two address lower bounds, a general query oracle, or the Paper A construction.

## Practical corollaries

- If \(w\le K\) \(\mu\)-a.s., then \(\Psi_w(t)\le Kt\). The stronger theorem does not *require* this restrictive assumption.
- If \(w\in L^p(\mu)\), \(p>1\), then Hölder yields \(\Psi_w(t)\le\|w\|_p t^{1-1/p}\).
- If the actual data law is *arbitrarily correlated but dominated by the product reference*, exact finite-palette recovery persists with **zero** increase in query count and no dependence on \(\|w\|_\infty\).
- For singular shifts, no guarantee better than the singular-mass term is possible from an observer whose correctness is known only source-almost surely. A stronger statement needs additional pointwise structural information about \(F\) on the singular support.

## Evidence, certificates and prior-art boundaries

**Analytically proved here:** the conditional observer transfer (T2)–(T3) assuming the source observer and its source-risk claim, the sharp general bounded-loss dual (T4), and the family criterion (Theorem 2). The sharp dual is a standard application of **Neyman–Pearson** threshold optimality and Lorenz/likelihood-ratio rearrangements. The uniform-integrability criterion is classical. Claiming global priority for either classical mechanism would be false.

**Finite formal kernel:** [FiniteLawTransfer.lean](FiniteLawTransfer.lean) proves the pointwise and finite-sum dual **upper bound** and a support-dominance exact transfer. It does *not* compile the infinite measure-theoretic equality or the source observability theorem. The [independent checker](check_sharp_transport.py) compares exact greedy sorted-ratio optimization, exhaustive primal extreme points and independent breakpoint dual for 2,760 finite probability pairs/thresholds. See [audit contract](AUDIT.md).

**Existing source observer:** [Paper A](../../../papers/exact-recovery/MANUSCRIPT.md) and [Paper B](../../../papers/spectral-adaptive-prediction/MANUSCRIPT.md), plus [pinned finite scalar Lean certificate](../formalization/product_space/FINITE_PRODUCT_INFLUENCE_PROOF_PASSPORT_20261110.md). Their open full-chain referee/priority gates are inherited; this theorem cannot cure them by change-of-measure algebra.

**Prior art checked on 11 November 2026:** Classical Neyman–Pearson test optimality (likelihood ratio threshold), uniform integrability / uniform absolute continuity, and density-ratio-based distribution shift. Relevant sources: [Berkeley Neyman–Pearson exposition](https://stat135.berkeley.edu/fall-2026/Modules/19-LikelihoodNPLemma.html); [Simchowitz et al., Statistical Learning under Heterogeneous Distribution Shift, ICML 2023](https://proceedings.mlr.press/v202/simchowitz23a.html); [Soltani Moakahr et al., Decision Tree Learning on Product Spaces, 2026](https://arxiv.org/abs/2605.12983). No source-to-source priority comparison has established global originality of the **combined observation transfer**. This remains a rigorous but **provisionally unoriginal synthesis** until stronger distinguishing content and independent external review are recorded.

**Next independent decisive test:** Ask an external referee to verify the exact full-condition inference from each Paper A/B source theorem, and search whether the identical reference-product/target-correlated observation formulation occurs in prior distribution shift, active query, stochastic process, and decision tree literature. For a genuinely new universal theorem, target a stronger structural result **not** implied merely by change of measure; otherwise retain this as a useful transfer lemma rather than flagship originality.

**Release gate:** source proof + exact finite checker + named Lean CI can certify the finite transfer kernel only; external mathematical review and global priority are *separate*. Repository merge must not be recorded as certified globally original mathematics.
