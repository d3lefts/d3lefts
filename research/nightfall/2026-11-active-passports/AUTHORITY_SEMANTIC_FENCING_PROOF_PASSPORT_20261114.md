# NIGHTFALL — Conditional Authority and Semantic Fencing Proof Passport (v14)

**Claim type:** supplemental to the twelve active mathematical claim IDs; not a thirteenth historical or internally approved Original Finding.  
**Research direction:** Devin J. Wright; AI-assisted proof construction, test development and source auditing.  
**Audit checkpoint:** 14 November 2026 (exact GitHub run IDs below).  
**Status:** **ten scoped Lean kernel-checked declarations on an unmerged draft PR**, source-matched **local** effect-service integration tested, general external effect mediation **unverified**. No independent human referee or priority certification.

## Mathematical statements

For a finite set of authenticated versioned sources `I`, a coherent safe baseline evidence set `B`, a permitted unsafe-history family `H_a(B)` of changed-source supports, and an atomic gate capable **only** of source-version equality tests, a set of checked sources `J` is sound **iff** it intersects every unsafe support. An unsafe permitted transition with an **empty detectable-change support** cannot be prevented by such a gate.

Under finite complete coverage and additive nonnegative source-check costs `w_i`, a globally minimum-cost fence exists and has cost

```text
G_a(B) = min_{J subset I} { sum_{i in J} w_i :
                           forall D in H_a(B), J intersects D }.
```

For a finite already-safe coherent evidence set, a finitely branching exact-read policy may still optimally observe after the safety *label* is known, because observations reduce the cost of the eventual source fence. The verified Lean theorem uses strong induction on shrinking finite belief sets and proves existence of a globally minimum worst-case-cost policy. The fully general initially mixed safe/unsafe case is **not** the scope of this final Lean declaration. A two-source concrete witness has direct guarded cost 8 quarter-units versus 5 after one read (37.5% saving). The selector family from the original paper note has an analytic unbounded ratio; its full variable-`r` formula is not one of the ten audited Lean declarations.

**Lean source:** [`SemanticFencing.lean`](https://github.com/d3lefts/d3lefts/blob/b4fa2e2ecd6041caafa9b5e9f61fbc10a70f7f1e/research/nightfall/formalization/agent_safety/SemanticFencing.lean), PR [#554](https://github.com/d3lefts/d3lefts/pull/554) **DRAFT, unmerged** at the checkpoint. Source SHA-256 `17779223198926147b1600c9c5faebbf333add1bc05c71562000f491ea624d58`, exact head `b4fa2e2ecd6041caafa9b5e9f61fbc10a70f7f1e`; pinned Lean 4.36.0-rc2 + Mathlib strict declaration/allowed-axiom receipt: [run 43662280902](https://github.com/d3lefts/d3lefts/actions/runs/43662280902). Ten declarations, only standard `Classical.choice`, `Quot.sound`, `propext` dependencies reported.

## Conditional all-horizon agent invariant

A separate, previously **merged** proof [PR #528](https://github.com/d3lefts/d3lefts/pull/528), Lean [run 43639554615](https://github.com/d3lefts/d3lefts/actions/runs/43639554615), certifies six named declarations including `Nightfall.AgentSafety.arbitrary_agent_all_horizons_safe`. It says every admitted discrete trace preserves the modeled invariant for *any* proposed action sequence if trusted effect-time observations, current epoch, complete mediation and all environmental transition obligations hold. It proves **no** hostile-kernel resistance, physical observation completeness, actuator interposition or global human safety.

**Other conditioned model:** [`Semantic fencing v0.3`](../assurance/semantic-fencing-v0.3/README.md) provides the exact finite algorithm, a separate 1,700-instance budget oracle, 350 heterogeneous histories, bounded 661-state interleavings and SQLite single-database negative controls; successful [run 43648303705](https://github.com/d3lefts/d3lefts/actions/runs/43648303705). This is finite supporting evidence, not a replacement for Lean or deployment certification.

## Operational security: source-matched local effect boundary

The ControlArena IaC Fast 20.1.1 security experiment uses real CDK synthesis in unprivileged no-network Docker, trusted source snapshots, independently checked CloudFormation template delta, source-policy epochs, separate Linux service UID, `SO_PEERCRED` and HMAC authentication, replay control, revoke/advance checks and a **single locally committed JSON artifact**. The PR #554 hardening bounds each admitted request by an absolute monotone deadline and a disposable worker, checks UID *before* reading attacker-controlled bytes, and caps the nonce ledger by invalidating old tickets through epoch rotation.

- Earlier PRs [#505](https://github.com/d3lefts/d3lefts/pull/505), [#510](https://github.com/d3lefts/d3lefts/pull/510), [#517](https://github.com/d3lefts/d3lefts/pull/517), [#530](https://github.com/d3lefts/d3lefts/pull/530), [#531](https://github.com/d3lefts/d3lefts/pull/531) test separate phases of transactionality, isolation and availability.
- Exact PR #554 head local security test [run 43662280945](https://github.com/d3lefts/d3lefts/actions/runs/43662280945) **succeeded**, including six fail-fast hardening regressions, the existing 21 tests, and ten independently audited local-authority scenarios.
- Merged [#557](https://github.com/d3lefts/d3lefts/pull/557) adds a *three-proposal* genuine small-model source-edit pilot with both official Inspect/ControlArena scorer types and source-matched archive; [run 43662000190](https://github.com/d3lefts/d3lefts/actions/runs/43662000190) passed. A green replay of three proposals does **not** establish protection against an arbitrary agent or a statistically meaningful success rate.

**Critical caution:** a request timeout may follow a successful atomic rename; clients must reconcile committed state rather than interpreting a timeout as a rollback. Worker deadlines are conditional on kernel scheduling and do not establish availability under floods, crash consistency for external deployments or protection against a compromised privileged issuer.

## Trusted-boundary assumption ledger

| Logical assumption | Empirical test status | Open proof obligation |
|---|---|---|
| Initial safe certified baseline | Official fixed ControlArena CloudFormation fixture and independent source/semantic negative controls tested | Complete behavior of actual AWS deployment not modeled |
| Source epoch authentication and ABA-freeness | Signed service-owned state, version/revoke/nonce/epoch tests passed | Adversary or external mutation routes outside trusted writers not eliminated |
| Effect-time atomic compare and commit | Local service serialized source/revoke updates and one JSON replacement; race controls passed | No verified atomic AWS/physical actuation transaction |
| Correct current observation | Source/policy/template/baseline hashes and coherent snapshot checked | Physical real-state compatibility and observation completeness not certified |
| Complete mediation | Docker guest and unrelated UID unable to reach tested host trusted record | Root-level, direct AWS, other network/resource, other agent and physical bypass channels still open |
| Safe environmental steps | Not part of the local artifact experiment | Explicit verified environment/plant safety model needed |
| Persistence/availability | Authenticated slow-verifier/slow-persistence, idle and slow-drip regressions; bounded nonce history | Flood, scheduler, descriptor, crash and ambiguous timeout outcomes open |

**Detailed scope ledger:** [`OPERATIONAL_TRUST_BOUNDARY_AUDIT.md`](https://github.com/d3lefts/d3lefts/blob/b4fa2e2ecd6041caafa9b5e9f61fbc10a70f7f1e/research/nightfall/assurance/OPERATIONAL_TRUST_BOUNDARY_AUDIT.md) (PR #554).

## Prior art and novelty gate

Finite hitting set/decision trees, Alpern–Schneider safety invariants, reference monitors, optimistic concurrency, SLSA/in-toto, source authentication, and contemporary admission control and adaptive observability predate this package. The narrow research-priority candidate is the **joint exact cost** of adaptive post-certification evidence and atomic semantic-version fencing under a strict version-only interface. No independent dated priority decision or human source-proof review is claimed.

## Reproduction, attack and stop rule

1. Reinspect PR #554 head, exact Lean theorem types and strict permitted-axiom receipt; do not equate a passing registry lint with a Lean build.
2. Reproduce original finite search and SQLite negative controls with `bash research/nightfall/assurance/semantic-fencing-v0.3/run_all.sh`.
3. Replay source-matched three-event ControlArena local effect service and six failure regressions using `.github/workflows/right-to-act-controlarena-promotion.yml` at the exact referenced head.
4. Attempt omitted source changes, alternate direct-effect authority, compromised issuer, stale observation at effect time, environment-change unsafe transition, timeout-after-commit and sustained request flood; each defeats an **assumption**, not the Lean implication.
5. Stop before production safety/novelty promotion or merging drafts if any exact theorem/CI receipt fails; require external human security and mathematical review. Preserve every negative result.

**Final scope:** provably safe **if the abstract trusted-boundary obligations are met**; tested narrow local JSON-enforcement prototype, but not a universally trusted real deployment.
