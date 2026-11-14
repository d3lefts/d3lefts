import Mathlib

/-!
# NIGHTFALL universal authorization: exact policy expressivity and changed grants

**Scope:** arbitrary policy and observation types, with finite type/cardinality
corollaries. The all-policies hypothesis is explicit and is NOT a physically
verified enforcement assumption. This file is pending strict pinned Lean CI.
-/
namespace Nightfall.UniversalAuthorityInformation

universe u v w

/-- A single fixed interpreter realizes every Boolean authorization rule. -/
def ExactUniversal
    {World : Type u} {Obs : Type v} {Policy : Type w}
    (observe : World → Obs) (decidePolicy : Policy → Obs → Bool) : Prop :=
  ∀ f : World → Bool, ∃ p : Policy,
    ∀ x : World, decidePolicy p (observe x) = f x

/-- Supporting ALL exact policies forces the observation interface to
    distinguish every pair of worlds / joint action profiles. -/
theorem exact_universal_observation_injective
    {World : Type u} {Obs : Type v} {Policy : Type w}
    (observe : World → Obs) (decidePolicy : Policy → Obs → Bool)
    (h : ExactUniversal observe decidePolicy) :
    Function.Injective observe := by
  classical
  intro x y heq
  by_contra hne
  obtain ⟨p, hp⟩ := h (fun z => if z = x then true else false)
  have heq' : (if x = x then true else false) =
      (if y = x then true else false) := by
    calc
      (if x = x then true else false) = decidePolicy p (observe x) := (hp x).symm
      _ = decidePolicy p (observe y) := congrArg (decidePolicy p) heq
      _ = (if y = x then true else false) := hp y
  have hnot : y ≠ x := Ne.symm hne
  simp [hnot] at heq'

/-- The policy register must carry enough possible states to label every
    Boolean predicate on joint effect profiles. -/
theorem exact_universal_policy_card_lower
    {World : Type u} {Obs : Type v} {Policy : Type w}
    [Fintype World] [Fintype Policy]
    (observe : World → Obs) (decidePolicy : Policy → Obs → Bool)
    (h : ExactUniversal observe decidePolicy) :
    Fintype.card (World → Bool) ≤ Fintype.card Policy := by
  classical
  have hs : Function.Surjective
      (fun p : Policy => fun x : World => decidePolicy p (observe x)) := by
    intro f
    obtain ⟨p, hp⟩ := h f
    refine ⟨p, ?_⟩
    funext x
    exact hp x
  exact Fintype.card_le_of_surjective _ hs

/-- The observation register must distinguish every joint effect profile. -/
theorem exact_universal_observation_card_lower
    {World : Type u} {Obs : Type v} {Policy : Type w}
    [Fintype World] [Fintype Obs]
    (observe : World → Obs) (decidePolicy : Policy → Obs → Bool)
    (h : ExactUniversal observe decidePolicy) :
    Fintype.card World ≤ Fintype.card Obs := by
  exact Fintype.card_le_of_injective observe
    (exact_universal_observation_injective observe decidePolicy h)

/-- An arbitrary new forbidden hyperedge newly invalidates exactly those
    coalitions that contain it and were independent under the old hypergraph. -/
theorem newly_invalidated_iff
    {α : Type u} [DecidableEq α]
    (old : Finset (Finset α)) (newEdge coalition : Finset α) :
    (newEdge ⊆ coalition ∧ ∀ e ∈ old, ¬ e ⊆ coalition) ↔
    ((∀ e ∈ old, ¬ e ⊆ coalition) ∧
      ∃ e ∈ insert newEdge old, e ⊆ coalition) := by
  constructor
  · rintro ⟨hcontains, hsafe⟩
    exact ⟨hsafe, newEdge, Finset.mem_insert_self _ _, hcontains⟩
  · rintro ⟨hsafe, e, he, hcontains⟩
    rcases Finset.mem_insert.mp he with heq | hold
    · subst e
      exact ⟨hcontains, hsafe⟩
    · exact False.elim ((hsafe e hold) hcontains)

end Nightfall.UniversalAuthorityInformation