import Mathlib

/-!
NIGHTFALL: genuine complex-PSD two-ray compression for arbitrary finite
Hilbert spaces. The key consequence derives a real coherence Gram bound
from a physical positive semidefinite effect matrix, rather than assuming
it as a separate field. This is a transitive ingredient of the universal
POVM Bayes-gain bound.
-/
namespace Nightfall.Quantum.PhysicalPOVM

open scoped ComplexOrder
open Matrix

theorem complex_psd_corner_gram
    (M : Matrix (Fin 2) (Fin 2) ℂ)
    (hM : M.PosSemidef) :
    (M 0 1).re ^ 2 ≤ (M 0 0).re * (M 1 1).re := by
  have hdiag0 : (M 0 0).im = 0 := by
    exact (Complex.im_eq_zero_iff_isSelfAdjoint _).mpr (hM.1.apply 0 0)
  have hdiag1 : (M 1 1).im = 0 := by
    exact (Complex.im_eq_zero_iff_isSelfAdjoint _).mpr (hM.1.apply 1 1)
  have hji : M 1 0 = star (M 0 1) :=
    (hM.1.apply 1 0).symm
  have hdet : 0 ≤ (M.det).re :=
    (RCLike.nonneg_iff.mp hM.det_nonneg).1
  rw [Matrix.det_fin_two, hji] at hdet
  simp only [Complex.sub_re, Complex.mul_re] at hdet
  simp [Complex.star_def, hdiag0, hdiag1] at hdet
  nlinarith [sq_nonneg (M 0 1).im]

theorem complex_psd_compressed_gram
    {ι : Type*} [Fintype ι]
    (E : Matrix ι ι ℂ) (hE : E.PosSemidef) (a b : ι) :
    (E a b).re ^ 2 ≤ (E a a).re * (E b b).re := by
  let embed : Fin 2 → ι := fun k => if k = 0 then a else b
  have hM : (E.submatrix embed embed).PosSemidef := hE.submatrix embed
  have h := complex_psd_corner_gram (E.submatrix embed embed) hM
  simpa [embed, Matrix.submatrix] using h

#print axioms Nightfall.Quantum.PhysicalPOVM.complex_psd_corner_gram
#print axioms Nightfall.Quantum.PhysicalPOVM.complex_psd_compressed_gram

end Nightfall.Quantum.PhysicalPOVM
