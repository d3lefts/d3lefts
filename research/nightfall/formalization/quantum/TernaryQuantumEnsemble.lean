import PhysicalQubitEnsemble
import TernaryPhase
import TensorCharacter

/-!
NIGHTFALL: original physical ternary ensemble, all tensor lengths.

This file closes the concrete pure-state positivity and trace-one proof
using the explicitly constructed complex cube root of unity; it also
kernel-proves all-dimensional cancellation of the first character
component. The full matrix-valued weighted character filter and all-POVM
optimal Bayes decision theorem are separate subsequent gates.
-/

namespace Nightfall.Quantum.TernarySource

open scoped BigOperators ComplexOrder
open Nightfall.Quantum.PhysicalQubit
open Nightfall.Quantum.TernaryPhase
open Nightfall.Quantum.TensorCharacter

theorem actual_ternary_state_physical
    (d : ℕ) (x : Fin d → Fin 3) :
    (productDensity d (Real.sqrt 3) (fun j => omega ^ (x j).val)).PosSemidef ∧
    Matrix.trace (productDensity d (Real.sqrt 3)
       (fun j => omega ^ (x j).val)) = 1 := by
  constructor
  · exact productDensity_psd _ _ _
  · exact powered_phase_product_physical d omega omega_unit x

theorem first_character_tensor_cancels
    (d : ℕ) (hd : 0 < d) :
    (∑ x : Fin d → Fin 3, ∏ j, omega ^ (x j).val) = 0 := by
  let j : Fin d := ⟨0, hd⟩
  simpa using
    (local_moment_zero_kills_tensor d
      (fun _ (s : Fin 3) => omega ^ s.val) j omega_sum)

theorem actual_source_unweighted_tensor_factor (d : ℕ)
    (a b : Fin d → Fin 2) :
    (∑ x : Fin d → Fin 3,
       productDensity d (Real.sqrt 3) (fun j => omega ^ (x j).val) a b) =
    ∏ j, (∑ s : Fin 3,
       qubitDensity (Real.sqrt 3) (omega ^ s.val) (a j) (b j)) := by
  classical
  calc
    (∑ x : Fin d → Fin 3,
       productDensity d (Real.sqrt 3) (fun j => omega ^ (x j).val) a b) =
      ∑ x : Fin d → Fin 3, ∏ j,
        qubitDensity (Real.sqrt 3) (omega ^ (x j).val) (a j) (b j) := by
          apply Finset.sum_congr rfl
          intro x _
          exact productDensity_entry d (Real.sqrt 3)
            (fun j => omega ^ (x j).val) a b
    _ = ∏ j, (∑ s : Fin 3,
        qubitDensity (Real.sqrt 3) (omega ^ s.val) (a j) (b j)) :=
          ternary_tensor_sum_factor d
            (fun j s => qubitDensity (Real.sqrt 3) (omega ^ s.val) (a j) (b j))

theorem actual_source_character_weighted_tensor_factor (d : ℕ) (a b : Fin d → Fin 2) :
    (∑ x : Fin d → Fin 3,
       (∏ j, omega ^ (x j).val) *
         productDensity d (Real.sqrt 3) (fun j => omega ^ (x j).val) a b) =
    ∏ j, (∑ s : Fin 3,
       omega ^ s.val * qubitDensity (Real.sqrt 3) (omega ^ s.val) (a j) (b j)) := by
  classical
  calc
    (∑ x : Fin d → Fin 3,
       (∏ j, omega ^ (x j).val) *
         productDensity d (Real.sqrt 3) (fun j => omega ^ (x j).val) a b) =
      ∑ x : Fin d → Fin 3, (∏ j, omega ^ (x j).val) *
        (∏ j, qubitDensity (Real.sqrt 3) (omega ^ (x j).val) (a j) (b j)) := by
          apply Finset.sum_congr rfl
          intro x _
          rw [productDensity_entry]
    _ = ∏ j, (∑ s : Fin 3,
       omega ^ s.val * qubitDensity (Real.sqrt 3) (omega ^ s.val) (a j) (b j)) :=
          character_weighted_tensor_sum d omega
            (fun j s => qubitDensity (Real.sqrt 3) (omega ^ s.val) (a j) (b j))

#print axioms Nightfall.Quantum.TernarySource.actual_source_unweighted_tensor_factor
#print axioms Nightfall.Quantum.TernarySource.actual_source_character_weighted_tensor_factor

#print axioms Nightfall.Quantum.TernarySource.actual_ternary_state_physical
#print axioms Nightfall.Quantum.TernarySource.first_character_tensor_cancels

end Nightfall.Quantum.TernarySource
