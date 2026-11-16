import Mathlib
import F9OracleBridge

/-!
Bind the two-coordinate squared sign block to the ACTUAL field GF(3^2).
No caller-provided existence of a two-vector basis is needed.
This local theorem alone is not the full all-k adaptive protocol.
-/

namespace Nightfall.FiniteField.F9ActualField
noncomputable section

abbrev F9 := GaloisField 3 2

theorem actual_F9_finrank :
    Module.finrank (ZMod 3) F9 = 2 := by
  simpa [F9] using (GaloisField.finrank 3 (by decide : 2 ≠ 0))

noncomputable def actual_F9_basis :
    Module.Basis (Fin 2) (ZMod 3) F9 :=
  Module.finBasisOfFinrankEq (ZMod 3) F9 actual_F9_finrank

theorem actual_F9_squared_pair_decodes (a b : Fin 2 → Bool)
    (h : (F9OracleBridge.blockValue actual_F9_basis a) ^ 2 =
      (F9OracleBridge.blockValue actual_F9_basis b) ^ 2) : a = b :=
  F9OracleBridge.block_value_squared_injective actual_F9_basis a b h

#print axioms Nightfall.FiniteField.F9ActualField.actual_F9_finrank
#print axioms Nightfall.FiniteField.F9ActualField.actual_F9_squared_pair_decodes

end
end Nightfall.FiniteField.F9ActualField
