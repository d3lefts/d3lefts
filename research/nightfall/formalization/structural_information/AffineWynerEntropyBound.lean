import Mathlib

/-!
# NIGHTFALL — exact Shannon entropy bound for a finite supported mass

For any finitely-supported probability mass on a finite ambient alphabet,
Shannon entropy is bounded by the log of the cardinality of any set containing
its support. We prove the maximum entropy inequality by the pinned Mathlib
concavity theorem, reindexing exactly onto the support subtype rather than
pretending nonzero masses at absent symbols.

This is the reusable analytic inequality needed after the q^r free-affine-fiber
cardinality theorem. It is not the C_W infimum theorem or a conditional
mixture entropy chain rule.
-/

namespace Nightfall.AffineWyner

open Finset

variable {X : Type*} [Fintype X] [DecidableEq X]

theorem entropy_supported_le_log_card
    (S : Set X) [Fintype S] [Nonempty S]
    (p : X → ℝ)
    (hp0 : ∀ x, 0 ≤ p x)
    (hp1 : ∑ x, p x = 1)
    (hsupport : ∀ x, x ∉ S → p x = 0) :
    (∑ x, negMulLog (p x)) ≤ Real.log (Fintype.card S) := by
  classical
  let w : S → ℝ := fun z => p z.1
  have hw0 : ∀ z : S, 0 ≤ w z := fun z => hp0 z.1
  have hw1 : ∑ z : S, w z = 1 := by
    calc
      (∑ z : S, w z) = ∑ x : X, p x := by
        symm
        apply Finset.sum_congr_set S (fun x => p x) w
        · intro x hx
          rfl
        · intro x hx
          exact hsupport x hx
      _ = 1 := hp1
  have hM : (0 : ℝ) < Fintype.card S := Nat.cast_pos.mpr Fintype.card_pos
  have hcon := Real.concaveOn_negMulLog.le_map_sum (t := univ)
    (w := fun _ => 1 / (Fintype.card S : ℝ)) (p := w) (fun _ _ => by positivity)
    (by rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]; field_simp)
    (fun θ _ => hw0 θ)
  simp only [smul_eq_mul] at hcon
  rw [← Finset.mul_sum, ← Finset.mul_sum, hw1, mul_one] at hcon
  have hval : negMulLog (1 / (Fintype.card S : ℝ)) =
      Real.log (Fintype.card S) / Fintype.card S := by
    unfold negMulLog
    rw [one_div, Real.log_inv]
    field_simp
  rw [hval, one_div_mul_eq_div] at hcon
  have hbound : (∑ z : S, negMulLog (w z)) ≤ Real.log (Fintype.card S) :=
    (div_le_div_iff_of_pos_right hM).mp hcon
  calc
    (∑ x : X, negMulLog (p x)) =
        ∑ z : S, negMulLog (w z) := by
      apply Finset.sum_congr_set S
          (fun x => negMulLog (p x))
          (fun z : S => negMulLog (w z))
      · intro x hx
        rfl
      · intro x hx
        simp [hsupport x hx]
    _ ≤ Real.log (Fintype.card S) := hbound

end Nightfall.AffineWyner

#print axioms Nightfall.AffineWyner.entropy_supported_le_log_card
