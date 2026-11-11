import EfronSteinDegree

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

end Nightfall.Observability.QuadraticANOVA
