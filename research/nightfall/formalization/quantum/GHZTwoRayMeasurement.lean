import Mathlib
import ComplexPOVMOptimal

/-!
NIGHTFALL: physically realizable, finite-dimensional GHZ two-ray POVM
and exact operational squared-error Bayes-optimal equality witness.

The state restriction here is the actual two-ray subspace (Fin 2).
For the full d-qubit ensemble one additionally needs the direct-sum
orthogonal complement projector and the source-average operator
reduction. Those remain independent transitive proof obligations.
-/

namespace Nightfall.Quantum.GHZTwoRay

open scoped BigOperators ComplexOrder
open Matrix
open Nightfall.Quantum.ComplexPOVM

def ketPlus (_ : Fin 2) : ℂ := 1

def ketMinus (i : Fin 2) : ℂ := if i = 0 then 1 else -1

noncomputable def projectPlus : Matrix (Fin 2) (Fin 2) ℂ :=
  (1 / 2 : ℂ) • Matrix.vecMulVec ketPlus (star ketPlus)

noncomputable def projectMinus : Matrix (Fin 2) (Fin 2) ℂ :=
  (1 / 2 : ℂ) • Matrix.vecMulVec ketMinus (star ketMinus)

theorem complex_half_nonneg : (0 : ℂ) ≤ 1 / 2 := by
  rw [RCLike.nonneg_iff]
  constructor <;> norm_num

theorem projectPlus_posSemidef : projectPlus.PosSemidef := by
  exact (Matrix.posSemidef_vecMulVec_self_star ketPlus).smul
    complex_half_nonneg

theorem projectMinus_posSemidef : projectMinus.PosSemidef := by
  exact (Matrix.posSemidef_vecMulVec_self_star ketMinus).smul
    complex_half_nonneg

theorem two_projectors_complete : projectPlus + projectMinus = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    norm_num [projectPlus, projectMinus, ketPlus, ketMinus,
      Matrix.vecMulVec, Matrix.one_apply, Matrix.smul_apply]

noncomputable def ghzMeasurement (z : Fin 2) : Matrix (Fin 2) (Fin 2) ℂ :=
  if z = 0 then projectPlus else projectMinus

theorem ghzMeasurement_positive (z : Fin 2) :
    (ghzMeasurement z).PosSemidef := by
  fin_cases z
  · simpa [ghzMeasurement] using projectPlus_posSemidef
  · simpa [ghzMeasurement] using projectMinus_posSemidef

theorem ghzMeasurement_complete :
    (∑ z : Fin 2, ghzMeasurement z) = 1 := by
  simpa [ghzMeasurement, Fin.sum_univ_two] using two_projectors_complete

theorem ghz_measurement_corner_values :
    (ghzMeasurement 0 0 0).re = 1 / 2 ∧
    (ghzMeasurement 1 0 0).re = 1 / 2 ∧
    (ghzMeasurement 0 1 1).re = 1 / 2 ∧
    (ghzMeasurement 1 1 1).re = 1 / 2 ∧
    (ghzMeasurement 0 0 1).re = 1 / 2 ∧
    (ghzMeasurement 1 0 1).re = -(1 / 2) := by
  norm_num [ghzMeasurement, projectPlus, projectMinus,
    ketPlus, ketMinus, Matrix.vecMulVec, Matrix.smul_apply]

theorem ghz_measurement_attains_bayes_optimum (u v t : ℝ)
    (hu : 0 < u) (hv : 0 < v) :
    (∑ z : Fin 2,
      (2 * t * (ghzMeasurement z 0 1).re) ^ 2 /
        (u * (ghzMeasurement z 0 0).re +
         v * (ghzMeasurement z 1 1).re)) =
    4 * t ^ 2 / (u + v) := by
  have hden : u + v ≠ 0 := (add_pos hu hv).ne'
  have hcorner := ghz_measurement_corner_values
  simp only [Fin.sum_univ_two]
  rcases hcorner with ⟨h00, h10, h01, h11, hco, hcm⟩
  rw [h00, h10, h01, h11, hco, hcm]
  field_simp
  <;> ring

theorem ghz_measurement_optimal_among_all_physical_povms (u v t : ℝ)
    (hu : 0 < u) (hv : 0 < v) :
    ∀ {Out : Type*} [Fintype Out]
      (E : Out → Matrix (Fin 2) (Fin 2) ℂ)
      (hpositive : ∀ z, (E z).PosSemidef)
      (hcomplete : (∑ z, E z) = 1)
      (w : Out → ℝ)
      (hBorn : ∀ z,
        u * (E z 0 0).re + v * (E z 1 1).re ≤ w z),
      (∑ z, (2 * t * (E z 0 1).re) ^ 2 / w z) ≤
        (∑ z : Fin 2,
         (2 * t * (ghzMeasurement z 0 1).re) ^ 2 /
          (u * (ghzMeasurement z 0 0).re +
           v * (ghzMeasurement z 1 1).re)) := by
  intro Out _ E hpositive hcomplete w hBorn
  rw [ghz_measurement_attains_bayes_optimum u v t hu hv]
  exact complex_povm_energy_optimal E hpositive hcomplete
    0 1 w u v t hu hv hBorn

#print axioms Nightfall.Quantum.GHZTwoRay.projectPlus_posSemidef
#print axioms Nightfall.Quantum.GHZTwoRay.projectMinus_posSemidef
#print axioms Nightfall.Quantum.GHZTwoRay.two_projectors_complete
#print axioms Nightfall.Quantum.GHZTwoRay.ghzMeasurement_complete
#print axioms Nightfall.Quantum.GHZTwoRay.ghz_measurement_attains_bayes_optimum
#print axioms Nightfall.Quantum.GHZTwoRay.ghz_measurement_optimal_among_all_physical_povms

end Nightfall.Quantum.GHZTwoRay
