# Classical simulation of quantum query algorithms, uniform over product distributions (2026-11-18)

## Update: sharper bound, Lean-certified

**Theorem** (`Simulation.simulation_degree` in `ProductSimulation.lean`, axioms `propext`,
`Classical.choice`, `Quot.sound` only). Let `p` be any product law on a finite `ι → α`
(any masses, zeros allowed) and `f : (ι → α) → [0, 1]` of interaction degree at most `d ≥ 1`.
If `n · ε³ δ² √δ ≥ 6√2 π⁶ d⁶`, there is a decision tree making at most `n` queries on every input
with `Pr_{x∼p}[ |f(x) − Q̃(x)| > ε ] ≤ δ`.

For a `T`-query quantum algorithm (`d = 2T`, §2 (A)) this is depth

    n = ⌈ 384 √2 π⁶ T⁶ / (ε³ δ^{5/2}) ⌉ ≈ 5.2 · 10⁵ · T⁶ ε⁻³ δ^{−5/2},

replacing the `T⁷ ε⁻⁵ δ^{−7/2}` bound of §§3–5 below. Still no dependence on the masses, the
alphabet or `n`.

**What changed.** The tree queries a coordinate with large *mean absolute increment*
`L_j(g) = E_{x, b∼p_j} |g(x) − g(x_j := b)|` instead of large Efron–Stein influence, and the
potential is the total `L(g) = ∑_k L_k(g)`:

* `L(g) ≤ K` when `g` has rows of cost `K` (`Influence.sum_pincr_le`); for `[0,1]`-valued `f`
  of degree `d`, `K = π² d² / 2` (`hasRows_of_degree`: Lemma B on `2f − 1`).
* Sections keep rows of the same cost (`hasRows_sect`), and fixing `x_j` lowers `L` on average by
  exactly `L_j` (`sum_mul_Ltot_sect`).
* A section with variance `> τ` has `L_j ≥ η` whenever `144 K⁴ η² ≤ τ³`
  (`Influence.mean_increment`: `Var³ ≤ 144 K⁴ L_j²`, Turturean's Theorem 7.10 on product spaces).
* So `η · E[#queries] ≤ L(f) ≤ K` (`expected_queries`), unfinished leaves need the full `n`
  queries (`bad_queries`), and finished leaves have error variance `≤ τ` (`leaf_error`).
* `simulation_rows`: `Pr[|f − Q̃| > ε] ≤ K / (η n) + τ / ε²`. With `τ = ε² δ / 2` and
  `η = τ^{3/2} / (12 K²)` this gives the theorem.

No boundedness or degree is used beyond the existence of rows, so `simulation_rows` holds for any
function with rows of cost `K` on any finite product law.

**Scope of the Lean statement.** One alphabet `α` for all coordinates. Different alphabets per
coordinate reduce to it by padding with zero-mass symbols; for a quantum algorithm the padded
oracle strings are still valid inputs, so `Q` stays in `[0, 1]` there. The quantum-to-polynomial
step (A) is on paper, not in Lean; the Lean theorem takes `f` of degree `≤ d` as its interface.

**Is it optimal?** Not known. `d = Θ(T)` and the row cost `K = Θ(d²)` is attained for degree-`d`
functions, so within this method the `T⁶` comes from `K³` in `mean_increment` and the potential.
Beating it needs a better increment inequality than `Var³ ≤ 144 K⁴ L_j²` or a different potential.
We know no lower bound matching `T⁶ ε⁻³ δ^{−5/2}`. The HMP bound `O(Q(f)⁶ / (εδ)²)` is for a
different task (computing a partial Boolean function on a dense domain, uniform cube only), so it
is not directly comparable.

---

The original paper proof follows. Its §§2(A)–(E) and §6 still apply; §§3–5 are superseded by the
update above.

## 1. Statement

**Setting.** Inputs `x = (x_1, …, x_n) ∈ Ω = Σ_1 × ⋯ × Σ_n`, with finite alphabets `Σ_i` (sizes
`k_i ≥ 2`, may differ), drawn from an arbitrary product law `μ = μ_1 ⊗ ⋯ ⊗ μ_n`. No lower bound on
the masses `μ_i(s)`; symbols of mass 0 are allowed.

**Query model.** Identify `Σ_i` with `ℤ_{k_i}`. A query is the unitary
`O_x |i, b, w⟩ = |i, b + x_i, w⟩` (index register `i`, answer register `b ∈ ℤ_{k_i}`, workspace
`w`). A `T`-query algorithm is `U_T O_x U_{T−1} ⋯ U_1 O_x U_0` applied to `|0⟩`, followed by a
measurement; `Q(x) ∈ [0, 1]` is its acceptance probability. Any oracle of the form
`O_x = ∑_{i,s} 1[x_i = s] · (|i⟩⟨i| ⊗ V_{i,s}) + P_0`, with `V_{i,s}` unitary and `P_0` acting off
the query subspace, works the same (phase oracles included).

**Theorem (uniform simulation).** Let `ε, δ ∈ (0, 1)` and `T ≥ 1`. For every product law `μ` on
`Ω` and every `T`-query algorithm with acceptance probability `Q`, there is a deterministic
classical decision tree `D` (depending on `Q` and `μ`) of depth at most

    D_max = ⌈ 2^{17/2} T^7 / (κ ε^5 δ^{7/2}) ⌉,   κ = 4√15 / (125 π^6) ≈ 1.29 · 10⁻⁴,

with output `Q̃(x) ∈ [0, 1]`, such that `Pr_{x∼μ} [ |Q̃(x) − Q(x)| > ε ] ≤ δ`.

Also, with depth at most `⌈ 2^{11} T^7 / (κ ε^6) ⌉`, `E_{x∼μ} |Q̃(x) − Q(x)| ≤ ε`.

**The point.** The depth bound depends only on `T`, `ε` and `δ`. It depends on neither the
alphabet sizes `k_i`, nor the masses `μ_i(s)`, nor `n`. For `p`-biased bits, Girish, Mittal,
Nehoran and Raz get a polynomial simulation whose overhead depends polynomially on
`1 / min(p, 1 − p)` (their Remark 3.4), so polynomially on `n` when `p = 1/n`. They do not treat
non-binary alphabets.

As in Aaronson–Ambainis and in GMNR, the classical algorithm knows `Q` and `μ` and is
computationally unbounded; only its query count is bounded.

## 2. Ingredients

Write `E`, `Var` for expectation and variance under `μ`. For `f : Ω → ℝ` and a coordinate `i`:

    Inf_i(f) = E_x [ Var_{x_i ∼ μ_i}( f | x_{−i} ) ] = ½ E_{x∼μ, b∼μ_i} ( f(x) − f(x_i := b) )²,

the Efron–Stein influence. This is `pinfl` in `ProductInfluence.lean` and the source-coordinate
influence of the infinite-product terminal. `I(f) = ∑_i Inf_i(f)` is the total influence.

**Degree.** `f` has degree at most `d` if it is a linear combination of indicator monomials
`∏_{i∈S} 1[x_i = τ_i]` with `|S| ≤ d` (`HasProdDegreeLE` / `DepDegreeLE` in Lean).

**(A) Algorithms are low degree.** `Q` has degree at most `2T`.
*Proof.* By induction on `t`, after `t` queries every amplitude, in the computational basis, is a
polynomial of degree at most `t` in the variables `y_{i,s} = 1[x_i = s]`. The `U_t` are
`x`-independent linear maps, so they preserve this. `O_x = ∑_{i,s} y_{i,s} (|i⟩⟨i| ⊗ V_{i,s}) + P_0`
is linear in the `y`. So each new amplitude is a linear combination of products `y_{i,s} · (degree
≤ t)`, which has degree `≤ t + 1`. The amplitudes are complex polynomials with real variables, so
`Q = ∑_{accepting basis states} |α|² = ∑ α ᾱ` has degree `≤ 2T`. Finally, a product of
indicators on the same coordinate is either `1[x_i = s]` (equal symbols) or `0`, so `Q` is a
combination of indicator monomials on at most `2T` distinct coordinates. ∎
(For bits this is Beals et al., Lemma 4.2; the indicator form for general alphabets is the same
argument.)

**(B) The influence inequality** (Lean-certified: `Influence.product_influence`,
`Heterogeneous.heterogeneous_influence`). If `|g| ≤ 1`, `g` has degree `≤ d`, and `Var(g) > 0`
under any product law on any finite alphabets (zero masses allowed), then some `j` has
`3 Var(g)^5 ≤ 12500 (π² d²)^6 Inf_j(g)²`.

*For `[0, 1]`-valued `f`*: apply (B) to `g = 2f − 1` (`|g| ≤ 1`, same degree,
`Var(g) = 4 Var(f)`, `Inf_j(g) = 4 Inf_j(f)`). Then
`3 · 4^5 Var(f)^5 ≤ 12500 π^{12} d^{12} · 16 Inf_j(f)²`, that is,

    Inf_j(f) ≥ κ Var(f)^{5/2} / d^6,   κ = 8 √(3/12500) / π^6 = 4√15 / (125 π^6).     (B′)

**(C) Total influence is at most degree times variance.** If `f` has degree `≤ d`, then
`I(f) ≤ d · Var(f)`.
*Proof.* Efron–Stein decomposition in `L²(μ)`: `f = ∑_{S ⊆ [n]} f_S`, orthogonal, with
`f_S` depending only on `x_S` and `E[f_S | x_{S′}] = 0` for `S ⊄ S′`. Then
`Inf_i(f) = ∑_{S ∋ i} ‖f_S‖²` and `Var(f) = ∑_{S ≠ ∅} ‖f_S‖²`. Degree `≤ d` in the indicator sense
gives `f_S = 0` for `|S| > d` (the projection of an indicator monomial on `T` has components only on
subsets of `T`; this is `prodDegree_iff_esDegree` in `EfronSteinDegree.lean`, and holds in
`L²(μ)` with zero masses too). So `I(f) = ∑_S |S| ‖f_S‖² ≤ d · Var(f)`. ∎

**(D) Restriction.** For a partial assignment `ρ` (values for a set `A` of coordinates, each of
positive mass), let `f_ρ` be `f` with `x_A := ρ`, a function on `∏_{i∉A} Σ_i` with law
`⊗_{i∉A} μ_i`. Then `f_ρ` takes values in the range of `f`, has degree `≤ deg f` (an indicator
monomial on `S` restricts to a constant times an indicator monomial on `S \ A`, or to 0), and
`Inf_i(f_ρ) = 0` for `i ∈ A`.

**(E) Influence is a martingale in the unqueried coordinates.** For `j ∉ A` and `i ∉ A ∪ {j}`,

    E_{b∼μ_j} [ Inf_i(f_{ρ, x_j = b}) ] = Inf_i(f_ρ),   and   Inf_j(f_{ρ, x_j = b}) = 0.

Hence `E_b [ I(f_{ρ, x_j = b}) ] = I(f_ρ) − Inf_j(f_ρ)`.
*Proof.* `Inf_i(f_ρ) = ½ E (f_ρ(x) − f_ρ(x_i := b′))²` with `x ∼ ⊗_{l∉A} μ_l`, `b′ ∼ μ_i`
independent. Split `x = (x_j, x_{−j})` and use Fubini for the product law: the inner expectation
with `x_j = b` fixed is `Inf_i(f_{ρ, x_j = b})`. ∎

## 3. The algorithm

Parameters `τ > 0` (variance threshold) and `D_max` (depth cap). On input `x`, starting from the
empty assignment `ρ`:

1. If `Var(Q_ρ) ≤ τ` or `|ρ| = D_max`: stop and output `m_ρ = E[Q_ρ]`.
2. Otherwise choose `j` with `Inf_j(Q_ρ) ≥ η := κ τ^{5/2} / (2T)^6` (it exists, see below), query
   `x_j`, extend `ρ` by `x_j`, and go to 1.

*Step 2 is well defined.* If `Var(Q_ρ) > τ`, then (B′) applied to `Q_ρ` (values in `[0, 1]`,
degree `≤ 2T` by (A), (D), product law on the remaining coordinates with arbitrary masses) gives
`j` with `Inf_j(Q_ρ) ≥ κ Var(Q_ρ)^{5/2} / (2T)^6 > η`. Since `Inf_i(Q_ρ) = 0` for queried `i`
(D), `j` is unqueried. Along a run on `x ∼ μ`, every queried value has positive mass almost
surely, so `Q_ρ` and its law are defined.

The output lies in `[0, 1]` and the algorithm makes at most `D_max` queries.

## 4. Query bound

Run the algorithm without the cap, on `x ∼ μ`; let `N ≤ n` be the number of queries and `ρ_t` the
assignment after `t` queries (`ρ_t = ρ_N` for `t ≥ N`). Put `Z_t = I(Q_{ρ_t}) ≥ 0`.

Conditioned on `ρ_t`, the unqueried coordinates are distributed as `⊗_{i∉A} μ_i` (product law).
So on `{t < N}`, by (E), `E[Z_{t+1} | ρ_t] = Z_t − Inf_{j_t}(Q_{ρ_t}) ≤ Z_t − η`, and on `{t ≥ N}`,
`Z_{t+1} = Z_t`. Taking expectations and summing over `t = 0, …, n − 1`:

    η · E[N] = η ∑_{t<n} Pr[N > t] ≤ Z_0 − E[Z_n] ≤ Z_0 = I(Q) ≤ 2T · Var(Q) ≤ T/2,

by (C) and `Var(Q) ≤ 1/4` for `[0, 1]`-valued `Q`. By Markov, `Pr[N > D_max] ≤ T / (2 η D_max)`.
The capped and uncapped runs agree on `{N ≤ D_max}`.

## 5. Error bound

On `{N ≤ D_max}` the run stops at a leaf `ρ` with `Var(Q_ρ) ≤ τ`, and outputs `m_ρ`. Conditioned
on reaching that leaf, `x_{−A}` is distributed as `⊗_{i∉A} μ_i`, so by Chebyshev
`Pr[ |Q(x) − m_ρ| > ε | leaf ρ ] ≤ τ / ε²`. Therefore

    Pr[ |Q̃(x) − Q(x)| > ε ] ≤ τ / ε² + T / (2 η D_max).

**High-probability form.** Take `τ = ε² δ / 2` and `D_max ≥ T / (η δ)`. Each term is at most
`δ/2`. With `η = κ τ^{5/2} / (64 T^6)`:

    T / (η δ) = 64 T^7 / (κ δ τ^{5/2}) = 64 · 2^{5/2} T^7 / (κ ε^5 δ^{7/2}) = 2^{17/2} T^7 / (κ ε^5 δ^{7/2}).

**Mean form.** On a stopped leaf, `E[ |Q − m_ρ| | leaf ] ≤ √τ`; elsewhere the error is at most 1.
So `E|Q̃ − Q| ≤ √τ + T / (2 η D_max)`. Take `τ = ε²/4` and `D_max ≥ T / (η ε)`:

    T / (η ε) = 64 T^7 / (κ ε τ^{5/2}) = 64 · 32 T^7 / (κ ε^6) = 2^{11} T^7 / (κ ε^6).  ∎

Numerically `2^{17/2}/κ ≈ 2.8 · 10⁶` and `2^{11}/κ ≈ 1.6 · 10⁷`. No attempt is made to optimize
constants or exponents.

## 6. What is new, and priority

* **New content:** the depth bound holds for every product law and every finite alphabet, with no
  dependence on the masses, the alphabet sizes or `n`. Ingredients (A), (C), (D), (E) are
  standard; the only non-standard input is (B), our Lean-certified inequality. The argument is the
  Aaronson–Ambainis decision-tree argument, with influences taken as Efron–Stein influences under
  `μ`.
* **Compared with GMNR (arXiv:2609.35327):** they prove polynomial simulation for `μ_p` and the
  slice for each fixed `p`, with overheads polynomial in `1 / min(p, 1 − p)` (Remark 3.4), binary
  only. The uniform statement removes that dependence and covers heterogeneous and non-binary
  product inputs.
* **Compared with HMP (arXiv:2611.12795):** their completion-framework proof gives a far better
  query bound on the uniform cube, `O(Q(f)^6 / (εδ)²)`. Our bound is weaker in exponents
  (`T^7 ε^{−5} δ^{−7/2}`). Our claim is uniformity over product laws, not the exponents.
* **Open priority questions, to check before claiming:**
  1. Whether the HMP completion/adversary argument already works, or is easily adapted, for
     arbitrary product distributions. If it is, it would likely give a better uniform bound and
     subsume this corollary. This is the main risk. First reading (2026-11-18, of the arXiv
     PDF, to be confirmed by a person): HMP state no result for biased, product or non-binary
     inputs, and their proof uses uniformity in several places — the swap symmetry of `(X, X^i)`
     in their Lemma 3, uniform counting of densities and subcubes in Lemma 4 and Theorem 2, and
     "resampling a uniform bit flips it with probability 1/2" in the appendix. Several of these
     steps look adaptable to product measures with weighted counting (OSSS itself holds for
     product measures), so the risk stands until someone attempts the adaptation.
  2. Whether GMNR or the limited-adaptivity paper arXiv:2608.20297 (which works with "dense
     distributions") contains a uniform-in-bias statement.
  3. Whether the k-ary indicator-polynomial form of (A) is stated in the literature, to cite
     instead of reproving.

## 7. Lean plan (not started)

1. `Q` as data: a degree-`≤ 2T` indicator expansion with values in `[0, 1]` (take (A) as the
   interface, or formalize the amplitude induction over finite-dimensional unitaries).
2. Restriction lemma (D) and the martingale identity (E) for `pinfl` / `dinfl`.
3. Total influence `≤ d · Var` (C) from `prodDegree_iff_esDegree`.
4. The decision tree as a recursive function on assignments; the potential argument (§4) as a
   finite telescoping sum (`N ≤ n`, no measure theory beyond finite sums).
5. Final statement with the explicit `D_max`, axioms `propext`, `Classical.choice`, `Quot.sound`.
