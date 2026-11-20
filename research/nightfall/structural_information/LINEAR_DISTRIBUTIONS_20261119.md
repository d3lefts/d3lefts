# Linear distributions: the right measure is low-weight dependency, not span (2026-11-19)

Status: Theorem A and Theorem B proved on paper (Theorem A uses only the certified product simulation
and the smoothing step of Route 2); the two-sided statement is a conjecture. Not reviewed.

Setting: `s` uniform in `F_2^m`, rows `g_1, …, g_n ∈ F_2^m`, input `x_i = ⟨g_i, s⟩`. Write `R` for the
row multiset and `ν_G` for the law of `x`. The support of `ν_G` is the code `C = {Gs}`; `x` is
`k`-wise independent iff every nonempty set of at most `k` rows is linearly independent, i.e. iff the
dual code `C^⊥` has minimum distance `> k`.

## 1. Span is not the measure

"How much of `F_2^m` the rows span" cannot separate the cases: `m` independent rows (a product law,
no advantage), Bernstein–Vazirani (all `2^m` rows, advantage `Ω(m)` at `T = 1`) and a random code with
`n = Cm` rows (see below, no advantage) all span `F_2^m`. What differs is the **low-weight
dependencies** among rows: sets `A` with `∑_{i∈A} g_i = 0` and `|A|` small. A degree-`≤ 2T`
statistic of `x` sees exactly the dependencies of weight `≤ 2T`; a simulation tree of depth `D` and its
smoothing see weight up to `h = O(ε^{-4} log(1/δ) (2T + D))`.

## 2. Theorem A (h-wise independence inherits product simulation; any distribution)

Let `μ` be a product law and `ν` any law on the same finite product whose marginals on every set of
at most `h` coordinates equal those of `μ`, where `h = 2k_φ · max(2T, D)` with
`k_φ = ⌈(2/(9ε⁴)) ln(8/δ)⌉` and `D` the `(ε, δ/4)`-simulation depth for `μ`. Then the tree `τ`
that simulates a `T`-query algorithm `Q` on `μ` also simulates it on `ν`:
`Pr_ν[|τ − Q| ≥ 2ε] ≤ δ`.

*Proof.* `G = φ(Q − τ)` (the binomial-tail smoothing of Route 2) has values in `[0,1]` and
coordinate degree `≤ h`, so `E_ν G = E_μ G` because `G` is a combination of indicator monomials on
`≤ h` coordinates. As in Route 2, `E_μ G ≤ δ/4 + δ/8`, and
`Pr_ν[|Q − τ| ≥ 2ε] ≤ E_ν G / (1 − δ/8) < δ`. ∎

`D = poly(T, 1/ε, 1/δ)` by the certified product simulation, so `h = poly(T, 1/ε, 1/δ)`.

*Credit.* The distinguishing version (a `2k`-wise independent law fools `k`-query quantum distinguishers) is a standard consequence of the polynomial method; Theorem A is its pointwise-simulation strengthening. See `PRIOR_ART_LINEAR_20261119.md`.

**Consequence: random linear codes have no advantage.** For `n = Cm` random rows, `C^⊥` has
relative distance `Θ(1)` with high probability, so `ν_G` is `Θ(n)`-wise independent. For every
`T` with `h(T, ε, δ) ≤ cn`, simulation costs `poly(T, 1/ε, 1/δ)` independent of `m`. Yet every row lies
in a dependency, so dual total correlation is `m` and Wyner common information is `m`. This is a
second, cleaner instance of "information-heavy, computationally useless", and it covers more than the
random-function family of `REPRESENTATIONS_AND_NECESSITY`: exact `h`-wise independence needs no
averaging argument.

## 3. Theorem B (linear sufficiency through a local "basis")

Call `B ⊆ F_2^m` a **`(c, c′, h)`-frame** for `R` if

1. every row `g_i` is a sum of at most `c` elements of `B`,
2. every `b ∈ B` is a sum of at most `c′` rows, and
3. every nonempty set of at most `h` elements of `B` is linearly independent.

If `R` has a `(c, c′, h(2cT))`-frame, every `T`-query algorithm on `ν_G` has a simulation of depth
`c′ · poly(cT, 1/ε, 1/δ)`.

*Proof.* `x′_b = ⟨b, s⟩` is an `h`-wise independent family of uniform bits. `x_i` is a parity of
`≤ c` coordinates of `x′` (quantum direction), and each `x′_b` is a parity of `≤ c′` coordinates of `x`
(classical direction, deterministic). By Theorem 1 of `REPRESENTATIONS_AND_NECESSITY` the simulation
reduces to `2cT`-query algorithms on `x′`, and Theorem A handles those with the uniform product
simulator. ∎

Define `Λ_T(G) = min { c · c′ : R has a (c, c′, h(2cT))-frame }`; then simulation costs
`poly(T, Λ_T(G), 1/ε, 1/δ)`.

| Rows | Frame | `Λ_T` | True advantage |
| --- | --- | --- | --- |
| independent rows | `B = R` | 1 | none |
| each row repeated `k` times | `B` = distinct rows | 1 | none |
| random code, `n = Cm` | `B = R` (dual distance `Θ(n)`) | 1 | none |
| any rows with dual distance `> h` | `B = R` | 1 | none (Theorem A) |
| Bernstein–Vazirani, `R = F_2^m` | see below | large | `Ω(m)` at `T = 1` |

**Bernstein–Vazirani: `Λ_T = m` exactly.** Let `R = F_2^m` and let `B` be a `(c, c′, h)`-frame
with `h = h(2cT)`. If `|B| ≥ c + 1`, the sum `v` of any `c + 1` elements of `B` is a row, hence a sum
of at most `c` elements of `B` by condition 1. The two subsets have different sizes, so their
symmetric difference is a nonempty dependency of weight `≤ 2c + 1`. Condition 3 then needs
`h ≤ 2c + 1`, but `h(2cT) ≥ 4 k_φ c T > 2c + 1`. So `|B| ≤ c`. Since `B` spans `F_2^m` (every vector
is a sum of elements of `B`), `c ≥ |B| ≥ m`. Conversely the standard basis is a frame with
`c = m`, `c′ = 1` (basis vectors are rows) and no dependencies at all. Hence `Λ_T(F_2^m) = m`,
matching the true advantage `Ω(m)` at `T = 1` up to the polynomial.

## 4. Conjecture (two-sided characterization for linear distributions)

There are polynomials `p, q` such that for every row multiset `R` and every `T`:

* (sufficiency, proved) simulation cost `≤ p(T, Λ_T(G), 1/ε, 1/δ)`;
* (necessity, open) if `Λ_T(G) ≥ L` then some `q(T, log L)`-query quantum algorithm on `ν_G` needs
  `L^{Ω(1)}` classical queries.

The natural algorithms for necessity are Fourier sampling on the subspace generated by short sums of
rows: a large `Λ_T` should force a large subspace `V` whose characters are all reachable as sums of
`≤ 2T` rows, on which Bernstein–Vazirani can be run. This is the step to attempt next. If it holds,
linear distributions would be the first non-trivial class where quantum query advantage is
characterized exactly, by a linear-algebraic quantity.

## 5. Next steps

1. Necessity in a special case: rows with a frame lower bound coming from a large "short-sum
   closed" subspace. Show Bernstein–Vazirani embeds with `poly(T)` overhead.
2. Decide whether `Λ_T` must be relaxed to approximate frames (dual distance `> h` replaced by
   small bias of all `≤ h`-sums). Caution: Fourier Checking is almost `k`-wise independent yet has a
   quantum advantage (Aaronson), so any approximate version must pay for the number of degree-`h`
   monomials.
3. Check Simon's problem inputs and random sparse rows (LDPC-type `G`) against the table.
