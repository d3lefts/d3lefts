import Mathlib

/-!
# Likelihood overlap transfer, finite and assumption-explicit
The finite test and overlap transfer need NO positivity of atoms; only nonnegative
probability weights. The caller must derive the conditional-mean closeness from
an actual product-degree theorem. This file cannot certify that premise.
-/
namespace Nightfall.ProductSpace.LatentComponent

open Finset
variable {β : Type} [Fintype β] [DecidableEq β]

noncomputable def errorP (p q : β → ℝ) : ℝ :=
  ∑ z, if q z ≤ p z then (0 : ℝ) else p z
noncomputable def errorQ (p q : β → ℝ) : ℝ :=
  ∑ z, if q z ≤ p z then q z else (0 : ℝ)
noncomputable def overlap (p q : β → ℝ) : ℝ :=
  ∑ z, min (p z) (q z)

/-- The sum of the two likelihood errors is exactly the mass overlap. -/
theorem likelihood_error_eq_overlap (p q : β → ℝ) :
    errorP p q + errorQ p q = overlap p q := by
  unfold errorP errorQ overlap
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro z _
  by_cases h : q z ≤ p z
  · simp [h, min_eq_right h]
  · have h' : p z ≤ q z := le_of_lt (lt_of_not_ge h)
    simp [h, min_eq_left h']

/-- A positive margin, two concentration bounds, and a residual mean bound
    force local misclassification cost. -/
theorem margin_forces_bad_mass (a b mp mq eps bp bq g : ℝ)
    (hgap : g = |a - b| - 2 * eps)
    (hmean : |mp - mq| ≤ g / 2)
    (hp : |mp - a| ≤ eps + bp)
    (hq : |mq - b| ≤ eps + bq) :
    g / 2 ≤ bp + bq := by
  have htri1 := abs_add_le (a - mp) (mp - mq)
  have htri2 := abs_add_le ((a - mp) + (mp - mq)) (mq - b)
  have hsum : |a - b| ≤ |a - mp| + |mp - mq| + |mq - b| := by
    have heq : (a - mp) + (mp - mq) + (mq - b) = a - b := by ring
    rw [heq] at htri2
    linarith
  rw [abs_sub_comm] at hp
  linarith

/-- Local costs bound the total overlap under nonnegative likelihood weights. -/
theorem overlap_from_local_bad
    (p q bp bq : β → ℝ) (g : ℝ)
    (hp : ∀ z, 0 ≤ p z) (hq : ∀ z, 0 ≤ q z)
    (hbp : ∀ z, 0 ≤ bp z) (hbq : ∀ z, 0 ≤ bq z)
    (hlocal : ∀ z, g / 2 ≤ bp z + bq z) :
    (g / 2) * overlap p q ≤ (∑ z, p z * bp z) + (∑ z, q z * bq z) := by
  unfold overlap
  rw [Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro z _
  have hmin : 0 ≤ min (p z) (q z) := le_min (hp z) (hq z)
  have h1 := mul_le_mul_of_nonneg_right (hlocal z) hmin
  have h2 := mul_le_mul_of_nonneg_right (min_le_left (p z) (q z)) (hbp z)
  have h3 := mul_le_mul_of_nonneg_right (min_le_right (p z) (q z)) (hbq z)
  nlinarith

/-- Two-component likelihood classification bound from per-leaf conditional
    expectation and failure bounds. Every conditional premise is exposed. -/
theorem likelihood_error_le_of_conditional_bounds
    (p q bp bq : β → ℝ) (mp mq : β → ℝ)
    (a b eps rho g : ℝ)
    (hg : 0 < g) (hgap : g = |a - b| - 2 * eps)
    (hp : ∀ z, 0 ≤ p z) (hq : ∀ z, 0 ≤ q z)
    (hbp : ∀ z, 0 ≤ bp z) (hbq : ∀ z, 0 ≤ bq z)
    (hmean : ∀ z, |mp z - mq z| ≤ g / 2)
    (hconcP : ∀ z, |mp z - a| ≤ eps + bp z)
    (hconcQ : ∀ z, |mq z - b| ≤ eps + bq z)
    (hglobalP : (∑ z, p z * bp z) ≤ rho)
    (hglobalQ : (∑ z, q z * bq z) ≤ rho) :
    errorP p q + errorQ p q ≤ 4 * rho / g := by
  have hloc : ∀ z, g / 2 ≤ bp z + bq z := fun z =>
    margin_forces_bad_mass a b (mp z) (mq z) eps (bp z) (bq z) g hgap
      (hmean z) (hconcP z) (hconcQ z)
  have hmass := overlap_from_local_bad p q bp bq g hp hq hbp hbq hloc
  rw [likelihood_error_eq_overlap]
  apply (le_div_iff₀ hg).2
  nlinarith

end Nightfall.ProductSpace.LatentComponent
