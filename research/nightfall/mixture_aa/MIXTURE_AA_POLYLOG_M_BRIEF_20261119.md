# Research brief: polylog-in-M simulation over product mixtures (2026-11-19)

Status: research target with reductions and a precisely stated crux. Nothing here is proved
beyond what is marked; no Lean yet. Author: review session on `main` at `912c1b2`.

## 1. Target theorem

Let `ν = ∑_{θ=1}^M π_θ μ_θ` be a mixture of `M` product laws on a finite product (any alphabets,
any masses). Let `f : Ω → [0,1]` have interaction degree `≤ d` (a `T`-query algorithm: `d = 2T`).

**Target (Mixture-AA simulation).** A deterministic decision tree of depth
`poly(d, log M, 1/ε, 1/δ)` approximates `f` within `ε` except with `ν`-probability `δ`.

Merged/certified today: depth `poly(d, M, 1/ε, 1/δ)` (`mixture_simulation`,
`mixture_simulation_jensen`; circuit form in #877/#905; TV form in #910). The target replaces `M`
by `log M`.

## 2. Why this is the right breakthrough

* **Tight in `log M`.** Bernstein–Vazirani inputs (truth table of `y ↦ s·y`, `s` uniform) are a
  uniform mixture of `M = 2^n` point masses (products). One quantum query recovers `s`, so the
  acceptance probability `Maj(s)` has `T = 1`, while classically each query reveals one parity of
  `s` and `Maj(s)` needs `Ω(n) = Ω(log M)` queries. So `log M` cannot be removed; the target says
  `poly(log M)` suffices.
* **Matches the Forrelation obstruction.** The archived audit (#868) gives product-mixture
  complexity `log M ≥ c·N` for Gaussian-sign Forrelation, with classical cost `Ω̃(√N)` at `T = 1`.
  The target is consistent with that (`poly(log M) = poly(N) ≥ √N`), and together they read:
  *a superpolynomial distributional quantum query advantage requires `log M` superpolynomial in
  `T` — exponential product-mixture complexity — and Forrelation has exactly that.*
* **Generalizes Turturean.** `M = 1` is the product-space AA theorem; the target is
  "AA for latent-class distributions" with only logarithmic cost in the number of classes.
* **Current `M`-dependence is an artifact.** Both certified steps lose `M` for the same reason:
  a query that is good for one component is charged at that component's posterior weight
  (`≥ τ/M` in `increment_good_jensen`, `≥ τ/(2M²)` in `separation_good`).

## 3. Reduction: the crux lemma

**Crux (Mixture-AA inequality).** There is `g(τ, d) = poly(τ/d)` (independent of `M`, `n`,
alphabets, masses) such that for every posterior `π` and section `f` (degree `≤ d`, values in
`[0,1]`) with `Var_ν(f) ≥ τ`, some coordinate `i` satisfies

    E_{θ∼π} L_i^{μ_θ}(f) ≥ g      (posterior-averaged mean increment)
    or   I(θ; x_i) ≥ g            (information about the component, x ∼ ν).

**Crux ⇒ target** (paper argument, same skeleton as the certified proof):
* Potential `Φ = E_π L^{μ_θ}(f_ρ) ≤ K = π²d²/2` drops in expectation by `E_π L_i` per query
  (certified identity `Phi_sum`).
* Potential `H(π) ≤ ln M` drops in expectation by `I(θ; x_i | ρ)` per query (chain rule); both are
  supermartingales under every query.
* Stop when `Var_{ν_ρ}(f_ρ) ≤ τ`; Chebyshev at leaves; Markov on the stopping time.
* `E[#queries] ≤ K/g + ln M/g`, so depth `poly(d, log M, 1/ε, 1/δ)`.

**Checks the crux passes** (paper):
* Address function `f(x) = x_{addr(x_A)}` with components fixing the address: within-component
  increments are `M`-diluted, but each address bit has `I(θ; x_i) ≈ ln 2`. ✓
* Components `Bern(1/2 ± γ)^n`, `f` a degree-`d` amplifier of the average: `B ≲ d²γ²`,
  `I(θ; x_i) ≈ 2γ²`. ✓ (Near an endpoint, `I` is `Θ(γ)` by the χ² form, still fine.)
* Identical marginals at every coordinate force identical components, so `I ≡ 0` implies
  `M = 1` and the crux is product AA. ✓

## 4. A structural handle: exact latent lifting

Let `u_i ∈ U_i` be independent seeds and `h_i(θ, u_i)` a coupling with `h_i(θ, ·)_# λ_i = μ_{θ,i}`
for every `θ` (e.g. `u_i ∈ ∏_θ Σ_i` with `h_i(θ,u_i) = u_i[θ]`, or a consistent-sampling coupling).
Then on the **product** space `Θ × ∏_i U_i` with law `π ⊗ ⊗_i λ_i`:

* `G(θ, u) := f(h(θ, u))` has the law of `f` under `ν`, values in `[0,1]`, and interaction degree
  `≤ d + 1` (each `1[x_i = a] = ∑_{θ'} 1[θ = θ'] 1[h_i(θ', u_i) = a]` uses two coordinates). The
  coordinate `θ` has alphabet size `M`, which the certified product theorems allow at no cost.
* Mean increments of seed coordinates are exactly the posterior-averaged component increments:
  `L_{u_i}(G) = E_{θ∼π} L_i^{μ_θ}(f)`. So applying the certified product inequality
  (`mean_increment`) to `G` gives, **with no `M` loss**, either a seed coordinate with
  `E_π L_i^{μ_θ}(f) ≥ Var^{3/2}/(12 K_{d+1}²)` — the first alternative of the crux — or a large
  increment of the hidden coordinate `θ`.

So the crux reduces to: **a large `θ`-increment of `G` (under a good coupling) forces an
observable coordinate with large `I(θ; x_i)`.** With consistent sampling,
`Pr[h_i(θ,u) ≠ h_i(θ',u)] ≤ 2 TV(μ_{θ,i}, μ_{θ',i})` for all pairs simultaneously, and
`I(θ; x_i) ≥ c · E_{θ,θ'} TV(μ_{θ,i}, μ_{θ',i})²`, so what is missing is a *pointwise* fooling
bound `E|f(x) − f(x')| ≤ C(d) · poly(max_i Pr[x_i ≠ x'_i])` for coupled inputs differing
coordinatewise with small probability. The mean version of that bound is the certified
`fooling_tv`; the pointwise version is the open step.

## 5. Plan

1. **Falsify first.** Exhaustive/optimization search on small cases (`n ≤ 5`, `M ≤ 8`, `d ≤ 3`,
   rational masses including zeros) for the minimum of `max_i max(E_π L_i, I(θ; x_i))` over
   bounded degree-`d` `f` with `Var_ν(f) ≥ τ`. A ratio that degrades with `M` kills the target.
2. **Pointwise fooling lemma.** Try the selector/row machinery (`product_block_inequality`) on
   the coupled pair, or a hybrid argument with rows at both endpoints.
3. Only then Lean: the lifting is finite and exact; `Phi_sum`, `Sq_gain`, the tree and potentials
   are reusable; the entropy potential needs a finite chain rule.

## 6. Review notes on Theorem P (#917)

The four-step reduction checks out on paper:
* Step 1 kernel: marginal `q` exact; mismatch only at the anchor,
  `≤ (A−1)/(N p(a)) ≤ A(A−1)/N`.
* Step 2 seed kernel: `∑_x p(x) K(u|x) = 1/N` exact; zero atoms harmless.
* Step 4: hybrid `|f(x)−f(y)| ≤ 4 ∑_q (∑_{i: x_i≠y_i} w_{q,i}(x))^{1/2}`; Jensen with
  `x`-trajectory weights gives `E|f(X)−f(Y)| ≤ 4t√λ`; union bound; deterministic tape by averaging.
* BDST Theorem 1 (arXiv:2608.19158) is for uniform bits, with depth
  `2^{O(d²)} (t log(1/δ)/ε)^{O(d)}`. With `t' = 2mt`, `m = O(log(tA/(εδ)))` and `d' = 2d`, the
  transferred bound stays polylogarithmic in `1/δ` and `A` for fixed `d`.
* Items for the non-author reviewer: BDST's exact round/oracle model (parallel query layers on the
  standard XOR bit oracle) against Step 3's two-layer compilation, and that the depth function is
  monotone in `t` and `d`.
