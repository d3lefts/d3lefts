import InfinitePiQ2InfluenceStability
import Mathlib

/-!
# Inactive finite-coordinate heat-bath identity for the actual product source

An index outside a finite coordinate support is absent from its
information σ-algebra. Consequently the genuine original-law L²
conditional expectation onto every other site fixes finite-cylinder
observables supported on that finite set.

This source-specific lemma handles the inactive-coordinate case of the
unconditional infinite-product Q2 finite-cell transfer, without assuming
a finite approximation, a heat-bath intertwining oracle, or bounds on
atom masses.
-/

namespace Nightfall.InfinitePiQ2InactiveSourceSigma

open MeasureTheory
open Nightfall.InfinitePiQ2Density
open Nightfall.InfinitePiQ2InfluenceStability

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- For i outside F, observing F is part of observing all coordinates
other than i, on the exact original arbitrary product measurable space. -/
theorem sourceFiniteCoordinateSigma_le_other_of_not_mem
    (F : Finset ι) (i : ι) (hi : i ∉ F) :
    sourceFiniteCoordinateSigma (X := X) F ≤
      sourceOtherSigma (X := X) i := by
  classical
  let incl : F → sourceOtherIndices i := fun j =>
    ⟨(j : ι), by
      change (j : ι) ≠ i
      intro he
      exact hi (he ▸ j.property)⟩
  let truncate : ((j : sourceOtherIndices i) → X j) →
      ((j : F) → X j) := fun y j => y (incl j)
  have hmeas : Measurable truncate := by
    change Measurable (fun (y : (j : sourceOtherIndices i) → X j)
      (j : F) => y (incl j))
    fun_prop
  unfold sourceFiniteCoordinateSigma sourceOtherSigma
  refine MeasurableSpace.comap_le_comap_of_eq_comp truncate hmeas ?_
  funext x j
  rfl

/-- Actual infinite-product heat-bath fixes every source cylinder
supported away from its refreshed coordinate. -/
theorem sourceOtherProjection_fixes_inactive_cylinder
    (F : Finset ι) (i : ι) (hi : i ∉ F)
    (S : Set ((j : F) → X j)) (hS : MeasurableSet S) (c : ℝ) :
    sourceOtherProjection μ i
      (sourceCylinderIndicator μ (cylinder F S)
        ((mem_measurableCylinders _).mpr ⟨F, S, hS, rfl⟩) c) =
    sourceCylinderIndicator μ (cylinder F S)
      ((mem_measurableCylinders _).mpr ⟨F, S, hS, rfl⟩) c := by
  have hsF :
      MeasurableSet[sourceFiniteCoordinateSigma (X := X) F]
        (cylinder F S) :=
    source_finite_info_cylinder_measurable (X := X) F S hS
  have hsOther :
      MeasurableSet[sourceOtherSigma (X := X) i]
        (cylinder F S) :=
    (sourceFiniteCoordinateSigma_le_other_of_not_mem
      (X := X) F i hi) _ hsF
  simpa only [sourceOtherProjection, sourceCylinderIndicator] using
    (condExpL2_indicator_of_measurable
      (sourceOtherSigma_le (X := X) i) hsOther
      (measure_ne_top (Measure.infinitePi μ) (cylinder F S)) c)

/-- The original-source coordinate residual of an inactive finite
cylinder is zero exactly, not just asymptotically. -/
theorem sourceCoordinateResidual_inactive_cylinder_zero
    (F : Finset ι) (i : ι) (hi : i ∉ F)
    (S : Set ((j : F) → X j)) (hS : MeasurableSet S) (c : ℝ) :
    sourceCoordinateResidual μ i
      (sourceCylinderIndicator μ (cylinder F S)
        ((mem_measurableCylinders _).mpr ⟨F, S, hS, rfl⟩) c) = 0 := by
  unfold sourceCoordinateResidual
  rw [sourceOtherProjection_fixes_inactive_cylinder μ F i hi S hS c]
  exact sub_self _

/-- An inactive coordinate has genuine original-product heat-bath influence
zero on every finite-cylinder generator, including zero-mass cells. -/
theorem sourceCoordinateInfluence_inactive_cylinder_zero
    (F : Finset ι) (i : ι) (hi : i ∉ F)
    (S : Set ((j : F) → X j)) (hS : MeasurableSet S) (c : ℝ) :
    sourceCoordinateInfluence μ i
      (sourceCylinderIndicator μ (cylinder F S)
        ((mem_measurableCylinders _).mpr ⟨F, S, hS, rfl⟩) c) = 0 := by
  unfold sourceCoordinateInfluence
  rw [sourceCoordinateResidual_inactive_cylinder_zero μ F i hi S hS c]
  simp

/-- The genuine L² projection onto a finite coordinate set is fixed by
refreshing an original-source site outside that set. This is the
unconditional inactive-index operator composition, for EVERY source L²
observable, not just cylinders. -/
theorem sourceOtherProjection_fixes_inactive_finiteProjection
    (F : Finset ι) (i : ι) (hi : i ∉ F)
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    sourceOtherProjection μ i
      (condExpL2 ℝ ℝ (sourceFiniteCoordinateSigma_le (X := X) F) f :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) =
      (condExpL2 ℝ ℝ (sourceFiniteCoordinateSigma_le (X := X) F) f :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) := by
  let g : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) :=
    (condExpL2 ℝ ℝ (sourceFiniteCoordinateSigma_le (X := X) F) f :
      Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
  have hsmall :
      AEStronglyMeasurable[sourceFiniteCoordinateSigma (X := X) F]
        (g : ((j : ι) → X j) → ℝ) (Measure.infinitePi μ) := by
    exact aestronglyMeasurable_condExpL2
      (sourceFiniteCoordinateSigma_le (X := X) F) f
  have hlarge :
      AEStronglyMeasurable[sourceOtherSigma (X := X) i]
        (g : ((j : ι) → X j) → ℝ) (Measure.infinitePi μ) := by
    exact hsmall.mono (sourceFiniteCoordinateSigma_le_other_of_not_mem
      (X := X) F i hi)
  have hmem : g ∈ lpMeas ℝ ℝ (sourceOtherSigma (X := X) i)
      (2 : ENNReal) (Measure.infinitePi μ) :=
    mem_lpMeas_iff_aestronglyMeasurable.mpr hlarge
  change
    (condExpL2 ℝ ℝ (sourceOtherSigma_le (X := X) i) g :
      Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) = g
  rw [condExpL2]
  haveI : Fact (sourceOtherSigma (X := X) i ≤
      (inferInstance : MeasurableSpace ((j : ι) → X j))) :=
    ⟨sourceOtherSigma_le (X := X) i⟩
  let gg : lpMeas ℝ ℝ (sourceOtherSigma (X := X) i)
      (2 : ENNReal) (Measure.infinitePi μ) := ⟨g, hmem⟩
  have h_coe_gg :
      (gg : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) = g := rfl
  have hfix := Submodule.orthogonalProjectionOnto_mem_subspace_eq_self gg
  rw [← h_coe_gg, hfix]

/-- The actual original infinite-product influence of an F-coordinate
conditional projection is identically zero at every coordinate outside F. -/
theorem sourceCoordinateInfluence_inactive_finiteProjection_zero
    (F : Finset ι) (i : ι) (hi : i ∉ F)
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    sourceCoordinateInfluence μ i
      (condExpL2 ℝ ℝ (sourceFiniteCoordinateSigma_le (X := X) F) f :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) = 0 := by
  unfold sourceCoordinateInfluence sourceCoordinateResidual
  rw [sourceOtherProjection_fixes_inactive_finiteProjection μ F i hi f]
  simp

#print axioms Nightfall.InfinitePiQ2InactiveSourceSigma.sourceOtherProjection_fixes_inactive_finiteProjection
#print axioms Nightfall.InfinitePiQ2InactiveSourceSigma.sourceCoordinateInfluence_inactive_finiteProjection_zero

#print axioms Nightfall.InfinitePiQ2InactiveSourceSigma.sourceFiniteCoordinateSigma_le_other_of_not_mem
#print axioms Nightfall.InfinitePiQ2InactiveSourceSigma.sourceOtherProjection_fixes_inactive_cylinder
#print axioms Nightfall.InfinitePiQ2InactiveSourceSigma.sourceCoordinateResidual_inactive_cylinder_zero
#print axioms Nightfall.InfinitePiQ2InactiveSourceSigma.sourceCoordinateInfluence_inactive_cylinder_zero

end Nightfall.InfinitePiQ2InactiveSourceSigma
