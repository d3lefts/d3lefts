import Init

/-!
NIGHTFALL product-space influence: two-draw orientation kernel.
This is a precise combinatorial component of Lemma A in Wright (2026).
A finite independent product law has joint pair mass equal to a product of
coordinatewise masses. Conditioning on unordered coordinate pairs leaves all
orientations equiprobable. The following is the exact arithmetic identity
underlying that assertion, for arbitrary alphabets and any dimension.

SCOPE: This file does NOT establish the reciprocal all-pairs inequality,
the localized influence inequality, or the main product-space A-A theorem.
-/

namespace Nightfall.ProductSpace

universe u

/-- The (unnormalized) mass of a list of unordered coordinate pairs. -/
def pairWeight {α : Type u} (p : α → Nat) : List (α × α) → Nat
  | [] => 1
  | (a, b) :: rest => (p a * p b) * pairWeight p rest

/-- The mass of an oriented list of pairs for a proposed orientation mask. -/
def orientedWeight {α : Type u} (p : α → Nat) :
    List (α × α) → List Bool → Nat
  | [], [] => 1
  | (a, b) :: rest, flag :: flags =>
      (if flag then p a * p b else p b * p a) * orientedWeight p rest flags
  | _, _ => 0

/-- Every orientation of independent coordinate pairs has identical mass. -/
theorem orientation_mass_independent {α : Type u} (p : α → Nat) :
    ∀ (pairs : List (α × α)) (flags : List Bool),
      pairs.length = flags.length →
      orientedWeight p pairs flags = pairWeight p pairs := by
  intro pairs
  induction pairs with
  | nil =>
      intro flags h
      cases flags with
      | nil => rfl
      | cons b bs => simp at h
  | cons ab rest ih =>
      intro flags h
      cases flags with
      | nil => simp at h
      | cons b bs =>
          cases ab with
          | mk a c =>
              have htail : rest.length = bs.length := by simpa using h
              cases b with
              | false =>
                  simp [orientedWeight, pairWeight, ih bs htail, Nat.mul_comm]
              | true =>
                  simp [orientedWeight, pairWeight, ih bs htail]

/-- Any two valid orientation masks give the same independent-pair mass. -/
theorem all_orientations_equiprobable {α : Type u} (p : α → Nat)
    (pairs : List (α × α)) (first second : List Bool)
    (hfirst : pairs.length = first.length)
    (hsecond : pairs.length = second.length) :
    orientedWeight p pairs first = orientedWeight p pairs second := by
  rw [orientation_mass_independent p pairs first hfirst,
      orientation_mass_independent p pairs second hsecond]

/-- The direction can be reversed without changing one pair's mass. -/
theorem single_pair_exchangeable {α : Type u} (p : α → Nat)
    (a b : α) : p a * p b = p b * p a := by
  exact Nat.mul_comm (p a) (p b)

end Nightfall.ProductSpace
