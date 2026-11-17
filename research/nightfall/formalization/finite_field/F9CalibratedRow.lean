import Mathlib
import F9OracleBridge
import F9ActualFieldBasis

/-!
# F9 deterministic calibration from squared coordinate observations

This supplies an actual legal squared-linear *row construction* from the
previously observed vector of coordinate squares. The all-k transcript
injection and its composition with the fixed lower bound are separate
obligations. No unpowered signal is available to the measurement policy.
-/

namespace Nightfall.FiniteField.F9CalibratedRow

open Nightfall.FiniteField.F9OracleBridge
abbrev F9 := Nightfall.FiniteField.F9ActualField.F9
noncomputable section

/-- A fixed function of an observed square, including nonsquare inputs.
Only source-generated square inputs use the successful branch. -/
noncomputable def canonicalRoot (v : F9) : F9 :=
  if h : ∃ z : F9, z ^ 2 = v then Classical.choose h else 0

theorem canonicalRoot_square (x : F9) :
    (canonicalRoot (x ^ 2)) ^ 2 = x ^ 2 := by
  unfold canonicalRoot
  split_ifs with h
  · exact Classical.choose_spec h
  · exact False.elim (h ⟨x, rfl⟩)

theorem source_is_canonical_root_up_to_sign (x : F9) :
    x = canonicalRoot (x ^ 2) ∨
      x = -canonicalRoot (x ^ 2) := by
  have hsq : x * x =
      canonicalRoot (x ^ 2) * canonicalRoot (x ^ 2) := by
    simpa only [pow_two] using (canonicalRoot_square x).symm
  exact (mul_self_eq_mul_self_iff).mp hsq

theorem canonicalRoot_square_nonzero {x : F9} (hx : x ≠ 0) :
    canonicalRoot (x ^ 2) ≠ 0 := by
  intro hzero
  have hpow : x ^ 2 ≠ 0 := pow_ne_zero _ hx
  have hsq := canonicalRoot_square x
  rw [hzero] at hsq
  exact hpow (by simpa using hsq.symm)

/-- Legal row: only the preceding square vector q determines its coefficients.
The three indicated source indices need not be distinct for linearity. -/
noncomputable def calibratedRow {k : ℕ}
    (q : Fin k → F9) (a b c : Fin k) (v w : F9) :
    Fin k → F9 :=
  fun j =>
    (if j = a then (v + w) / canonicalRoot (q a) else 0) +
    (if j = b then v / canonicalRoot (q b) else 0) +
    (if j = c then w / canonicalRoot (q c) else 0)

theorem calibratedRow_dot {k : ℕ}
    (q x : Fin k → F9) (a b c : Fin k) (v w : F9) :
    dot (calibratedRow q a b c v w) x =
      ((v + w) / canonicalRoot (q a)) * x a +
      (v / canonicalRoot (q b)) * x b +
      (w / canonicalRoot (q c)) * x c := by
  classical
  simp [dot, calibratedRow, add_mul, Finset.sum_add_distrib]

theorem calibratedRow_prefix_deterministic {k : ℕ}
    (q r : Fin k → F9) (hqr : q = r)
    (a b c : Fin k) (v w : F9) :
    calibratedRow q a b c v w =
      calibratedRow r a b c v w := by
  rw [hqr]

theorem calibratedRow_global_sign_invariant {k : ℕ}
    (q x : Fin k → F9) (a b c : Fin k) (v w : F9) :
    (dot (calibratedRow q a b c v w) (-x)) ^ 2 =
      (dot (calibratedRow q a b c v w) x) ^ 2 := by
  have hneg : dot (calibratedRow q a b c v w) (-x) =
      -(dot (calibratedRow q a b c v w) x) := by
    simp [dot, Finset.sum_neg_distrib, Pi.neg_apply, mul_neg]
  rw [hneg]
  ring

#print axioms Nightfall.FiniteField.F9CalibratedRow.canonicalRoot_square
#print axioms Nightfall.FiniteField.F9CalibratedRow.source_is_canonical_root_up_to_sign
#print axioms Nightfall.FiniteField.F9CalibratedRow.calibratedRow_dot
#print axioms Nightfall.FiniteField.F9CalibratedRow.calibratedRow_prefix_deterministic
#print axioms Nightfall.FiniteField.F9CalibratedRow.calibratedRow_global_sign_invariant

end
end Nightfall.FiniteField.F9CalibratedRow
