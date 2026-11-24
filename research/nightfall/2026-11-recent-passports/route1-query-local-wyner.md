# Route 1: query-local Wyner information transfer

**Editorial checkpoint:** 2026-11-24
**Claim ID:** `route1-query-local-wyner`
**Evidence tier:** branch-lean
**Public status:** PR-head / named Lean

## Exact claim

A b-local encoding with r-query latent recovery transfers the degree-d target to degree at most bd and compiles the latent q-query tree into an original-coordinate tree of depth rq.

## Scope and assumptions

Finite source, b-local encoding, exact recovery on support, TV slack and general-latent Wyner bound.

## Mechanism

Degree pullback and adaptive recovery-tree substitution.

## Certificate and provenance

Merged paper #1150; exact-head terminal and finite sampling lemma passed #1183 run 45330144365.

- Named terminal: Nightfall.QueryLocalWyner.query_local_wyner_blocal
- Exact head: 98f53f6abe2142dc97b74fcd97d683d2c3484096
- Receipt: https://github.com/d3lefts/d3lefts/actions/runs/45330144365

## Limitation

Open PR integration; the sampling lemma is not the full converse, and query depth is not runtime.

## Credit

NIGHTFALL Route 1 and classical Wyner common information.

## Next independent check

Integrate the exact-head terminal without changing its source type.

## Primary source

https://github.com/d3lefts/d3lefts/pull/1183

Earlier versions remain in Git history. This editorial index is not external peer review.
