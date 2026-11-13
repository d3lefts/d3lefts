# NIGHTFALL Q2 — finite source-to-terminal integration gate (2026-11-13)

**Status:** draft proof integration; **terminal theorem NOT machine certified**. This is a source audit of PR #422, PR #424 and PR #426. The only acceptable compilation receipt is the complete declaration printed below, with no extra budgets, amplitude caps, polynomial representation or oracle hypotheses.

## Proposed terminal Lean contract

```lean
-- target declaration (NOT currently compiled)
theorem actual_finite_quadratic_influence_q2
    {ι α : Type} [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α] [Nonempty α]
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (B : ℝ) (hB : 0 ≤ B)
    (hf : ∀ x, |f x| ≤ B)
    (hdegree : ESDegreeLE p f 2) :
    pvar p f = 0 ∨
      ∃ i : ι, (pvar p f)^2 ≤
        (256 * (1 + Real.sqrt 3)^2) * B^2 * pinfl p f i
```

If the reduced-strength constant is certified, replace it with
`(10+2*sqrt 2)^2*(1+sqrt 3)^2` **only after** separately certifying
the sharper additive noise/interpolation bound.

## Reusable accepted interfaces (check exact source SHA in receipts)

1. Actual quadratic mixed rectangles are background-independent: `ActualESQuadraticRectangles.actual_quadratic_rectangle_base_independent`.
2. Embedded arbitrary finite matching, unmatched sites held at a base: `ActualESGeneralMatching.actual_source_general_matching_amplitude_witness`; strict pass run 43482674865. Pointwise bound on a common alphabet.
3. Actual `ESDegreeLE` to 16B range and 8B source standard-deviation sections: `Q2AllDimensions.actual_degree_two_source_section_budget_eight_all`; strict pass 43360916112 at B=1.
4. Weighted graph matching `WeightedGreedyCover.matching_budget_to_endpoint_budget` assumes a **matching-mass premise**; it must receive a derived genuine-source result.
5. Independent Hilbert increments fourth moment/interpolation: `QuadraticActualMomentEndpoint.actual_product_fourth_endpoint`; genuine source increments conditional on amplitude/energy in `ActualESPairHilbertMoment.actual_source_pair_fourth_endpoint`.
6. New `ActualESMatchingFromGreedy` and `ActualESDistinctNeighborSections` in draft PR #426 (pending strict compilation).
7. Conditional expectation from true neighbor `Finset J_i`:
   `E[P_i(a,X)|X_{J_i}] = Y_i(a,X)` componentwise, no repeated synthetic coordinates.

## Outstanding exact gates

A. Apply the matching witness to every selected graph matching to derive `Σ_{e∈S} w_e ≤ 4B`, with one edge per unordered pair and weights defined on the positive-support product. Do not silently replace the support supremum by the full-alphabet supremum under almost-sure boundedness.

B. Construct the derived vertex cover, orient **each pair exactly once** and prove each owned-neighbor list has distinct coordinates. Prove `Σ_i c_i ≤ 8B`, `‖Y_{ij}(b)‖_i ≤ c_i`, without passing these as source-independent premises.

C. Prove exact joint source law / independent-neighbor moment identification, `s_i=Σ_{j∈J_i}‖h_ij‖²≤I_i≤M`, and `Σ_i s_i=Σ_{i<j}‖h_ij‖²`. Bounded synthetic increments alone are not enough.

D. Prove source-indexed **Hilbert** Jensen `z_i ≤ E‖P_i‖` via the true conditional-projection identity; the new generic finite vector Jensen lemma is a component, not the complete conditional theorem.

E. Join with the source 8B sections, `∑‖h_i‖≤8B`, fourth moment `s_i≤z_i(c_i+√(3M))`, and exact decomposition `V=∑‖h_i‖²+∑s_i`. Derive the displayed terminal theorem without extra hypotheses.

F. Once a common-alphabet finite theorem compiles, perform positive-support reduction and *heterogeneous coordinate-type* transport; then, separately, any measurable-product extension. They must not be claimed merely from finite support tests.

## Audit/stop rule

A successful CI on a **submodule** is never a terminal Q2 proof. Record exact declaration names, compiler/toolchain version, upstream git pin, source SHA-256, accepted axioms, and full dependent import closure. Strict compiler should reject `sorryAx`. Do not merge the current PRs or upgrade novelty status without review.
