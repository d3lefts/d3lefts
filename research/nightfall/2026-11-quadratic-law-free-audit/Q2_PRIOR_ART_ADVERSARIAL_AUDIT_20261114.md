# Q2 degree-two product-space variance–influence theorem: adversarial priority dossier

**Audit version:** 2026-11-14 / v1.0. **Research program:** NIGHTFALL / Devin J. Wright, AI-assisted research and formalization. **Status:** *first-known candidate* for the **specific quantitative uniform-in-law theorem**, not independently adjudicated world priority or publication acceptance. Public sources searched this session; no earlier equivalent theorem found in the examined corpus.

## A. Exact target and source certificate

Fix finite coordinates `ι`, finite alphabet `α`, any family of normalized distributions `p_i` on `α` (nonidentical, arbitrarily biased, zero atoms allowed), and bounded real `f:α^ι→ℝ` with **original-source Efron–Stein degree ≤2**. Let `B≥0` satisfy `|f(x)|≤B` for **all** configurations. Set `V=Var_p(f)`, `M=max_i I_i^p(f)`, where resampling influence is `I_i^p(f)=E_{X_{-i}} Var_{X_i~p_i} f(X)` (check exact normalizations when comparing another author).

Verified target:
```
Var_p(f)^2 ≤ K^2 B^2 M
K = 5√3 + 2(1+√2)(√13−√3) + 8√((5√5−11)/6)
K² ≈ 364.5526832774
```
**Lean source** `research/nightfall/formalization/observability/ActualSourceQ2364Terminal.lean`, declaration `Nightfall.Observability.ActualSourceQ2364Terminal.actual_source_q2_364_unconditional`.
**Merged PR** https://github.com/d3lefts/d3lefts/pull/525 ; **exact-head successful Lean 4.36.0-rc2 axiom-audited run** https://github.com/d3lefts/d3lefts/actions/runs/43644790107 at `a558a4dd7a2f2c7db521658c6d59d204758eb934`. The named terminal itself assumes no external section/moment/influence inequalities; it constructs these from original `p,f`.
This is **not** an unrestricted-degree, arbitrary dependent-measure, continuous-alphabet, or infinite-product theorem.

## B. Strict equivalence / anticipation test

A genuine earlier competitor must either (i) explicitly prove, for *every* finite independent product law, finite (potentially different) alphabets and all real-valued degree≤2 bounded functions, `M≥c V²/B²` with **absolute c>0 independent of all biases, dimensions and alphabet sizes**, or (ii) give a **rigorously explicit derivation** of such a bound from a published stronger theorem, preserving the degree, source measure and **resampling influence normalization**. Merely proving existence of some influence with a weaker power of V or law-dependent constant is **not mathematically equivalent**. A genuinely stronger prior theorem *would* defeat novelty even if it uses different terminology.

Do not conflate:
- **low-degree existence** of an influential coordinate and the **quantitative exponent two**;
- fixed bias `p` or min-atom-dependent constants and **uniformity as biases tend to zero**;
- Boolean-valued outputs and arbitrary real-valued bounded outputs;
- uniform Boolean hypercube and arbitrary heterogeneous finite alphabets;
- coordinate flip sensitivity and resampling-variance influence (normalize conversion explicitly);
- kernel proof, first public disclosure, originality, and independent human review.

## C. Closest published sources checked 2026-11-14

1. **David Turturean, _A proof of the Aaronson–Ambainis conjecture_, arXiv:2611.09773, 6 Nov 2026.** https://arxiv.org/abs/2611.09773 ; full exposition https://www.paperpeel.com/paper/2611.09773 . Proves general degree d for **uniform Boolean cube** with `max Inf_i≥c Var^(5/2)/d^6`. Our finite-product result has stricter variance exponent for degree 2 and broader source law; no explicit exact comparator or product-law-uniform result found in its stated theorem. An unrecognized reduction from its combinatorial certificates is a remaining audit question.

2. **Uma Girish, Kunal Mittal, Barak Nehoran, Ran Raz, _Distributional Variants of the Aaronson–Ambainis Conjecture_, arXiv:2609.35327, 28 Sep 2026.** https://arxiv.org/abs/2609.35327 . Theorem 4.3 compares the AA property on **fixed-bias iid Boolean laws** and uniform Hamming slices; Remark 4.4 explicitly says the transferred polynomial bounds depend on the bias via `min(p,1-p,...)`. Does not explicitly yield universal-bias, heterogeneous arbitrary-alphabet variance-squared degree-2 inequality. A nontrivial uniformization of the paper's gadgets would need proof.

3. **Irit Dinur, Ehud Friedgut, Guy Kindler, Ryan O'Donnell, _On the Fourier tails of bounded functions over the discrete cube_, STOC 2006, Israel J Math 2007.** https://doi.org/10.1007/s11856-007-0068-9 . Strong uniform-cube junta/tail dichotomy; not an arbitrary-biased finite-product theorem. Corollaries may provide weaker quantitative low-degree influence. Explicit derivation of the all-laws exponent-two estimate would be new evidence, not supplied in the cited scope.

4. **Yuval Filmus, Hamed Hatami, Nathan Keller, Noam Lifshitz, _On the sum of the L1 influences of bounded functions_, 2014.** https://arxiv.org/abs/1404.3396 . Uniform Boolean cube, dimension-free `L1` total influence upper bound `d²`. One can combine low-degree **unbiased** hypercontractivity and this bound to derive a variance-squared estimate for degree two on the uniform cube, so **do not claim that the exponent-two cube special case is new**. The missing ingredient in general laws is bias-independent conversion from source sections to quadratic energy.

5. **Hamed Hatami, _Decision trees and influences of variables over product probability spaces_, Comb Probab Comput 18 (2009), 357–369.** https://doi.org/10.1017/S0963548309009833 . Product-space decision-tree/junta approximation for **Boolean-valued** outputs under bounded total influence; exponentially large decision-tree depth `exp(O(I_f/ε²))`, not the present real-valued, universal quadratic-in-variance influence estimate. Must inspect full proof for a nontrivial extension to bounded real degree-two outputs.

6. **Elchanan Mossel, Ryan O'Donnell, Krzysztof Oleszkiewicz, _Noise stability of functions with low influences: invariance and optimality_, Annals of Mathematics 171 (2010), 295–341.** https://annals.math.princeton.edu/2010/171-1/p05 . Invariance for low-degree polynomials over general product spaces under mild **regularity/hypercontractivity** conditions. Check whether the invoked parameters remain uniform as minimal atom tends to zero. No unconditional bias-uniform exponent-two influence conclusion identified in its stated abstract.

7. **Nathan Keller, _On the influences of variables on Boolean functions in product spaces_, Comb Probab Comput 20 (2011), 83–102.** https://doi.org/10.1017/S0963548310000234 . General product spaces, Boolean functions and multiple influence definitions; generalized BKKKL/sharp threshold, not a stated degree-two real-valued variance-squared theorem.

8. **Geoffrey Grimmett, Svante Janson, James Norris, _Influence in product spaces_, Adv Applied Prob 48 (2016), 145–152.** https://doi.org/10.1017/apr.2016.46 . Very general product-space influence inequalities, but not the claimed low-degree real-valued `Var²` dimension-free statement. Verify normalization and possible Boolean encoding reductions.

9. **Demeter Kiss, _A generalization of Talagrand's variance bound in terms of influences_, 2010.** https://ir.cwi.nl/pub/16786/16786B.pdf . Finite-valued coordinate extensions of Talagrand, not a published formula identical to our uniform-in-atom `Var²` bounded-degree-two estimate; investigate constants with alphabet/min atom.

10. **V. de la Peña, S. Montgomery-Smith, J. Szulga, _Contraction and decoupling inequalities for multilinear forms and U-statistics_, Ann Probab 1994.** Related universal quadratic-chaos decoupling, not (from abstract) a bound on max coordinate influence vs total variance under a **uniform bound on f**. A formally instantiated corollary would count as prior art.

11. **Shmuel Friedland, Lek-Heng Lim, _Symmetric Grothendieck inequality_, 2020.** https://arxiv.org/abs/2003.07345 . Dimension-free quadratic-form norm comparison, not explicitly a distribution-free Efron–Stein influence theorem. This is a high-risk implication route requiring direct calculation.

12. **Itay Glazer, Dan Mikulincer, _Anti-concentration of polynomials: dimension-free covariance bounds and decay of Fourier coefficients_, J Functional Analysis 2022.** https://doi.org/10.1016/j.jfa.2022.109639 . Dimension-free coefficient-variance lower bounds for fixed source laws, but constants depend on `μ` (the measure) and conditions include infinite support; not uniform over arbitrary finite product measures.

13. **Andrew J. Young, Henry D. Pfister, _On the maximal L1 influence of real-valued boolean functions_, 2024.** `p`-biased Boolean laws and KKL-type `ln n/n` dependence rather than a dimension-free low-degree variance-squared result.

14. **Ryan O'Donnell, Michael Saks, Oded Schramm, Rocco A. Servedio, _Every Decision Tree Has an Influential Variable_, 2005.** Its variance/revealment inequality is available for Boolean functions under arbitrary product laws; does not alone bound decision-tree revealment by a dimension-free function of variance for *all bounded real degree-two functions*.


15. **Littlewood's 4/3 inequality (1930), Bohnenblust–Hille (1931), and modern uniform Boolean cube BH bounds.** A sharp dimension-free bilinear coefficient norm bound is classical: for a bilinear form on `ℓ∞`, its coefficients satisfy the Littlewood 4/3 inequality; see https://pmc.ncbi.nlm.nih.gov/articles/PMC11090839/ and the Boolean cube benchmark https://teorth.github.io/optimizationproblems/constants/26a.html . These furnish a **serious high-risk algebraic antecedent**. Their stated theorems do not directly compare *resampling influences for arbitrarily rare symbols* to variance, but a hidden multilinear operator consequence might. A proof of a uniform-in-law estimate extracted from these would settle priority against us. Do not discount classical operator theory merely because its theorem lacks our terminology.

### Quantitative control: why the unbiased cube special case is not first

Under the uniform Rademacher law, derivatives of a degree-two `f` are affine linear Rademacher sums. Khintchine's `L²/L¹` equivalence therefore bounds `√I_i` by a universal multiple of its first absolute derivative moment. Filmus–Hatami–Keller–Lifshitz bound the **sum of those first moments** by `O(d²)||f||∞`. Summing the Rademacher `L²` derivatives and using `Var(f)≤Σ_i I_i≤√M Σ_i√I_i` therefore yields `Var(f)²≤C||f||∞²M` already on the uniform cube. For highly biased coordinates the same Khintchine `L²/L¹` step is **not uniform**: a centered two-atom variable concentrated at probability `p` can have `L²/L¹` ratio of order `p^{-1/2}`. This is exactly why citing the uniform-cube method is insufficient to anticipate our arbitrary-product result.


## D. Red-team tests that could kill priority

- **Grothendieck operator test:** instantiate symmetric/bilinear factorization of all canonical pair kernels, compare the original `L∞` bound and `L²` owner energies, and attempt to derive `Var²≤C B² max I` without extra bounded-density or minimum-atom assumptions. If successful from an earlier theorem, priority must be demoted, even if the earlier paper does not use the word 'influence'.
- **Finite-product encoding test:** seek an exact, quantitative reduction from arbitrary probability alphabets to the uniform cube preserving degree two, source variance and resampling influence with a bias-independent factor. An earlier uniform-cube quadratic theorem plus such an older reduction would be an equivalent predecessor.
- **Junta implication test:** compute the strongest exponent in `Var` from DFKO/Hatami/Friedgut and check whether a nontrivial sharpening to exponent two already appeared.
- **Talagrand/Keller/MOO test:** inspect all hypothesis constants near vanishing atoms and separate fixed-law bounds from truly universal bounds.
- **Preprint and unpublished overlap:** search arXiv, ECCC, journal indexes, specialized books, code and archived notes for a theorem under other names: bounded order-two Hoeffding chaos, ANOVA `Var²` influence, quadratic noise/certificate inequalities.

## E. Search audit and priority status

**Search interfaces this session:** web indexed articles/arXiv full HTML/Turturean PaperPeel, journals and preprints; independent SciSpace scholarly index queries targeting exact original-source `Var²` theorem, degree-two quadratic influences, heterogeneous product measures, Grothendieck and decoupling. Representative queries: `bounded degree two variance influence product space`; `quadratic chaos variance squared max influence arbitrary distribution`; `Aaronson Ambainis arbitrary alphabet bias-free`; `degree-two polynomial Grothendieck influence`; `low degree finite product real-valued influence`. Searches are **not exhaustive** and an implication may be hidden in unnamed intermediate lemmas.

**Observed result:** No published **explicit** prior theorem or published **verified implication** matching the exact quantifier/exponent/bias requirements was identified in the above inspected literature. **Priority state: strong first-known candidate for this precise formulation and proof architecture.** Earlier qualitative/special-case results clearly exist; this is NOT the original discovery of 'all bounded low-degree functions have some influential variable' nor of the variance-squared inequality on the uniform cube.

**Proof correctness gate:** pinned Lean original-source theorem PASSED at #525, distinct from novelty certification.
**Novelty gate:** still requires independent field-specialist *proof-of-non-implication check* or a documented earlier counter-reference. Even an expert cannot logically establish absence from all possible private notes; public priority should be dated to the earliest accessible immutable source or accepted preprint, with full contribution attribution.
**Publication gate:** obtain human author signoff before submitting or contacting outside experts on the author's behalf.

## F. Minimal referee brief

> We prove for all finite independent product measures with arbitrary heterogeneous finite alphabets, including vanishing atoms, an absolute-constant quadratic variance–influence inequality for bounded real Hoeffding-degree≤2 functions: `Var_p(f)²≤364.553 ||f||∞² max_i I_i^p(f)`. The source-level theorem passed a pinned Lean 4.36.0-rc2 named axiom audit. We know the 2007 uniform-cube DFKO theorem, 2014 total `L1` bound of Filmus–Hatami–Keller–Lifshitz, 2026 Turturean AA proof, and 2026 Girish–Mittal–Nehoran–Raz fixed-bias equivalence. Does a prior Grothendieck/decoupling/junta result already imply our **uniform-in-distribution variance-squared** statement? Please supply the exact earlier theorem and quantitative reduction, or identify the first unproved dependency.

## G. Research decision

**No further constant optimization should be necessary before making a manuscript and seeking adversarial priority review.** Threshold for novelty: cannot derive the all-laws exponent-two bound from preexisting results with a correct constant independent of dimension, alphabets and bias. Threshold for landmark significance: beyond independent novelty review, explain a consequence unavailable from weaker prior estimates or a transfer of the mechanism to broader distributions/complex systems.

**Archive provenance:** main theorem #525 and successful CI as above. This document is a dated audit, not a claim of peer review or universal negative proof.
