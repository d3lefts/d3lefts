# Dossier 08 — Arena certificates and negative-result audit register

**Source dates:** 2026-10-18 to 2026-10-27. **Status:** multi-problem finite search and conditional score audit. Mathematical witness, platform acceptance, and leaderboard rank are **independent facts**.

## UP25: certified polynomial-root candidate and scorer discrepancy

The 2026-10-20 \`SUBMISSION_AND_RANKING.md\` reports an eligible candidate with 25 prescribed distinct positive double roots and local score
\[
0.31309310122257694.
\]
It records a full positive-ray interval root audit in the original bundle, with two distinct coordinate conventions (binary64 and exact decimal), and identifies \`UP25_25_roots_globally_certified.json\` as the intended candidate. Its local proof used Arb / python-flint for all residual roots. The archived final session **did not submit** this candidate to the platform.

Separately, the report gives an exact integer counterexample to the *global-root interpretation* of a then-leading competitor's local score: a later sign-changing residual root near \(518.901511298\) was beyond the scorer's reported scan endpoint near \(518.877844742\). This is a **scoring-audit report**, not an accusation of intent and not an official correction of the platform leaderboard. A reviewer must reproduce the exact polynomial, input bytes, root isolation, and official scoring specification before drawing an external conclusion.

Source checkpoints: \`NIGHTFALL_UP25_Tight_Exact_Bounds_20261020.zip\`, \`SUBMISSION_AND_RANKING.md\`, \`UP25_25_roots_globally_certified.json\`.

## C1 and C2: separate finite optimizer tracks

The archive contains \`NIGHTFALL_C1_BEST_EXACT_20261020.zip\`, C1 Arena receipts, and many C1 topology/active-set experiment packages. Report each mathematical candidate beside its **specific** score definition, exact witness hash, original submission receipt, and accepted status. Avoid collapsing earlier C1 checkpoints into a single unverified ranking claim.

The C2 \`NIGHTFALL C2 Goldilocks — Verified Optimization and Shareable Handoff.pdf\` reports a construction evaluating to **0.9622738429572678** under one independently implemented scorer and **0.9622738429572681** under a second. Its public seed scored **0.9622738429547247**; the very small gain (~\(2.54\times10^{-12}\)) was below the platform's reported improvement threshold and below the then-leading score. This is a valid *local optimizer result*, not a competitive record. The work used a public seed and credits that lineage.

## Minimum overlap and finite Sidon

The existing [Erdős minimum-overlap dossier](../erdos-overlap-paper.md) holds the main 131,072-cell internal exact upper-bound construction and distinguishes the accepted leaderboard snapshot from a size-ineligible separate witness. The [finite Sidon dossier](../sidon-finite-30/README.md) holds the explicit 30-point witness and its independent finite proof. This expansion supplies **cross-links**, rather than duplicating and possibly diverging from their certified ledgers.

## Negative-results registry (selected)

| Search family | Reported evidence | What survived |
| --- | --- | --- |
| UP25 contact-birth / Newton | Lower apparent active roots acquired later positive-ray sign changes | Keep the complete real-root isolation test; discard false-leading local improvements |
| C2 dormant-support births | Very small valid improvement, below threshold | Optimizer reproducibility and source lineage, no new rank |
| C3 basin/polishing | Plateau and lack of qualifying certificate | Retain algorithmic logs; no record claim |
| Sidon 18-point tie | Ties fail strict-improvement leaderboard gates | Finite structural data remain meaningful, independent of leaderboard eligibility |
| Ring loading | Reported tie at \(9/8\) | Strict gain remains open |
| Kakeya-related chains | No qualifying certificate from attempted local operators | Stop rule documented, no problem-level theorem claim |

## What publication of primary artifacts still requires

A reviewer must receive the exact input JSON, accepted platform receipts where any exist, original scorer versions, integer/interval checker, SHA-256 manifest, and dated leaderboard snapshot. Binary archives above are identified by title only and have **not** been uploaded as part of this dossier.

The accepted Erdős checkpoint has an additional provenance task, [issue #6](https://github.com/d3lefts/d3lefts/issues/6). Platform scoring inconsistencies should be documented to organizers and may never be used to displace another valid participant's result.

**Overall status:** reproducibility and negative findings; no new external competition standing is asserted by this page.
