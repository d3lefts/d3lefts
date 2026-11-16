import Mathlib

/-!
NIGHTFALL ternary pure qubit phase: an explicit physical primitive cubic
root of unity with positive amplitudes p=3/4, q=1/4.

No primitive-root axiom is assumed. All identities reduce to arithmetic
and the real positive square-root identity sqrt(3)^2=3.
-/

namespace Nightfall.Quantum.TernaryPhase

open scoped ComplexOrder
noncomputable section

def omega : ℂ := ⟨-(1 / 2 : ℝ), Real.sqrt 3 / 2⟩

theorem sqrt_three_sq : (Real.sqrt (3 : ℝ)) ^ 2 = 3 := by
  norm_num

theorem omega_poly : omega ^ 2 + omega + 1 = 0 := by
  apply Complex.ext
  · simp [omega, pow_two, Complex.mul_re, sqrt_three_sq]
    nlinarith [sqrt_three_sq]
  · simp [omega, pow_two, Complex.mul_im]
    ring

theorem omega_unit : omega * star omega = 1 := by
  apply Complex.ext
  · simp [omega, Complex.mul_re, sqrt_three_sq]
    nlinarith [sqrt_three_sq]
  · simp [omega, Complex.mul_im]
    ring

theorem omega_cube : omega ^ 3 = 1 := by
  apply sub_eq_zero.mp
  calc
    omega ^ 3 - 1 = (omega - 1) * (omega ^ 2 + omega + 1) := by ring
    _ = 0 := by rw [omega_poly]; ring

theorem omega_sum : (∑ a : Fin 3, omega ^ a.val) = 0 := by
  rw [Fin.sum_univ_three]
  norm_num
  linear_combination omega_poly

theorem omega_square_sum : (∑ a : Fin 3, (omega ^ a.val) ^ 2) = 0 := by
  rw [Fin.sum_univ_three]
  norm_num
  have hfour : omega ^ 4 = omega := by
    calc omega ^ 4 = omega ^ 3 * omega := by ring
      _ = omega := by rw [omega_cube]; ring
  rw [show (omega ^ 2) ^ 2 = omega ^ 4 by ring, hfour]
  linear_combination omega_poly

#print axioms Nightfall.Quantum.TernaryPhase.omega_poly
#print axioms Nightfall.Quantum.TernaryPhase.omega_unit
#print axioms Nightfall.Quantum.TernaryPhase.omega_cube
#print axioms Nightfall.Quantum.TernaryPhase.omega_sum
#print axioms Nightfall.Quantum.TernaryPhase.omega_square_sum

end
end Nightfall.Quantum.TernaryPhase
