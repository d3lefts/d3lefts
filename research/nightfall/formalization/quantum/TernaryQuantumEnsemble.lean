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

open scoped ComplexOrder
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

#print axioms Nightfall.Quantum.TernarySource.actual_ternary_state_physical
#print axioms Nightfall.Quantum.TernarySource.first_character_tensor_cancels

end Nightfall.Quantum.TernarySource
