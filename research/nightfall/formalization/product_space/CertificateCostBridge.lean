import NonconstantSamplerBridge

/-!
# NIGHTFALL finite product certificate-cost bridge

A globally valid fractional row of total cost at most K has inverse
cost at least 1/K. Summing over both output classes gives the exact
mass-to-certificate-cost comparison needed for the claimed adaptive
observation rate. With normalized product masses, the product of the
two output-class masses is the Boolean variance.

This module does not assert any degree bound, actual posterior measure
theorem, or end-to-end MSE policy. All statements are deterministic
finite-dimensional consequences of the real-valued row inequalities.
-/

namespace Nightfall.ProductSpace.Observation

open Finset Nightfall.ProductSpace Nightfall.ProductSpace.Transfer

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

def positiveClassMass (p : ι → α → ℝ) (g : (ι → α) → Bool) : ℝ :=
  ∑ x : {x : ι → α // g x = true}, prodMass p x.1

def negativeClassMass (p : ι → α → ℝ) (g : (ι → α) → Bool) : ℝ :=
  ∑ y : {y : ι → α // g y = false}, prodMass p y.1

/-- Positive certificate-row cost bounded by K implies inverse cost
at least 1/K, in any dimension. -/
theorem inverse_cost_at_least_inverse_budget
    (r : ι → ℝ) (K : ℝ)
    (hK : 0 < K) (hpos : 0 < ∑ j, r j)
    (hbound : (∑ j, r j) ≤ K) :
    K⁻¹ ≤ invCost r := by
  unfold invCost
  exact (inv_le_inv₀ hK hpos).2 hbound

/-- Weighted positive-class mass is at most K times its classwise
mass-weighted inverse certificate cost. -/
theorem positive_class_mass_le_cost
    (p : ι → α → ℝ) (hp : ∀ i a, 0 < p i a)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (K : ℝ) (hK : 0 < K)
    (hnorm : ∀ x, 0 < ∑ j, lam x j)
    (hbounded : ∀ x, (∑ j, lam x j) ≤ K) :
    positiveClassMass p g / K ≤ positiveClassValue p g lam := by
  unfold positiveClassMass positiveClassValue
  rw [Finset.sum_div]
  apply Finset.sum_le_sum
  intro x _
  have hinv := inverse_cost_at_least_inverse_budget
    (lam x.1) K hK (hnorm x.1) (hbounded x.1)
  have hmul := mul_le_mul_of_nonneg_left hinv (prodMass_pos p hp x.1).le
  simpa [div_eq_mul_inv] using hmul

theorem negative_class_mass_le_cost
    (p : ι → α → ℝ) (hp : ∀ i a, 0 < p i a)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (K : ℝ) (hK : 0 < K)
    (hnorm : ∀ x, 0 < ∑ j, lam x j)
    (hbounded : ∀ x, (∑ j, lam x j) ≤ K) :
    negativeClassMass p g / K ≤ negativeClassValue p g lam := by
  unfold negativeClassMass negativeClassValue
  rw [Finset.sum_div]
  apply Finset.sum_le_sum
  intro y _
  have hinv := inverse_cost_at_least_inverse_budget
    (lam y.1) K hK (hnorm y.1) (hbounded y.1)
  have hmul := mul_le_mul_of_nonneg_left hinv (prodMass_pos p hp y.1).le
  simpa [div_eq_mul_inv] using hmul

/-- **Certificate cost-to-Boolean variance interface.**
For normalized coordinate masses, the left side is Var(g); the actual
normalization identity is proved separately in PR #303.
Both row positivity and class positivity follow from nonconstancy. -/
theorem class_mass_product_le_certificate_cost
    (p : ι → α → ℝ) (hp : ∀ i a, 0 < p i a)
    (g : (ι → α) → Bool) (lam : (ι → α) → ι → ℝ)
    (hrow : IsProductRow g lam)
    (htrue : ∃ x, g x = true) (hfalse : ∃ x, g x = false)
    (K : ℝ) (hK : 0 < K)
    (hbounded : ∀ x, (∑ j, lam x j) ≤ K) :
    positiveClassMass p g * negativeClassMass p g ≤
      K ^ 2 * (positiveClassValue p g lam * negativeClassValue p g lam) := by
  have hnorm := row_cost_pos_of_two_classes g lam hrow htrue hfalse
  have h1 := positive_class_mass_le_cost p hp g lam K hK hnorm hbounded
  have h0 := negative_class_mass_le_cost p hp g lam K hK hnorm hbounded
  have h1' : positiveClassMass p g ≤ K * positiveClassValue p g lam := by
    simpa only [mul_comm] using (div_le_iff₀ hK).mp h1
  have h0' : negativeClassMass p g ≤ K * negativeClassValue p g lam := by
    simpa only [mul_comm] using (div_le_iff₀ hK).mp h0
  have hm0 : 0 ≤ negativeClassMass p g := by
    unfold negativeClassMass
    exact Finset.sum_nonneg (fun y _ => (prodMass_pos p hp y.1).le)
  have hV1 : 0 ≤ K * positiveClassValue p g lam := by
    exact mul_nonneg hK.le
      (positive_class_value_pos p hp g lam hnorm htrue).le
  calc
    positiveClassMass p g * negativeClassMass p g ≤
        (K * positiveClassValue p g lam) *
        (K * negativeClassValue p g lam) :=
      mul_le_mul h1' h0' hm0 hV1
    _ = K ^ 2 * (positiveClassValue p g lam * negativeClassValue p g lam) := by
      ring

end Nightfall.ProductSpace.Observation
