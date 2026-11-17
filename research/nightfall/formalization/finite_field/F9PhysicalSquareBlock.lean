import Mathlib
import F9CalibratedRow
import F9ActualFieldBasis
import F9OracleBridge

/-!
# Exact physical F9 squared-linear two-digit readout

The row is computed exclusively from the observed square prefix. Under
source phase-factorization the **actual squared** K-linear oracle result
equals the squared two-digit basis code used by the existing all-length
packet injection theorem. This is a source bridge, not a full adaptive policy.
-/

namespace Nightfall.FiniteField.F9PhysicalSquareBlock
open Nightfall.FiniteField.F9OracleBridge
open Nightfall.FiniteField.F9CalibratedRow
abbrev F9 := Nightfall.FiniteField.F9ActualField.F9

noncomputable def phase (b : Bool) : F9 := if b then 1 else -1
noncomputable def digit (b : Bool) : F9 := if b then 2 else 0

theorem physical_square_two_digit
    (u0 u1 u2 v w e : F9)
    (b0 b1 : Bool)
    (hu0 : u0 ≠ 0) (hu1 : u1 ≠ 0) (hu2 : u2 ≠ 0)
    (he : e ^ 2 = 1) :
    (((v + w) / u0) * (e * u0) +
       (v / u1) * (e * phase b0 * u1) +
       (w / u2) * (e * phase b1 * u2)) ^ 2 =
       (v * digit b0 + w * digit b1) ^ 2 := by
  have hval :
      ((v + w) / u0) * (e * u0) +
        (v / u1) * (e * phase b0 * u1) +
        (w / u2) * (e * phase b1 * u2) =
        e * (v * digit b0 + w * digit b1) := by
    cases b0 <;> cases b1 <;>
      simp [phase, digit] <;>
      field_simp [hu0, hu1, hu2] <;> ring
  rw [hval, mul_pow, he, one_mul]

theorem actual_squared_linear_reading {k : ℕ}
    (q x : Fin k → F9) (a b c : Fin k)
    (v w e : F9) (b0 b1 : Bool)
    (he : e ^ 2 = 1)
    (ha0 : canonicalRoot (q a) ≠ 0)
    (hb0 : canonicalRoot (q b) ≠ 0)
    (hc0 : canonicalRoot (q c) ≠ 0)
    (ha : x a = e * canonicalRoot (q a))
    (hb : x b = e * phase b0 * canonicalRoot (q b))
    (hc : x c = e * phase b1 * canonicalRoot (q c)) :
    (dot (calibratedRow q a b c v w) x) ^ 2 =
      (v * digit b0 + w * digit b1) ^ 2 := by
  rw [calibratedRow_dot, ha, hb, hc]
  exact physical_square_two_digit
    (canonicalRoot (q a)) (canonicalRoot (q b))
    (canonicalRoot (q c)) v w e b0 b1 ha0 hb0 hc0 he

theorem actual_basis_block_expansion (bits : Fin 2 → Bool) :
    blockValue Nightfall.FiniteField.F9ActualField.actual_F9_basis bits =
      Nightfall.FiniteField.F9ActualField.actual_F9_basis 0 * digit (bits 0) +
      Nightfall.FiniteField.F9ActualField.actual_F9_basis 1 * digit (bits 1) := by
  classical
  rw [blockValue, Nightfall.FiniteField.F9ActualField.actual_F9_basis.equivFun_symm_apply, Fin.sum_univ_two]
  have htwo : (algebraMap (ZMod 3) F9) (2 : ZMod 3) = (2 : F9) := by
    exact map_ofNat (algebraMap (ZMod 3) F9) 2
  cases h0 : bits 0 <;> cases h1 : bits 1 <;>
    simp [digit, signBit, h0, h1, Algebra.smul_def, htwo] <;> ring

#print axioms Nightfall.FiniteField.F9PhysicalSquareBlock.physical_square_two_digit
#print axioms Nightfall.FiniteField.F9PhysicalSquareBlock.actual_squared_linear_reading
#print axioms Nightfall.FiniteField.F9PhysicalSquareBlock.actual_basis_block_expansion

end Nightfall.FiniteField.F9PhysicalSquareBlock
