# NIGHTFALL agent toolchain RFC: Nushell pilot, evidence-first contract

**2026-11-22 · proposal, not a mandatory team migration.** The authoritative
certificate stack remains pinned Lean/Mathlib, exact independent checkers,
Git source blobs, Proof Passport v2, and source-scoped GitHub Actions.

## Decision

Adopt a **shell-agnostic task and evidence contract** for all agents.
Offer Nushell 0.117.0 as the preferred interactive *structured-data
orchestration shell*, not as the sole permitted interpreter and not as
the source of proof truth. Consider a version-pinned justfile as the
single agent command catalogue once a pilot shows reproducible gains.

Do NOT convert existing stable Bash CI/bootstrap steps, Python exact
checkers, Node/JS application checks, or Lean source files merely
to satisfy a shell preference. The current repository already has
hundreds of workflows; migrating wholesale adds regression surface.

## Why this could help

Nu treats tables, JSON, filenames, and structured records as typed
pipeline values, reducing grep/awk/json-parsing glue. It is useful
for viewing claim registries, filtering evidence receipts, batching
local operator runs, and producing structured handoffs. Nushell does
not certify the semantics of a theorem, guarantee independent reviews,
enforce complete evidence custody, or replace formal proof checking.

## Shared contract (shell-independent)

Every agent task must identify: problem ID; exact source refs and SHA;
scope and assumptions; declared expected theorem/witness; operator;
producer command and toolchain versions; verifier command; input
hashes; output hashes; the status of formal proof/independent checker;
negative controls; failure modes; non-author review status; stop rule.
Store bytes and receipts as JSON/NDJSON plus source artifacts. Keep
stdout for humans; machine receipts must be valid JSON with explicit
status, canonical ordering, and a clear distinction between:
  (a) a CLI task completed, (b) output replayed, (c) a theorem kernel-checked,
  (d) independent semantic review, and (e) novelty/prior-art clearance.

Never let a Nu pipeline silently coerce nonzero external exit codes
to an empty successful data record. Use native exception handling or
the external command's structured exit_code (via complete); fail closed.
Do not flatten arbitrarily nested JSON into columnar text before checks.
Do not use arrival time / agent identity as proof evidence.

## Separation of authority

- **Core/authority:** Lean kernel, trusted Python/Node exact verifiers,
  immutable Git blobs and pinned compiler lock, independent review.
- **Operator interface:** optionally Nu, or Bash/Python/just, all invoking
  the *same* versioned producer/checker commands.
- **Discovery:** separate experimental lane, free to use whichever
  language speeds hypothesis generation, but it cannot self-certify.
- **Independent auditing:** verifier B derives checks from the specification
  rather than copying A's implementation; share immutable input hashes.

## Prototype delivered with this RFC

The read-only `passport-preflight.nu` summarizes the checked-in
`docs/proof-passport-v2.json` as JSON, failing on malformed schema/version
or duplicate IDs. It explicitly emits `mathematical_certification: false`
and `semantic_review: false`. It is NOT a replacement for
`scripts/check_proof_passport_v2.py` or the source/axiom checks.

CI pins Nushell 0.117.0 and the setup action commit, first runs the
Python passport validator, then compares Nu's JSON summary to an
independently computed Python expectation and requires negative
mutants to fail. Nu is not installed by the canonical Lean setup action.

## Pilot and promotion criteria

Run equivalent tasks with existing shell vs Nu on identical commit SHAs
for three real operations: (1) proof-passport triage, (2) CI receipt
aggregation, and (3) exact-checker orchestration. Pre-register outcome
metrics: wall-clock seconds, setup seconds, unhandled exit failures,
lines of task glue, source-hash mismatches, and full check agreement.

Promote Nu as the preferred interactive agent shell ONLY if all:
1. One current-branch CI run passes on the pinned version and all
   negative tests fail as intended.
2. No loss of standard-axiom/Lean/evidence validators and zero false green.
3. Same canonical JSON and hash receipts independent of shell.
4. At least 20% reduction in median agent orchestration time OR
   30% reduction in glue/parse logic with no extra CI wall-clock overhead
   above 15%, across equivalent tasks. (These are policy targets, not
   results measured here.)
5. A different instance independently reviews the shell and CI code.

Rollback immediately on non-deterministic schema, unsupported platform,
version drift, hidden nonzero exit, or stale/mis-scoped certificate.

## Stronger long-term alternative

A versioned, small task runner (`just` or existing Python dispatch)
plus one JSON Schema for the task/receipt envelope could outperform
a uniform shell. Make a task name the primary interface (for example,
`check-proof`, `replay-witness`, `audit-axioms`, `diff-receipt`), with
each task calling the existing authorized verifier. Use Nu only where
its typed pipelines demonstrably improve discovery ergonomics.

External documentation consulted this session:
- Nushell 0.117.0, published 2026-11-09:
  https://www.nushell.sh/blog/2026-11-09-nushell_v0_117_0.html
- Nushell external exit status:
  https://www.nushell.sh/book/stdout_stderr_exit_codes.html
- just shell customization:
  https://just.systems/man/en/shell.html
- Immutable setup action used in the pilot:
  https://github.com/hustcer/setup-nu/commit/1b8faed9a8ff673c8ce0beae243e0b72d0787241

**Status:** proposal + pilot; certification and originality statuses unchanged.