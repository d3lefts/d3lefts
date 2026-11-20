# Route 1: optimized exponents (2026-11-19)

Status: paper bookkeeping on top of `ROUTE1_PROOF_20261119.md` (unreviewed). No new mathematics
beyond swapping in the certified mean-increment inequality and optimizing the Key Lemma threshold.

## Result

Depth of the classical tree for a `T`-query algorithm (`d = 2T`) on a mixture of `M` product laws,
error `ε` except probability `δ`:

| | seed term | information term |
| --- | --- | --- |
| `ROUTE1_PROOF` | `T⁸ ε⁻⁵ δ^{-7/2}` | `T²⁴ ε⁻¹⁵ δ^{-17/2} log M` |
| **this note** | **`T⁶ ε⁻³ δ^{-5/2}`** | **`T¹⁸ ε⁻⁹ δ^{-11/2} log M`** |
| conditional on poly-cost fiber-uniform rows | `T⁶ ε⁻³ δ^{-5/2}` | `T¹² ε⁻⁶ δ⁻⁴ log M` |

For `M = 1` (one product law, any alphabets and masses) the bound is `O(T⁶ ε⁻³ δ^{-5/2})`; on the
uniform cube Huffstutler–Miloschewsky–Podder have `O(T⁶ / (εδ)²)` (arXiv:2611.12795).

## Change 1: mean increments instead of influences (exponent 5/2 → 3/2 in `τ`)

`ROUTE1_PROOF` step 7 applies `infinitePi_aa_product` (influence form, `Inf ≥ τ^{5/2}/D⁶` up to
constants) and converts to increments. Apply instead the certified mean-increment form
`ProductInfluence.mean_increment`: `Var³ ≤ 144 K⁴ L_j²`, i.e. some coordinate has
`L_j ≥ Var^{3/2}/(12 K²)`. On the lifted `G` (degree `d + 1`, `K_{d+1} = π²(d+1)²`):

    g := τ^{3/2} / (12 π⁴ (d+1)⁴).

The lift has continuous consistent-sampling seeds; apply `mean_increment` to a finite seed
discretization (the coupling error goes to 0) or prove the infinite-product mean-increment analogue of
`infinitePi_aa_product`. The potential argument is in increments already, so nothing else changes.

## Change 2: optimal threshold in the Key Lemma (constant only)

`E_θ E_u |f(h(θ,u)) − f(h̄(u))| ≤ A/η² + Bη` with `A = π⁴ d² I*/4`, `B = 8 d²`. The optimum
`η = (π⁴ I*/16)^{1/3}` gives `≤ 21.9 d² (I*)^{1/3}` (was `32.4 d²` at `η = (I*)^{1/3}`), so the
θ-increment of `G` is `≤ 43.8 d² (I*)^{1/3}`, and a θ-coordinate with increment `≥ g` forces
`I* ≥ (g / (43.8 d²))³`.

## Accounting

`Φ = E_π ∑_i L_i^{μ_θ} ≤ 4d²` (single-coordinate sensitivity, `product_block_inequality`; the `2d²`
in `ROUTE1_PROOF` is for the halved resampling convention), `H(π) ≤ ln M`. Expected number of queries

    E[N] ≤ 4d²/g + ln M · (43.8 d²/g)³
         = 48π⁴ d²(d+1)⁴ τ^{-3/2} + (525.6 π⁴)³ d⁶ (d+1)¹² τ^{-9/2} ln M.

Chebyshev at the leaves with `τ = ε²δ/2`, Markov with depth `2E[N]/δ`:
`O(d⁶ ε⁻³ δ^{-5/2} + d¹⁸ ε⁻⁹ δ^{-11/2} ln M)`. Mean-error form (`E|err| ≤ ε`, `τ = ε²/4`, depth
`4E[N]/ε`): `O(d⁶ ε⁻⁴ + d¹⁸ ε⁻¹⁰ ln M)`.

## Where the remaining loss is

* **Key Lemma exponent `1/3`.** `1/2` is the best possible: one coordinate, components
  `Bern(½ ± γ)`, `f = x_1` gives θ-increment `≍ γ` with `I ≍ γ²`. The `1/3` comes from charging
  large-angle coordinates by `Pr_θ[j ∈ L_θ]` instead of by their mismatch probability, which the
  rows cannot see without fiber-uniformity. Fiber-uniform rows of cost `C(d)` (in the averaged form
  that `ROUTE1_ATTEMPT`'s Lemma R needs; the pointwise categorical form has a degree-2
  counterexample, #923) would give `θ-increment ≤ 4C √(I*/2)` and the conditional row of the table.
* **`δ`.** Markov on the stopping time and Chebyshev at the leaves cost `δ^{-5/2}`; polylog`(1/δ)`
  needs the bounded-round route (Theorem P / BDST), not this argument.
* **Prior art.** A search (2026-11-19) found no improvement on Turturean's exponents
  (`Inf ≥ (√15/(500π⁴)) Var^{5/2}/d⁶`); HMP improve the uniform-cube simulation but their proof
  uses uniformity throughout (see `SIMULATION_COROLLARY_PAPER_PROOF_20261118.md` §6), so it does not
  transfer here.
