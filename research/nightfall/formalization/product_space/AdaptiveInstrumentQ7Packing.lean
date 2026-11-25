import Mathlib

/-! Each listed configuration has eight disjoint tight-blocker triples.
The data is generated from the 180 archived canonical masks; the kernel
checks disjointness and the finite deletion bound. Source-face and full
catalogue extraction are separately checked by the executable replay. -/

set_option maxRecDepth 4096
set_option maxHeartbeats 4000000

namespace Nightfall.Q7BlockerPacking

theorem packing_lower_bound {W : Type} [DecidableEq W] {n : ℕ}
    (g : Fin n → Finset W) (s : Finset W)
    (hd : ∀ i j, i ≠ j → Disjoint (g i) (g j))
    (hh : ∀ i, ∃ w ∈ s, w ∈ g i) : n ≤ s.card := by
  classical
  choose w hws hwg using hh
  let f : Fin n → ↥s := fun i => ⟨w i, hws i⟩
  have hf : Function.Injective f := by
    intro i j h
    by_contra hij
    have he : w i = w j := congrArg Subtype.val h
    exact Finset.disjoint_left.mp (hd i j hij) (hwg i) (he.symm ▸ hwg j)
  simpa using Fintype.card_le_of_injective f hf

def groups (r : List (List ℕ)) (i : Fin 8) : Finset ℕ :=
  (r[i.val]?.getD []).toFinset

def PairwiseDisjoint (r : List (List ℕ)) : Prop :=
  ∀ i j : Fin 8, i ≠ j → Disjoint (groups r i) (groups r j)

instance (r : List (List ℕ)) : Decidable (PairwiseDisjoint r) := by
  unfold PairwiseDisjoint
  infer_instance

theorem certified_record (r : List (List ℕ)) (hd : PairwiseDisjoint r)
    (s : Finset ℕ) (hh : ∀ i : Fin 8, ∃ w ∈ s, w ∈ groups r i) :
    8 ≤ s.card :=
  packing_lower_bound (groups r) s hd hh

-- Orbit 19; added edges 0, 63, 136, 183.
def record0 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431]]
theorem record0_disjoint : PairwiseDisjoint record0 := by decide
-- Orbit 19; added edges 0, 63, 136, 261.
def record1 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [325, 341, 277], [389, 405, 293]]
theorem record1_disjoint : PairwiseDisjoint record1 := by decide
-- Orbit 19; added edges 0, 63, 136, 314.
def record2 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [298, 362, 378], [282, 426, 442]]
theorem record2_disjoint : PairwiseDisjoint record2 := by decide
-- Orbit 19; added edges 0, 63, 183, 261.
def record3 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293]]
theorem record3_disjoint : PairwiseDisjoint record3 := by decide
-- Orbit 19; added edges 0, 63, 183, 314.
def record4 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [167, 363, 367], [151, 427, 431], [298, 362, 378], [282, 426, 442]]
theorem record4_disjoint : PairwiseDisjoint record4 := by decide
-- Orbit 19; added edges 0, 63, 261, 314.
def record5 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record5_disjoint : PairwiseDisjoint record5 := by decide
-- Orbit 19; added edges 0, 136, 183, 261.
def record6 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293]]
theorem record6_disjoint : PairwiseDisjoint record6 := by decide
-- Orbit 19; added edges 0, 136, 183, 314.
def record7 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [298, 362, 378], [282, 426, 442]]
theorem record7_disjoint : PairwiseDisjoint record7 := by decide
-- Orbit 19; added edges 0, 136, 261, 314.
def record8 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 340, 152], [400, 404, 168], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record8_disjoint : PairwiseDisjoint record8 := by decide
-- Orbit 19; added edges 0, 183, 261, 314.
def record9 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record9_disjoint : PairwiseDisjoint record9 := by decide
-- Orbit 19; added edges 63, 136, 183, 261.
def record10 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293]]
theorem record10_disjoint : PairwiseDisjoint record10 := by decide
-- Orbit 19; added edges 63, 136, 183, 314.
def record11 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [298, 362, 378], [282, 426, 442]]
theorem record11_disjoint : PairwiseDisjoint record11 := by decide
-- Orbit 19; added edges 63, 136, 261, 314.
def record12 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record12_disjoint : PairwiseDisjoint record12 := by decide
-- Orbit 19; added edges 63, 183, 261, 314.
def record13 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record13_disjoint : PairwiseDisjoint record13 := by decide
-- Orbit 19; added edges 136, 183, 261, 314.
def record14 : List (List ℕ) := [[336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record14_disjoint : PairwiseDisjoint record14 := by decide
-- Orbit 31; added edges 0, 62, 136, 181.
def record15 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [58, 252, 253], [30, 444, 445], [336, 340, 152], [400, 404, 168], [177, 241, 245], [149, 425, 429]]
theorem record15_disjoint : PairwiseDisjoint record15 := by decide
-- Orbit 31; added edges 0, 62, 136, 261.
def record16 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [58, 252, 253], [30, 444, 445], [336, 340, 152], [400, 404, 168], [325, 341, 277], [389, 405, 293]]
theorem record16_disjoint : PairwiseDisjoint record16 := by decide
-- Orbit 31; added edges 0, 62, 136, 312.
def record17 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [58, 252, 253], [30, 444, 445], [336, 340, 152], [400, 404, 168], [240, 304, 248], [280, 424, 440]]
theorem record17_disjoint : PairwiseDisjoint record17 := by decide
-- Orbit 31; added edges 0, 62, 181, 261.
def record18 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [58, 252, 253], [30, 444, 445], [177, 241, 245], [149, 425, 429], [325, 341, 277], [389, 405, 293]]
theorem record18_disjoint : PairwiseDisjoint record18 := by decide
-- Orbit 31; added edges 0, 62, 181, 312.
def record19 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [58, 252, 253], [30, 444, 445], [177, 241, 245], [149, 425, 429], [240, 304, 248], [280, 424, 440]]
theorem record19_disjoint : PairwiseDisjoint record19 := by decide
-- Orbit 31; added edges 0, 62, 261, 312.
def record20 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [58, 252, 253], [30, 444, 445], [325, 341, 277], [389, 405, 293], [240, 304, 248], [280, 424, 440]]
theorem record20_disjoint : PairwiseDisjoint record20 := by decide
-- Orbit 31; added edges 0, 136, 181, 261.
def record21 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 340, 152], [400, 404, 168], [177, 241, 245], [149, 425, 429], [325, 341, 277], [389, 405, 293]]
theorem record21_disjoint : PairwiseDisjoint record21 := by decide
-- Orbit 31; added edges 0, 136, 181, 312.
def record22 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 340, 152], [400, 404, 168], [177, 241, 245], [149, 425, 429], [240, 304, 248], [280, 424, 440]]
theorem record22_disjoint : PairwiseDisjoint record22 := by decide
-- Orbit 31; added edges 0, 136, 261, 312.
def record23 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 340, 152], [400, 404, 168], [325, 341, 277], [389, 405, 293], [240, 304, 248], [280, 424, 440]]
theorem record23_disjoint : PairwiseDisjoint record23 := by decide
-- Orbit 31; added edges 0, 181, 261, 312.
def record24 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [177, 241, 245], [149, 425, 429], [325, 341, 277], [389, 405, 293], [240, 304, 248], [280, 424, 440]]
theorem record24_disjoint : PairwiseDisjoint record24 := by decide
-- Orbit 31; added edges 62, 136, 181, 261.
def record25 : List (List ℕ) := [[58, 252, 253], [30, 444, 445], [336, 340, 152], [400, 404, 168], [177, 241, 245], [149, 425, 429], [325, 341, 277], [389, 405, 293]]
theorem record25_disjoint : PairwiseDisjoint record25 := by decide
-- Orbit 31; added edges 62, 136, 181, 312.
def record26 : List (List ℕ) := [[58, 252, 253], [30, 444, 445], [336, 340, 152], [400, 404, 168], [177, 241, 245], [149, 425, 429], [240, 304, 248], [280, 424, 440]]
theorem record26_disjoint : PairwiseDisjoint record26 := by decide
-- Orbit 31; added edges 62, 136, 261, 312.
def record27 : List (List ℕ) := [[58, 252, 253], [30, 444, 445], [336, 340, 152], [400, 404, 168], [325, 341, 277], [389, 405, 293], [240, 304, 248], [280, 424, 440]]
theorem record27_disjoint : PairwiseDisjoint record27 := by decide
-- Orbit 31; added edges 62, 181, 261, 312.
def record28 : List (List ℕ) := [[58, 252, 253], [30, 444, 445], [177, 241, 245], [149, 425, 429], [325, 341, 277], [389, 405, 293], [240, 304, 248], [280, 424, 440]]
theorem record28_disjoint : PairwiseDisjoint record28 := by decide
-- Orbit 31; added edges 136, 181, 261, 312.
def record29 : List (List ℕ) := [[336, 340, 152], [400, 404, 168], [177, 241, 245], [149, 425, 429], [325, 341, 277], [389, 405, 293], [240, 304, 248], [280, 424, 440]]
theorem record29_disjoint : PairwiseDisjoint record29 := by decide
-- Orbit 66; added edges 0, 63, 200, 247.
def record30 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [336, 344, 216], [400, 408, 232], [231, 359, 367], [215, 423, 431]]
theorem record30_disjoint : PairwiseDisjoint record30 := by decide
-- Orbit 66; added edges 0, 63, 200, 265.
def record31 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [336, 344, 216], [400, 408, 232], [329, 345, 281], [393, 409, 297]]
theorem record31_disjoint : PairwiseDisjoint record31 := by decide
-- Orbit 66; added edges 0, 63, 200, 310.
def record32 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [336, 344, 216], [400, 408, 232], [294, 358, 374], [278, 422, 438]]
theorem record32_disjoint : PairwiseDisjoint record32 := by decide
-- Orbit 66; added edges 0, 63, 247, 265.
def record33 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [231, 359, 367], [215, 423, 431], [329, 345, 281], [393, 409, 297]]
theorem record33_disjoint : PairwiseDisjoint record33 := by decide
-- Orbit 66; added edges 0, 63, 247, 310.
def record34 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [231, 359, 367], [215, 423, 431], [294, 358, 374], [278, 422, 438]]
theorem record34_disjoint : PairwiseDisjoint record34 := by decide
-- Orbit 66; added edges 0, 63, 265, 310.
def record35 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [329, 345, 281], [393, 409, 297], [294, 358, 374], [278, 422, 438]]
theorem record35_disjoint : PairwiseDisjoint record35 := by decide
-- Orbit 66; added edges 0, 200, 247, 265.
def record36 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 344, 216], [400, 408, 232], [231, 359, 367], [215, 423, 431], [329, 345, 281], [393, 409, 297]]
theorem record36_disjoint : PairwiseDisjoint record36 := by decide
-- Orbit 66; added edges 0, 200, 247, 310.
def record37 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 344, 216], [400, 408, 232], [231, 359, 367], [215, 423, 431], [294, 358, 374], [278, 422, 438]]
theorem record37_disjoint : PairwiseDisjoint record37 := by decide
-- Orbit 66; added edges 0, 200, 265, 310.
def record38 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 344, 216], [400, 408, 232], [329, 345, 281], [393, 409, 297], [294, 358, 374], [278, 422, 438]]
theorem record38_disjoint : PairwiseDisjoint record38 := by decide
-- Orbit 66; added edges 0, 247, 265, 310.
def record39 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [231, 359, 367], [215, 423, 431], [329, 345, 281], [393, 409, 297], [294, 358, 374], [278, 422, 438]]
theorem record39_disjoint : PairwiseDisjoint record39 := by decide
-- Orbit 66; added edges 63, 200, 247, 265.
def record40 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [336, 344, 216], [400, 408, 232], [231, 359, 367], [215, 423, 431], [329, 345, 281], [393, 409, 297]]
theorem record40_disjoint : PairwiseDisjoint record40 := by decide
-- Orbit 66; added edges 63, 200, 247, 310.
def record41 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [336, 344, 216], [400, 408, 232], [231, 359, 367], [215, 423, 431], [294, 358, 374], [278, 422, 438]]
theorem record41_disjoint : PairwiseDisjoint record41 := by decide
-- Orbit 66; added edges 63, 200, 265, 310.
def record42 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [336, 344, 216], [400, 408, 232], [329, 345, 281], [393, 409, 297], [294, 358, 374], [278, 422, 438]]
theorem record42_disjoint : PairwiseDisjoint record42 := by decide
-- Orbit 66; added edges 63, 247, 265, 310.
def record43 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [231, 359, 367], [215, 423, 431], [329, 345, 281], [393, 409, 297], [294, 358, 374], [278, 422, 438]]
theorem record43_disjoint : PairwiseDisjoint record43 := by decide
-- Orbit 66; added edges 200, 247, 265, 310.
def record44 : List (List ℕ) := [[336, 344, 216], [400, 408, 232], [231, 359, 367], [215, 423, 431], [329, 345, 281], [393, 409, 297], [294, 358, 374], [278, 422, 438]]
theorem record44_disjoint : PairwiseDisjoint record44 := by decide
-- Orbit 68; added edges 0, 63, 136, 183.
def record45 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431]]
theorem record45_disjoint : PairwiseDisjoint record45 := by decide
-- Orbit 68; added edges 0, 63, 136, 261.
def record46 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [325, 341, 277], [389, 405, 293]]
theorem record46_disjoint : PairwiseDisjoint record46 := by decide
-- Orbit 68; added edges 0, 63, 136, 314.
def record47 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [298, 362, 378], [282, 426, 442]]
theorem record47_disjoint : PairwiseDisjoint record47 := by decide
-- Orbit 68; added edges 0, 63, 183, 261.
def record48 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293]]
theorem record48_disjoint : PairwiseDisjoint record48 := by decide
-- Orbit 68; added edges 0, 63, 183, 314.
def record49 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [167, 363, 367], [151, 427, 431], [298, 362, 378], [282, 426, 442]]
theorem record49_disjoint : PairwiseDisjoint record49 := by decide
-- Orbit 68; added edges 0, 63, 261, 314.
def record50 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record50_disjoint : PairwiseDisjoint record50 := by decide
-- Orbit 68; added edges 0, 136, 183, 261.
def record51 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293]]
theorem record51_disjoint : PairwiseDisjoint record51 := by decide
-- Orbit 68; added edges 0, 136, 183, 314.
def record52 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [298, 362, 378], [282, 426, 442]]
theorem record52_disjoint : PairwiseDisjoint record52 := by decide
-- Orbit 68; added edges 0, 136, 261, 314.
def record53 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 340, 152], [400, 404, 168], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record53_disjoint : PairwiseDisjoint record53 := by decide
-- Orbit 68; added edges 0, 183, 261, 314.
def record54 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record54_disjoint : PairwiseDisjoint record54 := by decide
-- Orbit 68; added edges 63, 136, 183, 261.
def record55 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293]]
theorem record55_disjoint : PairwiseDisjoint record55 := by decide
-- Orbit 68; added edges 63, 136, 183, 314.
def record56 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [298, 362, 378], [282, 426, 442]]
theorem record56_disjoint : PairwiseDisjoint record56 := by decide
-- Orbit 68; added edges 63, 136, 261, 314.
def record57 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record57_disjoint : PairwiseDisjoint record57 := by decide
-- Orbit 68; added edges 63, 183, 261, 314.
def record58 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record58_disjoint : PairwiseDisjoint record58 := by decide
-- Orbit 68; added edges 136, 183, 261, 314.
def record59 : List (List ℕ) := [[336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record59_disjoint : PairwiseDisjoint record59 := by decide
-- Orbit 73; added edges 0, 63, 136, 183.
def record60 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431]]
theorem record60_disjoint : PairwiseDisjoint record60 := by decide
-- Orbit 73; added edges 0, 63, 136, 261.
def record61 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [325, 341, 277], [389, 405, 293]]
theorem record61_disjoint : PairwiseDisjoint record61 := by decide
-- Orbit 73; added edges 0, 63, 136, 314.
def record62 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [298, 362, 378], [282, 426, 442]]
theorem record62_disjoint : PairwiseDisjoint record62 := by decide
-- Orbit 73; added edges 0, 63, 183, 261.
def record63 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293]]
theorem record63_disjoint : PairwiseDisjoint record63 := by decide
-- Orbit 73; added edges 0, 63, 183, 314.
def record64 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [167, 363, 367], [151, 427, 431], [298, 362, 378], [282, 426, 442]]
theorem record64_disjoint : PairwiseDisjoint record64 := by decide
-- Orbit 73; added edges 0, 63, 261, 314.
def record65 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record65_disjoint : PairwiseDisjoint record65 := by decide
-- Orbit 73; added edges 0, 136, 183, 261.
def record66 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293]]
theorem record66_disjoint : PairwiseDisjoint record66 := by decide
-- Orbit 73; added edges 0, 136, 183, 314.
def record67 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [298, 362, 378], [282, 426, 442]]
theorem record67_disjoint : PairwiseDisjoint record67 := by decide
-- Orbit 73; added edges 0, 136, 261, 314.
def record68 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 340, 152], [400, 404, 168], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record68_disjoint : PairwiseDisjoint record68 := by decide
-- Orbit 73; added edges 0, 183, 261, 314.
def record69 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record69_disjoint : PairwiseDisjoint record69 := by decide
-- Orbit 73; added edges 63, 136, 183, 261.
def record70 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293]]
theorem record70_disjoint : PairwiseDisjoint record70 := by decide
-- Orbit 73; added edges 63, 136, 183, 314.
def record71 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [298, 362, 378], [282, 426, 442]]
theorem record71_disjoint : PairwiseDisjoint record71 := by decide
-- Orbit 73; added edges 63, 136, 261, 314.
def record72 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record72_disjoint : PairwiseDisjoint record72 := by decide
-- Orbit 73; added edges 63, 183, 261, 314.
def record73 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record73_disjoint : PairwiseDisjoint record73 := by decide
-- Orbit 73; added edges 136, 183, 261, 314.
def record74 : List (List ℕ) := [[336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record74_disjoint : PairwiseDisjoint record74 := by decide
-- Orbit 87; added edges 0, 63, 136, 183.
def record75 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431]]
theorem record75_disjoint : PairwiseDisjoint record75 := by decide
-- Orbit 87; added edges 0, 63, 136, 261.
def record76 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [325, 341, 277], [389, 405, 293]]
theorem record76_disjoint : PairwiseDisjoint record76 := by decide
-- Orbit 87; added edges 0, 63, 136, 314.
def record77 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [298, 362, 378], [282, 426, 442]]
theorem record77_disjoint : PairwiseDisjoint record77 := by decide
-- Orbit 87; added edges 0, 63, 183, 261.
def record78 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293]]
theorem record78_disjoint : PairwiseDisjoint record78 := by decide
-- Orbit 87; added edges 0, 63, 183, 314.
def record79 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [167, 363, 367], [151, 427, 431], [298, 362, 378], [282, 426, 442]]
theorem record79_disjoint : PairwiseDisjoint record79 := by decide
-- Orbit 87; added edges 0, 63, 261, 314.
def record80 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [47, 382, 383], [31, 446, 447], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record80_disjoint : PairwiseDisjoint record80 := by decide
-- Orbit 87; added edges 0, 136, 183, 261.
def record81 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293]]
theorem record81_disjoint : PairwiseDisjoint record81 := by decide
-- Orbit 87; added edges 0, 136, 183, 314.
def record82 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [298, 362, 378], [282, 426, 442]]
theorem record82_disjoint : PairwiseDisjoint record82 := by decide
-- Orbit 87; added edges 0, 136, 261, 314.
def record83 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 340, 152], [400, 404, 168], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record83_disjoint : PairwiseDisjoint record83 := by decide
-- Orbit 87; added edges 0, 183, 261, 314.
def record84 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record84_disjoint : PairwiseDisjoint record84 := by decide
-- Orbit 87; added edges 63, 136, 183, 261.
def record85 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293]]
theorem record85_disjoint : PairwiseDisjoint record85 := by decide
-- Orbit 87; added edges 63, 136, 183, 314.
def record86 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [298, 362, 378], [282, 426, 442]]
theorem record86_disjoint : PairwiseDisjoint record86 := by decide
-- Orbit 87; added edges 63, 136, 261, 314.
def record87 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [336, 340, 152], [400, 404, 168], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record87_disjoint : PairwiseDisjoint record87 := by decide
-- Orbit 87; added edges 63, 183, 261, 314.
def record88 : List (List ℕ) := [[47, 382, 383], [31, 446, 447], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record88_disjoint : PairwiseDisjoint record88 := by decide
-- Orbit 87; added edges 136, 183, 261, 314.
def record89 : List (List ℕ) := [[336, 340, 152], [400, 404, 168], [167, 363, 367], [151, 427, 431], [325, 341, 277], [389, 405, 293], [298, 362, 378], [282, 426, 442]]
theorem record89_disjoint : PairwiseDisjoint record89 := by decide
-- Orbit 104; added edges 0, 62, 136, 181.
def record90 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [58, 252, 253], [30, 444, 445], [336, 340, 152], [400, 404, 168], [177, 241, 245], [149, 425, 429]]
theorem record90_disjoint : PairwiseDisjoint record90 := by decide
-- Orbit 104; added edges 0, 62, 136, 261.
def record91 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [58, 252, 253], [30, 444, 445], [336, 340, 152], [400, 404, 168], [325, 341, 277], [389, 405, 293]]
theorem record91_disjoint : PairwiseDisjoint record91 := by decide
-- Orbit 104; added edges 0, 62, 136, 312.
def record92 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [58, 252, 253], [30, 444, 445], [336, 340, 152], [400, 404, 168], [240, 304, 248], [280, 424, 440]]
theorem record92_disjoint : PairwiseDisjoint record92 := by decide
-- Orbit 104; added edges 0, 62, 181, 261.
def record93 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [58, 252, 253], [30, 444, 445], [177, 241, 245], [149, 425, 429], [325, 341, 277], [389, 405, 293]]
theorem record93_disjoint : PairwiseDisjoint record93 := by decide
-- Orbit 104; added edges 0, 62, 181, 312.
def record94 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [58, 252, 253], [30, 444, 445], [177, 241, 245], [149, 425, 429], [240, 304, 248], [280, 424, 440]]
theorem record94_disjoint : PairwiseDisjoint record94 := by decide
-- Orbit 104; added edges 0, 62, 261, 312.
def record95 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [58, 252, 253], [30, 444, 445], [325, 341, 277], [389, 405, 293], [240, 304, 248], [280, 424, 440]]
theorem record95_disjoint : PairwiseDisjoint record95 := by decide
-- Orbit 104; added edges 0, 136, 181, 261.
def record96 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 340, 152], [400, 404, 168], [177, 241, 245], [149, 425, 429], [325, 341, 277], [389, 405, 293]]
theorem record96_disjoint : PairwiseDisjoint record96 := by decide
-- Orbit 104; added edges 0, 136, 181, 312.
def record97 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 340, 152], [400, 404, 168], [177, 241, 245], [149, 425, 429], [240, 304, 248], [280, 424, 440]]
theorem record97_disjoint : PairwiseDisjoint record97 := by decide
-- Orbit 104; added edges 0, 136, 261, 312.
def record98 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [336, 340, 152], [400, 404, 168], [325, 341, 277], [389, 405, 293], [240, 304, 248], [280, 424, 440]]
theorem record98_disjoint : PairwiseDisjoint record98 := by decide
-- Orbit 104; added edges 0, 181, 261, 312.
def record99 : List (List ℕ) := [[320, 321, 16], [384, 385, 32], [177, 241, 245], [149, 425, 429], [325, 341, 277], [389, 405, 293], [240, 304, 248], [280, 424, 440]]
theorem record99_disjoint : PairwiseDisjoint record99 := by decide
-- Orbit 104; added edges 62, 136, 181, 261.
def record100 : List (List ℕ) := [[58, 252, 253], [30, 444, 445], [336, 340, 152], [400, 404, 168], [177, 241, 245], [149, 425, 429], [325, 341, 277], [389, 405, 293]]
theorem record100_disjoint : PairwiseDisjoint record100 := by decide
-- Orbit 104; added edges 62, 136, 181, 312.
def record101 : List (List ℕ) := [[58, 252, 253], [30, 444, 445], [336, 340, 152], [400, 404, 168], [177, 241, 245], [149, 425, 429], [240, 304, 248], [280, 424, 440]]
theorem record101_disjoint : PairwiseDisjoint record101 := by decide
-- Orbit 104; added edges 62, 136, 261, 312.
def record102 : List (List ℕ) := [[58, 252, 253], [30, 444, 445], [336, 340, 152], [400, 404, 168], [325, 341, 277], [389, 405, 293], [240, 304, 248], [280, 424, 440]]
theorem record102_disjoint : PairwiseDisjoint record102 := by decide
-- Orbit 104; added edges 62, 181, 261, 312.
def record103 : List (List ℕ) := [[58, 252, 253], [30, 444, 445], [177, 241, 245], [149, 425, 429], [325, 341, 277], [389, 405, 293], [240, 304, 248], [280, 424, 440]]
theorem record103_disjoint : PairwiseDisjoint record103 := by decide
-- Orbit 104; added edges 136, 181, 261, 312.
def record104 : List (List ℕ) := [[336, 340, 152], [400, 404, 168], [177, 241, 245], [149, 425, 429], [325, 341, 277], [389, 405, 293], [240, 304, 248], [280, 424, 440]]
theorem record104_disjoint : PairwiseDisjoint record104 := by decide

def records : List (List (List ℕ)) := [record0, record1, record2, record3, record4, record5, record6, record7, record8, record9, record10, record11, record12, record13, record14, record15, record16, record17, record18, record19, record20, record21, record22, record23, record24, record25, record26, record27, record28, record29, record30, record31, record32, record33, record34, record35, record36, record37, record38, record39, record40, record41, record42, record43, record44, record45, record46, record47, record48, record49, record50, record51, record52, record53, record54, record55, record56, record57, record58, record59, record60, record61, record62, record63, record64, record65, record66, record67, record68, record69, record70, record71, record72, record73, record74, record75, record76, record77, record78, record79, record80, record81, record82, record83, record84, record85, record86, record87, record88, record89, record90, record91, record92, record93, record94, record95, record96, record97, record98, record99, record100, record101, record102, record103, record104]

theorem records_count : records.length = 105 := by decide

theorem all_records_disjoint (r : List (List ℕ)) (hr : r ∈ records) : PairwiseDisjoint r := by
  simp only [records, List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with h0 | h1 | h2 | h3 | h4 | h5 | h6 | h7 | h8 | h9 | h10 | h11 | h12 | h13 | h14 | h15 | h16 | h17 | h18 | h19 | h20 | h21 | h22 | h23 | h24 | h25 | h26 | h27 | h28 | h29 | h30 | h31 | h32 | h33 | h34 | h35 | h36 | h37 | h38 | h39 | h40 | h41 | h42 | h43 | h44 | h45 | h46 | h47 | h48 | h49 | h50 | h51 | h52 | h53 | h54 | h55 | h56 | h57 | h58 | h59 | h60 | h61 | h62 | h63 | h64 | h65 | h66 | h67 | h68 | h69 | h70 | h71 | h72 | h73 | h74 | h75 | h76 | h77 | h78 | h79 | h80 | h81 | h82 | h83 | h84 | h85 | h86 | h87 | h88 | h89 | h90 | h91 | h92 | h93 | h94 | h95 | h96 | h97 | h98 | h99 | h100 | h101 | h102 | h103 | h104
  · rw [h0]; exact record0_disjoint
  · rw [h1]; exact record1_disjoint
  · rw [h2]; exact record2_disjoint
  · rw [h3]; exact record3_disjoint
  · rw [h4]; exact record4_disjoint
  · rw [h5]; exact record5_disjoint
  · rw [h6]; exact record6_disjoint
  · rw [h7]; exact record7_disjoint
  · rw [h8]; exact record8_disjoint
  · rw [h9]; exact record9_disjoint
  · rw [h10]; exact record10_disjoint
  · rw [h11]; exact record11_disjoint
  · rw [h12]; exact record12_disjoint
  · rw [h13]; exact record13_disjoint
  · rw [h14]; exact record14_disjoint
  · rw [h15]; exact record15_disjoint
  · rw [h16]; exact record16_disjoint
  · rw [h17]; exact record17_disjoint
  · rw [h18]; exact record18_disjoint
  · rw [h19]; exact record19_disjoint
  · rw [h20]; exact record20_disjoint
  · rw [h21]; exact record21_disjoint
  · rw [h22]; exact record22_disjoint
  · rw [h23]; exact record23_disjoint
  · rw [h24]; exact record24_disjoint
  · rw [h25]; exact record25_disjoint
  · rw [h26]; exact record26_disjoint
  · rw [h27]; exact record27_disjoint
  · rw [h28]; exact record28_disjoint
  · rw [h29]; exact record29_disjoint
  · rw [h30]; exact record30_disjoint
  · rw [h31]; exact record31_disjoint
  · rw [h32]; exact record32_disjoint
  · rw [h33]; exact record33_disjoint
  · rw [h34]; exact record34_disjoint
  · rw [h35]; exact record35_disjoint
  · rw [h36]; exact record36_disjoint
  · rw [h37]; exact record37_disjoint
  · rw [h38]; exact record38_disjoint
  · rw [h39]; exact record39_disjoint
  · rw [h40]; exact record40_disjoint
  · rw [h41]; exact record41_disjoint
  · rw [h42]; exact record42_disjoint
  · rw [h43]; exact record43_disjoint
  · rw [h44]; exact record44_disjoint
  · rw [h45]; exact record45_disjoint
  · rw [h46]; exact record46_disjoint
  · rw [h47]; exact record47_disjoint
  · rw [h48]; exact record48_disjoint
  · rw [h49]; exact record49_disjoint
  · rw [h50]; exact record50_disjoint
  · rw [h51]; exact record51_disjoint
  · rw [h52]; exact record52_disjoint
  · rw [h53]; exact record53_disjoint
  · rw [h54]; exact record54_disjoint
  · rw [h55]; exact record55_disjoint
  · rw [h56]; exact record56_disjoint
  · rw [h57]; exact record57_disjoint
  · rw [h58]; exact record58_disjoint
  · rw [h59]; exact record59_disjoint
  · rw [h60]; exact record60_disjoint
  · rw [h61]; exact record61_disjoint
  · rw [h62]; exact record62_disjoint
  · rw [h63]; exact record63_disjoint
  · rw [h64]; exact record64_disjoint
  · rw [h65]; exact record65_disjoint
  · rw [h66]; exact record66_disjoint
  · rw [h67]; exact record67_disjoint
  · rw [h68]; exact record68_disjoint
  · rw [h69]; exact record69_disjoint
  · rw [h70]; exact record70_disjoint
  · rw [h71]; exact record71_disjoint
  · rw [h72]; exact record72_disjoint
  · rw [h73]; exact record73_disjoint
  · rw [h74]; exact record74_disjoint
  · rw [h75]; exact record75_disjoint
  · rw [h76]; exact record76_disjoint
  · rw [h77]; exact record77_disjoint
  · rw [h78]; exact record78_disjoint
  · rw [h79]; exact record79_disjoint
  · rw [h80]; exact record80_disjoint
  · rw [h81]; exact record81_disjoint
  · rw [h82]; exact record82_disjoint
  · rw [h83]; exact record83_disjoint
  · rw [h84]; exact record84_disjoint
  · rw [h85]; exact record85_disjoint
  · rw [h86]; exact record86_disjoint
  · rw [h87]; exact record87_disjoint
  · rw [h88]; exact record88_disjoint
  · rw [h89]; exact record89_disjoint
  · rw [h90]; exact record90_disjoint
  · rw [h91]; exact record91_disjoint
  · rw [h92]; exact record92_disjoint
  · rw [h93]; exact record93_disjoint
  · rw [h94]; exact record94_disjoint
  · rw [h95]; exact record95_disjoint
  · rw [h96]; exact record96_disjoint
  · rw [h97]; exact record97_disjoint
  · rw [h98]; exact record98_disjoint
  · rw [h99]; exact record99_disjoint
  · rw [h100]; exact record100_disjoint
  · rw [h101]; exact record101_disjoint
  · rw [h102]; exact record102_disjoint
  · rw [h103]; exact record103_disjoint
  · rw [h104]; exact record104_disjoint

theorem all_records_require_eight (r : List (List ℕ)) (hr : r ∈ records)
    (s : Finset ℕ) (hh : ∀ i : Fin 8, ∃ w ∈ s, w ∈ groups r i) : 8 ≤ s.card :=
  certified_record r (all_records_disjoint r hr) s hh

end Nightfall.Q7BlockerPacking

#print axioms Nightfall.Q7BlockerPacking.packing_lower_bound
#print axioms Nightfall.Q7BlockerPacking.records_count
#print axioms Nightfall.Q7BlockerPacking.all_records_require_eight
