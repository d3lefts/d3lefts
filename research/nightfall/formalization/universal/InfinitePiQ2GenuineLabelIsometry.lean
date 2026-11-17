import InfinitePiQ2OriginalLabelTransport
import Mathlib.MeasureTheory.Function.LpSpace.Basic
import Mathlib.Probability.ProductMeasure

/-!
# Original-source arbitrary-index L² label pullback is a genuine isometry

For an arbitrary (including uncountable) original product probability law
μ=Measure.infinitePi μ, the coordinatewise measurable label map carries μ
to the literal independent product of the ORIGINAL pushforward marginals.
Consequently its L² pullback is the Mathlib certified linear isometry
Lp.compMeasurePreservingₗᵢ, without any assumed comparison distribution,
moment identity, or isometry hypothesis. Its adjoint is the concrete
finite-information averaging candidate used by InfinitePiQ2AdjointTransfer.

Unlike a finite tagged-alphabet construction, no finite-atom or countability
assumption is present. This does not by itself prove the heat-bath
intertwining or terminal Q2 inequality.
-/

namespace Nightfall.InfinitePiQ2GenuineLabelIsometry

open MeasureTheory
open Nightfall.InfinitePiQ2OriginalLabelTransport

universe u v w
variable {ι : Type u} {X : ι → Type v} {Y : ι → Type w}
variable [∀ i, MeasurableSpace (X i)]
variable [∀ i, MeasurableSpace (Y i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- True original product source to its own original-marginal
label product is measure preserving, with no probability oracle. -/
theorem original_infinite_label_measurePreserving
    (φ : ∀ i, X i → Y i)
    (hφ : ∀ i, Measurable (φ i)) :
    MeasurePreserving (sourceLabelMap φ)
      (Measure.infinitePi μ)
      (Measure.infinitePi (fun i => (μ i).map (φ i))) := by
  exact ⟨sourceLabelMap_measurable φ hφ,
    sourceLabelLaw_exact μ φ hφ⟩

/-- True original L² label pullback, constructed from an independently
verified measure-preserving map, not passed in as an isometry premise. -/
noncomputable def original_infinite_label_lift
    (φ : ∀ i, X i → Y i)
    (hφ : ∀ i, Measurable (φ i)) :
    Lp ℝ (2 : ENNReal)
        (Measure.infinitePi (fun i => (μ i).map (φ i))) →ₗᵢ[ℝ]
      Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) := by
  letI : Fact (1 ≤ (2 : ENNReal)) := ⟨by norm_num⟩
  exact Lp.compMeasurePreservingₗᵢ ℝ (sourceLabelMap φ)
    (original_infinite_label_measurePreserving μ φ hφ)

/-- A native infinite-label L² table has precisely its original
Hilbert norm after pulling back to original source words. -/
theorem original_infinite_label_lift_norm
    (φ : ∀ i, X i → Y i)
    (hφ : ∀ i, Measurable (φ i))
    (g : Lp ℝ (2 : ENNReal)
        (Measure.infinitePi (fun i => (μ i).map (φ i)))) :
    ‖original_infinite_label_lift μ φ hφ g‖ = ‖g‖ := by
  exact (original_infinite_label_lift μ φ hφ).norm_map g

/-- The isometry is exactly the source label composition in the
almost-everywhere meaning required to compare true source condExpL2
with the finite-table heat-bath. -/
theorem original_infinite_label_lift_ae
    (φ : ∀ i, X i → Y i)
    (hφ : ∀ i, Measurable (φ i))
    (g : Lp ℝ (2 : ENNReal)
        (Measure.infinitePi (fun i => (μ i).map (φ i)))) :
    (↑(original_infinite_label_lift μ φ hφ g) :
      ((i : ι) → X i) → ℝ) =ᵐ[Measure.infinitePi μ]
        (fun x => g (sourceLabelMap φ x)) := by
  change (↑(Lp.compMeasurePreserving (sourceLabelMap φ)
      (original_infinite_label_measurePreserving μ φ hφ) g) :
      ((i : ι) → X i) → ℝ) =ᵐ[Measure.infinitePi μ]
        (fun x => g (sourceLabelMap φ x))
  simpa only [Function.comp_apply] using
    (Lp.coeFn_compMeasurePreserving g
      (original_infinite_label_measurePreserving μ φ hφ))

#print axioms Nightfall.InfinitePiQ2GenuineLabelIsometry.original_infinite_label_measurePreserving
#print axioms Nightfall.InfinitePiQ2GenuineLabelIsometry.original_infinite_label_lift_norm
#print axioms Nightfall.InfinitePiQ2GenuineLabelIsometry.original_infinite_label_lift_ae

end Nightfall.InfinitePiQ2GenuineLabelIsometry
