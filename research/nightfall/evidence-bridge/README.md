# RYEV / Evidence Bridge v0 — narrowly scoped integration

**Assignment:** issue #30 (Evidence Bridge portion). **Status:** review-only; the Observatory Gate C experimental work remains entirely separate and unrun.

This branch is based on owner `main` and preserves the existing Referee → Claim Lab → Discovery same-tab workflow and local workspace normalization. Uploaded JSON files and direct same-tab receipts enter the **same strict read-only preview**. Nothing modifies a claim, any mathematical proof status, or research site content without a user-approved attachment. Approval downloads a complete local JSON workspace backup and adds one unassigned experiment marked **TESTED / UNAUDITED**. The receipt is passed to Discovery only after explicit approval. Cancel and malformed inputs cannot write to localStorage.

## Allowed receipt schemas

- `nightfall-referee-receipt-v1`: limited to exact finite Sidon or signed-shift overlap. Same-code independent recomputation of result and negative controls, producer engine version 1.0.0 and canonical input SHA-256 required.
- `nightfall-exact-local-receipt-v1`: fixed local Werner/F25 calculator engine. Recomputes exact result; legacy receipts lack producer-attested source signatures.

Hash fingerprints are **not** cryptographic signatures or endorsements. A claimed theorem, publication record, external reviewer, altered source dossier, altered result, incompatible code version, or unknown field is rejected. No imported file is executable code.

## Reproduction

From the repo root:

```bash
BRIDGE_FIXTURE_DIR=/tmp/ryev-bridge-fixtures node research/nightfall/evidence-bridge/test.cjs
python3 research/nightfall/referee/independent_verify.py /tmp/ryev-bridge-fixtures/sidon.json
python3 research/nightfall/referee/independent_verify.py /tmp/ryev-bridge-fixtures/overlap.json
node research/nightfall/evidence-bridge/invariant_forge.cjs
```

In GitHub Actions, Chromium tests exercise local workspace save/reload, refusal without mutation, explicit approval/backup, duplicate blocking, and the genuine owner same-tab Referee-to-Discovery journey on mobile and desktop.

**Review boundaries:** Math outputs are internally replayed with separate JavaScript and Python programs; outside peer review is pending. No Gate C twelve-arm evidence is included in this merge. Existing PR #36 retains exploratory Gate C engineering; keep it draft until review. Final owner UX/privacy and Vesper integration approval remain required.
