import Init

/-!
NIGHTFALL RYEV #273 / abstract kernel-level sumset-hole transfer.
No Mathlib, no custom axioms, no sorry, no finite enumeration.
All field-specific algebraic obligations appear explicitly as premises.

Given a subset T of an additive space, a translated observation f(x),
an involution inverse, and the fiber law square(a)=square(b)
=> a=b or a=inverse(b), the absence of a translated off-diagonal
sum forces the squared observation to be injective on T.

General field instantiation (translated_opposites_force_sum, etc)
and all-k supported-anchor decoder remain SEPARATE open tasks.
-/

namespace Nightfall.SumsetHole

universe u v

theorem translated_square_injective
    {G : Type u}
    (T : G → Prop)
    (sum : G → G → G)
    (translate square inverse : G → G)
    (hole : G)
    (no_pair_sum : ∀ x y, T x → T y → sum x y ≠ hole)
    (translate_inj : ∀ x y, translate x = translate y → x = y)
    (translate_opposite_implies_sum :
      ∀ x y, translate x = inverse (translate y) → sum x y = hole)
    (square_fibers :
      ∀ a b, square a = square b → a = b ∨ a = inverse b) :
    ∀ x y, T x → T y →
      square (translate x) = square (translate y) → x = y := by
  intro x y hx hy hsq
  cases square_fibers (translate x) (translate y) hsq with
  | inl heq =>
      exact translate_inj x y heq
  | inr hneg =>
      exact False.elim ((no_pair_sum x y hx hy)
        (translate_opposite_implies_sum x y hneg))

-- The full T+T hole is sufficient but not necessary; this stronger
-- theorem requires only that sums of DISTINCT T-elements miss hole.
-- A collision with x=y is allowed and is correctly treated as harmless.
theorem translated_square_injective_off_diagonal
    {G : Type u}
    (T : G → Prop)
    (sum : G → G → G)
    (translate square inverse : G → G)
    (hole : G)
    (no_distinct_pair_sum :
      ∀ x y, T x → T y → x ≠ y → sum x y ≠ hole)
    (translate_inj : ∀ x y, translate x = translate y → x = y)
    (translate_opposite_implies_sum :
      ∀ x y, translate x = inverse (translate y) → sum x y = hole)
    (square_fibers :
      ∀ a b, square a = square b → a = b ∨ a = inverse b) :
    ∀ x y, T x → T y →
      square (translate x) = square (translate y) → x = y := by
  intro x y hx hy hsq
  cases square_fibers (translate x) (translate y) hsq with
  | inl heq =>
      exact translate_inj x y heq
  | inr hneg =>
      by_contra hxy
      have hsum : sum x y = hole :=
        translate_opposite_implies_sum x y hneg
      exact (no_distinct_pair_sum x y hx hy hxy) hsum

-- If a binary subset-sum encoding is injective and takes values in T,
-- the observation square(translate(encode(signs))) is injective.
theorem binary_code_injective
    {G : Type u} {B : Type v}
    (T : G → Prop)
    (sum : G → G → G)
    (translate square inverse : G → G)
    (hole : G)
    (encode : B → G)
    (encode_inj : ∀ a b, encode a = encode b → a = b)
    (encode_in_T : ∀ a, T (encode a))
    (no_pair_sum : ∀ x y, T x → T y → sum x y ≠ hole)
    (translate_inj : ∀ x y, translate x = translate y → x = y)
    (translate_opposite_implies_sum :
      ∀ x y, translate x = inverse (translate y) → sum x y = hole)
    (square_fibers :
      ∀ a b, square a = square b → a = b ∨ a = inverse b) :
    ∀ a b, square (translate (encode a)) =
      square (translate (encode b)) → a = b := by
  intro a b h
  have hg := translated_square_injective T sum translate square inverse
    hole no_pair_sum translate_inj translate_opposite_implies_sum
    square_fibers (encode a) (encode b) (encode_in_T a)
    (encode_in_T b) h
  exact encode_inj a b hg

#print axioms Nightfall.SumsetHole.translated_square_injective
#print axioms Nightfall.SumsetHole.translated_square_injective_off_diagonal
#print axioms Nightfall.SumsetHole.binary_code_injective

end Nightfall.SumsetHole
