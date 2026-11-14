# Correlation-stable Aaronson–Ambainis transfer and stationary completion

**NIGHTFALL | research direction: Devin J. Wright | 13 November 2026**

**Status:** Source-preserving mathematical research branch. Author-side analytic derivations, three independent exact-rational adversarial checkers, a fourth correlated-block checker, and a dedicated CI replay. **No newly kernel-certified correlated theorem, independent human review, or established worldwide historical priority.**

## Source order and the principal change

1. [Hereditary correlated influence and adaptive observability](HEREDITARY_CORRELATION_THEOREM.md). Main result: if \(0<\alpha\le d\nu/d\mu\le\beta\), \(R=\beta/\alpha\), and f has reference-product Hoeffding degree<=d, then actual dependent heatbath influence satisfies
   \[
   \max_i I_i^\nu(f)\ge \frac{c_*}{R^{5/2}}\frac{\operatorname{Var}_\nu(f)^{5/2}}{B^3d^6},
   \quad c_*=\frac{\sqrt{3/12500}}{\pi^6}.
   \]
   This is hereditary after **every coordinate observation**; the exact total-influence drift holds even under arbitrary correlation. Consequently an ideal conditional-influence greedy observer reaches MSE<=eta after at most \(\min(n,\lceil4R^{7/2}d^7B^3/(c_*\eta^{3/2})\rceil)\) whole-coordinate reads.
2. [Two-scale block-product theorem](TWO_SCALE_BLOCK_THEOREM_20261113.md). Stronger **law class**: arbitrary, even singular, correlation within independent coordinate blocks of size<=s. A pointwise coordinate-degree<=d representation induces block-degree<=d, giving the original source-influence constant for **whole blocks**, and MSE<=eta after \(O(sd^7 B^3/\eta^{3/2})\) elementary reads. No global likelihood-ratio bound required. The proof is an elementary grouping corollary, not a historically novel product theorem.
3. [Parity-moment camouflage obstruction](PARITY_CAMOUFLAGE_20261113.md). Every reference degree< n monomial has unchanged expectation under a parity-tilted n-bit law, yet all heatbath influences satisfy \(I_i^\nu(f)=(2\tau-\tau^2)I_i^\mu(f)\) for *every* f. Under a hard parity constraint tau=0, nonconstant degree-one f may have **zero influence in every coordinate**. Hence covariance/moment preservation is insufficient for arbitrary correlated AA.
4. [Multiclass completion under stationary coordinate channels](STATIONARY_COMPLETION_20261113.md). Beyond the polynomial-degree route, draw independent uniform class shifts, extend a partial q-label function using classical adversary-like source weights, and certify total expected edge-disagreement energy \(\le\sum_b K_b\) for **arbitrary correlated, possibly singular, stationary laws and even nonreversible coordinate-local update channels**. This does **not** yield a correlated maximum-influence lower bound; it extends only the completion step.
5. [Proof passport and historical/algorithmic limits](PROOF_PASSPORT_20261113.md).

## Frozen certificate foundation

The *imported* theorem is [Lean #317](../formalization/product_space/FINITE_PRODUCT_INFLUENCE_PROOF_PASSPORT_20261110.md), historical pinned Lean 4.33.0, with the dependent heterogeneous-alphabet finite supplement [#325](https://github.com/d3lefts/d3lefts/pull/325). Its formalized coefficient is \(c_*=\sqrt{3/12500}/\pi^6\), not the sharper *uncompiled* dissertation constant. The source theorem itself builds on David Turturean's 2026 uniform-cube proof, arXiv:2611.09773. The completion route is motivated by Huffstutler–Miloschewsky–Podder arXiv:2611.12795, which is more general for the uniform Boolean query model because it works with a classical adversary measure.

## Independent exact checks

Run from this directory with Python >=3.11, standard library only:

    python3 check_correlated_transfer.py
    python3 check_parity_camouflage.py
    python3 check_stationary_completion.py
    python3 check_block_coarsening.py

Local original research runs were:
- 82 correlated-law perturbations, 1,798 posterior sections and 2,594 exact dependent-law influence drift tests; singular counterexample.
- 1,584 parity influence identities, 108 low-degree moment/covariance comparisons, 1,836 monomial equalities.
- 320 stationary completion models, 181 exact continuous two-class shift integrations, 139 three-class rational-grid cases (with an explicit finite-grid slack), 120 nonreversible stationary kernels.
- 110 arbitrary block-correlated product laws, 514 macroblock degree component checks, 221 block posterior drift identities and 84 zero-atom cases.

The branch CI replays the committed scripts separately. **These checks cannot establish universal theorem validity, quantum-query claims, authenticity of a real product law, or historical novelty.** They are finite counterexample searches and exact regression checks.

## Prior art and priority caution

- Turturean, *A proof of the Aaronson–Ambainis conjecture*, arXiv:2611.09773 (6 November 2026).
- Huffstutler, Miloschewsky, Podder, *A short proof of the Aaronson–Ambainis Conjecture via the completion framework*, arXiv:2611.12795 (9 November 2026).
- Blanc, Docter, Strassle, Tan, *Proof of the Aaronson–Ambainis Conjecture: An Exposition*, arXiv:2611.11626 (8 November 2026).
- Holley–Stroock bounded perturbation and classical conditional variance comparisons; grouping coordinates into independent blocks is standard coarse-graining.
- Classical parity character orthogonality and t-wise independence; standard randomized threshold/Lipschitz completion ideas.

Do not claim the individual tools above are original. The present candidate is their carefully scoped composition under explicitly different oracle conditions, and worldwide subsumption remains unverified.

## Next decisive experiment

A historically significant gain would require an **hereditary local Dirichlet/coercivity certificate** that remains dimension-free even when the global density ratio R is exponential in the number of weakly dependent blocks. The block grouping result proves such a structural bypass exists in one broad model, but does not provide efficient *fine-coordinate* observation under arbitrary internal correlations. Test any proposed bound against the parity-camouflage family and against the exact source influence identity, not against marginal moments alone.

**Stop rule:** do not repeatedly polish constants of the existing bounded-ratio transfer; seek a new source-aware operator connecting low-degree structure to *conditional-coordinate* observation under broader correlations. Preserve failed reductions and exact counterexamples.