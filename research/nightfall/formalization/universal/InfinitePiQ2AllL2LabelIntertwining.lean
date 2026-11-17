import InfinitePiQ2SourceLabelLpIntertwining
import Mathlib.MeasureTheory.Function.SimpleFuncDenseLp
import Mathlib.Analysis.InnerProductSpace.Adjoint

/-!
# Actual original-product L² source/table heat-bath intertwining

This is the continuous-linear upgrade of the exact bounded original
source/table L² intertwining, using Mathlib's genuine density of simple
functions in L². It is NOT an assumed hintertwine premise.

All source and label laws remain the original infinite products. A
finite label alphabet is required only at the selected coordinate.
-/

namespace Nightfall.InfinitePiQ2AllL2LabelIntertwining

open MeasureTheory
open Nightfall.InfinitePiQ2InfluenceStability
open Nightfall.InfinitePiQ2OriginalLabelTransport
open Nightfall.InfinitePiQ2GenuineLabelIsometry
open Nightfall.InfinitePiQ2SourceLabelLpIntertwining

universe u v w
variable {ι : Type u} {X : ι → Type v} {Y : ι → Type w}
variable [∀ i, MeasurableSpace (X i)] [∀ i, MeasurableSpace (Y i)]
variable [∀ i, MeasurableSingletonClass (Y i)]
variable [DecidableEq ι]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- Genuine source heat-bath as a continuous linear Hilbert operator.
This is exactly Mathlib's orthogonal projection onto the actual
source-other-coordinate sigma algebra. -/
noncomputable def sourceOtherProjectionCLM (i : ι) :
    Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) →L[ℝ]
      Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) :=
  (lpMeas ℝ ℝ (sourceOtherSigma (X := X) i)
    (2 : ENNReal) (Measure.infinitePi μ)).subtypeL ∘L
      condExpL2 ℝ ℝ (sourceOtherSigma_le (X := X) i)

theorem sourceOtherProjectionCLM_apply
    (i : ι) (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    sourceOtherProjectionCLM μ i f = sourceOtherProjection μ i f := by
  rfl

/-- The genuine source Hilbert heat-bath intertwines with the true
source-to-label L² isometry on ALL L² vectors, not only bounded
representatives. Simple functions are dense; continuity removes
the boundedness hypothesis without changing source law. -/
theorem sourceOtherProjectionCLM_intertwines_all_L2
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    (i : ι) [Fintype (Y i)] [DecidableEq (Y i)] :
    sourceOtherProjectionCLM μ i ∘L
        (original_infinite_label_lift μ φ hφ).toContinuousLinearMap =
      (original_infinite_label_lift μ φ hφ).toContinuousLinearMap ∘L
        sourceOtherProjectionCLM
          (fun j => (μ j).map (φ j)) i := by
  let q : (j : ι) → Measure (Y j) := fun j => (μ j).map (φ j)
  let U := original_infinite_label_lift μ φ hφ
  have hfun :
      (fun g : Lp ℝ (2 : ENNReal) (Measure.infinitePi q) =>
        (sourceOtherProjectionCLM μ i ∘L U.toContinuousLinearMap) g) =
      (fun g : Lp ℝ (2 : ENNReal) (Measure.infinitePi q) =>
        (U.toContinuousLinearMap ∘L sourceOtherProjectionCLM q i) g) := by
    apply (Lp.simpleFunc.denseRange (E := ℝ) (p := (2 : ENNReal))
      (μ := Measure.infinitePi q) (by norm_num)).equalizer
      (ContinuousLinearMap.continuous _)
      (ContinuousLinearMap.continuous _)
    funext fs
    let g : SimpleFunc ((j : ι) → Y j) ℝ :=
      Lp.simpleFunc.toSimpleFunc fs
    have hg : Measurable (g : ((j : ι) → Y j) → ℝ) :=
      Lp.simpleFunc.measurable fs
    have hg2 : MemLp (g : ((j : ι) → Y j) → ℝ)
        (2 : ENNReal) (Measure.infinitePi q) :=
      Lp.simpleFunc.memLp fs
    have hrep : hg2.toLp (g : ((j : ι) → Y j) → ℝ) =
        (fs : Lp ℝ (2 : ENNReal) (Measure.infinitePi q)) := by
      have ht := Lp.simpleFunc.toLp_toSimpleFunc fs
      exact congrArg
        (fun z : Lp.simpleFunc ℝ (2 : ENNReal) (Measure.infinitePi q) =>
          (z : Lp ℝ (2 : ENNReal) (Measure.infinitePi q))) ht
    obtain ⟨C, hC⟩ := g.exists_forall_norm_le
    let B : ℝ := max C 0
    have hB : 0 ≤ B := le_max_right C 0
    have hbound : ∀ y, |g y| ≤ B := by
      intro y
      have hc := (hC y).trans (le_max_left C 0)
      simpa only [Real.norm_eq_abs] using hc
    have hlift2 : MemLp
        (fun x => g (sourceLabelMap φ x)) (2 : ENNReal)
        (Measure.infinitePi μ) := by
      apply MemLp.of_bound
        (hg.comp (sourceLabelMap_measurable φ hφ)).aestronglyMeasurable B
      exact Filter.Eventually.of_forall (fun x => by
        simpa only [Real.norm_eq_abs] using hbound (sourceLabelMap φ x))
    have hstep :=
      sourceOtherProjection_lift_intertwines_bounded_Lp μ φ hφ
        (g : ((j : ι) → Y j) → ℝ) hg B hB hbound i hg2 hlift2
    have hgoal :
        sourceOtherProjection μ i
          (U (fs : Lp ℝ (2 : ENNReal) (Measure.infinitePi q))) =
        U (sourceOtherProjection q i
          (fs : Lp ℝ (2 : ENNReal) (Measure.infinitePi q))) := by
      rw [← hrep]
      exact hstep
    simpa only [ContinuousLinearMap.comp_apply,
      sourceOtherProjectionCLM_apply] using hgoal
  apply ContinuousLinearMap.ext
  intro f
  exact congrFun hfun f

#print axioms Nightfall.InfinitePiQ2AllL2LabelIntertwining.sourceOtherProjectionCLM_apply
#print axioms Nightfall.InfinitePiQ2AllL2LabelIntertwining.sourceOtherProjectionCLM_intertwines_all_L2

end Nightfall.InfinitePiQ2AllL2LabelIntertwining
