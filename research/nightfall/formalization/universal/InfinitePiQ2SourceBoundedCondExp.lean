import InfinitePiQ2Density
import Mathlib.MeasureTheory.Function.ConditionalExpectation.Basic

/-!
# Actual-source finite-information conditional expectation preserves L∞ bounds

For every (even uncountably indexed) independent product law, the
integrable conditional expectation onto an arbitrary finite-coordinate
information sigma algebra retains the original essential absolute bound.
No positive atom floor, table representation, source-law substitution,
or assumed bound on a conditional fiber mean.

This proves the boundedness gate at the original-law L¹ conditional
expectation level. Identifying it with the original L² condExpL2
projection and every finite-label table entry is a separate obligation.
-/

namespace Nightfall.InfinitePiQ2SourceBoundedCondExp

open MeasureTheory
open Nightfall.InfinitePiQ2Density

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- A genuine source-product finite-information conditional expectation
is an L∞ contraction in the exact almost-everywhere sense. -/
theorem source_finite_information_condExp_essential_bound
    (F : Finset ι)
    (f : ((j : ι) → X j) → ℝ)
    (B : ℝ)
    (hf : Integrable f (Measure.infinitePi μ))
    (hbound : ∀ᵐ x ∂(Measure.infinitePi μ), |f x| ≤ B) :
    ∀ᵐ x ∂(Measure.infinitePi μ),
      |(Measure.infinitePi μ)[f | sourceFiniteCoordinateSigma (X := X) F] x| ≤ B := by
  let ν : Measure ((j : ι) → X j) := Measure.infinitePi μ
  let m := sourceFiniteCoordinateSigma (X := X) F
  have hm : m ≤ (inferInstance : MeasurableSpace ((j : ι) → X j)) :=
    sourceFiniteCoordinateSigma_le (X := X) F
  have hlow : (fun _ : ((j : ι) → X j) => -B) ≤ᵐ[ν] f := by
    filter_upwards [hbound] with x hx
    exact (abs_le.mp hx).1
  have hhigh : f ≤ᵐ[ν] (fun _ : ((j : ι) → X j) => B) := by
    filter_upwards [hbound] with x hx
    exact (abs_le.mp hx).2
  have hlowExp :
      ν[(fun _ : ((j : ι) → X j) => -B) | m] ≤ᵐ[ν] ν[f | m] :=
    condExp_mono (integrable_const (-B)) hf hlow
  have hhighExp :
      ν[f | m] ≤ᵐ[ν] ν[(fun _ : ((j : ι) → X j) => B) | m] :=
    condExp_mono hf (integrable_const B) hhigh
  have hlow' : (fun _ : ((j : ι) → X j) => -B) ≤ᵐ[ν] ν[f | m] := by
    simpa only [condExp_const hm] using hlowExp
  have hhigh' : ν[f | m] ≤ᵐ[ν] (fun _ : ((j : ι) → X j) => B) := by
    simpa only [condExp_const hm] using hhighExp
  filter_upwards [hlow', hhigh'] with x hL hU
  exact abs_le.mpr ⟨hL, hU⟩

#print axioms Nightfall.InfinitePiQ2SourceBoundedCondExp.source_finite_information_condExp_essential_bound

end Nightfall.InfinitePiQ2SourceBoundedCondExp
