import Q2SharpSections

/-!
Swansea Q2 — remove the explicit hpoly hypothesis from the sharp finite
source-section lemma (for coordinate types containing two distinct vertices).

The representation is derived from the ACTUAL Efron–Stein components.
Every index S is retained, but for |S| > 2 its pair coefficient is zero.
For |S| <= 2 the component depends on at most two sites and can be
encoded in a pair coefficient. This is a representation lemma, NOT the
missing matching-mass/fourth-moment energy estimate.

Compiled in the same pinned Lean 4.33.0 Turturean workspace.
-/

namespace Nightfall.Observability.Q2SourceRepresentation

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.Observability.QuadraticANOVA
open Nightfall.Observability.QuadraticSwitching
open Nightfall.Observability.Q2SharpSections

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Nontrivial ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Any coordinate support with at most two sites can be embedded into
a pair of DISTINCT sites when the ambient coordinate type is nontrivial. -/
theorem small_support_embeds_in_pair
    (S : Finset ι) (hS : S.card ≤ 2) :
    ∃ i j : ι, i ≠ j ∧ S ⊆ ({i, j} : Finset ι) := by
  classical
  by_cases hzero : S = ∅
  · obtain ⟨i, j, hij⟩ : ∃ i j : ι, i ≠ j := exists_pair_ne ι
    refine ⟨i, j, hij, ?_⟩
    simp [hzero]
  · have hpos : 0 < S.card := by
      exact Finset.card_pos.mpr (Finset.nonempty_iff_ne_empty.mpr hzero)
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

/-- Extract an explicit quadratic polynomial from the ACTUAL
degree-two Efron–Stein expansion; the source function f itself is
unchanged. Singleton and constant terms may be represented by pair
kernels that ignore one or both arguments (this suffices for the
pointwise 16B switching and L2 section consequences).

No generic hpoly, matching mass, influence, moment or budget premise. -/
theorem exists_actual_quadratic_representation
    (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2) :
    ∃ u v : Finset ι → ι,
      (∀ S, u S ≠ v S) ∧
      ∃ k : Finset ι → α → α → ℝ,
        ∀ x : ι → α,
          f x = quadratic u v 0 (fun _ _ => 0) k x := by
  classical
  let base : ι → α := fun _ => Classical.choice inferInstance
  have hpair (S : Finset ι) :
      ∃ i j : ι, i ≠ j ∧ (S.card ≤ 2 → S ⊆ ({i, j} : Finset ι)) := by
    by_cases hs : S.card ≤ 2
    · obtain ⟨i, j, hij, hcover⟩ := small_support_embeds_in_pair S hs
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
        quadratic_hoeffding_decomposition p hp1 f hdegree x
    _ = ∑ S : Finset ι, k S (x (u S)) (x (v S)) := by
      apply Finset.sum_congr rfl
      intro S _
      by_cases hs : S.card ≤ 2
      · simpa only [k, if_pos hs] using hcomponent S hs
      · simp [k, hs]
    _ = quadratic u v 0 (fun _ _ => 0) k x := by
      simp [quadratic]

/-- Genuine finite-product L2 section budget with NO hpoly
hypothesis. A coordinate type of size one can be handled separately
by one-coordinate variance; this declaration covers all n >= 2.

This is the exact 8B analytical section quantity needed in the
Swansea dissertation's matching/fourth-moment route, NOT a Q2 proof. -/
theorem actual_degree_two_source_section_budget_eight
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
  obtain ⟨u, v, huv, k, hpoly⟩ :=
    exists_actual_quadratic_representation p hp1 f hdegree
  exact actual_quadratic_centered_sections_le_eight
    p hp hp1 f hf hdegree u v huv 0 (fun _ _ => 0) k hpoly x

end Nightfall.Observability.Q2SourceRepresentation
