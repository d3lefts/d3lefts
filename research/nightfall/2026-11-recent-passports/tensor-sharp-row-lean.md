# Sharp tensor-subcube row intersection bound

**NIGHTFALL Proof Passport supplement — 2026-11-22.** Source tier: `merged-lean`; Merged / named Lean. This is a claim-specific evidence sheet, not an automatic proof or originality promotion.

## Exact claim

For the recursive tensor row set R_L, every binary subspace W meets at most (dim W)^(log₂3) rows; an affine variant uses (dim W+1)^(log₂3).

## Hypotheses and scope

All tensor levels and binary subspaces in the formalized recursively defined family; original numeric-mask family identity is separately audited only through L≤3.

## Mechanism / operator

Three-slice rank induction and a sharp real scalar convexity inequality.

## Evidence and reproducible certificate

Merged PR #977, original named Lean kernel/leanchecker run #44739986591.

- Source pull request: https://github.com/d3lefts/d3lefts/pull/977
- Historical source head: `9e15771d3c818143d3c6d2fc250224bbe17c17ce`
- Named Lean kernel CI: https://github.com/d3lefts/d3lefts/actions/runs/44739986591
- Named declaration or research object: `SubcubeSharpAllLevels.all_levels_sharp`
- Supporting source or archival note: https://github.com/d3lefts/d3lefts/pull/977

## Precise limitation and negative controls

Not a general T≥2 simulator, not a novelty certificate, and not full all-L numeric generator equivalence.

The all-L recursively defined row theorem is the kernel target. Original numeric-mask generator equivalence has a separate L≤3 check. Do not infer a high-dimensional quantum circuit simulation result.

## Novelty, prior art and credit

NIGHTFALL collaborators; prior tensor/Sidon and Segre background requires separate attribution.

**Status gate:** historical priority is unresolved without source-level comparison and specialist independent criticism. A successful named Lean run proves only the exact compiled statement with its actual hypotheses; it does not certify a world-first claim.

## Next cheapest decisive experiment or adversarial audit

Extend/verify generator equivalence, review interpretation of the affine exponent.

**Certificate discipline:** preserve the input source, exact branch/head, checker and run identity, statement, hypotheses, negative tests and unproved dependencies with any downstream quotation. A new mathematical assertion requires a separately reviewed proof passport.
