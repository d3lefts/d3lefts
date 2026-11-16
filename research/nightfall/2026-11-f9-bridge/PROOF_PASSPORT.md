# NIGHTFALL F9 same-oracle proof passport — 2026-11-16

**Model:** K = GF(3²); all signals x∈K^k including zero and sparse support; a query is the square of a legal K-linear functional; equivalence is one global ± sign. Adaptive and fixed designs must count the **same** oracle.

## Kernel and independent-scoped checkpoints
- `F9OracleBridge.lean` kernel-checks injective square decoding of two characteristic-three relative-sign basis digits and exact complement-kernel squared collisions with non-sign-equivalent witness signals. Source-level pinned Lean and independent exact [run 43940265714](https://github.com/d3lefts/d3lefts/actions/runs/43940265714) passed. No prechosen unsquared oracle or sign information is allowed as a free query.
- `F9ActualFieldBasis.lean` instantiates the concrete `GaloisField 3 2` basis and locally unconditional two-sign square decoding. Source and named Lean CI [run 43940957192](https://github.com/d3lefts/d3lefts/actions/runs/43940957192) passed.
- `F9NonadaptiveLower.lean` uses rank-nullity, two short-row kernel witnesses, finite-index partition reconstruction, and the squared measurement identity to prove: if a fixed design of m K-linear squared observations separates every signal modulo ± and k≥2, then **m≥2k−1** (field characteristic ≠2 explicitly). Strict named pinned [run 43943837632](https://github.com/d3lefts/d3lefts/actions/runs/43943837632) passed at head `e83c50e5017272cc50c08dc37f3a6ab379c7cd2a`. It supplies the fixed-side mathematics; it does **not** imply a globally original code bound.
- Independent arithmetic code `verify_two_models.py` uses two distinct irreducible GF9 polynomial presentations and checked all 9+81+729+6561 = 7,380 signals per presentation (14,760 total) for k=1..4, plus 720 selected fixed-design collisions per presentation (1,440 total). Exact finite replay is not an all-k proof.

## Still open
- `F9ConcreteLower.lean` is a candidate *transitive interface* from actual GF9 separating rows to the `F9GapArithmetic.lean` lower premise; verify its **own** latest pinned compiler and axiom run before calling it kernel-certified.
- The all-k adaptive decoder-to-query-upper-bound is **not formalized**. Its source argument: first k square-coordinate queries identify support and chosen roots; pack up to two relative signs per subsequent squared-linear query using a GF3 basis. Derive a legal adaptive protocol from the actual previously measured squares, prove root/sign choices and reconstruction for every support configuration, and verify worst-case ≤k+ceil((k−1)/2) without reading extra information for free.
- The strengthened 17/8 intersecting-code asymptotic transfer belongs to credited external literature; do not import it as Lean-certified unless formally reconstructed.

## Mechanism and cheap next experiment
Reusable operator: phase root normalization → F3-basis binary packet → square injectivity. Lower-bound operator: partition fixed measurement rows → rank-nullity kernel witnesses → inequivalent u±v with equal squared transcript. The latter transfers beyond F9 to any field with characteristic ≠2; the former requires sufficient finite base-field dimension and signed-phase map injectivity.

Fastest decisive next test: construct a **single explicit all-k adaptive decision procedure** in Lean with transcript functions of earlier square outputs, prove same-oracle call accounting and exact reconstruction. Then compose it with the now-scoped fixed lower and `F9GapArithmetic.f9_gap_unbounded`. Current external novelty and independent non-author review remain unclaimed.

**Self-improvement recorded:** replace loose conditional lower complexity premise with explicit separating rows and rank-nullity; independent field models stress the same operator under a changed representation; preserve every failed Lean compile as a source/implementation error until repaired. Improvement in future user correction workload has not been measured.
