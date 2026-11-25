import Mathlib.Analysis.InnerProductSpace.Positive
import Mathlib.Analysis.InnerProductSpace.Rayleigh
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# NIGHTFALL T2 — original effect order implies operator contraction

This module discharges a semantic gap in the existing T2 direct-sum
operator proof: the paper assumes a physical bounded effect 0 <= P <= I,
whereas the Hilbert energy code uses the operator norm bound ‖P‖<=1.

We derive this implication directly in Mathlib's Loewner partial order
on continuous linear endomorphisms of any complex Hilbert space, without
finite-dimensionality, a spectral gap, a projectivity assumption, or a
commutation assumption. The proof uses Mathlib's selfadjoint Rayleigh
quotient characterization of the operator norm (not a new axiom).

Scope is the order-to-norm *effect bridge*; grouped path frame and
Fourier/query results remain separately identified.
-/

namespace Nightfall.StructuralInformation.T2EffectOrder

variable {E : Type*}
variable [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- A positive operator bounded above by I is norm-contractive, in
arbitrary complex Hilbert dimension. This proves the actual quantum
effect input required by the T2 crossed-slot Hilbert frame lemma. -/
theorem effect_norm_le_one
    (P : E →L[ℂ] E) (hP0 : 0 ≤ P) (hP1 : P ≤ 1) :
    ‖P‖ ≤ 1 := by
  have hpos : P.IsPositive :=
    ContinuousLinearMap.nonneg_iff_isPositive.mp hP0
  have hrem : ((1 : E →L[ℂ] E) - P).IsPositive :=
    ContinuousLinearMap.le_def.mp hP1
  rw [P.norm_eq_iSup_rayleighQuotient hpos.isSymmetric]
  refine ciSup_le fun x => ?_
  by_cases hx : x = 0
  · subst x
    simp
  have hden : 0 < ‖x‖ ^ 2 := by
    have hnx : 0 < ‖x‖ := norm_pos_iff.mpr hx
    positivity
  have hlow : 0 ≤ P.reApplyInnerSelf x :=
    hpos.re_inner_nonneg_left x
  have hupper : P.reApplyInnerSelf x ≤ ‖x‖ ^ 2 := by
    have hnonneg : 0 ≤ ((1 : E →L[ℂ] E) - P).reApplyInnerSelf x :=
      hrem.re_inner_nonneg_left x
    have heq : ((1 : E →L[ℂ] E) - P).reApplyInnerSelf x =
        ‖x‖ ^ 2 - P.reApplyInnerSelf x := by
      simp [ContinuousLinearMap.reApplyInnerSelf_apply, inner_sub_left,
        norm_sq_eq_re_inner] <;> norm_cast
    rw [heq] at hnonneg
    linarith
  have hq0 : 0 ≤ P.rayleighQuotient x :=
    div_nonneg hlow hden.le
  have hq1 : P.rayleighQuotient x ≤ 1 := by
    exact (div_le_iff₀ hden).mpr (by simpa [ContinuousLinearMap.rayleighQuotient] using hupper)
  simpa only [abs_of_nonneg hq0] using hq1

#print axioms Nightfall.StructuralInformation.T2EffectOrder.effect_norm_le_one

end Nightfall.StructuralInformation.T2EffectOrder
