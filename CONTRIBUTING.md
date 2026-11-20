# Contributing to NIGHTFALL

NIGHTFALL welcomes exact reproductions, proof criticism, source corrections, research tools, and clear documentation. **Evidence quality matters more than the volume of changes.** We retain failed attempts and prior versions when they explain a claim's limitations.

Research is directed by Devin J. Wright and is substantially AI-assisted. Internal model agreement is not independent external peer review. A passing test certifies only its stated scope.

## Active Lean 4.36 certification

New formalization and current-source CI changes must use the [canonical compiler lock](docs/lean-compiler-lock.json) and [reproduction guide](docs/lean-compiler-settings.md): Lean `4.36.0-rc2` and exact pinned Mathlib, checked via the shared `setup-nightfall-lean` action. Reuse the generated [Lake dependency manifest](lakefile.toml) and run `python3 scripts/generate_nightfall_lake.py --check`; never hand-edit source imports or historical receipts to make a build pass.

For a named theorem, retain exact source SHA, original definition/hypotheses, `#print axioms`, `lean_bridge.py --strict` receipt, and a scoped independent `lake check` when in a common project. `lake check --paranoid` is a separate, resource-intensive certification that must actually pass before being claimed. Do **not** promote a conditional theorem just because its source graph compiled. Before broadening the compiler pin or using a historical 4.33/4.35 result under 4.36, independently recompile affected sources and issue a new certificate rather than overwriting prior evidence.

## Scholarly source-of-truth protocol

Use the [paper shelf](papers/README.md) and [canonical claim catalogue](research/catalogue/CLAIMS.json) before introducing a new named mathematical result. A paper entry is an editorial **pointer to the original theorem**; do not copy formal declarations or replace historical source files in order to improve navigation.

For a new scholarly claim, supply a unique stable ID; quantified primary source; explicit imported premises; local source and checker paths; separate validity, source completeness, external-review and originality fields; and concrete proof/priority stop rules. Register dependencies in the catalogue without promoting a conditional deduction merely because its supporting checker passed. A material counterexample or source correction must demote dependent claims and preserve the earlier version with its reason.

Run `python3 scripts/check_research_archive.py --self-test` in addition to source-specific mathematical checks. The new workflow tests **archive metadata and dependency integrity only**; it is not a proof assistant. Changes to the journal release status, licensing, or public frozen evidence require explicit owner review.

## Exact computational lemmas: independent differential gate

Where a formal proof imports a finite enumeration or computed certificate,
use [the staged verification protocol](research/nightfall/AGENT_VERIFICATION_PROTOCOL.md#exact-staged-differential-formalization-4ct-inspired-v1).
The recommended construction is: frozen primary-source version and formal
specification → staged lemma DAG → independent implementation from the
**specification** and inputs alone → canonical exact output comparison →
Lean checker soundness and finite-case coverage → source-theorem bridge →
independent mathematical review. Keep efficiency benchmarks separate from
correctness and do not collapse any of these gates.

Run `python3 scripts/check_formalization_differential.py --self-test`
(16 adversarial controls) before adopting a new computational family. For
a frozen family, also run
`python3 scripts/check_formalization_differential.py --manifest <manifest.json> --root .`
and independently run each manifest's recorded producer command. The audit
checks source and output bytes and exact canonical NDJSON agreement; it does
**not** execute producers, prove implementation independence, certify the
mathematical semantics of the checker, or establish exhaustive coverage.
The manifest's claim-boundary fields deliberately remain false. Never
infer a completed theorem merely from matching C++/Python/Rust/Lean outputs
or a Lean-verified implementation subroutine.

This requirement follows the staged A.1–A.6 checks and version-aware
independent implementations associated with
[Inoue et al., arXiv:2603.24880v3](https://arxiv.org/abs/2603.24880v3),
not an import of their source code. Reference checker and independently
written checker must have recorded, reviewable lineages; source-level
similarity needs separate human assessment.

## Choose the right contribution

| Contribution | What to provide |
| --- | --- |
| **Correction / counterexample** | Claim and source version, smallest decisive failure, assumptions, reproducible steps, affected downstream claims |
| **Exact finite construction** | Input object, arithmetic conventions, independently replayable checker, hashes, admissibility/precision limits |
| **Theorem manuscript** | Full statement with quantified hypotheses, proof dependencies, primary source attribution, open proof and priority questions |
| **Lean formalization** | Exact declaration, pinned Lean/Mathlib versions, compiler receipts, standard-axiom audit, proof statement and remaining assumptions |
| **Site or tooling improvement** | Narrow scope, behavior before/after, keyboard/mobile/accessibility effects, relevant static and browser results |
| **Public binary release** | Confirmed disclosure authorization, complete manifest and source custody, independent byte-level replay and exact scope |

New manuscripts belong in the research archive as **candidates** until their particular review gates are met. Do not promote a manuscript or numerical experiment into the site's internally approved finding catalogue through a copy, layout, or CI-only change. The currently designated set is five *bounded/finite findings* (three core, two additionally scoped), not an assertion of five globally original peer-reviewed theorems.

## Branch and pull-request workflow

1. Create a topic branch from the current `main`. Keep one coherent concern per PR and avoid editing another instance's active branch.
2. Link a source issue or primary research file where relevant. Prefer additive, reversible changes to frozen evidence, certificates, and research history; never silently overwrite an immutable witness.
3. Use [the pull-request template](.github/pull_request_template.md). State what changed, what did not change, tests actually run, source hashes, limitations, and outstanding review.
4. Run the narrowest deterministic check first, then the relevant website, checker, or proof-assistant workflow. The [website CI](.github/workflows/verify-site.yml) checks presentation and selected program invariants; it does **not** independently prove new mathematical theorems.
5. Inspect the final diff, reconcile newer `main`, and merge only when the relevant checks and source scope are sound. Verify the merged state and, for public pages, deployment independently.

A branch protection/ruleset must be enabled by a repository administrator to enforce PR-only changes and required checks. Documentation alone cannot enforce it; check **Settings → Rules → Rulesets** and the applicable status-check names.

### CI concurrency and formal proof integrity

- For Q2, **do not add another automatically triggered pinned-Lean workflow**. Use the [single source-only certificate pipeline](.github/workflows/nightfall-q2-consolidated-lean.yml) and its [ordered stage driver](scripts/nightfall_q2_certify.py). Historical `nightfall-q2-*-v436.yml` jobs are manual-only diagnostics, not independent required checks.
- Prefer one CI run per PR head, source-dependency caching, and `concurrency.cancel-in-progress: true` when later runs supersede earlier checks. Non-Q2 research workflows retain separate subject-specific evidence contracts.
- Run `python3 scripts/audit_ci_architecture.py --self-test` after changing workflow triggers, CI scripts, or the canonical Q2 proof graph. This architectural test does **not** compile Lean.
- Do not close or merge old Q2 PRs merely because a newer PR reproduces their title. Compare source blobs and preserve unique proofs, failure records, certificates, and analytic manuscripts in an explicit custody ledger.
- A current-head terminal `ActualSourceQ2Terminal.actual_source_q2_terminal` **strict named-declaration receipt** is required before calling the dimension-free Q2 theorem machine-certified. Green build steps or scoped historical lemmas are insufficient.

### Quick checks

From the repository root:

```bash
python3 scripts/test_repository_docs.py
python3 scripts/check_research_archive.py --self-test
python3 scripts/check_site.py
node scripts/test_proof_passport_batch.cjs
```

For browser behavior use [the pinned website CI workflow](.github/workflows/verify-site.yml); for mathematical claims use the explicit source-specific commands, not a generic green build. A Lean result is certified **only to the named statement and its declared premises**. Keep receipts, source versions and axiom dependencies together.

## Scientific review and claims

A complete mathematical review distinguishes the following independent questions:

- **Validity:** Are the assumptions satisfied, and does the proof or computation establish precisely what is claimed?
- **Reproducibility:** Can an independent process rebuild the result from frozen inputs, checker version, commands and hashes?
- **Originality:** Does a dated, source-to-source comparison show the result is absent from relevant earlier work under equivalent hypotheses?
- **Significance:** Is the gain material beyond tolerance, restricted subclasses, or earlier mechanisms?
- **Eligibility/publication:** Is distribution authorized, and does any competition or journal impose additional requirements?

For formal review formats see [the external-review protocol](research/nightfall/REVIEW_PROTOCOL.md), [verification protocol](research/nightfall/AGENT_VERIFICATION_PROTOCOL.md), [dated review priorities](research/nightfall/REVIEW_TRIAGE_20261029.md) and [release scope](research/nightfall/PUBLICATION_SCOPE.md). Source-specific primary records override broad editorial summaries.

Preserve negative controls, failed counterexample searches, withdrawn claims, and historical versions with reasons. Do not confuse *no counterexample found* with *theorem proved*. Do not claim an old red CI run is green; cite the actual successful rerun and commit.

## Attribution, licensing and responsible disclosure

Credit original mathematicians, human research directors, contributors, review authors, and substantial AI-generated work accurately. The project does not use AI persona names to imply independent human collaborators. A reviewer should specify whether their check is author-internal, independently implemented, formal-kernel, or external.

No repository-wide `LICENSE` has been supplied. GitHub visibility is not blanket permission to reuse source code, manuscripts, figures or third-party material. Check each artifact's rights and request permission where needed. [`CITATION.cff`](CITATION.cff) supports citation; it does not grant reuse rights.

Use the [issue templates](https://github.com/d3lefts/d3lefts/issues/new/choose) for mathematical challenges and source corrections. Do **not** put credentials, private datasets, or unpublished sensitive material in public Issues or PRs. For a security-sensitive problem, use a private reporting channel if the repository has one enabled, rather than posting an exploitable disclosure publicly.
