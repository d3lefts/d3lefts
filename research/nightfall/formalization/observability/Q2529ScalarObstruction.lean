import Mathlib

/-!
# Exact 529 scalar-budget obstruction (not an actual-source counterexample)

The previously certified Q2 proof uses source-derived aggregate budgets:
sum u_i <= 8B, sum a_i <= 2(1+sqrt 2)B, sum c_i <= 8B,
together with a_i <= u_i, z_i <= u_i+a_i,
a_i^2 + s_i <= M, and the actual Hilbert fourth-moment cubic
s_i^3 <= z_i^2(c_i^2*s_i + 3*s_i^2).

This rational construction satisfies EVERY listed *abstract* budget at
B=M=1, even the optional sum z_i <=16B and z_i^2 <= s_i.
It has total V=24, hence V^2=576>529.

Three prototypes are repeated 2,4,18 times (24 scalar sites).
This blocks deriving K=529 FROM THESE SCALAR INEQUALITIES ALONE.
It is NOT a bounded degree-two product function, so it does NOT
disprove K=529 for the actual probabilistic Q2 problem.
-/

namespace Nightfall.Q2529ScalarObstruction

private noncomputable def w : Fin 3 → ℝ := ![2, 4, 18]
private noncomputable def a : Fin 3 → ℝ := ![0, 0, 4/15]
private noncomputable def u : Fin 3 → ℝ := ![7/12, 8/21, 7/24]
private noncomputable def z : Fin 3 → ℝ := ![7/12, 8/21, 67/120]
private noncomputable def s : Fin 3 → ℝ := ![1, 1, 209/225]
private noncomputable def c : Fin 3 → ℝ := ![0, 2, 0]

theorem every_scalar_site_valid :
    ∀ i : Fin 3,
      0 ≤ a i ∧ 0 ≤ u i ∧ 0 ≤ z i ∧
      0 ≤ s i ∧ 0 ≤ c i ∧ 0 ≤ w i ∧
      a i ≤ u i ∧ z i ≤ u i + a i ∧
      a i ^ 2 + s i ≤ 1 ∧
      z i ^ 2 ≤ s i ∧
      s i ^ 3 ≤ z i ^ 2 * (c i ^ 2 * s i + 3 * s i ^ 2) := by
  intro i
  fin_cases i <;> norm_num [a, u, z, s, c, w]

theorem weighted_budget_and_variance :
    (∑ i : Fin 3, w i * u i) = (667 / 84 : ℝ) ∧
    (∑ i : Fin 3, w i * a i) = (24 / 5 : ℝ) ∧
    (∑ i : Fin 3, w i * c i) = (8 : ℝ) ∧
    (∑ i : Fin 3, w i * z i) = (5351 / 420 : ℝ) ∧
    (∑ i : Fin 3, w i * (a i ^ 2 + s i)) = (24 : ℝ) := by
  norm_num [Fin.sum_univ_succ, w, a, u, z, s, c]

/-- A concrete exact-rational 24-site model satisfies all the local
budget and cubic assumptions, yet its squared energy exceeds 529.
The important scope is the abstract *scalar relaxation*, not actual f,p. -/
theorem bound_529_not_a_consequence_of_current_scalar_budgets :
    (∀ i : Fin 3,
      0 ≤ a i ∧ 0 ≤ u i ∧ 0 ≤ z i ∧
      0 ≤ s i ∧ 0 ≤ c i ∧ 0 ≤ w i ∧
      a i ≤ u i ∧ z i ≤ u i + a i ∧
      a i ^ 2 + s i ≤ 1 ∧
      z i ^ 2 ≤ s i ∧
      s i ^ 3 ≤ z i ^ 2 * (c i ^ 2 * s i + 3 * s i ^ 2)) ∧
    (∑ i : Fin 3, w i * u i) ≤ 8 ∧
    (∑ i : Fin 3, w i * a i) ≤ 2 * (1 + Real.sqrt 2) ∧
    (∑ i : Fin 3, w i * c i) ≤ 8 ∧
    (∑ i : Fin 3, w i * z i) ≤ 16 ∧
    529 < (∑ i : Fin 3, w i * (a i ^ 2 + s i)) ^ 2 := by
  obtain ⟨hu, ha, hc, hz, hV⟩ := weighted_budget_and_variance
  have hroot : (7 / 5 : ℝ) ≤ Real.sqrt 2 := by
    have hsqrt : (Real.sqrt 2) ^ 2 = 2 := Real.sq_sqrt (by norm_num)
    have hnonneg : 0 ≤ Real.sqrt 2 := Real.sqrt_nonneg _
    nlinarith
  refine ⟨every_scalar_site_valid, ?_, ?_, ?_, ?_, ?_⟩
  · rw [hu]
    norm_num
  · rw [ha]
    nlinarith
  · rw [hc]
  · rw [hz]
    norm_num
  · rw [hV]
    norm_num

end Nightfall.Q2529ScalarObstruction
