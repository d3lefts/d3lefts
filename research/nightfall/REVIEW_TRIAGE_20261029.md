# NIGHTFALL / Product-owner review queue — 29 October 2026

**Scope:** Editorial prioritization and adversarial review, not publication approval or a new scientific result. **Source snapshot:** `main` at `a677580b7b8d1a047ec501e4aa4ed9e6db1d82d1`. PR states change; follow the linked live PRs before acting.

## The next three scientific decisions

| Priority | Source and precise object | Independent attack needed | Release criterion |
| --- | --- | --- | --- |
| P1 — affine-gluing theorem | [Axiom draft #203](https://github.com/d3lefts/d3lefts/pull/203): uniform hyperplane and codimension-two incidence recovery for glued normalized quadratic planar maps over `F_3^n`, `n ≥ 3` | Non-author rederive the scalar-fiber bound, prove *all* heavy sections and full affine recovery, reproduce independent nonplanar negative cases, search same-premise prior art | Expose complete universal quantifiers, checkers, sources and dated priority comparison; leave as **candidate** until reviewed |
| P2 — cubic cover family | [Lemnis draft #204](https://github.com/d3lefts/d3lefts/pull/204): connected cubic bipartite covers parameterized by `d ≥ 8`, girth 14 and a 32-cycle | Independently enumerate quotient-neutral cycles and six polynomial obstructions, audit primitive-element existence and connectivity for every claimed degree, replay small fields with fault injection | Signed-off non-author proof and independent code review; no Erdős–Gyárfás solution or global record inferred |
| P3 — continuum transport barrier | [Tessera draft #199](https://github.com/d3lefts/d3lefts/pull/199): correct complement support, exact no-go for arbitrary-grid averaging, conditional bounded-variation transport | Check the pulse counterexample **for each grid N**, the `h TV(f)` constant and endpoint cases, compare independent `Fraction` implementation to its checker | Reconcile with already-corrected `main` [certificate ledger](CERTIFICATE_TRANSPORT_LEDGER_20261029.md); merge incremental proofs/tests only, avoid duplicate or contradictory definitions |

These are **review priorities**, not a ranking of the importance or novelty of the results. Internal checker agreement is neither independent human refereeing nor a dated same-premise novelty finding. A rigorous counterexample is a successful review outcome.

## Two execution dependencies

1. **Release integrity:** the default branch is presently unprotected. GitHub Pages publication can succeed despite a failing `Verify research website / verify` run. Set an enforced `main` ruleset requiring PR review and the website verification check; verify it with a deliberately failing PR. The connected GitHub workflow cannot configure administrative rulesets. **Until then, maintainers must manually withhold merges and publication claims on red checks.** [Contribution policy](../../CONTRIBUTING.md).
2. **CG:SHOP artifact identity:** [PR #175](https://github.com/d3lefts/d3lefts/pull/175) remains the code-integration lane. Establish which official-checked 250-instance V2 archive corresponds to **exact input bytes and Git SHA**; compare per-instance scores to official results before any competitive standing claim. Do not substitute the baseline PR's synthetic checks for official validation, and require operator authorization for an external competition submission.

## The owner decision sequence

1. **Reproduce the state:** capture base SHA, source and checker hashes, official inputs where needed, exact commands and failed-case witnesses.
2. **Check *scope* before novelty:** specify whether the statement is finite, conditional, dimension-uniform or universal; list imported assumptions. Identify source theorem dependencies.
3. **Independent adversarial pass:** non-author derivation plus separately implemented executable oracle where suitable. A negative result stays visible and may close the lane.
4. **Priority review:** dated same-hypothesis prior-art comparison, then assess real leverage. Never upgrade originality based on local tests.
5. **Integrate:** one scoped PR per claim, review outstanding comments, verify the current merge head, preserve all source links and prior certificates.
6. **Publish:** prefer a calm, curated public surface with one reproducible source path and explicit open obligations. A CI check is software assurance, not mathematical peer review; an accepted contest score requires an official receipt.

**Next-team routing:** Lemnis proof-attacks #203, Axiom independently audits #204, Ryev audits #199 with a separate implementation and maintains release CI, Vesper reconciles citations, conditions and decisions. Each reviewer must disclose any overlap with authorship; a reviewer that contributed to the proof is an internal collaborator, not an independent referee. Operator sign-off remains necessary for claims requiring human publication approval.

**Stop conditions:** If the exact checker fails, archive counterexample and demote the claim. If priority is inherited, credit the earlier source and retain only a demonstrated new technique. If a change raises no measurable scientific, reproducibility or user-journey value, do not add another public section.
