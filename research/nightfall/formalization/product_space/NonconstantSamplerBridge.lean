import CertificateObservationBridge

/-!
# Eliminate the nonconstant-function positivity side conditions

The composed finite-product overlap sampler previously required both
positive row totals and positive inverse-certificate class masses. Here
both are derived from:
* globally valid nonnegative fractional certificate rows,
* a nonconstant Boolean output with two nonempty classes,
* strictly positive finite-product atom weights.

This is still the finite common-alphabet product result, not an
infinite/measurable product theorem, or a full adaptive-policy theorem.
-/

namespace Nightfall.ProductSpace.Observation

open Finset Nightfall.ProductSpace Nightfall.ProductSpace.Transfer

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Every nonempty positive class has positive inverse-certificate mass
when all product atoms and row totals are positive. -/
theorem positive_class_value_pos
    (p : ι → α → ℝ) (hp : ∀ i a, 0 < p i a)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hnorm : ∀ x, 0 < ∑ j, lam x j)
    (htrue : ∃ x, g x = true) :
    0 < positiveClassValue p g lam := by
  unfold positiveClassValue
  apply Finset.sum_pos'
  · intro x _
    exact mul_nonneg (prodMass_pos p hp x.1).le
      (le_of_lt (inv_pos.mpr (hnorm x.1)))
  · obtain ⟨x, hx⟩ := htrue
    exact ⟨⟨x, hx⟩, Finset.mem_univ _,
      mul_pos (prodMass_pos p hp x) (inv_pos.mpr (hnorm x))⟩

theorem negative_class_value_pos
    (p : ι → α → ℝ) (hp : ∀ i a, 0 < p i a)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hnorm : ∀ x, 0 < ∑ j, lam x j)
    (hfalse : ∃ x, g x = false) :
    0 < negativeClassValue p g lam := by
  unfold negativeClassValue
  apply Finset.sum_pos'
  · intro y _
    exact mul_nonneg (prodMass_pos p hp y.1).le
      (le_of_lt (inv_pos.mpr (hnorm y.1)))
  · obtain ⟨y, hy⟩ := hfalse
    exact ⟨⟨y, hy⟩, Finset.mem_univ _,
      mul_pos (prodMass_pos p hp y) (inv_pos.mpr (hnorm y))⟩

/-- Strictly positive mass of both classes and positive costs follow
from nonconstancy, eliminating both independent normalization premises. -/
theorem nonconstant_sampler_premises
    (p : ι → α → ℝ) (hp : ∀ i a, 0 < p i a)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hrow : IsProductRow g lam)
    (htrue : ∃ x, g x = true) (hfalse : ∃ x, g x = false) :
    (∀ x, 0 < ∑ j, lam x j) ∧
      0 < positiveClassValue p g lam * negativeClassValue p g lam := by
  have hn := row_cost_pos_of_two_classes g lam hrow htrue hfalse
  refine ⟨hn, ?_⟩
  exact mul_pos
    (positive_class_value_pos p hp g lam hn htrue)
    (negative_class_value_pos p hp g lam hn hfalse)

/-- **The nonconstant finite-product overlap sampler without manual
localization, row-cost or class-positivity assumptions.**
All required positivity follows from the finite product and two classes. -/
theorem nonconstant_finite_product_sampler
    (p : ι → α → ℝ) (hp : ∀ i a, 0 < p i a)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hrow : IsProductRow g lam)
    (htrue : ∃ x, g x = true) (hfalse : ∃ x, g x = false) :
    0 < ∑ j, Real.sqrt (positiveLoad p g lam j * negativeLoad p g lam j) ∧
    (positiveClassValue p g lam * negativeClassValue p g lam) ^ 2 ≤
      (∑ j, Real.sqrt (positiveLoad p g lam j * negativeLoad p g lam j)) ^ 2 *
      (∑ j,
        (Real.sqrt (positiveLoad p g lam j * negativeLoad p g lam j) /
        (∑ k, Real.sqrt (positiveLoad p g lam k * negativeLoad p g lam k))) *
        crossingMass p g j) ∧
    positiveClassValue p g lam * negativeClassValue p g lam ≤
      ∑ j,
        (Real.sqrt (positiveLoad p g lam j * negativeLoad p g lam j) /
        (∑ k, Real.sqrt (positiveLoad p g lam k * negativeLoad p g lam k))) *
        crossingMass p g j := by
  obtain ⟨hnorm, hV⟩ :=
    nonconstant_sampler_premises p hp g lam hrow htrue hfalse
  exact finite_product_certificate_sampler p hp g lam hrow hnorm hV

end Nightfall.ProductSpace.Observation
