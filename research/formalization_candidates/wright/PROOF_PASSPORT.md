# Wright product-space influence — pinned finite Efron–Stein kernel receipt

**Status (2026-11-11):** strict Lean kernel certificate **PASS** for a *finite, heterogeneous-alphabet* theorem. **Do not claim** that Wright's stronger analytical constant, nonatomic product laws, arbitrary index sets, or the quadratic variance-exponent-two endpoint have been kernel-certified.

## Actual theorem

Source: `research/formalization_candidates/wright/HeterogeneousESDegreeEndpoint.lean`

```lean
Nightfall.ProductSpace.Heterogeneous.heterogeneous_es_influence
```

For a finite index type and coordinate-dependent finite nonempty alphabets `β i`, normalized nonnegative probability laws `q i` (zero masses allowed), a real function `F` with `|F| ≤ 1` on positive-probability inputs, Efron–Stein degree at most `d` in the support-preserving common-alphabet embedding (`DepESDegreeLE q F d`), and strictly positive variance `V=dvar q F`, the declaration produces an actual coordinate `j` such that

```
3 * V^5 ≤ 12500 * (Real.pi^2 * (d:ℝ)^2)^6 * (dinfl q F j)^2.
```

A second compiled declaration `depDegree_implies_depESDegree` shows that the already established dependent indicator-monomial degree hypothesis supplies this Efron–Stein degree condition; it is not an independent postulate about a supplied certificate. The Efron–Stein degree on heterogeneous alphabets is expressed by *all positive-support embeddings*, not a new native measure-theoretic conditional-expectation API.

The theorem uses the same `F`, `q`, variance, and resampling influences in its hypotheses and conclusion. No additional analytic inequality is assumed.

## Reproducible source-matched kernel receipt

- **Strict successful GitHub Actions run:** https://github.com/d3lefts/d3lefts/actions/runs/43143424439
- **Receipt artifact:** https://github.com/d3lefts/d3lefts/actions/runs/43143424439/artifacts/13910981581
- **Compiler:** `leanprover/lean4:v4.33.0`, via `.github/workflows/nightfall-wright-product-es-e2e.yml`
- **Pinned upstream:** `physical-superintelligence/aaronson-ambainis` commit `2a6ceaef872ae993708950f951989134084b851a`
- **Head SHA with the exact compiled source blob:** `d8685502ed7dce13ae961cc21149a69a77929a41`
- **New Lean source Git blob:** `5e13bffe4bbd5aeb7cdf3218863ed8f730244173`
- **Accepted axiom dependencies for both new declarations:** `Classical.choice`, `Quot.sound`, `propext`
- **Rejected by strict gate:** `sorryAx` and unauthorized custom axioms.

All five imported local sources `ProductSpaceTwoSidedBridge`, `ProductRowBound`, `ProductInfluence`, `EfronSteinDegree`, and `HeterogeneousAlphabets` were compiled in that same pinned upstream workspace before checking the endpoint. The source and exact pin hashes were archived in the receipt.

## Boundary to the full Wright manuscript theorem

The v6 manuscript asserts the stronger all-degree constant `cprod ≈ 0.001201250694`, whereas the finite formal source gives `c* = sqrt(3/12500)/pi^6 ≈ 1.6114e-5`, multiplying `Var(f)^(5/2)/d^6`. The stronger numerical coefficient is **not** derived from this Lean certificate.

Moreover this new declaration concerns **finite alphabets and finite index sets** only. PR #367 supplies a written analytic finite-to-arbitrary-measurable argument; its countably-active approximation, commuting conditional expectations, L² influence limit, and supremum-attainment steps must still be formalized in Lean before claiming the whole arbitrary-product theorem is kernel certified.

The degree-two optimal exponent-two extension is likewise separate and uncompiled at its full endpoint.

**Scientific grade:** certified construction for the exact finite-input theorem; full manuscript is partially certified only. Global originality and nonauthor review are separate.
