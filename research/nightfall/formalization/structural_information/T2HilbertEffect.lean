import Mathlib

/-!
# NIGHTFALL T2: complex Hilbert operator-norm contraction implies frame energy

For any finite set of oracle sectors D and any arbitrary (possibly
infinite-dimensional, nonseparable) complex inner-product fiber E,
the Hilbert direct sum `PiLp 2 (fun _ : D => E)` carries the physical
squared norm `sum_d ‖x d‖²`. We derive **rather than assume** the
Hilbert energy contraction of an arbitrary continuous complex linear
operator P with ‖P‖≤1, and the selected-coordinate pinching inequality.

The contractive operator may have arbitrary rank and mix oracle sectors;
there is no P Pi_d = Pi_d P hypothesis. The direct-sum Hilbert space is
not restricted to a finite-dimensional matrix representation.

This discharges the `energy (P x) ≤ energy x` premise of the earlier
crossed-frame source when P is given by an actual norm-bounded operator.
The positive-effect 0≤P≤I to op-norm bridge, the general physical
orthogonal-sector decomposition, and four-slot Fourier/query terminal
remain separate obligations.
-/

namespace Nightfall.StructuralInformation.T2HilbertEffect

open Finset

variable {D : Type*} [Fintype D] [DecidableEq D]
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

abbrev SectorSum (D E : Type*) := PiLp 2 (fun _ : D => E)

/-- The standard finite direct-sum physical squared Hilbert norm. -/
noncomputable def energy (x : SectorSum D E) : ℝ :=
  ∑ d : D, ‖x d‖ ^ 2

theorem norm_sq_eq_energy (x : SectorSum D E) :
    ‖x‖ ^ 2 = energy x := by
  exact PiLp.norm_sq_eq_of_L2 _ x

/-- An arbitrary possibly noncommuting complex operator of norm at most 1
preserves the physical energy inequality in any Hilbert dimension. -/
theorem contractive_operator_energy
    (P : SectorSum D E →L[ℂ] SectorSum D E)
    (hP : ‖P‖ ≤ 1) (x : SectorSum D E) :
    energy (P x) ≤ energy x := by
  have hnorm : ‖P x‖ ≤ ‖x‖ := by
    calc
      ‖P x‖ ≤ ‖P‖ * ‖x‖ := P.le_opNorm x
      _ ≤ 1 * ‖x‖ := mul_le_mul_of_nonneg_right hP (norm_nonneg x)
      _ = ‖x‖ := one_mul _
  have hsquared : ‖P x‖ ^ 2 ≤ ‖x‖ ^ 2 :=
    (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mpr hnorm
  calc
    energy (P x) = ‖P x‖ ^ 2 := (norm_sq_eq_energy (P x)).symm
    _ ≤ ‖x‖ ^ 2 := hsquared
    _ = energy x := norm_sq_eq_energy x

/-- The (not necessarily commute-preserving) selected input/output
sector pinching used in the T2 crossed-label proof. -/
theorem selected_sector_energy
    (P : SectorSum D E →L[ℂ] SectorSum D E)
    (hP : ‖P‖ ≤ 1)
    (w : D → SectorSum D E) :
    (∑ a : D, ‖(P (w a)) a‖ ^ 2) ≤
      ∑ a : D, energy (w a) := by
  apply Finset.sum_le_sum
  intro a _
  have hcoord : ‖(P (w a)) a‖ ^ 2 ≤ energy (P (w a)) := by
    unfold energy
    exact Finset.single_le_sum
      (fun b _ => sq_nonneg (‖(P (w a)) b‖)) (Finset.mem_univ a)
  exact hcoord.trans (contractive_operator_energy P hP (w a))

/-- The weighted second-query path rows in the genuine direct-sum space.
No finite-dimensionality hypothesis is imposed on the fiber E. -/
noncomputable def crossedInput (T : D → D → E)
    (beta : D → ℂ) (a : D) : SectorSum D E :=
  WithLp.toLp 2 (fun b : D => beta b • T b a)

/-- Noncommuting contracted path-energy inequality with no separately
postulated abstract energy bound: it follows from ‖P‖ ≤ 1. -/
theorem crossed_operator_energy
    (P : SectorSum D E →L[ℂ] SectorSum D E)
    (hP : ‖P‖ ≤ 1)
    (T : D → D → E) (beta : D → ℂ) :
    (∑ a : D, ‖(P (crossedInput T beta a)) a‖ ^ 2) ≤
      ∑ b : D, ‖beta b‖ ^ 2 *
        (∑ a : D, ‖T b a‖ ^ 2) := by
  calc
    _ ≤ ∑ a : D, energy (crossedInput T beta a) :=
      selected_sector_energy P hP (crossedInput T beta)
    _ = ∑ a : D, ∑ b : D,
          ‖beta b‖ ^ 2 * ‖T b a‖ ^ 2 := by
      simp only [energy, crossedInput, PiLp.toLp_apply, norm_smul, mul_pow]
    _ = ∑ b : D, ‖beta b‖ ^ 2 *
        (∑ a : D, ‖T b a‖ ^ 2) := by
      rw [Finset.sum_comm]
      simp only [← Finset.mul_sum]

#print axioms Nightfall.StructuralInformation.T2HilbertEffect.norm_sq_eq_energy
#print axioms Nightfall.StructuralInformation.T2HilbertEffect.contractive_operator_energy
#print axioms Nightfall.StructuralInformation.T2HilbertEffect.selected_sector_energy
#print axioms Nightfall.StructuralInformation.T2HilbertEffect.crossed_operator_energy

end Nightfall.StructuralInformation.T2HilbertEffect
