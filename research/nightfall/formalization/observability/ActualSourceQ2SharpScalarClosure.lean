import ActualProductQ2ScalarClosure

/-!
# Sharp Q2 scalar closure using one stronger additive source budget

The source-derived endpoint at coefficient
  ((10 + 2 sqrt(2)) (1 + sqrt(3)))² ≈ 1228.3563
requires only the stronger original-source additive budget
  sum_i a_i ≤ 2(1 + sqrt(2)) B
in addition to the already certified source section, matching cover,
owner-wise fourth moment and variance decomposition.

This theorem is NUMERICAL, conditional on an explicit additive budget.
It is not itself the terminal original-source Q2 theorem.
-/

namespace Nightfall.Observability.ActualSourceQ2SharpScalarClosure

open Finset
open Nightfall.Observability.ActualProductQ2ScalarClosure

variable {ι : Type*} [Fintype ι]

/-- Sharp coefficient after deriving the source singleton budget.
Every quantitative budget is visible; no source theorem is assumed. -/
theorem q2_sharp_scalar_from_additive_budget
    (a u c z s : ι → ℝ) (B T M V : ℝ)
    (hB : 0 ≤ B) (hT : 0 ≤ T) (hV : 0 ≤ V)
    (ha : ∀ i, 0 ≤ a i)
    (hc : ∀ i, 0 ≤ c i)
    (hz : ∀ i, 0 ≤ z i)
    (haT : ∀ i, a i ≤ T)
    (hzT : ∀ i, z i ≤ T)
    (hnoise : ∀ i, z i ≤ u i + a i)
    (hsection : (∑ i : ι, u i) ≤ 8 * B)
    (hadditive :
      (∑ i : ι, a i) ≤ (2 * (1 + Real.sqrt 2)) * B)
    (hcover : (∑ i : ι, c i) ≤ 8 * B)
    (hmoment :
      ∀ i, s i ≤ z i * (c i + Real.sqrt 3 * T))
    (hvariance :
      V = (∑ i : ι, (a i)^2) + (∑ i : ι, s i))
    (hT2 : T ^ 2 = M) :
    V ^ 2 ≤
      ((10 + 2 * Real.sqrt 2) * (1 + Real.sqrt 3))^2 *
        B^2 * M := by
  classical
  let A : ℝ := 2 * (1 + Real.sqrt 2)
  have hA : 0 ≤ A := by
    dsimp [A]
    positivity
  have hρ : 0 ≤ Real.sqrt (3 : ℝ) := Real.sqrt_nonneg _
  have hsumnoise :
      (∑ i : ι, z i) ≤
        (∑ i : ι, u i) + (∑ i : ι, a i) := by
    calc
      (∑ i : ι, z i) ≤ ∑ i : ι, (u i + a i) :=
        Finset.sum_le_sum (fun i _ => hnoise i)
      _ = (∑ i : ι, u i) + (∑ i : ι, a i) :=
        Finset.sum_add_distrib
  have hadd : (∑ i : ι, a i) ≤ A * B := hadditive
  have hzbudget :
      (∑ i : ι, z i) ≤ (8 + A) * B := by
    calc
      (∑ i : ι, z i) ≤
        (∑ i : ι, u i) + (∑ i : ι, a i) := hsumnoise
      _ ≤ 8 * B + A * B := add_le_add hsection hadd
      _ = (8 + A) * B := by ring
  have hbound := q2_scalar_endpoint_squared
    a c z s B T M A (Real.sqrt 3) V
    hB hT hV hA hρ ha hc hz haT hzT
    hmoment hadd hcover hzbudget hvariance hT2
  convert hbound using 1 <;> dsimp [A] <;> ring

end Nightfall.Observability.ActualSourceQ2SharpScalarClosure
