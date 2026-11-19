import Mathlib

/-!
# Strong simulation: finite weighted overlap, proof candidate

**Status:** source draft, NOT kernel-checked. The current session has no Lean/Lake
executable; no theorem in this file is claimed certified.

The finite-arithmetic consequence of the component separation argument is
proved with no global axioms. The analytic Bernstein input, the pointwise
conditional mean-to-tail implication, Hellinger tensorization, and the
conditional-tree assembly still need formal adapters.

This file is intentionally not imported by the integrated root until
an exact-source pinned Lake build succeeds.
-/

namespace Nightfall.StrongSimulation

/-- If every atom pays at least a common error gap, the weighted overlap
of two finite measures is controlled by their two weighted error budgets.
This is the finite Step-4 inequality, valid for unnormalized measures too. -/
theorem weighted_overlap_le_errors
    {α : Type*} [DecidableEq α] (s : Finset α)
    (p q errP errQ : α → ℝ) (gap : ℝ)
    (hp : ∀ x ∈ s, 0 ≤ p x)
    (hq : ∀ x ∈ s, 0 ≤ q x)
    (heP : ∀ x ∈ s, 0 ≤ errP x)
    (heQ : ∀ x ∈ s, 0 ≤ errQ x)
    (hgap : ∀ x ∈ s, gap ≤ errP x + errQ x) :
    gap * (∑ x ∈ s, min (p x) (q x)) ≤
      (∑ x ∈ s, p x * errP x) +
      (∑ x ∈ s, q x * errQ x) := by
  calc
    gap * (∑ x ∈ s, min (p x) (q x)) =
        ∑ x ∈ s, gap * min (p x) (q x) := by
          rw [Finset.mul_sum]
    _ ≤ ∑ x ∈ s, (p x * errP x + q x * errQ x) := by
      apply Finset.sum_le_sum
      intro x hx
      have hmin : 0 ≤ min (p x) (q x) := le_min (hp x hx) (hq x hx)
      have hg : gap * min (p x) (q x) ≤
          (errP x + errQ x) * min (p x) (q x) :=
        mul_le_mul_of_nonneg_right (hgap x hx) hmin
      have h1 : min (p x) (q x) * errP x ≤ p x * errP x :=
        mul_le_mul_of_nonneg_right (min_le_left (p x) (q x)) (heP x hx)
      have h2 : min (p x) (q x) * errQ x ≤ q x * errQ x :=
        mul_le_mul_of_nonneg_right (min_le_right (p x) (q x)) (heQ x hx)
      calc
        gap * min (p x) (q x) ≤
            (errP x + errQ x) * min (p x) (q x) := hg
        _ = min (p x) (q x) * errP x +
            min (p x) (q x) * errQ x := by ring
        _ ≤ p x * errP x + q x * errQ x := add_le_add h1 h2
    _ = (∑ x ∈ s, p x * errP x) +
          (∑ x ∈ s, q x * errQ x) := by
            rw [Finset.sum_add_distrib]

/-- Step-3 arithmetic: a small separation of the two conditional means,
plus two mean-to-tail bounds, forces the sum of the two tail masses to pay
for the gap between candidate outputs. -/
theorem separation_paid_by_error
    (u v meanP meanQ eps errP errQ : ℝ)
    (hp : |u - meanP| ≤ eps + errP)
    (hq : |meanQ - v| ≤ eps + errQ)
    (hm : |meanP - meanQ| ≤ eps) :
    |u - v| ≤ 3 * eps + errP + errQ := by
  have htri₁ : |(u - meanP) + (meanP - meanQ)| ≤
      |u - meanP| + |meanP - meanQ| := abs_add_le _ _
  have htri₂ :
      |((u - meanP) + (meanP - meanQ)) + (meanQ - v)| ≤
      |(u - meanP) + (meanP - meanQ)| + |meanQ - v| := abs_add_le _ _
  have heq : u - v =
      ((u - meanP) + (meanP - meanQ)) + (meanQ - v) := by ring
  rw [heq]
  linarith

end Nightfall.StrongSimulation
