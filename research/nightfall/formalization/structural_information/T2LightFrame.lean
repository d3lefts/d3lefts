import Mathlib

/-!
# NIGHTFALL T2: exact infinite-dimensional light-frame Bessel inequality

This file proves a genuine analytic, not combinatorial, ingredient of
the rank-free two-query Hilbert-energy proof.

For ANY (possibly infinite-dimensional and nonseparable) complex
inner-product space, ANY orthonormal family indexed by arbitrary type,
and ANY finite light support, scaling each orthonormal vector by a
complex weight of squared modulus <= eta gives the sharp finite frame
bound <= eta*‖x‖². This includes zero complex weights.

This is an operator/inner-product inequality with no assumption on
source dimension. It is a reusable light-frame input for both stages
of the full two-query path construction. It does not by itself prove
the two-stage pinching, the grouped four-tuple frame estimates or T2.
-/

namespace Nightfall.StructuralInformation.T2LightFrame

open Finset

variable {I : Type*}
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- Weighting an orthonormal family by light complex coefficients gives
a rank-free frame estimate. This is the exact Bessel mechanism underlying
the first-stage frame input to the quantum T2 bound. -/
theorem orthonormal_light_frame_energy
    (v : I → E) (hv : Orthonormal ℂ v)
    (r : I → ℂ) (s : Finset I) (eta : ℝ)
    (heta : 0 ≤ eta)
    (hr : ∀ i ∈ s, ‖r i‖ ^ 2 ≤ eta)
    (x : E) :
    (∑ i ∈ s, ‖inner ℂ (r i • v i) x‖ ^ 2) ≤ eta * ‖x‖ ^ 2 := by
  have hterm : ∀ i ∈ s,
      ‖inner ℂ (r i • v i) x‖ ^ 2 ≤
          eta * ‖inner ℂ (v i) x‖ ^ 2 := by
    intro i hi
    have hi' := hr i hi
    rw [inner_smul_left]
    simp only [norm_mul, norm_conj, mul_pow]
    exact mul_le_mul_of_nonneg_right hi' (sq_nonneg _)
  calc
    (∑ i ∈ s, ‖inner ℂ (r i • v i) x‖ ^ 2) ≤
        ∑ i ∈ s, eta * ‖inner ℂ (v i) x‖ ^ 2 := by
      apply Finset.sum_le_sum
      intro i hi
      exact hterm i hi
    _ = eta * (∑ i ∈ s, ‖inner ℂ (v i) x‖ ^ 2) := by
      rw [Finset.mul_sum]
    _ ≤ eta * ‖x‖ ^ 2 := by
      exact mul_le_mul_of_nonneg_left (hv.sum_inner_products_le x) heta

#print axioms Nightfall.StructuralInformation.T2LightFrame.orthonormal_light_frame_energy

end Nightfall.StructuralInformation.T2LightFrame
