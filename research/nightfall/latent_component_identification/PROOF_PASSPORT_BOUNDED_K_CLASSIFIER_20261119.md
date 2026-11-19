# Proof Passport — Bounded-K zero-atom component overlap

**Date:** 2026-11-19  
**Version:** 1.0  
**Status:** Lean kernel-certified actual observed-product overlap theorem; **not** the end-to-end quantum mixture theorem.  
**PR:** https://github.com/d3lefts/d3lefts/pull/899  
**Exact source head:** `13af7af53ad06145a3761331ada40f8d19caaae2`  
**Pinned Lean job:** https://github.com/d3lefts/d3lefts/actions/runs/44573285471 (success), job `135733881450`  
**Lean pin:** `v4.36.0-rc2`  
**Mathlib pin:** `9d581dfff2e41de989072ea63abf3daf69311520`  
**File:** `research/nightfall/formalization/product_space/MarginFreeBoundedK.lean`.

## Exact certified claim

Let P=⊗ᵢpᵢ and Q=⊗ᵢqᵢ be arbitrary known finite-alphabet product laws with normalized nonnegative marginals, including zero atoms. Let f have product interaction degree ≤d with d≥1 and 0≤f≤1. Suppose f is concentrated about u under P with failure mass at most ρP and about v under Q with failure mass at most ρQ, both at radius ε≥0. Take a margin γ>0 satisfying 16d²γ≤ε, separated centers |u-v|>3ε, test tolerance ζ>0, and natural K with

```
log(1/ζ) ≤ K γ² / 2.
```

There exists a *nonadaptively selected* coordinate set A with |A|≤K such that the two-sided Bayes error of the observed-source transcript laws satisfies

```
Σ_x min(P_A(x), Q_A(x))
  ≤ max(ζ, (ρP+ρQ)/(|u-v|-3ε)).
```

The observed laws are defined on the original entire index set with a fixed dummy symbol outside A; there is no arbitrary-large alphabet, minimum atom or source-dimension factor in K.

## Certified construction

Choose L={i:TV(pᵢ,qᵢ)>γ}. If |L|≥K, choose S⊆L with |S|=K (Finset exact subset-cardinality theorem), query S, and prove its observed-product overlap ≤ζ via source TV²≤2H², Bhattacharyya tensorization and exponential product bound. If |L|<K, query L and invoke the certified source disintegration plus pinned conditional mean-stability theorem. No pairwise test or concentration estimate is passed as an unverified analytic hypothesis: only source-level p,q,f hypotheses.

## Named kernel receipts

- `Nightfall.MarginFreeBoundedK.high_tv_observed_bayes_error`
- `Nightfall.MarginFreeBoundedK.largeTVCoords_small_complement`
- `Nightfall.MarginFreeBoundedK.largeTVCoords_large_members`
- `Nightfall.MarginFreeBoundedK.bounded_K_component_overlap`
- `Nightfall.MarginFreeLikelihood.likelihood_two_sided_error_eq_overlap`
- `Nightfall.MarginFreeLikelihood.likelihood_observed_locality`

The exact run compiled the full 56-module source closure and the new modules. Printed axiom receipts use only `propext`, `Classical.choice`, `Quot.sound`. No `sorryAx`. The first attempted run failed because the `tvd` namespace was omitted; this was repaired before the successful receipt.

## Quantitative consequence

With γ=ε/(16d²) and ε>0, the scalar budget becomes

```
K ≥ 512 d⁴ ε^(-2) log(1/ζ).
```

For a T-query quantum acceptance function *once its degree≤2T transfer is supplied*, this corresponds to K≥8192 T⁴ ε^(-2) log(1/ζ). The theorem does not supply or certify coherent quantum acceptance itself. The inequality in this paragraph is an arithmetic substitution, not a claim that this source theorem already handles a quantum oracle.

## Certification boundaries

The exact-source proof **does not** include the constructed likelihood decision as the final named theorem, the original-input-to-observed-transcript pushforward, or the original-input two-sided error identity; these are the subject of subsequent files `MarginFreeLikelihoodDecision.lean`, `MarginFreeClassifierTerminal.lean`, `MarginFreeObservationPushforward.lean` and `MarginFreeOriginalClassifier.lean`, whose later exact-head CI must pass before promotion.

The theorem also does not prove per-component BDST strong product simulation, coherent lazy query decoding, frozen pairwise tournament integration or an M-source end-to-end theorem. The already certified poly(1/δ) manuscript headline remains unchanged.

## Independent adversarial checks

3,000 randomized finite Bernoulli-product cases with exact Fraction arithmetic found no violation of the high-TV exponential error bound. An additional 850 exact cases verified the original-input likelihood-rule two-sided error equals observed Bayes overlap, and 3,778 exact cases verified observation pushforward equality. These are finite counterexample searches, not universal proofs. They did not constitute an independent human referee review.

**Next formalization gates:** certify original-input likelihood/pushforward modules and combine the source tests with weighted posterior duels; separately formalize quantum-oracle/BDST semantics.
