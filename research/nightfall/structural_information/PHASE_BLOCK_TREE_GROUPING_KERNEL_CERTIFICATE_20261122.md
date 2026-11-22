# Exact-source Lean certificate: phase-block physical tree compilation and coordinate-grouping degree

Date: 2026-11-22. **Status: kernel-checked, source-scoped mathematical bridges; complete original-circuit Route 1 terminal remains OPEN.**

## Actual Route 1 decision tree compiled into raw physical measurements

`research/nightfall/formalization/structural_information/PhaseBlockTreeCompiler.lean` (Git blob `47e988c9d70d49027e4d9cfb88ef87cd467b9346`) imports the actual existing `ProductSimulation.DTree`, defines an explicit computable eight-sign-class decoder from original intensity sensors 0,1,2, and proves:
```
decodeTriple_correct: ∀ s : Fin 8, decodeTriple (tripleRead s) = s
compileTree_eval:  ∀ t x, (compileTree t).eval (rawTable x) = t.eval x
compileTree_queries: ∀ t x, (compileTree t).queries (rawTable x) = 3 * t.queries x
```
The statement is universal over all source block index types B (the concrete Type universe of DTree), every finite adaptive decision tree, all source inputs, repeated queries and branches, with no new hypothetical decoder oracle. Exact pinned Lean named CI [45065169016](https://github.com/d3lefts/d3lefts/actions/runs/45065169016) **PASS**: ProductSimulation dependency closure, named theorem types and #print axioms checked with standard `propext`, `Classical.choice`, `Quot.sound` only, no `sorryAx`. This is an actual *physical sensor query* theorem, not an algorithmic lower bound against alternative sensing families.

## Grouping raw sensor coordinates cannot increase interaction degree

`research/nightfall/formalization/structural_information/PhaseBlockGrouping.lean` (Git blob `8bd6d322c58235567d4ed9cfb7605409df8509c6`) proves for any finite raw coordinate index I, block index B, finite alphabets A,C, parent map `I → B`, local reencoding `φ : I → A → C`, that pulling back a degree-≤d real function on raw coordinates through `x↦(i↦φ i (x(parent i)))` yields degree ≤d on hidden blocks. No assumption that the resulting degree bound holds is imported: the source function's exact indicator witness is transformed and reconstructed. Exact pinned Lean named CI [45065168946](https://github.com/d3lefts/d3lefts/actions/runs/45065168946) **PASS**, standard axioms only, no sorry.

## Dependencies, audit and limits

The source kernels build on the previously merged phase-block code and all-B rectangular-support lemma [PR #1118](https://github.com/d3lefts/d3lefts/pull/1118), as well as the original Route 1 degree and DTree definitions. Independent second code and finite decoder is credited to [merged #1087](https://github.com/d3lefts/d3lefts/pull/1087). Fixed-sensor phase decoding saves one of four original physical measurements per decoded block; basic B-independence is already obtainable by reading all four, and no universal raw-algorithm advantage is claimed.

**Missing end-to-end theorem:** the still-open [full terminal PR #1128](https://github.com/d3lefts/d3lefts/pull/1128) invokes these lemmas with an actual `QuantumCircuitPaths.Circuit` on *raw intensity addresses*, derives its scalar Born acceptance interaction degree ≤2T, calls the original `route1_polylog_simulation`, and compiles its selected block DTree to raw queries. `PhaseBlockRoute1Terminal.lean` and `PhaseBlockActualCircuit.lean` are **not yet named Lean certified**; normalized-circuit / correlated-Wyner extension [#1105](https://github.com/d3lefts/d3lefts/pull/1105) is likewise pending. The exact 3B-bit raw Wyner entropy calculation remains at paper level, while the all-B support obstruction is kernel checked.

**Certification gate:** only these two byte-identical modules with passing exact-source named compiler receipts may be merged under this proof note. This does not advance the entire paper to "end-to-end Lean certified" or assert originality. Protect all existing source-custody rows; this integration adds two pending exact blobs but leaves all 67 historical source-matched theorem records unchanged.
