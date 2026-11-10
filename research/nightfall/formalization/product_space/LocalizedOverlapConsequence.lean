import Mathlib

/-!
NIGHTFALL — Wright Certificate Engine, Theorem 1.3(b).
Geometric-mean localization consequence for any finite coordinate count.
The localized two-sided certificate inequality is an explicit hypothesis.
No sorry, custom axioms, native_decide or opaque postulates.
-/

namespace Nightfall.ProductSpace

open Finset

/-- The squared two-sided certificate mass is bounded by the maximal
influence times the squared unnormalized Bhattacharyya overlap. -/
theorem localized_overlap_consequence {n : ℕ}
    (P Q I : Fin n → ℝ) (V₁ V₀ M : ℝ)
    (hP : ∀ i, 0 ≤ P i) (hQ : ∀ i, 0 ≤ Q i)
    (hI : ∀ i, 0 ≤ I i) (hImax : ∀ i, I i ≤ M)
    (hM : 0 ≤ M) (hV₁ : 0 ≤ V₁) (hV₀ : 0 ≤ V₀)
    (hloc : V₁ * V₀ ≤ ∑ i, Real.sqrt (I i * (P i * Q i))) :
    (V₁ * V₀) ^ 2 ≤
      M * (∑ i, Real.sqrt (P i * Q i)) ^ 2 := by
  have hper : ∀ i : Fin n,
      Real.sqrt (I i * (P i * Q i)) ≤
        Real.sqrt M * Real.sqrt (P i * Q i) := by
    intro i
    rw [Real.sqrt_mul (hI i)]
    exact mul_le_mul_of_nonneg_right
      (Real.sqrt_le_sqrt (hImax i)) (Real.sqrt_nonneg _)
  have hsum : (∑ i, Real.sqrt (I i * (P i * Q i))) ≤
      Real.sqrt M * ∑ i, Real.sqrt (P i * Q i) := by
    calc
      (∑ i, Real.sqrt (I i * (P i * Q i))) ≤
          ∑ i, Real.sqrt M * Real.sqrt (P i * Q i) := by
            apply Finset.sum_le_sum
            intro i _
            exact hper i
      _ = Real.sqrt M * ∑ i, Real.sqrt (P i * Q i) := by
        rw [Finset.mul_sum]
  have hS : 0 ≤ ∑ i, Real.sqrt (P i * Q i) := by
    apply Finset.sum_nonneg
    intro i _
    exact Real.sqrt_nonneg _
  have hsmall : 0 ≤ V₁ * V₀ := mul_nonneg hV₁ hV₀
  have hlarge : 0 ≤ Real.sqrt M * ∑ i, Real.sqrt (P i * Q i) :=
    mul_nonneg (Real.sqrt_nonneg _) hS
  have hbound := le_trans hloc hsum
  have hsq : (V₁ * V₀) ^ 2 ≤
      (Real.sqrt M * ∑ i, Real.sqrt (P i * Q i)) ^ 2 := by
    nlinarith
  calc
    (V₁ * V₀) ^ 2 ≤
        (Real.sqrt M * ∑ i, Real.sqrt (P i * Q i)) ^ 2 := hsq
    _ = M * (∑ i, Real.sqrt (P i * Q i)) ^ 2 := by
      rw [mul_pow, Real.sq_sqrt hM]

end Nightfall.ProductSpace
