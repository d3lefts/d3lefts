# NIGHTFALL — Terminal Quadratic Variance–Influence Lean Audit

**Checkpoint:** 2026-11-13 (U.S. Eastern) / 2026-11-14 UTC. **Status:** in progress; NOT a terminal Lean theorem.  
**Parent:** [#468](https://github.com/d3lefts/d3lefts/pull/468) at `65faa846d606`.  
**Pin:** `leanprover/lean4:v4.36.0-rc2`; Mathlib `9d581dfff2e41de989072ea63abf3daf69311520`.  
**Audit branch:** `nightfall-q2-terminal-energy-v436-20261113`.

## Problem and contract

Take a finite coordinate set `ι`, a nonempty finite categorical alphabet `α`, nonnegative coordinate masses `p i a` summing to one (zero atoms allowed), and a real observable `f : (ι → α) → ℝ` satisfying `|f(x)| ≤ B` everywhere, `B ≥ 0`, and *canonical original-law Efron–Stein degree at most two*.

Write `V` for the genuine original-product variance, `I_i` for genuine resampling influence (half the squared two-draw difference), and `M = max_i I_i` when the coordinate type is nonempty (empty type separately gives `V=0`). The conditional target, **not yet derived from only these source hypotheses**, is

```text
V² ≤ 256 * (1 + sqrt 3)² * B² * M.
```

The source definition of degree must not be silently switched to an auxiliary polynomial or input law; finite sample labels must be actual distinct original coordinates. A bound with nonuniform categorical masses must not assume a positive atom floor.

## Verified current-pin building blocks (parent #468)

- `ActualSourceANOVA.lean`: literal original-product `es_decomp` and `actual_degree_two_source_decomposition`, strict compilation and allowed-axiom audit.
- `ActualSourceCanonicalIdentification.lean`: original-source singleton/pair conditional tables, double-centering, canonical pair `esComp` identification.
- `ActualSourceDegreeTwoSections.lean` plus `ActualSourceDegreeTwoAllDimensions.lean`: explicit degree-two-to-quadratic representation and source-only 8B section budget for all finite coordinate cardinalities.
- `ActualProductSourceDerivedStar.lean` and source soft-star orthogonality/Parseval prerequisites: original-source derived pair/singleton star properties; **not** the global owned-section energy comparison.
- `ActualSourceFiniteSampleLaw.lean`: exact joint law for *injectively enumerated original coordinates*, including first norm moments.
- `ActualSourcePairAmplitudes.lean`: source pair amplitude is attained as a finite maximum. This **does not** itself prove the source matching 4B bound.
- `QuadraticRealizedRangeBudget.lean`, `WeightedGreedyCover.lean`, `QuadraticActualMomentEndpoint.lean`: old graph/switching/Hilbert proofs recompiled under active pin.
- `ActualSourceQ2WeakScalarClosure.lean`: the final scalar implication, with separate `hsection`, `hcover`, `hmoment`, `hvariance`, owner-wise domination, and `T²=M` explicitly **assumed**.

Certified parent workflow examples: [canonical](https://github.com/d3lefts/d3lefts/actions/runs/43555451646) and [quantitative](https://github.com/d3lefts/d3lefts/actions/runs/43555451484), both passed for parent SHA `65faa846d606`.

## New source-energy proof ports in this branch

1. `ActualSourceInfluenceEnergy.lean` ports exact finite weighted centered/pair-difference algebra to the **current originalMass**, with an explicit source influence definition and proof goal `sourceSectionEnergy p f i = actualSourceInfluence p f i`. This is the missing influence identity and does not require the degree-two hypothesis.
2. `ActualSourceCanonicalCentering.lean` ports source conditional-update and Möbius-toggle centering for **every** canonical support.
3. `ActualSourceCanonicalOrthogonality.lean` ports pairwise orthogonality of distinct canonical supports in the *original law*.
4. `ActualSourceCanonicalVarianceEnergy.lean` ports exact Parseval variance identity and order-two truncation to the current definitions.

These newly ported modules have **provisional status until their strict current-pin workflow finishes successfully**. No `sorryAx`, `unsafe` import, or off-pin theorem counts as certification. The workflow emits compiled declaration and pin receipts.

## Remaining nontrivial source-to-terminal interfaces

1. **Global matching mass.** Recover for every *actual* vertex-disjoint subset of canonical pair supports the source-derived amplitude bound `sum w(e) ≤ 4B`, with unmatched sites and zero masses. Then use the independently proved weighted greedy matching mechanism for `sum c_i ≤ 8B`. A free `hmass` premise does not complete this.
2. **Owned distinct-neighbor representation.** Produce a simple graph of all genuine pair supports, an actual ownership orientation, and an injective enumeration of each owner's *distinct* neighbor set. Identify the resulting vector-valued section pointwise with the true conditional pair-sector, rather than sampling repeated independent copies.
3. **Owner energy/influence comparison.** Prove exactly (or with a certified `≤`) that `s_i`, the owned pair `L²` energy, is bounded by `I_i(f)`. Deduce `s_i ≤ M`, the owner's singleton amplitude `a_i ≤ sqrt M`, and the pair norm `z_i ≤ sqrt M`.
4. **Moment-to-source bridge.** Apply independent Hilbert fourth moments to that exact distinct-neighbor source law, then transfer its **first norm moment** back to the original source section via `ActualSourceFiniteSampleLaw`, giving `s_i ≤ z_i (c_i + sqrt(3M))` without an outside moment certificate.
5. **Integrated budget and Parseval.** Derive `sum u_i ≤ 8B` from the pointwise 8B section estimate and source-law normalization. Use singleton source Jensen for `a_i ≤ u_i`; derive `z_i ≤ u_i + a_i`; derive the variance identity `V = sum a_i² + sum s_i` from actual canonical orthogonality and exact ownership partition.
6. **Terminal declaration.** Define `M` as the maximum of *actual* source influences, handle empty-index and `M=0` cases, instantiate `T = sqrt M`, discharge every scalar closure input from source constructions, and restrict allowed Lean axioms to `propext`, `Classical.choice`, and `Quot.sound`.

## Adversarial checks / proof boundaries

- Repeated neighbor labels are disallowed in the transfer to the original joint law. Explicit injection on the used prefix is essential.
- `f` must be pointwise bounded on *all* finite table entries, including zero-mass input states, where the switching argument may evaluate it.
- Do not read a `4B` matched-rectangle bound from `full_matched_rectangles_le_four` without a source-level construction proving the even/odd block-polynomial evaluations equal source `f` at genuinely selected inputs.
- Numerical fourth-moment or scalar closure only gives the target implication from its hypotheses; it is not a source theorem.
- Classical ANOVA Parseval is old mathematics: Lean implementation validity does not establish novelty of the arbitrary-alphabet quadratic exponent-two inequality. Prior-art and external proof review are independent gates.

## Cheapest next decisive experiment

First compile `ActualSourceCanonicalVarianceEnergy.actual_degree_two_source_variance_energy` and `ActualSourceInfluenceEnergy.actual_source_section_energy_eq_influence` on the exact pinned compiler. If these pass, the next structural obstacle is **owned genuine-source pair stars, distinct-neighbor conditional Jensen, and global 4B source matching**; do not spend the next cycle tuning constants. If they fail, record the precise failing tactic/proof obligation and correct the source interface, not the final scalar inequality.

**Certificate:** `.github/workflows/nightfall-q2-source-influence-energy-v436.yml` plus the artifact `q2-source-influence-energy-v436`; per-run source SHA, Lean toolchain and pinned Mathlib SHA are included. No independent second-party verification yet.
