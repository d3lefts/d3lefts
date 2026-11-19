# Lemma H via a coordinate-separable fooling bound (paper notes, 2026-11-19)

Status: reduction and two special cases proved on paper; the general lemma is open. Not reviewed.

## 1. Reduction chain

**Lemma R (target).** For `f : Ω → [0,1]` of interaction degree `≤ d` and a product law `μ̄`, there are weights
`ā_j ≥ 0` depending only on `f` and `μ̄`, with `∑_j ā_j ≤ C(d)`, such that for every product law `μ`

    |E_μ f − E_μ̄ f| ≤ ∑_j ā_j · TV(μ_j, μ̄_j).

**R ⇒ H.** Cauchy–Schwarz: `(∑_j ā_j TV_j)² ≤ (∑_j ā_j)(∑_j ā_j TV_j²) ≤ C(d) ∑_j ā_j TV_j²`, and `TV² ≤ 2H²`.

**H ⇒ the between-component half of the crux, with no M.** Take `μ̄_j = ν̄_j`, the mixture marginal, and
`c = E_{μ̄} f`. Since the mean minimizes the weighted squared deviation,

    B = ∑_θ π_θ (m_θ − m̄)² ≤ ∑_θ π_θ (m_θ − c)² ≤ C ∑_j ā_j ∑_θ π_θ TV(μ_{θ,j}, ν̄_j)²
      ≤ (C/2) ∑_j ā_j I(θ; x_j) ≤ (C²/2) max_j I(θ; x_j),

using Pinsker, `∑_θ π_θ KL(μ_{θ,j} ‖ ν̄_j) = I(θ; x_j)`. The point is that `ā_j` does not depend on `θ`. The
certified `fooling_tv` (max over `j` inside the `θ`-average) is exactly what produces the factor `M`.

## 2. What the rows give directly

Couple `x ∼ μ̄` and `y ∼ μ` coordinatewise, independently over `j`, and use the row `a(x)` at the anchor `x`:
`|f(x) − f(y)| ≤ ∑_{j : x_j ≠ y_j} a_j(x)`.

**(a) Ratio-distance version (proved).** Use the coupling "with probability `λ_j` resample `x_j` from
`q_j = (μ_j − (1 − λ_j) μ̄_j)/λ_j`", valid for `λ_j = max_b (1 − μ_j(b)/μ̄_j(b))_+`. The resampling event is
independent of `x`, so

    |E_μ f − E_μ̄ f| ≤ ∑_j λ_j · E_{μ̄}[a_j(x)],   with ∑_j E_{μ̄}[a_j] ≤ K = π²d²/2.

This is Lemma R with TV replaced by the one-sided ratio distance `λ_j`. It fails to give the crux exactly
when a component deletes (or nearly deletes) a symbol that has small mass under `ν̄_j`: then `λ = 1` while
the contribution to `I(θ; x_j)` is small.

**(b) Maximal coupling.** The mismatch probability given `x_j = b` is `r_j(b) = (μ̄_j(b) − min)/μ̄_j(b)`,
with `∑_b μ̄_j(b) r_j(b) = TV_j`. Hence

    E[1{x_j ≠ y_j} a_j(x)] ≤ E_{x_{−j}}[ max_b a_j(x_{−j}, b) ] · TV_j,

so Lemma R holds with `ā_j = E_{x ∼ μ̄}[ max_b a_j(x_j := b) ]` provided the rows satisfy

**Fiber-uniform rows (the missing lemma).** For bounded degree-`d` `f` there are rows with

    E_{x ∼ μ̄} ∑_j max_b a_j(x_j := b) ≤ C(d)     (pointwise ≤ C(d) would suffice for every μ̄).

That is: the weight a row puts on coordinate `j` should not jump when only `x_j` itself changes.

**Checks.**
- `d = 1`, `f = ∑_j c_j(x_j)`: rows `a_j(x) = max_b |c_j(x_j) − c_j(b)| ≤ osc(c_j)`, and
  `∑_j osc(c_j) = max f − min f ≤ 1`. Fiber-uniform with `C = 1`. Proved.
- Address functions (`k` address coordinates, one data coordinate per address): the own-coordinate
  weights are about 1 on each address coordinate and on the addressed data coordinate, and changing a
  data coordinate does not raise its own weight unless it is addressed. Sum about `k + 1 ≤ d`.
- Symmetric threshold-type `f = q(|x|/n)` with Chebyshev-steep `q`: weights about `|q'|/n` at `x` and at
  its single-coordinate neighbours alike; sum about `2d²`.
- Single-coordinate flips force `a_j(x)` and `a_j(x_j := b)` both to be at least `|f(x) − f(x_j := b)|`,
  so the obstruction can only come from multi-coordinate terms in the certificate.

## 3. Suggested next steps

1. Try to prove fiber-uniform rows from the selector construction (`Pv`, `Gsel`): build the certificate at
   `x` from blocks whose replacement symbols are chosen over the whole `j`-fiber, not at a fixed `x_j`.
2. Falsification target: search for `f` of degree 2 or 3 and `x` where `∑_j max_b a_j(x_j := b)` is large
   for the LP-optimal rows (the rows are an LP at each point; small alphabets make this exact).
3. If fiber-uniform rows fail, Lemma R might still hold with a different coupling; the ratio-distance case
   (a) shows the obstruction is confined to deletions of small-mass symbols.
