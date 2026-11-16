# NIGHTFALL active dependency closure — frozen 2026-11-16

This *adds* the missing transitive proof-obligation layer between the existing
`CURRENT_FRONTIER.json` (historically pinned selected theorems) and the many
proof passports and draft PR descriptions. It does not replace those sources,
change any public claim, or assert independently checked Lean theorems.

**Recovery:** `python3 scripts/check_active_dependency_closure.py --self-test --summary`

**Independent structural audit:** `node scripts/independent_dependency_closure.cjs`
uses a separate runtime and iterative topological/reachability algorithm. Together
these checks reject **20 independently implemented negative metadata fixtures**
(12 Python, 8 Node). Both read the same frozen JSON, so this is algorithmic
cross-checking, *not* blind theorem reconstruction or independent Lean review.

**Freshness:** `python3 scripts/check_active_dependency_closure.py --live`
checks the *three* frozen draft PR head SHAs against GitHub and fails if any
have moved. It verifies source identity only; historical CI success alone
does not establish a complete proof.

The initial graph contains **two frontier terminals, 11 nodes and seven
open proof obligations**. The quantum chain requires actual-source Born trace,
a fully feasible measurement and one dependency-closed optimality theorem.
The F9 same-oracle chain requires the adaptive decoder bridge, nonadaptive
obstruction, coding-rate transfer and one final theorem. Construction is
not automatically completion: `scoped_ci_reported` and
`conditional_ci_reported` remain separate from `open`.

## Source-linked refresh overlay — 16 November 2026

The original 11-node DAG is intentionally an immutable *earlier* snapshot,
not a live truth table. The higher-freshness evidence index is
[`SOURCE_LINKED_PASSPORT_EVIDENCE.json`](SOURCE_LINKED_PASSPORT_EVIDENCE.json).
It records independently identified draft sources for:

- **Quantum:** physical-source normalized Born optimum and full-dimensional
  attaining POVM on [PR #658](https://github.com/d3lefts/d3lefts/pull/658).
  Its scoped Lean theorem passed; the original frozen q-terminal=open entry
  must not be misread as current proof status.
- **F9:** the same-oracle fixed lower-bound component on
  [PR #659](https://github.com/d3lefts/d3lefts/pull/659). Its adaptive
  all-k *legal policy* remains unformalized. Packet-algebra proofs and finite
  transcript tests do not discharge this terminal gate.

Run `python3 scripts/reconcile_source_linked_passports.py --self-test --live`
to check two exact PR heads, source Git blobs, matching successful named CI
workflow runs and named source declaration presence, with **nine adversarial
source/CI/claim-promotion mutations**. Head drift, failed workflow or changed
source fails closed instead of silently promoting a claim.

Run `python3 scripts/propose_source_refresh.py --output source-refresh-proposals.json`
to *generate a review-only candidate* from current sources. The CI workflow
also produces this review artifact and runs a scheduled daily drift check.
Neither program writes the canonical registry, changes the frozen graph,
merges branches, executes external code, or proves novelty. Changes to active
scientific status require manual scope review plus exact checking of the
source and proof dependencies.

---

## Repair rules

- The JSON is an immutable dated *checkpoint*. To update source evidence,
  advance its snapshot and checker together, preserve the previous snapshot in
  Git history and reproduce the exact cited workflow/artifact/source.
- Confirm a named theorem's *whole dependency closure* with the pinned Lean
  kernel, standard-axiom audit, explicit source/quantifier check and an
  independently implemented adversarial check before considering promotion.
- The checker hard-locks the status, original receipts, dependency edges,
  and terminal identities. It rejects twelve deliberate tampering cases:
  missing edges, cross-domain edges, loops, forged CI receipt/PR SHA,
  status promotion, erased assumptions and loss of independent tests.
- A passing ledger check validates only the **metadata and recovery graph**.
  It neither runs Lean nor proves correctness, novelty or safety.
- One agent constructs from frozen assumptions and inputs; another checks
  with disjoint implementation and no access to intermediate construction
  state. Store the separate checker source, exact input, outcome, and any
  counterexample in the existing Proof Passport infrastructure.
- For cross-domain transfers, make a *new* explicit theorem with assumptions,
  matching operators, a source/target map and an independent countermodel
  attack. A conceptual atlas edge is not a proof.

**Scope:** the PR source records currently live in
[#645](https://github.com/d3lefts/d3lefts/pull/645),
[#647](https://github.com/d3lefts/d3lefts/pull/647), and
[#655](https://github.com/d3lefts/d3lefts/pull/655).
They are draft, unmerged sources. Track their heads before trusting this page.
This is a capability/continuity improvement, **not a mathematical discovery**.

**Operational metric:** one command reconstructs 11 nodes and the actionable
minimum proof cut, with twelve independent negative metadata mutations. The
first test of useful impact is whether the next session can identify the same
ready-vs-blocked obligations without user correction; that user-effort
reduction remains **unmeasured**.
