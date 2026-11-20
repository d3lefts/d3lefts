# Influence route for linear inputs: row-norm potential, reduction, and the subcube base case (2026-11-19)

Status: Lemma P and Theorem Q proved on paper; Proposition R proved (and checked exactly for
`L ≤ 5`, `dichotomy_tests/flat_subspaces.py`). The influence inequality (★) for subcube parities is
**open**. Not reviewed.

## Setting

`x = Gs`, `s` uniform in `F_2^m`, rows `R`. A `T`-query algorithm's acceptance probability, as a
function of `s`, is `F = ∑_v ĉ_v χ_v` with `v` ranging over `d·R`, `d = 2T`. After classical queries
to rows spanning `W`, `F` restricted to the consistent coset is a function on `F_2^m / W`: characters
in one class `κ = v + W` merge, with merged coefficient `c_κ` (signs fixed by the answers).

**Row norm.** `‖v‖_R` = least number of rows summing to `v`. On the quotient,
`‖κ‖ = min_{v ∈ κ} ‖v‖_R` (rows in `W` cost nothing).

**Row influence.** For a row `g ∉ W`: `Inf_g(F) = ∑_{κ : ‖κ + g‖ < ‖κ‖} c_κ²`, the variance carried by
characters from which `g` can be peeled off. For independent rows (a product law) `‖·‖` is Hamming
weight and `Inf_g` is the usual influence.

## Lemma P (the potential)

Let `Φ(F) = ∑_{κ ≠ 0} ‖κ‖ c_κ²`. Then `Var F ≤ Φ(F) ≤ d · Var F`, and querying a row `g` gives
`E[Φ after] ≤ Φ − Inf_g(F)`.

*Proof.* Conditioning on `⟨g, s⟩` merges `κ` with `κ + g`. The answer is a uniform bit independent of
the current coset structure, so the expected squared merged coefficient is `c_κ² + c_{κ+g}²` (cross
terms cancel), and the merged norm is `min(‖κ‖, ‖κ + g‖)`. Each pair therefore loses at least
`|‖κ‖ − ‖κ+g‖|` times the coefficient mass on its higher-norm member, which is `≥ 1` times `c_κ²`
whenever `‖κ + g‖ < ‖κ‖`. Norms are `≥ 1` on nonzero classes and `≤ d` on the initial support. ∎

## Theorem Q (reduction)

Suppose a family `𝓡` of row systems is closed under quotients by spans of rows and satisfies

> **(★)** for every `R ∈ 𝓡` and every `F: s ↦ [0,1]` with spectrum in `d·R` and `Var F ≥ τ`, some row
> has `Inf_g(F) ≥ γ(τ, d)`.

Then every `T`-query algorithm on a linear input with rows in `𝓡` has an `(ε, δ)`-simulation of depth
`≤ 2T / (δ · γ(ε²δ/2, 2T))`.

*Proof.* Query the row of largest influence while `Var > τ = ε²δ/2`; stop and output the conditional
mean. By Lemma P, `Φ` is a nonnegative supermartingale starting at `≤ 2T · 1/4` and losing `≥ γ` per
query in expectation, so `E[#queries] ≤ T / (2γ)`; Markov at `2T/(δγ)` and Chebyshev at the leaves
give total failure `≤ δ`. ∎

For product laws (`𝓡` = independent rows) (★) with `γ = poly(τ/d)` is exactly the Aaronson–Ambainis
inequality (Turturean; our product-space theorem), and Theorem Q is the Aaronson–Ambainis simulation.
So **the influence route for subcube parities is exactly: prove (★) for the subcube family and its
row quotients.**

## Necessary condition and the subcube base case

(★) fails whenever short sums contain a *flat* subspace: if `V ⊆ R ∪ {0}` has dimension `k`, a bent
function of the `V`-coordinates has all row influences `≤ 2^{-k}` while `Var = 1/4`. This is the
Bernstein–Vazirani obstruction, and it is why (★) can only hold for families with small subspace
numbers.

**Proposition R.** For subcube parities on `{0,1}^L`, the largest subspace inside `R ∪ {0}` has
dimension exactly 2, for every `L`.

*Proof.* The XOR of two subcubes `A ≠ B` is a subcube only if one is a half of the other or they are
the two halves of their union. So in a subspace `V ⊆ R ∪ {0}` any two nonzero elements have sizes
in ratio `1/2, 1` or `2`, hence at most two sizes `s, 2s` occur. Two elements of size `2s` would be
complementary halves of an element of size `4s`, so there is at most one, `D`. Any two elements of
size `s` are complementary halves of `D`, so there are at most two. Hence `|V ∖ 0| ≤ 3`. The cube with
its two halves attains 2. ∎ (Exact search confirms `N_1 = 2` for `L = 1, …, 5`.)

So at the base level subcube parities have **no** Bernstein–Vazirani structure: the only flat pieces
are halving triples, and on a direct sum of triples a bent function still has row influences `1/4`.
This is the first positive evidence for (★) on this family beyond `T = 1`.

## What remains for (★) on subcubes

1. **Row-degree 1** (`d = 1`): bounded `F = c_0 + ∑_{g ∈ R} c_g χ_g` with `∑ c_g² ≥ τ` should have
   `max c_g² ≥ poly(τ/L)`. For a product this is the trivial `∑|c_g| ≤ 1`; here sign alignment fails
   because rows are dependent. Proposition R plus additive multiplicity `μ = 2L + 2`
   (`ONE_QUERY_ENERGY`) are the inputs to try.
2. **Quotients.** Conditioning on queried subcube parities merges rows; (★) must survive this. The
   key question is whether quotients can create flat subspaces of growing dimension. Proposition R's
   argument should extend to quotients by few rows, with the size argument applied to classes.
3. **General `d`**, by induction on row-norm levels, mirroring the Aaronson–Ambainis proof structure
   (block inequality and row bound), with subcube halving playing the role of single-bit flips.
