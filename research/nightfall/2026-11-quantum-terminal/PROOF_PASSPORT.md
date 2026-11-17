# NIGHTFALL quantum physical Born/POVM proof passport — 2026-11-16

**Scope:** uniform ternary sources; source-defined pure qubit product states with local amplitudes √3/2 and ωˣ/2; finite dimension d≥1. Source B and cosine-weighted A are constructed from the same unnormalized ensemble, not supplied as assumed GHZ operators.

## Reproducible results already checked
- Exact physical corner support, actual numerator trace-coherence, and full-ambient GHZ ±/complement projectors: [draft PR #655](https://github.com/d3lefts/d3lefts/pull/655), pinned source-head run [43917861968](https://github.com/d3lefts/d3lefts/actions/runs/43917861968).
- **New source-closed, unnormalized Bayes optimum:** `Nightfall.Quantum.ActualBornTerminal.actual_physical_povm_optimal`, plus full Born denominator, universal finite complex POVM energy bound, positivity/completeness, and exact attaining three-outcome POVM in `research/nightfall/formalization/quantum/PhysicalBornTerminal.lean`. Pinned Lean 4.36.0-rc2 and strict named-standard-axiom workflow [43941737696](https://github.com/d3lefts/d3lefts/actions/runs/43941737696) passed at head `1d43bcb9fcde8a847051c80e767c2f48be24cdd3`. This is an internal kernel certificate, not a novelty finding or independent human mathematical review.
- Separate independent implementation: `check_ghz_full_independent.py` reconstructs all 3^d states and their matrices for d=1..4, compares B/A to the predicted analytic source blocks, proves *in those finite instances* that the three effects are positive and complete, checks rational exact expected gains, and checks 20 complex orthonormal-basis measurements per dimension against GHZ. Numeric tolerances do not establish the all-d claim; the Lean theorem handles that.

## Exact normalized terminal — named Lean certificate

The normalized gain is **exactly** `(3/16)^d / ((3/4)^d+(1/4)^d)` for all d≥1. The separate `PhysicalGainNormalized.lean` named theorem
`Nightfall.Quantum.PhysicalGainNormalized.actual_physical_optimal_gain_normalized`
binds the physical A source, the B source, the attainable full-dimensional POVM, and the actual uniform 3^d source normalization. The source-closed pinned Lean compile and strict standard-axiom audit passed in [run 43944671505](https://github.com/d3lefts/d3lefts/actions/runs/43944671505), head `1ebb960f5c5a4b2de1616e39a68e5db8c92285d3`. The full independent numerical matrix audit had already passed at the earlier unnormalized source head [43941737696](https://github.com/d3lefts/d3lefts/actions/runs/43941737696); the new aggregate workflow includes it separately. This is a **scoped mathematical kernel certificate**, not a world novelty assessment or non-author mathematical referee verdict.

## Mechanism and transfer
The operative composition is: physical pure-state density → ternary character cancellation → exact two-corner observable → actual Born A/B trace → weighted PSD coherence inequality → full-register GHZ saturation. It is a candidate reusable proof operator for other character-coded quantum observability models, but an edge to another model must discharge its own source-character and POVM hypotheses.

## Independent criticism and cheap next test
The numerical checker is separately coded but intentionally knows the analytic expected value; it is not blind independent proof reconstruction. Attack all-outcome zero-mass treatment, d=1, normalized versus unnormalized conventions, and Hermitian positivity. Cheapest decisive experiment: strict named Lean source/axiom check of `actual_physical_optimal_gain_normalized` followed by a fresh independent symbolic reduction of 3^d factors; no further quantum claims until this gate passes.

**Self-improvement recorded:** prior missing transitivity was closed by *composing source-level definitions* rather than weakening the conclusion to assumed GHZ support; staged compiler failures were preserved in CI rather than relabeled inconclusive mathematical results. The measured reduction in human correction time remains untested.
