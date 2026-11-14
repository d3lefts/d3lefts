# NIGHTFALL Q2 — source-matched finite-product Lean certificate

**Validity state: strict kernel certificate, original-law Q2 finite scope.**
**Originality/significance state: unreviewed.**
**Publication: not authorized by this technical receipt.**

## Exact theorem
For a finite coordinate set `ι`, a nonempty common finite alphabet `α`, coordinate laws `p_i(a) ≥ 0` with `∑_a p_i(a)=1` (zero masses permitted), a function `f : (ι → α) → ℝ` with `ESDegreeLE p f 2`, and a pointwise bound `|f(x)| ≤ B`, `B ≥ 0`, the following is proved for **every** `M ≥ 0` such that `I_i(f) ≤ M` for all coordinates:

\[
\bigl(\operatorname{Var}_p f\bigr)^2\le
\underbrace{\bigl[16(1+\sqrt3)\bigr]^2}_{256(1+\sqrt3)^2}
B^2 M.
\]

The theorem's `sourceVariance` is the usual product-expectation squared deviation, and `sourceInfluence p f i` is the product-law variance in coordinate `i` (conditional-expectation squared deviation), **without** an extra factor of two. The proof states only the actual product law, degree, bound and influence cap; no external matching or moment oracle is supplied.

**Declaration:** `Nightfall.Observability.ActualSourceQ2Terminal.actual_source_q2_terminal`, source [`ActualSourceQ2Terminal.lean`](./formalization/observability/ActualSourceQ2Terminal.lean) (see the canonical GitHub path).

## Immutable compiler and evidence receipt

- Source commit: `d22962ba73b037a569196bc98d946dc192e4effa`, PR [#479](https://github.com/d3lefts/d3lefts/pull/479)
- Strict pinned run: [#43611982294](https://github.com/d3lefts/d3lefts/actions/runs/43611982294), **SUCCESS**, 2026-11-14 15:53 UTC
- All **eight** named-declaration stages: strict `PASS`, each `ACCEPT_STANDARD_AXIOMS ['Classical.choice','Quot.sound','propext']`; terminal declaration in stage 08
- Compiler: `leanprover/lean4:v4.36.0-rc2`, Mathlib commit `9d581dfff2e41de989072ea63abf3daf69311520`
- [Receipt ZIP](https://github.com/d3lefts/d3lefts/actions/runs/43611982294/artifacts/14121225201), SHA-256 `a37009051246139350614af2ec03ba27b0871c3f7eb96699b54c2028d7a423bd`
- [Machine-readable named-source certificate](../../../../docs/q2-source-lean-certificate-20261114.json) carries exact stage blob hashes, declaration names, provenance and explicit limits. The checker rebuilt dependency-order modules once and rejected non-allowlisted axioms.

## Scope distinctions and next audit

- Formal proof: **confirmed**, in the **exact finite common-alphabet setup**. Mathematical statement checked; no independent non-author proof review is claimed.
- Numerical exact checks: supplementary only, not needed to certify the Lean theorem.
- Arbitrary finite **heterogeneous alphabet types**, infinite/measurable product spaces, and downstream adaptive quantum/systems-engineering corollaries are **not** included in this receipt.
- Dated worldwide prior-art review, genuinely independent mathematical criticism and significance comparison remain **open**. Do not describe the result as original or competitive without those gates.
- Keep the 67-file Nov 12 historical source registry immutable. Updated and new Q2 files remain in the *pending historical registry* while this separate **current strict named-declaration** certificate records the new validity status; do not interpret pending *historical* custody as denying the current scoped receipt.

## Checkpoint to reproduce

Run the [consolidated workflow](https://github.com/d3lefts/d3lefts/actions/workflows/nightfall-q2-consolidated-lean.yml) against the exact source commit `d22962ba73b037a569196bc98d946dc192e4effa`, with the pinned dependencies above. Compare source blobs in the machine-readable certificate before interpreting any later receipt. Superseding commits require separate certification if those blobs change.
