import Mathlib.Analysis.Fourier.FiniteAbelian.PontryaginDuality
import Mathlib.Tactic.Ring

/-! Uniform finite binary-character dual, with exact real Parseval. -/
namespace Nightfall.StructuralInformation.T2UniformParseval
open Finset
variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

noncomputable def sign (s : AddChar G ℂ) (x : G) : ℝ := (s x).re

theorem char_sign (h₂ : ∀ x : G, x + x = 0) (s : AddChar G ℂ) (x : G) :
    s x = 1 ∨ s x = -1 := by
  have h : s x * s x = 1 := by rw [← s.map_add_eq_mul, h₂, s.map_zero_eq_one]
  exact mul_self_eq_one_iff.mp h

theorem sign_mul (h₂ : ∀ x : G, x + x = 0) (s : AddChar G ℂ) (x y : G) :
    sign s x * sign s y = sign s (x+y) := by
  unfold sign
  rw [s.map_add_eq_mul]
  rcases char_sign h₂ s x with hx | hx <;> rw [hx] <;> simp

theorem sign_orthog (h₂ : ∀ x : G, x+x=0) (x y : G) :
    (∑ s : AddChar G ℂ, sign s x * sign s y) =
      if x=y then (Fintype.card G : ℝ) else 0 := by
  classical
  simp_rw [sign_mul h₂]
  have h := congrArg Complex.re (AddChar.sum_apply_eq_ite (x+y))
  have hz : x+y=0 ↔ x=y := by
    constructor
    · intro hxy
      calc x = x + (y+y) := by rw [h₂,add_zero]
           _ = (x+y)+y := by rw [add_assoc]
           _ = y := by rw [hxy,zero_add]
    · rintro rfl; exact h₂ x
  simp only [sign, Complex.re_sum] at *
  by_cases hxy : x = y
  · have hh : x + y = 0 := hz.mpr hxy
    simpa only [if_pos hh, if_pos hxy, Complex.natCast_re] using h
  · have hh : x + y ≠ 0 := fun he => hxy (hz.mp he)
    simpa only [if_neg hh, if_neg hxy, Complex.zero_re] using h

noncomputable def polynomial (F : Finset G) (c : G → ℝ) (s : AddChar G ℂ) : ℝ :=
  ∑ z ∈ F, c z * sign s z

theorem uniform_parseval (h₂ : ∀ x : G, x+x=0) (F : Finset G) (c : G → ℝ) :
    (∑ s : AddChar G ℂ, (polynomial F c s)^2) =
      (Fintype.card G : ℝ) * ∑ z ∈ F, (c z)^2 := by
  classical
  calc
    _ = ∑ s : AddChar G ℂ, ∑ x ∈ F, ∑ y ∈ F,
        (c x * c y) * (sign s x * sign s y) := by
      apply Finset.sum_congr rfl
      intro s _
      unfold polynomial
      rw [pow_two, Finset.sum_mul]
      apply Finset.sum_congr rfl
      intro x _
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro y _
      ring
    _ = ∑ x ∈ F, ∑ y ∈ F, (c x * c y) * ∑ s : AddChar G ℂ, sign s x * sign s y := by
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro x _
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro y _
      rw [Finset.mul_sum]
    _ = _ := by
      simp_rw [sign_orthog h₂, mul_ite, mul_zero]
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro x hx
      rw [Finset.sum_eq_single x]
      · simp; ring
      · intro y _ hy
        simp [Ne.symm hy]
      · exact fun hn => (hn hx).elim

#print axioms uniform_parseval
end Nightfall.StructuralInformation.T2UniformParseval
