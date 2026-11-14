import Mathlib

/-!
# Q2: scalar-budget closure for the 625.014 analytic candidate

This proves the finite-sum implication under an explicit SITEWISE
inequality. The fourth-moment cubic and actual-source site bridge are
NOT proved here; strict compilation does not certify unconditional Q2.
-/

namespace Nightfall.Q2625ScalarEnvelope

variable {Index : Type*} [Fintype Index]

theorem sitewise_budget_to_variance_squared
    (a u c s : Index → ℝ)
    (B T M V alpha beta gamma : ℝ)
    (hB : 0 ≤ B) (hT : 0 ≤ T) (hV : 0 ≤ V)
    (halpha : 0 ≤ alpha) (hbeta : 0 ≤ beta) (hgamma : 0 ≤ gamma)
    (hsite : ∀ i, (a i)^2 + s i ≤
      T * (alpha * u i + beta * a i + gamma * c i))
    (hsection : (∑ i : Index, u i) ≤ 8 * B)
    (hadditive : (∑ i : Index, a i) ≤
      (2 * (1 + Real.sqrt 2)) * B)
    (hcover : (∑ i : Index, c i) ≤ 8 * B)
    (hvariance : V = (∑ i : Index, (a i)^2) + (∑ i : Index, s i))
    (hT2 : T^2 = M) :
    V^2 ≤ (8 * alpha + (2 * (1 + Real.sqrt 2)) * beta + 8 * gamma)^2
      * B^2 * M := by
  classical
  let K : ℝ := 8 * alpha + (2 * (1 + Real.sqrt 2)) * beta + 8 * gamma
  have hsiteSum :
      V ≤ T * (alpha * (∑ i : Index, u i) +
        beta * (∑ i : Index, a i) +
        gamma * (∑ i : Index, c i)) := by
    calc
      V = ∑ i : Index, ((a i)^2 + s i) := by
        rw [hvariance, Finset.sum_add_distrib]
      _ ≤ ∑ i : Index,
          T * (alpha * u i + beta * a i + gamma * c i) :=
        Finset.sum_le_sum (fun i _ => hsite i)
      _ = T * (alpha * (∑ i : Index, u i) +
          beta * (∑ i : Index, a i) +
          gamma * (∑ i : Index, c i)) := by
        simp only [mul_add, Finset.sum_add_distrib, ← Finset.mul_sum]
        ring
  have hU := mul_le_mul_of_nonneg_left hsection
    (mul_nonneg hT halpha)
  have hA := mul_le_mul_of_nonneg_left hadditive
    (mul_nonneg hT hbeta)
  have hC := mul_le_mul_of_nonneg_left hcover
    (mul_nonneg hT hgamma)
  have hVbound : V ≤ K * B * T := by
    dsimp [K]
    nlinarith [hsiteSum, hU, hA, hC]
  have hK : 0 ≤ K := by
    dsimp [K]
    positivity
  have hnonneg : 0 ≤ K * B * T :=
    mul_nonneg (mul_nonneg hK hB) hT
  have hsq : V^2 ≤ (K * B * T)^2 := by
    nlinarith [mul_nonneg (sub_nonneg.mpr hVbound)
      (add_nonneg hnonneg hV)]
  calc
    V^2 ≤ (K * B * T)^2 := hsq
    _ = (8 * alpha + (2 * (1 + Real.sqrt 2)) * beta + 8 * gamma)^2
      * B^2 * M := by
        rw [← hT2]
        dsimp [K]
        ring

end Nightfall.Q2625ScalarEnvelope
