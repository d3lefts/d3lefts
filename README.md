# NIGHTFALL / PHASESHIFT

**An open research archive for mathematics, exact computational evidence, and trustworthy AI systems.**

Research directed by **Devin J. Wright** · Human-led, AI-assisted · 2026

[Research engineering and evaluations](https://d3lefts.github.io/d3lefts/engineering.html) · [Evaluation lab](https://d3lefts.github.io/d3lefts/evals.html) · [DispatchQ-B1 task-design dossier](https://d3lefts.github.io/d3lefts/dispatchq-b1.html) · [Principal mathematical results](https://d3lefts.github.io/d3lefts/mathematical-results.html) · [Research website](https://d3lefts.github.io/d3lefts/) · [Browse research](https://d3lefts.github.io/d3lefts/research.html) · [Independent review](https://d3lefts.github.io/d3lefts/review.html) · [Source and evidence](https://d3lefts.github.io/d3lefts/evidence.html)

[![Verify research website](https://github.com/d3lefts/d3lefts/actions/workflows/verify-site.yml/badge.svg)](https://github.com/d3lefts/d3lefts/actions/workflows/verify-site.yml)

NIGHTFALL studies mathematical structures and builds reproducible mechanisms for discovering, checking, and explaining results. Every claim should travel with its **statement, assumptions, source, verification method, and limitations**. A computation, a formal proof, an originality assessment, and a competition result are different kinds of evidence.

## Principal mathematical result — Universal Quadratic Influence

For essentially bounded real observables of Hoeffding degree at most two on arbitrary independent probability spaces, including arbitrary index sets and heterogeneous measurable alphabets,

$\operatorname{Var}(f)^2\le C_2 B^2\sup_i I_i(f),\qquad C_2=\bigl(2(1+\sqrt2)\sqrt3+11901/6250\bigr)^2\approx105.41623982.$

Here $|f|\le B$ almost everywhere and $I_i$ is the squared original-law heat-bath residual norm. Equivalently, the bound holds for every nonnegative common influence cap $M$. The formal Hoeffding-degree predicate is the closed span of degree-at-most-two coordinate components. A separate biased-sign construction certifies the necessary lower bound $C_2\ge4$; the optimal coefficient is not known.

**Evidence:** [Named Lean theorem](research/nightfall/formalization/universal/InfinitePiQ2HoeffdingDegree.lean) · [a.e. residual terminal](research/nightfall/formalization/universal/InfinitePiQ2UnconditionalTerminal.lean) · [integrated Lake build and kernel replay](https://github.com/d3lefts/d3lefts/actions/runs/44470008420) · [lower-bound construction](https://github.com/d3lefts/d3lefts/pull/819). Lean 4.36.0-rc2, pinned Mathlib. The finite theorem is separately certified. External specialist statement review and worldwide originality remain open; no claim of a new result for the classical binary-only setting.

## Research portfolio

- **Mathematical observability:** product-space influence, variance bounds and adaptive prediction.
- **Information and quantum complexity:** source-relative query models and classical simulation.
- **Phase retrieval:** adaptive reconstruction and fundamental recovery limits.
- **Research engineering:** formal verification, reproducible evidence and agent evaluation; blind external-model benchmark results are not yet established.

[Mathematical results](https://d3lefts.github.io/d3lefts/mathematical-results.html) · [Engineering and evaluations](https://d3lefts.github.io/d3lefts/engineering.html) · [Claim catalogue](research/catalogue/CLAIMS.json)

## Scholarly research archive — start here

For a mathematician or referee, begin with the [**paper shelf**](papers/README.md), then the [**canonical claim catalogue**](research/catalogue/README.md) and its [machine-readable status/dependency registry](research/catalogue/CLAIMS.json). Each paper entry directs you to the **original source**, exact evidence, and specific missing proof gates; it does not copy or promote its theorem.

[Independent referee desk](research/referee/README.md) · [Historical finite evidence and errata](research/archive/README.md) · [Publication/reuse rights](research/REUSE_AND_RIGHTS.md) · [Full research map](research/README.md).

This is a **non-destructive index migration**: the original `research/nightfall/` files, Lean declarations, witness hashes, cited URLs and frozen 40-record/11-passport historical catalogues remain in place. The selected claims in the current catalogue are **not** a count of refereed results or additions to the approved finding list. The [Paper A](papers/exact-recovery/MANUSCRIPT.md), [Paper B](papers/spectral-adaptive-prediction/MANUSCRIPT.md), and [Paper C](papers/specialized-complexity/MANUSCRIPT.md) manuscripts have distinct query models and certification scopes. Their validity, source completeness, independent review and originality remain separately labeled.

## Lean certification environment — current and historical

The active Lean/Mathlib compiler configuration is **Lean 4.36.0-rc2** (exact Mathlib commit `9d581dfff2e41de989072ea63abf3daf69311520`), defined in [the compiler lock](docs/lean-compiler-lock.json), reproduced via the [compiler and certification guide](docs/lean-compiler-settings.md), and checked by the shared [CI installation](.github/actions/setup-nightfall-lean/action.yml). Historical 4.33/4.35 certificate receipts are retained at their original pins, not silently migrated.

Merged [PR #696](https://github.com/d3lefts/d3lefts/pull/696) provides a **103-source selected Q2 Lake build**, four named axiom checks and `lake check` official kernel replay at this exact pin (run [44027853225](https://github.com/d3lefts/d3lefts/actions/runs/44027853225)). That historical build's infinite-product L² limit is **conditional**; later PRs #776 and #888 certify separate unconditional terminals. multi-kernel `lake check --paranoid` and independent field-statement review remain separate gates. Current finite unrestricted Q2 coefficient C105.416 has its own original-source certificate. See the [active Proof Passport overlay](docs/lean-proof-passport-overlay.json) for exact named declaration and remaining obligations.

**Expanded shared certificate:** Merged [PR #718](https://github.com/d3lefts/d3lefts/pull/718) subsequently extended the selected Q2 closure to **107 original source modules**; exact [run 44120677824](https://github.com/d3lefts/d3lefts/actions/runs/44120677824) passed `lake build Nightfall`, eight named axiom reports and independent `lake check`. Its historical limit declaration is conditional; this checkpoint was superseded by the unconditional terminal in #776 and Hoeffding integration in #888. The all-(L^2) source-label extension in #743 has its own pending common-build gate. The merged GF(9) all-length adaptive source certificate (#690) is **not** included in this selected Q2 Lake graph.

## Historical research checkpoint — 14 November 2026 (superseded where noted)

**Start with the active work, not the historical PR queue:**

- **The Right to Act / autonomous assurance:** [assurance research hub](research/nightfall/assurance/README.md) · [exact semantic-fencing theorem and executable audits](research/nightfall/assurance/semantic-fencing-v0.3/README.md) · [real ControlArena IaC Fast benchmark code](research/nightfall/right-to-act-controlarena/live_iac_fast.py). The former Tennessee Eastman plan is a **historical, superseded** benchmark, not the active track. Physical/non-bypass safety remains unproved.
- **Quadratic influence and observability:** [original-source formalization](research/nightfall/formalization/README.md) · [conditional shifted Q2 107/99 targets](research/nightfall/formalization/q2_shifted/Q2ShiftedConditionalTargets.lean) · [single pinned source certification pipeline](.github/workflows/nightfall-q2-consolidated-lean.yml). The shifted-owner 190/107/99 route was conditional at this checkpoint; distinct unconditional finite C107 and C105.416 terminals subsequently compiled. The historical scalar implications are not themselves terminal proofs.
- **Proof and source custody:** [November 14 PR reconciliation and limits](research/nightfall/assurance/RECONCILIATION_20261114.md) · [research archive and preserved retired workflows](research/archive/README.md) · [live pull-request queue](https://github.com/d3lefts/d3lefts/pulls?q=is%3Apr+is%3Aopen). Earlier dated queue documents are snapshots, not a live status feed.

For new contributors: claim and proof status are determined by exact source, assumptions, and receipts—not by a PR's title, a green generic build, or the date in a folder name.

## Historical research checkpoint — 13 November 2026

The permanent archive and dated finite-evidence catalogues are preserved; recent author-side theorem work has **not** silently upgraded their originality or formalization status. For the full live overlap map, see [active research / integration queue](research/nightfall/ACTIVE_RESEARCH_QUEUE_20261113.md).

- **Quadratic influence (Q2):** the then-current *analytic* original-law finite-product bound is $\operatorname{Var}(f)^2\le K_2 B^2\max_i I_i(f)$, $K_2=(10+2\sqrt2)^2(1+\sqrt3)^2\approx1228.3563$, in merged [PR #448](https://github.com/d3lefts/d3lefts/pull/448). The fractional/soft ownership route in merged [PR #452](https://github.com/d3lefts/d3lefts/pull/452) is an author-analytic alternative with passing exact tests; independent proof scrutiny and terminal Lean remain open. The matching, Jensen and original-source Lean receipts on `main` have narrower scopes; no terminal source-only Q2 declaration had compiled at that historical checkpoint. Later unconditional finite and arbitrary-product certificates supersede that status; priority against categorical Grothendieck/decoupling remains unresolved.
- **Sharp restriction obstruction:** [weighted finite-replica transfer](research/nightfall/2026-11-replica-restriction/README.md) proves on paper a sharp joint variance-retention/maximum-influence tradeoff, with two independent exact-rational checkers and a passing [scoped replay](https://github.com/d3lefts/d3lefts/actions/runs/43515837487). It rules out a particular Boolean-to-categorical proof transfer, **not Q2 itself**. Worldwide historical novelty and external review remain open.
- **The Convoluted Costs of Knowing:** author-side candidate [oracle-matched task-revelation theorem, merged PR #450](https://github.com/d3lefts/d3lefts/pull/450), [posterior influence bridge, merged PR #449](https://github.com/d3lefts/d3lefts/pull/449), and [editorial dissertation, merged PR #446](https://github.com/d3lefts/d3lefts/pull/446) are distinct research tracks; merging documentation does not confer theorem validity or doctoral acceptance. Keep their models and conditional premises explicit; do not merge the dissertation as a finished doctoral submission.

**Integration discipline:** see the [live open research PRs](https://github.com/d3lefts/d3lefts/pulls?q=is%3Apr+is%3Aopen) for the current count; the dated research queue records the last independently reviewed snapshot. The remaining Q2 source branches overlap modules already merged into `main`. A separate [source custody repair](https://github.com/d3lefts/d3lefts/pull/454) registers exact Lean blobs instead of disabling provenance checks. Never bulk-merge them by PR number. Match exact theorem types, source hashes, compiler pins, and proof dependencies; preserve counterexamples and abandoned routes.

## Start here

| Area | What is available | Where to inspect it |
| --- | --- | --- |
| **Product-space influence and fractional certificates** | Certificate Engine v2 candidate and a separate **Lean 4.33.0 kernel-compiled finite-product scalar influence theorem** (PR #317; exponent 5/2, explicit weaker coefficient), alongside earlier **Lean 4.35.0** supporting bridge lemmas with narrower scopes. The arbitrary-product scalar degree-two extension now has an integrated Lean terminal; adaptive Hilbert extensions retain their own distinct certification scopes. The unrestricted degree-three and general degree-dependent exponent-two questions remain open. | [Manuscript and checks](research/nightfall/2026-11-certificate-engine/README.md) · [Lean source](research/nightfall/formalization/product_space/) · [Proof-status dossier](https://d3lefts.github.io/d3lefts/product-space-influence.html) |
| **Cubic leaf-alphabet-free influence (active, restricted)** | Analytic exponent-two bound for cubic interactions with a bounded **top-degree-only** vertex cover; also any number of independent covered blocks, with no leaf count/alphabet/minimum-mass factor. Includes an exact selector sharpness example, a nonadaptive lower bound, and a rank-sensitive Hilbert corollary with a logarithmic overhead. **Not the unrestricted cubic theorem; no external peer review or full Lean receipt.** | [Proof and limits](research/nightfall/2026-11-cubic-leaf-alphabet-free/PROOF_NOTE.md) · [Exact direct-resampling checks](research/nightfall/2026-11-cubic-leaf-alphabet-free/check_leaf_free_exact.py) · [Review PR #335](https://github.com/d3lefts/d3lefts/pull/335) |
| **Erdős minimum overlap** | Exact finite rational witness and independently replayable arithmetic; mathematical witness identity is distinct from any accepted competition entry. | [Evidence and prior-art status](research/nightfall/projects/erdos/STATUS_AND_PRIOR_ART_20261028.md) |
| **Sidon and finite-field constructions** | Explicit finite objects, exact checkers, source-dependent theorem candidates, and open proof/novelty audits. | [Curated research index](research/nightfall/README.md) |
| **Werner-state bounds** | Conditional finite-copy certificate registry and documented source-inequality dependencies. | [Werner atlas](research/nightfall/projects/werner-atlas/README.md) |
| **AI safety and verification** | SourceBound/authorization research and a publicly available review release; theoretical claims and measured experiments are distinguished. | [Review dossier](research/nightfall/projects/ai-safety-peer-review-2026-10-28/README.md) |

**Historical curated editorial scope (10–11 November 2026; later active status recorded above).** The website includes 40 curated research records, 11 evidence-specific Proof Passports, and five internally approved finite or bounded findings (three in the core index and two in a separately scoped publication note). These are *catalogue and evidence classifications*, **not** a claim that five globally original theorems have received independent peer review. New candidate manuscripts remain outside that approved finding set.

## Read and verify the evidence

- [Current public research library](https://d3lefts.github.io/d3lefts/research.html), [claim-specific limitations](research/nightfall/AUDIT.md), and [publication-scope boundaries](research/nightfall/PUBLICATION_SCOPE.md).
- [Review protocol](research/nightfall/REVIEW_PROTOCOL.md) explains reproducibility, formalization, attribution, and counterexample reporting.
- [Public curated evidence release](https://github.com/d3lefts/d3lefts/releases/tag/nightfall-research-2026-10-28) includes the archived checksums and supporting materials. The private historical master archives are **not** public release assets.

### Repository guide

| Path | Purpose |
| --- | --- |
| [`docs/`](docs/README.md) | Static research website, accessible interactions, and its development guide |
| [`papers/`](papers/README.md) | Theorem-first scholarly reading room; one primary-source link per principal mathematical manuscript |
| [`research/catalogue/`](research/catalogue/README.md) | Selected claim statuses and dependency DAG with automatic editorial validation |
| [`research/referee/`](research/referee/README.md) | Explicit external proof-review assignments and failure-report format |
| [`research/archive/`](research/archive/README.md) | Historical finite objects, releases, source custody, errors and adverse experiments |
| [`research/nightfall/`](research/nightfall/README.md) | **Unmoved original** manuscripts, candidate proofs, certificate packages, research histories, and audits |
| [`research/nightfall/formalization/`](research/nightfall/formalization/) | Lean proof sources with explicitly scoped theorem statements |
| [`scripts/`](scripts/) and [`tests/`](tests/) | Exact checkers, CI support, website tests, and adversarial controls |
| [`.github/workflows/`](.github/workflows/) | Automated checks and reproducibility receipts |

### Reproduce a first check

From the repository root with Python 3 and Node.js:

```bash
python3 scripts/check_site.py
python3 scripts/test_repository_docs.py
python3 scripts/check_research_archive.py --self-test
node scripts/test_proof_passport_batch.cjs
```

These are documentation/site and **scoped finite-record consistency checks**, not mathematical refereeing. Some browser tests require Chromium and Playwright; specialist research checkers document their own inputs, toolchains, and hashes. For the pinned Lean bridge, see [the formalization directory](research/nightfall/formalization/product_space/) and [contribution guide](CONTRIBUTING.md).

## Contribute or report a problem

Independent replications, attempted counterexamples, missing-source reports, and priority corrections are welcome. Open a [verification report](https://github.com/d3lefts/d3lefts/issues/new/choose), or use [CONTRIBUTING.md](CONTRIBUTING.md) and the repository pull-request template for source-backed changes. Negative results and superseded claims remain part of the record.

This project is **human-directed and substantially AI-assisted**. Specific manuscripts credit earlier authors, imported theorems, AI drafting contributions, and independent reviewers separately. A green CI run or an AI cross-check is not an external peer-review endorsement.

### Reuse and licensing

There is **no repository-wide `LICENSE` file** at this checkpoint. Public visibility alone does not grant a blanket right to reuse source code, figures, manuscripts, or third-party materials. Check individual files and upstream sources, and obtain permission where required. [Citation metadata](CITATION.cff) describes how to credit the archive; it is not a software license.
