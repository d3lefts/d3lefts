import Mathlib

/-!
# Q2 arbitrary-index finite-cylinder limit — conditional kernel stage

This lemma has no restriction on the coordinate index type. Its hypotheses
explicitly require approximation of actual variance by finite-cylinder
variance and an already established finite-cylinder bound. Neither is
established for Measure.infinitePi here. This is NOT an end-to-end
kernel certification of the universal probability-space theorem.
-/

namespace Nightfall.Q2UniversalTransfer

variable {Index : Type*} [DecidableEq Index]

theorem finite_cylinder_upper_limit
    (V C : ℝ) (projectionVar : Finset Index → ℝ)
    (happrox : ∀ ε : ℝ, 0 < ε →
      ∃ F : Finset Index, V ≤ projectionVar F + ε)
    (hfinite : ∀ F : Finset Index, projectionVar F ≤ C) :
    V ≤ C := by
  by_contra hn
  have hgap : 0 < (V - C) / 2 := by linarith
  obtain ⟨F, hF⟩ := happrox ((V - C) / 2) hgap
  linarith [hfinite F]

theorem quadratic_bound_from_finite_cylinders
    (V B M K : ℝ) (projectionVar : Finset Index → ℝ)
    (hV : 0 ≤ V) (hB : 0 ≤ B) (hM : 0 ≤ M) (hK : 0 ≤ K)
    (happrox : ∀ ε : ℝ, 0 < ε →
      ∃ F : Finset Index, V ≤ projectionVar F + ε)
    (hfinite : ∀ F : Finset Index,
      projectionVar F ≤ K * B * Real.sqrt M) :
    V^2 ≤ K^2 * B^2 * M := by
  have hbound : V ≤ K * B * Real.sqrt M :=
    finite_cylinder_upper_limit V (K * B * Real.sqrt M) projectionVar
      happrox hfinite
  have hnonneg : 0 ≤ K * B * Real.sqrt M := by positivity
  have hsq : V^2 ≤ (K * B * Real.sqrt M)^2 := by
    nlinarith [mul_nonneg (sub_nonneg.mpr hbound)
      (add_nonneg hnonneg hV)]
  calc
    V^2 ≤ (K * B * Real.sqrt M)^2 := hsq
    _ = K^2 * B^2 * ((Real.sqrt M)^2) := by ring
    _ = K^2 * B^2 * M := by rw [Real.sq_sqrt hM]

end Nightfall.Q2UniversalTransfer
