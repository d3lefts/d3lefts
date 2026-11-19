# Mixture-AA crux: first falsification pass (2026-11-19)

Status: evidence and one partial proof; the crux is **not** proved.

## Numerical search (`crux_search/crux_search.py`)

Minimises `C = max_j max(A_j, I_j)` over degree-`≤ d` functions `f : {0,1}^n → [0,1]` and
`M`-component product mixtures subject to `Var_ν(f) ≥ τ`, where
`A_j = ∑_θ π_θ L_{θ,j}(f)` (posterior-averaged mean absolute increment) and `I_j = I(θ; x_j)` (nats).
Projected to exact feasibility before scoring.

| n | d | τ | M | min C found | Var | active components |
| --- | --- | --- | --- | --- | --- | --- |
| 4 | 2 | 0.05 | 1 | 0.074 | 0.050 | 1 |
| 4 | 2 | 0.05 | 2 | 0.055 | 0.052 | 2 |
| 4 | 2 | 0.05 | 4 | 0.051 | 0.050 | 4 |
| 4 | 2 | 0.05 | 8 | 0.075 | 0.051 | 8 |
| 4 | 2 | 0.05 | 16 | 0.049 | 0.050 | 5 |
| 6 | 2 | 0.05 | 2 | 0.078 | 0.050 | 2 |
| 6 | 2 | 0.05 | 8 | 0.181 | 0.070 | 8 |
| 6 | 2 | 0.05 | 32 | 0.342 | 0.075 | 32 |

No degradation with `M` (min `C ≈ τ` throughout). **Caveat:** the local optimiser (L-BFGS with
finite differences, few restarts) gets *worse* at large `M`, so the `n = 6` rows say more about the
optimiser than about the crux. This pass does not falsify the crux, but it is not strong evidence
for it either; structured families (below) are more informative.

## Structured stress tests (by hand)

All pass, and for the same reason: a bounded degree-`d` function has a fractional-certificate row
of cost `K = π² d² / 2` at every point, so its total response to coordinate changes is bounded.

* **One-hot shifts** (component `θ` moves only coordinate `θ`): `B ≤ K/M`, so large between-variance
  forces small `M`.
* **Coherent biased coins** (`p = ½ ± γ` on all coordinates): `B ≈ γ²`, `I_j ≈ γ²`, linear.
* **Hidden address** (components bias different data bits, address uniform): `B ≤ γ²/K_addr²`.

## Partial proof: point-mass mixtures

If every component is a point mass (`ν` is an arbitrary distribution supported on `M` points), then
`max_j I(θ; x_j) ≥ Var_ν(f) / K`.

*Proof.* Let `c` be the coordinatewise mode and `q_j = Pr_ν[x_j ≠ c_j]`. With a row `a(c)` at `c`,
`|f(x) − f(c)| ≤ ∑_{j : x_j ≠ c_j} a_j(c)`, so `Var_ν f ≤ E|f(x) − f(c)| ≤ ∑_j a_j(c) q_j ≤ K max_j q_j`.
For point masses `x_j` is a function of `θ`, so `I(θ; x_j) = H(x_j) ≥ −ln(1 − q_j) ≥ q_j`. ∎

This is the pure "between" case (`W = 0`) and it is `M`-free with linear dependence on `Var`.
It does not extend directly: for general components the reference point and the coordinate
mismatch events are correlated, which is exactly the obstacle the pointwise fooling lemma must
handle.

## Two notes for the brief

1. **Lifting coupling.** The hidden-coordinate lifting `x_j = G_j(θ, u_j)` must make the
   coordinate mismatch probability `Pr[G_j(θ,u_j) ≠ G_j(θ',u_j)]` comparable to
   `TV(μ_{θ,j}, μ_{θ',j})` for the switch alternative to convert into information. A quantile
   coupling is not maximal on finite alphabets in general, and no single coupling is maximal for all
   pairs simultaneously; the conversion has to be stated for the coupling actually used.
2. **A sharper target for the between part (Lemma H).** For product laws `μ, μ̄` and bounded
   degree-`d` `f`, find weights `w_j ≥ 0` depending only on `(f, μ̄)` with `∑_j w_j ≤ C(d)` such that
   `(E_μ f − E_μ̄ f)² ≤ C(d) ∑_j w_j H²(μ_j, μ̄_j)` (Hellinger). With `μ̄ = ⊗_j ν̄_j` this gives
   `B ≤ C(d)² max_j I_j` (using `∑_θ π_θ H²(μ_{θ,j}, ν̄_j) ≤ I_j`), which is the `M`-free between
   alternative, without the lifting. It holds in every family above.
