import Mathlib
import PhysicalQubitEnsemble
import TernaryPhase
import LocalTernaryMoments

/-!
NIGHTFALL: actual qubit local phase identities for the fixed physical
p=3/4, q=1/4 ternary ensemble. No assumed "Fourier coefficient" table.
-/

namespace Nightfall.Quantum.LocalTernaryMoments

open scoped BigOperators ComplexOrder
open Nightfall.Quantum.PhysicalQubit
open Nightfall.Quantum.TernaryPhase

theorem omega_star_sq : star omega = omega ^ 2 := by
  have h : omega * (star omega - omega ^ 2) = 0 := by
    calc
      _ = omega * star omega - omega ^ 3 := by ring
      _ = 0 := by rw [omega_unit, omega_cube]; ring
  have hn : omega ≠ 0 := by
    intro hz
    have hu := omega_unit
    rw [hz] at hu
    norm_num at hu
  exact sub_eq_zero.mp ((mul_eq_zero.mp h).resolve_left hn)

theorem real_sqrt_three_complex_sq :
    ((Real.sqrt 3 : ℝ) : ℂ) ^ 2 = 3 := by
  exact_mod_cast (by norm_num : (Real.sqrt (3 : ℝ)) ^ 2 = 3)

theorem actual_local_density_entry (s : Fin 3) (a b : Fin 2) :
    qubitDensity (Real.sqrt 3) (omega ^ s.val) a b =
      if a = 0 then
        (if b = 0 then (3 / 4 : ℂ)
         else ((Real.sqrt 3 : ℝ) : ℂ) / 4 * (omega ^ 2) ^ s.val)
      else
        (if b = 0 then ((Real.sqrt 3 : ℝ) : ℂ) / 4 * omega ^ s.val
         else (1 / 4 : ℂ)) := by
  fin_cases a <;> fin_cases b
  · simpa using (Nightfall.Quantum.LocalMoments.entry_00 (omega ^ s.val))
  · have hs : star (omega ^ s.val) = (omega ^ 2) ^ s.val := by
      rw [star_pow, omega_star_sq]
    simpa [hs] using (Nightfall.Quantum.LocalMoments.entry_01 (omega ^ s.val))
  · simpa [mul_comm] using (Nightfall.Quantum.LocalMoments.entry_10 (omega ^ s.val))
  · simpa using (Nightfall.Quantum.LocalMoments.entry_11 (omega ^ s.val)
      (unit_phase_powers omega omega_unit s.val))

#print axioms Nightfall.Quantum.LocalTernaryMoments.omega_star_sq
#print axioms Nightfall.Quantum.LocalTernaryMoments.actual_local_density_entry

end Nightfall.Quantum.LocalTernaryMoments
