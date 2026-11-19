import StrongSmoothingAmplifier

/-!
# Smoothed event indicator as an explicit real polynomial

Polynomial implementation of the certified cubic amplifier. Its evaluation
equals the scalar iterated cubic, so the dimension-free doubly-exponential
tail bounds are genuine polynomial bounds. The base threshold separator is
a separate lemma and the quantum simulation theorem is not in this file.
-/

namespace Nightfall.StrongSmoothing

open Polynomial

noncomputable def cubicPoly : Polynomial ℝ :=
  X ^ 2 * (C 3 - C 2 * X)

theorem cubicPoly_eval (x : ℝ) :
    cubicPoly.eval x = cubic x := by
  simp [cubicPoly, cubic]

noncomputable def ampPoly : ℕ → Polynomial ℝ
  | 0 => X
  | n + 1 => cubicPoly.comp (ampPoly n)

theorem ampPoly_eval (n : ℕ) (x : ℝ) :
    (ampPoly n).eval x = amp n x := by
  induction n with
  | zero => simp [ampPoly, amp]
  | succ n ih =>
      change (cubicPoly.comp (ampPoly n)).eval x =
        cubic (amp n x)
      rw [Polynomial.eval_comp, cubicPoly_eval, ih]

theorem cubicPoly_natDegree_le_three : cubicPoly.natDegree ≤ 3 := by
  unfold cubicPoly
  have h1 : (X ^ 2 : Polynomial ℝ).natDegree ≤ 2 := by simp
  have hc : (C (2 : ℝ) * X).natDegree ≤ 1 := by
    have h := Polynomial.natDegree_C_mul_le (2 : ℝ) (X : Polynomial ℝ)
    simpa using h
  have h3 : (C (3 : ℝ) - C 2 * X).natDegree ≤ 1 := by
    have hh := Polynomial.natDegree_sub_le (C (3 : ℝ)) (C 2 * X)
    have hconst : (C (3 : ℝ) : Polynomial ℝ).natDegree ≤ 1 := by simp
    omega
  have hm := Polynomial.natDegree_mul_le
    (p := (X ^ 2 : Polynomial ℝ))
    (q := (C (3 : ℝ) - C 2 * X))
  omega

theorem ampPoly_natDegree_le (n : ℕ) :
    (ampPoly n).natDegree ≤ 3 ^ n := by
  induction n with
  | zero => simp [ampPoly]
  | succ n ih =>
      change (cubicPoly.comp (ampPoly n)).natDegree ≤ 3 ^ (n + 1)
      have hcomp := Polynomial.natDegree_comp_le
        (p := cubicPoly) (q := ampPoly n)
      have hdeg := cubicPoly_natDegree_le_three
      have hprod := Nat.mul_le_mul hdeg ih
      calc
        (cubicPoly.comp (ampPoly n)).natDegree ≤
          cubicPoly.natDegree * (ampPoly n).natDegree := hcomp
        _ ≤ 3 * 3 ^ n := hprod
        _ = 3 ^ (n + 1) := by simp [pow_succ, mul_comm]

theorem ampPoly_low_tail (n : ℕ) {x : ℝ}
    (hx : 0 ≤ x) (hxmax : x ≤ 2 / 5) :
    3 * (ampPoly (n + 3)).eval x ≤ (3 / 4 : ℝ) ^ (2 ^ n) := by
  rw [ampPoly_eval]
  exact amp_low_tail n hx hxmax

theorem ampPoly_high_tail (n : ℕ) {x : ℝ}
    (hx : 3 / 5 ≤ x) (hx1 : x ≤ 1) :
    3 * (1 - (ampPoly (n + 3)).eval x) ≤
      (3 / 4 : ℝ) ^ (2 ^ n) := by
  rw [ampPoly_eval]
  exact amp_high_tail n hx hx1

end Nightfall.StrongSmoothing
