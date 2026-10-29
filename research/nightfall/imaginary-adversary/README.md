# Imaginary Adversary | Devil's Advocate

**Version:** 1.0.0 / 2026-10-29  
**Research lead:** Devin J. Wright / NIGHTFALL | CONSTELLATION  
**Purpose:** Companion to Referee. A bounded counterexample and proof-obligation instrument; no automatic proof promotion.

## Workbench contracts

**Sidon.** With 4–40 distinct integer coordinates, enumerate the four-point (4,5) distance predicate; independently expose disjoint-pair repeated sums (weak Sidon) and repeated unordered pair sums including diagonal pairs (classical Sidon). The definitions differ. The negative-control set {1,2,3,5} violates (4,5) through distances {1,2,3,4}, survives weak Sidon, and violates classical Sidon via 1+3=2+2. A finite test passing proves only the selected predicate on the selected coordinates.

**Minimum overlap.** With 2–64 equal-width cells, rational denominator D, integer heights satisfying 0 ≤ A_i ≤ D and unit mass 2ΣA_i=nD, compute the exact integer signed-lag maximum C(k)=Σ_i A_i(D−A_(i−k)), where off-support cells are zero, for 1−n ≤ k < n. The exact continuous supremum equals 2·max C(k)/(nD²), since the translation objective is piecewise linear between cell-aligned lags. Reject any supplied rational upper bound below the computed value. Test at most 256 deterministic feasible one-unit mass-preserving transfers and return the best strict improvement when found. Failure to improve establishes no global optimality, no record and no asymptotic bound.

**General proof attack.** A deterministic, source-aware question set flags missing hypotheses, source references, closest same-model baselines, hidden dependencies and invalid extrapolation to universal claims. This is a review prompt, never a theorem solver.

## Verification and output

The local JSON record format is nightfall-imaginary-adversary-receipt-v1. It preserves the full user-supplied input, exact finite result, explicit counterexample if found, proof objections, trust boundary, timestamp and SHA-256 input fingerprint where the browser exposes WebCrypto. A digest is an input fingerprint only; it is neither a signature nor independent verification.

Possible statuses: COUNTEREXAMPLE_FOUND, NO_COUNTEREXAMPLE_IN_TESTED_SCOPE, INCONCLUSIVE. None grants global truth, novelty, external peer review, or approval for publication.

Referee retains its distinct exact finite verifier, negative controls, and approved local Claim Lab handoff. The Adversary exports an attack brief; no imported attack record may silently upgrade a claim.

## Replay and independent controls

Run from the repository root:

    node --check docs/adversary-core.js
    node --check docs/adversary-app.js
    node scripts/test_adversary.cjs
    python3 scripts/check_site.py

The adversary test suite independently evaluates overlap via pair-difference convolution on 24 finite fixtures and checks exact Sidon definition splits, invalid inputs, mass normalization, rational upper-bound falsification, universal warning and improvement-certificate arithmetic. CI executes it. Browser smoke and manual visual testing are separate gates.

Publication stages R0 through R4 remain governed by ORIGINAL_PUBLICATION_PROGRAM_20261029.md. Before attaching an adversarial result to a paper, independently rederive the failing arithmetic, date the closest prior art, and preserve original provenance with the author and reviewer credits.