# The merging step: direct sums and local codes over balanced blocks (2026-11-19)

Status: Theorem F proved on paper (two-sided, polynomial losses). Not reviewed, no Lean. First
multi-scale step toward Conjecture E. Notation as in `LINEAR_DISTRIBUTIONS_20261119.md`.

## Definitions

For a row set `R` (a block):

* `d(R)` — minimum weight of a nonzero dependency `∑_{i∈A} g_i = 0` (`∞` if the rows are independent);
* `ρ(R)` — covering radius: the least `r` with `r·R = span(R)`;
* `R` is **`p`-balanced** (for a nondecreasing polynomial `p`) if `ρ(R) ≤ p(d(R))` whenever `d(R) < ∞`.

`R` is **`(c₀, c₀′)`-locally equivalent** to `R′` (both acting on the same `s`) if every row of `R` is
a sum of at most `c₀` rows of `R′` and every row of `R′` is a sum of at most `c₀′` rows of `R`.

Examples of balanced blocks: Bernstein–Vazirani (`d = 3`, `ρ = 1`); dual BCH and Gold/APN graphs
(`d = 2t + 1`, `ρ = 2t − 1`); independent rows (`d = ∞`). Not balanced, but locally equivalent to
a direct sum of balanced blocks: repeated rows (`c₀ = c₀′ = 1` to single-row blocks) and any local
code of a product.

## Theorem F

Let `R′ = R_1 ⊕ ⋯ ⊕ R_q` (blocks acting on independent parts of `s`) with every `R_j`
`p`-balanced, and let `R` be `(c₀, c₀′)`-locally equivalent to `R′`. For `T, ε, δ` put
`H = h(2c₀T, ε, δ) = poly(c₀T, 1/ε, log 1/δ)` (the smoothing degree of Theorem A) and

    k* = max { rank R_j : d(R_j) ≤ H }      (k* = 0 if every block has d(R_j) > H).

1. **Simulation.** Every `T`-query quantum algorithm on `ν_G` (rows `R`) has an `(ε, δ)`-simulation
   of depth `c₀′ · max(1, k*) · poly(c₀T, 1/ε, 1/δ)`.
2. **Advantage.** If `k* ≥ 1`, there is a quantum algorithm with `r = c₀′ · p(H)` queries computing a
   function that needs at least `k*/2 − O(1)` classical queries, even with arbitrary parity queries.

So, for every `T`, the advantage obtainable with `poly(T)` quantum queries is `k*` up to polynomial
factors in `T, c₀, c₀′, 1/ε, log 1/δ`: the size of the largest balanced block that has a dependency
short enough for `T`-query algorithms to see. **The number of blocks `q` and the total dimension
play no role.**

### Proof of 1 (merge dependent blocks into single symbols)

Call block `j` *dependent* if `d(R_j) ≤ H` and *independent* otherwise. Build a representation `x′` of
the input:

* for each dependent block, one symbol `σ_j = s^{(j)} ∈ F_2^{rank R_j}` (coordinates of `s` on that
  block in a basis of `span R_j`), alphabet size `2^{rank R_j}`;
* for each independent block, its row bits `⟨g, s⟩, g ∈ R_j`.

Quantum direction: a row of `R` is a sum of `≤ c₀` rows of `R′`; each row of `R′` is either a row bit
or a parity of one symbol, so one query to `x` costs `≤ 2c₀` queries to `x′` (compute–uncompute).
Classical direction: a symbol `σ_j` is determined by `rank R_j ≤ k*` independent rows of `R_j`, each a
sum of `≤ c₀′` rows of `R`, so `c′ ≤ c₀′ k*`; row bits of independent blocks cost `≤ c₀′`.

Law of `x′`: blocks are independent; symbols are uniform; inside an independent block any `≤ H`
row bits are independent and uniform because `d(R_j) > H`. A set of `≤ H` coordinates of `x′` therefore
has exactly the product (uniform) marginal. Theorem A, applied to the `2c₀T`-query compiled algorithm
with the uniform product law on these mixed alphabets, gives depth `poly(c₀T, 1/ε, 1/δ)` on `x′`.
This uses the **alphabet-free** product-space simulation: the merged symbols have alphabets of size
`2^{k*}`, and the certified bound does not depend on alphabet size. The representation transfer
theorem (`REPRESENTATIONS_AND_NECESSITY`, Theorem 1) multiplies by `c′ ≤ c₀′ max(1, k*)`. ∎

### Proof of 2

Take a dependent block `j*` with `rank R_{j*} = k*`. Balance gives
`ρ(R_{j*}) ≤ p(d(R_{j*})) ≤ p(H)`, so `V = span R_{j*}` (dimension `k*`) satisfies
`V ⊆ p(H)·R_{j*} ⊆ p(H)·R′ ⊆ c₀′p(H)·R`. Theorem C applies. ∎

## Why this is the merging step

Frames (`Λ_T`) only re-encode rows as short sums of an independent family, and need independence that
grows with the frame cost, which is circular when blocks of very different sizes coexist. Merging a
dependent block into **one large-alphabet symbol** costs nothing on the quantum side (`c = 1` per row)
and its full rank on the classical side, and it needs no independence at all inside the block. The
independence threshold then depends only on `T`, not on block sizes. This is where the alphabet-free
product theorem enters the linear theory.

## Coverage and limits

* Covered, two-sided: Bernstein–Vazirani, dual BCH, Gold/APN graphs, repeated rows, local codes of
  products, and arbitrary direct sums and local re-encodings of these.
* Random rows `n = 2^{m^α}` are covered if they are `p`-balanced with `p` linear; both `d` and `ρ` are
  `Θ(m^{1−α})` heuristically (GV-type estimates), to be proved.
* Not covered: rank-one matrices (`d = 3`, `ρ = a`, unbounded ratio), which satisfy Conjecture E
  anyway via Flanders' theorem. This is the model case for the next multi-scale step: blocks that
  are neither balanced nor direct sums, whose short sums contain large but proper subspaces.

## Next

1. Generalize from direct sums to **towers**: a block whose dependency structure is balanced only
   after quotienting by a subspace found at a smaller scale (rank-one: fix the row space of `x`).
2. A merging procedure for general `R`: repeatedly find the largest subspace `V` inside short sums
   (Theorem C side), merge it into a symbol, quotient, and recurse; the depth of the recursion is the
   multi-scale parameter, and PFR should bound it when doubling is small.
