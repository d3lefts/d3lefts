# Lean community five-gate Proof Passport overlay

**Status:** active machine-checked evidence overlay, with main-merged 4.36 source certificates; not a new mathematical theorem.
**Registry:** [docs/lean-proof-passport-overlay.json](../../../docs/lean-proof-passport-overlay.json)
**Canonical scientific passports:** [docs/active-proof-passport.json](../../../docs/active-proof-passport.json)
**External verification standard:** https://leanprover-community.github.io/did_you_prove_it.html

## Verified 17 November Q2 / F9 integration checkpoint

The **107-source selected original Q2 Lake closure** passed `lake build Nightfall`, eight named standard-axiom audits and the independent `lake check` on exact PR #718 head `8e63401fcb1c40a37b9416e5413e7e96fc988307` in [run 44120677824](https://github.com/d3lefts/d3lefts/actions/runs/44120677824); merge commit `836af9435cf1ef33b779ce91eafe917ce5f99edc`. This **extends** the earlier #696 103-source receipt without modifying it. The integrated 107-source theorem graph includes actual original-product conditional-expectation and Hilbert tensor bridges, but its (L^2) limit remains conditional and there is **no unconditional infinite-product Q2 terminal**. The 120-source all-(L^2) expansion is independent, still awaiting exact same-head CI (#743). No `lake check --paranoid` receipt is asserted.

The **all-length actual legal squared-oracle GF(9) F9 adaptive theorem is already merged to main** (#690, merge `ba5e57cf36e21df8589df82308f9a8be0ecd23d0`, strict original-source named Lean run 44015925118). Its four-source F9-specific status remains a different source graph, **not** part of the 107-source Q2 Lake graph and **not** the arbitrary infinite-field theorem. The Commonwealth abstract proof-passport source/contract remains conditional and distinct from deployed authority.

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
| `q2-infinite-integration` | **Merged PR #696**, 103-source Lean 4.36 selected Lake dependency build, four named foundational-axiom audits, and actual `lake check` kernel replay **PASS** (run #44027853225) | The imported infinite L² limit remains conditional; no unconditional infinite terminal, field-statement review, or paranoid multi-kernel pass |
| `f9-adaptive-pr-head` | **Merged PR #690**: source-closed all-length GF(9) adaptive transcript declaration with pinned named Lean receipt | On main, but outside the selected 103-source Q2 Lake closure; not the generic infinite-field terminal and no independent statement review |
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

These checks run in the existing `.github/workflows/nightfall-active-passports.yml`. Keep them distinct from the actual `lake build`, pinned named `lean_bridge.py`, exact theorem-contract and standard-axiom CI receipts. Merged PR #696's Lake build and official kernel replay have a separate, source-scoped CI receipt. Their proof content is conditional for infinite-product Q2.

### Negative tests

The checker deliberately rejects:
- Replacing the merged finite Q2 source identity with an unverified blob.
- Marking an open infinite-product terminal as fully certified.
- Falsely claiming a `lake check --paranoid` result without a receipt.
- Relabeling the imported conditional infinite-product theorem as a nonexistent unconditional terminal.

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

Merged PR #696 added an actual `lake check` after `lake build Nightfall`.
Both PASS at exact source head `a5770989b9e6e3234c750f8c0d9228802cb088f7`
in GitHub Actions run `44027853225`; merge commit
`06a4eb403b7c7c5c9f62660848803e1d91ab0a70`. This certifies only
the selected 103-source import graph. `lake check --paranoid` is
optional and has **no passing recorded result**. No kernel result closes
an absent mathematical premise or substitutes for expert statement audit.
See `docs/lean-compiler-settings.md` for current root tools and historical versions.

Official reference:
https://lean-lang.org/doc/reference/latest/releases/v4.35.0/
