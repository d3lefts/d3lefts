import Mathlib
import PhysicalQubitEnsemble
import TernaryPhase
import TensorCharacter
import LocalTernaryMoments

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
    simp only [smul_eq_mul, state, character,
      PhysicalQubit.productDensity_entry]
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

theorem weighted_local_zero_outside_01
    (a b : Fin 2) (h : a ≠ 0 ∨ b ≠ 1) :
    (∑ s : Fin 3, TernaryPhase.omega ^ s.val *
      PhysicalQubit.qubitDensity (Real.sqrt 3)
        (TernaryPhase.omega ^ s.val) a b) = 0 := by
  fin_cases a <;> fin_cases b
  · exact LocalMoments.weighted_00_zero
  · simp at h
  · exact LocalMoments.weighted_10_zero
  · exact LocalMoments.weighted_11_zero

theorem actual_fourier_entry_zero_off_ghz
    (d : ℕ) (a b : Fin d → Fin 2) (j : Fin d)
    (h : a j ≠ 0 ∨ b j ≠ 1) :
    unnormalizedC d a b = 0 := by
  exact unnormalizedC_zero_of_local d a b j
    (weighted_local_zero_outside_01 (a j) (b j) h)

theorem actual_fourier_ghz_corner_value (d : ℕ) :
    unnormalizedC d (fun _ => 0) (fun _ => 1) =
      ((3:ℂ) * ((Real.sqrt (3:ℝ) : ℂ)/4)) ^ d := by
  rw [unnormalizedC_entry]
  simp [LocalMoments.weighted_01_value]

def localBWeight (a : Fin 2) : ℂ :=
  if a = 0 then (9:ℂ)/4 else (3:ℂ)/4

theorem local_B_diagonal (a : Fin 2) :
    (∑ s : Fin 3,
      PhysicalQubit.qubitDensity (Real.sqrt 3)
        (TernaryPhase.omega ^ s.val) a a) = localBWeight a := by
  fin_cases a
  · exact LocalMoments.unweighted_00_value
  · exact LocalMoments.unweighted_11_value

theorem local_B_offdiagonal (a b : Fin 2) (h : a ≠ b) :
    (∑ s : Fin 3,
      PhysicalQubit.qubitDensity (Real.sqrt 3)
        (TernaryPhase.omega ^ s.val) a b) = 0 := by
  fin_cases a <;> fin_cases b
  · simp at h
  · exact LocalMoments.unweighted_01_zero
  · exact LocalMoments.unweighted_10_zero
  · simp at h

theorem actual_B_diagonal (d : ℕ) (a : Fin d → Fin 2) :
    unnormalizedB d a a = ∏ j, localBWeight (a j) := by
  rw [unnormalizedB_entry]
  apply Finset.prod_congr rfl
  intro j _
  exact local_B_diagonal (a j)

theorem actual_B_offdiagonal (d : ℕ) (a b : Fin d → Fin 2)
    (j : Fin d) (h : a j ≠ b j) :
    unnormalizedB d a b = 0 := by
  rw [unnormalizedB_entry]
  exact Finset.prod_eq_zero (Finset.mem_univ j)
    (local_B_offdiagonal (a j) (b j) h)

theorem actual_C_zero_if_local_diagonal
    (d : ℕ) (a b : Fin d → Fin 2) (j : Fin d)
    (h : a j = b j) : unnormalizedC d a b = 0 := by
  by_cases ha : a j = 0
  · have hb : b j = 0 := by rw [← h]; exact ha
    exact actual_fourier_entry_zero_off_ghz d a b j
      (Or.inr (by simp [hb]))
  · exact actual_fourier_entry_zero_off_ghz d a b j (Or.inl ha)

def unnormalizedCconj (d : ℕ) :
    Matrix (Fin d → Fin 2) (Fin d → Fin 2) ℂ :=
  ∑ x : Fin d → Fin 3, (star (character d x)) • state d x

theorem physical_A_entry_is_two_characters (d : ℕ)
    (a b : Fin d → Fin 2) :
    unnormalizedA d a b =
      (unnormalizedC d a b + unnormalizedCconj d a b) / 2 := by
  classical
  simp only [unnormalizedA, unnormalizedC, unnormalizedCconj,
    Matrix.sum_apply, Matrix.smul_apply, smul_eq_mul]
  rw [← Finset.sum_add_distrib, Finset.sum_div]
  apply Finset.sum_congr rfl
  intro x _
  ring

theorem physical_Cconj_entry_star_swap (d : ℕ)
    (a b : Fin d → Fin 2) :
    unnormalizedCconj d a b = star (unnormalizedC d b a) := by
  classical
  calc
    unnormalizedCconj d a b =
      ∑ x : Fin d → Fin 3,
        star (character d x * state d x b a) := by
          simp only [unnormalizedCconj, Matrix.sum_apply, Matrix.smul_apply, smul_eq_mul]
          apply Finset.sum_congr rfl
          intro x _
          have h : star (state d x b a) = state d x a b :=
            ((state_is_physical d x).1.1.apply a b)
          rw [star_mul, h]
          ring
    _ = star (∑ x : Fin d → Fin 3,
        character d x * state d x b a) := by
          simp
    _ = star (unnormalizedC d b a) := by
          simp [unnormalizedC, Matrix.sum_apply, Matrix.smul_apply, smul_eq_mul]

theorem physical_A_entry_from_fourier (d : ℕ)
    (a b : Fin d → Fin 2) :
    unnormalizedA d a b =
      (unnormalizedC d a b + star (unnormalizedC d b a)) / 2 := by
  rw [physical_A_entry_is_two_characters,
    physical_Cconj_entry_star_swap]

theorem actual_A_zero_if_local_diagonal
    (d : ℕ) (a b : Fin d → Fin 2) (j : Fin d)
    (h : a j = b j) : unnormalizedA d a b = 0 := by
  rw [physical_A_entry_from_fourier,
    actual_C_zero_if_local_diagonal d a b j h,
    actual_C_zero_if_local_diagonal d b a j h.symm]
  norm_num

theorem actual_A_ghz_corner_value
    (d : ℕ) (hd : 0 < d) :
    unnormalizedA d (fun _ => 0) (fun _ => 1) =
      (((3:ℂ) * ((Real.sqrt (3:ℝ) : ℂ)/4)) ^ d) / 2 := by
  let j : Fin d := ⟨0, hd⟩
  have hzero : unnormalizedC d (fun _ => 1) (fun _ => 0) = 0 :=
    actual_fourier_entry_zero_off_ghz d _ _ j (Or.inl (by simp))
  rw [physical_A_entry_from_fourier,
    actual_fourier_ghz_corner_value, hzero]
  simp

theorem unnormalizedA_from_actual_states (d : ℕ)
    (a b : Fin d → Fin 2) :
    unnormalizedA d a b =
      ∑ x : Fin d → Fin 3,
        ((character d x + star (character d x)) / 2) * (state d x a b) := by
  simp [unnormalizedA, Matrix.sum_apply, Matrix.smul_apply, smul_eq_mul]

#print axioms Nightfall.Quantum.OperatorReduction.state_is_physical
#print axioms Nightfall.Quantum.OperatorReduction.unnormalizedB_entry
#print axioms Nightfall.Quantum.OperatorReduction.unnormalizedC_entry
#print axioms Nightfall.Quantum.OperatorReduction.unnormalizedC_zero_of_local
#print axioms Nightfall.Quantum.OperatorReduction.weighted_local_zero_outside_01
#print axioms Nightfall.Quantum.OperatorReduction.actual_fourier_entry_zero_off_ghz
#print axioms Nightfall.Quantum.OperatorReduction.actual_fourier_ghz_corner_value
#print axioms Nightfall.Quantum.OperatorReduction.local_B_diagonal
#print axioms Nightfall.Quantum.OperatorReduction.local_B_offdiagonal
#print axioms Nightfall.Quantum.OperatorReduction.actual_B_diagonal
#print axioms Nightfall.Quantum.OperatorReduction.actual_B_offdiagonal
#print axioms Nightfall.Quantum.OperatorReduction.actual_C_zero_if_local_diagonal
#print axioms Nightfall.Quantum.OperatorReduction.physical_A_entry_is_two_characters
#print axioms Nightfall.Quantum.OperatorReduction.physical_Cconj_entry_star_swap
#print axioms Nightfall.Quantum.OperatorReduction.physical_A_entry_from_fourier
#print axioms Nightfall.Quantum.OperatorReduction.actual_A_zero_if_local_diagonal
#print axioms Nightfall.Quantum.OperatorReduction.actual_A_ghz_corner_value
#print axioms Nightfall.Quantum.OperatorReduction.unnormalizedA_from_actual_states

end
end Nightfall.Quantum.OperatorReduction
