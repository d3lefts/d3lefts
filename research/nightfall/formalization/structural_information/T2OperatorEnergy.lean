import Mathlib

/-!
# NIGHTFALL T2 — noncommuting crossed-slot energy, finite complex-sector model

A mathematically independent formal derivation of source equation (8) for
one-complex-coordinate-per-sector path vectors. Unlike the existing XOR
certificate, this is an actual arbitrary complex linear-operator inequality.

Let `T b a` be the amplitude of path from initial sector `a` to final
sector `b`. Let `P` be a complex linear contraction in the physical
Hilbert norm (squared norm = sum of coordinate squared complex moduli).

At crossed equality `a=b'`, the grouped synthesis vector has coordinate
`a` equal to `sum_b beta_b (P (delta_b (T b a))) a`. We prove
its energy is bounded by `sum_b |beta_b|^2 sum_a |T b a|^2`,
with no assumption that `P` commutes with coordinate projectors.

The general Hilbert direct-sum and full T2 Fourier/query terminals are NOT
proved by this finite complex-sector module.
-/

namespace Nightfall.StructuralInformation.T2OperatorEnergy

open Finset

variable {D : Type*} [Fintype D] [DecidableEq D]

/-- One complex coordinate for each orthogonal oracle sector. -/
abbrev H (D : Type*) := D → ℂ

/-- The literal Hilbert squared norm of a complex coordinate vector. -/
noncomputable def energy (x : H D) : ℝ :=
  ∑ d : D, Complex.normSq (x d)

theorem energy_nonneg (x : H D) : 0 ≤ energy x := by
  unfold energy
  exact Finset.sum_nonneg (fun d _ => Complex.normSq_nonneg _)

/-- Every selected output coordinate is dominated by the Hilbert energy.
The positivity of *other* sectors is the key geometric input. -/
theorem coordinate_energy_le (x : H D) (a : D) :
    Complex.normSq (x a) ≤ energy x := by
  unfold energy
  exact Finset.single_le_sum
    (fun b _ => Complex.normSq_nonneg _) (Finset.mem_univ a)

/-- The central pinching estimate: arbitrary energy-contractive operators,
without a commutation or diagonality hypothesis, can only decrease
the selected-coordinate energy in each independent input row. -/
theorem selected_output_energy_le
    (P : H D → H D)
    (hP : ∀ x, energy (P x) ≤ energy x)
    (w : D → H D) :
    (∑ a : D, Complex.normSq ((P (w a)) a)) ≤
      ∑ a : D, energy (w a) := by
  apply Finset.sum_le_sum
  intro a _
  exact (coordinate_energy_le (P (w a)) a).trans (hP (w a))

/-- The actual primitive two-stage path input at fixed first stage `a`,
weighted by an arbitrary complex test vector beta. -/
noncomputable def crossedInput (T : D → D → ℂ)
    (beta : D → ℂ) (a : D) : H D :=
  fun b => beta b * T b a

/-- No path orthogonality assumption is needed: orthogonality across
second-stage labels is represented by disjoint complex coordinates.
This is the full crossed-slot squared-energy bound. -/
theorem crossed_energy_le
    (P : H D → H D)
    (hP : ∀ x, energy (P x) ≤ energy x)
    (T : D → D → ℂ) (beta : D → ℂ) :
    (∑ a : D, Complex.normSq ((P (crossedInput T beta a)) a)) ≤
      ∑ b : D, Complex.normSq (beta b) *
        (∑ a : D, Complex.normSq (T b a)) := by
  calc
    (∑ a : D, Complex.normSq ((P (crossedInput T beta a)) a))
        ≤ ∑ a : D, energy (crossedInput T beta a) :=
      selected_output_energy_le P hP (crossedInput T beta)
    _ = ∑ a : D, ∑ b : D,
          Complex.normSq (beta b) * Complex.normSq (T b a) := by
        simp only [energy, crossedInput, Complex.normSq_mul]
    _ = ∑ b : D, Complex.normSq (beta b) *
        (∑ a : D, Complex.normSq (T b a)) := by
        rw [Finset.sum_comm]
        simp only [← Finset.mul_sum]

/-- A single path is *literally* supported on its output sector b. -/
noncomputable def path (T : D → D → ℂ) (b a : D) : H D :=
  fun d => if d = b then T b a else 0

/-- The weighted sum of legal paths with fixed first label a has
coordinate b exactly beta_b*T_ba, with zero cross-sector interference. -/
theorem weighted_path_sum (T : D → D → ℂ)
    (beta : D → ℂ) (a : D) :
    (∑ b : D, beta b • path T b a) = crossedInput T beta a := by
  classical
  funext d
  simp [path, crossedInput, Finset.sum_apply, Pi.smul_apply,
        smul_eq_mul, mul_ite]

/-- Source-defined crossed equality synthesis coordinate, not an
independently assumed frame inequality. -/
noncomputable def crossedF
    (P : H D →ₗ[ℂ] H D) (T : D → D → ℂ)
    (b a : D) : ℂ :=
  (P (path T b a)) a

/-- The key noncommuting synthesis identity is forced by the linearity
of P; it is not introduced as an axiom or postulated oracle property. -/
theorem crossed_synthesis
    (P : H D →ₗ[ℂ] H D)
    (T : D → D → ℂ) (beta : D → ℂ) (a : D) :
    (∑ b : D, beta b * crossedF P T b a) =
      (P (crossedInput T beta a)) a := by
  classical
  calc
    (∑ b : D, beta b * crossedF P T b a) =
        (∑ b : D, (P (beta b • path T b a)) a) := by
      simp [crossedF, map_smul, Pi.smul_apply, smul_eq_mul]
    _ = (P (∑ b : D, beta b • path T b a)) a := by
      rw [map_sum]
      simp only [Finset.sum_apply]
    _ = (P (crossedInput T beta a)) a := by
      rw [weighted_path_sum]

/-- The complete crossed-slot estimate (paper equation (8)), for
arbitrary complex matrix effects satisfying the squared-Hilbert
contraction. The effect NEED NOT commute with the oracle sectors. -/
theorem noncommuting_crossed_slot_bound
    (P : H D →ₗ[ℂ] H D)
    (hP : ∀ x, energy (P x) ≤ energy x)
    (T : D → D → ℂ) (beta : D → ℂ) :
    (∑ a : D, Complex.normSq
      (∑ b : D, beta b * crossedF P T b a)) ≤
    ∑ b : D, Complex.normSq (beta b) *
      (∑ a : D, Complex.normSq (T b a)) := by
  calc
    _ = ∑ a : D, Complex.normSq
      ((P (crossedInput T beta a)) a) := by
        apply Finset.sum_congr rfl
        intro a _
        rw [crossed_synthesis]
    _ ≤ _ := crossed_energy_le P hP T beta

#print axioms Nightfall.StructuralInformation.T2OperatorEnergy.selected_output_energy_le
#print axioms Nightfall.StructuralInformation.T2OperatorEnergy.crossed_energy_le
#print axioms Nightfall.StructuralInformation.T2OperatorEnergy.weighted_path_sum
#print axioms Nightfall.StructuralInformation.T2OperatorEnergy.crossed_synthesis
#print axioms Nightfall.StructuralInformation.T2OperatorEnergy.noncommuting_crossed_slot_bound

end Nightfall.StructuralInformation.T2OperatorEnergy
