import Mathlib
import PhysicalQubitEnsemble
import TernaryPhase

/-!
NIGHTFALL explicit 3-phase local operator moments for the physical
p=3/4, q=1/4 pure-qubit density matrix. No prior local matrix moments
are assumed: all four entries are proved from product amplitudes.
-/
namespace Nightfall.Quantum.LocalMoments

open scoped BigOperators Matrix ComplexOrder
open Nightfall.Quantum
noncomputable section

private theorem root_square :
    ((Real.sqrt (3 : ℝ) : ℂ) ^ 2) = 3 := by
  exact_mod_cast TernaryPhase.sqrt_three_sq

private theorem root_star :
    star ((Real.sqrt (3 : ℝ)) : ℂ) = ((Real.sqrt (3 : ℝ)) : ℂ) := by
  simp

private theorem two_star : star (2 : ℂ) = 2 := by norm_num

theorem entry_00 (θ : ℂ) :
    PhysicalQubit.qubitDensity (Real.sqrt 3) θ 0 0 = (3:ℂ)/4 := by
  change ((Real.sqrt (3:ℝ) : ℂ) / 2) *
    star ((Real.sqrt (3:ℝ) : ℂ) / 2) = (3:ℂ)/4
  rw [star_div₀, root_star, two_star]
  calc
    ((Real.sqrt (3:ℝ) : ℂ)/2) * ((Real.sqrt (3:ℝ) : ℂ)/2) =
      ((Real.sqrt (3:ℝ) : ℂ)^2)/4 := by ring
    _ = (3:ℂ)/4 := by rw [root_square]

theorem entry_11 (θ : ℂ) (hθ : θ * star θ = 1) :
    PhysicalQubit.qubitDensity (Real.sqrt 3) θ 1 1 = (1:ℂ)/4 := by
  change θ / 2 * star (θ / 2) = (1:ℂ)/4
  rw [star_div₀, two_star]
  calc
    θ/2 * (star θ/2) = (θ * star θ)/4 := by ring
    _ = (1:ℂ)/4 := by rw [hθ]

theorem entry_10 (θ : ℂ) :
    PhysicalQubit.qubitDensity (Real.sqrt 3) θ 1 0 =
      θ * ((Real.sqrt (3:ℝ) : ℂ)/4) := by
  change θ / 2 * star (((Real.sqrt (3:ℝ)) : ℂ)/2) =
    θ * ((Real.sqrt (3:ℝ) : ℂ)/4)
  rw [star_div₀, root_star, two_star]
  ring

theorem entry_01 (θ : ℂ) :
    PhysicalQubit.qubitDensity (Real.sqrt 3) θ 0 1 =
      ((Real.sqrt (3:ℝ) : ℂ)/4) * star θ := by
  change ((Real.sqrt (3:ℝ) : ℂ)/2) * star (θ / 2) =
      ((Real.sqrt (3:ℝ) : ℂ)/4) * star θ
  rw [star_div₀, two_star]
  ring

theorem unweighted_00_value :
    (∑ s : Fin 3,
      PhysicalQubit.qubitDensity (Real.sqrt 3)
        (TernaryPhase.omega ^ s.val) 0 0) = (9:ℂ)/4 := by
  simp_rw [entry_00]
  rw [Fin.sum_univ_three]
  ring

theorem unweighted_11_value :
    (∑ s : Fin 3,
      PhysicalQubit.qubitDensity (Real.sqrt 3)
        (TernaryPhase.omega ^ s.val) 1 1) = (3:ℂ)/4 := by
  calc
    (∑ s : Fin 3,
      PhysicalQubit.qubitDensity (Real.sqrt 3)
        (TernaryPhase.omega ^ s.val) 1 1) =
      ∑ _s : Fin 3, (1:ℂ)/4 := by
        apply Finset.sum_congr rfl
        intro s _
        exact entry_11 _ (PhysicalQubit.unit_phase_powers
          TernaryPhase.omega TernaryPhase.omega_unit s.val)
    _ = (3:ℂ)/4 := by rw [Fin.sum_univ_three]; ring

theorem conjugate_character_sum :
    (∑ s : Fin 3, star (TernaryPhase.omega ^ s.val)) = 0 := by
  have h := congrArg (fun z : ℂ => star z) TernaryPhase.omega_sum
  rw [Fin.sum_univ_three] at h ⊢
  simp only [star_add, star_zero] at h
  exact h

theorem unweighted_10_zero :
    (∑ s : Fin 3,
      PhysicalQubit.qubitDensity (Real.sqrt 3)
        (TernaryPhase.omega ^ s.val) 1 0) = 0 := by
  calc
    (∑ s : Fin 3,
      PhysicalQubit.qubitDensity (Real.sqrt 3)
        (TernaryPhase.omega ^ s.val) 1 0) =
      (∑ s : Fin 3, TernaryPhase.omega ^ s.val) *
        ((Real.sqrt (3:ℝ) : ℂ)/4) := by
          rw [Finset.sum_mul]
          apply Finset.sum_congr rfl
          intro s _
          exact entry_10 _
    _ = 0 := by rw [TernaryPhase.omega_sum]; ring

theorem unweighted_01_zero :
    (∑ s : Fin 3,
      PhysicalQubit.qubitDensity (Real.sqrt 3)
        (TernaryPhase.omega ^ s.val) 0 1) = 0 := by
  calc
    (∑ s : Fin 3,
      PhysicalQubit.qubitDensity (Real.sqrt 3)
        (TernaryPhase.omega ^ s.val) 0 1) =
      (∑ s : Fin 3, star (TernaryPhase.omega ^ s.val)) *
        ((Real.sqrt (3:ℝ) : ℂ)/4) := by
          rw [Finset.sum_mul]
          apply Finset.sum_congr rfl
          intro s _
          rw [entry_01]
          ring
    _ = 0 := by rw [conjugate_character_sum]; ring

theorem weighted_00_zero :
    (∑ s : Fin 3, TernaryPhase.omega ^ s.val *
      PhysicalQubit.qubitDensity (Real.sqrt 3)
        (TernaryPhase.omega ^ s.val) 0 0) = 0 := by
  simp_rw [entry_00]
  rw [← Finset.sum_mul, TernaryPhase.omega_sum]
  ring

theorem weighted_11_zero :
    (∑ s : Fin 3, TernaryPhase.omega ^ s.val *
      PhysicalQubit.qubitDensity (Real.sqrt 3)
        (TernaryPhase.omega ^ s.val) 1 1) = 0 := by
  have h : (∑ s : Fin 3, TernaryPhase.omega ^ s.val *
    PhysicalQubit.qubitDensity (Real.sqrt 3)
      (TernaryPhase.omega ^ s.val) 1 1) =
      ∑ s : Fin 3, TernaryPhase.omega ^ s.val * (1:ℂ)/4 := by
    apply Finset.sum_congr rfl
    intro s _
    rw [entry_11 _ (PhysicalQubit.unit_phase_powers
      TernaryPhase.omega TernaryPhase.omega_unit s.val)]
    ring
  rw [h]
  simp only [mul_one, ← Finset.sum_div, TernaryPhase.omega_sum, zero_div]

theorem weighted_10_zero :
    (∑ s : Fin 3, TernaryPhase.omega ^ s.val *
      PhysicalQubit.qubitDensity (Real.sqrt 3)
        (TernaryPhase.omega ^ s.val) 1 0) = 0 := by
  calc
    (∑ s : Fin 3, TernaryPhase.omega ^ s.val *
      PhysicalQubit.qubitDensity (Real.sqrt 3)
        (TernaryPhase.omega ^ s.val) 1 0) =
        (∑ s : Fin 3, (TernaryPhase.omega ^ s.val)^2) *
          ((Real.sqrt (3:ℝ) : ℂ)/4) := by
      rw [Finset.sum_mul]
      apply Finset.sum_congr rfl
      intro s _
      rw [entry_10]
      ring
    _ = 0 := by rw [TernaryPhase.omega_square_sum]; ring

theorem weighted_01_value :
    (∑ s : Fin 3, TernaryPhase.omega ^ s.val *
      PhysicalQubit.qubitDensity (Real.sqrt 3)
        (TernaryPhase.omega ^ s.val) 0 1) =
          (3:ℂ) * ((Real.sqrt (3:ℝ) : ℂ)/4) := by
  calc
    (∑ s : Fin 3, TernaryPhase.omega ^ s.val *
      PhysicalQubit.qubitDensity (Real.sqrt 3)
        (TernaryPhase.omega ^ s.val) 0 1) =
          ∑ _s : Fin 3, ((Real.sqrt (3:ℝ) : ℂ)/4) := by
      apply Finset.sum_congr rfl
      intro s _
      rw [entry_01]
      calc
        TernaryPhase.omega ^ s.val *
          (((Real.sqrt (3:ℝ) : ℂ)/4) * star (TernaryPhase.omega ^ s.val)) =
          ((Real.sqrt (3:ℝ) : ℂ)/4) *
            (TernaryPhase.omega ^ s.val *
            star (TernaryPhase.omega ^ s.val)) := by ring
        _ = ((Real.sqrt (3:ℝ) : ℂ)/4) := by
          rw [PhysicalQubit.unit_phase_powers
            TernaryPhase.omega TernaryPhase.omega_unit s.val]
          ring
    _ = (3:ℂ) * ((Real.sqrt (3:ℝ) : ℂ)/4) := by
      rw [Fin.sum_univ_three]
      ring

#print axioms Nightfall.Quantum.LocalMoments.unweighted_00_value
#print axioms Nightfall.Quantum.LocalMoments.unweighted_11_value
#print axioms Nightfall.Quantum.LocalMoments.unweighted_10_zero
#print axioms Nightfall.Quantum.LocalMoments.unweighted_01_zero
#print axioms Nightfall.Quantum.LocalMoments.weighted_00_zero
#print axioms Nightfall.Quantum.LocalMoments.weighted_11_zero
#print axioms Nightfall.Quantum.LocalMoments.weighted_10_zero
#print axioms Nightfall.Quantum.LocalMoments.weighted_01_value

end
end Nightfall.Quantum.LocalMoments
