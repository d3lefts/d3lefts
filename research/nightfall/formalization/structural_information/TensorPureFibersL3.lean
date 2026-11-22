import SubcubeL3

/-!
# Exact local primitive XOR-fiber coefficient certificates through level 3

These finite kernel targets are the input coefficient table for the separate
paper-level Lovitz-Petrov all-depth polynomial theorem. They do not encode
nor assert the published splitting theorem as a Lean axiom, and they do not
prove the full two-query quantum simulation theorem.

Primitivity of a distinct nonzero set of up to four rows with nonzero XOR
is equivalent to the absence of a zero-XOR triple. In a binary vector space
singleton XORs are nonzero, and zero-XOR pairs of distinct rows do not exist.
-/

namespace Nightfall.StructuralInformation.TensorPureFibersL3

open Nightfall.StructuralInformation.SubcubeL3

set_option maxRecDepth 20000
set_option maxHeartbeats 20000000

def xorFold (s : Finset Nat) : Nat :=
  (s.sort (· ≤ ·)).foldl Nat.xor 0

def primitiveFiber (rows : Finset Nat) (k : Nat) : Finset (Finset Nat) :=
  (rows.powersetCard k).filter (fun s =>
    xorFold s = 1 ∧ ∀ t ∈ s.powersetCard 3, xorFold t ≠ 0)

/-- All source-level original-row 2-XOR representations at depth 1. -/
theorem primitive_two_L1 : (primitiveFiber rows1 2).card = 1 := by decide

/-- The depth-two three-term primitive fiber coefficient. -/
theorem primitive_three_L2 : (primitiveFiber rows2 3).card = 4 := by decide

/-- The depth-two four-term primitive fiber coefficient. -/
theorem primitive_four_L2 : (primitiveFiber rows2 4).card = 5 := by decide

/-- The depth-three three-term primitive fiber, agreeing with 3 * 4. -/
theorem primitive_three_L3 : (primitiveFiber rows3 3).card = 12 := by decide

/-- Depth-three four-term primitive fiber: 45=3*5+30.
    This is a full finite enumeration of 27 choose 4 unordered row sets;
    it does NOT prove that all L reduce to depth three. -/
theorem primitive_four_L3 : (primitiveFiber rows3 4).card = 45 := by decide

#print axioms Nightfall.StructuralInformation.TensorPureFibersL3.primitive_two_L1
#print axioms Nightfall.StructuralInformation.TensorPureFibersL3.primitive_three_L2
#print axioms Nightfall.StructuralInformation.TensorPureFibersL3.primitive_four_L2
#print axioms Nightfall.StructuralInformation.TensorPureFibersL3.primitive_three_L3
#print axioms Nightfall.StructuralInformation.TensorPureFibersL3.primitive_four_L3

end Nightfall.StructuralInformation.TensorPureFibersL3
