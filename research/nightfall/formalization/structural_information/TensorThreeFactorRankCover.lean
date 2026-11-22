import Mathlib

/-!
# All 3x3 binary matrices decompose into at most three ORIGINAL q=3 rows

Finite source-equivalent certificate for the q=3 local tensor family:
* an original row is u tensor v for 1<=u,v<=7 (GF2^3 vectors);
* a missing all-zero summand is represented by the constant 0, not counted;
* every 9-bit target is the XOR of three permitted rows or zero labels.

This does NOT formalize arbitrary-depth Lovitz-Petrov splitting or
the global cubic primitive-frequency theorem.
-/

namespace Nightfall.StructuralInformation.TensorThreeFactorRankCover

set_option maxRecDepth 10000
set_option maxHeartbeats 4000000

def outer3 (a b : Nat) : Nat :=
  (Finset.range 9).sum (fun i =>
    if Nat.testBit a (i / 3) = true ∧
       Nat.testBit b (i % 3) = true
    then 2 ^ i else 0)

def rows3x3 : Finset Nat :=
  ((Finset.Icc 1 7).product (Finset.Icc 1 7)).image
    (fun p => outer3 p.1 p.2)

def sourceOrZero : Finset Nat := insert 0 rows3x3

def term0 (z : Nat) : Nat := outer3 1 (z % 8)
def term1 (z : Nat) : Nat := outer3 2 ((z / 8) % 8)
def term2 (z : Nat) : Nat := outer3 4 ((z / 64) % 8)

/-- Each explicit row-decomposition term belongs to the *actual*
7² rank-one tensor-row generator or is zero. -/
theorem all_three_terms_source :
    ∀ z : Fin 512,
      term0 z.val ∈ sourceOrZero ∧
      term1 z.val ∈ sourceOrZero ∧
      term2 z.val ∈ sourceOrZero := by decide

/-- Exact GF₂ 3×3 row-decomposition identity for all 512 matrices.
    The three rank-one factors are explicitly source-identified. -/
theorem every_3x3_binary_matrix_uses_at_most_three_rows :
    ∀ z : Fin 512,
      Nat.xor (Nat.xor (term0 z.val) (term1 z.val))
        (term2 z.val) = z.val := by decide

/-- Kernel-checked existential terminal: every 3×3 binary matrix is
    the XOR of at most three original nonzero q=3 tensor rows. -/
theorem rank_three_source_oracle_cover (z : Fin 512) :
    ∃ a ∈ sourceOrZero, ∃ b ∈ sourceOrZero,
      ∃ c ∈ sourceOrZero, Nat.xor (Nat.xor a b) c = z.val := by
  obtain ⟨h0,h1,h2⟩ := all_three_terms_source z
  exact ⟨term0 z.val,h0,term1 z.val,h1,term2 z.val,h2,
    every_3x3_binary_matrix_uses_at_most_three_rows z⟩

#print axioms Nightfall.StructuralInformation.TensorThreeFactorRankCover.all_three_terms_source
#print axioms Nightfall.StructuralInformation.TensorThreeFactorRankCover.every_3x3_binary_matrix_uses_at_most_three_rows
#print axioms Nightfall.StructuralInformation.TensorThreeFactorRankCover.rank_three_source_oracle_cover

end Nightfall.StructuralInformation.TensorThreeFactorRankCover
