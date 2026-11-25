import AllOrderTruncation

namespace Nightfall.AllOrder
open Finset
variable {Ω : Type*} [Fintype Ω]

/-- Finite expectation with the uniform law. -/
noncomputable def avg (f : Ω → ℝ) : ℝ := (∑ w, f w) / (Fintype.card Ω : ℝ)

/-- Cauchy-Schwarz under the normalized finite uniform law. -/
theorem avg_cauchy (f g : Ω → ℝ) :
    (avg (fun x => f x*g x))^2 ≤ avg (fun x => (f x)^2)*avg (fun x => (g x)^2) := by
  classical
  unfold avg
  by_cases h : (Fintype.card Ω : ℝ) = 0
  · simp [h]
  · have hp : 0 < (Fintype.card Ω : ℝ)^2 := sq_pos_of_ne_zero h
    rw [div_pow, div_mul_div_comm, ← pow_two]
    apply (div_le_div_iff_of_pos_right hp).2
    exact Finset.sum_mul_sq_le_sq_mul_sq univ f g

/-- L1/L2/L4 interpolation by two finite Cauchy-Schwarz inequalities. -/
theorem avg_moment_interpolation (Y : Ω → ℝ) :
    (avg (fun x => (Y x)^2))^3 ≤ (avg (fun x => |Y x|))^2 * avg (fun x => (Y x)^4) := by
  classical
  let m₁ := avg (fun x => |Y x|)
  let m₂ := avg (fun x => (Y x)^2)
  let m₃ := avg (fun x => |Y x|^3)
  let m₄ := avg (fun x => (Y x)^4)
  have h₁ : 0 ≤ m₁ := by unfold m₁ avg; positivity
  have h₂ : 0 ≤ m₂ := by unfold m₂ avg; positivity
  have h₃ : 0 ≤ m₃ := by unfold m₃ avg; positivity
  have h₄ : 0 ≤ m₄ := by unfold m₄ avg; positivity
  have hc₁ : m₂^2 ≤ m₁*m₃ := by
    have h := avg_cauchy (fun x => Real.sqrt |Y x|) (fun x => Real.sqrt |Y x| * |Y x|)
    have he : ∀ x, Real.sqrt |Y x| * (Real.sqrt |Y x| * |Y x|) = (Y x)^2 := by
      intro x
      rw [← mul_assoc, ← pow_two, Real.sq_sqrt (abs_nonneg _), ← pow_two, sq_abs]
    have he' : ∀ x, (Real.sqrt |Y x| * |Y x|)^2 = |Y x|^3 := by
      intro x
      rw [mul_pow, Real.sq_sqrt (abs_nonneg _)]
      ring
    simpa only [he, he', Real.sq_sqrt (abs_nonneg _), m₁, m₂, m₃] using h
  have hc₂ : m₃^2 ≤ m₂*m₄ := by
    have h := avg_cauchy (fun x => |Y x|) (fun x => (Y x)^2)
    have he : ∀ x, |Y x| * (Y x)^2 = |Y x|^3 := by
      intro x
      rw [← sq_abs (Y x)]
      ring
    simpa only [he, sq_abs, ← pow_mul, show 2*2=4 by decide, m₂, m₃, m₄] using h
  change m₂^3 ≤ m₁^2*m₄
  by_cases hz : m₂ = 0
  · rw [hz, zero_pow (by decide : 3 ≠ 0)]; exact mul_nonneg (sq_nonneg _) h₄
  · have hs := mul_le_mul hc₁ hc₁ (by positivity : 0 ≤ m₂^2) (mul_nonneg h₁ h₃)
    have ht := mul_le_mul_of_nonneg_left hc₂ (sq_nonneg m₁)
    apply (mul_le_mul_iff_right₀ (lt_of_le_of_ne h₂ (Ne.symm hz))).mp
    calc
      m₂*m₂^3 = m₂^2*m₂^2 := by ring
      _ ≤ (m₁*m₃)*(m₁*m₃) := hs
      _ = m₁^2*m₃^2 := by ring
      _ ≤ m₁^2*(m₂*m₄) := ht
      _ = m₂*(m₁^2*m₄) := by ring

#print axioms avg_cauchy
#print axioms avg_moment_interpolation
end Nightfall.AllOrder
