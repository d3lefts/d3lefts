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
