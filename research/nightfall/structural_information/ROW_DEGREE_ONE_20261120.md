# Row-degree 1 for subcube parities: reduction to a Sidon constant, and evidence it is linear in L (2026-11-20)

Status: Lemma S proved; the value of the Sidon constant is **conjectural** (exact for `L ≤ 2`,
`L = 3`). Not reviewed. Scripts: `dichotomy_tests/sidon_lp.py`, `sidon_tensor.py`,
`flat_search.py`.

## The target

Step 1 of `INFLUENCE_ROUTE_20261119.md`: for bounded `F = c_0 + ∑_{g ∈ R} c_g χ_g` (`R` = subcube
characters of `{0,1}^L`, `F ∈ [0,1]`, or `|F| ≤ 1`), show `max_g c_g² ≥ poly(Var F / L)`. At row-degree 1,
`Inf_g = c_g²`, so this is (★) for `d = 1`.

## Lemma S (reduction to a Sidon-type constant)

Let `K(L) = sup { ∑_g |c_g| : |c_0 + ∑_g c_g χ_g| ≤ 1 everywhere }`. Then every such `F` with
`|F| ≤ 1` has `max_g c_g² ≥ (Var F)² / K(L)²`.

*Proof.* `Var F = ∑ c_g² ≤ max_g |c_g| · ∑_g |c_g| ≤ max_g |c_g| · K(L)`. ∎

`K(L)` is the Sidon constant of the subcube characters (with a free constant term), computable as
`max_σ` of a linear program. For independent characters it is 1 (the trivial Aaronson–Ambainis
degree-1 case); for a Bernstein–Vazirani subspace of dimension `k` it is `2^{k/2}`.

## Data

| L | rows | `K(L)` | how |
| --- | --- | --- | --- |
| 1 | 3 | 1.5 | exact (all sign patterns) |
| 2 | 9 | 2.25 | exact (all sign patterns) |
| 3 | 27 | **3.0** | exact: all 2^19 normalised sign patterns, reduced to 6 456 orbits, one LP each (`sidon_exact.py`, 66 s) |
| 4 | 81 | ≥ 2.525 | tensor-product patterns only (local search too slow at 65 536 constraints) |

**Correction and resolution (2026-11-20).** `L = 1, 2` fit both `3(L+1)/4` and `1.5^L`; only `L = 3`
separates them (`3.0` vs `3.375`). An earlier version of this note claimed the data ruled out the
exponential; that was wrong, since the `L = 3` value was then only a search lower bound (and the MILP
did not close: dual bound `13.98`). `sidon_exact.py` now computes `K(3)` exactly. Translations
`S ↦ S + a` multiply `σ_g` by `χ_g(a)`, and the 8 point rows are independent, so every pattern is
equivalent to one with all point signs `+` (`2^19` patterns). Cube automorphisms (48) and `G ↦ −G` cut
these to 6 456 orbits, each solved exactly by LP. Result: **`K(3) = 3.000`**, ruling out `1.5^L` at
`L = 3` and matching `3(L+1)/4`. The same code reproduces `K(2) = 2.25`. Growth beyond `L = 3` is still
unproved: `L = 4` has `2^65` normalised patterns.

**Conjecture S.** `K(L) = Θ(L)` (possibly exactly `3(L+1)/4`).

With Lemma S this gives (★) at row-degree 1 with `γ = Θ(τ²/L²) = Θ(τ² / log² m)`: polylogarithmic in
`m`, as the influence route needs.

**Flatness check.** The obstruction to (★) is a bounded function with *flat* coefficients and
constant variance (as Bernstein–Vazirani has). Searching sign patterns for the flattest function
`F = c_0 + t ∑ σ_g χ_g` gives best variance `0.56, 0.27, 0.10` for `L = 2, 3, 4`, decaying by roughly a
factor of 2.3 per level. No flat function of constant variance appears, consistent with
Proposition R (no flat subspace beyond dimension 2).

## What is proved unconditionally

Riesz products over families of rows that are independent and contain no other row in their span
give `∑_{g ∈ J} |c_g| ≤ 1` per family. The subcubes with a fixed free set and fixed parity of the
fixed part form such families, so `K(L) ≤ 2^{L+1} = 2m`, which is only polynomial in `m`. A
counting argument shows any cover by such families needs `≥ (3/2)^L` of them, so proving
Conjecture S needs a non-covering argument. The natural one is the mode recursion: fixing `S_1`
leaves a level-`(L−1)` instance in `S_0` with coefficients `c^0_g + c^*_g χ_g(S_1)`; averaging gives
`∑_g max(|c^0_g|, |c^*_g|) ≤ K(L−1)` (and the two symmetric versions). This currently loses a factor
3 per level; the data say the true loss is additive (`+3/4` per level).

## Relation to the other results

* `T = 1` is already settled by the additive-energy simulator (Theorem I, Proposition J). Row-degree 1
  is the first level of the influence route, which is the only route that can reach polynomial
  bounds for larger `T`.
* If Conjecture S fails exponentially, the influence route fails for subcubes already at `d = 1`,
  even though Theorem I simulates `T = 1`. That would show the two analytic simulators are
  complementary and a hybrid is needed.

## Next

1. Prove `K(L) ≤ K(L−1) + O(1)` from the mode recursion (the additive loss the data show).
2. Compute `K(4)` with a faster solver (column generation over the 65 536 constraints) to test `3.75`.
3. Then quotients (step 2 of the influence route).

## Extremal functions (2026-11-20, `dichotomy_tests/sidon_extremals.py`)

The optimal LP solutions for `L = 1, 2, 3` are **flat**: every nonzero coefficient is `±1/(2L)`, on
exactly `3L(L+1)/2` rows (3, 9, 18), so `∑|c| = 3(L+1)/4 = K(L)`. Their variance is exactly
`3(L+1)/(8L)` (`0.75, 0.5625, 0.5`) and their values lie in `{±1, ±1/L, 0}`-type sets (`L = 1`: `±1`;
`L = 2`: `−1, 0, 1`; `L = 3`: `±1, ±1/3`). `L = 1` is the AND gadget on the triple `{0, 1, *}`.

Consequences:

* **The `log² m` loss is real.** These functions have variance `≥ 3/8` and every coefficient squared
  equal to `1/(4L²)`. So no row-degree-1 influence inequality for subcubes can beat
  `max c² ≈ Var / L²`.
* **Lemma S is tight.** If `K(L) = 3(L+1)/4`, Lemma S gives `max c² ≥ Var²/K² = 1/(4(L+1)²)` at
  `Var = 3/8`, within a factor `(L+1)²/L²` of these examples.
* **Target for the proof.** Conjecture S says the flat family is optimal. A proof would most naturally
  be a dual certificate (a signed measure `λ` with `λ̂ = σ` on rows, `λ̂(0) = 0`, `‖λ‖₁ ≤ 3(L+1)/4`) for
  every sign pattern, built mode by mode. The naive three-part construction (one measure per first-mode
  type `0, 1, *`) gives `3 K(L−1)`; the data require the three parts to share mass so that each level
  adds `3/4`. An explicit flat family for all `L` would give the matching lower bound.

## Dual certificates and pattern structure (2026-11-20, `sidon_duals.py`, `sidon_freeset.py`)

`K(σ) = min { ‖λ‖₁ : λ̂(0) = 0, λ̂(g) = σ_g for all rows g }` (LP duality; `λ` a signed measure on `S`).
Exact optimal certificates:

* `L = 1`: `λ = δ_0 − u` (`u` uniform), norm 1.5. In general `δ_0 − u` certifies the all-`+` pattern
  with norm `< 2` for every `L`, so the all-`+` pattern never gives more than 2.
* `L = 2`: support 10 of 16 points, weights in `{1/8, 3/8}`, norm 2.25.
* `L = 3`: support 24 of 256 points, weights in `{1/40, 1/20, 1/8, 3/20, 1/5, 3/10, 13/40}`, norm 3.

**Patterns that depend only on the free set are not optimal.** Over all `2^7` such patterns at `L = 3`
the best is `2.8125 < 3` (`2.25` at `L = 2` is attained by one). So optimal patterns depend on the
fixed values too, and a certificate cannot be built from free-set bookkeeping alone.

**Why the obvious decompositions fail.** Splitting rows by free set `A` gives families of disjoint
cells whose test measures automatically vanish on rows not measurable with respect to the cells, but
they must also vanish on unions of cells that are subcubes; the only cheap way (parity classes of
cells) costs `2^{L+1}` families. Riesz-product covers need `≥ (3/2)^L` families. A proof of
Conjecture S must therefore share certificate mass across free sets, as the `L = 3` optimum does
(mixed weights on 24 points). No inductive pattern is visible yet in the `L = 2 → 3` certificates.

Status of Conjecture S: exact values `1.5, 2.25, 3.0` (`L = 1, 2, 3`); flat extremal family through
`L = 3`; **no proof of any polynomial upper bound** (best proved: `2m`).

## Resolution: Conjecture S is false — `K(L)` grows exponentially (2026-11-20)

**Theorem T.** `K(L) ≥ c · (3/2)^{L/2} = c · m^{0.2925}` with `c = 2^{-1/(2 ln 2)} / √(2 ln 2) ≈ 0.52`,
so `K(L) > 3(L+1)/4` for all `L ≥ 16` (e.g. `K(20) ≥ 29.7`). The exact values `1.5, 2.25, 3.0` for `L ≤ 3` were small-case
coincidences.

*Proof* (the standard "Sidon sets are proportionally independent" counting, made explicit).

1. **Sidon ⇒ subgaussian (Rudin).** For any signs `ε` on `R` there is a measure `μ_ε` with
   `μ̂_ε = ε` on `R` and `‖μ_ε‖ ≤ K(L)` (the dual of `K`). For `f` with spectrum in `R`,
   `f = μ_ε * (∑ ε_g ĉ_g χ_g)`, so `‖f‖_p ≤ K(L) ‖∑ ε_g ĉ_g χ_g‖_p` by Young. Averaging over random `ε`
   and applying Khintchine pointwise in `S` gives `‖f‖_p ≤ K(L) √p ‖f‖_2`.
2. **Counting.** Take `f = ∑_{g ∈ R} χ_g` and `p = 2q`. Then `‖f‖_2² = |R| = 3^L` and
   `E f^{2q} = ∑_v r_q(v)²`, where `r_q(v)` counts `q`-tuples of rows summing to `v`. Since
   `∑_v r_q(v) = |R|^q` over at most `2^m` vectors, Cauchy–Schwarz gives `E f^{2q} ≥ |R|^{2q}/2^m`.
3. Combining: `|R|^q ≤ 2^m (K √(2q))^{2q}`, i.e.
   `log₂ K ≥ ½ log₂|R| − m/(2q) − ½ log₂(2q)`. With `|R| = 3^L`, `m = 2^L`, `q = m ln 2` this is
   `log₂ K ≥ 0.2925 L − 0.96`. ∎

This is the quantitative form of the classical fact (Pisier's arithmetic characterization) that a
Sidon set in `F_2^n` with constant `S` has size `O(S² · rank)`. Subcube rows have `3^L` elements in
rank `2^L`, so their Sidon constant must be at least `(3/2)^{L/2}` up to lower-order factors.

## Consequences for the influence route

* **Lemma S gives only a polynomial-in-`m` bound.** `max c² ≥ Var²/K²` with `K ≥ m^{0.29}` loses a
  power of `m`, not of `log m`. Bounding `Σ|c|` cannot give a polylogarithmic row-degree-1 inequality.
* **(★) at row-degree 1 is not refuted.** A large Sidon constant does not by itself produce a
  bounded function with constant variance and uniformly small coefficients. The flat extremals through
  `L = 3` have variance `≈ 3/8`; whether constant-variance flat functions exist for large `L` is now the
  decisive question (option 3: a variance-based argument, or a construction refuting (★)).
* **`T = 1` is unaffected.** The additive-energy simulator (Theorem I, Proposition J) does not use `K`.

## Direct test of (★) at row-degree 1 with capped coefficients (2026-11-20, `boxed_flat.py`, `boxed_flat_cg.py`)

Question: if every `|c_g| ≤ t`, how much variance can a bounded `F` have? (A counterexample to (★) needs
constant variance with `t = m^{-Ω(1)}`.) For a sign pattern, maximise `∑ σ_g c_g` under `|F| ≤ 1` and
`0 ≤ σ_g c_g ≤ t` (exact LP; the cutting-plane version adds only violated points), then local search over
patterns to maximise the resulting variance.

| L | cap `t` | best variance found | `∑|c|` |
| --- | --- | --- | --- |
| 3 | 1/4 | 0.625 | 2.5 |
| 3 | 1/8 | 0.375 | 3.0 |
| 3 | 1/16 | 0.105 | 1.69 (all 27 rows at cap) |
| 3 | 1/32 | 0.026 | 0.84 (all 27 rows at cap) |
| 4 | 1/8 | 0.375 | 3.0 |
| 4 | 1/16 | 0.1875 | 3.0 |

At `L ≤ 4` the best variance found is `≈ t · ∑|c|` with `∑|c| ≤ 3`, i.e. `max c² ≳ (Var/3)²`: no
constant-variance flat function appears. Local search at `L = 4` does not exceed `∑|c| = 3`, so it has
not found `K(4)`'s true value either. Theorem T only forces exponential growth from about `L = 16`, so
**small cases cannot decide (★) at row-degree 1**; it needs an argument.

Status: (★) at row-degree 1 for subcubes is open. Bounding `∑|c|` cannot prove it (Theorem T); the
remaining options are a variance-based proof or a construction of constant-variance flat functions from
the high-order additive relations that drive Theorem T.
