# Finite-product bias-independent influence theorem — proof passport

**Checkpoint:** 10 November 2026 ET / 11 November 2026 UTC  
**Status:** **LEAN KERNEL-COMPILED FINITE THEOREM** at an immutable source commit; no external human referee, no globally original priority finding, and **no arbitrary measurable/infinite product lift** certified here.

## Exact verified claim

For a finite coordinate type `ι`, a common finite alphabet type `α`, each normalized marginal table `p_i:α→ℝ` with `p_i(a)≥0` and `Σ_a p_i(a)=1`, let `f:(ι→α)→ℝ` satisfy `|f(x)|≤1` for every `x`. Assume `f` has **indicator-monomial product degree** at most `d` (`RowBound.HasProdDegreeLE f d`) and positive product variance `V=` `pvar p f >0`.

The verified Lean declaration

```lean
Nightfall.ProductSpace.Influence.product_influence
```

proves there exists a coordinate `j` with

```text
3 * V^5 <= 12500 * (pi^2 * d^2)^6 * I_j(f)^2
```

where `I_j(f)=(1/2) E[(f(X)-f(X^(j)))^2]` is the independent-resampling/Efron–Stein influence. Equivalently,

```text
max_j I_j(f) >= c_finite * V^(5/2) / d^6,
c_finite = sqrt(3/12500) / pi^6
         = 0.00001611411225376563... .
```

For the equivalent form with `d=0`, nonconstant `f` is impossible under the product-degree assumption. No lower bound on atom probabilities, no identical-distribution assumption, and no dependence on finite dimension or alphabet cardinality appears in the constant. **Zero-mass atoms are permitted.**

This is **not** yet a kernel-checked statement about arbitrary measurable coordinate spaces, infinitely or uncountably many coordinates, completed-product sigma-algebras or an end-to-end quantum algorithm. All coordinate alphabets in this exact declaration share one finite **type**; coordinate distributions can differ.

## Verification provenance

| Item | Frozen evidence |
|---|---|
| Merged PR | [#317](https://github.com/d3lefts/d3lefts/pull/317) |
| Exact checked PR head | `e67990dfc252b6ef9446c7b7c1a9ebf06e5c58eb` |
| Merge commit | `a626832fe99a4622db8334c74c488a40a8f17227` |
| Source file | [ProductInfluence.lean](ProductInfluence.lean), Git blob SHA `70f69d8caebfaef40efdf16bab63f223753c190f` |
| Full pinned source build and axiom receipt | [GitHub Actions run #42929857470](https://github.com/d3lefts/d3lefts/actions/runs/42929857470), job `130225552886`, **success** |
| Lean environment | `leanprover/lean4:v4.33.0`, pinned Turturean project commit `2a6ceaef872ae993708950f951989134084b851a` |
| Axiom audit | **19 named declarations compiled**; `product_influence` reports only `Classical.choice`, `Quot.sound`, `propext`; no `sorryAx`, no custom axioms |
| Other PR-head checks | All seven associated workflows **success**, including source-specific certificate-cost and website checks |

This is a **machine-checked theorem** with the hypotheses literally in the source. Its novelty has not been independently determined.

## Mechanism, sources and logical dependencies

1. **Product row construction:** [#310](https://github.com/d3lefts/d3lefts/pull/310) kernel-compiles the competing-symbol selector `RowBound.product_row_bound` with row cost at most `π²d²`, under the indicator-monomial degree representation.
2. **Weighted two-draw certificate transfer:** [#295](https://github.com/d3lefts/d3lefts/pull/295) and [#298](https://github.com/d3lefts/d3lefts/pull/298) supply finite-product reciprocal and localized inequalities without minimum-mass factors.
3. **Level-set integration, third moment and median:** `integrated_incr`, `third_moment`, `exists_median`, `variance_cube_le`, `mean_increment`, and related lemmas port the core strategy from **David Turturean**, [arXiv:2611.09773](https://arxiv.org/abs/2611.09773). The source imports Turturean's pinned `Level.Integral` and `TwoSided.CauchySchwarz` support.
4. **Averaging and influence extraction:** `pinfl_avg_le`, `rows_avg`, `exists_avg_set`, `influence_cost` yield `3V^5 ≤12500K^6 I_j^2`, then substitute `K=π²d²`.

Credit the antecedent techniques and the original Turturean theorem; NIGHTFALL's certified contribution is the explicit **finite-product transfer and composition** under heterogeneous marginal laws, subject to full dated prior-art comparison.

## Comparisons and unmoved proof gates

The existing public candidate manuscript proposes a **stronger constant** `c_prod≈0.001201250694` for arbitrary products. **That stronger constant is NOT the constant proved by `product_influence`.** The pinned Lean-checked coefficient is `c_finite≈0.00001611411225`; do not silently replace one with the other or promote a proposed inequality on the basis of the weaker formal receipt.

Remaining gates:

- Formal bridge between `HasProdDegreeLE` and a general Hoeffding/Efron–Stein degree statement, respecting null atoms.
- Independently audited finite-partition/conditional-projection passage to arbitrary coordinate alphabets and arbitrary index sets, including measurable versions and null-set handling.
- Verification of stronger manuscript constant and optional monotone/binary improvements under their precise hypotheses.
- End-to-end adaptive prediction, quantum whole-symbol query implication, and no-promise correlated input boundaries.
- Non-author specialist proof review and dated, direct source-to-source originality audit (including Turturean and later distributional and decision-tree proofs).

## Reproduction and failure boundary

Open [the pinned source](https://github.com/d3lefts/d3lefts/blob/e67990dfc252b6ef9446c7b7c1a9ebf06e5c58eb/research/nightfall/formalization/product_space/ProductInfluence.lean) and [workflow](https://github.com/d3lefts/d3lefts/blob/e67990dfc252b6ef9446c7b7c1a9ebf06e5c58eb/.github/workflows/nightfall-product-influence.yml). The workflow fetches the exact upstream Turturean commit, compiles the complete module, requests each named declaration and invokes the standard-axiom checker. An earlier failed build at [run #42928872042](https://github.com/d3lefts/d3lefts/actions/runs/42928872042) is preserved: unsolved goals, timeout and `sorryAx` on the attempted compilation; it was superseded by the passing exact head above.

**Next decisive experiment:** formalize the finite-law `HasProdDegreeLE` ↔ ANOVA support-degree equivalence, then an independent measure-theoretic lifting lemma with finite-partition approximants and exact null-set controls. Do not count numerical counterexample searches as full proof.

## 11 November 2026 supplement — PR #325 supersedes two listed open finite gates

This original PR #317 proof receipt is unchanged for source-hash provenance, but its **common-alpha restriction no longer describes the strongest certified finite theorem**. Merged [PR #325](https://github.com/d3lefts/d3lefts/pull/325), pinned [Actions 42932085109](https://github.com/d3lefts/d3lefts/actions/runs/42932085109), proves `prodDegree_iff_esDegree` on finite tables and `heterogeneous_influence` with *dependent coordinate alphabets*, zero atoms, and a support-only bound on the real function. The original review gate about formalizing finite ANOVA equivalence is now CLOSED. The arbitrary measurable/infinite-product lift remains UNCHECKED. Classical Hoeffding/Efron–Stein algebra is a prior-art dependency and cannot be listed as a new mathematical discovery; see `docs/lean-certificate-provenance.json`.
