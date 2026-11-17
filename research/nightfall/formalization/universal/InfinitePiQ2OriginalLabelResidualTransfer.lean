import InfinitePiQ2AllL2LabelIntertwining
import InfinitePiQ2RangeProjectionTransfer
import Mathlib.Analysis.InnerProductSpace.Adjoint

/-!
# Actual original-product finite-label projection influence and degree transfer

The genuine source/label all-L² heat-bath intertwining is derived in
InfinitePiQ2AllL2LabelIntertwining, not assumed here. We instantiate
the independently certified Hilbert-adjoint projection transfer with
the actual original product and its literal marginal pushforward law.
-/

namespace Nightfall.InfinitePiQ2OriginalLabelResidualTransfer

open MeasureTheory
open Nightfall.InfinitePiQ2InfluenceStability
open Nightfall.InfinitePiQ2OriginalLabelTransport
open Nightfall.InfinitePiQ2GenuineLabelIsometry
open Nightfall.InfinitePiQ2AllL2LabelIntertwining
open Nightfall.InfinitePiQ2AdjointTransfer
open Nightfall.InfinitePiQ2RangeProjectionTransfer

universe u v w
variable {ι : Type u} {X : ι → Type v} {Y : ι → Type w}
variable [∀ i, MeasurableSpace (X i)] [∀ i, MeasurableSpace (Y i)]
variable [∀ i, MeasurableSingletonClass (Y i)]
variable [DecidableEq ι]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- True source-other-coordinate Hilbert heat baths are self-adjoint.
The operator is the actual source condExpL2, not a postulated E. -/
theorem sourceOtherProjectionCLM_selfAdjoint (i : ι) :
    (sourceOtherProjectionCLM μ i).adjoint =
      sourceOtherProjectionCLM μ i := by
  haveI : Fact (sourceOtherSigma (X := X) i ≤
      (inferInstance : MeasurableSpace ((j : ι) → X j))) :=
    ⟨sourceOtherSigma_le (X := X) i⟩
  let K : Submodule ℝ
      (Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :=
    lpMeas ℝ ℝ (sourceOtherSigma (X := X) i)
      (2 : ENNReal) (Measure.infinitePi μ)
  change (K.starProjection).adjoint = K.starProjection
  exact ContinuousLinearMap.isSelfAdjoint_iff'.mp
    (isSelfAdjoint_starProjection K)

/-- Every genuine original-source coordinate residual is contracted
by orthogonal finite-label conditional averaging U U†. The constant
is exactly one, independent of source dimension or atom sizes. -/
theorem source_label_projection_residual_norm_le
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    (i : ι) [Fintype (Y i)] [DecidableEq (Y i)]
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    ‖sourceCoordinateResidual μ i
      (labelRangeProjection
        (original_infinite_label_lift μ φ hφ) f)‖ ≤
      ‖sourceCoordinateResidual μ i f‖ := by
  let q : (j : ι) → Measure (Y j) := fun j => (μ j).map (φ j)
  have hT : (sourceOtherProjectionCLM q i).adjoint =
      sourceOtherProjectionCLM q i :=
    sourceOtherProjectionCLM_selfAdjoint q i
  have hS : (sourceOtherProjectionCLM μ i).adjoint =
      sourceOtherProjectionCLM μ i :=
    sourceOtherProjectionCLM_selfAdjoint μ i
  have hI :=
    sourceOtherProjectionCLM_intertwines_all_L2 μ φ hφ i
  have hcontract :=
    labelRangeProjection_residual_norm_le
      (original_infinite_label_lift μ φ hφ)
      (sourceOtherProjectionCLM q i)
      (sourceOtherProjectionCLM μ i)
      hT hS hI f
  simpa only [residual, sourceCoordinateResidual,
    sourceOtherProjectionCLM_apply] using hcontract

/-- True original-product Efron-Stein L² degree at most two survives
finite-label conditional averaging, with no supplied intertwining
or finite-cell degree oracle. -/
theorem source_label_projection_triple_zero
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    [∀ i, Fintype (Y i)] [∀ i, DecidableEq (Y i)]
    (i j k : ι)
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (hf : sourceCoordinateResidual μ i
      (sourceCoordinateResidual μ j
        (sourceCoordinateResidual μ k f)) = 0) :
    sourceCoordinateResidual μ i
      (sourceCoordinateResidual μ j
        (sourceCoordinateResidual μ k
          (labelRangeProjection
            (original_infinite_label_lift μ φ hφ) f))) = 0 := by
  let q : (l : ι) → Measure (Y l) := fun l => (μ l).map (φ l)
  have hT : ∀ l, (sourceOtherProjectionCLM q l).adjoint =
      sourceOtherProjectionCLM q l :=
    fun l => sourceOtherProjectionCLM_selfAdjoint q l
  have hS : ∀ l, (sourceOtherProjectionCLM μ l).adjoint =
      sourceOtherProjectionCLM μ l :=
    fun l => sourceOtherProjectionCLM_selfAdjoint μ l
  have hI : ∀ l, sourceOtherProjectionCLM μ l ∘L
      (original_infinite_label_lift μ φ hφ).toContinuousLinearMap =
      (original_infinite_label_lift μ φ hφ).toContinuousLinearMap ∘L
        sourceOtherProjectionCLM q l :=
    fun l => sourceOtherProjectionCLM_intertwines_all_L2 μ φ hφ l
  have hf' : residual (sourceOtherProjectionCLM μ i)
      (residual (sourceOtherProjectionCLM μ j)
        (residual (sourceOtherProjectionCLM μ k) f)) = 0 := by
    simpa only [residual, sourceCoordinateResidual,
      sourceOtherProjectionCLM_apply] using hf
  have hdegree :=
    labelRangeProjection_triple_zero
      (original_infinite_label_lift μ φ hφ)
      (fun l => sourceOtherProjectionCLM q l)
      (fun l => sourceOtherProjectionCLM μ l)
      hT hS hI i j k f hf'
  simpa only [residual, sourceCoordinateResidual,
    sourceOtherProjectionCLM_apply] using hdegree

#print axioms Nightfall.InfinitePiQ2OriginalLabelResidualTransfer.sourceOtherProjectionCLM_selfAdjoint
#print axioms Nightfall.InfinitePiQ2OriginalLabelResidualTransfer.source_label_projection_residual_norm_le
#print axioms Nightfall.InfinitePiQ2OriginalLabelResidualTransfer.source_label_projection_triple_zero

end Nightfall.InfinitePiQ2OriginalLabelResidualTransfer
