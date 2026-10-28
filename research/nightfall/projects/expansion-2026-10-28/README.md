# NIGHTFALL / PHASESHIFT — Eight-dossier research expansion

**Date:** 2026-10-28. **Human research lead:** Devin J. Wright. **Publication state:** eight text-first technical dossiers. **Coverage window:** research manuscripts originating chiefly September–October 2026. Independent external peer review and priority checks remain open.

This expansion preserves distinct lines of mathematical and AI-systems research found during the August–October archive review. It records the **best stated theorem or experimental finding**, its necessary assumptions, source checkpoints, failure modes, and decisive verification work. It is **not** a release of every source binary: manuscripts, spreadsheets, source JSON, and several checkers identified by filename remain in the research Library pending a hash-verified public mirror.

## Dossier index

| # | Dossier | Strongest scoped result | Publication/evidence status |
| --- | --- | --- | --- |
| 01 | [Werner margins, 25–100 continuation, restricted four-copy sector](01-werner-margins.md) | Separability-based copy-dependent strict NPT bound; source-conditional 25-copy increment ~6.53e-9; 27×27 supported-sector gluing theorem | Self-contained analytic argument plus conditional upstream seed, external audit pending |
| 02 | [Periodic forest-gauge obstruction](02-periodic-forest.md) | Exact combinatorial defect identity forces max free-edge neighbor degree ≥13 on periodic 4D forest gauges | Explicit proof and new independently coded [integer checker](verify_periodic_forest.py); priority unconfirmed |
| 03 | [ETH taper and restricted rank barrier](03-eth-taper-and-obstruction.md) | Fourfold asymptotic leading precision allowance reduction in specified interpolation regime; 12-base lower bound for disjoint middle-layer refinements | Mathematical proofs and reported finite tests; no improved SAT exponent |
| 04 | [Busy Beaver fresh-layer theorem and BB(6) maps](04-busy-beaver-return-maps.md) | One-way planar phase bound \(S\le S_U\le nS\), externally controlled \(k\)-climb identity, five arithmetic return-map reductions | Manuscript results and imported upstream symbolic transition rules |
| 05 | [Selection-aware partial pivoting](05-selection-aware-pivoting.md) | Singular-value tail for actual future selected Gaussian pivot rows, retaining triangular elimination loss | Conditional derivation with published pivot-polytope inputs; no final growth-factor gain |
| 06 | [Hidden-function interpretability audits](06-hidden-function-audits.md) | Paired signed observational/causal residual with justified abstention; 31-state exact demonstration | Small algebraic demonstration + prospective blinded evaluation proposal |
| 07 | [Causal cuts, cognition and proof-search calculus](07-causal-cognition-proof-search.md) | Finite-state directed-cut factorization; synthetic evaluation transport; admissible obstruction-pair calculus | Framework, finite mathematics and synthetic studies |
| 08 | [Arena and negative-result audits](08-arena-and-negative-results.md) | UP25 exact root-audit candidate plus scorer discrepancy; C1/C2 provenance and failed-operator register | Historical research records, no new leaderboard standing |

## Verification performed in this publication turn

A separate, directly enumerating Python [forest checker](verify_periodic_forest.py) was run locally under Python 3 with pure integer arithmetic. **32 trials passed**: dimensions 4 and 5; periodic side lengths 3 and 4; eight deterministic random forests per setting. It separately forms the plaquette-pair adjacency graph, counts forest components and defect terms, and checks the exact identity. This checks representative finite cases rather than certifying the universal argument.

**Other dossier results** are publication of recovered research claims and manuscript proofs. Their original complete binary checkers were not executed in this publication turn. No earlier internal verification report is silently promoted to independent external certification.

## Source and binary publishing checklist

1. Freeze each original Library source, preserve original filename and SHA-256, and list the byte size.
2. Publish source manuscript (PDF plus editable source), machine witness (JSON/CSV), independent checker, and a manifest as a separate GitHub Release asset.
3. Replay checker from a clean checkout, record exact command, Python/dependency versions, stdout/stderr, and input/output hashes.
4. Review imported published mathematical premises and record exact theorem statement and page/commit.
5. Conduct a dated priority check and keep adverse findings, referee corrections, and hypothesis restrictions visible.
6. Obtain human review before describing any result as a novel theorem, public numerical record, or original competing result.

## Dependency distinctions

The **Werner three-column 4–20 approved registry** and older 1–100 atlas are authoritative for those scope labels; the new 25–100 conditional continuation does not silently rewrite them. The **Erdős accepted submission** is separate from the oversize mathematical witness. The **UP25 scorer counterexample** is a local exact audit, distinct from any official platform decision. The **forest-gauge theorem** applies to periodic geometry, distinct from the source paper's free-boundary gauge.

The Xi/critical-line and prime-frequency research remain outside this public expansion according to the existing release boundary. This page records no changed proof status for those excluded programs.

## Attribution and archival continuity

Research direction and authorship: Devin J. Wright. AI-assisted calculations, proofs, coding, and research synthesis are documented in the original checkpoints; source authors retain credit for imported theorems. The frozen master release inventories in [the original release ledger](../../RELEASE.md) remain unchanged. Adding public text now does not rewrite the previously hashed source archives.

**Public parent index:** [NIGHTFALL archive](../../README.md). **Independent review protocol:** [REVIEW_PROTOCOL.md](../../REVIEW_PROTOCOL.md).
