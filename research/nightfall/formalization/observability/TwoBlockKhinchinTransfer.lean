import Mathlib

/-!
# Exact two-independent-block iteration of a row L1/L2 inequality

The analytic sharp one-block vector Khintchine inequality is an explicit
hypothesis. These theorems rigorously compose TWO independent averaging
operations, giving the exact factor 2 from two factors sqrt(2), with no
expectation-of-maximum interchange.

These results are NOT the missing arbitrary-family vector Khintchine theorem.
-/

namespace Nightfall.CubicQ3.TwoBlockTransfer

open Finset

/-- Composition of two pointwise row L1/L2 inequalities with fully explicit
finite original sampling weights and arbitrary nonnegative comparison factors. -/
theorem two_block_l1_l2_transfer
    {ι U W : Type*} [Fintype ι] [Fintype U] [Fintype W]
    (pU : U → ℝ) (pW : W → ℝ)
    (s : ι → U → W → ℝ) (mid : ι → W → ℝ) (q : ι → ℝ)
    (K₁ K₂ : ℝ)
    (hpW : ∀ w, 0 ≤ pW w)
    (hK₁ : 0 ≤ K₁) (hK₂ : 0 ≤ K₂)
    (hfirst : ∀ i w, mid i w ≤ K₁ * (∑ u, pU u * s i u w))
    (hsecond : ∀ i, Real.sqrt (q i) ≤ K₂ * (∑ w, pW w * mid i w)) :
    ∀ i, Real.sqrt (q i) ≤
      (K₁ * K₂) * (∑ w, pW w * (∑ u, pU u * s i u w)) := by
  intro i
  have hweighted :
      (∑ w, pW w * mid i w) ≤
        (∑ w, pW w * (K₁ * (∑ u, pU u * s i u w))) := by
    apply Finset.sum_le_sum
    intro w _
    exact mul_le_mul_of_nonneg_left (hfirst i w) (hpW w)
  have hrewrite :
      (∑ w, pW w * (K₁ * (∑ u, pU u * s i u w))) =
        K₁ * (∑ w, pW w * (∑ u, pU u * s i u w)) := by
    calc
      _ = (∑ w, K₁ * (pW w * (∑ u, pU u * s i u w))) := by
        apply Finset.sum_congr rfl
        intro w _
        ring
      _ = K₁ * (∑ w, pW w * (∑ u, pU u * s i u w)) := by
        rw [Finset.mul_sum]
  have hdouble := mul_le_mul_of_nonneg_left hweighted hK₂
  have hsecond_i := hsecond i
  rw [hrewrite] at hdouble
  nlinarith

/-- With the sharp one-block coefficient √2 *supplied* in each block, their
iterated row estimate has coefficient 2, with exact rational arithmetic. -/
theorem two_block_sharp_factor_two
    {ι U W : Type*} [Fintype ι] [Fintype U] [Fintype W]
    (pU : U → ℝ) (pW : W → ℝ)
    (s : ι → U → W → ℝ) (mid : ι → W → ℝ) (q : ι → ℝ)
    (hpW : ∀ w, 0 ≤ pW w)
    (hfirst : ∀ i w, mid i w ≤
      Real.sqrt (2 : ℝ) * (∑ u, pU u * s i u w))
    (hsecond : ∀ i, Real.sqrt (q i) ≤
      Real.sqrt (2 : ℝ) * (∑ w, pW w * mid i w)) :
    ∀ i, Real.sqrt (q i) ≤
      2 * (∑ w, pW w * (∑ u, pU u * s i u w)) := by
  intro i
  have h := two_block_l1_l2_transfer pU pW s mid q
    (Real.sqrt (2 : ℝ)) (Real.sqrt (2 : ℝ)) hpW
    (Real.sqrt_nonneg _) (Real.sqrt_nonneg _) hfirst hsecond i
  have hroot : Real.sqrt (2 : ℝ) * Real.sqrt (2 : ℝ) = 2 := by
    rw [← pow_two, Real.sq_sqrt (by norm_num)]
  rw [hroot] at h
  exact h

end Nightfall.CubicQ3.TwoBlockTransfer
