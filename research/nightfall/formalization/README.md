# NIGHTFALL Lean compiler bridge (v2)

This is an **interface to the official Lean 4 compiler and kernel**, not a new implementation of Lean or a proof synthesizer. It lets ChatGPT/Claude agent workspaces, local machines, Codespaces, and GitHub Actions use the **same checked-in toolchain and receipt format**. The repository currently pins `leanprover/lean4:v4.36.0-rc2` in `lean-toolchain`, with Mathlib commit `9d581dfff2e41de989072ea63abf3daf69311520`. The shared [setup action](../../../.github/actions/setup-nightfall-lean/action.yml) checks these exact versions; historical compiler receipts remain tied to their original pins.

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
