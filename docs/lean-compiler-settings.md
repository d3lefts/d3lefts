# NIGHTFALL Lean 4.36 compiler and certification settings

**Active supported toolchain:** `leanprover/lean4:v4.36.0-rc2` (release candidate, **not** an assertion that the final 4.36.0 stable release has been tested).
**Exact Lean source commit:** `b35cb10cf2ced51a2fd1880cfdbf75c71ab7a35a`.
**Exact Mathlib Git commit:** `9d581dfff2e41de989072ea63abf3daf69311520` (tag `v4.36.0-rc2`).
**Allowed Lean foundational axioms:** `propext`, `Classical.choice`, `Quot.sound`.
**Authoritative machine-readable configuration:** [lean-compiler-lock.json](lean-compiler-lock.json).

This is the **active certification environment** across current-source NIGHTFALL and Commonwealth Lean verification. Historic Lean 4.33/4.35 reports and dated receipts remain pinned to the exact compiler that originally produced them. Changing a version string on an old receipt is prohibited; reproducing it at 4.36 requires a new named source-matched receipt.

## One exact compiler environment

The following consume the same root lock (rather than copying a version from documentation):

- [Root `lean-toolchain`](../lean-toolchain) selects Lean 4.36.0-rc2 via elan.
- [Shared GitHub Actions installer](../.github/actions/setup-nightfall-lean/action.yml) derives Lean version, Lean source revision, Mathlib tag and Mathlib Git revision from the lock, then checks the actual installed compiler and Mathlib Git checkout before caching.
- [Lake manifest generator](../scripts/generate_nightfall_lake.py) reads the Mathlib revision from the lock. [`lakefile.toml`](../lakefile.toml) is the checked-in generated exact dependency-closure manifest; change its contents only via the generator after modifying actual source imports.
- [Compiler-lock validator](../scripts/check_nightfall_compiler_lock.py) checks root, Lake, active receipt index, Proof Passport overlay, and Commonwealth theorem-contract pin agreement; its `--installed-mathlib` and `--lean-version-file` switches additionally validate a real CI installation.
- [Active workflow inventory](../scripts/audit_active_lean_436.py) rejects conflicting compiler versions in the maintained certification entry points and reports historical workflow references without altering them.

## Reproducible local invocation

Install [elan](https://lean-lang.org/install/) and a local Python 3.11+ / Git environment. At repository root:

```sh
elan toolchain install "$(cat lean-toolchain)"
python3 scripts/check_nightfall_compiler_lock.py --checkout .
python3 scripts/generate_nightfall_lake.py --check
lake update
python3 scripts/check_nightfall_compiler_lock.py --checkout .
lake exe cache get
lake build Nightfall
lake check
```

The `lake update` step must not silently update Mathlib beyond the exact Git commit in the lock; the second audit rejects a mismatched `lakefile.toml`, and the integrated CI also checks the actual `.lake/packages/mathlib` Git HEAD. For exact installation verification, point the validator at that Mathlib directory and provide a file containing the installed `lean --version` output.

For the more expensive multi-kernel check:

```sh
lake check --paranoid
```

This optional check needs the bundled independent checkers, more RAM/time, and a pinned executable environment; no passing `--paranoid` receipt is asserted in the current proof passport.

## Certification levels and claim scope

| Gate | Concrete checker | What it establishes |
|---|---|---|
| Reproducible environment | Compiler lock + installed-binary Git identity | Toolchain and Mathlib source identity for this build |
| Original-source integrity | Git blob and SHA-256 receipt validators | Named source bytes match the recorded checkpoint |
| Named proof / imported dependencies | `scripts/lean_bridge.py --strict --decl …`; generated Lake package | Lean compiles the named source and imports with its explicit hypotheses |
| Lean axioms | `#print axioms` and receipt checker | No unexpected nonstandard axioms in specifically audited names |
| Independent kernel replay | `lake check` | Official kernel rechecks proofs for Lake default targets at the pin |
| Multi-checker replay | `lake check --paranoid` | Bundled independent checkers agree, **only if separately run and passed** |
| Mathematical interpretation | Independent statement-and-hypotheses review | Actual theorem type matches the claimed research problem |
| Novelty, applicability, authority | Prior-art, systems, and authenticated-source audits | Independent of kernel proof checking |

**PR #696 is merged** (merge `06a4eb403b7c7c5c9f62660848803e1d91ab0a70`). Exact source head `a5770989b9e6e3234c750f8c0d9228802cb088f7`, [GitHub Actions run #44027853225](https://github.com/d3lefts/d3lefts/actions/runs/44027853225), verified `lake build Nightfall`, named axiom audits, and `lake check` for the **103-source selected Q2 closure** under Lean 4.36.0-rc2. This is **not all Lean modules** and **not the unconditional infinite-product Q2 theorem**: its L² limit remains conditional, and exact original-source heat-bath/fiber-mean/degree/influence bridges remain outstanding.

The canonical live [Proof Passport overlay](lean-proof-passport-overlay.json) records the merge without turning this conditional source theorem into an unconditional result. The merged F9 source is a separate pinned named Lean theorem receipt, not a member of the 103-source Lake build.

## Upgrades and older certificates

1. Make a dedicated compatibility branch from current main; never rewrite the immutable historical source receipts or evidence.
2. Change only the root compiler lock and `lean-toolchain` together. Regenerate Lake configuration using the lock; do not hand-insert an unreviewed Mathlib revision.
3. Require compiler-install identity, exact-source audit, named theorem type and axiom reports, complete selected dependency build, `lake check`, and suitable parity tests before changing the active configuration.
4. Use a new receipt tied to precise Git blob, source commit, compiler/Mathlib pins and workflow run. A prior version's CI green status does not carry automatically to the new version.
5. For mathematical statement-equivalence, domain changes, or real-world admission effects, require independent review or an additional external authority certificate; neither a version bump nor a kernel replay confers them.

## References

- [Lean 4.36.0-rc2 release notes](https://lean-lang.org/doc/reference/latest/releases/v4.36.0/)
- [Lake check and paranoid checking](https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Lake/)
- [Lean-community proof verification checklist](https://leanprover-community.github.io/did_you_prove_it.html)
- [NIGHTFALL integrated source dependency record](../Nightfall/INTEGRATION.md)
