# Row-degree 1 for subcube parities: reduction to a Sidon constant, and evidence it is linear in L (2026-11-20)

Status: Lemma S proved; the value of the Sidon constant is **conjectural** (exact for `L ≤ 2`,
searched for `L = 3`). Not reviewed. Scripts: `dichotomy_tests/sidon_lp.py`, `sidon_tensor.py`,
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
| 3 | 27 | ≥ 3.0, ≤ 13.98 | local search and an exact MILP (incumbent 3.0, not closed in 800 s); tensor-product patterns give only 2.625 |
| 4 | 81 | ≥ 2.525 | tensor-product patterns only (local search too slow at 65 536 constraints) |

**Correction (2026-11-20).** `L = 1, 2` fit **both** `3(L+1)/4` and `1.5^L`; only `L = 3` separates
them (`3.0` vs `3.375`). The best pattern found at `L = 3` gives `3.0`, but the exact MILP did not close
(dual bound `13.98`), so `L = 3` does **not** yet rule out exponential growth. Next: exact `K(3)` by
enumerating sign patterns up to symmetry (translations make the 8 point-rows positive, leaving
`2^19` patterns, further reduced by the `S_3^L ⋊ S_L` action).

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
