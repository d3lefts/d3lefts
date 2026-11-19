# Proof Passport — hybrid-coupled bounded-round simulation
Version 0.2 · 2026-11-19 · NIGHTFALL

## Claim and certification boundary

**New paper-level construction (not a complete Lean-certified theorem):**
for a known arbitrary finite-alphabet product input law P (zero atoms
allowed), a t-query, d-round coherent-value-oracle algorithm admits a
deterministic symbol decision-tree simulator with error ε, failure δ,
depth bounded by

    S(2mt, 2d, ε/2, δ/2)
    with m ≥ max(ceil(log₂(A(A−1))),
                 ceil(2log₂ A+2log₂(16t/(εδ)))),

where A=max_i |Σ_i| and S is the established uniform-Boolean BDST
strong-simulation bound. The classical query overhead is polylogarithmic
in 1/δ for fixed d, and there is **no min-atom c** in this *product* result.

**Positive-margin mixture corollary, paper-level:** A hybrid-coupling
classifier with γ-cutoff θ=c ε²/(64t²) and
K=ceil(8192 t⁴ c^(-2) ε^(-4) log(1/ζ)) queries combines with the
frozen weighted-duel theorem to give a known-M-mixture simulator
of depth M S(2mt,2d,ε/2,ρ/2) + binom(M,2) K, 5ε accuracy,
δ failure (ρ,ζ set at scale εδ/M and δ/M). This corollary applies
to quantum acceptance functions, NOT arbitrary bounded low-degree
functions. **The full corollary is not in Lean.**

**Source:** research/nightfall/strong_simulation_progress/
STRONG_PRODUCT_HYBRID_COUPLING_20261119.md

## Certified Lean kernels on PR #893

- [Run 44547090800](https://github.com/d3lefts/d3lefts/actions/runs/44547090800):
  component identification, weighted posterior duel and scalar error budget,
  standard axioms.
- [Run 44552000305](https://github.com/d3lefts/d3lefts/actions/runs/44552000305):
  StrongMixtureUnion.lean finite event cover, component failure mass,
  mixture event mass equality and bound, standard axioms.
- [Run 44554354047](https://github.com/d3lefts/d3lefts/actions/runs/44554354047):
  QuantumHybridWeightedExpectation.lean *first three* theorems:
  weighted_sqrt_le_sqrt_budget, query_weighted_mismatch_mean_le,
  query_weighted_sqrt_discrepancy_le. The kernel printed only
  propext, Classical.choice, Quot.sound. Subsequent extension to
  conditional_hybrid_mean_le and conditional_hybrid_failure_le is
  under a **separate, not-yet-verified CI run**, not covered by the
  cited passing certificate.

## Independent exact checks and parallel division

- PR #895: one-sided dyadic rounding, including zero atoms, conditional
  seed-block checker; exact arithmetic checks are not a proof of the
  quantum oracle model.
- PR #896: finite likelihood and product-affinity/high-TV component
  classification.
- PR #894: independent bias-free degree-d stability and counterexample
  to merely |u−v|>2ε identification; not required for the
  positive-margin *quantum-only* fallback.
- PR #897: explicit dyadic fixed-point and smoothing certificates,
  useful as fallback but no longer necessary for hybrid product transfer.

Coordination requests were posted to all four PRs with precise assignments
and the revised proof route. No merges authorized or performed.

## Remaining real obligations

1. **Quantum hybrid semantics:** formalize the precise unitary
   value-oracle model, the telescoping state-vector norm inequality,
   and acceptance probability conversion, with all t query slots
   and possibly parallel query registers.
2. **Coherent finite-alphabet pullback:** model reversible computation
   of the block decoder g_i(U_i), two m-bit oracle rounds per original
   round, and the query-count bound 2mt without hidden assumptions.
3. **Conditional decoder:** give a Lean source-level proof of the
   one-sided dyadic p→q coupling, positive support for the uniform
   block preimage, product/joint laws and lazy persistent U_i|X_i.
4. **Actual product likelihood test:** product Hellinger tensorization,
   the high-TV cutoff and conditioning under frozen preliminary
   transcript with zero/missing-coordinate treatment.
5. **Full composition:** combine quantitative external BDST theorem
   contract, hybrid law, randomized-to-deterministic seed averaging,
   and the certified event/mixture tournament into one Lean theorem.
6. **Human review and prior art:** independent non-author mathematical
   review and dated detailed novelty audit. A successful CI run is not
   a human or novelty certificate.

## Most economical next experiment

Use a 1-query coherent value-oracle model over two finite coordinates.
Prove the telescoping inequality in Lean with explicit query-projector
weights; then generalize by induction over t and run the exact
source-pinned workflow. If the oracle bridge fails, identify the exact
representation mismatch rather than promoting the analytic argument.

### Current promotion status

The finite combinatorial/Jensen core is certified on the cited
commits. The **strong product and mixture theorems remain paper-level
and provisional**. The previously Lean-certified general
poly(1/δ) mixture theorem remains the established preprint headline
until those obligations are closed.
