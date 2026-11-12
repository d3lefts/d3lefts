# Spectral observability — formal theorem coverage and remaining gates

**Checkpoint:** 2026-11-10 (America/New_York) / 2026-11-11 UTC.  
**Principal source:** Wright, *Spectral Observability of Low-Interaction Systems*, research synthesis v5; related quadratic and cubic proof supplements.  
**Compiler:** official Lean 4.35.0, Mathlib v4.35.0, existing `scripts/lean_bridge.py` and fail-closed `check_receipts.py`.  
**Verified receipt:** [Actions run 42959881782](https://github.com/d3lefts/d3lefts/actions/runs/42959881782), source head `16f57381c036c9670e9ba478be511bd957584de4`.  
**Status:** **13 kernel-compiled declarations; NOT a formalization of the complete spectral observability or unrestricted cubic theorems.** Standard Lean axioms `propext`, `Classical.choice`, `Quot.sound` only; no `sorryAx` or custom axioms.

## Newly kernel-checked theorems

| Module | Declarations | Mathematical scope |
|---|---:|---|
| [CategoricalSignedProxy.lean](CategoricalSignedProxy.lean) | 4 | For arbitrary finite alphabets, signed proxy with weights `w≥0, Σw²=1` and sign vectors `ε²=1`: exact proxy total mass 1, squared-radius identity `Σ(w+ε−wS)²=m+1−S²`, and sharp **pointwise** `||Z||₁≤√(m+1)` |
| [TopInteractionCover.lean](TopInteractionCover.lean) | 5 | Nonnegative finite ANOVA energy tables: order≥3 interaction mass charged to a transversal `H`, bounded by `Σ_{i∈H}I_i≤|H|M`; addition of an *assumed* degree-two bound yields `V≤CB√M+|H|M` |
| [QuadraticEndpointMarkov.lean](QuadraticEndpointMarkov.lean) | 2 | The exact polynomial identity `q'(0)=-3q(0)+4q(1/2)-q(1)` and the classical `|q'(0)|≤8B` for bounded quadratic `q` on `[0,1]` |
| [SortedInfluenceTail.lean](SortedInfluenceTail.lean) | 2 | Dimension-independent deterministic `4q·Σ_tail bᵢ²≤A²` when the chosen `q` weights are not smaller than unselected weights and their total sum is ≤A, hence `Σ_tail bᵢ²≤A²/(4q)` |

Each is universally quantified over the appropriate finite domains, not merely an exhaustive small-instance test. Proof compilation and standard-axiom auditing cover the exact named statements. **Only these statements are kernel-checked.** They are mostly classical or routine algebraic inputs; mathematical novelty and credit remain with the relevant prior authors.

## Broader existing kernel coverage in repository

- PRs #317/#325: finite heterogeneous-product Aaronson–Ambainis influence theorem with the inherited `(5/2,6)` exponents and exact coefficient. This does **not** imply the improved degree-two `V²` bound for arbitrary alphabets.
- PRs #298–#312: the pinned finite-product two-sided certificate theorem, concrete overlap sampler, posterior one-step law, and a degree-dependent contraction under an explicitly matched ANOVA energy representation.
- Earlier Lean modules include exact fourth moment for Rademacher sums, weight removal, Boolean Efron–Stein degree equivalence, and finite ANOVA bookkeeping.

## Most consequential uncompiled proof obligations

1. **Unrestricted scalar degree-two variance-squared theorem** in the v5 paper: formalize the order-two Hoeffding expansion and coupling construction for every weighted matching; the pointwise `Σ oscillation_i≤16B` requires connecting the newly compiled quadratic switching lemma with genuine conditional-section maxima; prove the independent Hilbert-`L²` increment fourth-moment estimate; compose the resulting `V≤16(1+√3)B√M`. None of these major statements has a complete Lean declaration here.
2. **Hilbert spectral rank theorem and `Θ(r/η)` adaptive prediction:** prove the finite-sphere covariance inequality, rank projection/trace decomposition, genuine conditional expectation and measurable coordinate selection, full stopped-potential estimate, and the matched additive-sign lower construction. v5's paper proof and internal tests are not substitutes for compilation.
3. **Nonadaptive all-degree categorical theorem:** prove full independent fair-sign first and second *expectations* of signed proxy, moment preservation for multilinear sections, vector-valued Bonami interpolation, common-line Jordan/Chebyshev extrapolation, the exact ANOVA fixed-set prediction interpretation, and minimax lower bound. The new pointwise proxy norm and sorted-tail steps alone do not establish the theorem. **Do not claim an error in the original `√(m+1)` parameter**: PR #333 was retracted after visual inspection of the PDF showed the square root already printed.
4. **Restricted cubic top-cover theorem (#335):** connect the actual Efron–Stein interaction energies to `TopInteractionCover`, prove that integrating a transversal of all size-three supports produces a bounded degree-two observable with no larger influences, and import a verified quadratic scalar estimate. The independent disjoint-star and Hilbert rank transfers require their own proofs. No unrestricted cubic `(2,4)` claim follows.
5. **All-order linear interaction hypergraph theorem (v5 Section 6):** formalize activation parity couplings, exact greedy support assignment, residual disjointness of assigned supports, the Hilbert fourth-moment certificate and preservation of linearity under posterior restriction. The finite top-cover energy theorem does not establish this result.
6. **Infinite arbitrary measurable products (v5 Appendix A):** countable-coordinate support, finite rectangular approximations, strong measurability, simultaneous full-measure posterior sections, a measurable selection rule, and trace/risk convergence. Kernel certification of finite algebra does not certify these analytic bridges.

## Independent adversarial review and next decisive experiment

An independent proof checker should begin with **the quadratic matching-to-fourth-moment step**: it is the first missing load-bearing mathematical implication required by both scalar alphabet-independent exponent two and Hilbert rank-`r` observability. Specifically, test whether the assigned increments are conditionally independent given arbitrary categorical product laws and whether `E||Z_i||⁴≤c_i² E||Z_i||²+3(E||Z_i||²)²` holds with the claimed cost assignment. Reject a proof if an assumption about disjoint assigned supports has been silently strengthened.

For categorical nonadaptive observation, next formalize **moment matching for the proxy**; no amount of additional finite sign-table testing can replace a quantified theorem.

**Review gates:** source-exact statement matching; replayable Lean receipt and hashes; independent non-author proof review; dated prior-art comparison; and human publication authorization. Never promote candidate -> complete theorem -> novel discovery automatically.

## 12 November 2026 delta — scope, not a theorem promotion

The opening 13-declaration count is an **11 November selected batch**, not the full current registry. The [canonical source inventory](../../../../docs/lean-certificate-provenance.json) has 67 separately scoped Lean source files through #408. The new [actual Efron–Stein pair matching ledger](../product_space/ACTUAL_ES_PAIR_MATCHING_LEDGER_20261112.md) records eight strictly compiled true-source pair/rectangle declarations (Lean 4.33.0, receipt #43167542367); #407 adds genuine finite quadratic row/section proofs. Source-level global matching parity, unconditional arbitrary-law exponent-two, Hilbert rank/adaptive risk and arbitrary measurable lift are **still not complete end-to-end Lean theorems**. See the [active quadratic/rank passport](../../2026-11-active-passports/quadratic-rank-observability.md). The original dated 11 November record is preserved above.
