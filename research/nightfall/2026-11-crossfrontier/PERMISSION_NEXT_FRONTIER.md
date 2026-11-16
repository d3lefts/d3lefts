# NIGHTFALL permission economics — v1.1 adversarial next frontier

Date 2026-11-16. Preserve PR #603's and #636's original certified scopes; do not hide novel mechanics behind the formula. This note presents a rigorous scoped generalization and preregisters the next structural tests. It does not certify real-world effect mediation.

## What our completed results jointly establish

- Matching zero-error cost of complementary evidence versus perfect direct inspection with a hard capacity/deadline requirement and trusted final guard (pinned Lean PR #603).
- Authenticated one-checkpoint authority revision with a stable post-checkpoint epoch, all nonnegative raw-disclosure/predicate fees, exact optimal strategy switch, and a *separate* correlated possible-world admission certificate (pinned Lean PR #636).
- Certificate-invalidation capacity externality: even one revoked certificate can raise the overall optimal verification cost more than its direct replacement cost (exact witness 4→12 under costs 1 and 5).
- Semantic-fence impossibility of invisible unsafe version changes; operational completeness is an external assumption rather than inferred from a successful checker.
- Genuine negative benchmark: PR #642 reports a selective audited guard faster on four authored ControlArena fixtures but still admitting 1/4 harmful fixtures, whereas the full mission verifier rejects all. A faster unsafe gate fails our mission.

## New mechanism: adversarial possible-world enlargement as residual hitting set

Fix a nominal safe world w*, finite set W_t of worlds possible under authenticated authority version e_t, safety predicate P, allowed sensors s∈S with deterministic outputs o_s(w) and nonnegative costs. Let an existing set C of source-transferable, authenticated sensor certificates be truthful at w*. Define D(w)={s:o_s(w)≠o_s(w*)}. The cached certificate remains a zero-error safe admission proof after revision W_t→W_{t+1} exactly when
  ∀w∈W_{t+1} with not P(w), D(w)∩C≠∅.
For a new allowlist A, the **exact minimum incremental repair cost** with additive prices and reuse of C is
  min { Σ_{s∈T}c_s : T⊆A\C, ∀unsafe w∈W_{t+1}, D(w)∩(C∪T)≠∅ }.
Proof: necessity by indistinguishable unsafe completion, sufficiency by the full distinguishing transcript, and attainment by finite enumeration. This yields a general correlated change-repair objective, *not* the independent modular closed form. It is a special case of classical weighted Hitting Set, so novelty can only reside in source authentication, privacy/effect coupling, or an improved algorithmic subclass.

Two successive source enlargements can destroy a once-sound proof even when every old observation remains true. The source-checkpoint conditional price is inapplicable without a trusted stable suffix or an atomic revalidation at effect time.

## Counterexample and exact audit

Worlds are (x,y)∈{0,1}²; nominal (0,0); safe iff x=y. Epoch W0={(0,0),(1,1)} admits a 0-read certificate. W1=W0∪{(1,0)} requires x, or both-raw, or predicate. W2=W1∪{(0,1)} requires x and y (cost 2) or a permitted predicate (cost 3). The cached x=0 is still true but fails to protect against unsafe (0,1). If a source revision can occur after evidence and before effect finality without an authenticated guard that prevents stale use, any accepting path admits the indistinguishable unsafe continuation.

Companion exact independent enumerator checks every nested finite-world sequence and sensor subset under the strict disclosed allowlist. Source-reconstruction and executable admission behavior, not raw arithmetic alone, are the next experimental targets.

## Pre-registered decisive experiment

**Prediction:** A source-version-only guard will accept at least one unsafe history when a policy/correlation dependency changes without propagating its source version. An authenticated complete dependency fence rejects it, but may reduce legitimate availability; a trusted atomic finality guard plus fresh sufficient evidence restores safety.

**Alternatives:** (i) a complete dependency graph means version-only already suffices; (ii) raw evidence remains sound under the chosen update; (iii) monitor and enforcement share a failure domain.

**Test:** Build an independently coded finite adversarial interleaving explorer for two revisions inside one inspection window, with all enabled histories, separate witness construction and admission implementation; freeze source model and replay. Score unsafe commits, safe effects completed before deadline, cost, and stale/revoked evidence reuse; compare naive full refresh, scope-aware refresh, and optimal zero-error policy on the same worlds. Then reproduce on a concrete actual effect sink, with a deliberately omitted dependency negative control.

**Stop rule:** Any unsafe committed effect falsifies the corresponding implementation contract regardless of cost advantage. No unrestricted physical-safety or universal optimality claim without independent guard-path completeness. Target the joint minimax of safe availability, freshness, privacy, and true effect completeness, not scalar coefficient polishing.

## Priority / novelty boundaries

Classical hitting sets, Bayesian decision rules, source-version optimistic concurrency, multi-mode scheduling, reference monitors and 2026 assurance-aware scheduling are antecedents. Distinguish the new integrated assurance contract from the standard optimization primitives. No human referee, full prior-art clearance, or consequential deployment authorization is implied.
