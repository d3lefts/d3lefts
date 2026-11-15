# NIGHTFALL Proof Passport — Source-Certified Frontier, 15 November 2026

**Version:** 16 checkpoint. **Owner/research direction:** Devin J. Wright. **Nature:** evidence ledger and reproducibility handoff, not peer review or a new independent Lean kernel run. **Current canonical active registry:** `docs/active-proof-passport.json` v15, 15 active claims; the older v14 archive remains historical.

## Objective and exact strongest certified statement

Let (I) be a finite coordinate set and (A) one nonempty finite common alphabet. Let (p_i) be heterogeneous normalized nonnegative independent marginal laws on (A), including zero-mass atoms. If real (f:A^I\to\mathbb R) has pointwise Efron–Stein degree at most two and (|f(x)|\le B) for **every** configuration, with (B\ge0), then

[
\operatorname{Var}_p(f)^2 \le K B^2 \max_i I_i^p(f),\qquad
K=[2\sqrt3(1+\sqrt2)+48/25]^2\approx105.741756923658.
]

(I_i^p(f)) is the original-law resampling/conditional-variance influence. **Canonical singleton components are unrestricted.**

**Certificate and checker:** `Nightfall.Observability.ActualSourceQ2105Terminal.actual_source_q2_105_unconditional` in `research/nightfall/formalization/observability/ActualSourceQ2105Terminal.lean`, **exact Git blob SHA-1** `ed945639f7cbe26ba8fdb50d691127c01cdf863f`. Original strict pinned Lean 4.36.0-rc2 named-axiom/source gate: [run 43671321904](https://github.com/d3lefts/d3lefts/actions/runs/43671321904), source head `ae8ebec96d6c3ce4a25fb42bc7ae6ba170ca9103`, PR [#564](https://github.com/d3lefts/d3lefts/pull/564). Post-reconciliation exact-source replay [run 43678232064](https://github.com/d3lefts/d3lefts/actions/runs/43678232064) passed for the unchanged theorem blob. Standard Lean axioms only, no `sorryAx`, as recorded by original named audit. The theorem is merged to `main`.

The proof mechanism is original-source Hoeffding decomposition, exact canonical pair ownership, integrated Bernoulli-switch section budget (2(1+\sqrt2)B), source-derived owned-neighbor Hilbert increments, and rational (eta=6/25) shifted norm interpolation. All needed inputs follow from the same original (p,f); no extra caller-supplied section/owner/moment bound.

## Scoped additional certificates

| Claim | Source | Lean evidence | Exact status |
| --- | --- | --- | --- |
| Earlier unrestricted (K\approx107.393449899771) | `ActualSourceQ2107Terminal.lean`, blob `a1e81b41d6c14c7da3c7f8d1ecc376027a70059f` | [run 43666215780](https://github.com/d3lefts/d3lefts/actions/runs/43666215780), PR #558 | **Proved**, superseded by C105 |
| Earlier unrestricted (K\approx364.5526832774) | `ActualSourceQ2364Terminal.lean`, blob `5263d9da1ec2f12fbc8986c3698859faedb390a3` | [run 43644790107](https://github.com/d3lefts/d3lefts/actions/runs/43644790107), PR #525 | **Proved**, historical |
| Pure-sector (K\approx95.063) | `ActualSourcePureQ2Sharp.lean` | [run 43664979586](https://github.com/d3lefts/d3lefts/actions/runs/43664979586), PR #553 | **Proved only if all singleton components vanish** |
| Six-cover conditional (K\approx96.100399066982) | `ActualSourceQ296SixCover.lean`, blob `8de1ad77a9f218d0df3673d8574ddd6592556865` | [run 43676624010](https://github.com/d3lefts/d3lefts/actions/runs/43676624010), PR #570 | **Proved implication only**; additional (∑_i c_i\le6B) source-compatible graph-cover hypothesis unproved universally |
| One-increment Hilbert variance | `ShiftedOneIncrementL1L2.lean` | [run 43676488130](https://github.com/d3lefts/d3lefts/actions/runs/43676488130), PR #571 | **One increment only**; cannot infer arbitrary length |
| Finite five-cover obstruction | `ExactFiveCoverObstruction.lean` | [run 43677348342](https://github.com/d3lefts/d3lefts/actions/runs/43677348342), PR #573 | **Exact finite/abstract certificate**; source canonical-pair linkage remains a separate proof |

All source blobs should be checked by the current dated receipt JSON, not copied blindly from a proposed branch. In particular, do **not** add an unnamed or failed CI run as a kernel certificate. All cited run numbers refer to historical successful exact-head workflows.

## Sub-100 gap

**Unrestricted (K=96.5735201305) is NOT PROVED.** The exact sufficient Hilbert comparison remains open for independent centered bounded Hilbert (Y_j) and shift (h):
[
\mathbb E\|h+\sum_jY_j\|^2
\le 2(\mathbb E\|h+\sum_jY_j\|)^2
+c\mathbb E\|h+\sum_jY_j\|.
]
The conditional scalar sum-of-squares implication alone is not a source-level unrestricted theorem. A second route would prove a **universal** source-owned cost bound (∑_i c_i\le 6B); current certification proves only its conditional consequence. Both open conditions are independent proof obligations.

## Related non-kernel results, not silently promoted

- [PR #569](https://github.com/d3lefts/d3lefts/pull/569): 746,493 exact finite product Hilbert stress tests; no universal inference.
- [PR #572](https://github.com/d3lefts/d3lefts/pull/572): orthogonal-increment self-bounding analytic argument; no Lean all-length certificate.
- [PR #574](https://github.com/d3lefts/d3lefts/pull/574): all-length symmetric-law first-chaos analytic proof and exact tests; no Lean asymmetric theorem.
- [PR #577](https://github.com/d3lefts/d3lefts/pull/577): 23,400 exact centered asymmetric-law finite tests; no proof beyond their enumerated finite scope.
- [PR #576](https://github.com/d3lefts/d3lefts/pull/576): finite mission-conditioned optimal recertification, grouped setup min-cut subclass and Bayesian risk analysis with exact audit; **not Lean-certified** and not real deployed-system safety.
- SCIF source-change formalization and finite semantic-fencing assurance remain individually scoped. No infinite-product all-(L^2) theorem, no deployed-agent complete mediation, and no independent worldwide-priority certification follows from these records.

## Reproducibility and source custody

1. Inspect `docs/current-lean-proof-receipts-20261115.json` for current dated receipts and historical references. Locate each original source path at current `main`; check its Git blob SHA-1.
2. Verify cited pinned Lean 4.36.0-rc2 run conclusion and the named-declaration axiom report, rather than treating green website tests as mathematical checks.
3. Run `python3 scripts/check_current_frontier.py --self-test`; the source-exact ledger `research/catalogue/CURRENT_FRONTIER.json` rejects forged proof statuses and hashes.
4. Run the active passport and website tests for public-scope consistency.
5. Never infer novelty from a prior-art search alone. See merged adversarial priority audit [PR #550](https://github.com/d3lefts/d3lefts/pull/550).
6. Full LaTeX/PDF archival publication, non-author referee review, broad language-alphabet transfer, and operational/effect-time physical assurance remain separate release gates.

**Change log v16:** preserve the exact C105 source-level result and post-merge replay, attach scoped C95/C96/one-increment/five-cover receipts, register new analytic and recertification discoveries without mislabeling Lean proof, and explicitly keep unrestricted sub-100 and real-world complete mediation open.
