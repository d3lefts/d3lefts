# Commonwealth OS backend 0.4 — proof obligations and gates

Status: **internally tested, synthetic-only backend**. This module is not a legally authorized voting system, an independent verification certification, a secure public election, or a production deployment.

## Architecture delta

- One SQLite modular monolith accepts institution-scoped synthetic commands, with explicit `expectedVersion` and idempotency keys.
- All proposal revisions, source-document versions, policies, event journal, authority journal, publication previews, and approvals are append-only under SQLite triggers.
- `ExtendedStore` provisions fictional actors and rules, maintains a signed-evidence-compatible historical grant journal, and uses SQLite `BEGIN IMMEDIATE` for writes.
- Version locking and current authority checks operate inside the transaction; stale rule, roster, motion revision, or linked source blocks guarded transitions.
- VOID terminates pre-publication decisions; the synthetic publication flow requires a distinct clerk and **two different release reviewers**, preserving immutable corrections.
- `verify-v2.mjs` is separate source code with its own digest, replay, policy, roster, role, lock, source and publication checks. It requires a pinned external signer key; a supplied key inside the passport is not sufficient.
- `recertification.mjs` returns explicit impact/unknown categories; **it does not automatically reauthorize decisions**.
- Browser-facing routes remain synthetic-only. The frontend is owned by a parallel workstream.

## Formal refinement mapping (NOT A PROOF)

| Abstract requirement | Code-level discharge attempted | Not established |
|---|---|---|
| Authority at transition | SQLite `actorFor` inside transaction; replay of authority event head | Identity truth, external law or correct role delegation |
| Atomic effect / no replay | `BEGIN IMMEDIATE`, unique composite PK, version check and idempotency | Production PostgreSQL/OS/hardware effect atomicity |
| Evidence integrity | Hash-linked immutable journal, Ed25519 export and independent replay | External key custody, evidence completeness, trusted signer distribution |
| Same-world composition | Fixed institution, item, locked motion and rule epoch across event history | Statutory correctness and population completeness |
| Source freshness | Pinned synthetic dependencies, stale source blocks guarded commands | Official source publication semantics and external source custodians |
| Change-stable recertification | Version/hash dependency impact with UNKNOWN result | Universal graph completeness or automatic preservation of legal validity |
| Publication assurance | Separate reviewers, append-only preview and corrections | Redaction safety for arbitrary personal data, legal open records |
| Confidential ballot | NONE; named synthetic roll calls only | Secrecy, coercion resistance, end-to-end election audit |

The Lean PR #613 proves model-level conditional statements; these passing runtime tests do **not** prove a refinement theorem from arbitrary Node/SQLite execution traces to Lean. A formal simulation relation, proof over a typed implementation semantics, and independent adversarial review remain open.

## User and deployment boundaries

Use only fictional actors, fictional laws, and fake tokens. `createServer()` is a local research service; CLI binds localhost only. No OIDC connection, WebAuthn, live institution roster, live municipal source, deployment secrets, real vote or outside actor effect is enabled.

An existing v0.3 SQLite file lacks original authority-event provenance. **Do not silently backfill it and claim completeness.** The v0.4 independent verifier requires complete authority history from fresh v0.4 provisioning. Migration into authoritative use needs custodian proof and a separate conversion/replay protocol.

No claim of PostgreSQL readiness: `migrations/postgresql-design-only.sql` is a nonexecuted design exercise. Independent database integration and crash-fault, RLS, restore, and workload audit are required before choosing a production backend.

## Audit/stop rule

Stop on mismatching trace, unrecognized schema, missing rule authority, missing external signer pin, stale source, stale voter epoch, nondeterministic tally, undocumented delegated permission, or PII in a proposed public release. Report failures. Require outside source/identity/security review before any consequential organizational vote.
