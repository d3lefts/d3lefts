import Mathlib

/-!
# Binary genuine-conditional variance: exact two-atom source bridge

For one original binary coordinate, fixing all other coordinates leaves two
joint atom masses p,q. This module proves the exact weighted variance formula
and its uniform physical-derivative upper comparison, independently of
coordinate independence, Dobrushin, Ising or a supplied influence bound.

It does NOT prove a full-law Poincare inequality or the all-degree hierarchy.
-/

namespace Nightfall.CubicContractionBinarySource

/-- Conditional quadratic loss for a two-atom fiber, with its actual masses. -/
theorem weighted_pair_variance_eq
    (p q a b : ℝ) (hpos : 0 < p + q) :
    p * (a - (p*a + q*b)/(p+q))^2 +
    q * (b - (p*a + q*b)/(p+q))^2 =
    (p*q/(p+q))*(a-b)^2 := by
  have hne : p + q ≠ 0 := ne_of_gt hpos
  field_simp
  ring

/-- The true two-atom conditional variance coefficient never exceeds 1/4 of total fiber mass. -/
theorem pair_coefficient_le_quarter
    (p q : ℝ) (hpos : 0 < p + q) :
    p*q/(p+q) ≤ (p+q)/4 := by
  apply (div_le_iff₀ hpos).2
  nlinarith [sq_nonneg (p-q)]

/--
The genuine conditional-coordinate energy is bounded by the sum of the
two-mass physical derivative energies on the same original source fibers.
No independent-site or reference-law change.
-/
theorem binary_fiber_influence_le_derivative
    (p q a b : ℝ) (hpos : 0 < p + q) :
    (p*q/(p+q))*(a-b)^2 ≤
    ((p+q)/4)*(a-b)^2 := by
  exact mul_le_mul_of_nonneg_right
    (pair_coefficient_le_quarter p q hpos) (sq_nonneg (a-b))

/-- Finite sum over arbitrary original-law two-state fibers. -/
theorem summed_fiber_influence_le_derivative
    {α : Type*} (s : Finset α) (p q a b : α → ℝ)
    (hpos : ∀ x ∈ s, 0 < p x + q x) :
    (∑ x ∈ s, (p x*q x/(p x+q x))*(a x-b x)^2) ≤
    (∑ x ∈ s, ((p x+q x)/4)*(a x-b x)^2) := by
  apply Finset.sum_le_sum
  intro x hx
  exact binary_fiber_influence_le_derivative
    (p x) (q x) (a x) (b x) (hpos x hx)

#check Nightfall.CubicContractionBinarySource.weighted_pair_variance_eq
#check Nightfall.CubicContractionBinarySource.pair_coefficient_le_quarter
#check Nightfall.CubicContractionBinarySource.binary_fiber_influence_le_derivative
#check Nightfall.CubicContractionBinarySource.summed_fiber_influence_le_derivative
#print axioms Nightfall.CubicContractionBinarySource.weighted_pair_variance_eq
#print axioms Nightfall.CubicContractionBinarySource.summed_fiber_influence_le_derivative

end Nightfall.CubicContractionBinarySource
