# RYEV / Evidence Bridge v0 and Invariant Forge

**Assignment:** https://github.com/d3lefts/d3lefts/issues/30. **Research owner:** Devin J. Wright. **Engineering:** Ryev. **Scientific integration review:** Vesper.

**Status:** review branch. No new universal mathematical theorem is claimed, and Observatory release is gated.

## Evidence Bridge v0 — strict versioned parser

The canonical Node/browser adapter is research/nightfall/evidence-bridge/core.js. The published-site copy in docs/evidence-bridge-core.js is required to match byte-for-byte.

The asynchronous preview() function accepts genuine Referee v1.0.0 finite Sidon/overlap receipts and legacy local exact-calculator v1 Werner/F25 receipts. It rejects unknown versions, unrecognized authority/scope fields, forged independent-review claims, claims of asymptotic significance derived from a finite set, digest mismatches, changed result arithmetic, altered negative controls, conflicting receipt IDs, and duplicate canonical inputs.

For Referee, SHA-256 is checked over the exact JSON.stringify canonical input shape used by the producer, followed by a *first-party exact arithmetic recomputation*. For the legacy Exact Tools family, the producer lacks a source-committed version and input digest; the Bridge reruns the allowlisted deterministic engine and computes a local receipt fingerprint. A fingerprint is not a signature. First-party replay is not external scientific approval.

Every accepted preview carries reviewStatus unreviewed, promotionAllowed false, an empty claimsTouched array, a null authoritativeReviewer, the mathematical scope, and its source hashes.

## Claim Lab consent and preservation

The importer stages the proposed attachment in a read-only preview. Cancel writes nothing. On explicit approval it downloads a complete current-workspace JSON backup, then appends one unassigned experiment marked TESTED / UNAUDITED. No existing user claim, evidence-status label, or manuscript classification changes.

A localStorage write must succeed and pass readback before the displayed application state changes. Full storage and duplicate receipts fail closed. Source JSON receipts remain in the user's files; the local entry stores their fingerprint and a compact metadata pointer.

## Tests

Run in the repository root:

    BRIDGE_FIXTURE_DIR=/tmp/ryev-fixtures node research/nightfall/evidence-bridge/test.cjs
    python3 research/nightfall/referee/independent_verify.py /tmp/ryev-fixtures/sidon.json
    python3 research/nightfall/referee/independent_verify.py /tmp/ryev-fixtures/overlap.json
    node research/nightfall/evidence-bridge/invariant_forge.cjs

These cover four genuine receipt types and sixteen negative controls, including every required Issue #30 refusal class. The Chromium suite tests save/reload preservation, read-only preview, cancel, downloaded backup, approved local attachment, reload persistence, tampered input rejection, and duplicate blocking at desktop and mobile sizes. CI saves the accepted and rejected input receipts.

## Original instrument design: Invariant Forge

Invariant Forge supplements negative tampering tests with positive mathematical **metamorphic invariance**. A verifier should accept a mathematical property under transformations that preserve it; invariant-preserving inputs can discover coordinate-orientation and normalization bugs that fixture-only testing misses.

For the finite overlap step array A with denominator D, Q_A(k) is the sum of A[i] times (D minus A[i-k]) over valid indices. Let R reverse the array and C complement each height to D minus its original value. Exact index substitution gives:

    Q_R(A)(k)   = Q_A(-k)
    Q_C(A)(k)   = Q_A(-k)
    Q_R(C(A))(k)= Q_A(k)

Every identity holds at every signed lag as an exact integer statement. Since mass is normalized, reversal and complement preserve admissibility. The executable stress test checks all three transformations for the 16-cell golden fixture and 40 seeded mass-normalized examples.

For Sidon (4,5), every nonzero integer-affine x ↦ ax+b transform preserves pair-sum coincidences and 3-term arithmetic progressions, so the maximum Sidon subset size is invariant. Invariant Forge checks three transformed 30-point witnesses including coordinate reflection. Number of internal branch-and-bound search states is *not* an invariant and is excluded from the exact comparison.

These are elementary established algebraic properties used in a new **research-system verification design**. They are not announced as novel mathematical theorems or outside referee review.

## Observatory Gate C

The gated companion folder at research/nightfall/observatory/gate-c-ryev fixes six tasks (two finite-field, two Werner, two spectral), six immutable source blob identities, seed 1729, and per-arm limits of 2,000 total model tokens and 20 external calls.

The runner freezes 12 graph/flat allocations with identical source blobs, generates condition-masked grading templates, validates all raw outputs and token budgets, and refuses to score without 12 actual model responses plus 12 separately graded records. It preserves negative results and emits UNREVIEWED results until a separate scientific reviewer signs off.

**Incomplete release gate:** A genuine matched-budget 12-arm model execution and blinded adjudication have yet to be performed. No outcome or performance improvement is fabricated. Consequently Observatory Gate C and Gate D remain pending. This PR is not a public Observatory launch.

The owner-approved 32-document research library, three Original Findings, guided Sidon replay and external publication gates remain unchanged.

## Owner integration review / 29 October 2026

The owner subsequently added a direct Referee -> Claim Lab -> Discovery same-tab route to main. The PR now starts from that current owner Claim Lab source and consolidates **both manual file import and one-shot same-tab Referee handoff** behind one `stageRefereeReceipt()` entrypoint using the strict Evidence Bridge parser. Session transfer to Discovery is enabled only **after** explicit backup-and-attach approval. Cancelling cannot create a Discovery replay receipt. Producer-label, source-dossier and source-note authority forgeries are rejected before staging.

`test_owner_handoff.mjs` exercises an actual Referee Sidon calculation in Chromium, the direct transfer, read-only preview, cancellation, approved backup and Claim Lab storage, a Discovery replay, a forged source-dossier attempt and reload preservation at 390px and 1280px. These additions are committed for CI execution; earlier CI green runs refer to older commits, so current head must be checked separately.

The original Vesper Gate C v1 uses `parity_runner.cjs`. `metering_core.cjs` plus `run_metered.cjs` send the exact frozen model input to OpenAI's Responses input-token count endpoint, capture the provider's *raw* response usage and request IDs, and reject zero/self-reported counts, altered source text and mismatched prompts. The operator needs explicit API credentials and a secret frozen pairing key. None is available in this session; the twelve real model trials and independent blind grades remain pending. A captured JSON trace itself lacks cryptographic provider attestation; do not claim otherwise.
