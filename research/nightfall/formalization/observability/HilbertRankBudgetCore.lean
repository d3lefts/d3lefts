import Mathlib

/-!
# NIGHTFALL — Hilbert quadratic rank-linear terminal from source budgets

These are the *exact finite index* algebraic dependencies of Theorem D (#368).
The missing, logically stronger premise is that actual independent-product
Hilbert-valued degree-two ANOVA sections satisfy these **source-derived**
matching, additive, and oscillation budgets. The budget hypotheses in this
module are NOT claimed to be proved for arbitrary source functions.

The first theorem closes the sharp scalar aggregation of budgets. The second
proves the stated 5043*r constant from the spherical coefficient constraint
a_r² >= 1/(3r). Neither implies the full universal Theorem D1/D2 without
separate source-operator and measurable adaptive-policy theorems.
-/

namespace Nightfall.HilbertRankCore

open Finset

variable {I : Type*} [Fintype I]

/-- From the *actual form* of the source D1 analytical accounting:
the additive variance budget is 7 A R; total matching charge <=8 A;
Hilbert section L1 budget <=15 A; and independent increment fourth
moment bounds each assigned pair variance by (c_i + sqrt(3) R) z_i.
This lemma is a fully quantified and nonasymptotic proof of the final
aggregation; source-to-budget implications remain separately gated. -/
theorem rank_observability_from_budgets
    (v s c z : I → ℝ) (A R : ℝ)
    (hR : 0 ≤ R)
    (hc : ∀ i, 0 ≤ c i)
    (hz : ∀ i, z i ≤ R)
    (hadd : (∑ i, v i) ≤ 7 * A * R)
    (hcost : (∑ i, c i) ≤ 8 * A)
    (hsections : (∑ i, z i) ≤ 15 * A)
    (hassigned : ∀ i, s i ≤ (c i + Real.sqrt 3 * R) * z i) :
    (∑ i, (v i + s i)) ≤
      15 * (1 + Real.sqrt 3) * A * R := by
  have hcostterm : (∑ i, c i * z i) ≤ 8 * A * R := by
    calc
      (∑ i, c i * z i) ≤ ∑ i, c i * R := by
        apply Finset.sum_le_sum
        intro i hi
        exact mul_le_mul_of_nonneg_left (hz i) (hc i)
      _ = (∑ i, c i) * R := by simp only [Finset.sum_mul]
      _ ≤ (8 * A) * R :=
        mul_le_mul_of_nonneg_right hcost hR
  have hsr : 0 ≤ Real.sqrt 3 * R :=
    mul_nonneg (Real.sqrt_nonneg _) hR
  have hsectionterm :
      (Real.sqrt 3 * R) * (∑ i, z i) ≤
        (Real.sqrt 3 * R) * (15 * A) :=
    mul_le_mul_of_nonneg_left hsections hsr
  have hassignedSum :
      (∑ i, s i) ≤ (∑ i, c i * z i) +
        (Real.sqrt 3 * R) * (∑ i, z i) := by
    calc
      (∑ i, s i) ≤ ∑ i, (c i + Real.sqrt 3 * R) * z i := by
        apply Finset.sum_le_sum
        intro i hi
        exact hassigned i
      _ = ∑ i, (c i * z i + (Real.sqrt 3 * R) * z i) := by
        apply Finset.sum_congr rfl
        intro i hi
        ring
      _ = (∑ i, c i * z i) +
            (Real.sqrt 3 * R) * (∑ i, z i) := by
        rw [Finset.sum_add_distrib]
        simp only [Finset.mul_sum]
  calc
    (∑ i, (v i + s i)) = (∑ i, v i) + (∑ i, s i) :=
      Finset.sum_add_distrib
    _ ≤ 7 * A * R +
          ((∑ i, c i * z i) +
            (Real.sqrt 3 * R) * (∑ i, z i)) :=
      add_le_add hadd hassignedSum
    _ ≤ 7 * A * R + (8 * A * R +
        (Real.sqrt 3 * R) * (15 * A)) := by
      gcongr
    _ = 15 * (1 + Real.sqrt 3) * A * R := by ring

/-- Closing the **exact 5043 coefficient** algebraically when the spherical
small-ball coefficient has the source-stated lower bound.
a is the (strictly positive) spherical coefficient; no source theorem
establishing that coefficient for the actual observable is assumed proved. -/
theorem rank_linear_5043_from_spherical
    (V B M a : ℝ) (r : ℕ)
    (hV0 : 0 ≤ V) (hB : 0 ≤ B) (hM : 0 ≤ M) (ha : 0 < a)
    (har : 1 ≤ 3 * (r : ℝ) * a ^ 2)
    (hvariance : V ≤
      (15 * (1 + Real.sqrt 3)) * B * Real.sqrt M / a) :
    V ^ 2 ≤ 5043 * (r : ℝ) * B ^ 2 * M := by
  have h3 : (Real.sqrt 3) ^ 2 = (3 : ℝ) :=
    Real.sq_sqrt (by norm_num)
  have h3pos : 0 ≤ Real.sqrt (3 : ℝ) := Real.sqrt_nonneg _
  have hD : 15 * (1 + Real.sqrt 3) ≤ (41 : ℝ) := by
    nlinarith
  have hvarmul :
      V * a ≤ (15 * (1 + Real.sqrt 3)) * B * Real.sqrt M :=
    (le_div_iff₀ ha).mp hvariance
  have hBR : 0 ≤ B * Real.sqrt M :=
    mul_nonneg hB (Real.sqrt_nonneg _)
  have hvar41 : V * a ≤ 41 * B * Real.sqrt M := by
    calc
      V * a ≤ (15 * (1 + Real.sqrt 3)) * B * Real.sqrt M := hvarmul
      _ ≤ 41 * B * Real.sqrt M := by
        nlinarith [mul_nonneg (sub_nonneg.mpr hD) hBR]
  have hleft : 0 ≤ V * a := mul_nonneg hV0 ha.le
  have hright : 0 ≤ 41 * B * Real.sqrt M := by positivity
  have hsq : (V * a) ^ 2 ≤ (41 * B * Real.sqrt M) ^ 2 := by
    nlinarith [mul_nonneg (sub_nonneg.mpr hvar41)
      (add_nonneg hright hleft)]
  calc
    V ^ 2 = V ^ 2 * 1 := by ring
    _ ≤ V ^ 2 * (3 * (r : ℝ) * a ^ 2) :=
      mul_le_mul_of_nonneg_left har (sq_nonneg V)
    _ = (3 * (r : ℝ)) * (V * a) ^ 2 := by ring
    _ ≤ (3 * (r : ℝ)) * (41 * B * Real.sqrt M) ^ 2 :=
      mul_le_mul_of_nonneg_left hsq (by positivity)
    _ = 5043 * (r : ℝ) * B ^ 2 * M := by
      calc
        (3 * (r : ℝ)) * (41 * B * Real.sqrt M) ^ 2 =
          3 * (r : ℝ) * 41 ^ 2 * B ^ 2 * (Real.sqrt M) ^ 2 := by ring
        _ = 5043 * (r : ℝ) * B ^ 2 * M := by
          rw [Real.sq_sqrt hM]
          ring

end Nightfall.HilbertRankCore

#print axioms Nightfall.HilbertRankCore.rank_observability_from_budgets
#print axioms Nightfall.HilbertRankCore.rank_linear_5043_from_spherical
#print Nightfall.HilbertRankCore.rank_linear_5043_from_spherical
