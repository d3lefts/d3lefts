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

theorem two_GHZ_rays_distinct (d : ℕ) (hd : 0 < d) :
    zeroRay d ≠ oneRay d := by
  intro h
  have h01 : (0 : Fin 2) = 1 := by
    simpa [zeroRay, oneRay] using
      congrArg (fun v : Register d => v ⟨0, hd⟩) h
  exact (by decide : (0 : Fin 2) ≠ 1) h01

theorem physical_A_is_two_corner_matrix (d : ℕ) (hd : 0 < d) :
    unnormalizedA d =
      Matrix.single (zeroRay d) (oneRay d)
        (unnormalizedA d (zeroRay d) (oneRay d)) +
      Matrix.single (oneRay d) (zeroRay d)
        (unnormalizedA d (oneRay d) (zeroRay d)) := by
  classical
  have hray := two_GHZ_rays_distinct d hd
  ext a b
  by_cases h1 : a = zeroRay d ∧ b = oneRay d
  · rcases h1 with ⟨rfl, rfl⟩
    simp [Matrix.single, hray, hray.symm]
  by_cases h2 : a = oneRay d ∧ b = zeroRay d
  · rcases h2 with ⟨rfl, rfl⟩
    simp [Matrix.single, hray, hray.symm]
  have hf : a ≠ zeroRay d ∨ b ≠ oneRay d := not_and_or.mp h1
  have hb : b ≠ zeroRay d ∨ a ≠ oneRay d := (not_and_or.mp h2).symm
  have hzero := A_zero_outside_two_GHZ_corners d a b hf hb
  simp [Matrix.single, hzero, h1, h2, eq_comm]

theorem actual_physical_A_trace_two_rays
    (d : ℕ) (hd : 0 < d)
    (E : Matrix (Register d) (Register d) ℂ) :
    Matrix.trace (unnormalizedA d * E) =
      unnormalizedA d (zeroRay d) (oneRay d) *
        E (oneRay d) (zeroRay d) +
      unnormalizedA d (oneRay d) (zeroRay d) *
        E (zeroRay d) (oneRay d) := by
  classical
  rw [physical_A_is_two_corner_matrix d hd, add_mul, Matrix.trace_add]
  simp only [Matrix.trace_single_mul, smul_eq_mul]

#print axioms Nightfall.Quantum.PhysicalNumerator.two_GHZ_rays_distinct
#print axioms Nightfall.Quantum.PhysicalNumerator.physical_A_is_two_corner_matrix
#print axioms Nightfall.Quantum.PhysicalNumerator.actual_physical_A_trace_two_rays
#print axioms Nightfall.Quantum.PhysicalNumerator.C_zero_outside_GHZ_corner
#print axioms Nightfall.Quantum.PhysicalNumerator.A_zero_outside_two_GHZ_corners
#print axioms Nightfall.Quantum.PhysicalNumerator.A_nonzero_implies_GHZ_corners
#print axioms Nightfall.Quantum.PhysicalNumerator.A_all_diagonal_entries_zero

end
end Nightfall.Quantum.PhysicalNumerator
