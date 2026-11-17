# Lean community five-gate Proof Passport overlay

**Status:** proposed cross-program verification overlay; not a new mathematical certificate.
**Registry:** [docs/lean-proof-passport-overlay.json](../../../docs/lean-proof-passport-overlay.json)
**Canonical scientific passports:** [docs/active-proof-passport.json](../../../docs/active-proof-passport.json)
**External verification standard:** https://leanprover-community.github.io/did_you_prove_it.html

## Mechanism

A Proof Passport is a record of *exact statement -> assumptions -> source -> pinned compiler and dependency tree -> kernel receipt -> source change and human semantic review -> permitted scope of reuse*. A compiled Lean file is not independently a scientific result, and a proof of a finite model is not authorization to take a real-world action.

The official Lean-community standard requires all five checks:

1. A reproducible Lean/Lake **project** and pinned dependencies.
2. The project **builds** successfully.
3. The named claimed theorem actually appears in the compiled **dependency closure**.
4. Its `#print axioms` report is confined to `propext`, `Classical.choice` and `Quot.sound`.
5. The theorem's **actual type** faithfully formalizes the external claim; this requires independent expert statement review when not already maintained in Mathlib.

The overlay records *receipt references* without converting them into live same-commit recompilation. `receipt_referenced` and `pr_head_receipt_referenced` are custody statuses; the Node checker does **not** run Lean, contact GitHub Actions, certify a proof, perform peer review or authenticate public law. It checks exact Git-blob SHA-1, named declaration existence and consistency with the existing scientific/frontier/receipt ledgers and Commonwealth theorem contract. SHA-1 is Git object identity, not a security-grade signature; CI receipt authentication remains a separate responsibility.

## Current records and admissibility

| Evidence record | Present scope | Review and promotion boundary |
|---|---|---|
| `q2-finite-current` | Original-source finite Q2 at the exact C105.416 coefficient, merged source blob and named strict kernel receipt | Independent mathematical statement review open; NOT arbitrary infinite product |
| `q2-infinite-integration` | PR #696: 103-source pinned Lake **selected import** build | No unconditional infinite terminal; original-source conditional-expectation/intertwining, bounded fiber mean, degree transfer and exact statement bridge open |
| `f9-adaptive-pr-head` | PR #690: strict named all-length F9 transcript certificate at its original checked head | PR-only, not a generic infinite-field theorem and no promotion to main |
| `commonwealth-abstract-authority` | PR #613 finite/abstract possible-world Lean model, exact theorem contract | Not proof of legal truth, authenticated evidence, complete physical mediation, or live authority |

### Proof dependency graph

```text
Q2 original finite source theorem [C105.416; historical pinned receipt]
       |
       +--> original infinitePi label law (#691) [scoped]
       +--> Hilbert adjoint/influence lemma (#694) [scoped; conditional]
       +--> bounded fiber-mean and heat-bath intertwining [open]
       +--> source L2 quadratic limit [conditional]
       |
       +--> unconditional infinite-product terminal [OPEN]
             |
             +--> independent statement-equivalence audit [OPEN]

Commonwealth model theorem + exact theorem contract
       +--> source/version authentication [NOT CERTIFIED]
       +--> protected private-evidence binding [NOT CERTIFIED]
       +--> verified effect-time mediation [NOT CERTIFIED]
       +--> institutional authority/review [NOT AUTHORIZED]
```

## Change-stable recertification

Treat each tuple
`(claim, assumptions, theorem declaration, source Git blob, Lean pin, Mathlib pin, imported dependency closure, evidence authority version)`
as a distinct certificate identity. If any component changes, its old certificate is *not automatically valid* for the new source or authority. For a changed Lean file: recompute the blob and rerun named, common-pin compilation; for a changed dependency: rebuild the affected closure; for a changed mathematical statement: request independent semantic review; for a changed evidence authority version: recertify source freshness and real enforcement separately.

The overlay currently enforces the source-hash and categorical promotion guards. The dependency/version recertification rule is a required **future enforcement gate**, not an implemented cryptographic version fence.

## Local and CI checks

```sh
node scripts/check_lean_proof_passport_overlay.cjs
node scripts/test_active_proof_passport.cjs
```

These checks run in the existing `.github/workflows/nightfall-active-passports.yml`. Keep them distinct from the actual `lake build`, pinned named `lean_bridge.py`, exact theorem-contract and standard-axiom CI receipts. The PR #696 integrated Lake build is a separate proof-engineering gate and remains source-specific.

### Negative tests

The checker deliberately rejects:
- Replacing the merged finite Q2 source identity with an unverified blob.
- Marking an open infinite-product terminal as fully certified.
- Treating an unmerged PR-head proof source as a verified main-source declaration.

## Review and stop rule

Before promotion, obtain a single-pinned source-closed compiler receipt; verify the named theorem type and no additional hypotheses; require independent field-statement matching, and separately evaluate novelty/prior art if making a priority claim. A source-only/metadata checker is never allowed to promote a claim on its own. Public claim IDs and the frozen historical 11-passport archive remain unchanged.

## Reproducible compiler upgrade policy

The authoritative environment is now `docs/lean-compiler-lock.json`.
The shared `.github/actions/setup-nightfall-lean/action.yml` rejects
compiler/tag/Mathlib/source-commit disagreement before cached artifacts
can support a new named theorem receipt. The lock guard cross-checks:

- root `lean-toolchain`, active strict receipt index, exact Commonwealth
  theorem contract and five-gate scientific passport;
- root `lakefile.toml`, if present, against the same Mathlib Git revision;
- actual `lean --version` Git commit and installed Mathlib `git rev-parse HEAD`
  during the shared setup action.

`python3 scripts/check_nightfall_compiler_lock.py` checks local source
consistency; the additional `--installed-mathlib` and
`--lean-version-file` options check the actual CI compiler installation.
The independent, no-Lean test suite
`python3 -m unittest discover -s tests -p 'test_nightfall_compiler_lock.py'`
contains tampering tests. The dedicated
`.github/workflows/nightfall-compiler-lock.yml` is a fast metadata gate,
not a proof checker.

**No compiler upgrade performed:** Lean 4.36.0-rc2 and Mathlib commit
`9d581dfff2e41de989072ea63abf3daf69311520` remain fixed.
Future upgrades must take an isolated branch and re-run all affected
source-level proof dependencies. An inherited old receipt is not a
certificate for a new toolchain.

## New independent-kernel certification gate

The currently separate PR #696 integrated Lake closure adds the actual
`lake check` command after `lake build Nightfall`; an optional
`lake check --paranoid` invokes the bundled independent kernel
implementations. Until the **same head** of that PR passes, the overlay
records this gate as scheduled rather than complete. A passing check
never closes absent mathematical premises or the expert statement audit.

Official reference:
https://lean-lang.org/doc/reference/latest/releases/v4.35.0/
