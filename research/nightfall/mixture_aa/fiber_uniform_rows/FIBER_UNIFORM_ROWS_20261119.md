# Route 1 reduced to one lemma: fiber-uniform rows (2026-11-19)

Status: the polylog-in-M target is proved on paper **conditional on Lemma FUR** below. FUR is open;
exact LP computations support it. Not reviewed, no Lean. Supersedes the near/far split in
`ROUTE1_ATTEMPT_20261119.md`.

## Lemma FUR (open)

There is `C(d) = poly(d)` such that every `f : Ω → [0,1]` of coordinate degree `≤ d` on a finite
product `Ω = ∏ Σ_i` has **fiber-invariant rows**: functions `α_i : Σ_{−i} → [0,1]` with

1. `|f(x) − f(y)| ≤ ∑_{i : x_i ≠ y_i} α_i(x_{−i})` for all `x, y`, and
2. `∑_i α_i(x_{−i}) ≤ C(d)` for all `x`.

Ordinary rows (`RowBound.product_row_bound`) satisfy (1)–(2) with `C = π² d²` but may depend on
`x_i`. FUR asks that the weight on coordinate `i` not depend on `x_i` itself. The statement is
law-free, so it covers rare symbols automatically.

## Evidence (`fiber_lp.py`, `climb.py`)

Exact LPs for the minimum pointwise cost, plain rows vs fiber-invariant rows.

* 40 random and Chebyshev-amplified instances, `(n, k, d)` from `(4,2,2)` to `(6,2,3)` and
  `(4,3,3)`: the two costs are equal in 36 cases; max ratio 1.14.
* Hill-climbing on coefficients to maximise fiber/plain (9 runs; `(4,3,2)`, `(3,4,2)`, `(4,3,3)`):
  max ratio **1.28**; max fiber cost 2.58, below the plain-row maxima reached by Chebyshev
  functions (3.0 for `d = 2`, 4.84 for `d = 3`).

## FUR ⇒ the crux ⇒ the target

Mixture `ν = ∑_θ π_θ μ_θ` of `M` product laws, `ν̄ = ⊗ ν̄_j` its marginal product,
`I_j = I(θ; x_j)`.

**Lifting.** Seeds `u_j` independent; consistent sampling gives maps `h_j(θ, u_j)` with law `μ_{θ,j}`
for every `θ`, and `h̄_j(u_j)` with law `ν̄_j`, such that
`Pr_u[h_j(θ, u_j) ≠ h̄_j(u_j)] ≤ 2 TV(μ_{θ,j}, ν̄_j)` for all `θ` simultaneously.
`G(θ, u) = f(h(θ, u))` lives on the product `Θ × ∏ U_j` with law `π ⊗ λ^{⊗n}`, has the law of `f`
under `ν`, values in `[0,1]` and coordinate degree `≤ d + 1`.

**Product AA on `G`** (certified mean-increment form, `M`-free since `θ` is just one more coordinate
with an alphabet of size `M`): if `Var_ν f ≥ τ`, some coordinate has mean increment
`≥ g := τ^{3/2} / (12 K_{d+1}²)`.

* *Seed `u_i`*: its increment equals `E_{θ∼π} L_i^{μ_θ}(f)`, the posterior-averaged component
  increment, which is what the certified potential `Φ` pays for when `x_i` is queried.
* *`θ`*: `L_θ(G) = E|f(h(θ,u)) − f(h(θ′,u))| ≤ 2 E_θ E_u |f(h(θ,u)) − f(h̄(u))|`. Apply FUR at the
  anchor `x̄ = h̄(u)`: `|f(h(θ,u)) − f(x̄)| ≤ ∑_{j mismatched} α_j(x̄_{−j})`. The mismatch at `j` depends
  on `u_j` only and `α_j(x̄_{−j})` on `u_{−j}` only, so they are independent:
  `E_u ≤ ∑_j 2 TV(μ_{θ,j}, ν̄_j) · ᾱ_j`, `ᾱ_j = E_ν̄ α_j`, `∑_j ᾱ_j ≤ C`. Cauchy–Schwarz and
  `E_θ TV² ≤ I_j / 2` give `L_θ(G) ≤ 4 C √(max_j I_j / 2)`, so `max_j I_j ≥ g² / (8 C²)`.

This is the crux of `MIXTURE_AA_POLYLOG_M_BRIEF_20261119.md` with
`g(τ, d) = min(g, g²/(8C²)) = poly(τ/d)`, independent of `M`, `n`, alphabets and masses.

**Target.** The brief's two-potential argument (`Φ ≤ 4d²`, `H(π) ≤ ln M`, both supermartingales,
stop at `Var ≤ τ`, Chebyshev at leaves, Markov on the stopping time) then gives a deterministic tree
of depth `poly(d, 1/ε, 1/δ) · (1 + log M)` approximating `f` within `ε` except with
`ν`-probability `δ`, for every mixture of `M` product laws. With `d = 2T` this is the polylog-`M`
classical simulation of `T`-query quantum algorithms, and with the Bernstein–Vazirani lower bound in
the brief it is tight in `log M` up to the polynomial.

## What a proof of FUR needs

The LP dual pools the per-coordinate budget over each fiber `{x_{−i} = z}` instead of per anchor:
a distribution `κ` on anchors with packings whose coordinate-`i` load is at most 1 **on average over
each `i`-fiber**. The selector argument handles one anchor at a time. A proof likely needs a selector
whose value at `w = 0` is a law on the fiber, not a point, together with an absolute value inside the
anchor average, which the current endpoint machinery does not give.
