# NIGHTFALL Q2 — source-matched finite-product Lean certificate

## Strongest current Q2 finite-product certificate — 14 November, post-merge

**STRICT LEAN 4.36.0-rc2, original-source unconditional terminal:** merged [PR #498](https://github.com/d3lefts/d3lefts/pull/498), strict [run 43633180605](https://github.com/d3lefts/d3lefts/actions/runs/43633180605), artifact 14129276102, SHA-256 `aa709276c44891c2ba3d51de85dc4ec092d5b7aa01d8dcc79935a9cd6e403094`.

The finite **common-alphabet** degree-two original-source bound is now
`Var_p(f)^2 ≤ [257/20+(9/4)√2+5√3+√6]^2 B^2 max_i sourceInfluence(p,f,i)`,
coefficient ≈**736.673197758287**. Strictly verified named terminal:
`Nightfall.Observability.ActualSourceQ2EnergyDualUnconditional.actual_source_q2_energy_dual_unconditional`. The joint original singleton plus greedily owned pair energy cap is **source-derived**, not assumed by the caller. Only standard foundational axioms are reported.

The 1064.958 (#494), 1228.356 and 1910.81 proof checkpoints remain valid weaker/historical results. Source scopes, heterogeneous alphabet types, infinite products, human referee and novelty remain separate open gates. The currently unproved 625/620 candidates are NOT certified.

---
**Validity state: strict kernel certificate, original-law Q2 finite scope.**
**Originality/significance state: unreviewed.**
**Publication: not authorized by this technical receipt.**

## Latest stronger finite-Q2 certificate — 14 November 2026

**STATUS: STRICT LEAN 4.36.0-rc2 KERNEL-CERTIFIED, finite common-alphabet original-source Q2; no novelty/human referee claim.**
The initial 8-stage proof described below remains an immutable, valid **weaker**
baseline. It has been superseded quantitatively by merged
[PR #494](https://github.com/d3lefts/d3lefts/pull/494),
`Nightfall.Observability.ActualSourceQ2CoupledUnconditional.actual_source_q2_coupled_unconditional`,
whose same-pin strict compiler run [43627249467](https://github.com/d3lefts/d3lefts/actions/runs/43627249467)
passed a fully unconditional terminal declaration with only
`Classical.choice`, `Quot.sound` and `propext`.
Its current-head receipt artifact [14126078653](https://github.com/d3lefts/d3lefts/actions/runs/43627249467/artifacts/14126078653)
has SHA-256 `f6b1d8d3092ee6acc5b5d6a01b851d048853910933d0e622d3609a8497dd1259`.

For every actual-coordinate cap `M≥0` as in the original theorem, the new
coefficient is
`C₂=407+138√2+188√3+56√6≈1064.958449026294`:

\[
(\operatorname{Var}_p f)^2 \le C_2 B^2 M.
\]

No separate matching, additive source-budget, fourth-moment or energy
hypothesis is supplied to its terminal declaration. The common-alphabet and
finite-coordinate premises are unchanged. The old 1228.356 manuscript and
1910.81 terminal are **historical valid/weaker** checkpoints, not the latest
certified constant.

**New separate source-law certificates:** merged [SCIF #496](https://github.com/d3lefts/d3lefts/pull/496),
strict run [43630623548](https://github.com/d3lefts/d3lefts/actions/runs/43630623548)
with artifact [14128206335](https://github.com/d3lefts/d3lefts/actions/runs/43630623548/artifacts/14128206335),
certifies finite-table recentering, source-canonical graph invariance after
pointwise degree preservation, exact local singleton/pair energy algebra,
zero-reassignment amplitude cover with `1+min(2TV,1)`, and two-endpoint
amplitude inflation at most `4`. Those declarations have not yet been
composed into one full-source `sourceInfluence` update and owner package.

All new source SHA-1 and named-declaration receipts are recorded in
[14 November current-proof index](../../docs/current-lean-proof-receipts-20261114.json).
The frozen historical 67-source provenance and the immutable original 8-stage
receipt remain unchanged.

---

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
- [Machine-readable named-source certificate](../../docs/q2-source-lean-certificate-20261114.json) carries exact stage blob hashes, declaration names, provenance and explicit limits. The checker rebuilt dependency-order modules once and rejected non-allowlisted axioms.

## Scope distinctions and next audit

- Formal proof: **confirmed**, in the **exact finite common-alphabet setup**. Mathematical statement checked; no independent non-author proof review is claimed.
- Numerical exact checks: supplementary only, not needed to certify the Lean theorem.
- Arbitrary finite **heterogeneous alphabet types**, infinite/measurable product spaces, and downstream adaptive quantum/systems-engineering corollaries are **not** included in this receipt.
- Dated worldwide prior-art review, genuinely independent mathematical criticism and significance comparison remain **open**. Do not describe the result as original or competitive without those gates.
- Keep the 67-file Nov 12 historical source registry immutable. Updated and new Q2 files remain in the *pending historical registry* while this separate **current strict named-declaration** certificate records the new validity status; do not interpret pending *historical* custody as denying the current scoped receipt.

## Checkpoint to reproduce

Run the [consolidated workflow](https://github.com/d3lefts/d3lefts/actions/workflows/nightfall-q2-consolidated-lean.yml) against the exact source commit `d22962ba73b037a569196bc98d946dc192e4effa`, with the pinned dependencies above. Compare source blobs in the machine-readable certificate before interpreting any later receipt. Superseding commits require separate certification if those blobs change.
