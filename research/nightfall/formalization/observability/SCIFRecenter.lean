import Mathlib

/-!
# SCIF I–II: finite source-law recentering and mixed-difference invariance

All identities are literal finite weighted sums on the FULL alphabets.
The marginal weights may vanish. The statements below do not assume the
quadratic variance–influence theorem or supplied new centeredness.

This module proves the local pair-table algebra underlying the SCIF
source update. Integration with the canonical full-product Efron–Stein
projections is a separate, stronger formalization step.
-/

namespace Nightfall.SCIF
open Finset

variable {A B : Type*} [Fintype A] [Fintype B]

noncomputable def firstMean (q : A → ℝ) (H : A → B → ℝ) (b : B) : ℝ :=
  ∑ a : A, q a * H a b

noncomputable def pairRecenter (q : A → ℝ) (H : A → B → ℝ)
    (a : A) (b : B) : ℝ :=
  H a b - firstMean q H b

/-- The updated pair kernel is centered under the new source law. -/
theorem pairRecenter_first_centered
    (q : A → ℝ) (hq : (∑ a : A, q a) = 1)
    (H : A → B → ℝ) (b : B) :
    (∑ a : A, q a * pairRecenter q H a b) = 0 := by
  classical
  calc
    (∑ a : A, q a * pairRecenter q H a b) =
      (∑ a : A, q a * H a b) -
        (∑ a : A, q a) * firstMean q H b := by
          simp_rw [pairRecenter, mul_sub]
          rw [Finset.sum_sub_distrib, ← Finset.sum_mul]
    _ = 0 := by
      rw [hq]
      simp [firstMean]

/-- The new first-coordinate average preserves old centering in the
unchanged second-coordinate law. -/
theorem firstMean_other_centered
    (q : A → ℝ) (r : B → ℝ) (H : A → B → ℝ)
    (hH : ∀ a : A, (∑ b : B, r b * H a b) = 0) :
    (∑ b : B, r b * firstMean q H b) = 0 := by
  classical
  calc
    (∑ b : B, r b * firstMean q H b) =
        ∑ b : B, ∑ a : A, r b * (q a * H a b) := by
          simp [firstMean, Finset.mul_sum]
    _ = ∑ a : A, ∑ b : B, r b * (q a * H a b) :=
          Finset.sum_comm
    _ = ∑ a : A, q a * (∑ b : B, r b * H a b) := by
          apply Finset.sum_congr rfl
          intro a _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro b _
          ring
    _ = 0 := by simp [hH]

/-- Updating law k does not destroy centering in any unchanged neighbor. -/
theorem pairRecenter_other_centered
    (q : A → ℝ) (r : B → ℝ) (H : A → B → ℝ)
    (hH : ∀ a : A, (∑ b : B, r b * H a b) = 0)
    (a : A) :
    (∑ b : B, r b * pairRecenter q H a b) = 0 := by
  classical
  calc
    (∑ b : B, r b * pairRecenter q H a b) =
      (∑ b : B, r b * H a b) -
      (∑ b : B, r b * firstMean q H b) := by
        simp_rw [pairRecenter, mul_sub]
        rw [Finset.sum_sub_distrib]
    _ = 0 := by
      rw [hH a, firstMean_other_centered q r H hH]
      ring

/-- Pointwise two-site star recentering, with the original pair table. -/
theorem two_site_recenter_identity
    (q : A → ℝ) (m : ℝ) (hK : A → ℝ) (hJ : B → ℝ)
    (H : A → B → ℝ) (a : A) (b : B) :
    m + hK a + hJ b + H a b =
      (m + ∑ z : A, q z * hK z) +
      (hK a - ∑ z : A, q z * hK z) +
      (hJ b + firstMean q H b) +
      pairRecenter q H a b := by
  dsimp [pairRecenter]
  ring

/-- Four-corner mixed difference: an algebraic, not measure-based, edge witness. -/
def rectangle (H : A → B → ℝ) (a a' : A) (b b' : B) : ℝ :=
  H a b - H a' b - H a b' + H a' b'

/-- Every four-corner mixed difference is exactly unchanged by recentering. -/
theorem rectangle_pairRecenter
    (q : A → ℝ) (H : A → B → ℝ)
    (a a' : A) (b b' : B) :
    rectangle (pairRecenter q H) a a' b b' =
      rectangle H a a' b b' := by
  dsimp [rectangle, pairRecenter]
  ring

/-- The intrinsic algebraic edge is present after recentering iff
it was present before; this includes previously impossible states. -/
theorem algebraic_edge_iff_after_recenter
    (q : A → ℝ) (H : A → B → ℝ) :
    (∃ a a' : A, ∃ b b' : B,
        rectangle (pairRecenter q H) a a' b b' ≠ 0) ↔
    (∃ a a' : A, ∃ b b' : B,
        rectangle H a a' b b' ≠ 0) := by
  simp only [rectangle_pairRecenter]

end Nightfall.SCIF
