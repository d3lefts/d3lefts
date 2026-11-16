import Mathlib
import F9ActualFieldBasis
import F9OracleBridge
import F9GapArithmetic

/-!
An arbitrary-length (not finite-checked-only) sign-packing injection for F9.

Given n Boolean relative signs, split them deterministically into padded
blocks of two. The squared value of the actual GF(3^2) basis block uniquely
determines each block and hence all n signs. No assumption of an UNSQUARED
block decoder is needed. This is the all-n packet/injectivity component,
NOT YET a proof that each block value arises from a legal adaptive linear row
chosen solely from earlier coordinate-square outputs.
-/

namespace Nightfall.FiniteField.F9SignPacketAllK
open Nightfall.FiniteField
noncomputable section

def paddedPair {n : ℕ} (bits : Fin n → Bool)
    (block : Fin ((n + 1) / 2)) : Fin 2 → Bool :=
  fun digit =>
    if h : 2 * block.val + digit.val < n then
      bits ⟨2 * block.val + digit.val, h⟩
    else false

theorem all_sign_bits_decoded
    (n : ℕ) (x y : Fin n → Bool)
    (h : ∀ block : Fin ((n + 1) / 2),
      (F9OracleBridge.blockValue F9ActualField.actual_F9_basis
        (paddedPair x block)) ^ 2 =
      (F9OracleBridge.blockValue F9ActualField.actual_F9_basis
        (paddedPair y block)) ^ 2) : x = y := by
  classical
  funext j
  let block : Fin ((n + 1) / 2) := ⟨j.val / 2, by omega⟩
  let digit : Fin 2 := ⟨j.val % 2, by omega⟩
  have hidx : 2 * block.val + digit.val = j.val := by
    dsimp [block, digit]
    omega
  have hvalid : 2 * block.val + digit.val < n := by
    omega
  have hp := F9OracleBridge.block_value_squared_injective
    F9ActualField.actual_F9_basis
    (paddedPair x block) (paddedPair y block) (h block)
  have hbit := congrArg (fun f : Fin 2 → Bool => f digit) hp
  have hx : paddedPair x block digit = x j := by
    simp only [paddedPair, dif_pos hvalid]
    congr 1
    exact Fin.ext hidx
  have hy : paddedPair y block digit = y j := by
    simp only [paddedPair, dif_pos hvalid]
    congr 1
    exact Fin.ext hidx
  simpa only [hx, hy] using hbit

theorem packet_count_fits_same_oracle_upper
    (k s : ℕ) (hs : s ≤ k) :
    k + s / 2 ≤ F9GapArithmetic.adaptiveUpper k := by
  dsimp [F9GapArithmetic.adaptiveUpper]
  omega

theorem full_support_exact_budget (k : ℕ) :
    k + k / 2 = F9GapArithmetic.adaptiveUpper k := by
  dsimp [F9GapArithmetic.adaptiveUpper]
  omega

#print axioms Nightfall.FiniteField.F9SignPacketAllK.all_sign_bits_decoded
#print axioms Nightfall.FiniteField.F9SignPacketAllK.packet_count_fits_same_oracle_upper
#print axioms Nightfall.FiniteField.F9SignPacketAllK.full_support_exact_budget

end
end Nightfall.FiniteField.F9SignPacketAllK
