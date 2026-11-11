# NIGHTFALL universal spectral observability — handoff checkpoint
**Date:** 2026-11-11 UTC. **Status as of original handoff:** scoped formal results merged, concrete posterior composition was in draft. Later 11 Nov CI supersedes the draft-only status below. NOT a complete Lean-certified universal theorem. Do not present it as independently refereed or as a proved global novelty claim.

## Exact immutable repository trail

- **Merged PR #341:** `AdaptiveBudget.lean`, five finite ANOVA-energy/unit-drift/budget declarations. Pinned Lean 4.35.0 receipts. This is an ABSTRACT stopping interface, not a realized posterior theorem.
- **Merged PR #343:** `RademacherOrthogonality.lean`, three weighted signed-ensemble identities. Does not provide every individual sign's covariance variance.
- **Merged PR #344:** `DiagonalSignCoherence.lean`, two pinned-Lean declarations, `diagonal_signed_variance` and `scalar_to_trace_with_coherence`. CI https://github.com/d3lefts/d3lefts/actions/runs/42972021272; merge SHA `689fda260df6f9724237c648893f3b329673d644`. The `hscalar` and `hcoh` hypotheses are EXPLICIT; neither is derived there from the actual finite-product influence theorem.
- **Merged PR #345:** `PosteriorRankBudget.lean`, three pinned-Lean declarations `potential_flow_identity`, `expected_kernel_drift`, `posterior_weighted_budget`. CI https://github.com/d3lefts/d3lefts/actions/runs/42972026337; merge SHA `5fcb65817e62a89dbf5e9964141bf40f4f01146e`. These work for arbitrary finite transition kernels satisfying the stated flow and drift hypotheses. No assertion of actual posterior drift.
- **Draft PR #346:** `ActualPosteriorInfluence.lean`. It defines `posteriorLaw` after a transcript `s : ι → Option α`: unchanged coordinate laws for `none` and Dirac laws for observed `some a`; `posteriorMass` is their finite product. Targets six pinned-Lean declarations: positivity, normalization, exact real signed-scalar resampling identity, and rank-times-vector resampling inequality.
  - Initial CI https://github.com/d3lefts/d3lefts/actions/runs/42973066803 **FAILED** because `posteriorLaw_nonneg` had an unsolved `if` positivity branch and the strict audit exposed `sorryAx` downstream.
  - Corrective source commit `8351101641a64213bcbc37d8741916a137e4e45b` explicitly case-splits `a = b`. **The six declarations must not be called certified before a green, strict new CI receipt.**
  - Preserve the failed run as evidence, not as a proof.

## Research target and verified versus conditional links

At a nonconstant finite-product posterior, let `G` be a bounded output in an active Euclidean covariance space of rank `s`. Write
`v = E ||G-EG||²`, `I_i(G)=E||G-E_iG||²`, `p=Σ_i I_i(G)`, `m=max_i I_i(G)`, and
`A_i=E[(G-E_iG)(G-E_iG)^T]`.
By exact ANOVA, `v ≤ p ≤ d v` (requires instantiation from the actual posterior; existing abstract energy lemmas are not this instantiation).

If a real scalar influence premise holds on each posterior section,
`max_i I_i(h) ≥ c D^(2-2q) d^(-β) Var(h)^q` for `|h|≤D`,
choose a posterior covariance eigenbasis, and let `ε∈{±1}^s`. Then each
`h_ε=⟨ε,G⟩` has `Var(h_ε)=v` and `|h_ε|≤sqrt(s)B`.
Define local coherence `κ=max_{i,ε} (εᵀ A_i ε)/tr(A_i)` over positive-trace `i`. Thus
`m ≥ [c B^(2-2q) d^(-β) s^(1-q)/κ] v^q`.
This is the **direct rank–coherence certificate**. The merged PR #344 only formalizes its finite algebraic diagonal-variance and abstract coherence composition; the complete scalar influence application with actual `A_i` is open.

For a coordinate query, the intended actual ANOVA identity is
`E_{X_i}[p(after observing X_i)] = p(before) - I_i(G)`.
The merged PR #345 formally telescopes finite transition-kernel drift under an explicit hypothesis. It does not derive that hypothesis from this actual identity. With `q=5/2,β=6,c=√(3/12500)/π^6`, the v7 candidate gives a rank–coherence-weighted stopping certificate. Its conditional scope and formulas are in `NIGHTFALL_Rank_Coherence_v7.pdf` (user source) and the repository `PR #332` all-degree analytic draft; do not confuse this with v6's sharper log-sign/PSD bound.

### Required nonduplicative follow-on work
1. **Concrete finite-product bridge:** identify `ActualPosteriorInfluence.scalarResamplingInfluence` definitionally or by a named equality with `Nightfall.ProductSpace.Influence.pinfl` at `p'=posteriorLaw p s`. Next prove actual posterior vector covariance and the signed scalar cross-term identities; instantiate `product_influence` on the posterior signed scalar section, including the boundedness and finite-degree hypotheses.
2. **Active-rank coherence:** prove PSD trace positivity for actual `A_i`, and the `κ≤s` fallback (plus exact `κ` improvement); derive conditional local progress `α(r/s)^(q-1)/κ` with all positive parameters and the r-referenced capped potential. Then connect the conditional ANOVA identity to the kernel drift argument in #345, and derive finite hard-cap/risk statement.
3. **Measurable products:** work from the exact finite theorem to rectangular conditional expectations and finite-coordinate approximation. Explicitly prove L² approximation, degree preservation, influence monotonicity, posterior conditional independence, measurable tie-breaking, and Hilbert spectral-tail risk. None is kernel-checked currently.
4. **Optional stronger branch:** the Gaussian/PSD moment inequality that replaces the fallback `κ≤s` by the logarithmic factor in v6 requires a separate analytic proof and adversarial audit, and must not be silently imported into the direct coherence proof.

**Verifier:** run `python3 scripts/lean_bridge.py <source>.lean --workspace /tmp/mathlib4 --timeout 480 --strict --allow-axiom Classical.choice --allow-axiom Quot.sound --allow-axiom propext --decl <each fully qualified name>` against pinned Lean 4.35.0/Mathlib v4.35.0, then `research/nightfall/formalization/product_space/check_receipts.py`. Preserve full sources, hashes, run ID, and axiom audit; no self-certification.

**Next decisive experiment:** inspect PR #346 repaired compiler receipt. If green, merge the finite posterior law/influence identities; otherwise keep draft and patch exact reported goals. Then formalize the equality to `pinfl`, rather than adding another abstract stopping theorem.

## Post-handoff correction — green actual-posterior certificate (11 November 2026)

The opening list is an immutable timeline, **not the current state** of PR #346. It later merged after repair; [CI #42973878336](https://github.com/d3lefts/d3lefts/actions/runs/42973878336) confirms six scoped finite posterior declarations. The initial failed CI remains a valid negative history, not the final result. The required full matching to `ProductInfluence.pinfl` and risk theorem remain separate. Do not quote the prior `Draft PR #346` line without this supersession. Routine normalized-posterior, sign isometry, generic weighted drift and block-sensitivity lemmas are in the [quarantined Lean inventory](../../../docs/lean-certificate-provenance.json), **not** additional original discoveries.
