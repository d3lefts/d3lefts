import InfinitePiQ2AllL2LabelIntertwining

/-!
# Exact original-source influence of genuine finite-label pullbacks

The true original-product L² label pullback is isometric and intertwines
with both true source and original-pushforward label heat baths. Therefore
the Efron-Stein coordinate residual norm, and hence coordinate influence,
are exactly preserved by pulling a label observable back to the original
source. No finite-source weight oracle, source substitution or atom floor.
-/

namespace Nightfall.InfinitePiQ2SourceLabelExactInfluence

open MeasureTheory
open Nightfall.InfinitePiQ2InfluenceStability
open Nightfall.InfinitePiQ2OriginalLabelTransport
open Nightfall.InfinitePiQ2GenuineLabelIsometry
open Nightfall.InfinitePiQ2AllL2LabelIntertwining

universe u v w
variable {ι : Type u} {X : ι → Type v} {Y : ι → Type w}
variable [∀ i, MeasurableSpace (X i)] [∀ i, MeasurableSpace (Y i)]
variable [∀ i, MeasurableSingletonClass (Y i)]
variable [DecidableEq ι]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- Exact original-source/label coordinate residual norm equality
for every L² label observable under the original pushforward product. -/
theorem source_label_pullback_residual_norm_eq
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    (i : ι) [Fintype (Y i)] [DecidableEq (Y i)]
    (g : Lp ℝ (2 : ENNReal)
      (Measure.infinitePi (fun j => (μ j).map (φ j)))) :
    ‖sourceCoordinateResidual μ i
      (original_infinite_label_lift μ φ hφ g)‖ =
    ‖sourceCoordinateResidual
      (fun j => (μ j).map (φ j)) i g‖ := by
  let q : (j : ι) → Measure (Y j) := fun j => (μ j).map (φ j)
  let U := original_infinite_label_lift μ φ hφ
  have hI :=
    sourceOtherProjectionCLM_intertwines_all_L2 μ φ hφ i
  have hE : sourceOtherProjection μ i (U g) =
      U (sourceOtherProjection q i g) := by
    have h := congrArg
      (fun T : Lp ℝ (2 : ENNReal) (Measure.infinitePi q) →L[ℝ]
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) => T g) hI
    simpa only [ContinuousLinearMap.comp_apply,
      sourceOtherProjectionCLM_apply] using h
  have hsub : U (g - sourceOtherProjection q i g) =
      U g - U (sourceOtherProjection q i g) :=
    map_sub U g (sourceOtherProjection q i g)
  unfold sourceCoordinateResidual
  calc
    ‖U g - sourceOtherProjection μ i (U g)‖ =
        ‖U (g - sourceOtherProjection q i g)‖ := by
          rw [hE, hsub]
    _ = ‖g - sourceOtherProjection q i g‖ :=
      original_infinite_label_lift_norm μ φ hφ _

/-- Exact Efron-Stein coordinate influence equality, rather than
a mere inequality, under the true original-source label pullback. -/
theorem source_label_pullback_influence_eq
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    (i : ι) [Fintype (Y i)] [DecidableEq (Y i)]
    (g : Lp ℝ (2 : ENNReal)
      (Measure.infinitePi (fun j => (μ j).map (φ j)))) :
    sourceCoordinateInfluence μ i
      (original_infinite_label_lift μ φ hφ g) =
    sourceCoordinateInfluence (fun j => (μ j).map (φ j)) i g := by
  unfold sourceCoordinateInfluence
  rw [source_label_pullback_residual_norm_eq μ φ hφ i g]

#print axioms Nightfall.InfinitePiQ2SourceLabelExactInfluence.source_label_pullback_residual_norm_eq
#print axioms Nightfall.InfinitePiQ2SourceLabelExactInfluence.source_label_pullback_influence_eq

end Nightfall.InfinitePiQ2SourceLabelExactInfluence
