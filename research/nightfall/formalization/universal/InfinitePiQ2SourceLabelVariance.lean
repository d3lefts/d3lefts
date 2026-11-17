import InfinitePiQ2GenuineLabelIsometry
import InfinitePiQ2Density
import Mathlib.MeasureTheory.Integral.Bochner.Basic

/-!
# Genuine original-product L² variance invariance under finite-label pullback

The actual source label map transports the original infinite-product
probability law to the product of its true coordinate pushforward laws.
The genuine Hilbert pullback is a Mathlib linear isometry. It preserves
both the Hilbert norm and the ordinary mean exactly, so it preserves
the original source L² variance with no constant loss, atom floor,
source substitution, or countability requirement.

This is an independent source-to-label numerical interface used by
the final infinite-product Q2 terminal, not that terminal itself.
-/

namespace Nightfall.InfinitePiQ2SourceLabelVariance

open MeasureTheory
open Nightfall.InfinitePiQ2Density
open Nightfall.InfinitePiQ2GenuineLabelIsometry
open Nightfall.InfinitePiQ2OriginalLabelTransport

universe u v w
variable {ι : Type u} {X : ι → Type v} {Y : ι → Type w}
variable [∀ i, MeasurableSpace (X i)]
variable [∀ i, MeasurableSpace (Y i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- The genuine original infinite-product expectation is exactly the
original pushforward-label expectation for every L² label observable.
This is source law transport, not a parameterized expectation oracle. -/
theorem sourceLabelLift_mean_exact
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    (g : Lp ℝ (2 : ENNReal)
      (Measure.infinitePi (fun i => (μ i).map (φ i)))) :
    (∫ x, (original_infinite_label_lift μ φ hφ g) x
      ∂ Measure.infinitePi μ) =
      ∫ y, g y ∂ Measure.infinitePi (fun i => (μ i).map (φ i)) := by
  let q : (i : ι) → Measure (Y i) := fun i => (μ i).map (φ i)
  let m : ((i : ι) → X i) → ((i : ι) → Y i) := sourceLabelMap φ
  have hmp : MeasurePreserving m
      (Measure.infinitePi μ) (Measure.infinitePi q) :=
    original_infinite_label_measurePreserving μ φ hφ
  have hmeas : Measurable m :=
    sourceLabelMap_measurable φ hφ
  have hae :
      (↑(original_infinite_label_lift μ φ hφ g) :
        ((i : ι) → X i) → ℝ) =ᵐ[Measure.infinitePi μ]
        (fun x => g (m x)) :=
    original_infinite_label_lift_ae μ φ hφ g
  calc
    (∫ x, (original_infinite_label_lift μ φ hφ g) x
      ∂ Measure.infinitePi μ) =
        ∫ x, g (m x) ∂ Measure.infinitePi μ :=
      integral_congr_ae hae
    _ = ∫ y, g y ∂ (Measure.infinitePi μ).map m := by
      exact (integral_map hmeas.aemeasurable
        (Lp.aestronglyMeasurable g)).symm
    _ = ∫ y, g y ∂ Measure.infinitePi q := by
      rw [hmp.map_eq]

/-- The exact original-source variance of a true label pullback equals
the exact variance on the induced original-product pushforward-label
law. The proof uses only source mean transport and L² norm isometry. -/
theorem sourceLabelLift_variance_exact
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    (g : Lp ℝ (2 : ENNReal)
      (Measure.infinitePi (fun i => (μ i).map (φ i)))) :
    sourceL2Variance μ
      (original_infinite_label_lift μ φ hφ g) =
    sourceL2Variance
      (fun i => (μ i).map (φ i)) g := by
  have hnorm :
      ‖original_infinite_label_lift μ φ hφ g‖ = ‖g‖ :=
    original_infinite_label_lift_norm μ φ hφ g
  have hmean := sourceLabelLift_mean_exact μ φ hφ g
  unfold sourceL2Variance
  rw [hnorm, hmean]

#print axioms Nightfall.InfinitePiQ2SourceLabelVariance.sourceLabelLift_mean_exact
#print axioms Nightfall.InfinitePiQ2SourceLabelVariance.sourceLabelLift_variance_exact

end Nightfall.InfinitePiQ2SourceLabelVariance
