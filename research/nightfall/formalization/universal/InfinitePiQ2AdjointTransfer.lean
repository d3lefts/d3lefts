import Mathlib

/-!
# Hilbert adjoint transfer for source-exact finite-cell discretization

The finite-table pullback under a measure-preserving label map is an
L² linear isometry U. Its adjoint U† is the finite-cell averaging map.
This module proves the generic, assumption-explicit algebraic principle:
if actual-source and finite-table heat-bath operators intertwine along
U and are self-adjoint, their residual energies contract under U†
and every triple-residual zero passes through U†.

This does *not* assert that the source-specific heat-bath intertwining
hypothesis has been established for the original infinite product, nor
does it claim that U† preserves an L∞ bound. Those are remaining gates.
-/

namespace Nightfall.InfinitePiQ2AdjointTransfer

variable {H K : Type*}
variable [NormedAddCommGroup H] [InnerProductSpace ℝ H] [CompleteSpace H]
variable [NormedAddCommGroup K] [InnerProductSpace ℝ K] [CompleteSpace K]

/-- A genuinely L²-isometric finite-label pullback has an adjoint of
operator norm at most one; no source substituted distribution is used. -/
theorem isometryAdjoint_contract (U : H →ₗᵢ[ℝ] K) (f : K) :
    ‖U.toContinuousLinearMap.adjoint f‖ ≤ ‖f‖ := by
  have hU : ‖U.toContinuousLinearMap‖ ≤ 1 := by
    refine ContinuousLinearMap.opNorm_le_bound _ (by norm_num) ?_
    intro x
    simpa using (le_refl (‖x‖))
  have hAdj : ‖U.toContinuousLinearMap.adjoint‖ =
      ‖U.toContinuousLinearMap‖ := by
    exact (ContinuousLinearMap.adjoint).norm_map _
  have hop := U.toContinuousLinearMap.adjoint.le_opNorm f
  have hmul := mul_le_mul_of_nonneg_right hU (norm_nonneg f)
  nlinarith

/-- Self-adjoint heat-bath operators intertwine in the reverse
direction along the Hilbert adjoint of the finite-label lift. -/
theorem isometryAdjoint_intertwines
    (U : H →ₗᵢ[ℝ] K)
    (Etable : H →L[ℝ] H)
    (Esource : K →L[ℝ] K)
    (hT : Etable.adjoint = Etable)
    (hS : Esource.adjoint = Esource)
    (hintertwine : Esource ∘L U.toContinuousLinearMap =
      U.toContinuousLinearMap ∘L Etable) :
    Etable ∘L U.toContinuousLinearMap.adjoint =
      U.toContinuousLinearMap.adjoint ∘L Esource := by
  have h := congrArg ContinuousLinearMap.adjoint hintertwine
  simpa only [ContinuousLinearMap.adjoint_comp, hT, hS] using h.symm

/-- Single-coordinate heat-bath residual. -/
def residual (E : H →L[ℝ] H) (f : H) : H := f - E f

/-- The exact finite-table residual of the adjoint-averaged source
observable is the adjoint image of the original source residual. -/
theorem isometryAdjoint_residual
    (U : H →ₗᵢ[ℝ] K)
    (Etable : H →L[ℝ] H)
    (Esource : K →L[ℝ] K)
    (hT : Etable.adjoint = Etable)
    (hS : Esource.adjoint = Esource)
    (hintertwine : Esource ∘L U.toContinuousLinearMap =
      U.toContinuousLinearMap ∘L Etable)
    (f : K) :
    residual Etable (U.toContinuousLinearMap.adjoint f) =
      U.toContinuousLinearMap.adjoint (residual Esource f) := by
  have h := isometryAdjoint_intertwines U Etable Esource hT hS hintertwine
  have heq : Etable (U.toContinuousLinearMap.adjoint f) =
      U.toContinuousLinearMap.adjoint (Esource f) := by
    have ha := congrArg (fun T : K →L[ℝ] H => T f) h
    simpa only [ContinuousLinearMap.comp_apply] using ha
  simp only [residual, heq, map_sub]

/-- Uniform source-coordinate influence contraction; applies to the
whole original Hilbert space, regardless of its index cardinality. -/
theorem isometryAdjoint_residual_norm_le
    (U : H →ₗᵢ[ℝ] K)
    (Etable : H →L[ℝ] H)
    (Esource : K →L[ℝ] K)
    (hT : Etable.adjoint = Etable)
    (hS : Esource.adjoint = Esource)
    (hintertwine : Esource ∘L U.toContinuousLinearMap =
      U.toContinuousLinearMap ∘L Etable)
    (f : K) :
    ‖residual Etable (U.toContinuousLinearMap.adjoint f)‖ ≤
      ‖residual Esource f‖ := by
  rw [isometryAdjoint_residual U Etable Esource hT hS hintertwine f]
  exact isometryAdjoint_contract U _

/-- Triple-residual degree-two vanishing transfers through the same
adjoint, for any three coordinates and without requiring all indices
to be distinct. If the original triple residual is zero, so is the
finite-label table's triple residual. -/
theorem isometryAdjoint_triple_zero
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
    residual (Etable i)
      (residual (Etable j)
        (residual (Etable k) (U.toContinuousLinearMap.adjoint f))) = 0 := by
  rw [isometryAdjoint_residual U (Etable k) (Esource k)
    (hT k) (hS k) (hintertwine k) f]
  rw [isometryAdjoint_residual U (Etable j) (Esource j)
    (hT j) (hS j) (hintertwine j) (residual (Esource k) f)]
  rw [isometryAdjoint_residual U (Etable i) (Esource i)
    (hT i) (hS i) (hintertwine i)
    (residual (Esource j) (residual (Esource k) f))]
  simp only [hf, map_zero]

end Nightfall.InfinitePiQ2AdjointTransfer
