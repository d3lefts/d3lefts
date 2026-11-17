import InfinitePiQ2RangeProjectionTransfer
import InfinitePiQ2GenuineLabelIsometry
import Mathlib.MeasureTheory.Function.L2Space
import Mathlib.MeasureTheory.Function.LpSpace.Indicator
import Mathlib.Analysis.InnerProductSpace.Adjoint

/-!
# Exact preservation of original-source means by finite-label averaging

The true original-product finite-label L² pullback U is a linear isometry.
Its range projection P=U U† preserves the inner product against every
lifted label vector. In particular the constant-one vector is in this
range, so the **actual original-product source integral** is preserved.

This removes the separate mean-preservation premise from future
applications of the corrected dense-label L² limit for genuine label
range projections. It does not assert their L² density or any Q2 bound.
-/

namespace Nightfall.InfinitePiQ2OriginalLabelMeanProjection

open MeasureTheory
open Nightfall.InfinitePiQ2RangeProjectionTransfer
open Nightfall.InfinitePiQ2GenuineLabelIsometry
open Nightfall.InfinitePiQ2OriginalLabelTransport

/-- Genuine orthogonal label averaging preserves every inner-product
functional against a vector in its label-pullback range. No assumed
projection idempotence, operator norm, or source law. -/
theorem labelRangeProjection_preserves_inner
    {H K : Type*}
    [NormedAddCommGroup H] [InnerProductSpace ℝ H] [CompleteSpace H]
    [NormedAddCommGroup K] [InnerProductSpace ℝ K] [CompleteSpace K]
    (U : H →ₗᵢ[ℝ] K) (f : K) (g : H) :
    ⟪U g, labelRangeProjection U f⟫_ℝ = ⟪U g, f⟫_ℝ := by
  calc
    ⟪U g, labelRangeProjection U f⟫_ℝ =
        ⟪labelRangeProjection U f, U g⟫_ℝ := real_inner_comm _ _
    _ = ⟪U.toContinuousLinearMap.adjoint f, g⟫_ℝ := by
      change ⟪U (U.toContinuousLinearMap.adjoint f), U g⟫_ℝ = _
      exact U.inner_map_map _ _
    _ = ⟪f, U g⟫_ℝ :=
      ContinuousLinearMap.adjoint_inner_left U.toContinuousLinearMap g f
    _ = ⟪U g, f⟫_ℝ := real_inner_comm _ _

universe u v w
variable {ι : Type u} {X : ι → Type v} {Y : ι → Type w}
variable [∀ i, MeasurableSpace (X i)] [∀ i, MeasurableSpace (Y i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- The original-source label pullback sends the constant-one L²
function under the exact pushforward-label product to the constant-one
L² function under the actual original infinite product. -/
theorem sourceLabelLift_one
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i)) :
    original_infinite_label_lift μ φ hφ
      (Lp.const (2 : ENNReal)
        (Measure.infinitePi (fun i => (μ i).map (φ i))) (1 : ℝ)) =
      Lp.const (2 : ENNReal) (Measure.infinitePi μ) (1 : ℝ) := by
  let q : (i : ι) → Measure (Y i) := fun i => (μ i).map (φ i)
  let hmp := original_infinite_label_measurePreserving μ φ hφ
  change
    Lp.compMeasurePreserving (sourceLabelMap φ) hmp
      (Lp.const (2 : ENNReal) (Measure.infinitePi q) (1 : ℝ)) =
    Lp.const (2 : ENNReal) (Measure.infinitePi μ) (1 : ℝ)
  simpa only [Lp.indicatorConstLp_univ, Set.preimage_univ] using
    (Lp.indicatorConstLp_compMeasurePreserving
      (p := (2 : ENNReal)) (μ := Measure.infinitePi μ)
      (μb := Measure.infinitePi q)
      (s := Set.univ) MeasurableSet.univ
      (measure_ne_top (Measure.infinitePi q) Set.univ)
      (1 : ℝ) hmp)

/-- The actual original-source finite-label orthogonal projection U U†
preserves the true source mean exactly, for any arbitrary product index,
finite/nonatomic source alphabets, and any coordinatewise measurable
label map. No finite-atom floor or caller-supplied mean identity. -/
theorem sourceLabelRangeProjection_preserves_mean
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    (∫ x, (labelRangeProjection
      (original_infinite_label_lift μ φ hφ) f) x
      ∂ Measure.infinitePi μ) =
      ∫ x, f x ∂ Measure.infinitePi μ := by
  let q : (i : ι) → Measure (Y i) := fun i => (μ i).map (φ i)
  let U := original_infinite_label_lift μ φ hφ
  let cq : Lp ℝ (2 : ENNReal) (Measure.infinitePi q) :=
    Lp.const (2 : ENNReal) (Measure.infinitePi q) (1 : ℝ)
  let cμ : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) :=
    Lp.const (2 : ENNReal) (Measure.infinitePi μ) (1 : ℝ)
  have hUc : U cq = cμ := sourceLabelLift_one μ φ hφ
  have hP :
      ⟪cμ, labelRangeProjection U f⟫_ℝ =
        (∫ x, (labelRangeProjection U f) x ∂ Measure.infinitePi μ) := by
    simpa only [cμ, Lp.indicatorConstLp_univ, MeasureTheory.setIntegral_univ] using
      (L2.inner_indicatorConstLp_one
        (MeasurableSet.univ : MeasurableSet (Set.univ : Set ((i : ι) → X i)))
        (measure_ne_top (Measure.infinitePi μ) Set.univ)
        (labelRangeProjection U f))
  have hfmean :
      ⟪cμ, f⟫_ℝ =
        (∫ x, f x ∂ Measure.infinitePi μ) := by
    simpa only [cμ, Lp.indicatorConstLp_univ, MeasureTheory.setIntegral_univ] using
      (L2.inner_indicatorConstLp_one
        (MeasurableSet.univ : MeasurableSet (Set.univ : Set ((i : ι) → X i)))
        (measure_ne_top (Measure.infinitePi μ) Set.univ) f)
  have hinter := labelRangeProjection_preserves_inner U f cq
  rw [hUc] at hinter
  exact hP.symm.trans (hinter.trans hfmean)

#print axioms Nightfall.InfinitePiQ2OriginalLabelMeanProjection.labelRangeProjection_preserves_inner
#print axioms Nightfall.InfinitePiQ2OriginalLabelMeanProjection.sourceLabelLift_one
#print axioms Nightfall.InfinitePiQ2OriginalLabelMeanProjection.sourceLabelRangeProjection_preserves_mean

end Nightfall.InfinitePiQ2OriginalLabelMeanProjection
