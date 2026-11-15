# Retired manual-only Q2 Lean 4.36 diagnostics

**Archive date:** 2026-11-14 · **Custodian:** Devin J. Wright / NIGHTFALL.

These **14** GitHub Actions entrypoints were explicitly marked
`workflow_dispatch`-only and superseded operationally by the
[consolidated Q2 pinned source certification workflow](../../../../.github/workflows/nightfall-q2-consolidated-lean.yml).
They were moved out of `.github/workflows/` so routine GitHub Actions navigation
shows fewer obsolete options. **No Lean source, theorem, proof witness, PR, Actions
receipt, or historic commit was deleted.**

Every file under this directory has **the same Git blob SHA and byte content**
as its original `.github/workflows/<basename>`. Archive provenance and
reactivation tests are enforced by
[`scripts/check_retired_workflows.py`](../../../../scripts/check_retired_workflows.py),
which contains a source-SHA map and checks against silent reactivation.

**Scope of cleanup:** 14 active entrypoints retired; 67,025 bytes of historical
workflow YAML retained here. This is repository hygiene, *not* a mathematical
certificate, independent review, or assertion that every source file referenced
by an obsolete diagnostic remains supported by the current toolchain.

To repeat an individual historical check, retrieve the relevant frozen commit
or inspect this YAML and run it in an isolated archival branch. To restore a
diagnostic as active, submit a dedicated PR removing it from the retired manifest,
reviewing its dependency closure and runner budget, and replacing legacy workflow
action pins with current approved pins. Do not simply copy it back into
`.github/workflows/`.

**Current active verification:**
- [Q2 consolidated source Lean pipeline](../../../../.github/workflows/nightfall-q2-consolidated-lean.yml)
- [Q2 shifted scalar certificate](../../../../.github/workflows/nightfall-q2-shifted-scalar.yml)
- [Q2 source Jensen check](../../../../.github/workflows/nightfall-q2-shifted-source-jensen.yml)
- [Strict current named-certificate ledger](../../../../.github/workflows/nightfall-lean-certificate-registry.yml)

The source custody, supersession, and live research context are documented in
[NIGHTFALL November 14 reconciliation](../../../nightfall/assurance/RECONCILIATION_20261114.md).
