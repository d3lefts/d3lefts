import SubcubeL3

/-!
# A source-identified six-active-site product-tensor circuit over F₂

Actual source: SubcubeL3.tensorMask 6. A family of eight distinct nonzero
rank-one tensor masks is minimally XOR-dependent, has variation in all six
tensor factors, and splits into two *primitive* four-row representations
of the same nonzero original row.

This exact finite construction is a lower witness for the SIX-SITE EXCHANGE
SUPPORT mechanism. It does *not* prove any all-frequency counting upper
bound, nonadaptive quantum simulation theorem, or historical novelty.
-/

namespace Nightfall.StructuralInformation.TensorSixSiteCircuit

open Nightfall.StructuralInformation.SubcubeL3

set_option maxRecDepth 20000
set_option maxHeartbeats 6000000

/-- Eight explicit row masks, written in the source's least-significant-bit
tensor coordinate convention. -/
def maskAt (k : Fin 8) : Nat :=
  match k.val with
  | 0 => 3
  | 1 => 10
  | 2 => 128
  | 3 => 136
  | 4 => 257
  | 5 => 16777472
  | 6 => 72057594037927936
  | 7 => 72057594054705152
  | _ => 0

/-- The exact local factor row from which each mask is generated:
0=e₀, 1=e₁, 2=e₀+e₁. -/
def factors6 (k : Fin 8) (j : Fin 6) : Fin 3 :=
  Fin.ofNat 3 <|
    match k.val with
    | 0 => if j.val = 0 then 2 else 0
    | 1 => if j.val = 0 then 1 else if j.val = 1 then 2 else 0
    | 2 => if j.val < 3 then 1 else 0
    | 3 => if j.val < 2 then 1 else if j.val = 2 then 2 else 0
    | 4 => if j.val = 3 then 2 else 0
    | 5 => if j.val = 3 then 1 else if j.val = 4 then 2 else 0
    | 6 => if 3 ≤ j.val then 1 else 0
    | 7 => if j.val = 3 ∨ j.val = 4 then 1
           else if j.val = 5 then 2 else 0
    | _ => 0

/-- Certifies that all eight displayed 64-bit masks are actual original
nonzero product-tensor rows, not arbitrary integer vectors. -/
theorem source_mask_identification :
    ∀ k : Fin 8, tensorMask 6 (factors6 k) = maskAt k := by
  decide

theorem source_rows_distinct :
    ∀ a b : Fin 8, a ≠ b → maskAt a ≠ maskAt b := by
  decide

/-- The eight product rows vary in every one of the six factors. -/
theorem every_factor_active :
    ∀ j : Fin 6, ∃ a b : Fin 8, factors6 a j ≠ factors6 b j := by
  decide

/-- Exactly the sum of the chosen rows, with no assumed tensor identities. -/
def selectedXor (selector : Fin 256) : Nat :=
  Nat.xor (if Nat.testBit selector.val 7 then 72057594054705152 else 0) (Nat.xor (if Nat.testBit selector.val 6 then 72057594037927936 else 0) (Nat.xor (if Nat.testBit selector.val 5 then 16777472 else 0) (Nat.xor (if Nat.testBit selector.val 4 then 257 else 0) (Nat.xor (if Nat.testBit selector.val 3 then 136 else 0) (Nat.xor (if Nat.testBit selector.val 2 then 128 else 0) (Nat.xor (if Nat.testBit selector.val 1 then 10 else 0) (Nat.xor (if Nat.testBit selector.val 0 then 3 else 0) (0))))))))

/-- Exact 256-case kernel certificate: the ONLY zero-XOR subcollections
are the empty set and all eight rows. This proves a single eight-element
binary-matroid circuit, not a statistical sample. -/
theorem circuit_only_empty_or_full :
    ∀ selector : Fin 256,
      selectedXor selector = 0 ↔
      selector.val = 0 ∨ selector.val = 255 := by
  decide

/-- Each disjoint primitive four-row block represents the SAME row (mask 1). -/
theorem first_four_representation :
    Nat.xor (Nat.xor (Nat.xor 3 10) 128) 136 = 1 := by
  decide

theorem second_four_representation :
    Nat.xor (Nat.xor (Nat.xor 257 16777472) 72057594037927936)
      72057594054705152 = 1 := by
  decide

#print axioms Nightfall.StructuralInformation.TensorSixSiteCircuit.source_mask_identification
#print axioms Nightfall.StructuralInformation.TensorSixSiteCircuit.source_rows_distinct
#print axioms Nightfall.StructuralInformation.TensorSixSiteCircuit.every_factor_active
#print axioms Nightfall.StructuralInformation.TensorSixSiteCircuit.circuit_only_empty_or_full
#print axioms Nightfall.StructuralInformation.TensorSixSiteCircuit.first_four_representation
#print axioms Nightfall.StructuralInformation.TensorSixSiteCircuit.second_four_representation

end Nightfall.StructuralInformation.TensorSixSiteCircuit
