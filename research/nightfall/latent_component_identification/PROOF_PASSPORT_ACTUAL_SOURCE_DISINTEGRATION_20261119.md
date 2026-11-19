# Proof Passport — Zero-atom actual-source component disintegration

**Date:** 2026-11-19  
**Status:** Lean kernel-certified finite-product *low-TV branch and source identity*. The full bounded-K component classifier, quantum product transfer, and strong mixture theorem remain unfinished.  
**PR:** https://github.com/d3lefts/d3lefts/pull/899  
**Exact source commit:** `182a74c5aab68f0bd3aaf7cdd40b1d97d72ddad2`  
**Pinned CI:** https://github.com/d3lefts/d3lefts/actions/runs/44569554567 (SUCCESS)  
**CI job:** `135720555604`; complete 56-module source closure + named axiom audit  
**Lean:** 4.36.0-rc2, Mathlib `9d581dfff2e41de989072ea63abf3daf69311520`.

## Exact construction and mechanism

Given finite coordinate index I, finite symbol alphabet Σ, arbitrary nonnegative and normalized coordinate laws p_i (zero atoms permitted), and A⊆I with a designated dummy symbol a₀, define:

```
observedLaw A a₀ p i a = if i∈A then p i a else δ_(a₀)(a)
pin A x p i a         = if i∈A then δ_(xᵢ)(a) else p i a
prodMass p x          = ∏_(i∈I) p i (xᵢ).
```

Drawing a transcript X from `observedLaw` and a second Y from `pin A X p` reproduces the actual original product law for **each source outcome** y:

```
∑_x prodMass(observedLaw A a₀ p)(x)
      * prodMass(pin A x p)(y)
  = prodMass(p)(y).
```

Consequently, for every event E on original source inputs, integrating the conditional event probability given the observed transcript reproduces the unconditional source event probability. Applied to the event `|f(y)-u|>ε`, the source failure-mass identity is exact, **not** a bound or an assumption about rare cells.

## Named kernel checks

CI compiles and prints axioms for:

- `Nightfall.MarginFreeDisintegration.observed_then_pin_mass`
- `Nightfall.MarginFreeDisintegration.observed_then_pin_failure`
- `Nightfall.MarginFreeDisintegration.observed_component_low_tv`
- `Nightfall.MarginFreeIntegrated.weighted_pinned_component_overlap`
- `Nightfall.ProductSpace.PinnedConditional.pinned_small_mean_shift`
- `Nightfall.MarginFreeLargeGaps.high_tv_product_bayes_error`

Axiom dependencies: `propext`, `Classical.choice`, `Quot.sound` only; no `sorryAx` and no extra theorem axiom. Source-level 56-module closure passed. The strict provenance is tied to the exact SHA above; earlier runs failed on missing source file, namespace elaboration, and product-factorization tactic, and **are not** positive receipts.

## What the low-TV branch now proves

Take two known finite product laws P and Q, and observed coordinate set A such that all *remaining* coordinates have TV ≤γ, with 16d²γ≤ε. For f∈[0,1] of product interaction degree≤d, if source failure probabilities around centers u and v are ≤ρ_P and ≤ρ_Q, and |u−v|>3ε, then the Bayes overlap of the actual observed transcript laws is at most

```
(ρ_P + ρ_Q) / (|u−v| - 3ε).
```

This does not require a positive minimum atom. The `>3ε` separation is substantive: a merely `>2ε` lemma was previously falsified and must not be restored.

The high-TV branch separately proves a product likelihood error bound when every one of the K observed coordinates has TV≥γ and the explicit bound `log(1/ζ)≤Kγ²/2` is supplied.

## Remaining decisive interface

For a margin γ>0, define `L={i : TV(p_i,q_i)>γ}` *before observing responses*. Let K be an integer budget satisfying `Kγ²/2≥log(1/ζ)`. Construct and certify the two-branch nonadaptive test:
1. If |L|≥K, select exactly K members using `Finset.exists_subset_card_eq` or a deterministic `Finset` choice; restrict both laws to `{i // i∈S}`, apply `high_tv_product_bayes_error` on that subtype and transfer its likelihood error to the complete input.
2. If |L|<K, query all of L; every unqueried coordinate has TV≤γ. Apply `observed_component_low_tv` with the actual-source disintegration certificate, obtaining overlap ≤(ρ_P+ρ_Q)/(|u−v|−3ε).

Then assemble the pairwise tests with the **separately certified conditional finite-mixture terminal** from #893, and finally fill the upstream per-component strong-product and coherent-oracle hypotheses. Do not infer a full result from these separate certificates.

## Independent audit targets

Check zero-atom branches, dummy symbol dependence, exact support of transcript mass, empty sets, the K=0 and ζ≥1 parameter regimes, strict vs weak TV threshold conventions, likelihood-classifier correctness from overlap, and query depth counted as distinct inspected coordinates. Review the chosen subset's product law reindexing. Compare to already-known TV/Hellinger results and prior art before novelty claims.

**Publication status:** existing certified poly(1/δ) product-mixture theorem remains headline; strong log(1/δ) result remains provisional.
