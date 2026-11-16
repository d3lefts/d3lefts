import Mathlib
import PhysicalQubitEnsemble
import TernaryPhase
import TensorCharacter

/-!
NIGHTFALL — transitive physical operator-entry bridge.

The averaged source operators here are *defined from the actual positive
pure-product density matrices*, not from a supplied diagonal/corner ansatz.
Their entries factor by the finite ternary-product character theorem.
CI revision 2: verify transitive dependency compilation and explicit entry factorization.\nNo POVM optimality, GHZ saturation, or character-local matrix-entry formula
is asserted without its own subsequent proof.
-/

namespace Nightfall.Quantum.OperatorReduction

open scoped BigOperators Matrix ComplexOrder
open Matrix
noncomputable section

def state (d : ℕ) (x : Fin d → Fin 3) :
    Matrix (Fin d → Fin 2) (Fin d → Fin 2) ℂ :=
  PhysicalQubit.productDensity d (Real.sqrt 3)
    (fun j => TernaryPhase.omega ^ (x j).val)

def character (d : ℕ) (x : Fin d → Fin 3) : ℂ :=
  ∏ j, TernaryPhase.omega ^ (x j).val

theorem state_is_physical (d : ℕ) (x : Fin d → Fin 3) :
    (state d x).PosSemidef ∧ Matrix.trace (state d x) = 1 := by
  constructor
  · exact PhysicalQubit.productDensity_psd d _ _
  · exact PhysicalQubit.powered_phase_product_physical
      d TernaryPhase.omega TernaryPhase.omega_unit x

def unnormalizedB (d : ℕ) :
    Matrix (Fin d → Fin 2) (Fin d → Fin 2) ℂ :=
  ∑ x : Fin d → Fin 3, state d x

def unnormalizedC (d : ℕ) :
    Matrix (Fin d → Fin 2) (Fin d → Fin 2) ℂ :=
  ∑ x : Fin d → Fin 3, character d x • state d x

def unnormalizedA (d : ℕ) :
    Matrix (Fin d → Fin 2) (Fin d → Fin 2) ℂ :=
  ∑ x : Fin d → Fin 3,
    (((character d x + star (character d x)) / 2) • state d x)

theorem unnormalizedB_entry (d : ℕ)
    (a b : Fin d → Fin 2) :
    unnormalizedB d a b =
      ∏ j, (∑ s : Fin 3,
        PhysicalQubit.qubitDensity (Real.sqrt 3)
          (TernaryPhase.omega ^ s.val) (a j) (b j)) := by
  classical
  have h : unnormalizedB d a b =
      ∑ x : Fin d → Fin 3,
        ∏ j, PhysicalQubit.qubitDensity (Real.sqrt 3)
          (TernaryPhase.omega ^ (x j).val) (a j) (b j) := by
    simp only [unnormalizedB, Matrix.sum_apply]
    apply Finset.sum_congr rfl
    intro x _
    exact PhysicalQubit.productDensity_entry
      d (Real.sqrt 3) (fun j => TernaryPhase.omega ^ (x j).val) a b
  rw [h]
  exact TensorCharacter.ternary_tensor_sum_factor
    d (fun j s => PhysicalQubit.qubitDensity (Real.sqrt 3)
      (TernaryPhase.omega ^ s.val) (a j) (b j))

theorem unnormalizedC_entry (d : ℕ)
    (a b : Fin d → Fin 2) :
    unnormalizedC d a b =
      ∏ j, (∑ s : Fin 3,
        TernaryPhase.omega ^ s.val *
        PhysicalQubit.qubitDensity (Real.sqrt 3)
          (TernaryPhase.omega ^ s.val) (a j) (b j)) := by
  classical
  have h : unnormalizedC d a b =
      ∑ x : Fin d → Fin 3,
        (∏ j, TernaryPhase.omega ^ (x j).val) *
          (∏ j, PhysicalQubit.qubitDensity (Real.sqrt 3)
            (TernaryPhase.omega ^ (x j).val) (a j) (b j)) := by
    simp only [unnormalizedC, Matrix.sum_apply, Matrix.smul_apply]
    apply Finset.sum_congr rfl
    intro x _
    rw [PhysicalQubit.productDensity_entry]
    rfl
  rw [h]
  exact TensorCharacter.character_weighted_tensor_sum d TernaryPhase.omega
    (fun j s => PhysicalQubit.qubitDensity (Real.sqrt 3)
      (TernaryPhase.omega ^ s.val) (a j) (b j))

theorem unnormalizedC_zero_of_local
    (d : ℕ) (a b : Fin d → Fin 2) (j : Fin d)
    (hzero : (∑ s : Fin 3,
        TernaryPhase.omega ^ s.val *
        PhysicalQubit.qubitDensity (Real.sqrt 3)
          (TernaryPhase.omega ^ s.val) (a j) (b j)) = 0) :
    unnormalizedC d a b = 0 := by
  rw [unnormalizedC_entry]
  exact Finset.prod_eq_zero (Finset.mem_univ j) hzero

theorem unnormalizedA_from_actual_states (d : ℕ)
    (a b : Fin d → Fin 2) :
    unnormalizedA d a b =
      ∑ x : Fin d → Fin 3,
        ((character d x + star (character d x)) / 2) * (state d x a b) := by
  simp [unnormalizedA]

#print axioms Nightfall.Quantum.OperatorReduction.state_is_physical
#print axioms Nightfall.Quantum.OperatorReduction.unnormalizedB_entry
#print axioms Nightfall.Quantum.OperatorReduction.unnormalizedC_entry
#print axioms Nightfall.Quantum.OperatorReduction.unnormalizedC_zero_of_local
#print axioms Nightfall.Quantum.OperatorReduction.unnormalizedA_from_actual_states

end
end Nightfall.Quantum.OperatorReduction
