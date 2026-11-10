import ProductSpaceTwoSidedBridge

/-!
Finite level-crossing from the kernel-checked product-space two-sided
inequality, conditional on real-function certificate rows. This version
handles thresholds outside the finite range and both nonempty classes.
Turturean's antipodal formalization is the pinned imported input.
Mean-threshold continuity, row-cost degree bounds, and infinite products
remain separate certification obligations.
-/

namespace Nightfall.ProductSpace.LevelCrossing
open Finset Nightfall.ProductSpace Nightfall.ProductSpace.Transfer
variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]

def IsRealRow (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ) : Prop :=
  (∀ x j, 0 ≤ a x j) ∧
    (∀ x y, |f x - f y| ≤ ∑ j ∈ disagree x y, a x j)

noncomputable def thresholdBool (f : (ι → α) → ℝ) (t : ℝ) (x : ι → α) : Bool :=
  decide (t < f x)

noncomputable def thresholdRow (f : (ι → α) → ℝ)
    (a : (ι → α) → ι → ℝ) (t : ℝ) (x : ι → α) (j : ι) : ℝ :=
  a x j / |f x - t|

private theorem abs_threshold_le_difference (u v t : ℝ)
    (hcross : (t < u ∧ v ≤ t) ∨ (u ≤ t ∧ t < v)) :
    |u - t| ≤ |u - v| := by
  rcases hcross with ⟨hu, hv⟩ | ⟨hu, hv⟩
  · rw [abs_of_nonneg (by linarith : 0 ≤ u - t)]
    rw [abs_of_nonneg (by linarith : 0 ≤ u - v)]
    linarith
  · rw [abs_of_nonpos (by linarith : u - t ≤ 0)]
    rw [abs_of_nonpos (by linarith : u - v ≤ 0)]
    linarith

private theorem opposite_thresholds (f : (ι → α) → ℝ) (t : ℝ)
    (x y : ι → α) (h : thresholdBool f t y ≠ thresholdBool f t x) :
    (t < f x ∧ f y ≤ t) ∨ (f x ≤ t ∧ t < f y) := by
  by_cases hx : t < f x
  · by_cases hy : t < f y
    · have : False := h (by simp [thresholdBool, hx, hy])
      exact False.elim this
    · exact Or.inl ⟨hx, le_of_not_gt hy⟩
  · by_cases hy : t < f y
    · exact Or.inr ⟨le_of_not_gt hx, hy⟩
    · have : False := h (by simp [thresholdBool, hx, hy])
      exact False.elim this

theorem thresholdRow_isProductRow
    (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ)
    (hr : IsRealRow f a) (t : ℝ) (ht : ∀ x, f x ≠ t) :
    IsProductRow (thresholdBool f t) (thresholdRow f a t) := by
  constructor
  · intro x j
    exact div_nonneg (hr.1 x j) (abs_nonneg _)
  · intro x y hchange
    have hgap : 0 < |f x - t| := by
      apply abs_pos.mpr
      exact sub_ne_zero.mpr (ht x)
    have hdiff := abs_threshold_le_difference (f x) (f y) t
      (opposite_thresholds f t x y hchange)
    have hbound : |f x - t| ≤ ∑ j ∈ disagree x y, a x j :=
      le_trans hdiff (hr.2 x y)
    change (1 : ℝ) ≤ ∑ j ∈ disagree x y, a x j / |f x - t|
    rw [← Finset.sum_div]
    apply (le_div_iff₀ hgap).2
    simpa using hbound

theorem thresholdRow_norm_pos
    (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ)
    (hr : IsRealRow f a) (t : ℝ) (ht : ∀ x, f x ≠ t)
    (hupper : ∃ x, t < f x) (hlower : ∃ y, f y < t) :
    ∀ x, 0 < ∑ j, thresholdRow f a t x j := by
  have hrow := thresholdRow_isProductRow f a hr t ht
  intro x
  obtain ⟨xupper, hu⟩ := hupper
  obtain ⟨xlower, hl⟩ := hlower
  let y : ι → α := if t < f x then xlower else xupper
  have hdiff : thresholdBool f t y ≠ thresholdBool f t x := by
    by_cases hx : t < f x
    · have hy : ¬ t < f y := by simp [y, hx, not_lt.mpr (le_of_lt hl)]
      simp [thresholdBool, hx, hy]
    · have hy : t < f y := by simp [y, hx, hu]
      simp [thresholdBool, hx, hy]
  have hbase := hrow.2 x y hdiff
  have hle : (∑ j ∈ disagree x y, thresholdRow f a t x j) ≤
      ∑ j, thresholdRow f a t x j := by
    apply Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
    intro j _ _
    exact hrow.1 x j
  linarith

theorem threshold_positive_inverse_cost
    (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ)
    (t : ℝ) (ht : ∀ x, f x ≠ t) (p : ι → α → ℝ) :
    (∑ x : {x : ι → α // thresholdBool f t x = true},
      prodMass p x.1 * invCost (thresholdRow f a t x.1)) =
    ∑ x : {x : ι → α // thresholdBool f t x = true},
      prodMass p x.1 * ((f x.1 - t) * invCost (a x.1)) := by
  apply Finset.sum_congr rfl
  intro x _
  have hx : t < f x.1 := by
    have h := x.2
    simpa [thresholdBool] using h
  have hgap : 0 < |f x.1 - t| := abs_pos.mpr (sub_ne_zero.mpr (ht x.1))
  change prodMass p x.1 * invCost (fun j => a x.1 j / |f x.1 - t|) = _
  rw [invCost_scaled (a x.1) hgap, abs_of_pos (sub_pos.mpr hx)]

theorem threshold_negative_inverse_cost
    (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ)
    (t : ℝ) (ht : ∀ x, f x ≠ t) (p : ι → α → ℝ) :
    (∑ x : {x : ι → α // thresholdBool f t x = false},
      prodMass p x.1 * invCost (thresholdRow f a t x.1)) =
    ∑ x : {x : ι → α // thresholdBool f t x = false},
      prodMass p x.1 * ((t - f x.1) * invCost (a x.1)) := by
  apply Finset.sum_congr rfl
  intro x _
  have hxnot : ¬ t < f x.1 := by
    have h := x.2
    simpa [thresholdBool] using h
  have hx : f x.1 < t := by
    have hxle : f x.1 ≤ t := le_of_not_gt hxnot
    exact lt_of_le_of_ne hxle (ht x.1)
  have hgap : 0 < |f x.1 - t| := abs_pos.mpr (sub_ne_zero.mpr (ht x.1))
  change prodMass p x.1 * invCost (fun j => a x.1 j / |f x.1 - t|) = _
  rw [invCost_scaled (a x.1) hgap]
  rw [abs_of_neg (sub_neg.mpr hx)]
  ring

/-- Finite-product level-crossing inequality for thresholds outside the
range. The reciprocal and positivity conditions are discharged through
the imported one-toolchain product-space theorem. -/
theorem finite_level_crossing
    (p : ι → α → ℝ) (hp : ∀ i b, 0 < p i b)
    (f : (ι → α) → ℝ) (a : (ι → α) → ι → ℝ)
    (hr : IsRealRow f a) (t : ℝ) (ht : ∀ x, f x ≠ t)
    (hupper : ∃ x, t < f x) (hlower : ∃ y, f y < t)
    (M : ℝ) (hM0 : 0 ≤ M)
    (hM : ∀ j, (∑ z, pairMass p z * edgeCross (thresholdBool f t) j z) ≤ M) :
    (∑ x : {x : ι → α // thresholdBool f t x = true},
      prodMass p x.1 * ((f x.1 - t) * invCost (a x.1))) *
    (∑ y : {y : ι → α // thresholdBool f t y = false},
      prodMass p y.1 * ((t - f y.1) * invCost (a y.1))) ≤ M := by
  have hrow := thresholdRow_isProductRow f a hr t ht
  have hnorm := thresholdRow_norm_pos f a hr t ht hupper hlower
  have hresult := two_sided_product p hp (thresholdBool f t)
    (thresholdRow f a t) hrow hnorm M hM0 hM
  rw [threshold_positive_inverse_cost f a t ht p,
      threshold_negative_inverse_cost f a t ht p] at hresult
  exact hresult

end Nightfall.ProductSpace.LevelCrossing
