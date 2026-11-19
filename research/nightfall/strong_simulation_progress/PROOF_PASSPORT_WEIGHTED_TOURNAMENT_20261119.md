# Proof Passport — Strong latent-product component-identification core

**Passport version:** 1.0 (2026-11-19)
**PR:** https://github.com/d3lefts/d3lefts/pull/893
**Certified source commit:** `67965c09a39e892808a4a0103f617bf21244d9e9`
**Kernel check:** https://github.com/d3lefts/d3lefts/actions/runs/44547090800
**Workflow:** `.github/workflows/nightfall-component-identification.yml`
**Compiler:** Lean 4.36.0-rc2; exact Mathlib commit `9d581dfff2e41de989072ea63abf3daf69311520`
**Axiom audit:** `#print axioms` for nominated declarations; only `propext`, `Classical.choice`, and `Quot.sound`. No `sorryAx` in checked declarations. This is a **partial mathematical certificate**, not certification of the full theorem.

## Lean sources, verified named results

1. `research/nightfall/formalization/product_space/ComponentIdentification.lean`:
   `mean_near`, `cell_cost`, `pay_per_cell`,
   `component_identification_core`,
   `min_le_sqrt_mul`, `prod_one_sub_le_exp`, `hellinger_K_le`.
   **Scope:** bounded [0,1] conditional means, separation paid by bad mass, finite overlap budget, abstract Hellinger cutoff. The mean shift enters as an **explicit hypothesis** `hBern`, not as a theorem of this file.
2. `research/nightfall/formalization/product_space/ComponentIdentificationWeightedTournament.lean`:
   `weighted_overlap_from_pointwise_cost`,
   `weighted_overlap_le_failure_div`,
   `pair_error_budget_scaled`, `pair_error_budget`,
   `strong_rounding_four_eta`, `undefeated_output_accuracy`.
   **Scope:** unnormalized, unequal-posterior-prior Bayes cost; finite low/high gap error combination; four-eta error algebra and 5-epsilon output geometry. The conditional test construction, affinity factorization and prior mass normalization remain hypotheses.
3. `research/nightfall/formalization/product_space/StrongMixtureDuel.lean`:
   `weighted_posterior_duel`, `five_epsilon_from_agreement`,
   `undefeated_is_accurate`.
   **Scope:** a second independent formulation of the conditional weighted Bayes-budget arithmetic and deterministic tournament correctness, with large/small gap leaf inequalities supplied as explicit hypotheses.

## Reproducible checker

The workflow runs:

```bash
python3 research/nightfall/strong_simulation_progress/component_id_nonvacuous_check.py
cp research/nightfall/formalization/product_space/ComponentIdentification.lean /tmp/mathlib4/
cp research/nightfall/formalization/product_space/ComponentIdentificationWeightedTournament.lean /tmp/mathlib4/
cp research/nightfall/formalization/product_space/StrongMixtureDuel.lean /tmp/mathlib4/
cd /tmp/mathlib4
lake env lean -o .lake/build/lib/lean/ComponentIdentification.olean ComponentIdentification.lean
lake env lean -o .lake/build/lib/lean/ComponentIdentificationWeightedTournament.olean ComponentIdentificationWeightedTournament.lean
lake env lean -o .lake/build/lib/lean/StrongMixtureDuel.olean StrongMixtureDuel.lean
```

The CI log includes axiom printing on the named declarations. The exact
Python test covers: a nonvacuous 9-bit-majority overlap inequality,
a nonempty small-gap set with nonzero mean shift, and a regression
counterexample against the *incorrect* weighted-prior overlap factorization.
A successful numerical test is **not** a theorem certificate.

## Claims *not* kernel-certified

- The real-polynomial Bernstein or Markov derivative inequality along the product-law marginal interpolation, and its application to the true product means (not merely a scalar hypothesis).
- The exact component-identification theorem with its `K=O(d² log(1/δ)/(ε²c²))` coordinate selection and genuine product Hellinger tensorization.
- The strong uniform-to-product transfer: finite-alphabet coherent quantum oracle query substitution, dyadic rounding, conditional block sampling, deterministic seed selection, and the binomial polynomial failure-event envelope.
- Explicit simulator-depth block-size fixed point tied to **specified** BDST constants.
- The full algorithm integrating component trees, conditional tests and mixture failure accounting into an unconditional end-to-end decision tree theorem.
- Any bias-free margin removal from PR #894, novelty claim, non-author mathematical review, or publication claim.

## Certification status

| Claim | Status |
| --- | --- |
| Finite mean/failure and overlap inequalities | **Lean kernel certified** |
| Finite weighted unequal-prior conditional duel error accounting | **Lean kernel certified conditional implications** |
| Scalar event-error and winner-accuracy composition | **Lean kernel certified conditional implications** |
| Positive-margin component identification with Bernstein | **Partial; analytic and law bridges open** |
| Strong biased-product simulation | **Paper argument; not Lean certified** |
| Strong bounded-round mixture simulation | **Provisional; not Lean certified** |
| Bias-free stronger proposal (#894) | **Separate provisional research result** |

**Independent non-author review:** None recorded. Kernel checking is an
independent mechanical proof checker, not a substitute for external
mathematical review of assumptions and theorem scope.

**Next cheapest decisive proof gate:** Formalize the actual probability-law
finite-product Bernstein/Markov stability inequality and the factorization
of Bhattacharyya affinity (not supplied as named hypotheses). Then certify
the dyadic decoding transfer and finally assemble the full mixture theorem.
