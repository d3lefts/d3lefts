# NIGHTFALL Observatory / Scientific Constitution v1

**Authorized:** 2026-10-28, by NIGHTFALL Site Owner  
**Technical steward:** Vesper. **Independent research agents:** Axiom, Lemnis.  
**Publication status:** Graph prototype. Gate A may be satisfied by static integrity checks. Gates B and C require additional reproducible outputs before public release under Gate D.

## Article I — A claim has a stable identity and a limited scope

Every public claim has:
- Immutable `id`, positive `revision` and SHA-256 identity hash over the sorted compact UTF-8 serialization of `id`, `revision`, `scope`, `source_key` and `statement`. Historical identities are frozen in `claim-identities.lock.json`; an edited claim must receive a **new identity**.
- A quantified claim statement, explicit scope, status, owner, proof dependencies, source path and revision, reproduction instructions, boundary condition and falsifiers.
- A source record tied to original archive paths. Existing sources use the pinned Git commit `df9511c622c309046180fd0e015aca88577c58ec`; new Observatory notes are marked release-v1 until their own publication commit is pinned. The Git history and identity lock together preserve the published record.
- An honest reproducibility distinction: a source-conditional exact arithmetic check proves only its downstream identity; a source-theorem dependency remains conditional until independently justified.

A second, per-claim frozen status attestation in `claim-identities.lock.json` records status, title, owner, boundary, reproduction commands and falsification conditions. Dependencies, full provenance and scientific edge content have separate immutable lock records. The pull-request checker rejects edits to any lock already published on the target branch. Status promotions receive a **new claim identity** with an evidence-linked review event; retained historical claims remain inspectable. New initial locks still need human scientific review: a local hash can detect an inadvertent mutation, yet cannot independently establish truth.

Claim status vocabulary: `certified-finite`, `established-method`, `empirical-negative`, `conditional`, `candidate`, `proposed`, `falsified`, `withdrawn`.

## Article II — Typed edges are scientific assertions

Exactly five classes:
1. **Proven implication:** An explicit proof supports the stated implication, with compatible quantified scopes. The v1 validator *allowlists* each reviewed implication and checks its required algebraic exemplar. It cannot establish correctness of arbitrary new mathematics.
2. **Certified computational dependency:** A published finite conclusion is tied to a specific reproducible calculation, with a checker path and exact source artifact.
3. **Shared mathematical mechanism:** An analogy in construction or verification, with an explicit statement that neither project implies the other.
4. **Proposed transfer:** Required source premises, target assumptions and cheapest decisive falsification experiment are recorded. No conclusion is advanced.
5. **Falsified transfer:** The failed claim, precise test and recorded adverse outcome remain queryable.

A common word, mathematical analogy, shared constraint format or bibliographic citation **never** becomes an implication edge on its own. Each edge carries a source file, rationale, assumptions, experiment and status.

## Article III — Failure and priority are first-class

Withdrawals, corrected comparisons, negative experiments and source-priority demotions remain visible with provenance. A genuine mathematical result, an original computational artifact, a source-conditional certificate and a newly named formulation must never share a status by convenience. Novelty requires dated comparison against closest pre-existing literature.

## Article IV — Display contract

Original Findings remains the homepage and entry point. The Observatory is a separate, progressively enhanced network view with:
- Scope Boundary — what additional inequality, scope or hypothesis is missing.
- Evidence Trace — exact source and proof-dependency chain, plus reproduction commands.
- Transfer Explorer — graph edges with type, assumptions and next decisive test.
- Failure History — rejected claims and negative data retained permanently.
- Research Frontier — prioritized blocked steps, with owner and absence of a certified result explicit.

Accessibility: static fallback, keyboard-selectable entities, visible focus, reduced-motion support and text-equivalent edge lists. The visual graph is never the sole way to read a scientific statement.

## Article V — Release gates

- **A, evidence integrity:** exact schema, frozen identity hashes, source-path existence, edge types, proof edge allowlist, no unsupported implication, explicit scope and failure conditions; checked by `scripts/verify_observatory.py`.
- **B, independent reproduction:** at least one complete scientific result reconstructed from primary input by an independently implemented method and checked with exact arithmetic. Existing Sidon finite checks are a candidate; frozen machine-proof artifact and independent replay receipt must accompany the public release. A local CI pass alone does not certify outside independence.
- **C, controlled transfer evaluation:** a predeclared graph-assisted decision versus a flat baseline at identical research budgets. Follow `GATE_C_PREREGISTRATION.md`; negative results may fulfill the evaluation milestone if genuine and inspectable.
- **D, public release:** A, B, C pass; review status, interaction accessibility and performance meet acceptance tests. This preview stays on a feature branch until that condition holds, unless explicitly authorized as a labeled experimental preview.

A release gate reports `pending`, `passed`, or `failed`; it never silently promotes itself.
