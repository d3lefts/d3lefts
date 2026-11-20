# Route 1: polylog-M classical simulation over mixtures of product laws (paper proof, 2026-11-19)

Status: **complete paper proof, without FUR.** Not reviewed, no Lean, priority not checked. The
crux of `MIXTURE_AA_POLYLOG_M_BRIEF_20261119.md` is proved with `g = poly(τ/d)` and no dependence on
`M`, `n`, alphabets or masses. FUR (`fiber_uniform_rows/`) turns out not to be needed.

## Theorem

Let `ν = ∑_{θ=1}^M π_θ μ_θ` be a mixture of `M` product laws on `Ω = ∏_{j≤n} Σ_j` (finite
alphabets, any masses, zeros allowed), and `f : Ω → [0,1]` of coordinate degree `≤ d` (a `T`-query
acceptance probability has `d = 2T`). For `0 < ε, δ < 1` there is a deterministic decision tree of
depth

    poly(d, 1/ε, 1/δ) · (1 + log M)

whose output is within `ε` of `f(x)` except with `ν`-probability `δ`. The bound is linear in
`log M`, which is necessary (Bernstein–Vazirani, brief §2).

## Notation and certified inputs

* `K = π² d²`: every point `x` has a row `a(x)` with `|f(x) − f(y)| ≤ ∑_{j : x_j ≠ y_j} a_j(x)` and
  `∑_j a_j(x) ≤ K` (`RowBound.product_row_bound`).
* `osc_j(z) = max_{b,c} |f(z^{j←b}) − f(z^{j←c})|`; pointwise `∑_j osc_j(z) ≤ 4d²` for `[0,1]`-valued
  `f` (`product_block_inequality`, single-coordinate blocks).
* Product AA on arbitrary product probability spaces (`infinitePi_aa_product`, Lean-certified):
  `|G| ≤ 1`, Efron–Stein degree `≤ D`, `Var G ≥ τ` ⇒ some coordinate has
  `Inf_c(G) ≥ γ(τ, D) := √(3 τ⁵ / 12500) / (π² D²)³`.
* At a node, `ν̄ = ⊗ ν̄_j` is the product of the (posterior) mixture marginals,
  `I_j = I(θ; x_j) = E_θ KL(μ_{θ,j} ‖ ν̄_j)`, `I* = max_j I_j`, and
  `φ_{θ,j} = arccos BC(μ_{θ,j}, ν̄_j)` (Hellinger angle).

Two elementary facts: `φ² ≤ (π²/2) H² ≤ (π²/4) KL` (from `1 − cos φ = H²`, `φ ≤ π sin(φ/2)`,
`H² ≤ −ln BC ≤ KL/2`), so `E_θ φ_{θ,j}² ≤ (π²/4) I_j`; and `TV ≤ sin φ ≤ φ`.

## Lemma S (switching-time fooling; folklore device)

If `(x_j, x′_j)` are independent across `j` and `q_j = Pr[x_j ≠ x′_j]`, then
`E|f(x) − f(x′)| ≤ 4d² max_j q_j`. (Switch each coordinate at an independent uniform time; the jump
at `j` is at most `1[x_j ≠ x′_j] osc_j(z)` with `z` independent of `(x_j, x′_j)`; sum with
`∑_j osc_j ≤ 4d²`. See `fiber_uniform_rows/SWITCHING_FOOLING_20261119.md`.)

## Key Lemma (M-free fooling of the latent label)

Use consistent sampling: independent seeds `u_j` and maps with `h_j(θ, ·)_# λ_j = μ_{θ,j}` for
every `θ`, `h̄_j(·)_# λ_j = ν̄_j`, and `Pr[h_j(θ, u_j) ≠ h̄_j(u_j)] ≤ 2 TV(μ_{θ,j}, ν̄_j)` for all `θ`
at once. Then for every `η ∈ (0, 1]`

    E_{θ∼π} E_u |f(h(θ, u)) − f(h̄(u))| ≤ K · (π²/4) · I*/η² + 8 d² η.

With `η = (I*)^{1/3}` the right side is `≤ c_d (I*)^{1/3}`, `c_d = π⁴d²/4 + 8d²`.

*Proof.* Fix `η`. For each `θ` let `L_θ = {j : φ_{θ,j} > η}` (large-angle coordinates; a
deterministic set). Write `x̄ = h̄(u)`, `y = h(θ, u)`, and let `z` agree with `y` on `L_θ` and with
`x̄` elsewhere.

*Large part.* `z` differs from `x̄` only inside `L_θ`, so by the row at `x̄`,
`|f(x̄) − f(z)| ≤ ∑_{j ∈ L_θ} a_j(x̄)`. Average over `θ` with `u` fixed:
`E_θ |f(x̄) − f(z)| ≤ ∑_j a_j(x̄) · Pr_θ[j ∈ L_θ] ≤ K · max_j Pr_θ[j ∈ L_θ]`. Pointwise in `u`, so also
after `E_u`. By Markov, `Pr_θ[j ∈ L_θ] ≤ E_θ φ_{θ,j}² / η² ≤ (π²/4) I_j / η²`.

*Small part.* `z` and `y` agree on `L_θ`; off `L_θ` the pairs `(x̄_j, y_j)` are independent across
`j` with mismatch `≤ 2 TV ≤ 2 φ_{θ,j} ≤ 2η`. Lemma S gives `E_u |f(z) − f(y)| ≤ 8 d² η` for every `θ`.

Add the two. ∎

The point is that the large coordinates are charged through a **deterministic** set `L_θ` whose
frequency over `θ` is controlled by information. That removes both obstructions of the earlier
attempts: the max over coordinates sits outside the average over components (packing at a single
anchor), and no row weight is correlated with its own mismatch event (no fiber issue). Small
coordinates need no information at all, only the threshold `η`.

## Crux (M-free)

At a node with `Var_ν(f) ≥ τ`: some coordinate `j` has
`E_{θ∼π} L_j^{μ_θ}(f) ≥ 2γ` or `I_j ≥ (γ / c_d)³`, where `γ = γ(τ, d + 1)` and
`L_j^μ(f) = E_{x∼μ, b∼μ_j} |f(x) − f(x^{j←b})|`.

*Proof.* Lift: `G(θ, u) = f(h(θ, u))` on the product space `Θ × ∏_j U_j` with law `π ⊗ ⊗ λ_j`. `G`
has the law of `f` under `ν`, values in `[0,1]`, and Efron–Stein degree `≤ d + 1` (each indicator
monomial on `S` becomes a function of `(θ, u_S)`). Product AA gives a coordinate with
`Inf ≥ γ`, and `Inf_c ≤ ½ E|G − G^{(c)}|` for `[0,1]`-valued `G`.
* Seed `u_j`: resampling `u_j` with `θ` fixed resamples `x_j ∼ μ_{θ,j}`, so
  `E_π L_j^{μ_θ}(f) = E|G − G^{(u_j)}| ≥ 2γ`.
* `θ`: `2γ ≤ E|G(θ, u) − G(θ′, u)| ≤ 2 E_θ E_u |f(h(θ,u)) − f(h̄(u))| ≤ 2 c_d (I*)^{1/3}`
  by the Key Lemma. ∎

## Algorithm and depth

At node `ρ` (posterior `π_ρ`, restricted components `μ_{θ,ρ}`, still products; `f_ρ` still degree
`≤ d`): if `Var_{ν_ρ}(f_ρ) ≤ τ`, stop and output `E_{ν_ρ} f_ρ`; otherwise query the coordinate the
crux provides.

Potentials, both `≥ 0` and non-increasing in expectation under every query:
* `Φ(ρ) = E_{θ∼π_ρ} ∑_i L_i^{μ_{θ,ρ}}(f_ρ) ≤ 2d²`. Querying `x_j` gives
  `E Φ(ρ′) = Φ(ρ) − E_{π_ρ} L_j^{μ_θ}(f_ρ)` exactly (posterior update `π′ ∝ π μ_{θ,j}(a)` and Fubini;
  certified as `Phi_sum` in the mixture simulation).
* `H(π_ρ) ≤ ln M`, which drops in expectation by `I(θ; x_j | ρ)` (chain rule).

Each query drops `Φ` by `≥ 2γ` or `H` by `≥ (γ/c_d)³` in expectation, so the number of queries `N`
satisfies `E N ≤ 2d²/(2γ) + ln M · (c_d/γ)³`. Chebyshev at leaves gives error `> ε` with probability
`≤ τ/ε²`; cap the depth at `2 E N / δ` (Markov) and take `τ = ε² δ / 2`. With
`γ ≍ τ^{5/2}/d^6` and `c_d ≍ d²`:

    depth = O( (d^8 τ^{-5/2} + d^{24} τ^{-15/2} ln M) / δ ),   τ = ε² δ / 2.

Polynomial in `d, 1/ε, 1/δ`, linear in `log M`. No attempt to optimise exponents.

## What to check (review list)

1. Consistent sampling for finitely many laws on a finite alphabet, plus the reference `ν̄_j`, with
   exact marginals and mismatch `≤ 2TV/(1 + TV)` (Kleinberg–Tardos; Holenstein).
2. `infinitePi_aa_product` applies to `G` on `Θ × ∏ U_j` (finite `Θ`, standard seed spaces) with
   Efron–Stein degree `d + 1`; its influence is the Efron–Stein influence used here.
3. The `Φ` identity at nodes where some components get posterior weight 0 (zero-mass symbols).
4. Priority: mixtures of product distributions in the AA / simulation literature (GMNR, BDST,
   HMP and follow-ups since Nov 2026).

## Relation to earlier notes

* FUR (`fiber_uniform_rows/`) is not needed; its evidence and Approach-A counterexample stay as
  records. Lemma B of `ROUTE1_ATTEMPT_20261119.md` was the right tool, applied to the deterministic
  large-angle sets instead of the random mismatch sets.
* The brief's claim that a max-form pointwise fooling bound suffices was wrong (max inside the
  component average); the Key Lemma is the correct replacement.
