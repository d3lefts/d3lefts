import Mathlib
import T2ZeroTripleOverlap31

/-!
# Two-query zero-triple multiplicity, source-level formal stage

This module formalizes the exact 0/1/2 multiplicity of nonzero extended
zero-triple survivor EVENTS at four binary-character slots.  It upgrades
the scoped survivor identities in T2ZeroTripleOverlap31 to an integer
coefficient identity on *every* four-tuple, not just a finite enumerator.

It is intentionally narrower than the T2-31 quantum theorem: proving
equivalence of the event-based singleton/doubleton predicates with the
paper's distinct-label Class C and repeated-pair R_* predicates, the
6*M2 fiber charge, all complex Hilbert frame inequalities, and original-
label Walsh projection remains separate work. No theorem-shaped axioms.
-/

namespace Nightfall.StructuralInformation.T2ZeroTripleMultiplicity

open Nightfall.StructuralInformation.T2ZeroTripleOverlap

variable {G : Type*} [AddCommGroup G]

/-- A four-slot tuple is entirely nonzero. -/
def allNonzero (a b c d : G) : Prop :=
  a ≠ 0 ∧ b ≠ 0 ∧ c ≠ 0 ∧ d ≠ 0

/-- Extended nonzero-zero-triple survivor events, with survivor in
positions 0, 1, 2, and 3 respectively. -/
def e0 (a b c d : G) : Prop := allNonzero a b c d ∧ b + c + d = 0
def e1 (a b c d : G) : Prop := allNonzero a b c d ∧ a + c + d = 0
def e2 (a b c d : G) : Prop := allNonzero a b c d ∧ a + b + d = 0
def e3 (a b c d : G) : Prop := allNonzero a b c d ∧ a + b + c = 0

/-- A fixed, zero-or-one integer coefficient for a proposition. -/
noncomputable def bit (p : Prop) : ℤ := by
  classical
  exact if p then 1 else 0

/-- Exactly one of the four extended survivor events holds. -/
def exactlyOne (p q r s : Prop) : Prop :=
  (p ∧ ¬q ∧ ¬r ∧ ¬s) ∨
  (¬p ∧ q ∧ ¬r ∧ ¬s) ∨
  (¬p ∧ ¬q ∧ r ∧ ¬s) ∨
  (¬p ∧ ¬q ∧ ¬r ∧ s)

/-- Exactly two of the four extended survivor events hold. -/
def exactlyTwo (p q r s : Prop) : Prop :=
  (p ∧ q ∧ ¬r ∧ ¬s) ∨
  (p ∧ ¬q ∧ r ∧ ¬s) ∨
  (p ∧ ¬q ∧ ¬r ∧ s) ∨
  (¬p ∧ q ∧ r ∧ ¬s) ∨
  (¬p ∧ q ∧ ¬r ∧ s) ∨
  (¬p ∧ ¬q ∧ r ∧ s)

/-- Boolean incidence identity for four events when triple intersections
are excluded. The proof checks every truth pattern, not numeric samples. -/
theorem four_event_incidence (p q r s : Prop)
    (hpqr : ¬ (p ∧ q ∧ r))
    (hpqs : ¬ (p ∧ q ∧ s))
    (hprs : ¬ (p ∧ r ∧ s))
    (hqrs : ¬ (q ∧ r ∧ s)) :
    bit p + bit q + bit r + bit s =
      bit (exactlyOne p q r s) + 2 * bit (exactlyTwo p q r s) := by
  classical
  by_cases hp : p <;>
  by_cases hq : q <;>
  by_cases hr : r <;>
  by_cases hs : s <;>
  simp_all [bit, exactlyOne, exactlyTwo] <;> omega

/-- In an exponent-two group, three distinct extended survivor
positions are impossible when all four slot labels are nonzero.  This
proves all four separate three-event exclusions, rather than assuming
the nonzero-frequency classification. -/
theorem four_zero_triple_exclusions
    (h₂ : ∀ x : G, x + x = 0) (a b c d : G) :
    ¬ (e0 a b c d ∧ e1 a b c d ∧ e2 a b c d) ∧
    ¬ (e0 a b c d ∧ e1 a b c d ∧ e3 a b c d) ∧
    ¬ (e0 a b c d ∧ e2 a b c d ∧ e3 a b c d) ∧
    ¬ (e1 a b c d ∧ e2 a b c d ∧ e3 a b c d) := by
  constructor
  · rintro ⟨h0, h1, h2⟩
    have hd : d = 0 :=
      three_survivors_force_fourth_zero h₂ a b c d h0.2 h1.2 h2.2
    exact h0.1.2.2.2 hd
  constructor
  · rintro ⟨h0, h1, h3⟩
    have ht0 : b + d + c = 0 := by
      calc
        b + d + c = b + c + d := by abel
        _ = 0 := h0.2
    have ht1 : a + d + c = 0 := by
      calc
        a + d + c = a + c + d := by abel
        _ = 0 := h1.2
    have hc : c = 0 :=
      three_survivors_force_fourth_zero h₂ a b d c ht0 ht1 h3.2
    exact h0.1.2.2.1 hc
  constructor
  · rintro ⟨h0, h2, h3⟩
    have ht0 : c + d + b = 0 := by
      calc
        c + d + b = b + c + d := by abel
        _ = 0 := h0.2
    have ht1 : a + d + b = 0 := by
      calc
        a + d + b = a + b + d := by abel
        _ = 0 := h2.2
    have ht2 : a + c + b = 0 := by
      calc
        a + c + b = a + b + c := by abel
        _ = 0 := h3.2
    have hb : b = 0 :=
      three_survivors_force_fourth_zero h₂ a c d b ht0 ht1 ht2
    exact h0.1.2.1 hb
  · rintro ⟨h1, h2, h3⟩
    have ht0 : c + d + a = 0 := by
      calc
        c + d + a = a + c + d := by abel
        _ = 0 := h1.2
    have ht1 : b + d + a = 0 := by
      calc
        b + d + a = a + b + d := by abel
        _ = 0 := h2.2
    have ht2 : b + c + a = 0 := by
      calc
        b + c + a = a + b + c := by abel
        _ = 0 := h3.2
    have ha : a = 0 :=
      three_survivors_force_fourth_zero h₂ b c d a ht0 ht1 ht2
    exact h1.1.1 ha

/-- The exact integer four-survivor coefficient formula on arbitrary
four-tuples of an exponent-two group, with no finite-size bound or
choice of coefficient field.  This is a *multiplicity* identity;
its numerical coefficients may multiply any complex path weight. -/
theorem zero_triple_event_multiplicity
    (h₂ : ∀ x : G, x + x = 0) (a b c d : G) :
    bit (e0 a b c d) + bit (e1 a b c d) +
        bit (e2 a b c d) + bit (e3 a b c d) =
      bit (exactlyOne (e0 a b c d) (e1 a b c d)
        (e2 a b c d) (e3 a b c d)) +
        2 * bit (exactlyTwo (e0 a b c d) (e1 a b c d)
          (e2 a b c d) (e3 a b c d)) := by
  rcases four_zero_triple_exclusions h₂ a b c d with
    ⟨h012, h013, h023, h123⟩
  exact four_event_incidence
    (e0 a b c d) (e1 a b c d) (e2 a b c d) (e3 a b c d)
    h012 h013 h023 h123

#print axioms Nightfall.StructuralInformation.T2ZeroTripleMultiplicity.four_event_incidence
#print axioms Nightfall.StructuralInformation.T2ZeroTripleMultiplicity.four_zero_triple_exclusions
#print axioms Nightfall.StructuralInformation.T2ZeroTripleMultiplicity.zero_triple_event_multiplicity

end Nightfall.StructuralInformation.T2ZeroTripleMultiplicity
