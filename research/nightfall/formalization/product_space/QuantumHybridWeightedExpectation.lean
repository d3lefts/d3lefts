import Mathlib

/-!
# Weighted conditional mismatch: Jensen-to-hybrid finite expectation bridge

No quantum hybrid oracle lemma is assumed in the two results below.
We prove the finite probability arithmetic needed to turn per-coordinate
conditional mismatch bounds into bounds on the expected square root of
a query-weighted discrepancy. This remains distinct from proving the
actual quantum query hybrid inequality and coherent alphabet reduction.

The independent coordinate mismatch probabilities can be arbitrarily
dependent across coordinates; only one-coordinate marginal bounds matter.
No positive atom margin is assumed.
-/

namespace Nightfall.QuantumHybridWeightedExpectation

open Finset

/-- Concavity of sqrt in a finite probability space, with only a bound
on its second moment's integrand. The proof uses the tangent-square
inequality and handles strictly positive lambda. -/
theorem weighted_sqrt_le_sqrt_budget
    {Ω : Type*} [Fintype Ω]
    (π z : Ω → ℝ) (λ : ℝ)
    (hπ0 : ∀ y, 0 ≤ π y)
    (hπsum : (∑ y : Ω, π y) = 1)
    (hz : ∀ y, 0 ≤ z y)
    (hλ : 0 < λ)
    (hbudget : (∑ y : Ω, π y * z y) ≤ λ) :
    (∑ y : Ω, π y * Real.sqrt (z y)) ≤ Real.sqrt λ := by
  have hr : 0 < Real.sqrt λ := Real.sqrt_pos.2 hλ
  have hr2 : (Real.sqrt λ) ^ 2 = λ :=
    Real.sq_sqrt (le_of_lt hλ)
  have hpoint : ∀ y : Ω,
      2 * Real.sqrt λ * Real.sqrt (z y) ≤ z y + λ := by
    intro y
    have hsq : 0 ≤ (Real.sqrt (z y) - Real.sqrt λ) ^ 2 :=
      sq_nonneg _
    have hszy : (Real.sqrt (z y)) ^ 2 = z y :=
      Real.sq_sqrt (hz y)
    nlinarith
  have hterm : ∀ y : Ω,
      2 * Real.sqrt λ * (π y * Real.sqrt (z y)) ≤
        π y * z y + π y * λ := by
    intro y
    have h := mul_le_mul_of_nonneg_left (hpoint y) (hπ0 y)
    nlinarith
  have hsum : 2 * Real.sqrt λ *
      (∑ y : Ω, π y * Real.sqrt (z y)) ≤
        (∑ y : Ω, π y * z y) + λ := by
    calc
      2 * Real.sqrt λ * (∑ y : Ω, π y * Real.sqrt (z y))
          = ∑ y : Ω, 2 * Real.sqrt λ * (π y * Real.sqrt (z y)) := by
              rw [Finset.mul_sum]
      _ ≤ ∑ y : Ω, (π y * z y + π y * λ) :=
        Finset.sum_le_sum (fun y _ => hterm y)
      _ = (∑ y : Ω, π y * z y) +
            (∑ y : Ω, π y * λ) := by rw [Finset.sum_add_distrib]
      _ = (∑ y : Ω, π y * z y) + λ := by
        rw [← Finset.sum_mul, hπsum, one_mul]
  have hscaled : (2 * Real.sqrt λ) *
      (∑ y : Ω, π y * Real.sqrt (z y)) ≤
        (2 * Real.sqrt λ) * Real.sqrt λ := by
    nlinarith [hbudget, hr2]
  exact (mul_le_mul_left (by positivity : 0 < 2 * Real.sqrt λ)).mp hscaled

/-- A normalized query-index distribution assigns expected mismatch mass
at most lambda if the one-coordinate conditional mismatch probabilities
are each at most lambda. This needs no independence of the mismatch events. -/
theorem query_weighted_mismatch_mean_le
    {ι Ω : Type*} [Fintype ι] [Fintype Ω]
    (π : Ω → ℝ) (w : ι → ℝ) (mismatch : ι → Ω → ℝ) (λ : ℝ)
    (hw0 : ∀ i, 0 ≤ w i)
    (hwsum : (∑ i : ι, w i) = 1)
    (hmarg : ∀ i, (∑ y : Ω, π y * mismatch i y) ≤ λ) :
    (∑ y : Ω, π y * (∑ i : ι, w i * mismatch i y)) ≤ λ := by
  calc
    (∑ y : Ω, π y * (∑ i : ι, w i * mismatch i y))
        = ∑ y : Ω, ∑ i : ι, w i * (π y * mismatch i y) := by
            apply Finset.sum_congr rfl
            intro y hy
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro i hi
            ring
    _ = ∑ i : ι, ∑ y : Ω, w i * (π y * mismatch i y) :=
      Finset.sum_comm
    _ = ∑ i : ι, w i * (∑ y : Ω, π y * mismatch i y) := by
      apply Finset.sum_congr rfl
      intro i hi
      rw [Finset.mul_sum]
    _ ≤ ∑ i : ι, w i * λ := by
      apply Finset.sum_le_sum
      intro i hi
      exact mul_le_mul_of_nonneg_left (hmarg i) (hw0 i)
    _ = λ := by rw [← Finset.sum_mul, hwsum, one_mul]

/-- The Jensen consequence used at each quantum query. Conditional
discrepancy indicators may be dependent across coordinates. -/
theorem query_weighted_sqrt_discrepancy_le
    {ι Ω : Type*} [Fintype ι] [Fintype Ω]
    (π : Ω → ℝ) (w : ι → ℝ) (mismatch : ι → Ω → ℝ) (λ : ℝ)
    (hπ0 : ∀ y, 0 ≤ π y)
    (hπsum : (∑ y : Ω, π y) = 1)
    (hw0 : ∀ i, 0 ≤ w i)
    (hwsum : (∑ i : ι, w i) = 1)
    (hmis0 : ∀ i y, 0 ≤ mismatch i y)
    (hλ : 0 < λ)
    (hmarg : ∀ i, (∑ y : Ω, π y * mismatch i y) ≤ λ) :
    (∑ y : Ω, π y *
        Real.sqrt (∑ i : ι, w i * mismatch i y)) ≤ Real.sqrt λ := by
  apply weighted_sqrt_le_sqrt_budget π
    (fun y => ∑ i : ι, w i * mismatch i y)
    λ hπ0 hπsum
  · intro y
    apply Finset.sum_nonneg
    intro i hi
    exact mul_nonneg (hw0 i) (hmis0 i y)
  · exact hλ
  · exact query_weighted_mismatch_mean_le π w mismatch λ hw0 hwsum hmarg

end Nightfall.QuantumHybridWeightedExpectation
