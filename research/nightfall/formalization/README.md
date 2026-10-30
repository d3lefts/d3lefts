# NIGHTFALL Lean compiler bridge (v1)

This is an **interface to the official Lean 4 compiler and kernel**, not a new implementation of Lean or a proof synthesizer. It lets ChatGPT/Claude agent workspaces, local machines, Codespaces, and GitHub Actions use the **same checked-in toolchain and receipt format**. The repository pins `leanprover/lean4:v4.35.0` in `lean-toolchain`; the GitHub Action provisions that version with `elan`.

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

`--strict` requires at least one `--decl`. It exits nonzero if Lean fails, a source-policy token (`sorry`, `admit`, `axiom`, `constant`, `native_decide`, `unsafe`, `partial`) is seen in executable text, or Lean does not explicitly report that every audited declaration depends on zero axioms. The scanner ignores nested block comments, line comments and strings; it is a **screen**, not a formal semantic analysis of dependencies. A positive `#print axioms` check is reported by Lean; it does not prove source originality, use of intended premises, or correct mathematical statement selection.

Receipt fields include source SHA-256, pinned and actual toolchain, command, compiler status, diagnostics, outputs, scanned-policy findings, named-declaration axiom audit and checked scope. This is suitable for attaching to NIGHTFALL Proof Passports; imported-premise scope, independent review, novelty and competition status must remain separate. Do not include secrets or private sources in public CI runs.

## Verification status

- **Unit tests:** protocol logic and simulated compiler responses are runnable with Python alone; they do **not** establish Lean compilation.
- **Compiler check:** the workflow runs the real Lean toolchain; its logs and artifacts are the only CI-backed confirmation for that run.
- **Known limitation:** no Lean binary is guaranteed in ChatGPT's ephemeral sandbox, and this bridge does not install tools persistently across unrelated sessions. GitHub Actions provides the reusable remote executor.
