# Commonwealth OS — server refinement ledger v0.1

**Date:** 2026-11-15 US Eastern / 2026-11-16 UTC. **Status:** synthetic-only implementation checks, bounded differential tests, and a separately compiled Lean server reference model **only if strict CI is green**. This is NOT a full program-refinement proof or approved voting infrastructure.

## Objective and claim contract

Bridge the previously scoped Democratic Assurance Proof Passport (P1–P4; draft #613) to the actual draft transactional server (draft #610). Its server provides **DEMO** phase transitions and nonbinding synthetic vote reviews, not official effects. The prototype is intentionally unsuitable for real member/voter data or operational elections.

Desired commutation (not yet universally proved):

    concrete Store.command(C, c) succeeds with C'
          | abstraction α                    | abstraction α
          v                                  v
    model step(α(C), abstractCommand(c)) = α(C')

and for a rejected command, the concrete item projection is unchanged. The bounded source-different test in `tests/trace_refinement.test.mjs` checks this over 720 deterministic generated inputs and multiple starting phases. It does not quantify over all SQL states, all JavaScript values, concurrent processes, or all network clients.

### Projection α
- `items.state` ↔ Lean `State.phase`
- `items.version` ↔ `itemVersion`
- `items.current_revision` ↔ `revision`
- `institutions.policy_version` and `eligibility_version` ↔ policy and eligibility epochs
- `items.locked_revision`, `locked_policy_version`, `locked_eligibility_version` ↔ `locked : Option LockStamp`
- unique vote actor IDs ↔ `castBy : Finset String`
- roster, attendance, quorum, role validity ↔ externally checked Boolean facts in the Lean `Command`
- `REVIEWED_DEMO` ↔ `reviewedDemo`, **never** actual legal/electoral authority

### Concrete changes to reduce the refinement gap
1. `Store.idempotent` now revalidates authenticated actor tenant, role, active status and eligibility **inside** the same `BEGIN IMMEDIATE` transaction that performs the write. The prior outside-only precheck could not establish freshness against another DB process.
2. `Store.snapshot` now uses one SQLite read transaction, producing a coherent multi-query snapshot across concurrent DB writers (subject to SQLite's WAL isolation).
3. `OPEN`, `CAST`, `CLOSE`, `REVIEW` each emit immutable event details binding the policy epoch, eligibility epoch and frozen revision at that commit.
4. The source-different `verify.mjs` now checks every guarded event's epoch witness against the signed LOCK, plus policy version history, revision authorship and locked eligibility version.
5. `tests/refinement.test.mjs` re-signs six corrupt payloads with a trusted signing key and confirms that semantic replay rejects them, tests cross-connection snapshot isolation, atomic rollback and mid-vote roster invalidation.
6. `tests/trace_refinement.test.mjs` independently evaluates concrete actions against the abstract transition contract over 720 deterministic generated inputs. The independent model covers a declared projection and passes Boolean eligibility/role facts as inputs; it is not a proof of legal correctness.

## Formal Lean kernel scope

`formal/ServerRefinement.lean` defines an executable reference transition function for the critical DEMO lifecycle and policy/roster version checks. Its named theorems include stale-operation rejection, duplicate-cast rejection, post-lock revision rejection, and the necessary freshness of any accepted CAST or REVIEW. The workflow `.github/workflows/commonwealth-server-refinement-lean.yml` uses pinned Lean 4.36.0-rc2 and Mathlib, strict axiom auditing, and source-hash custody. **Do not call it certified unless the current workflow run actually succeeds.**

The previously certified 15/15 abstract Democratic Assurance declarations in [run #43777906044](https://github.com/d3lefts/d3lefts/actions/runs/43777906044) prove conditional evidence-to-effect soundness. This new server does not implement a trusted real-world effect sink, so those proofs cannot be silently inherited by the server's DEMO vote-review status.

## Assumptions NOT discharged

- **No concrete language refinement:** Node.js and SQLite have not been proven equivalent to the Lean transition function for arbitrary values or concurrent executions; bounds tests are evidence, not a universal theorem.
- **No real legal attestation:** institution-specific governing documents, electorate, quorum, voting authorization and appeals remain externally unverified.
- **No official voting protocol:** ballot secrecy, coercion resistance, end-to-end cryptographic voting validity and accessibility remain unevaluated.
- **No externally effectful operation:** `REVIEWED_DEMO` is only a synthetic review state; no authorization for money transfers, official adoption or municipal records exists.
- **No host/security trust:** tamper-resistant key custody, server compromise, DB administrator attack, disaster recovery and external audit anchoring are outside the proof.
- **No liveness:** the checker proves fail-closed safety under its assumptions, not guaranteed availability or legitimate-action completion.

## Correct next scientific gate

Formulate and verify a *concrete refinement contract* that validates every permitted database write against the event-producing transition relation and includes a complete inventory of external effects. Machine-check the actual transaction isolation/linearization argument separately, including multiple processes and revocation interleavings. Independent review must attack both the abstraction map and unmodeled database/API behaviors before any binding pilot.

**Deployment gate:** only DEMONSTRATION/ADVISORY states are permitted here. Leave source and PR in draft until all institutional, security and operational assumptions are independently discharged.
