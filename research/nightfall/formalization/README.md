# NIGHTFALL Lean compiler bridge (v2)

This is an **interface to the official Lean 4 compiler and kernel**, not a new implementation of Lean or a proof synthesizer. It lets ChatGPT/Claude agent workspaces, local machines, Codespaces, and GitHub Actions use the **same checked-in toolchain and receipt format**. The repository currently pins `leanprover/lean4:v4.36.0-rc2` in `lean-toolchain`, with Mathlib commit `9d581dfff2e41de989072ea63abf3daf69311520`. The shared [setup action](../../../.github/actions/setup-nightfall-lean/action.yml) checks these exact versions; historical compiler receipts remain tied to their original pins.

## Unified root Lake package and source-preserving certification

Merged [PR #696](https://github.com/d3lefts/d3lefts/pull/696) established the historical selected 103-source Lake closure; [strict run 44027853225](https://github.com/d3lefts/d3lefts/actions/runs/44027853225) passed the then-current `lake build Nightfall`, scoped named axioms and `lake check`. That **historical** result must not be represented as verification of later imports.

The current mainline Q2/cubic/infinite-product root has 140 selected modules; draft integration [PR #859](https://github.com/d3lefts/d3lefts/pull/859), stacked on [AA product-space PR #858](https://github.com/d3lefts/d3lefts/pull/858), expands the deterministic closure to **203** exact-source modules. Added modules are 51 attributed upstream AA auxiliaries, seven product-space modules, the infinite-product AA terminal, three source-identical all-degree transfers from [PR #847](https://github.com/d3lefts/d3lefts/pull/847), and one existing original-label residual dependency. The shared `Nightfall/Main.lean` imports and audits actual theorem declarations from all four families, and `scripts/check_nightfall_lake_scope.py` enforces the 177-module upstream dependency inventory and rejects importing upstream cube-terminal shortcuts. This is a **draft integration**, not a claim that the 203-module pinned Lake build is already green.

The current mainline Q2 import includes an unconditional arbitrary-index *a.e.* terminal under its stated genuine triple-residual degree predicate, and the separate variance statement. Claiming a different canonical ANOVA degree notion is equivalent requires its own statement-level review. Likewise, the AA product-space theorem and the exact printed-cube specialization have separate strict receipts, but no certificate is transferred to this new combined build until its own `lake build Nightfall`, integrated named-axiom audit and `lake check` succeed. Off-tree author-side cubic/Q3, dependent-law DQ2, poly-d UE2 and open degree-semantics results are deliberately not promoted by inclusion or prose. Neither successful compilation nor a passing axiom audit establishes novelty or independent mathematical peer review.

The active compiler pin is now source-controlled via [`docs/lean-compiler-lock.json`](../../../docs/lean-compiler-lock.json); [`docs/lean-compiler-settings.md`](../../../docs/lean-compiler-settings.md) documents local setup, current CI, multi-kernel replay, and the immutable historical 4.33/4.35 receipts. `scripts/generate_nightfall_lake.py` obtains Mathlib from this lock, and the shared action verifies the installed compiler Git source commit.

```sh
python3 scripts/check_nightfall_compiler_lock.py --checkout .
python3 scripts/audit_active_lean_436.py
python3 scripts/generate_nightfall_lake.py --check
python3 scripts/check_nightfall_lake_scope.py
lake update
lake exe cache get
lake build Nightfall
lake check
```

## Local and agent sandbox use

Install the [official `elan` toolchain manager](https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Managing-Toolchains-with-Elan/), then in the repository run:

```sh
elan toolchain install "$(cat lean-toolchain)"
python3 scripts/lean_bridge.py research/nightfall/formalization/characteristic_three/Finite3.lean \
  --decl Nightfall.FiniteField.cubing_is_identity_mod_three \
  --decl Nightfall.FiniteField.cube_additive_mod_three \
  --strict --json-out lean-receipts/finite3.json
```

If the agent sandbox already exposes Lean, no special installation is needed. Use `--compiler /path/to/lean` for a custom executable; a `lakefile.lean`/`lakefile.toml` at the workspace root selects `lake env lean` automatically when Lake is on `PATH`. If the runtime cannot install/run Lean, the bridge returns **UNAVAILABLE** and saves a receipt; it never labels a synthetic or model-only proof as compiled.

## Shared GitHub Actions execution

Open [Lean bridge workflow](https://github.com/d3lefts/d3lefts/actions/workflows/lean-char3-sanity.yml) → **Run workflow** → optionally supply the relative path of another **committed** `.lean` source. GitHub Actions installs the pinned official toolchain, runs bridge unit tests, checks the two finite characteristic-three lemmas with a named-declaration axiom audit, checks the optional source, and uploads JSON receipts under the **nightfall-lean-receipts** artifact. The optional source receives a compilation receipt only; it is **not** promoted to an axiom-free proof without a declaration audit.

Command syntax:

```sh
python3 scripts/lean_bridge.py path/to/Claim.lean [--decl Namespace.theorem] ... \
  [--strict] [--json-out receipts/claim.json] [--timeout 120]
```

`--strict` requires at least one `--decl`. It exits nonzero if Lean fails, a source-policy token (`sorry`, `admit`, `axiom`, `constant`, `native_decide`, `unsafe`, `partial`) is found in executable text, or any audited declaration depends on an axiom outside its **explicit allowlist**. Q2 accepts only the standard foundations `Classical.choice`, `Quot.sound`, and `propext` (not `sorryAx`). The scanner ignores nested block comments, line comments and strings; it is a **screen**, not a formal semantic analysis of dependencies. A positive `#print axioms` check is reported by Lean; it does not prove source originality, use of intended premises, or correct mathematical statement selection.

Receipt fields include source SHA-256, pinned and actual toolchain, command, compiler status, diagnostics, outputs, scanned-policy findings, named-declaration axiom audit and checked scope. This is suitable for attaching to NIGHTFALL Proof Passports; imported-premise scope, independent review, novelty and competition status must remain separate. Do not include secrets or private sources in public CI runs.

## Verification status

- **Unit tests:** protocol logic and simulated compiler responses are runnable with Python alone; they do **not** establish Lean compilation.
- **Compiler check:** the workflow runs the real Lean toolchain; its logs and artifacts are the only CI-backed confirmation for that run.
- **Known limitation:** no Lean binary is guaranteed in ChatGPT's ephemeral sandbox, and this bridge does not install tools persistently across unrelated sessions. GitHub Actions provides the reusable remote executor.

## Unified certificate provenance and reconciliation

The [consolidated certificate index](CERTIFICATE_INDEX.md) provides one source-exact,
fail-closed command for the entire NIGHTFALL Lean registry, including historical
successful-run links and separate off-main custody. It does **not** replace
strict named-declaration Lean receipts or claim a same-pin universal proof.

## One-run Q2 verification (November 2026)

The canonical [Q2 workflow](../../../.github/workflows/nightfall-q2-consolidated-lean.yml) uses one pinned Lean/Mathlib setup, an import dependency graph and **one compilation per local source module per run**. Its [stage driver](../../../scripts/nightfall_q2_certify.py) checks original pair moments, owned interaction energy, source Jensen, fourth moment, singleton/pair variance, first-norm cap and finally the original-source Q2 declaration with separate strict axiom receipts. A failed intermediate stage leaves the full theorem **unverified**.

A current Q2 PR to `main` triggers that canonical pipeline. New commits cancel superseded builds on the same proof branch. The `nightfall-q2-*-v436.yml` workflows are intentionally `workflow_dispatch` **manual diagnostics**; they must not resume automatic push/PR triggering. The [CI governance check](../../../scripts/audit_ci_architecture.py) enforces this separation without requiring Lean.

For a source-complete Q2 PR checkout, inspect the dependency plan without installing Lean:

```sh
python3 scripts/nightfall_q2_certify.py --plan
python3 scripts/audit_ci_architecture.py --self-test
```

A green CI infrastructure check or historical subtheorem receipt does not certify the terminal Q2 variance inequality. Keep the terminal theorem's exact source commit, named declaration, actual compiler receipt, and independent review status separate. Older proof paths and non-Q2 workflows are retained for provenance.
