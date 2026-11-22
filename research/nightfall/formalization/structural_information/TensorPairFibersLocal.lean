import SubcubeL3

/-!
# Small-depth, original-source pair-XOR fiber certificates

Pure finite algebra: unordered pairs of distinct original tensor rows.
Exact named Lean kernel results at depths one and two, including every
non-row frequency. Does not certify all-L tensor circuit splitting,
quantum amplitudes or the complete two-query simulator.
-/
namespace Nightfall.StructuralInformation.TensorPairFibersLocal

open Nightfall.StructuralInformation.SubcubeL3

set_option maxRecDepth 10000
set_option maxHeartbeats 4000000

def pairCount (rs : Finset Nat) (z : Nat) : Nat :=
  ((rs.product rs).filter (fun p => p.1 < p.2 ∧ Nat.xor p.1 p.2 = z)).card

theorem row_pair_L1 :
    ∀ z ∈ rows1, pairCount rows1 z = 1 := by decide

theorem row_pair_L2 :
    ∀ z ∈ rows2, pairCount rows2 z = 2 := by decide

theorem nonrow_pair_L2 :
    ∀ z : Fin 16, z.val ≠ 0 → z.val ∉ rows2 →
      pairCount rows2 z.val = 3 := by decide

#print axioms Nightfall.StructuralInformation.TensorPairFibersLocal.row_pair_L1
#print axioms Nightfall.StructuralInformation.TensorPairFibersLocal.row_pair_L2
#print axioms Nightfall.StructuralInformation.TensorPairFibersLocal.nonrow_pair_L2

end Nightfall.StructuralInformation.TensorPairFibersLocal
