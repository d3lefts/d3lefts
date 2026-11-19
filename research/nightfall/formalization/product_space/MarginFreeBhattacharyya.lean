import Mathlib
import ComponentIdentification
import MarginFreeFiniteTests

/-!
# Hellinger/Bhattacharyya finite-product tensorization

A genuine source-level tensor identity for arbitrary finite alphabets and
zero-probability atoms. It is independent of minimum atom probability.

No analytic expectation stability or Hellinger-vs-total-variation inequality
is assumed or asserted in this file.
-/

namespace Nightfall.MarginFreeBhattacharyya

open Finset
open Nightfall.ComponentIdentification

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Bhattacharyya overlap factors over an arbitrary finite product,
including source alphabets that contain zero-mass symbols. -/
theorem affinity_tensorization (p q : ι → α → ℝ) :
    (∑ x : ι → α, ∏ i : ι, Real.sqrt (p i (x i) * q i (x i))) =
      ∏ i : ι, ∑ a : α, Real.sqrt (p i a * q i a) := by
  rw [Finset.prod_univ_sum, Fintype.piFinset_univ]

theorem product_sqrt (p q : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a) (hq : ∀ i a, 0 ≤ q i a)
    (x : ι → α) :
    Real.sqrt ((∏ i : ι, p i (x i)) * (∏ i : ι, q i (x i))) =
      ∏ i : ι, Real.sqrt (p i (x i) * q i (x i)) := by
  have hmul :
      (∏ i : ι, p i (x i)) * (∏ i : ι, q i (x i)) =
        ∏ i : ι, p i (x i) * q i (x i) := by
    rw [Finset.prod_mul_distrib]
  rw [hmul]
  exact Real.sqrt_prod Finset.univ (fun i _ => mul_nonneg (hp i (x i)) (hq i (x i)))

/-- The exact two-sided Bayes error for product laws never exceeds the
product of their coordinate Bhattacharyya coefficients. This is the
finite source-level tensorization needed in the identification test. -/
theorem bayes_error_le_product_affinity (p q : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a) (hq : ∀ i a, 0 ≤ q i a) :
    (∑ x : ι → α, min (∏ i : ι, p i (x i)) (∏ i : ι, q i (x i))) ≤
      ∏ i : ι, ∑ a : α, Real.sqrt (p i a * q i a) := by
  calc
    (∑ x : ι → α, min (∏ i : ι, p i (x i)) (∏ i : ι, q i (x i)))
        ≤ ∑ x : ι → α,
            Real.sqrt ((∏ i : ι, p i (x i)) * (∏ i : ι, q i (x i))) := by
          apply Finset.sum_le_sum
          intro x _
          apply min_le_sqrt_mul
          · exact Finset.prod_nonneg (fun i _ => hp i (x i))
          · exact Finset.prod_nonneg (fun i _ => hq i (x i))
    _ = ∑ x : ι → α, ∏ i : ι, Real.sqrt (p i (x i) * q i (x i)) := by
          apply Finset.sum_congr rfl
          intro x _
          exact product_sqrt p q hp hq x
    _ = _ := affinity_tensorization p q

end Nightfall.MarginFreeBhattacharyya
