# Finite Heterogeneous-Product Influence: Formal Source

**Status:** Scoped Lean kernel-compiled theorem **at a pinned commit**, not an end-to-end universal-product or quantum theorem. Non-author human mathematical review and originality audit are unrecorded.

**Canonical proof source:** [ProductInfluence.lean](../../research/nightfall/formalization/product_space/ProductInfluence.lean)  
**Full named proof passport:** [FINITE_PRODUCT_INFLUENCE_PROOF_PASSPORT_20261110.md](../../research/nightfall/formalization/product_space/FINITE_PRODUCT_INFLUENCE_PROOF_PASSPORT_20261110.md).

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
