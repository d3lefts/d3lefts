import QuadraticRealizedRangeBudget

/-!
# Genuine bounded quadratic f: 8B original-law centered section budget

Ports the finite weighted Popoviciu/std-to-range lemmas and composes
them with the existing pinned 16B simultaneous switching bound.
The **same actual f** is used for bounds and source sections; no
section norm budget or independent-copy oracle is a hypothesis.

The explicit quadratic hpoly representation remains an input
hypothesis. Separately identify this representation with a canonical
ESDegreeLE source in the full Q2 bridge; this is not a terminal Q2.
-/

namespace Nightfall.Observability.ActualSourceSectionBudgetEight

open Finset
open Nightfall.Observability.QuadraticSwitching

variable {α : Type} [Fintype α]

/-- Finite-law Popoviciu inequality, with no positive-atom floor. -/
theorem weighted_variance_le_quarter_range
    (p : α → ℝ) (hp : ∀ a, 0 ≤ p a)
    (hp1 : ∑ a : α, p a = 1)
    (y : α → ℝ) (lo hi : ℝ)
    (hlo : ∀ a, lo ≤ y a) (hhi : ∀ a, y a ≤ hi) :
    4 * (∑ a : α, p a *
      (y a - (∑ b : α, p b * y b)) ^ 2) ≤ (hi - lo) ^ 2 := by
  classical
  let μ : ℝ := ∑ a : α, p a * y a
  let mid : ℝ := (hi + lo) / 2
  let sqsum : ℝ := ∑ a : α, p a * (y a) ^ 2
  have hexpand (v : ℝ) :
      (∑ a : α, p a * (y a - v) ^ 2) =
        sqsum - 2 * v * μ + v ^ 2 := by
    calc
      (∑ a : α, p a * (y a - v) ^ 2) =
          ∑ a : α, (p a * (y a) ^ 2 -
            (2 * v) * (p a * y a) + v ^ 2 * p a) := by
              apply Finset.sum_congr rfl
              intro a _
              ring
      _ = sqsum - 2 * v * μ + v ^ 2 := by
        simp only [Finset.sum_sub_distrib, Finset.sum_add_distrib,
          ← Finset.mul_sum]
        rw [hp1]
        dsimp [sqsum, μ]
        ring
  have hshift :
      (∑ a : α, p a * (y a - mid) ^ 2) =
        (∑ a : α, p a * (y a - μ) ^ 2) + (μ - mid) ^ 2 := by
    rw [hexpand mid, hexpand μ]
    ring
  have hpoint (a : α) :
      (y a - mid) ^ 2 ≤ (hi - lo) ^ 2 / 4 := by
    have hl : 0 ≤ y a - lo := sub_nonneg.mpr (hlo a)
    have hr : 0 ≤ hi - y a := sub_nonneg.mpr (hhi a)
    dsimp [mid]
    nlinarith [mul_nonneg hl hr]
  have hsecond :
      (∑ a : α, p a * (y a - mid) ^ 2) ≤
        (hi - lo) ^ 2 / 4 := by
    calc
      (∑ a : α, p a * (y a - mid) ^ 2) ≤
          ∑ a : α, p a * ((hi - lo) ^ 2 / 4) := by
            apply Finset.sum_le_sum
            intro a _
            exact mul_le_mul_of_nonneg_left (hpoint a) (hp a)
      _ = (hi - lo) ^ 2 / 4 := by
            rw [← Finset.sum_mul, hp1, one_mul]
  change 4 * (∑ a : α, p a * (y a - μ) ^ 2) ≤ (hi - lo) ^ 2
  nlinarith [sq_nonneg (μ - mid)]

/-- Weighted standard deviation is at most half the full support range. -/
theorem weighted_std_le_half_range
    (p : α → ℝ) (hp : ∀ a, 0 ≤ p a)
    (hp1 : ∑ a : α, p a = 1)
    (y : α → ℝ) (lo hi : ℝ)
    (hlohi : lo ≤ hi)
    (hlo : ∀ a, lo ≤ y a) (hhi : ∀ a, y a ≤ hi) :
    2 * Real.sqrt (∑ a : α, p a *
      (y a - (∑ b : α, p b * y b)) ^ 2) ≤ hi - lo := by
  let vv : ℝ := ∑ a : α, p a *
    (y a - (∑ b : α, p b * y b)) ^ 2
  have hnonneg : 0 ≤ vv := by
    dsimp [vv]
    apply Finset.sum_nonneg
    intro a _
    exact mul_nonneg (hp a) (sq_nonneg _)
  have hsquare : 4 * vv ≤ (hi - lo) ^ 2 :=
    weighted_variance_le_quarter_range p hp hp1 y lo hi hlo hhi
  have hsqrt : (Real.sqrt vv) ^ 2 = vv := Real.sq_sqrt hnonneg
  have hpos : 0 ≤ Real.sqrt vv := Real.sqrt_nonneg _
  by_contra hbad
  have hgt : hi - lo < 2 * Real.sqrt vv := lt_of_not_ge hbad
  have hprod : 0 <
      (2 * Real.sqrt vv - (hi - lo)) *
      (2 * Real.sqrt vv + (hi - lo)) :=
    mul_pos (by linarith) (by linarith)
  nlinarith [hprod]


variable {ι E : Type}
  [Fintype ι] [DecidableEq ι]
  [DecidableEq α] [Nonempty α] [Fintype E]

private theorem singleSwitched_eq_update
    (x w : ι → α) (i : ι) :
    singleSwitched x w i = Function.update x i (w i) := by
  funext j
  by_cases hj : j = i
  · subst j
    simp [singleSwitched]
  · simp [singleSwitched, hj]

/-- Bounded original finite quadratic function has total
centered source-coordinate L² section norm at most 8B at each
original input. This is directly derived from its real quadratic
representation and original law: no section-budget oracle. -/
theorem actual_quadratic_source_section_budget_eight
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ) (B : ℝ)
    (hf : ∀ x, |f x| ≤ B)
    (u v : E → ι) (hne : ∀ e, u e ≠ v e)
    (c : ℝ) (h : ι → α → ℝ)
    (k : E → α → α → ℝ)
    (hpoly : ∀ x, f x = quadratic u v c h k x)
    (x : ι → α) :
    (∑ i : ι,
      Real.sqrt (∑ a : α, p i a *
        (f (Function.update x i a) -
          (∑ b : α, p i b * f (Function.update x i b))) ^ 2)) ≤
      8 * B := by
  classical
  have hb : ∀ w : ι → α,
      |quadratic u v c h k w| ≤ B := by
    intro w
    rw [← hpoly w]
    exact hf w
  obtain ⟨y, z, hy, hz, hrange⟩ :=
    quadratic_actual_all_section_ranges_le_sixteen
      u v hne c h k B hb x
  have hlow (i : ι) (a : α) :
      f (Function.update x i (z i)) ≤
        f (Function.update x i a) := by
    simpa only [hpoly, singleSwitched_eq_update] using hz i a
  have hhigh (i : ι) (a : α) :
      f (Function.update x i a) ≤
        f (Function.update x i (y i)) := by
    simpa only [hpoly, singleSwitched_eq_update] using hy i a
  have htotal :
      (∑ i : ι,
        (f (Function.update x i (y i)) -
         f (Function.update x i (z i)))) ≤ 16 * B := by
    simpa only [hpoly, singleSwitched_eq_update] using hrange
  have hby_coordinate (i : ι) :
      2 * Real.sqrt (∑ a : α, p i a *
        (f (Function.update x i a) -
         (∑ b : α, p i b * f (Function.update x i b))) ^ 2) ≤
       f (Function.update x i (y i)) -
       f (Function.update x i (z i)) := by
    exact weighted_std_le_half_range
      (p i) (hp i) (hp1 i)
      (fun a : α => f (Function.update x i a))
      (f (Function.update x i (z i)))
      (f (Function.update x i (y i)))
      ((hlow i (y i)).trans (le_refl _))
      (hlow i) (hhigh i)
  have hsum := Finset.sum_le_sum
    (s := (Finset.univ : Finset ι))
    (fun i _ => hby_coordinate i)
  rw [← Finset.mul_sum] at hsum
  linarith

end Nightfall.Observability.ActualSourceSectionBudgetEight
