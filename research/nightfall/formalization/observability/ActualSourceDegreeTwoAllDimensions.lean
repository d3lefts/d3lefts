import ActualSourceDegreeTwoSections

/-!
# Extend the source-only degree-two 8B section budget to n = 0,1

The two-or-more coordinate case is the current-pin proved
source-derived quadratic switching representation. For a
subsingleton coordinate type, Popoviciu bounds the sole
centered section directly, with no degree requirement.
Pointwise source boundedness is assumed, including on zero atoms.

This is a supporting original-source inequality, not terminal Q2.
-/

namespace Nightfall.Observability.ActualSourceDegreeTwoAllDimensions

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceSectionBudgetEight
open Nightfall.Observability.ActualSourceDegreeTwoSections

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

theorem actual_degree_two_source_section_budget_eight_all_current
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ) (B : ℝ)
    (hB : 0 ≤ B)
    (hf : ∀ x, |f x| ≤ B)
    (hdegree : ESDegreeLE p f 2)
    (x : ι → α) :
    (∑ i : ι, Real.sqrt (∑ a : α, p i a *
      (f (Function.update x i a) -
        (∑ b : α, p i b * f (Function.update x i b))) ^ 2)) ≤
      8 * B := by
  classical
  by_cases hn : Nontrivial ι
  · letI : Nontrivial ι := hn
    exact actual_degree_two_source_section_budget_eight_current
      p hp hp1 f B hf hdegree x
  · haveI : Subsingleton ι := by
      constructor
      intro i j
      by_contra hij
      apply hn
      exact ⟨i, j, hij⟩
    have hcard_nat : Fintype.card ι ≤ 1 := by
      have hinj : Function.Injective (fun _ : ι => (() : Unit)) := by
        intro a b _
        exact Subsingleton.elim a b
      simpa using
        (Fintype.card_le_of_injective
          (fun _ : ι => (() : Unit)) hinj)
    have hcard : (Fintype.card ι : ℝ) ≤ 1 := by
      exact_mod_cast hcard_nat
    have hcoord (i : ι) :
        Real.sqrt (∑ a : α, p i a *
          (f (Function.update x i a) -
            (∑ b : α, p i b * f (Function.update x i b))) ^ 2) ≤ B := by
      have hlo (a : α) : -B ≤ f (Function.update x i a) :=
        (abs_le.mp (hf (Function.update x i a))).1
      have hhi (a : α) : f (Function.update x i a) ≤ B :=
        (abs_le.mp (hf (Function.update x i a))).2
      have hstd := weighted_std_le_half_range
        (p i) (hp i) (hp1 i)
        (fun a : α => f (Function.update x i a))
        (-B) B (by linarith) hlo hhi
      linarith
    calc
      (∑ i : ι, Real.sqrt (∑ a : α, p i a *
        (f (Function.update x i a) -
          (∑ b : α, p i b * f (Function.update x i b))) ^ 2)) ≤
          ∑ _i : ι, B := by
            exact Finset.sum_le_sum (fun i _ => hcoord i)
      _ = (Fintype.card ι : ℝ) * B := by
            simp [nsmul_eq_mul]
      _ ≤ B := by
            have h := mul_le_mul_of_nonneg_right hcard hB
            nlinarith
      _ ≤ 8 * B := by linarith

end Nightfall.Observability.ActualSourceDegreeTwoAllDimensions
