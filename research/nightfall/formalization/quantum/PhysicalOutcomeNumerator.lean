import Mathlib
import PhysicalOperatorReduction

/-!
NIGHTFALL — exact support of the physical source-averaged Bayes numerator.

No "GHZ support" is supplied as an axiom. This is deduced from the actual
ternary pure-product states, the cubic-root character cancellations, and the
source-derived operator A in PhysicalOperatorReduction.

This is NOT yet the trace-based Born risk identity and NOT an attaining
all-register POVM: these remain separate proof obligations.
-/

namespace Nightfall.Quantum.PhysicalNumerator

open scoped BigOperators ComplexOrder
open Nightfall.Quantum.OperatorReduction
noncomputable section

abbrev Register (d : ℕ) := Fin d → Fin 2

def zeroRay (d : ℕ) : Register d := fun _ => 0
def oneRay (d : ℕ) : Register d := fun _ => 1

theorem C_zero_if_bra_not_zero (d : ℕ)
    (a b : Register d) (ha : a ≠ zeroRay d) :
    unnormalizedC d a b = 0 := by
  have hex : ∃ j : Fin d, a j ≠ (0 : Fin 2) := by
    by_contra h
    push_neg at h
    apply ha
    funext j
    simpa [zeroRay] using h j
  rcases hex with ⟨j, hj⟩
  exact actual_fourier_entry_zero_off_ghz d a b j (Or.inl hj)

theorem C_zero_if_ket_not_one (d : ℕ)
    (a b : Register d) (hb : b ≠ oneRay d) :
    unnormalizedC d a b = 0 := by
  have hex : ∃ j : Fin d, b j ≠ (1 : Fin 2) := by
    by_contra h
    push_neg at h
    apply hb
    funext j
    simpa [oneRay] using h j
  rcases hex with ⟨j, hj⟩
  exact actual_fourier_entry_zero_off_ghz d a b j (Or.inr hj)

theorem C_zero_outside_GHZ_corner (d : ℕ)
    (a b : Register d)
    (h : a ≠ zeroRay d ∨ b ≠ oneRay d) :
    unnormalizedC d a b = 0 := by
  rcases h with ha | hb
  · exact C_zero_if_bra_not_zero d a b ha
  · exact C_zero_if_ket_not_one d a b hb

theorem A_zero_outside_two_GHZ_corners (d : ℕ)
    (a b : Register d)
    (hforward : a ≠ zeroRay d ∨ b ≠ oneRay d)
    (hbackward : b ≠ zeroRay d ∨ a ≠ oneRay d) :
    unnormalizedA d a b = 0 := by
  calc
    unnormalizedA d a b =
        (unnormalizedC d a b + star (unnormalizedC d b a)) / 2 :=
      physical_A_entry_from_fourier d a b
    _ = 0 := by
      rw [C_zero_outside_GHZ_corner d a b hforward,
        C_zero_outside_GHZ_corner d b a hbackward]
      simp

theorem A_nonzero_implies_GHZ_corners (d : ℕ)
    (a b : Register d)
    (hnonzero : unnormalizedA d a b ≠ 0) :
    (a = zeroRay d ∧ b = oneRay d) ∨
      (a = oneRay d ∧ b = zeroRay d) := by
  classical
  by_cases hfirst : a = zeroRay d ∧ b = oneRay d
  · exact Or.inl hfirst
  by_cases hsecond : a = oneRay d ∧ b = zeroRay d
  · exact Or.inr hsecond
  have hf : a ≠ zeroRay d ∨ b ≠ oneRay d :=
    not_and_or.mp hfirst
  have hb : b ≠ zeroRay d ∨ a ≠ oneRay d :=
    (not_and_or.mp hsecond).symm
  exact (hnonzero (A_zero_outside_two_GHZ_corners d a b hf hb)).elim

theorem A_all_diagonal_entries_zero (d : ℕ) (hd : 0 < d)
    (a : Register d) : unnormalizedA d a a = 0 := by
  exact actual_A_zero_if_local_diagonal d a a ⟨0, hd⟩ rfl

#print axioms Nightfall.Quantum.PhysicalNumerator.C_zero_outside_GHZ_corner
#print axioms Nightfall.Quantum.PhysicalNumerator.A_zero_outside_two_GHZ_corners
#print axioms Nightfall.Quantum.PhysicalNumerator.A_nonzero_implies_GHZ_corners
#print axioms Nightfall.Quantum.PhysicalNumerator.A_all_diagonal_entries_zero

end
end Nightfall.Quantum.PhysicalNumerator
