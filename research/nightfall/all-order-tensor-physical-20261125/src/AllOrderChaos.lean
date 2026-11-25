import AllOrderMoments
import Mathlib.Data.Fintype.Pi
import Mathlib.Data.Fintype.EquivFin
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise

namespace Nightfall.AllOrder
open Finset

section Avg
variable {Ω Ξ J : Type*} [Fintype Ω] [Fintype Ξ] [Fintype J]

theorem avg_equiv (e : Ω ≃ Ξ) (f : Ξ → ℝ) : avg (f ∘ e) = avg f := by
  unfold avg
  rw [Fintype.card_congr e]
  congr 1
  exact Fintype.sum_equiv e _ _ (fun _ => rfl)

theorem avg_prod (f : Ω × Ξ → ℝ) : avg f = avg (fun x : Ω => avg (fun y : Ξ => f (x,y))) := by
  unfold avg
  rw [Fintype.sum_prod_type, Fintype.card_prod, Nat.cast_mul, ← Finset.sum_div]
  ring

theorem avg_add (f g : Ω → ℝ) : avg (fun x => f x + g x) = avg f + avg g := by
  simp [avg, Finset.sum_add_distrib, add_div]

theorem avg_mul_const (f : Ω → ℝ) (c : ℝ) : avg (fun x => f x * c) = avg f * c := by
  simp [avg, ← Finset.sum_mul, div_mul_eq_mul_div]

theorem avg_const_mul (f : Ω → ℝ) (c : ℝ) : avg (fun x => c * f x) = c * avg f := by
  simp [avg, ← Finset.mul_sum, mul_div_assoc]

theorem avg_sum (f : J → Ω → ℝ) : avg (fun x => ∑ j, f j x) = ∑ j, avg (f j) := by
  unfold avg
  rw [Finset.sum_comm, Finset.sum_div]

theorem avg_mono (f g : Ω → ℝ) (h : ∀ x, f x ≤ g x) : avg f ≤ avg g := by
  unfold avg
  exact div_le_div_of_nonneg_right (Finset.sum_le_sum (fun x _ => h x)) (by positivity)

theorem avg_const [Nonempty Ω] (c : ℝ) : avg (fun _ : Ω => c) = c := by
  have h : (Fintype.card Ω : ℝ) ≠ 0 := by positivity
  simp [avg, h, nsmul_eq_mul, mul_comm]

theorem avg_nonneg (f : Ω → ℝ) (h : ∀ x, 0 ≤ f x) : 0 ≤ avg f := by
  unfold avg
  exact div_nonneg (Finset.sum_nonneg (fun x _ => h x)) (by positivity)

end Avg

def rad (b : Bool) : ℝ := if b then 1 else -1

theorem rad_sq (b : Bool) : (rad b)^2 = 1 := by cases b <;> norm_num [rad]

theorem abs_rad (b : Bool) : |rad b| = 1 := by cases b <;> norm_num [rad]

theorem avg_fin_succ {n : ℕ} {A : Type*} [Fintype A] (f : (Fin (n+1) → A) → ℝ) :
    avg f = avg (fun x : A => avg (fun y : Fin n → A => f (Fin.cons x y))) := by
  let e := Fin.consEquiv (fun _ : Fin (n+1) => A)
  rw [← avg_equiv e f, avg_prod]
  rfl

theorem avg_bool (f : Bool → ℝ) : avg f = (f true + f false)/2 := by
  simp [avg, Fintype.sum_bool]

noncomputable def linearRad {n : ℕ} (a : Fin n → ℝ) (x : Fin n → Bool) : ℝ := ∑ j, a j * rad (x j)

theorem linearRad_cons {n : ℕ} (a : Fin (n+1) → ℝ) (b : Bool) (x : Fin n → Bool) :
    linearRad a (Fin.cons b x) = a 0 * rad b + linearRad (fun j => a j.succ) x := by
  unfold linearRad
  rw [Fin.sum_univ_succ]
  simp

theorem linearRad_second (n : ℕ) (a : Fin n → ℝ) : avg (fun x => (linearRad a x)^2) = ∑ j, (a j)^2 := by
  induction n with
  | zero => simp [linearRad, avg]
  | succ n ih =>
    rw [avg_fin_succ, avg_bool]
    simp only [linearRad_cons, rad, Bool.false_eq_true, ↓reduceIte, mul_one, mul_neg_one]
    let Y := linearRad (fun j : Fin n => a j.succ)
    have h : (avg (fun y => (a 0 + Y y)^2) + avg (fun y => (-a 0 + Y y)^2))/2 =
        avg (fun y => (a 0)^2 + (Y y)^2) := by
      rw [← avg_add, div_eq_mul_inv, ← avg_mul_const]
      congr 1
      funext y
      ring
    change (avg (fun y => (a 0 + Y y)^2) + avg (fun y => (-a 0 + Y y)^2))/2 = _
    rw [h, avg_add, avg_const, ih, Fin.sum_univ_succ]

theorem linearRad_fourth (n : ℕ) (a : Fin n → ℝ) : avg (fun x => (linearRad a x)^4) ≤ 3 * (∑ j, (a j)^2)^2 := by
  induction n with
  | zero => simp [linearRad, avg]
  | succ n ih =>
    rw [avg_fin_succ, avg_bool]
    simp only [linearRad_cons, rad, Bool.false_eq_true, ↓reduceIte, mul_one, mul_neg_one]
    let Y := linearRad (fun j : Fin n => a j.succ)
    have h : (avg (fun y => (a 0 + Y y)^4) + avg (fun y => (-a 0 + Y y)^4))/2 =
        avg (fun y => (a 0)^4 + (6*(a 0)^2)*(Y y)^2 + (Y y)^4) := by
      rw [← avg_add, div_eq_mul_inv, ← avg_mul_const]
      congr 1
      funext y
      ring
    change (avg (fun y => (a 0 + Y y)^4) + avg (fun y => (-a 0 + Y y)^4))/2 ≤ _
    rw [h, avg_add, avg_add, avg_const, avg_const_mul, linearRad_second, Fin.sum_univ_succ]
    have hi := ih (fun j : Fin n => a j.succ)
    change avg (fun y => (Y y)^4) ≤ _ at hi
    nlinarith [sq_nonneg ((a 0)^2)]

#print axioms linearRad_second
#print axioms linearRad_fourth
end Nightfall.AllOrder
