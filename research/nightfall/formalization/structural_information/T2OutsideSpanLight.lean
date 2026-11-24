import T2HeavyQuery
import T2WalshTranscript

/-!
# NIGHTFALL T2 — every Fourier frequency outside heavy-query span is genuinely light

The quantum T2-31 proof chooses original legal labels H from first
and second stage path masses and then removes *only* Walsh frequencies
in their additive span W. To use the rank-free four-slot energy lemma,
one must prove that any tuple with XOR outside W has a slot outside W,
and that such a slot is an actual legal original label with both
p_a and q_a light.

This module proves those two links uniformly for arbitrary additive
commutative groups and finite original-label sets. The uncharged zero
oracle sector is handled explicitly, rather than accidentally charged
as a classical query. No label-independence assumption and no query
to a fabricated XOR label are made.
-/

namespace Nightfall.StructuralInformation.T2OutsideSpanLight

open Finset
open Nightfall.StructuralInformation.T2HeavyQuery
open Nightfall.StructuralInformation.T2WalshTranscript

variable {G : Type*} [AddCommGroup G] [DecidableEq G]

/-- A four-slot frequency outside the generated heavy-query span
contains at least one original slot outside that span. -/
theorem outside_span_has_outside_slot
    (H : Finset G) (a b c d : G)
    (hout : fourFrequency a b c d ∉ AddSubgroup.closure (H : Set G)) :
    a ∉ AddSubgroup.closure (H : Set G) ∨
    b ∉ AddSubgroup.closure (H : Set G) ∨
    c ∉ AddSubgroup.closure (H : Set G) ∨
    d ∉ AddSubgroup.closure (H : Set G) := by
  classical
  by_contra h
  push_neg at h
  rcases h with ⟨ha, hb, hc, hd⟩
  exact hout (four_frequency_in_generated_span H a b c d ha hb hc hd)

/-- No outside-span slot can be the free zero sector; every such
slot must be an actual unqueried original label, light at both stages. -/
theorem outside_span_original_label_is_light
    (R : Finset G) (p q : G → ℝ) (eta : ℝ)
    (a : G)
    (haD : a ∈ insert 0 R)
    (hout : a ∉ AddSubgroup.closure
      (heavyLabels R p q eta : Set G)) :
    a ∈ R ∧ p a < eta ∧ q a < eta := by
  classical
  have ha0 : a ≠ 0 := by
    intro hz
    subst a
    exact hout (zero_mem _)
  have haR : a ∈ R := by
    rcases Finset.mem_insert.mp haD with h | h
    · exact (ha0 h).elim
    · exact h
  have hnotHeavy : a ∉ heavyLabels R p q eta := by
    intro ha
    have hmem : a ∈ (heavyLabels R p q eta : Set G) := by
      simpa using ha
    exact hout (AddSubgroup.subset_closure hmem)
  have hnot : ¬ (eta ≤ p a ∨ eta ≤ q a) := by
    intro h
    exact hnotHeavy (Finset.mem_filter.mpr ⟨haR, h⟩)
  have hp : p a < eta := lt_of_not_ge (fun h => hnot (Or.inl h))
  have hq : q a < eta := lt_of_not_ge (fun h => hnot (Or.inr h))
  exact ⟨haR, hp, hq⟩

/-- The exact structural light-slot condition used to invoke (3) for
each nonzero-frequency original four-path. In particular, this does
not charge zero or assume heavy labels are independent. -/
theorem outside_heavy_four_frequency_has_legal_light_slot
    (R : Finset G) (p q : G → ℝ) (eta : ℝ)
    (a b c d : G)
    (ha : a ∈ insert 0 R) (hb : b ∈ insert 0 R)
    (hc : c ∈ insert 0 R) (hd : d ∈ insert 0 R)
    (hout : fourFrequency a b c d ∉ AddSubgroup.closure
      (heavyLabels R p q eta : Set G)) :
    (a ∈ R ∧ p a < eta ∧ q a < eta) ∨
    (b ∈ R ∧ p b < eta ∧ q b < eta) ∨
    (c ∈ R ∧ p c < eta ∧ q c < eta) ∨
    (d ∈ R ∧ p d < eta ∧ q d < eta) := by
  rcases outside_span_has_outside_slot
    (heavyLabels R p q eta) a b c d hout with
    h | h | h | h
  · exact Or.inl (outside_span_original_label_is_light R p q eta a ha h)
  · exact Or.inr (Or.inl
      (outside_span_original_label_is_light R p q eta b hb h))
  · exact Or.inr (Or.inr (Or.inl
      (outside_span_original_label_is_light R p q eta c hc h)))
  · exact Or.inr (Or.inr (Or.inr
      (outside_span_original_label_is_light R p q eta d hd h)))

#print axioms Nightfall.StructuralInformation.T2OutsideSpanLight.outside_span_has_outside_slot
#print axioms Nightfall.StructuralInformation.T2OutsideSpanLight.outside_span_original_label_is_light
#print axioms Nightfall.StructuralInformation.T2OutsideSpanLight.outside_heavy_four_frequency_has_legal_light_slot

end Nightfall.StructuralInformation.T2OutsideSpanLight
