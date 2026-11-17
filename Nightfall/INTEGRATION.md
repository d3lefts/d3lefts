# Integrated Lean 4.36 Lake source-closure checkpoint

The purpose is to remove ambiguity between individually compiled claims and
one actual Lean dependency build. This mainline checkpoint provides a **single Lake package**
pinned to Lean 4.36.0-rc2 and Mathlib commit
`9d581dfff2e41de989072ea63abf3daf69311520`.

## What the default target actually imports

`lake build Nightfall` builds `Nightfall.Main`, which imports the original
source files (not duplicated snippets):

- `observability/ActualSourceQ2107Terminal.lean`: the original-source
  **finite** Q2 107 bound, with arbitrary finite heterogeneous laws.
- `universal/InfinitePiQ2Limit.lean`: the original-infinite-measure L²
  quadratic limit **conditional** on all finite-information bounds.
- `q2_shifted/Q2ShiftedConditionalTargets.lean`: conditional 107/99
  algebraic implications with explicit hypotheses.

The common `Nightfall.Core` contains finite product mass, expectation,
variance, heat-bath residual, resampling influence, and a prospective
degree-two residual definition. `Nightfall.Targets` records the candidate
finite statement as a `Prop`, not a claimed theorem. Legacy modules do not
yet import this Core; adapters are required before refactoring. The proposed
residual degree predicate is not yet proved equivalent to `ESDegreeLE`.

## Missing gates (not hidden hypotheses)

1. Prove an exact adapter from `Nightfall.Core` source-law definitions to
   the legacy definitions and the ANOVA degree predicate.
2. Bring the genuine original infinite-product finite-cell projection,
   boundedness/degree preservation and heat-bath influence contraction
   into the same checked import graph.
3. Compose the finite Q2 inequality with the original source's L² quadratic
   limit, with **no caller-supplied finite inequality hypothesis**.
4. Have a non-author audit the final problem statement against accepted
   standard definitions. An axiom audit does not certify semantics.
5. Extend the Lake library roots beyond this Q2 slice, replaying retired
   Lean 4.33/4.35 sources under the single pin without changing their
   historical receipts. Incompatible imports must be reported, not bypassed.

## Certification status

**Integrated compilation and independent Lean-kernel replay verified for the selected 103-source closure** by strict pinned CI run [44027853225](https://github.com/d3lefts/d3lefts/actions/runs/44027853225), exact source head `a5770989b9e6e3234c750f8c0d9228802cb088f7`, merged in PR #696 at `06a4eb403b7c7c5c9f62660848803e1d91ab0a70`. The four named terminal/conditional axiom audits reported only `propext`, `Classical.choice`, and `Quot.sound`. The generated closure is now checked in and CI enforces exact match against the original sources. Remaining infinite-product bridging and human statement review are expressly open.

**Scope remains conditional for infinite-product Q2.** The successful
`lake build Nightfall` and `lake check` establish a shared, source-closed
compilation and an independent kernel replay at the pinned toolchain.
They do not eliminate the finite-information premise of
`InfinitePiQ2Limit.source_q2_quadratic_limit`, discharge the heat-bath
intertwining/fiber-mean obligations, establish novelty, or constitute
independent mathematical review. `lake check --paranoid` remains an
optional, separately unverified multi-checker gate.

**Current compiler policy:** root `lean-toolchain`,
`docs/lean-compiler-lock.json`, the generated `lakefile.toml`, and
the shared Lean CI action all use Lean **4.36.0-rc2** and exact Mathlib
Git commit `9d581dfff2e41de989072ea63abf3daf69311520`.
See `docs/lean-compiler-settings.md` for local reproduction and
the historical-receipt boundary.

CI: `.github/workflows/nightfall-integrated-lake.yml`.

## Independent kernel replay extension (2026-11-17)

The integrated project now has a mandatory `lake check` step **after**
`lake build Nightfall` and its four named `#print axioms` audits. As
documented in Lean 4.35 release notes, `lake check` exports the complete
default build target and independently replays it through Lean's proof kernel,
rejecting nonstandard axioms. The workflow archives `lake-check.log` and
only writes a PASS marker after a successful command exit.

A manual workflow-dispatch input `paranoid: true` additionally requests
`lake check --paranoid`, running every bundled external checker. This is
intentionally opt-in because replaying the full Mathlib-backed closure
through multiple kernels has a substantial resource cost.

**Neither step certifies an infinite-product theorem that is absent from
the imported sources.** Kernel agreement validates that the checked terms
inhabit their Lean types; independent review of the exact mathematical
statement, source heat-bath intertwining, and removal of conditional
premises remain separate mandatory gates.

Upstream reference:
https://lean-lang.org/doc/reference/latest/releases/v4.35.0/
