import ActualSourceConditionalSection
import ActualSourceCentered

/-!
# Actual Q2 source projection by canonical Efron-Stein interactions

Proves that the finite-neighbor conditional expectation of an ACTUAL
source's centered section is precisely the sum of its canonical
Efron-Stein components whose support contains the owned coordinate
and is contained in the observed set plus that coordinate.

The final declaration truncates that sum to support sizes ≤ 2 for
an actual degree-two source. Unlike an assumed decomposition or
generic energy oracle, the proof uses the source's own finite
conditional-expectation and Mobius ANOVA definitions and proves the
orthogonal-coordinate annihilation from source resampling.

This is the representation/conditioning bridge; it does NOT yet prove
a global source variance/influence energy budget, nor a terminal Q2 bound.
All alphabet law weights may be zero (only normalized in this module).
-/

namespace Nightfall.Observability.ActualSourceConditionalProjection

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceCentered
open Nightfall.Observability.ActualSourceConditionalSection
open Nightfall.Observability.ActualProductResampleBridge
open Nightfall.Observability.ActualProductMergeTower

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Conditioning a source function already supported on U changes nothing. -/
theorem condExp_of_dependsOn
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (U : Finset ι) (g : (ι → α) → ℝ)
    (hg : DependsOn U g)
    (x : ι → α) :
    condExp p U g x = g x := by
  have hpoint (y : ι → α) : g (merge U x y) = g x := by
    apply hg
    intro k hk
    simp [merge, hk]
  unfold condExp
  calc
    (∑ y : ι → α, originalMass p y * g (merge U x y)) =
        ∑ y : ι → α, originalMass p y * g x := by
          apply Finset.sum_congr rfl
          intro y _
          rw [hpoint y]
    _ = (∑ y : ι → α, originalMass p y) * g x := by
          rw [Finset.sum_mul]
    _ = g x := by rw [sum_originalMass' p hp1, one_mul]

/-- Averaging any centered source component over a missing coordinate
annihilates its conditional expectation. This is genuine source
resampling, not an assumed conditional-expectation operator law. -/
theorem condExp_zero_of_centered_missing
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (g : (ι → α) → ℝ) (U : Finset ι)
    (i : ι) (hi : i ∉ U)
    (hc : ∀ z : ι → α,
      (∑ a : α, p i a * g (Function.update z i a)) = 0)
    (x : ι → α) :
    condExp p U g x = 0 := by
  unfold condExp
  calc
    (∑ y : ι → α, originalMass p y * g (merge U x y)) =
       ∑ y : ι → α, ∑ a : α,
         originalMass p y * p i a * g (merge U x (Function.update y i a)) := by
           simpa only [Finset.mul_sum, mul_assoc] using
             (actual_source_resample_sum p hp1 i (fun y => g (merge U x y))).symm
    _ = ∑ y : ι → α, originalMass p y *
        (∑ a : α, p i a * g (Function.update (merge U x y) i a)) := by
          apply Finset.sum_congr rfl
          intro y _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro a _
          rw [merge_update_free U i hi x y a]
          ring
    _ = 0 := by
          simp only [hc, mul_zero, Finset.sum_const_zero]

/-- Canonical ANOVA interaction disappears if conditioning omits one of
the interaction's own coordinates. -/
theorem condExp_esComp_of_not_subset
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (U T : Finset ι) (hT : ¬ T ⊆ U)
    (x : ι → α) :
    condExp p U (esComp p T f) x = 0 := by
  have hmiss : ∃ i ∈ T, i ∉ U := by
    by_contra h
    push_neg at h
    exact hT (fun i hi => h i hi)
  obtain ⟨i, hiT, hiU⟩ := hmiss
  exact condExp_zero_of_centered_missing
    p hp1 (esComp p T f) U i hiU
    (fun z => actual_esComp_centered p hp1 f T i hiT z) x

/-- Canonical interaction survives conditioning iff its entire support
is retained. Exact regardless of zero-probability atoms. -/
theorem condExp_esComp_eq_ite
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (U T : Finset ι) (x : ι → α) :
    condExp p U (esComp p T f) x =
      if T ⊆ U then esComp p T f x else 0 := by
  by_cases ht : T ⊆ U
  · rw [if_pos ht]
    exact condExp_of_dependsOn p hp1 U (esComp p T f)
      (fun x y hxy =>
        (esComp_dependsOn p T f) x y (fun i hi => hxy i (ht hi))) x
  · rw [if_neg ht]
    exact condExp_esComp_of_not_subset p hp1 f U T ht x

/-- Completely source-derived conditional expectation expansion.
No Hoeffding degree cap is necessary here. -/
theorem actual_condExp_es_expansion
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (U : Finset ι) (x : ι → α) :
    condExp p U f x =
      ∑ T : Finset ι,
        if T ⊆ U then esComp p T f x else 0 := by
  have hpoint (y : ι → α) :
      f y = ∑ T : Finset ι, esComp p T f y :=
    (es_decomp p hp1 f y).symm
  calc
    condExp p U f x =
        condExp p U
          (fun y => ∑ T : Finset ι, esComp p T f y) x := by
            unfold condExp
            apply Finset.sum_congr rfl
            intro y _
            rw [hpoint (merge U x y)]
    _ = ∑ T : Finset ι, condExp p U (esComp p T f) x := by
          simpa only [one_mul] using
            (condExp_lin (κ := Finset ι) p U
              (fun _ => (1 : ℝ))
              (fun T => esComp p T f) x)
    _ = ∑ T : Finset ι,
        if T ⊆ U then esComp p T f x else 0 := by
          apply Finset.sum_congr rfl
          intro T _
          exact condExp_esComp_eq_ite p hp1 f U T x

/-- For S not containing i, a support that does not contain i cannot
distinguish S from S∪{i}. -/
private theorem subset_insert_of_missing
    (U S : Finset ι) (i : ι) (hi : i ∉ U) :
    U ⊆ insert i S ↔ U ⊆ S := by
  constructor
  · intro h k hk
    have hki : k ≠ i := by
      intro heq
      exact hi (heq ▸ hk)
    have hmem := h hk
    simpa only [Finset.mem_insert, hki, false_or] using hmem
  · intro h
    exact h.trans (Finset.subset_insert i S)

/-- TRUE source section projection: average the centered original
function over all coordinates not in S and retain precisely the
canonical interactions containing i supported by S∪{i}. -/
theorem actual_source_section_es_projection
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (i : ι) (S : Finset ι) (hi : i ∉ S)
    (x : ι → α) (a : α) :
    averageSourceSection p f i S x a =
      ∑ T : Finset ι,
        if i ∈ T ∧ T ⊆ insert i S then
          esComp p T f (Function.update x i a) else 0 := by
  rw [average_source_section_eq_condExp_difference p hp1 f i S hi x a,
      actual_condExp_es_expansion p hp1 f (insert i S)
        (Function.update x i a),
      actual_condExp_es_expansion p hp1 f S x,
      ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro T _
  by_cases hmem : i ∈ T
  · have hnot : ¬T ⊆ S := by
      intro h
      exact hi (h hmem)
    simp [hmem, hnot]
  · have hsame := subset_insert_of_missing T S i hmem
    have hval : esComp p T f (Function.update x i a) =
        esComp p T f x := by
      apply esComp_dependsOn p T f
      intro k hk
      have hki : k ≠ i := by
        intro h
        exact hmem (h ▸ hk)
      exact Function.update_of_ne hki a x
    by_cases hS : T ⊆ S
    · have hI : T ⊆ insert i S := hsame.mpr hS
      simp [hmem, hS, hI, hval]
    · have hI : ¬T ⊆ insert i S := fun h => hS (hsame.mp h)
      simp [hmem, hS, hI]

/-- Actual degree-two Efron-Stein truncation of the conditional
section representation, directly from the source degree hypothesis.
Only singleton and pair interactions can survive. -/
theorem actual_degree_two_section_es_projection
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (i : ι) (S : Finset ι) (hi : i ∉ S)
    (x : ι → α) (a : α) :
    averageSourceSection p f i S x a =
      ∑ T : Finset ι,
        if T.card ≤ 2 ∧ i ∈ T ∧ T ⊆ insert i S then
          esComp p T f (Function.update x i a) else 0 := by
  rw [actual_source_section_es_projection p hp1 f i S hi x a]
  apply Finset.sum_congr rfl
  intro T _
  by_cases hc : T.card ≤ 2
  · simp [hc]
  · have hz : esComp p T f (Function.update x i a) = 0 :=
      hdegree T (by omega) (Function.update x i a)
    by_cases hI : i ∈ T ∧ T ⊆ insert i S
    · simp [hc, hI, hz]
    · simp [hc, hI]

end Nightfall.Observability.ActualSourceConditionalProjection
