import Mathlib

/-!
# Source-derived Q2 190.28 scalar budget closure

Pure real arithmetic. A complete source terminal must prove the
new true singleton budget Σ originalSingletonNorm≤2B.
This module has no independent probabilistic claims.
-/

namespace Nightfall.Q2190
open Finset

variable {Index : Type*} [Fintype Index]

theorem joint_site_to_190_budget
    (a u c s : Index → ℝ)
    (B T M V alpha beta gamma : ℝ)
    (hB : 0 ≤ B) (hT : 0 ≤ T) (hV : 0 ≤ V)
    (halpha : 0 ≤ alpha) (hbeta : 0 ≤ beta) (hgamma : 0 ≤ gamma)
    (hsite : ∀ i, (a i)^2 + s i ≤
      T * (alpha * u i + beta * a i + gamma * c i))
    (hsection : (∑ i : Index, u i) ≤ 5 * B)
    (hsingleton : (∑ i : Index, a i) ≤ 2 * B)
    (hcover : (∑ i : Index, c i) ≤ 8 * B)
    (hvariance : V = (∑ i : Index, (a i)^2) + (∑ i : Index, s i))
    (hT2 : T^2 = M) :
    V^2 ≤ (5 * alpha + 2 * beta + 8 * gamma)^2
      * B^2 * M := by
  classical
  let K : ℝ := 5 * alpha + 2 * beta + 8 * gamma
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
  have hU := mul_le_mul_of_nonneg_left hsection
    (mul_nonneg hT halpha)
  have hA := mul_le_mul_of_nonneg_left hsingleton
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
    _ = (5 * alpha + 2 * beta + 8 * gamma)^2
      * B^2 * M := by
        rw [← hT2]
        dsimp [K]
        ring

end Nightfall.Q2190
