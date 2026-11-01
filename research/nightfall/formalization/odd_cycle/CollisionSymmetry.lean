import Init

namespace Nightfall.OddCycle

/-- Injective decoding under a negation-invariant observation forbids
distinct opposite codewords. No cardinality assumptions are needed. -/
theorem opposite_codewords_coincide
    {α β : Type} (neg : α → α) (measure : α → β)
    (code : α → Prop)
    (invariant : ∀ x, measure (neg x) = measure x)
    (decodable : ∀ x y, code x → code y →
      measure x = measure y → x = y)
    (x : α) (hx : code x) (hnx : code (neg x)) :
    neg x = x := by
  exact decodable (neg x) x hnx hx (invariant x)

/-- A centrally symmetric code with injective negation-invariant
measurement has no translation adjacency except at negation-fixed points.
The abstract shift relation is shift x = neg (mirror x). -/
theorem translation_collision_implies_fixed
    {α β : Type} (neg mirror shift : α → α) (measure : α → β)
    (code : α → Prop)
    (invariant : ∀ x, measure (neg x) = measure x)
    (decodable : ∀ x y, code x → code y →
      measure x = measure y → x = y)
    (symmetric : ∀ x, code x → code (mirror x))
    (shift_spec : ∀ x, shift x = neg (mirror x))
    (x : α) (hx : code x) (hs : code (shift x)) :
    neg (mirror x) = mirror x := by
  have hm : code (mirror x) := symmetric x hx
  have hn : code (neg (mirror x)) := by
    rw [← shift_spec x]
    exact hs
  exact opposite_codewords_coincide neg measure code invariant decodable
    (mirror x) hm hn

end Nightfall.OddCycle
