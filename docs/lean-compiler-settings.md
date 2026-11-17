# NIGHTFALL Lean 4.36 compiler and certification settings

**Active supported toolchain:** `leanprover/lean4:v4.36.0-rc2` (release candidate, **not** an assertion that the final 4.36.0 stable release has been tested).
**Exact Lean source commit:** `b35cb10cf2ced51a2fd1880cfdbf75c71ab7a35a`.
**Exact Mathlib Git commit:** `9d581dfff2e41de989072ea63abf3daf69311520` (tag `v4.36.0-rc2`).
**Allowed Lean foundational axioms:** `propext`, `Classical.choice`, `Quot.sound`.
**Authoritative machine-readable configuration:** [lean-compiler-lock.json](lean-compiler-lock.json).

This is the **active certification environment** across current-source NIGHTFALL and Commonwealth Lean verification. Historic Lean 4.33/4.35 reports and dated receipts remain pinned to the exact compiler that originally produced them. Changing a version string on an old receipt is prohibited; reproducing it at 4.36 requires a new named source-matched receipt.

## Current consolidated proof-checkpoint status

The original **103-source** Q2 source graph (#696, run 44027853225) remains a valid historical full `lake check` certificate. It has now been extended on `main` by the **107-source** source graph of #718 (merge `836af9435cf1ef33b779ce91eafe917ce5f99edc`). [Run 44120677824](https://github.com/d3lefts/d3lefts/actions/runs/44120677824) passed exact-version compiler/Mathlib setup, generated closure, `lake build Nightfall`, eight named axiom checks, and an independent `lake check`. There is **no** full arbitrary-index infinite-product Q2 terminal and no multi-kernel paranoid replay; the new 120-source all-(L^2) candidate in #743 requires a separate exact-head build/check.

F9's all-length actual GF(9) squared-oracle adaptive terminal (#690) was merged with its own source-matched strict named Lean 4.36 compiler receipt (run 44015925118). Its theorem source is outside this Q2 Lake build, so no F9 `lake check` is inferred. Commonwealth's finite abstract authority proof passports have a distinct exact-type Lean workflow and are not live-law or real-world enforcement certificates.

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


## Source-bound proof-object certification (2026-11-17)

The existing five Lean gates (package, build, inclusion, axioms, statement)
remain unchanged. Model-bound computational claims additionally require an
**original input → derived instance → proof object → exact checker → formal
soundness theorem** chain. The canonical extension is
[`proof-object-passport.json`](proof-object-passport.json), linked from
[`lean-proof-passport-overlay.json`](lean-proof-passport-overlay.json) and
[`active-proof-passport.json`](active-proof-passport.json).

**Mandatory for new model-bound certificates:**

1. Preserve an immutable, inspectable original problem model and its source
   version. Hash that original model, the exact derived instance and the proof
   object separately; a valid matrix-level witness does not show that the
   matrix faithfully encodes the original problem.
2. Replay the independently written exact checker against the *original model*.
   Require negative/mutation controls, not only a single positive example.
   A solver's own "unsatisfiable" or "optimal" return code is not a certificate.
3. Supply the actual Lean theorem source **and a separately stated exact-type
   contract**. Run `scripts/lean_bridge.py --strict --contract ... --decl ...`
   under `docs/lean-compiler-lock.json`; audit the named dependencies and
   immutable source digests. Run a common Lake build and independent
   `lake check` only when claiming those additional levels of replay.
4. Retain exact PR head, CI run, artifact, source/toolchain hashes, dependencies,
   intended claim and limitations. Changes to any model, encoding, witness,
   checker, theorem contract, dependency or authenticated authority version
   invalidate the corresponding reusable certificate until rechecked.
5. Separate **checker acceptance**, **scoped Lean soundness**, **end-to-end
   mathematical application**, **external independent review**, **source
   authority**, and **novelty**. No transition occurs automatically.

The first worked example is
[`papers/certifying-algorithms/`](../papers/certifying-algorithms/README.md):
a finite two-source weighted hitting-set budget is reduced to rational
inequalities and refuted using an exact Farkas multiplier. The independent
Python verifier reconstructs the matrix from the recorded unsafe-change
supports and budget; two Lean soundness lemmas were compiled with a separate
exact theorem-type contract under run
[#44171429696](https://github.com/d3lefts/d3lefts/actions/runs/44171429696).
This is **not** a Lean evaluation of the JSON witness, a certified
integer optimum for arbitrary recertification instances, a real-world
completeness guarantee, or an independent `lake check` replay.

```bash
node scripts/check_proof_object_passport.cjs
node scripts/check_lean_proof_passport_overlay.cjs
python3 -I papers/certifying-algorithms/check_farkas.py --self-test
python3 -I papers/certifying-algorithms/check_farkas.py \
  papers/certifying-algorithms/two_source_fence.json
```

These are offline integrity and exact-arithmetic checks. GitHub's
`nightfall-gsi-farkas-certificate-lean.yml` separately runs the pinned Lean
compiler. The shared `nightfall-lean-bridge-v2.yml` and
`nightfall-active-passports.yml` workflows now enforce this extra
proof-object policy without changing historical four-record Lean overlays or
promoting any existing Q2, F9, permission, or Commonwealth scientific claim.

**Methods credit:** Generalised Superintelligence's
[checker-first research](https://generalised.si/) motivated the process
change; Farkas' lemma and sound proof-carrying verification are classical.
No reported external discovery or benchmark speedup is imported as a
NIGHTFALL result.
