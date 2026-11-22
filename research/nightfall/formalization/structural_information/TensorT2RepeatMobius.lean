import Mathlib

/-!
# Four-slot repetition: partition-lattice Möbius compression

For any nonzero characteristic-two XOR frequency, there are only three
possible equality patterns: all distinct; exactly one equal pair; or one
equal triple plus a singleton. Two disjoint equal pairs imply XOR zero.

Consequently the indicator of any repetition equals the sum of the six
pair-equality indicators minus TWICE the sum of four triple-equality
indicators, with no 57-term higher inclusion-exclusion expansion.

This is a source-independent **combinatorial** kernel certificate. It
does not prove the Hilbert-space single-equality energy bounds or a
terminal quantum simulator.
-/

namespace Nightfall.StructuralInformation.TensorT2RepeatMobius

variable {A : Type*} [DecidableEq A]

def repeated (a b c d : A) : ℤ :=
  if a = b ∨ a = c ∨ a = d ∨ b = c ∨ b = d ∨ c = d then 1 else 0

def pairEvents (a b c d : A) : ℤ :=
  (if a = b then 1 else 0) +
  (if a = c then 1 else 0) +
  (if a = d then 1 else 0) +
  (if b = c then 1 else 0) +
  (if b = d then 1 else 0) +
  (if c = d then 1 else 0)

def tripleEvents (a b c d : A) : ℤ :=
  (if a = b ∧ b = c then 1 else 0) +
  (if a = b ∧ b = d then 1 else 0) +
  (if a = c ∧ c = d then 1 else 0) +
  (if b = c ∧ c = d then 1 else 0)

/-- The exact integer Möbius identity on the nonzero-XOR equality strata.
Only three *disjoint equal pairs* are excluded. -/
theorem mobius_repeated_when_no_two_disjoint_pairs (a b c d : A)
    (h₁ : ¬ (a = b ∧ c = d))
    (h₂ : ¬ (a = c ∧ b = d))
    (h₃ : ¬ (a = d ∧ b = c)) :
    repeated a b c d =
      pairEvents a b c d - 2 * tripleEvents a b c d := by
  by_cases hab : a = b <;>
  by_cases hac : a = c <;>
  by_cases had : a = d <;>
  by_cases hbc : b = c <;>
  by_cases hbd : b = d <;>
  by_cases hcd : c = d <;>
  simp_all [repeated, pairEvents, tripleEvents] <;>
  omega

/-- Source-equivalent form for a characteristic-two additive label group,
including labels equal to zero. -/
theorem mobius_repeated_nonzero_xor
    {G : Type*} [AddCommGroup G] [DecidableEq G]
    (h₂ : ∀ x : G, x + x = 0)
    (a b c d : G) (hz : a + b + c + d ≠ 0) :
    repeated a b c d =
      pairEvents a b c d - 2 * tripleEvents a b c d := by
  have habcd : ¬ (a = b ∧ c = d) := by
    rintro ⟨hab, hcd⟩
    apply hz
    calc
      a + b + c + d = (a + a) + (c + c) := by rw [← hab, ← hcd]; abel
      _ = 0 := by simp [h₂]
  have hacbd : ¬ (a = c ∧ b = d) := by
    rintro ⟨hac, hbd⟩
    apply hz
    calc
      a + b + c + d = (a + a) + (b + b) := by rw [← hac, ← hbd]; abel
      _ = 0 := by simp [h₂]
  have hadbc : ¬ (a = d ∧ b = c) := by
    rintro ⟨had, hbc⟩
    apply hz
    calc
      a + b + c + d = (a + a) + (b + b) := by rw [← had, ← hbc]; abel
      _ = 0 := by simp [h₂]
  exact mobius_repeated_when_no_two_disjoint_pairs a b c d
    habcd hacbd hadbc

/-- A simple, rationally certified bound for the sharpened T2
pair-energy constant. The separate Hilbert inequalities are external
proof obligations, NOT axioms or theorems in this file. -/
theorem improved_T2_pair_constant :
    6 * Real.sqrt 2 + 8 + 4 * (1 + 2 * Real.sqrt 3) ≤
      (35 : ℝ) := by
  have hs₂ : Real.sqrt (2 : ℝ) ≤ (3 / 2 : ℝ) := by
    nlinarith [Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 2),
      Real.sqrt_nonneg (2 : ℝ)]
  have hs₃ : Real.sqrt (3 : ℝ) ≤ (7 / 4 : ℝ) := by
    nlinarith [Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 3),
      Real.sqrt_nonneg (3 : ℝ)]
  nlinarith

#print axioms Nightfall.StructuralInformation.TensorT2RepeatMobius.mobius_repeated_when_no_two_disjoint_pairs
#print axioms Nightfall.StructuralInformation.TensorT2RepeatMobius.mobius_repeated_nonzero_xor
#print axioms Nightfall.StructuralInformation.TensorT2RepeatMobius.improved_T2_pair_constant

end Nightfall.StructuralInformation.TensorT2RepeatMobius
