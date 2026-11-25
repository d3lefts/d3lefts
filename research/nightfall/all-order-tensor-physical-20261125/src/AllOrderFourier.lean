import AllOrderMask
import T2UniformParseval
import Mathlib.Algebra.Order.BigOperators.Ring.Finset
import Mathlib.Tactic.Positivity

namespace Nightfall.AllOrder
open Finset
open Nightfall.StructuralInformation.T2UniformParseval
variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]
variable {A : Type*} [Fintype A]

/-- Character of an arbitrary finite sum is the product of real signs. -/
theorem sign_sum (h₂ : ∀ z : G, z+z=0) (s : AddChar G ℂ)
    (S : Finset A) (a : A → G) :
    sign s (∑ i ∈ S, a i) = ∏ i ∈ S, sign s (a i) := by
  classical
  induction S using Finset.induction_on with
  | empty => simp [sign]
  | @insert i S hi ih => rw [sum_insert hi, prod_insert hi, ← sign_mul h₂, ih]

/-- Finite XOR zero-mask as an exact normalized character average. -/
theorem zero_mask_average (h₂ : ∀ z : G, z+z=0) (S : Finset A) (a : A → G) :
    (∑ s : AddChar G ℂ, ∏ i ∈ S, sign s (a i)) =
      if (∑ i ∈ S, a i) = 0 then (Fintype.card G : ℝ) else 0 := by
  classical
  simp_rw [← sign_sum h₂]
  have h := sign_orthog h₂ (∑ i ∈ S, a i) (0 : G)
  simpa [sign] using h

/-- Equality (hence shifted equality) is an exact sign mask. -/
theorem equality_mask_average (h₂ : ∀ z : G, z+z=0) (x y : G) :
    (∑ s : AddChar G ℂ, ((Fintype.card G : ℝ)⁻¹) * (sign s x * sign s y)) =
      if x = y then 1 else 0 := by
  classical
  rw [← Finset.mul_sum, sign_orthog h₂]
  have h : (Fintype.card G : ℝ) ≠ 0 := by positivity
  split <;> simp [h]

noncomputable def fiberCoefficient (S : Finset A) (z : A → G) (b : A → ℝ) (v : G) : ℝ :=
    ∑ a ∈ S.filter (fun a => z a = v), b a

/-- Actual coefficient grouping by the XOR frequency, with all signs retained. -/
theorem grouped_character_eval (S : Finset A) (z : A → G) (b : A → ℝ) (s : AddChar G ℂ) :
    polynomial univ (fiberCoefficient S z b) s = ∑ a ∈ S, b a * sign s (z a) := by
  classical
  unfold polynomial fiberCoefficient
  simp_rw [Finset.sum_mul]
  rw [← Finset.sum_fiberwise S z (fun a => b a * sign s (z a))]
  apply Finset.sum_congr rfl
  intro v _
  apply Finset.sum_congr rfl
  intro a ha
  rw [(Finset.mem_filter.mp ha).2]

/-- Fiberwise Cauchy-Schwarz: bound in terms of actual active support size. -/
theorem grouped_energy_bound (S : Finset A) (z : A → G) (b : A → ℝ) (B : ℕ)
    (hB : ∀ v, (S.filter (fun a => z a = v)).card ≤ B) :
    (∑ v : G, (fiberCoefficient S z b v)^2) ≤ (B : ℝ) * ∑ a ∈ S, (b a)^2 := by
  classical
  calc
    _ ≤ ∑ v : G, (B : ℝ) * ∑ a ∈ S.filter (fun a => z a = v), (b a)^2 := by
      apply Finset.sum_le_sum
      intro v _
      let U := S.filter (fun a => z a = v)
      have h := Finset.sum_mul_sq_le_sq_mul_sq U (fun _ => (1 : ℝ)) b
      simp only [one_mul, one_pow, Finset.sum_const, nsmul_eq_mul, mul_one] at h
      unfold fiberCoefficient
      exact h.trans (mul_le_mul_of_nonneg_right (by exact_mod_cast hB v) (Finset.sum_nonneg (fun _ _ => sq_nonneg _)))
    _ = _ := by rw [← Finset.mul_sum, Finset.sum_fiberwise]

/-- Full finite-character Fourier transfer, for every arity of the input path.
    B is the maximum cardinality of the *contracted* active fiber. -/
theorem active_fiber_risk (h₂ : ∀ z : G, z+z=0) (S : Finset A) (z : A → G)
    (b : A → ℝ) (B : ℕ) (hB : ∀ v, (S.filter (fun a => z a = v)).card ≤ B) :
    (∑ s : AddChar G ℂ, (∑ a ∈ S, b a * sign s (z a))^2) ≤
      (Fintype.card G : ℝ) * ((B : ℝ) * ∑ a ∈ S, (b a)^2) := by
  simp_rw [← grouped_character_eval S z b]
  rw [uniform_parseval h₂]
  exact mul_le_mul_of_nonneg_left (grouped_energy_bound S z b B hB) (by positivity)

#print axioms sign_sum
#print axioms zero_mask_average
#print axioms equality_mask_average
#print axioms grouped_character_eval
#print axioms grouped_energy_bound
#print axioms active_fiber_risk
end Nightfall.AllOrder
