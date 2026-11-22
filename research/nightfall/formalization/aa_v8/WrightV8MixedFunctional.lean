import ProductInfluence
import WrightV8MedianMixed

/-!
# Actual product-space mixed crossing numerator budget (v8).
This is a functional, zero-bias-assumption bridge from Turturean's
integrated all-pairs lemma, but not the complete mixed median theorem.
-/

namespace Nightfall.Wright.MixedFunctional

open Finset
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.Transfer
open Nightfall.Wright.SharpMedian

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

noncomputable def downSet (p : ι → α → ℝ)
    (f : (ι → α) → ℝ) (r : ℝ) : Finset (ι → α) :=
  Finset.univ.filter (fun y => f y < r ∧ 0 < prodMass p y)

noncomputable def crossingProduct
    (f : (ι → α) → ℝ) (r : ℝ) (x y : ι → α) : ℝ :=
    ((f x - r) * Real.sqrt (f x - r)) *
      ((r - f y) * Real.sqrt (r - f y))

/-- Real mixed numerator controlled by the original integrated
all-pairs bound. This is the 8-to-1 crossing step before
weight removal, with all law-dependent masses explicit. -/
theorem weighted_mixed_crossing_budget
    (p : ι → α → ℝ) (hp : ∀ i b, 0 ≤ p i b)
    (hp1 : ∀ i, ∑ b, p i b = 1)
    (f : (ι → α) → ℝ)
    (a : (ι → α) → ι → ℝ) (hr : RealRow f a)
    (w : ι → ℝ) (hw : ∀ j, 0 < w j)
    (M : ℝ) (hM : ∀ j, pincr p f j ≤ M) (r : ℝ) :
    8 * (∑ x ∈ upSet p f r,
         ∑ y ∈ downSet p f r,
           (prodMass p x * prodMass p y / pairCost w a x y) *
             crossingProduct f r x y) ≤
      3 * M * ∑ j, (w j)⁻¹ := by
  have hm : ∀ x y : ι → α,
      0 ≤ prodMass p x * prodMass p y / pairCost w a x y := by
    intro x y
    exact div_nonneg
      (mul_nonneg (prodMass_nonneg' p hp x) (prodMass_nonneg' p hp y))
      (pairCost_nonneg w hw a hr.1 x y)
  have ht : ∀ x y : ι → α,
      0 ≤ (prodMass p x * prodMass p y / pairCost w a x y) *
        (max (f x - f y) 0) ^ 3 := by
    intro x y
    exact mul_nonneg (hm x y) (pow_nonneg (le_max_right _ _) 3)
  have hpair : ∀ x ∈ upSet p f r, ∀ y ∈ downSet p f r,
      8 * ((prodMass p x * prodMass p y / pairCost w a x y) *
        crossingProduct f r x y) ≤
      (prodMass p x * prodMass p y / pairCost w a x y) *
        (max (f x - f y) 0) ^ 3 := by
    intro x hx y hy
    have hfx : r < f x := (Finset.mem_filter.mp hx).2.1
    have hfy : f y < r := (Finset.mem_filter.mp hy).2.1
    have hx0 : 0 ≤ f x - r := by linarith
    have hy0 : 0 ≤ r - f y := by linarith
    have hc : 8 * ((f x - r) * Real.sqrt (f x - r)) *
        ((r - f y) * Real.sqrt (r - f y)) ≤
        (f x - f y) ^ 3 :=
      mixed_cube_of_crossing (f x - r) (r - f y) (f x - f y)
        hx0 hy0 (by linarith)
    rw [max_eq_left (show (0 : ℝ) ≤ f x - f y by linarith)]
    unfold crossingProduct
    calc
      8 * ((prodMass p x * prodMass p y / pairCost w a x y) *
          (((f x - r) * Real.sqrt (f x - r)) *
            ((r - f y) * Real.sqrt (r - f y)))) =
        (prodMass p x * prodMass p y / pairCost w a x y) *
          (8 * ((f x - r) * Real.sqrt (f x - r)) *
            ((r - f y) * Real.sqrt (r - f y))) := by ring
      _ ≤ (prodMass p x * prodMass p y / pairCost w a x y) *
          (f x - f y) ^ 3 :=
        mul_le_mul_of_nonneg_left hc (hm x y)
  have hI := integrated_incr p hp hp1 f a hr w hw
  calc
    8 * (∑ x ∈ upSet p f r,
         ∑ y ∈ downSet p f r,
           (prodMass p x * prodMass p y / pairCost w a x y) *
             crossingProduct f r x y) =
      ∑ x ∈ upSet p f r,
        ∑ y ∈ downSet p f r,
          8 * ((prodMass p x * prodMass p y / pairCost w a x y) *
                crossingProduct f r x y) := by
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro x _
          rw [Finset.mul_sum]
    _ ≤ ∑ x ∈ upSet p f r,
          ∑ y ∈ downSet p f r,
            (prodMass p x * prodMass p y / pairCost w a x y) *
              (max (f x - f y) 0) ^ 3 := by
          apply Finset.sum_le_sum
          intro x hx
          apply Finset.sum_le_sum
          intro y hy
          exact hpair x hx y hy
    _ ≤ ∑ x, ∑ y,
            (prodMass p x * prodMass p y / pairCost w a x y) *
              (max (f x - f y) 0) ^ 3 := by
          have hy : ∀ x : ι → α,
              (∑ y ∈ downSet p f r,
                  (prodMass p x * prodMass p y / pairCost w a x y) *
                    (max (f x - f y) 0) ^ 3) ≤
                ∑ y, (prodMass p x * prodMass p y / pairCost w a x y) *
                    (max (f x - f y) 0) ^ 3 := by
            intro x
            exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
              (fun y _ _ => ht x y)
          exact (Finset.sum_le_sum (fun x _ => hy x)).trans
            (Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
              (fun x _ _ => Finset.sum_nonneg (fun y _ => ht x y)))
    _ = 6 * ∑ x, ∑ y,
            (prodMass p x * prodMass p y / pairCost w a x y) *
              ((max (f x - f y) 0) ^ 3 / 6) := by
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro x _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro y _
          ring
    _ ≤ 6 * ∑ j, pincr p f j / (2 * w j) :=
          mul_le_mul_of_nonneg_left hI (by norm_num)
    _ ≤ 3 * M * ∑ j, (w j)⁻¹ := by
          rw [Finset.mul_sum, Finset.mul_sum]
          apply Finset.sum_le_sum
          intro j _
          calc
            6 * (pincr p f j / (2 * w j)) =
                (3 * pincr p f j) * (w j)⁻¹ := by ring
            _ ≤ (3 * M) * (w j)⁻¹ :=
              mul_le_mul_of_nonneg_right
                (by linarith [hM j]) (inv_nonneg.mpr (hw j).le)

end Nightfall.Wright.MixedFunctional
