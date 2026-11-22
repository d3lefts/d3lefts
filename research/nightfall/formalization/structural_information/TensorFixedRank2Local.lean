import TensorPureFibersL3

/-!
# Exact local primitive rank-two nonrow tensor XOR fibers

Target at L2 is 9 = e00 + e11; at L3 is 65 =
(e00 + e11) tensor e0, under the established mask generator.
Counts of unordered DISTINCT primitive source rows, not ordered
quantum path lifts. No all-L splitting or quantum theorem asserted.
-/
namespace Nightfall.StructuralInformation.TensorFixedRank2Local

open Nightfall.StructuralInformation.SubcubeL3
open Nightfall.StructuralInformation.TensorPureFibersL3

set_option maxRecDepth 20000
set_option maxHeartbeats 20000000

def primitiveAt (rows : Finset Nat) (k target : Nat) : Finset (Finset Nat) :=
  (rows.powersetCard k).filter (fun s =>
    xorLow8 s = target ∧
      ((s.powersetCard 3).filter (fun t => xorLow8 t = 0)).card = 0)

/-- All three unordered primitive pair representations of the rank-two L2 target. -/
theorem pair_rank2_L2 : (primitiveAt rows2 2 9).card = 3 := by decide

theorem triple_rank2_L2 : (primitiveAt rows2 3 9).card = 7 := by decide

theorem quadruple_rank2_L2 : (primitiveAt rows2 4 9).card = 6 := by decide

theorem pair_rank2_L3 : (primitiveAt rows3 2 65).card = 3 := by decide

theorem triple_rank2_L3 : (primitiveAt rows3 3 65).card = 13 := by decide

theorem quadruple_rank2_L3 : (primitiveAt rows3 4 65).card = 60 := by decide

#print axioms Nightfall.StructuralInformation.TensorFixedRank2Local.pair_rank2_L2
#print axioms Nightfall.StructuralInformation.TensorFixedRank2Local.triple_rank2_L2
#print axioms Nightfall.StructuralInformation.TensorFixedRank2Local.quadruple_rank2_L2
#print axioms Nightfall.StructuralInformation.TensorFixedRank2Local.pair_rank2_L3
#print axioms Nightfall.StructuralInformation.TensorFixedRank2Local.triple_rank2_L3
#print axioms Nightfall.StructuralInformation.TensorFixedRank2Local.quadruple_rank2_L3

end Nightfall.StructuralInformation.TensorFixedRank2Local
