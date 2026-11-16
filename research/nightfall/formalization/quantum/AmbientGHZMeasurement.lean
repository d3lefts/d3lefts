import Mathlib

/-!
NIGHTFALL — ambient-dimensional GHZ measurement operators.

For any finite Hilbert basis and any two distinct basis rays, construct
both rank-one GHZ projectors and the full orthogonal-complement diagonal
projector. The third effect is required whenever the space has dimension
greater than two. No physical source or Bayes-optimality theorem is
assumed in this reusable measurement module.
-/

namespace Nightfall.Quantum.AmbientGHZ

open scoped BigOperators ComplexOrder
open Matrix
noncomputable section

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

def plusVector (a b : ι) (i : ι) : ℂ :=
  if i = a then 1 else if i = b then 1 else 0

def minusVector (a b : ι) (i : ι) : ℂ :=
  if i = a then 1 else if i = b then -1 else 0

def plusEffect (a b : ι) : Matrix ι ι ℂ :=
  ((1 / 2 : ℂ) •
    Matrix.vecMulVec (plusVector a b) (star (plusVector a b)))

def minusEffect (a b : ι) : Matrix ι ι ℂ :=
  ((1 / 2 : ℂ) •
    Matrix.vecMulVec (minusVector a b) (star (minusVector a b)))

def complementEffect (a b : ι) : Matrix ι ι ℂ :=
  Matrix.diagonal (fun i => if i = a ∨ i = b then 0 else (1 : ℂ))

theorem complex_half_nonneg : (0 : ℂ) ≤ 1 / 2 := by
  rw [RCLike.nonneg_iff]
  constructor <;> norm_num

theorem plusEffect_posSemidef (a b : ι) :
    (plusEffect a b).PosSemidef := by
  exact (Matrix.posSemidef_vecMulVec_self_star (plusVector a b)).smul
    complex_half_nonneg

theorem minusEffect_posSemidef (a b : ι) :
    (minusEffect a b).PosSemidef := by
  exact (Matrix.posSemidef_vecMulVec_self_star (minusVector a b)).smul
    complex_half_nonneg

theorem complementEffect_posSemidef (a b : ι) :
    (complementEffect a b).PosSemidef := by
  apply Matrix.PosSemidef.diagonal
  intro i
  by_cases h : i = a ∨ i = b
  · simp [h]
  · simp [h]

theorem complete_three_ambient_effects (a b : ι) (hab : a ≠ b) :
    plusEffect a b + minusEffect a b + complementEffect a b = 1 := by
  classical
  ext i j
  by_cases hia : i = a <;> by_cases hib : i = b <;>
    by_cases hja : j = a <;> by_cases hjb : j = b <;>
      simp_all [plusEffect, minusEffect, complementEffect, plusVector, minusVector,
        Matrix.vecMulVec, Matrix.smul_apply, Matrix.diagonal_apply, Matrix.one_apply] <;>
      norm_num <;> simp_all [eq_comm] <;> try ring

def ghzAmbient (a b : ι) (z : Fin 3) : Matrix ι ι ℂ :=
  if z = 0 then plusEffect a b
  else if z = 1 then minusEffect a b
  else complementEffect a b

theorem ghzAmbient_positive (a b : ι) (z : Fin 3) :
    (ghzAmbient a b z).PosSemidef := by
  fin_cases z
  · simpa [ghzAmbient] using plusEffect_posSemidef a b
  · simpa [ghzAmbient] using minusEffect_posSemidef a b
  · simpa [ghzAmbient] using complementEffect_posSemidef a b

theorem ghzAmbient_complete (a b : ι) (hab : a ≠ b) :
    (∑ z : Fin 3, ghzAmbient a b z) = 1 := by
  simpa [Fin.sum_univ_three, ghzAmbient] using
    complete_three_ambient_effects a b hab

#print axioms Nightfall.Quantum.AmbientGHZ.complex_half_nonneg
theorem ambient_ghz_corner_values (a b : ι) (hab : a ≠ b) :
    (ghzAmbient a b 0 a a).re = 1 / 2 ∧
    (ghzAmbient a b 1 a a).re = 1 / 2 ∧
    (ghzAmbient a b 0 b b).re = 1 / 2 ∧
    (ghzAmbient a b 1 b b).re = 1 / 2 ∧
    (ghzAmbient a b 0 a b).re = 1 / 2 ∧
    (ghzAmbient a b 1 a b).re = -(1 / 2) ∧
    (ghzAmbient a b 2 a a).re = 0 ∧
    (ghzAmbient a b 2 b b).re = 0 ∧
    (ghzAmbient a b 2 a b).re = 0 := by
  norm_num [ghzAmbient, plusEffect, minusEffect, complementEffect,
    plusVector, minusVector, Matrix.vecMulVec, Matrix.smul_apply,
    Matrix.diagonal_apply, hab, hab.symm]

theorem ambient_ghz_attains_two_ray_energy
    (a b : ι) (hab : a ≠ b)
    (u v t : ℝ) (hu : 0 < u) (hv : 0 < v) :
    (∑ z : Fin 3,
      (2 * t * (ghzAmbient a b z a b).re) ^ 2 /
        (u * (ghzAmbient a b z a a).re +
         v * (ghzAmbient a b z b b).re)) =
      4 * t ^ 2 / (u + v) := by
  have hden : u + v ≠ 0 := (add_pos hu hv).ne'
  obtain ⟨h00, h10, h01, h11, hco, hcm, h20, h21, h2c⟩ :=
    ambient_ghz_corner_values a b hab
  simp only [Fin.sum_univ_three]
  rw [h00, h10, h01, h11, hco, hcm, h20, h21, h2c]
  field_simp
  <;> ring

#print axioms Nightfall.Quantum.AmbientGHZ.ambient_ghz_corner_values
#print axioms Nightfall.Quantum.AmbientGHZ.ambient_ghz_attains_two_ray_energy
#print axioms Nightfall.Quantum.AmbientGHZ.plusEffect_posSemidef
#print axioms Nightfall.Quantum.AmbientGHZ.minusEffect_posSemidef
#print axioms Nightfall.Quantum.AmbientGHZ.complementEffect_posSemidef
#print axioms Nightfall.Quantum.AmbientGHZ.complete_three_ambient_effects
#print axioms Nightfall.Quantum.AmbientGHZ.ghzAmbient_positive
#print axioms Nightfall.Quantum.AmbientGHZ.ghzAmbient_complete

end
end Nightfall.Quantum.AmbientGHZ
