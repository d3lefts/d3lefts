import Mathlib

/-!
# NIGHTFALL v8: mixed-moment algebra for the sharper two-sided median

This file certifies the *numerical and pairwise* steps of the v8 median
improvement, not the functional median inequality for arbitrary product laws.
The remaining bridge is a weighted mixed-third-moment consequence of the
actual product-space integrated all-pairs theorem and localized weight removal.

No FHKL, median, row, or product-space estimate is assumed or postulated here.
The statements are concrete real inequalities with explicit hypotheses.
-/

namespace Nightfall.Wright.SharpMedian

open Finset

/-- The exact sharp cubic AM--GM factor in the cross-median term. -/
theorem mixed_cube_amgm (u v : ℝ) (hu : 0 ≤ u) (hv : 0 ≤ v) :
    8 * (u * Real.sqrt u) * (v * Real.sqrt v) ≤ (u + v) ^ 3 := by
  let s : ℝ := Real.sqrt u
  let t : ℝ := Real.sqrt v
  have hs : s ^ 2 = u := Real.sq_sqrt hu
  have ht : t ^ 2 = v := Real.sq_sqrt hv
  have hst : 0 ≤ 2 * (s * t) := by
    dsimp [s, t]
    positivity
  have hamgm : 2 * (s * t) ≤ u + v := by
    nlinarith [sq_nonneg (s - t)]
  have hpow : (2 * (s * t)) ^ 3 ≤ (u + v) ^ 3 :=
    pow_le_pow_left₀ hst hamgm 3
  calc
    8 * (u * Real.sqrt u) * (v * Real.sqrt v) =
        8 * (s ^ 2 * s) * (t ^ 2 * t) := by
          change 8 * (u * s) * (v * t) = 8 * (s ^ 2 * s) * (t ^ 2 * t)
          rw [hs, ht]
    _ = (2 * (s * t)) ^ 3 := by ring
    _ ≤ (u + v) ^ 3 := hpow

/-- Applies the mixed-cubic inequality to a pair crossing an arbitrary level. -/
theorem mixed_cube_of_crossing (u v δ : ℝ)
    (hu : 0 ≤ u) (hv : 0 ≤ v) (hδ : u + v ≤ δ) :
    8 * (u * Real.sqrt u) * (v * Real.sqrt v) ≤ δ ^ 3 := by
  exact (mixed_cube_amgm u v hu hv).trans
    (pow_le_pow_left₀ (add_nonneg hu hv) hδ 3)

/-- Finite weighted all-pairs bridge. The only geometric input is the
    actual crossing difference bound u(x)+v(y) ≤ delta(x,y).
    This is the numerator comparison needed for v8's mixed-moment argument. -/
theorem weighted_mixed_pair_dominance
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (A : Finset α) (B : Finset β)
    (m : α → ℝ) (n : β → ℝ)
    (u : α → ℝ) (v : β → ℝ)
    (delta cost : α → β → ℝ)
    (hm : ∀ x ∈ A, 0 ≤ m x)
    (hn : ∀ y ∈ B, 0 ≤ n y)
    (hu : ∀ x ∈ A, 0 ≤ u x)
    (hv : ∀ y ∈ B, 0 ≤ v y)
    (hc : ∀ x ∈ A, ∀ y ∈ B, 0 < cost x y)
    (hcross : ∀ x ∈ A, ∀ y ∈ B, u x + v y ≤ delta x y) :
    (∑ x ∈ A, ∑ y ∈ B,
      m x * n y / cost x y *
        (8 * (u x * Real.sqrt (u x)) * (v y * Real.sqrt (v y)))) ≤
    (∑ x ∈ A, ∑ y ∈ B,
      m x * n y / cost x y * (delta x y) ^ 3) := by
  apply Finset.sum_le_sum
  intro x hx
  apply Finset.sum_le_sum
  intro y hy
  exact mul_le_mul_of_nonneg_left
    (mixed_cube_of_crossing (u x) (v y) (delta x y)
      (hu x hx) (hv y hy) (hcross x hx y hy))
    (div_nonneg (mul_nonneg (hm x hx) (hn y hy)) (hc x hx y hy).le)

/-- Elementary cube-root elimination for nonnegative normalized moments. -/
theorem le_one_of_cube_le_one (x : ℝ) (hx : 0 ≤ x) (h : x ^ 3 ≤ 1) :
    x ≤ 1 := by
  by_contra hnot
  have hx1 : (1 : ℝ) < x := lt_of_not_ge hnot
  have hfac : 0 < (x - 1) * (x ^ 2 + x + 1) := by
    apply mul_pos (by linarith)
    nlinarith [sq_nonneg x]
  nlinarith [hfac]

/-- The complete dimensionless 5/4 optimization from normalized third
    moments, Hölder cubes, and the mixed-crossing product budget.

    In the analytic proof, a,b are normalized 3/2 moments and
    x,y are normalized second moments. The additional functional
    inequalities producing these hypotheses are not proved here. -/
theorem normalized_two_sided_median
    (a b x y : ℝ)
    (ha0 : 0 ≤ a) (hb0 : 0 ≤ b)
    (ha1 : a ≤ 1) (hb1 : b ≤ 1)
    (hx0 : 0 ≤ x) (hy0 : 0 ≤ y)
    (hab : a * b ≤ 1 / 8)
    (hx : x ^ 3 ≤ a ^ 2) (hy : y ^ 3 ≤ b ^ 2) :
    x + y ≤ 5 / 4 := by
  have ha2 : a ^ 2 ≤ 1 := by
    nlinarith [mul_nonneg ha0 (sub_nonneg.mpr ha1)]
  have hb2 : b ^ 2 ≤ 1 := by
    nlinarith [mul_nonneg hb0 (sub_nonneg.mpr hb1)]
  have hx1 : x ≤ 1 :=
    le_one_of_cube_le_one x hx0 (le_trans hx ha2)
  have hy1 : y ≤ 1 :=
    le_one_of_cube_le_one y hy0 (le_trans hy hb2)
  have hprod : x ^ 3 * y ^ 3 ≤ a ^ 2 * b ^ 2 :=
    mul_le_mul hx hy (pow_nonneg hy0 _) (pow_nonneg ha0 _)
  have hxycube : (x * y) ^ 3 ≤ (1 / 4 : ℝ) ^ 3 := by
    calc
      (x * y) ^ 3 = x ^ 3 * y ^ 3 := by ring
      _ ≤ a ^ 2 * b ^ 2 := hprod
      _ = (a * b) ^ 2 := by ring
      _ ≤ (1 / 8 : ℝ) ^ 2 :=
        pow_le_pow_left₀ (mul_nonneg ha0 hb0) hab 2
      _ = (1 / 4 : ℝ) ^ 3 := by norm_num
  let z : ℝ := x * y
  have hzcube : z ^ 3 ≤ (1 / 4 : ℝ) ^ 3 := hxycube
  have hz : z ≤ 1 / 4 := by
    by_contra hnot
    have hlt : (1 / 4 : ℝ) < z := lt_of_not_ge hnot
    have hp : 0 < (z - 1 / 4) * (z ^ 2 + z / 4 + 1 / 16) := by
      apply mul_pos (by linarith)
      nlinarith [sq_nonneg z]
    nlinarith [hp]
  have hxy : x * y ≤ 1 / 4 := hz
  have hnonneg : 0 ≤ (1 - x) * (1 - y) :=
    mul_nonneg (sub_nonneg.mpr hx1) (sub_nonneg.mpr hy1)
  nlinarith [hnonneg]

end Nightfall.Wright.SharpMedian
