# JP-01 / Ryev: independent instrument preflight (review-only)

**Date:** 2026-10-29. **Assignment:** #170. **Research owner:** Devin J. Wright.
**Status:** SYNTHETIC SOFTWARE PREFLIGHT; **0 humans, 0 genuine model experiments, 0 blinded independent grades**.
The protocol in `README.md` remains the scientific source of truth. This file adds a checker, **not** permission to recruit or collect data.

## Objective and cheapest decisive test

Pre-register a mechanical check for three-arm assignment, four separately randomized lean bits per pseudonymous participant, event ordering, and the *declared* view of a source-blind adversary. The independent executable must fail on an altered random-lean assignment, duplicate subject, event tamper, removed step, leaked preference, unexpected raw field, absent seed and a precommitment-order attack even when the attacker recomputes the hash chain. Both positive and negative behavior matter.

Run `python3 scripts/audit_jp01_instrument.py --self-test` (Python 3 standard library only).
The local replay on the committed version produced **12 synthetic pseudonyms** (4/arm), **216 synthetic event records**, and **9/9 deliberately invalid mutations refused**. This is **fixture coverage**, not effect-size evidence.
Also run `python3 scripts/check_judgment_provenance.py --self-test` to replay the separately authored descriptive estimator (synthetic F = 1, 0.5, 0). The two programs have separate purposes: instrument audit versus outcome analysis.

## Instrument v0.1 contract

A manifest records `version`, `label` (`SYNTHETIC_FIXTURE` or `REAL_UNRELEASED`), `task_pack_sha256`, `prompt_pack_sha256`, `seed_sha256`, and `participants`. Participants use pseudonymous `pNNNN` aliases and each has one arm plus four binary lean assignments. Unknown manifest fields, duplicate IDs, malformed assignment vectors and unsupported versions are refused. A 32-byte seed, kept **outside the repository**, is required for the auditor to reproduce the HMAC-SHA256 leans and balanced randomized three-person arm blocks. The seed hash alone is insufficient to certify randomization.

Every event has `alias`, `decision_id`, `seq`, `t` (a monotone logical timestamp), `kind`, `role`, `visible_sources`, `content_sha256`, `prev_hash` and `event_hash`. Unexpected fields are rejected; raw transcripts do **not** belong in the manifest or ledger. The schema enforces consent-attestation event first, four complete decisions in order, debrief-attestation last, and exact per-arm stage ordering. In the blind arm, `precommit` must precede `alternative` and `lead`; both precommitment and the source-blind adversary must declare a view limited to `brief,evidence`. This is a **declaration audit**; it cannot inspect actual runtime network access.

A chained SHA-256 digest detects uncoordinated edits to the ledger. **It is not a signature, external timestamp, immutable record or guarantee against wholesale rewriting.** Future real use would require an independent external time anchor, operationally enforced source isolation, content-independent consent verification, restricted retention, actual frozen task/prompt pack, secure blinded grades, independent statistical review, a powered sample-size calculation and explicit human authorization.

## Negative controls / limits

1. Changed lean under same seed → refuse.
2. Duplicate alias / inconsistent assignment → refuse.
3. Unsupported schema → refuse.
4. Changed event hash payload → refuse.
5. Missing event → refuse.
6. Blind precommit reveals `lead` → refuse.
7. Unexpected raw preference field → refuse.
8. Missing private randomization seed → refuse.
9. Invalid precommitment order with *recomputed valid hash chain* → refuse.

**Unresolved scientific gates:** The protocol has no frozen real-study pack, ethics approval, independent blind reviewer, adequately powered sample, valid pilot, participant outcomes, or verified preservation of severe-error detection. Consent events do not prove informed consent; a reported view is not sandbox isolation; participant pseudonyms are not an anonymity guarantee. Current tool status stays PROPOSAL / NO HUMAN RESULTS. Vesper and human owner release gates remain open.

**Acceptance:** Executable pass in isolated CI; full-site regression preserved; separate source-and-inference review; owner permission before any live task, spending, recruitment or publication. No site UI or status change in this PR.
