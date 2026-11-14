import Mathlib

/-!
# Q2 scalar endpoint from fully declared numerical budgets

This is the final deterministic arithmetic portion of the finite-source
quadratic variance–influence proof. It does not derive its budget inputs
from a genuine source f: that substantial source bridge is separately
required, and the theorem below MUST NOT be presented as a kernel
proof of Q2 without those upstream declarations.

Lean pin: repository Lean 4.36.0-rc2, pinned Mathlib.
-/

namespace Nightfall.Observability.ActualProductQ2ScalarClosure

open Finset

variable {ι : Type*} [Fintype ι]

/-- Conditional Q2 *scalar* closure:
if the source-derived analytic budgets and the owner-wise fourth moment
endpoint hold, the numerical inequality follows with no dimension factor.

Every budget is deliberately explicit. There is no Q2 axiom and no
claim that arbitrary f satisfies the displayed hypotheses. -/
theorem q2_scalar_endpoint
    (a c z s : ι → ℝ)
    (B T α ρ V : ℝ)
    (hB : 0 ≤ B)
    (hT : 0 ≤ T)
    (hα : 0 ≤ α)
    (hρ : 0 ≤ ρ)
    (ha : ∀ i, 0 ≤ a i)
    (hc : ∀ i, 0 ≤ c i)
    (hz : ∀ i, 0 ≤ z i)
    (haca : ∀ i, a i ≤ T)
    (hzca : ∀ i, z i ≤ T)
    (hstep : ∀ i, s i ≤ z i * (c i + ρ * T))
    (habudget : (∑ i : ι, a i) ≤ α * B)
    (hcbudget : (∑ i : ι, c i) ≤ 8 * B)
    (hzbudget : (∑ i : ι, z i) ≤ (8 + α) * B)
    (hvariance : V = (∑ i : ι, (a i)^2) + ∑ i : ι, s i) :
    V ≤ (8 + α) * (1 + ρ) * B * T := by
  classical
  have ha_sq (i : ι) : a i ^ 2 ≤ T * a i := by
    nlinarith [mul_nonneg (ha i) (sub_nonneg.mpr (haca i))]
  have ha_total :
      (∑ i : ι, (a i)^2) ≤ T * (∑ i : ι, a i) := by
    calc
      (∑ i : ι, (a i)^2) ≤ ∑ i : ι, T * a i := by
        exact Finset.sum_le_sum (fun i _ => ha_sq i)
      _ = T * (∑ i : ι, a i) := by rw [← Finset.mul_sum]
  have hcz (i : ι) : c i * z i ≤ T * c i := by
    nlinarith [mul_nonneg (hc i) (sub_nonneg.mpr (hzca i))]
  have hcz_total :
      (∑ i : ι, c i * z i) ≤ T * (∑ i : ι, c i) := by
    calc
      (∑ i : ι, c i * z i) ≤ ∑ i : ι, T * c i := by
        exact Finset.sum_le_sum (fun i _ => hcz i)
      _ = T * (∑ i : ι, c i) := by rw [← Finset.mul_sum]
  have hs_total :
      (∑ i : ι, s i) ≤
      (∑ i : ι, c i * z i) + ρ * T * (∑ i : ι, z i) := by
    calc
      (∑ i : ι, s i) ≤
          ∑ i : ι, z i * (c i + ρ * T) := by
            exact Finset.sum_le_sum (fun i _ => hstep i)
      _ = (∑ i : ι, c i * z i) + ρ * T * (∑ i : ι, z i) := by
        simp only [mul_add, Finset.sum_add_distrib]
        rw [← Finset.mul_sum]
        congr 1
        · apply Finset.sum_congr rfl
          intro i _
          ring
        · ring
  have hrough :
      V ≤ T * (∑ i : ι, a i) +
        T * (∑ i : ι, c i) +
        ρ * T * (∑ i : ι, z i) := by
    rw [hvariance]
    linarith [ha_total, hcz_total, hs_total]
  have h1 : T * (∑ i : ι, a i) ≤ T * (α * B) :=
    mul_le_mul_of_nonneg_left habudget hT
  have h2 : T * (∑ i : ι, c i) ≤ T * (8 * B) :=
    mul_le_mul_of_nonneg_left hcbudget hT
  have h3 : ρ * T * (∑ i : ι, z i) ≤
      (ρ * T) * ((8 + α) * B) := by
    exact mul_le_mul_of_nonneg_left hzbudget
      (mul_nonneg hρ hT)
  nlinarith [h1, h2, h3]

/-- Squared variance–influence endpoint. The source must still provide
the hypotheses for q2_scalar_endpoint, V≥0 and T²=M. -/
theorem q2_scalar_endpoint_squared
    (a c z s : ι → ℝ)
    (B T M α ρ V : ℝ)
    (hB : 0 ≤ B) (hT : 0 ≤ T) (hV : 0 ≤ V)
    (hα : 0 ≤ α) (hρ : 0 ≤ ρ)
    (ha : ∀ i, 0 ≤ a i) (hc : ∀ i, 0 ≤ c i)
    (hz : ∀ i, 0 ≤ z i)
    (haca : ∀ i, a i ≤ T) (hzca : ∀ i, z i ≤ T)
    (hstep : ∀ i, s i ≤ z i * (c i + ρ * T))
    (habudget : (∑ i : ι, a i) ≤ α * B)
    (hcbudget : (∑ i : ι, c i) ≤ 8 * B)
    (hzbudget : (∑ i : ι, z i) ≤ (8 + α) * B)
    (hvariance : V = (∑ i : ι, (a i)^2) + ∑ i : ι, s i)
    (hT_sq : T ^ 2 = M) :
    V ^ 2 ≤ ((8 + α) * (1 + ρ)) ^ 2 * B ^ 2 * M := by
  have hv_le := q2_scalar_endpoint a c z s B T α ρ V
    hB hT hα hρ ha hc hz haca hzca hstep
    habudget hcbudget hzbudget hvariance
  have hcoef : 0 ≤ (8 + α) * (1 + ρ) * B * T := by
    apply mul_nonneg
    apply mul_nonneg
    · apply mul_nonneg <;> linarith
    · exact hB
    · exact hT
  have hsq : V ^ 2 ≤ ((8 + α) * (1 + ρ) * B * T)^2 := by
    nlinarith [mul_nonneg (sub_nonneg.mpr hv_le)
      (add_nonneg hcoef hV)]
  calc
    V ^ 2 ≤ ((8 + α) * (1 + ρ) * B * T)^2 := hsq
    _ = ((8 + α) * (1 + ρ)) ^ 2 * B ^ 2 * M := by
      rw [← hT_sq]
      ring

end Nightfall.Observability.ActualProductQ2ScalarClosure
