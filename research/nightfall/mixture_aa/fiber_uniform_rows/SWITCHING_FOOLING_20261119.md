# Switching-time fooling lemma, and a gap in the brief's reduction (2026-11-19)

Status: Lemma S proved on paper (short). The switching-time coupling is a standard device; Lemma S is
likely folklore and should be cited as such, not claimed. Constant: `∑_j osc_j ≤ 4d²` for `[0,1]`-valued
`f` (the `8d²` below is loose but valid). It settles the "pointwise fooling bound" that
`MIXTURE_AA_POLYLOG_M_BRIEF_20261119.md` §4 lists as the open step. It does **not** close route 1:
the brief's reduction from that bound to the crux has a gap (below), which is exactly where FUR is
needed. Not reviewed, no Lean.

## Lemma S (switching-time fooling)

Let `(x_j, x′_j)` be independent across `j` (any per-coordinate couplings, any alphabets and masses),
`q_j = Pr[x_j ≠ x′_j]`, and `f : Ω → [0,1]` of coordinate degree `≤ d`. Then

    E|f(x) − f(x′)| ≤ ∑_j q_j ∫_0^1 E[osc_j(z(t))] dt ≤ 8 d² · max_j q_j,

where `osc_j(z) = max_{b,c} |f(z^{j←b}) − f(z^{j←c})|` and `z(t)` is defined below.

*Proof.* Draw `U_j ∼ Unif[0,1]` independently and let `z(t)_j = x′_j` if `U_j ≤ t`, else `x_j`. Then
`z(0) = x`, `z(1) = x′`, and `f(x′) − f(x)` is the sum of the jumps at the times `U_j`. The jump at `j` is
at most `1[x_j ≠ x′_j] · osc_j(z(U_j))`, and given `U_j = t` the other coordinates of `z(t)` are
independent of `(x_j, x′_j)`. So `E|jump_j| ≤ q_j ∫ E osc_j(z(t)) dt`. Pointwise,
`∑_j osc_j(z) ≤ 2 ∑_j max_b |f(z) − f(z^{j←b})| ≤ 8 d²` by `product_block_inequality` with
single-coordinate blocks (`m = 1`), as in `CubePrintedAA.sum_flip_le`. ∎

## The gap in the brief's reduction

For the lifted `G(θ, u) = f(h(θ, u))`, Lemma S gives
`L_θ(G) ≤ 8 d² · E_{θ,θ′} max_j Pr_u[h_j(θ,u) ≠ h_j(θ′,u)]`. The crux needs `max_j` **outside** the
average over components (it must become `max_j I(θ; x_j)`). One-hot mixtures (component `θ` moves
only coordinate `θ`) make `E_{θ,θ′} max_j` of order 1 while `max_j I_j ≍ 1/M`. The true `L_θ(G)` is
small there (`≤ 16 d²/M`), which the refined form of Lemma S sees, but its weights
`∫ E osc_j(z(t)) dt` depend on `(θ, θ′)` through the laws of the other coordinates.

Making those weights component-independent is what FUR does (weights `α_j(x̄_{−j})` at a
`θ`-free anchor). Comparing `E osc_j` under the switched law with `E_ν̄ osc_j` by the same switching
argument moves the problem to second-order oscillations, whose sum can be of order `√n`, so naive
recursion fails (`FUR_PROOF_ATTEMPT_20261119.md`, approach 2).

## What this changes

* The pointwise fooling bound is no longer open; the open statement is precisely
  **component-independent weights** (FUR, or its in-expectation version, approach E).
* Lemma S is useful on its own: bias-free, alphabet-free, `n`-free fooling of bounded low-degree
  functions by product couplings, with a two-line proof from the certified block inequality.
