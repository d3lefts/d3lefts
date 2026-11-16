import Mathlib
import F9ActualFieldBasis
import F9NonadaptiveLower
import F9GapArithmetic

/-!
Concrete F9 instantiation of the exact same squared-K-linear oracle lower bound.
The proof supplies the field characteristic and actual separating measurement
rows, rather than supplying the asymptotic fixed-lower hypothesis from outside.
The adaptive upper remains explicitly conditional on a full all-k protocol.
-/

namespace Nightfall.FiniteField.F9ConcreteLower
open Nightfall.FiniteField
noncomputable section

abbrev F9 := F9ActualField.F9

theorem F9_two_ne_zero : (2 : F9) ≠ 0 := by
  norm_num [F9]

theorem actual_fixed_square_lower
    {m k : ℕ} (hk : 2 ≤ k)
    (rows : Fin m → Fin k → F9)
    (hsep : F9NonadaptiveLower.fixedSquareSeparates rows) :
    F9GapArithmetic.fixedLower k ≤ m := by
  simpa [F9GapArithmetic.fixedLower] using
    F9NonadaptiveLower.same_oracle_nonadaptive_lower
      hk rows F9_two_ne_zero hsep

theorem actual_fixed_family_lower
    (fixed : ℕ → ℕ)
    (rows : (k : ℕ) → Fin (fixed k) → Fin k → F9)
    (hsep : ∀ k, F9NonadaptiveLower.fixedSquareSeparates (rows k)) :
    ∀ k, 2 ≤ k → F9GapArithmetic.fixedLower k ≤ fixed k := by
  intro k hk
  exact actual_fixed_square_lower hk (rows k) (hsep k)

theorem same_oracle_gap_given_actual_adaptive_upper
    (fixed adaptive : ℕ → ℕ)
    (rows : (k : ℕ) → Fin (fixed k) → Fin k → F9)
    (hsep : ∀ k, F9NonadaptiveLower.fixedSquareSeparates (rows k))
    (hadaptive : ∀ k, 2 ≤ k →
      adaptive k ≤ F9GapArithmetic.adaptiveUpper k) :
    ∀ threshold : ℕ, ∃ k : ℕ,
      threshold ≤ fixed k - adaptive k := by
  exact F9GapArithmetic.f9_gap_unbounded fixed adaptive
    (actual_fixed_family_lower fixed rows hsep) hadaptive

#print axioms Nightfall.FiniteField.F9ConcreteLower.F9_two_ne_zero
#print axioms Nightfall.FiniteField.F9ConcreteLower.actual_fixed_square_lower
#print axioms Nightfall.FiniteField.F9ConcreteLower.actual_fixed_family_lower
#print axioms Nightfall.FiniteField.F9ConcreteLower.same_oracle_gap_given_actual_adaptive_upper

end
end Nightfall.FiniteField.F9ConcreteLower
