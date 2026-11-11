import EfronSteinDegree
import ProductInfluence

/-!
# NIGHTFALL: actual finite-product quadratic Hoeffding bridge

This module *imports* the previously kernel-checked Möbius
Hoeffding/Efron–Stein decomposition, rather than postulating
decomposition as a premise. It certifies pointwise truncation to
interaction supports of cardinality at most two on arbitrary finite
product alphabets with coordinate-dependent laws, including zero-mass
atoms.

This proves the real low-degree representation needed as the starting
point for the quadratic matching construction. It does not prove the
orthogonality/matching-cost/fourth-moment estimates or the final
dimension-independent variance-squared influence theorem.

Upstream: Nightfall.ProductSpace.EfronStein.es_decomp and
ESDegreeLE, merged PR #325; Lean v4.33.0 / pinned Turturean project.
-/

namespace Nightfall.Observability.QuadraticANOVA

open Finset
open Nightfall.ProductSpace.EfronStein

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Every genuine Hoeffding-degree-two function equals its exact
sum of empty, singleton and pair Efron–Stein components, pointwise,
under arbitrary normalized coordinate marginals. This theorem has
no extra decomposition premise: it imports the actual product-space
conditional expectation construction. -/
theorem quadratic_hoeffding_decomposition
    (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (x : ι → α) :
    f x = ∑ S : Finset ι,
      if S.card ≤ 2 then esComp p S f x else 0 := by
  calc
    f x = ∑ S : Finset ι, esComp p S f x :=
      (es_decomp p hp1 f x).symm
    _ = ∑ S : Finset ι,
      if S.card ≤ 2 then esComp p S f x else 0 := by
      apply Finset.sum_congr rfl
      intro S _
      by_cases hS : S.card ≤ 2
      · simp [hS]
      · have hlarge : 2 < S.card := by omega
        rw [hdegree S hlarge x]
        simp [hS]

/-- The quadratic pointwise decomposition is unchanged when written
as a sum over exactly the low-cardinality supports. -/
theorem quadratic_hoeffding_filter
    (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (x : ι → α) :
    f x = ∑ S ∈ (Finset.univ.filter
      (fun S : Finset ι => S.card ≤ 2)), esComp p S f x := by
  rw [quadratic_hoeffding_decomposition p hp1 f hdegree x]
  simp only [Finset.sum_filter]


/-!
## Complete finite arbitrary-law degree-two baseline — not the exponent-two endpoint

Unlike the certificate-composition algebra in QuadraticDiscoveryCore, the
declaration below has *only actual product-law, boundedness, and Hoeffding
degree hypotheses*.  It derives degree-two indicator representation from the
actual Efron–Stein decomposition and applies the existing imported pinned
Turturean-based product theorem.  No matching-cost or fourth-moment
certificate is passed in as a premise.

This is the established exponent-(5/2) **baseline**, NOT the desired
variance-squared, dimension-free quadratic improvement.
-/

/-- Actual degree-two, arbitrary-law product influence — honest unconditional
    normalized theorem.  Includes the variance-zero case and permits zero
    probability atoms.  The positive variance case has exponent five on
    variance and exponent two on influence; it does **not** establish the
    open final exponent-two influence endpoint. -/
theorem quadratic_actual_product_influence_e2e
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ)
    (hf : ∀ x, |f x| ≤ 1)
    (hdegree : ESDegreeLE p f 2) :
    Nightfall.ProductSpace.Influence.pvar p f = 0 ∨
    ∃ j : ι,
      3 * Nightfall.ProductSpace.Influence.pvar p f ^ 5 ≤
      12500 * (Real.pi ^ 2 * (2 : ℝ) ^ 2) ^ 6 *
        Nightfall.ProductSpace.Influence.pinfl p f j ^ 2 := by
  by_cases hV : 0 < Nightfall.ProductSpace.Influence.pvar p f
  · right
    exact Nightfall.ProductSpace.Influence.product_influence
      p hp hp1 2 f hf
      ((prodDegree_iff_esDegree p hp1 f 2).mpr hdegree) hV
  · left
    exact le_antisymm (le_of_not_gt hV)
      (Nightfall.ProductSpace.Influence.pvar_nonneg p hp f)

end Nightfall.Observability.QuadraticANOVA
