import InfinitePiQ2AdjointTransfer
import Mathlib

/-!
# Commutation and degree transfer for genuine Hilbert label projections

Given the real source/label L² isometry U and the (separately
certified) heat-bath intertwining E_source U = U E_label,
the canonical label-information averaging operator P = U U†
commutes with the original-source heat-bath at *every* coordinate.
Thus the original-source residual energy of P f is no larger
than that of f, and source degree ≤ 2 persists after P.

These are abstract operator lemmas, not postulated original-source
intertwining, and are deliberately scoped: the actual Measure.infinitePi
instantiation must discharge hintertwine using the original-source
finite-label heat-bath identity. No unconditional Q2 terminal is
claimed merely from this generic theorem.
-/

namespace Nightfall.InfinitePiQ2RangeProjectionTransfer

open Nightfall.InfinitePiQ2AdjointTransfer

variable {H K : Type*}
variable [NormedAddCommGroup H] [InnerProductSpace ℝ H] [CompleteSpace H]
variable [NormedAddCommGroup K] [InnerProductSpace ℝ K] [CompleteSpace K]

/-- The concrete Hilbert finite-label averaging operator U U†,
not a caller-supplied projection or a surrogate source law. -/
noncomputable def labelRangeProjection (U : H →ₗᵢ[ℝ] K) : K →L[ℝ] K :=
  U.toContinuousLinearMap ∘L U.toContinuousLinearMap.adjoint

/-- If the genuine table and source heat baths intertwine on the
label pullback and are self-adjoint, finite-label averaging commutes
with the original source heat bath. The reverse intertwining follows
from the independently certified Hilbert adjoint theorem. -/
theorem labelRangeProjection_commutes
    (U : H →ₗᵢ[ℝ] K)
    (Etable : H →L[ℝ] H) (Esource : K →L[ℝ] K)
    (hT : Etable.adjoint = Etable)
    (hS : Esource.adjoint = Esource)
    (hintertwine : Esource ∘L U.toContinuousLinearMap =
      U.toContinuousLinearMap ∘L Etable) :
    Esource ∘L labelRangeProjection U =
      labelRangeProjection U ∘L Esource := by
  have hb := isometryAdjoint_intertwines U Etable Esource hT hS hintertwine
  apply ContinuousLinearMap.ext
  intro f
  have hforward :
      Esource (U.toContinuousLinearMap (U.toContinuousLinearMap.adjoint f)) =
        U.toContinuousLinearMap
          (Etable (U.toContinuousLinearMap.adjoint f)) := by
    have h := congrArg
      (fun T : H →L[ℝ] K => T (U.toContinuousLinearMap.adjoint f))
      hintertwine
    simpa only [ContinuousLinearMap.comp_apply] using h
  have hbackward :
      Etable (U.toContinuousLinearMap.adjoint f) =
        U.toContinuousLinearMap.adjoint (Esource f) := by
    have h := congrArg
      (fun T : K →L[ℝ] H => T f) hb
    simpa only [ContinuousLinearMap.comp_apply] using h
  change Esource
      (U.toContinuousLinearMap (U.toContinuousLinearMap.adjoint f)) =
      U.toContinuousLinearMap
        (U.toContinuousLinearMap.adjoint (Esource f))
  calc
    Esource (U.toContinuousLinearMap
        (U.toContinuousLinearMap.adjoint f)) =
      U.toContinuousLinearMap
        (Etable (U.toContinuousLinearMap.adjoint f)) := hforward
    _ = U.toContinuousLinearMap
        (U.toContinuousLinearMap.adjoint (Esource f)) := by
      rw [hbackward]

/-- The source residual passes exactly through label conditional
averaging, without a replacement law, artificial finite dimension,
or a dimension-dependent error term. -/
theorem labelRangeProjection_residual
    (U : H →ₗᵢ[ℝ] K)
    (Etable : H →L[ℝ] H) (Esource : K →L[ℝ] K)
    (hT : Etable.adjoint = Etable)
    (hS : Esource.adjoint = Esource)
    (hintertwine : Esource ∘L U.toContinuousLinearMap =
      U.toContinuousLinearMap ∘L Etable)
    (f : K) :
    residual Esource (labelRangeProjection U f) =
      labelRangeProjection U (residual Esource f) := by
  have hc := labelRangeProjection_commutes U Etable Esource hT hS hintertwine
  have heq : Esource (labelRangeProjection U f) =
      labelRangeProjection U (Esource f) := by
    have h := congrArg (fun T : K →L[ℝ] K => T f) hc
    simpa only [ContinuousLinearMap.comp_apply] using h
  dsimp only [residual]
  rw [heq]
  exact ((labelRangeProjection U).map_sub f (Esource f)).symm

/-- Label conditional averaging contracts every actual-source
coordinate residual in the genuine L² Hilbert norm. -/
theorem labelRangeProjection_residual_norm_le
    (U : H →ₗᵢ[ℝ] K)
    (Etable : H →L[ℝ] H) (Esource : K →L[ℝ] K)
    (hT : Etable.adjoint = Etable)
    (hS : Esource.adjoint = Esource)
    (hintertwine : Esource ∘L U.toContinuousLinearMap =
      U.toContinuousLinearMap ∘L Etable)
    (f : K) :
    ‖residual Esource (labelRangeProjection U f)‖ ≤
      ‖residual Esource f‖ := by
  rw [labelRangeProjection_residual U Etable Esource hT hS hintertwine f]
  change ‖U.toContinuousLinearMap
    (U.toContinuousLinearMap.adjoint (residual Esource f))‖ ≤
    ‖residual Esource f‖
  calc
    ‖U.toContinuousLinearMap
      (U.toContinuousLinearMap.adjoint (residual Esource f))‖ =
      ‖U.toContinuousLinearMap.adjoint (residual Esource f)‖ := by
        exact U.norm_map _
    _ ≤ ‖residual Esource f‖ := isometryAdjoint_contract U _

/-- Every source triple residual zero stays zero after genuine
finite-label orthogonal averaging, conditional only on the explicit
source/table heat-bath intertwining for all three sites. -/
theorem labelRangeProjection_triple_zero
    {ι : Type*} (U : H →ₗᵢ[ℝ] K)
    (Etable : ι → H →L[ℝ] H)
    (Esource : ι → K →L[ℝ] K)
    (hT : ∀ i, (Etable i).adjoint = Etable i)
    (hS : ∀ i, (Esource i).adjoint = Esource i)
    (hintertwine : ∀ i, Esource i ∘L U.toContinuousLinearMap =
      U.toContinuousLinearMap ∘L Etable i)
    (i j k : ι) (f : K)
    (hf : residual (Esource i)
        (residual (Esource j) (residual (Esource k) f)) = 0) :
    residual (Esource i)
      (residual (Esource j)
        (residual (Esource k) (labelRangeProjection U f))) = 0 := by
  rw [labelRangeProjection_residual U (Etable k) (Esource k)
    (hT k) (hS k) (hintertwine k) f]
  rw [labelRangeProjection_residual U (Etable j) (Esource j)
    (hT j) (hS j) (hintertwine j) (residual (Esource k) f)]
  rw [labelRangeProjection_residual U (Etable i) (Esource i)
    (hT i) (hS i) (hintertwine i)
    (residual (Esource j) (residual (Esource k) f))]
  simp only [hf, map_zero]

#print axioms Nightfall.InfinitePiQ2RangeProjectionTransfer.labelRangeProjection_commutes
#print axioms Nightfall.InfinitePiQ2RangeProjectionTransfer.labelRangeProjection_residual
#print axioms Nightfall.InfinitePiQ2RangeProjectionTransfer.labelRangeProjection_residual_norm_le
#print axioms Nightfall.InfinitePiQ2RangeProjectionTransfer.labelRangeProjection_triple_zero

end Nightfall.InfinitePiQ2RangeProjectionTransfer
