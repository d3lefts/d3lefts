# NIGHTFALL v8 — Specialist referee manuscript

**Author:** Devin J. Wright · **Date:** November 11, 2026 · **Length:** 32 pages (local pdfTeX build)

**Scope:** This is a complete analytic manuscript for expert review, not a worldwide-priority claim, a published arXiv paper, or an end-to-end Lean-certified theorem.

## Source and exact reproduction

The v8 LaTeX main file is `Bias_Free_Aaronson_Ambainis_All_Product_Spaces_v8.tex`; its two `\input` sources are `Rank_Optimal_Observation_Introduction_v8.tex` and `Rank_Optimal_Observation_Section_v8.tex`. The original v7 manuscript remains untouched for historical comparison.

From repository root:

```sh
sha256sum -c papers/finite-product-influence/SOURCE_SHA256SUMS_v8
python3 papers/finite-product-influence/check_v8_exact.py
python3 papers/finite-product-influence/check_rank_posterior_exact.py
cd papers/finite-product-influence
latexmk -pdf -interaction=nonstopmode -halt-on-error -file-line-error Bias_Free_Aaronson_Ambainis_All_Product_Spaces_v8.tex
```

Expected checker reports: `PASS v8_exact_models=225`, `PASS fixed_budget_spectral_regime=225`, `PASS binary_Grothendieck_polarization=1620`, and the exact audit digest `a3f067713ce7f87beb67accd506bbf610adeca2db1a84645f4a8806c4473cd5e`. The inherited v7 posterior/lower-bound checker reports 1638 and 384 cases with digest `5fc2d5221f4a27ad606beb948c27f278b4645761ac6b3bbeac4df0850703454b`. A separate direct finite table checker in the accompanying source package checks 225 more additive-filter instances; that checker is optional to the GitHub build.

## Quantitative changes from v7

| Item | v7 | v8 |
|---|---|---|
| Scalar arbitrary-alphabet degree 2, `V² <= K B² M` | `K=225(1+sqrt(3))² ≈ 1679.423` | `K=(10+2sqrt(2))²(1+sqrt(3))² ≈ 1228.356` |
| Rank-r quadratic, squared influence | `3K_old r B² M` | `3K r B² M` |
| Adaptive rank-r cap coefficient | `4(3K_old) ≈ 20153.07` | `12K ≈ 14740.28` |
| One-query scalar, arbitrary alphabets | `1680/(δ ε²)` | `1229/(δ ε²)` |
| One-query scalar, binary products | `<94/(δ ε²)` | `<51/(δ ε²)`, Grothendieck comparator |
| Adaptive rank-r, binary products | binary special case not optimized in v7 | `<610 r B²/η`, Grothendieck comparator |
| Fixed nonadaptive scalar when η exceeds quadratic energy δ₂ | not included | `ceil((3+2sqrt(2))B²/(η−δ₂))` |

V8 improves **constants**, not the optimal exponent or the all-degree theorem. Its optimized first-order oscillation estimate is an analytic deduction from a degree-two Markov noise polynomial and does not require any false independence or minimum-atom hypothesis. The new Grothendieck binary comparator is a classical-method consequence; **not independently novel**. The fixed-budget result is restricted to a specified spectral regime.

## Proof and priority boundaries

The original Boolean theorem and antipodal/weight-removal architecture are due to David Turturean. The categorical/nonatomic extension of the quadratic influence estimate is still subject to a specialist comparison with classical categorical bilinear Grothendieck inequalities. The stronger all-degree coefficient, full quadratic theorem, rank-adaptive result, and quantum corollaries lack end-to-end Lean certification and independent external non-author mathematical review. The pinned Lean theorem has a different, weaker coefficient and a finite model. The full two-draw/Fubini lift is analytic only.

Publication requires explicit author approval. The archive and CI check source integrity, mathematical examples and typesetting—not originality or complete proof validity. See `V8_PROOF_PASSPORT.md` for the theorem-by-theorem dependency and attack plan.
