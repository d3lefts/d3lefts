import ActualSourceANOVA
import ActualSourceSectionBudgetEight

/-!
# Source-only degree-two function -> literal quadratic switching representation

Port of the genuinely source-derived representation mechanism in legacy
PR #424 (Q2SourceRepresentation.lean) to current Lean 4.36.0-rc2.
No supplied polynomial representation or section-budget hypothesis.

Scope: finite nontrivial coordinate types, finite nonempty common alphabet,
normalized original source laws (zero-mass atoms permitted), and pointwise
bounded degree-two observable.

This is NOT a terminal variance–influence theorem.
-/

namespace Nightfall.Observability.ActualSourceDegreeTwoSections

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceSectionBudgetEight
open Nightfall.Observability.QuadraticSwitching

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Nontrivial ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Every support of size ≤2 can be placed inside a two-element subset
of a nontrivial finite coordinate type. -/
theorem source_small_support_embeds_in_pair
    (S : Finset ι) (hS : S.card ≤ 2) :
    ∃ i j : ι, i ≠ j ∧ S ⊆ ({i,j} : Finset ι) := by
  classical
  by_cases hzero : S = ∅
  · obtain ⟨i, j, hij⟩ : ∃ i j : ι, i ≠ j := exists_pair_ne ι
    refine ⟨i, j, hij, ?_⟩
    simp [hzero]
  · have hpos : 0 < S.card :=
      Finset.card_pos.mpr (Finset.nonempty_iff_ne_empty.mpr hzero)
    by_cases htwo : S.card = 2
    · obtain ⟨i, j, hij, hSij⟩ := Finset.card_eq_two.mp htwo
      refine ⟨i, j, hij, ?_⟩
      simp [hSij]
    · have hone : S.card = 1 := by omega
      obtain ⟨i, hi⟩ := Finset.card_eq_one.mp hone
      obtain ⟨j, hji⟩ : ∃ j : ι, j ≠ i := exists_ne i
      have hij : i ≠ j := Ne.symm hji
      refine ⟨i, j, hij, ?_⟩
      simp [hi]

/-- Literal quadratic representation of the input f in *its original*
Efron–Stein decomposition; the arbitrary two-site embedding of singleton
components is for polynomial switching only. -/
theorem source_degree_two_as_actual_quadratic
    (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2) :
    ∃ u v : Finset ι → ι,
      (∀ S, u S ≠ v S) ∧
      ∃ k : Finset ι → α → α → ℝ,
        ∀ x : ι → α, f x = quadratic u v 0 (fun _ _ => 0) k x := by
  classical
  let base : ι → α := fun _ => Classical.choice inferInstance
  have hpair (S : Finset ι) :
      ∃ i j : ι, i ≠ j ∧
        (S.card ≤ 2 → S ⊆ ({i,j} : Finset ι)) := by
    by_cases hs : S.card ≤ 2
    · obtain ⟨i, j, hij, hcover⟩ := source_small_support_embeds_in_pair S hs
      exact ⟨i, j, hij, fun _ => hcover⟩
    · obtain ⟨i, j, hij⟩ : ∃ i j : ι, i ≠ j := exists_pair_ne ι
      exact ⟨i, j, hij, fun hs' => (hs hs').elim⟩
  choose u v huv hcover using hpair
  let k : Finset ι → α → α → ℝ := fun S a b =>
    if S.card ≤ 2 then
      esComp p S f (Function.update (Function.update base (u S) a) (v S) b)
    else 0
  refine ⟨u, v, huv, k, ?_⟩
  intro x
  have hcomponent (S : Finset ι) (hS : S.card ≤ 2) :
      esComp p S f x =
      esComp p S f
        (Function.update (Function.update base (u S) (x (u S))) (v S) (x (v S))) := by
    apply esComp_dependsOn p S f
    intro i hi
    have hipair : i ∈ ({u S, v S} : Finset ι) := hcover S hS hi
    have hior : i = u S ∨ i = v S := by simpa using hipair
    rcases hior with hiu | hiv
    · subst i
      simp [huv S]
    · subst i
      simp
  calc
    f x = ∑ S : Finset ι,
        if S.card ≤ 2 then esComp p S f x else 0 :=
      (actual_degree_two_source_decomposition p hp1 f hdegree x).symm
    _ = ∑ S : Finset ι, k S (x (u S)) (x (v S)) := by
      apply Finset.sum_congr rfl
      intro S _
      by_cases hs : S.card ≤ 2
      · simpa only [k, if_pos hs] using hcomponent S hs
      · simp [k, hs]
    _ = quadratic u v 0 (fun _ _ => 0) k x := by
      simp [quadratic]

/-- Q2's no-extra-oracle L² source-section budget, now with the
genuine current-pin original-source Hoeffding degree hypothesis
and no supplied hpoly representation. -/
theorem actual_degree_two_source_section_budget_eight_current
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ) (B : ℝ)
    (hf : ∀ x, |f x| ≤ B)
    (hdegree : ESDegreeLE p f 2)
    (x : ι → α) :
    (∑ i : ι, Real.sqrt (∑ a : α, p i a *
      (f (Function.update x i a) -
        (∑ b : α, p i b * f (Function.update x i b))) ^ 2)) ≤
      8 * B := by
  classical
  obtain ⟨u, v, huv, k, hpoly⟩ :=
    source_degree_two_as_actual_quadratic p hp1 f hdegree
  exact actual_quadratic_source_section_budget_eight
    p hp hp1 f B hf u v huv 0 (fun _ _ => 0) k hpoly x

end Nightfall.Observability.ActualSourceDegreeTwoSections
