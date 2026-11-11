# Product-Space Influence: Analytic Manuscript and Formal Source

**Status:** Scoped Lean kernel-compiled theorem **at a pinned commit**, not an end-to-end universal-product or quantum theorem. Non-author human mathematical review and originality audit are unrecorded.

**Canonical proof source:** [ProductInfluence.lean](../../research/nightfall/formalization/product_space/ProductInfluence.lean)  
**Full named proof passport:** [FINITE_PRODUCT_INFLUENCE_PROOF_PASSPORT_20261110.md](../../research/nightfall/formalization/product_space/FINITE_PRODUCT_INFLUENCE_PROOF_PASSPORT_20261110.md).


## Consolidated analytic manuscript (v7, not an end-to-end formal certificate)

The current **specialist-review manuscript source** is [Bias-Free Aaronson--Ambainis v7](Bias_Free_Aaronson_Ambainis_All_Product_Spaces_v7.tex). It inherits the full 26-page v6 all-degree proof, the scalar quadratic matching--fourth-moment proof and one-query consequence, and adds the separate [rank-optimal theorem statement](Rank_Optimal_Observation_Introduction_v7.tex) and [full Hilbert/posterior proof](Rank_Optimal_Observation_Section_v7.tex). The separate v6 source in PR #382 remains the direct historical baseline; v5 in PR #379 is superseded for publication drafting.

Compile from this directory with \`latexmk -pdf -interaction=nonstopmode -halt-on-error Bias_Free_Aaronson_Ambainis_All_Product_Spaces_v7.tex\`. The resulting PDF is a generated artifact, not a proof checker; source content is authoritative. A CI build may certify LaTeX compilability, not mathematical validity.

**Scope:** The all-degree product-law bound has variance exponent 5/2 and degree exponent 6. The stronger scalar quadratic estimate is \`Var(f)^2 <= 225(1+sqrt(3))^2 B^2 max_i I_i\`. For rank-r Hilbert output the separate analytic bound is \`Var(F)^2 <= 675(1+sqrt(3))^2 r B^2 max_i I_i\`, giving a finite-product adaptive hard cap \`ceil(2700(1+sqrt(3))^2 r B^2 / eta)\` to the covariance tail plus eta, with matching order. None of these sharper analytic statements is certified by the finite Lean theorem below.

**Release gates:** Specialist non-author verification of the all-degree transfer, quadratic matching and rank/posterior chains; scope-matched global prior-art review; current archive/site CI; and explicit author approval to submit to arXiv. Archival staging is not publication.

**Related restricted work:** The cubic top-degree-cover mechanism already appears in merged PR #335; PR #381 shares that core-averaging proof idea and offers a distinct sharp top-layer projection formula. PR #380 invalidates the direct independent-increment fourth-moment extension to general cubic overlaps. Do not count these as independent unrestricted-cubic solutions.

---

## Exact scope

Finite coordinates `iota`, common finite alphabet *type* `alpha`, heterogeneous nonnegative normalized marginal tables allowing zero-mass atoms, `|f|<=1`, and indicator-monomial product degree `<=d`. The named declaration

```lean
Nightfall.ProductSpace.Influence.product_influence
```

establishes an existential resampling-coordinate bound

```text
3 Var(f)^5 <= 12500 (pi^2 d^2)^6 I_j(f)^2
```

or coefficient `sqrt(3/12500)/pi^6`, **not** the stronger earlier manuscript coefficient. The imported level and antipodal proof infrastructure comes from David Turturean's independently authored Boolean-cube Aaronson–Ambainis work.

## Provenance

- Pinned NIGHTFALL checked source: `e67990dfc252b6ef9446c7b7c1a9ebf06e5c58eb`.
- Pinned upstream Turturean source: `2a6ceaef872ae993708950f951989134084b851a`.
- Lean `4.33.0` with the upstream pinned project.
- [Successful named theorem and axioms receipt](https://github.com/d3lefts/d3lefts/actions/runs/42929857470); `product_influence` reports only standard Lean axioms as documented.
- The previous failed attempt is preserved in the primary proof passport; do not substitute a later edited file for the checked SHA.

## Not proved by this source

- Arbitrary nonatomic or infinite products, including measurable-selection/null-set handling.
- The sharper `V^2` degree-two formula.
- Hilbert-rank adaptive observability, categorical minimax laws, or unrestricted cubic exponent two.
- Historical global originality, journal acceptance or external referee endorsement.

**First extension gate:** formal proof of Hoeffding-support degree ↔ indicator-product degree and independently reviewed finite-partition lift, then compose actual posterior rather than adding more abstract stopping inequalities.
