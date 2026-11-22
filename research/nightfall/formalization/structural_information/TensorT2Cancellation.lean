import Mathlib

/-!
# Four-label cancellations in the binary tensor-query model

This is a **scoped** Lean certificate for the six repeated-label cases used
in the two-query quantum path expansion. It does NOT certify the
rank-free simulation theorem in PR #1016.

Every binary-label space is an additive commutative group satisfying
`x + x = 0`. We leave this as an explicit assumption, rather than
pretend that an abstract additive group automatically has characteristic two.

The six implications show that every four-label sum containing a
repeated label is an original-row sum of at most two surviving labels.
The zero-triple uniqueness result is also recorded independently.
-/

namespace Nightfall.StructuralInformation.TensorT2Cancellation

variable {G : Type*} [AddCommGroup G]

private theorem cancel_double (h₂ : ∀ x : G, x + x = 0)
    (x y z : G) : x + x + y + z = y + z := by
  calc
    x + x + y + z = (x + x) + (y + z) := by abel
    _ = y + z := by rw [h₂ x, zero_add]

/-- In an exponent-two additive group, a zero pair means equal labels. -/
theorem pair_zero_iff_eq (h₂ : ∀ x : G, x + x = 0)
    (a b : G) : a + b = 0 ↔ a = b := by
  constructor
  · intro hab
    calc
      a = a + (b + b) := by rw [h₂ b, add_zero]
      _ = (a + b) + b := by abel
      _ = b := by rw [hab, zero_add]
  · intro h
    rw [h]
    exact h₂ b

theorem collapse_ab (h₂ : ∀ x : G, x + x = 0)
    (a b c d : G) (h : a = b) :
    a + b + c + d = c + d := by
  rw [← h]
  exact cancel_double h₂ a c d

theorem collapse_ac (h₂ : ∀ x : G, x + x = 0)
    (a b c d : G) (h : a = c) :
    a + b + c + d = b + d := by
  rw [← h]
  calc
    a + b + a + d = a + a + b + d := by abel
    _ = b + d := cancel_double h₂ a b d

theorem collapse_ad (h₂ : ∀ x : G, x + x = 0)
    (a b c d : G) (h : a = d) :
    a + b + c + d = b + c := by
  rw [← h]
  calc
    a + b + c + a = a + a + b + c := by abel
    _ = b + c := cancel_double h₂ a b c

theorem collapse_bc (h₂ : ∀ x : G, x + x = 0)
    (a b c d : G) (h : b = c) :
    a + b + c + d = a + d := by
  rw [← h]
  calc
    a + b + b + d = b + b + a + d := by abel
    _ = a + d := cancel_double h₂ b a d

theorem collapse_bd (h₂ : ∀ x : G, x + x = 0)
    (a b c d : G) (h : b = d) :
    a + b + c + d = a + c := by
  rw [← h]
  calc
    a + b + c + b = b + b + a + c := by abel
    _ = a + c := cancel_double h₂ b a c

theorem collapse_cd (h₂ : ∀ x : G, x + x = 0)
    (a b c d : G) (h : c = d) :
    a + b + c + d = a + b := by
  rw [← h]
  calc
    a + b + c + c = c + c + a + b := by abel
    _ = a + b := cancel_double h₂ c a b

/-- Any repeated pair of four quantum path labels leaves a two-label XOR.
    This handles all six distinct equality events (not the coefficient-energy
    estimates needed to sum the amplitudes). -/
theorem repeated_four_labels_collapse (h₂ : ∀ x : G, x + x = 0)
    (a b c d : G)
    (h : a = b ∨ a = c ∨ a = d ∨ b = c ∨ b = d ∨ c = d) :
    a + b + c + d = c + d ∨
    a + b + c + d = b + d ∨
    a + b + c + d = b + c ∨
    a + b + c + d = a + d ∨
    a + b + c + d = a + c ∨
    a + b + c + d = a + b := by
  rcases h with hab | hac | had | hbc | hbd | hcd
  · exact Or.inl (collapse_ab h₂ a b c d hab)
  · exact Or.inr (Or.inl (collapse_ac h₂ a b c d hac))
  · exact Or.inr (Or.inr (Or.inl (collapse_ad h₂ a b c d had)))
  · exact Or.inr (Or.inr (Or.inr (Or.inl (collapse_bc h₂ a b c d hbc))))
  · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (collapse_bd h₂ a b c d hbd)))))
  · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr
      (collapse_cd h₂ a b c d hcd)))))

/-- A four-slot tuple cannot contain two different zero triples
    while its four labels are all distinct. This statement holds
    in *every* additive commutative group. -/
theorem overlapping_zero_triples_force_repeat
    (a b c d : G)
    (habc : a + b + c = 0)
    (habd : a + b + d = 0) : c = d := by
  have heq : (a + b) + c = (a + b) + d := by
    calc
      (a + b) + c = 0 := habc
      _ = (a + b) + d := habd.symm
  exact add_left_cancel heq

#print axioms Nightfall.StructuralInformation.TensorT2Cancellation.pair_zero_iff_eq
#print axioms Nightfall.StructuralInformation.TensorT2Cancellation.repeated_four_labels_collapse
#print axioms Nightfall.StructuralInformation.TensorT2Cancellation.overlapping_zero_triples_force_repeat

end Nightfall.StructuralInformation.TensorT2Cancellation
