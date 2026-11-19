# Classical simulation of quantum queries under bounded product-mixture complexity (2026-11-18)

## Status (updated after review)

* **Lean-certified** (`MixtureSimulation.lean`, `Mixture.mixture_simulation`, axioms `propext`,
  `Classical.choice`, `Quot.sound` only; local strict audit passed; CI step added). For any mixture
  `ν = ∑_θ w_θ ⊗_i P θ i` of `M` product laws on a finite `ι → α` (any masses, zeros allowed),
  `f : ι → α → [0,1]` of interaction degree `d ≥ 1`, `τ ∈ (0, 1/2]`, `n ≥ 1`: some decision tree
  makes at most `n` queries on every input and

      Pr_{x∼ν}[ |f x − Q̃ x| > ε ] ≤ (12 π⁶ d⁶ M / (τ² √τ) + 512 d⁴ M⁴ / τ³) / n + τ / ε².

  With `τ = ε²δ/2` the depth is `O(d⁶ M ε⁻⁵ δ^{−7/2} + d⁴ M⁴ ε⁻⁶ δ⁻⁴)`. The Lean fooling lemma
  (`fooling_tv`) has constant `16 d² γ` (paper: `2 d² γ`), via the vendored endpoint Markov bound on a
  cube of `⌊1/γ⌋` bits; this is why the second term's constant is `512` per unit of `τ⁻³`
  rather than `32`. The quantum-to-polynomial step (degree `≤ 2T`) remains on paper.
* **Edge cases raised by reviewers, resolved in the formalization.** Posterior weights are kept
  unnormalized (`upd`, `Vs`), so zero-weight components never divide by zero; `x / 0 = 0` terms are
  checked explicitly in `chi_sq_bound`. The fooling lemma assumes `0 < γ ≤ 1/2`; larger `γ` is never
  needed.
* **Headline corrected.** The theorem rules out superpolynomial classical-versus-quantum query
  separations on input distributions whose product-mixture complexity `M` is polynomial in the
  quantum query count `T` (at fixed `ε, δ`). It does *not* say anything about `M` polynomial in the
  input length `n`. Correct headline: *superpolynomial distributional quantum query advantages
  require product-mixture complexity superpolynomial in the quantum query budget.* The earlier
  wording in §1 and §6 below ("not mixtures of polynomially many product distributions") overstated
  this and is superseded.
* **Reviewer improvements (paper level, not in Lean).** Second readers report a sharper bound from
  Jensen across component variances and an entropy potential, e.g.
  `O(d⁶ M ε⁻⁵ δ^{−7/2} + d⁴ M² log M ε⁻⁴ δ⁻³)`, and a direct rank argument showing the Gaussian-sign
  Forrelation law needs exactly `M ≥ N` components (cross-moment matrix of full rank vs. rank `≤ M`
  for any mixture of `M` products). Both are recorded in the PR #858 review thread; neither is
  formalized here.
* **Prior art to address.** Blais–O'Donnell–Wimmer (low-degree polynomial regression under
  mixtures of product distributions): different task (learning), must be discussed.

The original paper proof follows unchanged.

## 1. Statement

**Setting.** `Ω = Σ_1 × ⋯ × Σ_n`, finite alphabets. The input law is a mixture of `M` product
laws, `ν = ∑_{θ=1}^M w_θ μ_θ`, each `μ_θ = ⊗_i μ_{θ,i}` arbitrary (any biases, zero masses allowed).
The classical algorithm knows `ν` and the decomposition, as in Aaronson–Ambainis.

**Theorem (mixtures).** Let `f : Ω → [0, 1]` have interaction degree at most `d ≥ 1` (for a
`T`-query quantum algorithm, `d = 2T`). For `ε, δ ∈ (0, 1)` there is a deterministic decision
tree `Q̃` of depth

    D ≤ 2^{11/2}·3 π⁶ · d⁶ M ε⁻⁵ δ^{−7/2}  +  512 · d⁴ M⁴ ε⁻⁶ δ⁻⁴        (Gini version)

with `Pr_{x∼ν}[ |f(x) − Q̃(x)| > ε ] ≤ δ`. With the entropy potential (§4, remark) the second term
becomes `O(d⁴ M² log M · ε⁻⁴ δ⁻³)`.

So the overhead is `poly(T, M, 1/ε, 1/δ)`, independent of the biases, the alphabets and `n`.

**Sharpness of the hypothesis.** Every distribution on a finite `Ω` is a mixture of `|supp ν|`
point masses, and a point mass is a product law. So some bound on `M` is necessary: the mixture
count is exactly the parameter that separates "simulable" from "arbitrary". Exponential query
separations on fixed input distributions (e.g. Forrelation) must therefore use distributions whose
product-mixture complexity is `n^{Ω(1)}` (§6).

## 2. Two lemmas

**Lemma A (fooling by small marginal changes).** Let `μ, μ'` be product laws on `Ω` with
`γ_i = TV(μ_i, μ'_i)` and `γ = max_i γ_i < 1`, and let `f : Ω → [0, 1]` have degree `≤ d`. Then
`|E_μ f − E_{μ'} f| ≤ 2 d² γ`.

*Proof.* Maximal coupling per coordinate: `μ_i = (1 − γ_i) c_i + γ_i r_i`,
`μ'_i = (1 − γ_i) c_i + γ_i r'_i`, with `c_i, r_i, r'_i` probability vectors. For `u ≥ 0` put
`λ_i(u) = (1 − u γ_i) c_i + u γ_i r_i`, a probability vector for `0 ≤ u ≤ R := 1/γ`. Then
`q(u) = E_{⊗ λ_i(u)} f` is a polynomial in `u` of degree `≤ d`: the expectation of an indicator
monomial on `S` is a product of `|S| ≤ d` affine functions of `u`. It takes values in `[0, 1]` on
`[0, R]`. By Markov's inequality on `[0, R]`, `|q'| ≤ (2d²/R)·(1/2) = d² γ` (applied to `q − 1/2`),
so `|E_μ f − E_{⊗ c_i} f| = |q(1) − q(0)| ≤ d² γ`. The same for `μ'` with `r'_i`. ∎

(If `γ = 1` the bound `2d² ≥ 1` is trivial.)

**Lemma B (posterior impurity drops when components separate).** Let `π` be a law on `[M]`, and
for one coordinate `j` let `ν̄_j = ∑_θ π_θ μ_{θ,j}`, `π(θ | b) = π_θ μ_{θ,j}(b) / ν̄_j(b)`. Then

    E_{b∼ν̄_j} [ ∑_θ π(θ|b)² ] − ∑_θ π_θ² = ∑_θ π_θ² χ²(μ_{θ,j} ‖ ν̄_j) ≥ 4 π_θ² TV(μ_{θ,j}, ν̄_j)²

for every `θ`.

*Proof.* `E_b π(θ|b) = π_θ`, so the left side is `∑_θ Var_b π(θ|b)`, and
`Var_b π(θ|b) = ∑_b ν̄(b)(π_θ μ_θ(b)/ν̄(b) − π_θ)² = π_θ² χ²(μ_θ ‖ ν̄)`. Cauchy–Schwarz gives
`(∑_b |μ_θ(b) − ν̄(b)|)² ≤ χ²(μ_θ ‖ ν̄) · ∑_b ν̄(b)`, i.e. `χ² ≥ 4 TV²`. ∎

## 3. The algorithm

State: the queried assignment `ρ`. Write `f_ρ` for the section (a function of the unqueried
coordinates), `π = π_ρ` for the posterior on `θ` (`π_ρ(θ) ∝ w_θ μ_θ(ρ)`), and `ν_ρ = ∑_θ π_ρ(θ) μ_θ`
on the unqueried coordinates (each `μ_θ` restricted, still a product law); `ν_ρ` is the
conditional law of the unqueried coordinates given `ρ`. Put

* `m_θ = E_{μ_θ} f_ρ`, `W = ∑_θ π_θ Var_{μ_θ}(f_ρ)` (within), `B = ∑_θ π_θ (m_θ − m̄)²` (between);
  `Var_{ν_ρ}(f_ρ) = W + B`.
* `K = π² d² / 2`: every section of `f` has rows of cost `K` (`hasRows_of_degree`, `hasRows_sect`).

Rule, with threshold `τ`:

1. If `Var_{ν_ρ}(f_ρ) ≤ τ` or the depth cap is reached: output `E_{ν_ρ} f_ρ`.
2. Else if `W > τ/2` (**increment step**): query `j` maximising `∑_θ π_θ L^{μ_θ}_j(f_ρ)`, where
   `L^μ_j(g) = E_{x∼μ, b∼μ_j} |g(x) − g(x_j := b)|`.
3. Else (`B > τ/2`, **separation step**): query `j` maximising the expected drop of the posterior
   impurity `1 − ∑_θ π_θ²`.

## 4. Analysis

**Potentials.** `Φ(ρ) = ∑_θ π_ρ(θ) L^{μ_θ}(f_ρ)` with `L^μ = ∑_k L^μ_k`, and
`G(ρ) = 1 − ∑_θ π_ρ(θ)²`. Both are non-negative, `Φ(∅) ≤ K` (`sum_pincr_le` for each `θ`) and
`G(∅) ≤ 1`.

*Both are supermartingales along the run, for any choice of query.* Querying `j`, the answer `b` has
law `ν̄_j`, and `π_{ρb}(θ) ν̄_j(b) = π_ρ(θ) μ_{θ,j}(b)`. Hence

    E_b Φ(ρb) = ∑_θ π_ρ(θ) ∑_b μ_{θ,j}(b) L^{μ_θ}(f_{ρ, x_j = b}) = ∑_θ π_ρ(θ) ( L^{μ_θ}(f_ρ) − L^{μ_θ}_j(f_ρ) ),

by the product identity `sum_mul_Ltot_sect` for each `μ_θ`. And `E_b G(ρb) = G(ρ) − (drop in
Lemma B) ≤ G(ρ)`.

**Increment step gains.** `W > τ/2` and `Var ≤ 1/4` give `π(H) > τ` for
`H = {θ : Var_{μ_θ}(f_ρ) > τ/4}`, so some `θ* ∈ H` has `π_{θ*} ≥ τ/M`. By `mean_increment` for
`μ_{θ*}` (rows of cost `K`), some `j*` has `L^{μ_{θ*}}_{j*}(f_ρ) ≥ η` with
`144 K⁴ η² = (τ/4)³`. The chosen `j` therefore lowers `E Φ` by at least `g_a = τη/M`.

**Separation step gains.** `2B = ∑_{θ,θ'} π_θ π_{θ'} (m_θ − m_{θ'})² > τ`. Pairs with
`π_θ π_{θ'} < τ/(2M²)` contribute less than `τ/2`, so some pair has `π_θ π_{θ'} ≥ τ/(2M²)` and
`|m_θ − m_{θ'}| > √(τ/2)`. Lemma A (for `f_ρ`, degree `≤ d`, values in `[0,1]`) gives an unqueried
`j` with `TV(μ_{θ,j}, μ_{θ',j}) ≥ √(τ/2) / (2d²) =: γ`. One of `θ, θ'` is at TV `≥ γ/2` from `ν̄_j`,
so by Lemma B the impurity drops by at least
`g_b = (τ/(2M²))² · γ² = τ³ / (32 M⁴ d⁴)` in expectation.

**Expected number of queries.** Summing the expected drops of the two potentials,

    E[N] ≤ Φ(∅)/g_a + G(∅)/g_b ≤ K M/(τ η) + 32 M⁴ d⁴ / τ³ = 12 π⁶ d⁶ M τ^{−5/2} + 32 d⁴ M⁴ τ^{−3}.

**Error.** At a finished leaf `Var_{ν_ρ}(f_ρ) ≤ τ`, and `ν_ρ` is the conditional law of the
unqueried coordinates, so Chebyshev gives `Pr[ |f − Q̃| > ε | leaf ] ≤ τ/ε²`. With
`τ = ε²δ/2` and cap `D ≥ 2E[N]/δ` (Markov), `Pr[ |f − Q̃| > ε ] ≤ δ`, giving the stated `D`.

*Remark (entropy).* Replacing `G` by the posterior entropy `H(π) ≤ ln M`, the separation step lowers
`E H` by the mutual information `I(θ; x_j | ρ) ≥ π_θ · 2 TV(μ_{θ,j}, ν̄_j)²` (Pinsker), which gives
the `O(d⁴ M² log M ε⁻⁴ δ⁻³)` term. The Gini version uses only finite sums and is the one to
formalize.

## 5. Corollaries

* **Product laws** (`M = 1`): the separation step never occurs; this is the Lean-certified
  `simulation_degree` up to the depth constant.
* **Dense over a mixture.** If `ν ≤ C · ν'` pointwise with `ν'` a mixture of `M` products, run the
  tree for `ν'` with `δ/C`: depth `poly(T, M, C, 1/ε, 1/δ)`.
* **Latent-variable models.** Inputs generated by a hidden state with `M` values and conditionally
  independent symbols (latent class models, `M`-state hidden "regimes") are exactly mixtures of
  `M` products.

## 6. Consequence for separations (to verify against the sources before claiming)

A distinguishing advantage `c` of a `T`-query quantum algorithm between `ν_1` and `ν_2` transfers
to the tree under `½ν_1 + ½ν_2` (advantage `≥ c − 4(ε + δ)`). If `ν_2` is uniform (a product) and
classical algorithms need `q(n)` queries for constant advantage, then `ν_1` cannot be a mixture of
`M` products unless `D(T, M, ε, δ) ≥ q(n)` at constant `ε, δ`. For Forrelation (one quantum query;
classical lower bound `Ω̃(√n)`, Aaronson–Ambainis STOC 2015 — check the adaptive statement) this
forces product-mixture complexity `M ≥ n^{1/8 − o(1)}`. Statement: *exponential quantum query
speedups need input distributions that are not mixtures of polynomially many product
distributions.*

## 7. What remains

1. A second reader for Lemma A (in particular the polynomial `q(u)` and the range `[0, 1/γ]`) and
   for the posterior bookkeeping in §4.
2. Priority check for "mixtures of product distributions" in the AA/simulation literature.
3. Lean, building on `ProductSimulation.lean`: the posterior-state tree, the two supermartingale
   identities (finite sums), Lemma B (finite Cauchy–Schwarz), and Lemma A. Lemma A needs Markov's
   inequality at interior points; the vendored `Row.markovEndpoint` gives the endpoint case on
   `[0, 2]`, and applying it on `[t, R]` for `t ≤ R/2` gives `|q'(t)| ≤ 4d²/R` there, enough for
   `|q(1) − q(0)|` with a constant `2×` worse.
4. Beyond mixtures: weakly dependent laws (Dobrushin uniqueness, high-temperature Gibbs measures).
   The potential argument goes through with Glauber (heat-bath) increments for *any* law; what is
   missing is the per-step gain, i.e. an Aaronson–Ambainis inequality for the conditional
   resampling increments of such measures. Open.
