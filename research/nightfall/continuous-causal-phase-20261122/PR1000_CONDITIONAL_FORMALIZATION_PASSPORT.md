# PR #1000 formalization continuation — conditional proof passport v1

Date: 2026-11-22. STATUS: CONDITIONAL LEAN SOURCE, PINNED CI STATUS MUST BE CHECKED AT THE EXACT CURRENT PR HEAD. NO UNCONDITIONAL TOPOLOGY CERTIFICATE OR NOVELTY CLAIM.

## Problem and model

Input dimension n≥2, exact noiseless real intensity readings, m≤2n−2. The model is deterministic causal linear-functional sensing with continuous *row choice on actually reachable prefix sets*. Use length-indexed history encoded by reverse-chronological List ℝ and the Mathlib fixed-length list topology; this is equivalent to chronological Euclidean prefix coordinates up to reversal. Row selection is a total function on List ℝ valued in continuous real linear functionals; values off the attainable set are arbitrary, and only its restriction to the actual attainable image at each length must be continuous.

In ProductSphereCausalComposition.lean:
- CausalRows n : List ℝ → (Fin n → ℝ) →L[ℝ] ℝ.
- amp a : genuine-prefix intensity amplitude oracle.
- ReachableContinuous a := ∀ k, ContinuousOn a (Set.range (transcript (amp a) k)).
- testU/testV are physical genuine-prefix comparisons, indexed by U stages 0≤j<r and V stages r≤j<r+s.
- Both tests have the two *separate* sign characters required by the exact ProductSphereZero n r s interface, not just joint oddness.
- Continuous actual transcripts and both comparison maps are derived from ReachableContinuous using ContinuousOn.comp_continuous and Continuous.clm_apply. These maps never evaluate the original row selector on unreachable virtual histories.
- Given an explicit ProductSphereZero proof object, the theorem derives unit u,v, equal ACTUAL physical transcripts for u+v/u−v, and excludes both equality and opposite-sign equality.

ConditionalPhaseThreshold.lean:
- ExactRecovery a m means equality of actual physical intensity transcripts implies x=y or x=−y.
- no_continuous_causal_exact_recovery_below assumes n≥2, m≤2n−2, admissible reachable-prefix row continuity, and the one external topological family ∀r,s<n, ProductSphereZero n r s.
- Choose r=min(m,n−1), s=m−r, verify r,s<n, apply the conditional collision and derive a contradiction to ExactRecovery. This is a fully quantified all-dimensional lower bound *conditional on the stated classical topology theorem*.

Row-norm ≤1 is not needed for this lower bound; omitting it strengthens the algebraic claim. No randomized, discontinuous, block rank-k or known-norm-sphere result is asserted by this particular Lean terminal.

## Exact independent source provenance

- Baseline topology proof candidate: #995 (original author-side argument).
- Independent author-nonidentical mathematical audit: #1000 (Claude; not an external referee).
- Genuine-prefix causal algebra: #1008, copied here byte-for-byte at original Git blob 584d95ffca013872e5b19e0e30ac039440d36810. Do not treat source copying as new independent authorship or merge two copies blindly.
- Existing Mathlib-pinned pure-character ProductSphereZero interface and exact mod-two coefficient arithmetic: merged PR #1010, imported from main unmodified.
- Companion distinct noisy model and norm constraints: #1001. No noise theorem is imported into this certificate.
- Original complement-property construction upper count: #695. This PR proves only the conditional lower obstruction, not a fresh upper frame theorem.

## One remaining mathematical existence dependency

ProductSphereZero n r s is **a proposition**, NOT a theorem or axiom in our imported code. It says: every pair of continuous-on-sphere blocks with characters U-odd/V-even and U-even/V-odd has a simultaneous zero for 0≤r,s≤n−1. In a paper proof this follows from the known characteristic-class obstruction α^rβ^s in H*(RP^(n−1)×RP^(n−1);F₂). The elementary grid nonvanishing checks in #1010 do not formalize the bundle/cohomology nonvanishing-section implication.

Proof completion requires a Lean kernel proof of ProductSphereZero with no source-level new axiom, sorryAx, or supplied oracle. The present conditional proof has the topological proposition as a clearly printed theorem argument, so the Lean kernel does NOT treat it as an unconditional fact.

## Adversarial review and stop rule

1. Audit List topology on fixed-length components and comparison with original chronological Euclidean H_k; verify the row selector continuity scope is not strengthened.
2. Audit the parity transformations of genuine-prefix sums and stage indexing for r=0, s=0, n=2, m=0, non-full-rank/zero rows, and all-U/all-V colorings.
3. Check actual causal transcript equality, not virtual-history numerical equality, including sign non-equivalence.
4. Check the higher theorem's quantifier is ∀r,s<n ProductSphereZero n r s and not a per-policy zero witness.
5. Run the standalone CI at its exact PR head, inspect each named #print axioms receipt, and reject nonstandard axioms/sorryAx. Retain failed runs and source hashes.
6. Preserve separate model/scientific priority gates. Even a complete Lean proof of a classical topology implication would not establish publication priority of the phase-retrieval application.

STOP: conditional proof can be merged as an accurately scoped auxiliary after independent source review, but do not promote the all-policy theorem, register original novelty, or label PR #1000 breakthrough until the topology theorem and external review are actually completed.

## Discovery graph

Problem → reachable-only continuous causal rows → genuine-prefix comparison → independent sign characters and derived continuity → ProductSphereZero (still unproved in Lean) → joint test zero → actual collision → sign non-equivalence → conditional 2n−1 minimum alongside the existing full-spark upper construction.
