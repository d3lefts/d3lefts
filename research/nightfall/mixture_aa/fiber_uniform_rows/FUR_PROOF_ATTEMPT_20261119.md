# FUR: proof attempt, evidence and work plan (2026-11-19)

Status: **FUR not proved.** One aggregate lemma proved, two natural approaches shown to fail, new
evidence that FUR is exact on the Boolean cube. Written as a hand-off for parallel work.

## Statement (from `FIBER_UNIFORM_ROWS_20261119.md`)

`f : ∏ Σ_i → [0,1]`, coordinate degree `≤ d`. Want `α_i(x_{−i}) ≥ 0` with
`|f(x) − f(y)| ≤ ∑_{i ∈ D(x,y)} α_i(x_{−i})` and `∑_i α_i(x_{−i}) ≤ C(d) = poly(d)` for all `x`.

**Dual (LP duality, exact).** FUR with constant `C` ⇔ for every distribution `κ` on anchors and
weights `λ(x, y) ≥ 0` satisfying the *fiber budgets*

    for every i and every i-fiber F = {x : x_{−i} = z}:  ∑_{x∈F} ∑_{y : y_i ≠ x_i} λ(x, y) ≤ κ(F),

we have `∑_{x,y} λ(x,y) |f(x) − f(y)| ≤ C`. The plain row bound is the same with per-anchor budgets
(`≤ κ(x)`), proved by the selector. FUR's budgets are pooled over each fiber.

## New evidence (`growth.py`)

Boolean cube, `n = 4 … 9`, random ±1 quadratic forms plus a linear term (degree 2) and a high-degree
control: fiber cost **equals** plain cost in 17 of 18 instances (the exception: 5.235 vs 5.018, on
the high-degree control at `n = 9`). With `fiber_lp.py`/`climb.py` (alphabets 3–4): ratio ≤ 1.28.
No growth with `n` is visible. So FUR looks true with `C ≈ K` on bits, and close to it in general.

## Proved: aggregate single peel (Lemma P)

For any fiber-feasible `(κ, λ)`, peeling one disagreeing coordinate `i` at the anchor,
`|f(x) − f(y)| ≤ osc_i(x_{−i}) + |f(x^{i←y_i}) − f(y)|`, costs in total at most

    ∑_i ∑_F κ(F) · osc_i(F) = E_κ ∑_i osc_i(x_{−i}) ≤ 8 d²,

because `osc_i(x_{−i}) = max_{b,c} |f(x^{i←b}) − f(x^{i←c})|` is fiber-invariant, the fiber budget
bounds the λ-mass that uses coordinate `i`, and `∑_i osc_i ≤ 8 d²` holds pointwise
(`product_block_inequality` with single-coordinate blocks, `m = 1`). So **every pair may be peeled
once at every one of its coordinates at the anchor, for a total of `8d²`**.

## Approaches that fail (so nobody repeats them)

1. **Scale per anchor.** Per-anchor normalisation gives `value ≤ K · E_κ max_i L_i(x)` with
   `L_i` the load; fiber budgets only bound `E[L_i | x_{−i}] ≤ 1`, and `E max_i L_i` can be of order
   the alphabet size (`L_i = k · 1[x_i = a_i]`).
2. **Multilinear expansion.** `f(y) − f(x) = ∑_{S ⊆ D, |S| ≤ d} Δ_S f(x_{−S}; x_S, y_S)` makes all weights
   fiber-invariant, but `∑_{|S| = 2} |Δ_S|` can be of order `√n` pointwise (normalised random quadratic
   forms), so absolute values per `S` lose too much.
3. **Hybrid peeling of all coordinates.** After the first peel the anchor leaves its fibers, so the
   budgets for later coordinates no longer apply (Lemma P only covers peels at the original anchor).
4. **Symmetrising plain rows** (`max` or average over the fiber): no control on how much the plain
   weight on `i` jumps when `x_i` changes.

## Work plan for parallel agents

* **A. Boolean exactness (most promising).** Prove that on `{0,1}^n` an optimal plain row family can
  be chosen fiber-invariant (`a_i(x) = a_i(x^i)`), i.e. fiber cost = plain cost. Start by extracting
  optimal primal/dual pairs from `fiber_lp.py` on `n ≤ 6` and looking for the exchange argument; the
  fiber `{x, x^i}` has two points, and a pair anchored at `x^i` using `i` has `y_i = x_i`.
* **B. Selector with a fiber anchor.** Generalise `Gsel` so that at `w = 0` coordinate `i` is drawn
  from the κ-conditional law on its fiber rather than fixed. Target: the dual inequality directly,
  with an absolute value inside the anchor average (the current endpoint lemma gives it outside).
* **C. Peel-then-row.** Use Lemma P to peel each pair at one coordinate chosen by a rule that keeps
  the re-anchored family plain-feasible up to a constant; the plain row bound then finishes.
* **D. Falsification at scale.** Push `growth.py` to `n = 10–12` (sparse LP) and alphabets 3–5 with
  rare-symbol-heavy coefficients; any family with fiber/plain growing in `n` or `k` kills FUR with
  `poly(d)` and redirects route 1.
* **E. Weaker sufficient statement.** Route 1 only needs FUR **in expectation under one product
  law** (`E_{x∼ν̄} ∑_i α_i(x_{−i}) ≤ C`), not pointwise. Check whether Lemma P plus the plain row bound
  already gives that version.
