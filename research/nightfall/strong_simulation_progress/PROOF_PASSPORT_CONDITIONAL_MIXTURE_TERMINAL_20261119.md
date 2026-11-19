# Proof Passport — Conditional finite strong-mixture terminal

**Date:** 2026-11-19  
**Version:** 1.0  
**Certification level:** Kernel-checked conditional theorem, **not** end-to-end quantum strong mixture simulation  
**PR:** https://github.com/d3lefts/d3lefts/pull/893  
**Exact source commit:** `84b1c4c406940708539b77cff0194c70fd91b144`  
**Pinned source CI:** https://github.com/d3lefts/d3lefts/actions/runs/44569395411 (success)  
**CI job:** `135719985731`  
**Lean:** v4.36.0-rc2, Mathlib `9d581dfff2e41de989072ea63abf3daf69311520`

## Named theorem

`Nightfall.StrongMixtureTerminal.strong_latent_mixture_terminal_conditional`
from `research/nightfall/formalization/product_space/StrongMixtureTerminalConditional.lean`.

Theorem input:
* finite latent labels J and input space Ω;
* prior weights `π_j≥0` summing to one, and finite nonnegative component masses `p_j(x)`;
* true real target f, per-component deterministic predictions `estimate j x`, deterministic selection `select x`, and concrete lost-duel predicates `duelLost j x`;
* **explicit source hypotheses**, for every j: `Pr_(p_j)(|f-estimate_j|>ε)≤rho` and `Pr_(p_j)(duelLost_j)≤beta`;
* **explicit tournament implication**, for all j,x: if `|f(x)-estimate_j(x)|≤ε` and the true component loses no duel, then `|f(x)-estimate_(select(x))(x)|≤5ε`.

The theorem concludes the **actual mixture failure-mass** bound
```
Σ_j π_j Σ_x p_j(x) · 1[|f(x)-estimate_(select(x))(x)|>5ε] ≤ rho+beta.
```

The finite statement accepts zero component weights, unequal weights, and arbitrary overlapping duel events, and does not require independence of loss events. The source masses are assumed nonnegative; normalization of each source may be supplied by upstream construction. `hproduct`, `hduel`, and `hgood` are explicit, **unproved interface hypotheses at this boundary**. Nothing assumes the output succeeds.

## Verification

Pinned Lean kernel compiled and `#print axioms` reported only `propext`, `Classical.choice`, and `Quot.sound`. The module does not use `sorry` or a custom theorem axiom. Earlier iterations failed on undecidable arbitrary duel predicates and missing nonnegativity branches; exact-source fixes `0b3e8b77` and `58068a25` eliminated these failures. The full named terminal passed on the cited run. The kernel receipt does **not** certify the remaining premises.

## Missing composition obligations

1. Instantiate `hproduct` from source-exact BDST strong uniform-Boolean simulator + lazy conditional dyadic symbol-block decoder + normalized coherent quantum circuit.
2. Instantiate `hduel` from a fully sourced zero-atom classifier: high-TV coordinate selection, tensorized Hellinger test and weighted low-TV observed-source concentration, with correct positive separation margin.
3. Prove `hgood` from the actual frozen pairwise tournament selection algorithm (not merely a schematic implication).
4. Connect the true coordinate query budget to the final selected deterministic tree, including global weighted seed fixing (separate certified passport).
5. Independently review the full theorem and priority against BDST and other 2026 distributional variants.

**Publication status:** retain the established Lean-certified poly(1/δ) headline. No claim of a certified log(1/δ) quantum mixture theorem.
