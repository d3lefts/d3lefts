# Route 1 (polylog-in-M Mixture-AA): attempt of 2026-11-19

Status: **not solved.** Two new lemmas proved on paper, the crux reduced to one sharper open
statement. Not reviewed, no Lean.

Notation: `ν = ∑_θ π_θ μ_θ`, `ν̄ = ⊗_j ν̄_j` the product of the mixture marginals,
`I_j = I(θ; x_j)`, `TV_{θ,j} = TV(μ_{θ,j}, ν̄_j)`, `m_θ = E_{μ_θ} f`, `c = E_ν̄ f`,
`B = Var_θ(m_θ) ≤ ∑_θ π_θ (m_θ − c)²`. Rows `a(x)` of cost `≤ K = π² d²` at every point
(`RowBound.product_row_bound`), capped at 1 without loss. `∑_θ π_θ TV_{θ,j}² ≤ I_j / 2` (Pinsker).

## Lemma A (overlap anchor; proved)

For product laws `ν̄, μ` with `∑_j TV(μ_j, ν̄_j) ≤ 1/2`:
`|E_μ f − E_ν̄ f| ≤ 2e ∑_j TV(μ_j, ν̄_j) · Ā_j`, where `Ā_j = E_ν̄[a_j]` (so `∑_j Ā_j ≤ K`).

*Proof.* Per coordinate, couple `x_j ∼ ν̄_j`, `y_j ∼ μ_j` maximally. Let `w_j = x_j (= y_j)` off the
mismatch event, and on it draw `w_j` from the overlap law `ω_j ∝ min(ν̄_j, μ_j)`. Then `w_j ∼ ω_j`
is independent of the mismatch indicator, and `w ∼ ⊗ ω_j`. Rows at the anchor `w`:
`|f(x) − f(y)| ≤ |f(x) − f(w)| + |f(w) − f(y)| ≤ 2 ∑_{j mismatched} a_j(w)`. Taking expectations,
`≤ 2 ∑_j TV_j E_ω[a_j]`. Since `ω_j ≤ ν̄_j / (1 − TV_j)`, `dω/dν̄ ≤ ∏ (1 − TV_j)^{-1} ≤ e` and
`a ≥ 0`, so `E_ω a_j ≤ e Ā_j`. ∎

**Consequence (M-free between bound for near components).** Call `θ` *near* if
`∑_j TV_{θ,j} ≤ 1/2`. Cauchy–Schwarz with weights `Ā_j` gives

    ∑_{θ near} π_θ (m_θ − c)² ≤ 4e² K ∑_j Ā_j ∑_θ π_θ TV_{θ,j}² ≤ 2e² K² max_j I_j.

The same anchor bounds the θ-increment of the lifted function `G(θ, u) = f(h(θ, u))` over pairs of
near components by `4eK √(max_j I_j / 2)`. So near components are handled in **both** halves
of the crux (between variance and θ-increment), with no `M`, `n`, alphabet or mass dependence.
This is the first M-free statement covering components that differ on many coordinates, not only
point masses (`CRUX_FALSIFICATION`) or one-hot shifts.

## Lemma B (packing form; proved)

For any point `x` and any family of points `y^θ` with weights `π_θ`,
`E_θ |f(x) − f(y^θ)| ≤ ∑_i a_i(x) q_i(x) ≤ K · max_i q_i(x)`, `q_i(x) = Pr_θ[y^θ_i ≠ x_i]`.
Immediate from the row at `x`; it is the dual (fractional block sensitivity) form of the product row
bound. With disjoint supports (`μ_θ = ν̄` off a set `S_θ`, the `S_θ` disjoint) it gives
`∑_θ |m_θ − c| ≤ 4d²` and so `B ≤ 4d² max_θ π_θ`, settling the disjoint-shift family exactly.

## What remains (the sharpened crux)

Only **far** components (`∑_j TV_{θ,j} > 1/2`) are open. Splitting each far component's
coordinates into a Bernstein part (`TV ≤ η`; cost `≤ d π √(η/2)` by the Hellinger–Bernstein lemma)
and a spiky part (`TV > η`) leaves exactly:

> **Open.** Components whose spiky part has `∑_{j : TV_{θ,j} > η} TV_{θ,j} > 1/2`.

Chaining Lemma A across batches fails because the anchor's density ratio against `ν̄` compounds.
Lemma B with a random anchor `x = h(θ_0, u)` fails because `E_x max_i q_i(x)` can be of order
`min(1, n p)` when many coordinates carry a rare symbol that the components disagree on (the
"rare fiber" obstruction). In every example we checked the true `B` is still small
(e.g. two components `Bern(2p)^n` vs `Bern(0)^n` with `np ≈ 1`: `B ≈ p²`, `I_j ≈ p`), so this
is a proof obstruction, not a counterexample.

Both failures point to the same missing lemma as `LEMMA_R_REDUCTION_20261119.md`
(fiber-uniform rows on average): rows whose weight on coordinate `j` does not jump when `x_j`
moves to a rare symbol. A concrete next test is the LP for fiber-uniform rows on small instances
with rare symbols (`n ≤ 6`, `d ≤ 3`).
