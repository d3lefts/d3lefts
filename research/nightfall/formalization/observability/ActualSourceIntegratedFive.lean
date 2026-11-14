import ActualSourceIntegratedSections
import ActualSourceDegreeTwoSections
import ActualSourceSectionBudgetFive

/-!
# Full-source finite degree-two integrated section bound: 5B

Pointwise canonical ES degree two under actual p, including zero masses;
no source-section-budget assumption. This is the independently checked
10B simultaneous switching improvement, not the stronger 4(1+sqrt 2)B
continuous Bernoulli switching candidate.
-/

namespace Nightfall.Observability.ActualSourceIntegratedFive
open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceIntegratedSections
open Nightfall.Observability.ActualSourceSectionBudgetEight
open Nightfall.Observability.ActualSourceSectionBudgetFive
open Nightfall.Observability.ActualSourceDegreeTwoSections

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

theorem actual_degree_two_source_section_budget_five_all_current
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
      5 * B := by
  classical
  by_cases hn : Nontrivial ι
  · letI : Nontrivial ι := hn
    obtain ⟨u,v,huv,k,hpoly⟩ :=
      source_degree_two_as_actual_quadratic p hp1 f hdegree
    exact actual_quadratic_source_section_budget_five
      p hp hp1 f B hf u v huv 0 (fun _ _ => 0) k hpoly x
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
      _ ≤ 5 * B := by linarith


theorem actual_source_integrated_five_budget
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (B : ℝ) (hB : 0 ≤ B) (hf : ∀ x, |f x| ≤ B) :
    (∑ i : ι, sourceMeanSectionNorm p f i) ≤ 5 * B := by
  classical
  have hmass (x : ι → α) : 0 ≤ originalMass p x := by
    unfold originalMass
    exact Finset.prod_nonneg (fun i _ => hp i (x i))
  have hpoint (x : ι → α) :
      (∑ i : ι, sourceSectionNorm p f i x) ≤ 5 * B := by
    simpa only [sourceSectionNorm] using
      actual_degree_two_source_section_budget_five_all_current
        p hp hp1 f B hB hf hdegree x
  calc
    (∑ i : ι, sourceMeanSectionNorm p f i) =
      ∑ x : ι → α,
        originalMass p x * (∑ i : ι, sourceSectionNorm p f i x) := by
      unfold sourceMeanSectionNorm
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro x _
      rw [Finset.mul_sum]
    _ ≤ ∑ x : ι → α, originalMass p x * (5 * B) := by
      apply Finset.sum_le_sum
      intro x _
      exact mul_le_mul_of_nonneg_left (hpoint x) (hmass x)
    _ = 5 * B := by
      rw [← Finset.sum_mul, sum_originalMass' p hp1, one_mul]


end Nightfall.Observability.ActualSourceIntegratedFive
