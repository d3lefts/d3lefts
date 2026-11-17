# Integrated Lake migration checkpoint (draft)

The purpose is to remove ambiguity between individually compiled claims and
one actual Lean dependency build. This draft introduces a **single Lake package**
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

**Integrated compilation verified for the selected 103-source closure** by strict pinned CI run 44023827988 (branch commit 90853957ec9b743f29bcb84566e9f2ff1d0859d4). The four named terminal/conditional axiom audits reported only `propext`, `Classical.choice`, and `Quot.sound`. The generated closure is now checked in and CI enforces exact match against the original sources. Remaining infinite-product bridging and human statement review are expressly open.

**Scope is not unconditional infinite-product Q2.** The local environment that prepared this
scaffold has no Lean executable. A passing build would prove only that
these named modules and their transitive dependencies compiled together
at one pin, and that the listed theorem axiom sets were acceptable.
It would not prove the infinite-product Q2 target, originality, or external
peer review. Do not merge this draft until the build is green and its
dependency and statement scope has been inspected.

CI: `.github/workflows/nightfall-integrated-lake.yml`.
