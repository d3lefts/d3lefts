import Q2SourceRepresentation

/-!
# Swansea Q2: all finite dimensions, sharp actual-source section budget

This closes the n=0,1 edge cases from Q2SourceRepresentation using
finite-law Popoviciu's inequality.  Unlike earlier 8*pi^2 row bounds,
the resulting actual-source theorem has constant 8, with only
normalized laws, pointwise |f|<=1 and ESDegreeLE p f 2.

This is NOT the full variance-squared influence theorem Q2.
-/

namespace Nightfall.Observability.Q2AllDimensions

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.Observability.Q2SharpSections
open Nightfall.Observability.Q2SourceRepresentation

variable {ι α : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- For any finite coordinate type, including empty and singleton,
and arbitrary normalized finite coordinate laws with zero masses
allowed, the sum of actual centered coordinate sections is at most 8.

No quadratic-representation/matching/moment hypothesis is assumed.
The bound is pointwise in all other coordinates. -/
theorem actual_degree_two_source_section_budget_eight_all
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ)
    (hf : ∀ x, |f x| ≤ 1)
    (hdegree : ESDegreeLE p f 2)
    (x : ι → α) :
    (∑ i : ι,
      Real.sqrt (∑ a : α, p i a *
        (f (Function.update x i a) -
          (∑ b : α, p i b * f (Function.update x i b))) ^ 2)) ≤ 8 := by
  classical
  by_cases hn : Nontrivial ι
  · letI : Nontrivial ι := hn
    exact actual_degree_two_source_section_budget_eight
      p hp hp1 f hf hdegree x
  · haveI : Subsingleton ι := by
      constructor
      intro i j
      by_contra hij
      apply hn
      exact ⟨i, j, hij⟩
    have hcard_nat : Fintype.card ι ≤ 1 := Fintype.card_le_one
    have hcard : (Fintype.card ι : ℝ) ≤ 1 := by
      exact_mod_cast hcard_nat
    have hcoord (i : ι) :
        Real.sqrt (∑ a : α, p i a *
          (f (Function.update x i a) -
            (∑ b : α, p i b * f (Function.update x i b))) ^ 2) ≤ 1 := by
      have hlo (a : α) :
          (-1 : ℝ) ≤ f (Function.update x i a) :=
        (abs_le.mp (hf (Function.update x i a))).1
      have hhi (a : α) :
          f (Function.update x i a) ≤ (1 : ℝ) :=
        (abs_le.mp (hf (Function.update x i a))).2
      have hstd := weighted_std_le_half_range
        (p i) (hp i) (hp1 i)
        (fun a : α => f (Function.update x i a))
        (-1) 1 (by norm_num) hlo hhi
      norm_num at hstd ⊢
      linarith
    calc
      (∑ i : ι, Real.sqrt (∑ a : α, p i a *
        (f (Function.update x i a) -
          (∑ b : α, p i b * f (Function.update x i b))) ^ 2)) ≤
        ∑ i : ι, (1 : ℝ) := by
          apply Finset.sum_le_sum
          intro i _
          exact hcoord i
      _ = (Fintype.card ι : ℝ) := by simp
      _ ≤ 1 := hcard
      _ ≤ 8 := by norm_num

end Nightfall.Observability.Q2AllDimensions
