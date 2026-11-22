import Mathlib
import MathlibExt.Geometry.Manifold.ParametricSard

/-!
# Euclidean parametric-Sard: existence of an actual regular parameter

The pinned external ATLAS theorem gives volume badParameterSet = 0
for a smooth Euclidean family F whose FULL derivative is surjective
on its zero set.

This module proves the missing selection implication: a regular
parameter actually exists, with its exact global slice-derivative
conclusion, by nonzeroness of Lebesgue volume.

It is a general reusable measure-to-regularity bridge, not a proof
that the augmented product-BU family satisfies the hypotheses.
It assumes no product-sphere topology theorem and introduces no
new axiom or sorry. Uses exact external source pinned separately.
-/

namespace Nightfall.ProductBURegularParameter

open MeasureTheory
open MathlibExt.Geometry.Manifold.ParametricSardWanted

theorem exists_regular_slice_of_global_surjectivity
    {p m n : ℕ}
    (F : EuclideanSpace ℝ (Fin p) × EuclideanSpace ℝ (Fin m) →
      EuclideanSpace ℝ (Fin n))
    (y : EuclideanSpace ℝ (Fin n))
    (hF : ContDiff ℝ (⊤ : ℕ∞) F)
    (hreg : ∀ a x, F (a, x) = y →
      Function.Surjective (fderiv ℝ F (a, x))) :
    ∃ a : EuclideanSpace ℝ (Fin p), ∀ x,
      F (a, x) = y →
      Function.Surjective (fderiv ℝ (fun z => F (a, z)) x) := by
  have hzero : volume (badParameterSet (F := F) (y := y)) = 0 :=
    parametricSard F y hF hreg
  have hnonzero :
      (volume : Measure (EuclideanSpace ℝ (Fin p))) ≠ 0 :=
    NeZero.ne _
  have huniv :
      volume (Set.univ : Set (EuclideanSpace ℝ (Fin p))) ≠ 0 :=
    Measure.measure_univ_ne_zero.mpr hnonzero
  have ⟨a, ha⟩ :
      ∃ a : EuclideanSpace ℝ (Fin p),
        a ∉ badParameterSet (F := F) (y := y) := by
    by_contra hn
    have hall : badParameterSet (F := F) (y := y) = Set.univ := by
      apply Set.eq_univ_of_forall
      intro a
      by_contra hx
      exact hn ⟨a, hx⟩
    apply huniv
    simpa [hall] using hzero
  refine ⟨a, ?_⟩
  intro x hx
  by_contra hcrit
  exact ha ⟨x, hx, hcrit⟩

#print exists_regular_slice_of_global_surjectivity
#print axioms exists_regular_slice_of_global_surjectivity

end Nightfall.ProductBURegularParameter
