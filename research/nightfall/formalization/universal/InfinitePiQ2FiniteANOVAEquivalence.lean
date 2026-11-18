import InfinitePiQ2FiniteDegreeBridge
import ActualSourceANOVA

/-!
# Canonical finite ANOVA degree two iff all mixed third differences vanish

This is a **finite** semantic equivalence. Its converse (ANOVA to
mixed differences) uses the genuine source Möbius decomposition;
the forward direction is the previously kernel-checked finite bridge.
No positivity, full support, or atom lower bound is needed.

This file is not the infinite-product L² equivalence. The latter
requires the finite-information projection/density limit.
-/

namespace Nightfall.InfinitePiQ2FiniteANOVAEquivalence

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.InfinitePiQ2DegreeRetraction
open Nightfall.InfinitePiQ2FiniteDegreeBridge

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

private theorem delta_sum {K : Type} [Fintype K]
    (i : ι) (a b : α) (g : K → (ι → α) → ℝ) :
    delta i a b (fun x => ∑ t, g t x) =
      fun x => ∑ t, delta i a b (g t) x := by
  funext x
  simp only [delta, Finset.sum_sub_distrib]

private theorem delta_comm_ne
    (i j : ι) (hij : i ≠ j) (a b : α) (c d : α)
    (f : (ι → α) → ℝ) :
    delta i a b (delta j c d f) =
      delta j c d (delta i a b f) := by
  funext x
  simp only [delta]
  rw [Function.update_comm hij a c x,
    Function.update_comm hij a d x,
    Function.update_comm hij b c x,
    Function.update_comm hij b d x]
  ring

private theorem delta_zero_of_dependsOn
    (S : Finset ι) (g : (ι → α) → ℝ)
    (hdep : DependsOn S g) (i : ι) (hi : i ∉ S)
    (a b : α) :
    delta i a b g = fun _ => 0 := by
  funext x
  have ha : g (Function.update x i a) = g x := by
    apply hdep
    intro j hj
    have hji : j ≠ i := by
      intro he
      subst j
      exact hi hj
    exact Function.update_of_ne hji a x
  have hb : g (Function.update x i b) = g x := by
    apply hdep
    intro j hj
    have hji : j ≠ i := by
      intro he
      subst j
      exact hi hj
    exact Function.update_of_ne hji b x
  simp only [delta, ha, hb, sub_self]

private theorem dependsOn_card_two_is_pointwise
    (S : Finset ι) (g : (ι → α) → ℝ)
    (hcard : S.card ≤ 2) (hdep : DependsOn S g) :
    PointwiseDegreeTwo g := by
  intro i j k hij hik hjk a a' b b' c c' x
  have hmiss : i ∉ S ∨ j ∉ S ∨ k ∉ S := by
    by_contra hn
    push_neg at hn
    obtain ⟨hi, hj, hk⟩ : i ∈ S ∧ j ∈ S ∧ k ∈ S := hn
    have hthree : 2 < S.card :=
      (Finset.two_lt_card).mpr ⟨i, hi, j, hj, k, hk, hij, hik, hjk⟩
    omega
  rcases hmiss with hi | hj | hk
  · have hz := delta_zero_of_dependsOn S g hdep i hi a a'
    rw [delta_comm_ne i j hij a a' b b' (delta k c c' g)]
    rw [delta_comm_ne i k hik a a' c c' g, hz]
    simp [delta]
  · have hz := delta_zero_of_dependsOn S g hdep j hj b b'
    rw [delta_comm_ne j k hjk b b' c c' g, hz]
    simp [delta]
  · have hz := delta_zero_of_dependsOn S g hdep k hk c c'
    rw [hz]
    simp [delta]

private theorem pointwise_sum {K : Type} [Fintype K]
    (g : K → (ι → α) → ℝ)
    (hg : ∀ t, PointwiseDegreeTwo (g t)) :
    PointwiseDegreeTwo (fun x => ∑ t, g t x) := by
  intro i j k hij hik hjk a a' b b' c c' x
  simp only [delta_sum]
  exact Finset.sum_eq_zero (fun t _ => hg t i j k hij hik hjk
    a a' b b' c c' x)

/-- The classical finite source ANOVA condition (all components above
order two vanish) is exactly the pointwise mixed-third-difference
condition, with no bias, positivity or support assumptions. -/
theorem canonical_ANOVA_degree_two_iff_mixed_third_zero
    (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ) :
    ESDegreeLE p f 2 ↔ PointwiseDegreeTwo f := by
  constructor
  · intro hdeg
    let g : Finset ι → (ι → α) → ℝ := fun S x =>
      if S.card ≤ 2 then esComp p S f x else 0
    have hg : ∀ S : Finset ι, PointwiseDegreeTwo (g S) := by
      intro S
      by_cases hS : S.card ≤ 2
      · simpa only [g, if_pos hS] using
          (dependsOn_card_two_is_pointwise S (esComp p S f)
            hS (esComp_dependsOn p S f))
      · have hzero : PointwiseDegreeTwo (fun _ : ι → α => (0 : ℝ)) := by
          intro i j k hij hik hjk a a' b b' c c' x
          simp [delta]
        simpa only [g, if_neg hS] using hzero
    have hsum : PointwiseDegreeTwo (fun x => ∑ S, g S x) :=
      pointwise_sum g hg
    have hrep : f = fun x => ∑ S, g S x := by
      funext x
      exact (actual_degree_two_source_decomposition p hp1 f hdeg x).symm
    rw [hrep]
    exact hsum
  · intro hf
    exact pointwiseDegreeTwo_implies_ESDegreeLE p f hf

#print axioms Nightfall.InfinitePiQ2FiniteANOVAEquivalence.canonical_ANOVA_degree_two_iff_mixed_third_zero

end Nightfall.InfinitePiQ2FiniteANOVAEquivalence
