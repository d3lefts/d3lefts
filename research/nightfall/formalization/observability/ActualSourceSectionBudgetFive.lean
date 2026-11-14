import ActualSourceSectionBudgetEight
import QuadraticSectionTen

/-!
# Source-realized 5B section budget from paired Markov cancellation
The old 8B bound reused one-sided Markov twice.
This theorem improves the switching stage to 10B and the
pointwise mean-square-root section budget to 5B.
-/

namespace Nightfall.Observability.ActualSourceSectionBudgetFive
open Finset
open Nightfall.Observability.QuadraticSwitching
open Nightfall.Observability.ActualSourceSectionBudgetEight

variable {α ι E : Type}
  [Fintype α] [DecidableEq α] [Nonempty α]
  [Fintype ι] [DecidableEq ι] [Fintype E]

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
theorem actual_quadratic_source_section_budget_five
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
    quadratic_actual_all_section_ranges_le_ten
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
         f (Function.update x i (z i)))) ≤ 10 * B := by
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


end Nightfall.Observability.ActualSourceSectionBudgetFive
