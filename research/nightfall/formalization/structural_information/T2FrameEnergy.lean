import Mathlib

/-!
# NIGHTFALL T2: rank-free double-frame energy without trace-class bookkeeping

The paper's equation (3) is a double sum of matrix elements of the
physical terminal effect. Once a restricted path family has a genuine
Hilbert light-frame inequality, we can bound the *full* two-path
coefficient energy simply by swapping finite sums, applying the
restricted frame inequality at P applied to every unrestricted path,
and then using the actual contraction of P.

This is a source-equivalent analytic lemma for arbitrary complex
Hilbert spaces, including infinite-dimensional, high-rank effects,
with no orthogonality assumption among arbitrary path vectors.
Importantly, no statement of the desired double energy bound is
introduced as an axiom or buried in a definition.

The separate first/second-stage light-frame construction and actual
four-slot Fourier partition are still required for the full T2 theorem.
-/

namespace Nightfall.StructuralInformation.T2FrameEnergy

open Finset

variable {I : Type*} [Fintype I] [DecidableEq I]
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- A restricted Hilbert frame with operator bound eta controls all
its matrix elements against an unrestricted unit-mass path family
through any norm-contractive P. Rank and dimension do not occur. -/
theorem restricted_double_frame_energy
    (L : Finset I) (t : I → E) (P : E → E)
    (hP : ∀ x, ‖P x‖ ≤ ‖x‖)
    (eta : ℝ) (heta : 0 ≤ eta)
    (hframe : ∀ x : E,
       (∑ i ∈ L, ‖inner ℂ (t i) x‖ ^ 2) ≤ eta * ‖x‖ ^ 2)
    (hmass : (∑ j : I, ‖t j‖ ^ 2) ≤ 1) :
    (∑ i ∈ L, ∑ j : I,
       ‖inner ℂ (t i) (P (t j))‖ ^ 2) ≤ eta := by
  have hpoint (j : I) :
      ‖P (t j)‖ ^ 2 ≤ ‖t j‖ ^ 2 :=
    (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mpr (hP (t j))
  have hweighted :
      (∑ j : I, eta * ‖P (t j)‖ ^ 2) ≤
      ∑ j : I, eta * ‖t j‖ ^ 2 := by
    apply Finset.sum_le_sum
    intro j _
    exact mul_le_mul_of_nonneg_left (hpoint j) heta
  calc
    (∑ i ∈ L, ∑ j : I,
        ‖inner ℂ (t i) (P (t j))‖ ^ 2) =
        ∑ j : I, ∑ i ∈ L,
          ‖inner ℂ (t i) (P (t j))‖ ^ 2 := by
      rw [Finset.sum_comm]
    _ ≤ ∑ j : I, eta * ‖P (t j)‖ ^ 2 := by
      apply Finset.sum_le_sum
      intro j _
      exact hframe (P (t j))
    _ ≤ ∑ j : I, eta * ‖t j‖ ^ 2 := hweighted
    _ = eta * (∑ j : I, ‖t j‖ ^ 2) := by rw [Finset.mul_sum]
    _ ≤ eta * 1 := mul_le_mul_of_nonneg_left hmass heta
    _ = eta := by ring

/-- A bounded physical positive effect has precisely the norm
contraction required above. This restates its operator input explicitly
rather than silently restricting P to finite-rank projections. -/
theorem restricted_double_frame_energy_of_opNorm
    (L : Finset I) (t : I → E) (P : E →L[ℂ] E)
    (hP : ‖P‖ ≤ 1)
    (eta : ℝ) (heta : 0 ≤ eta)
    (hframe : ∀ x : E,
       (∑ i ∈ L, ‖inner ℂ (t i) x‖ ^ 2) ≤ eta * ‖x‖ ^ 2)
    (hmass : (∑ j : I, ‖t j‖ ^ 2) ≤ 1) :
    (∑ i ∈ L, ∑ j : I,
       ‖inner ℂ (t i) (P (t j))‖ ^ 2) ≤ eta := by
  apply restricted_double_frame_energy L t P (fun x => ?_) eta heta hframe hmass
  calc
    ‖P x‖ ≤ ‖P‖ * ‖x‖ := P.le_opNorm x
    _ ≤ 1 * ‖x‖ := mul_le_mul_of_nonneg_right hP (norm_nonneg x)
    _ = ‖x‖ := one_mul _

#print axioms Nightfall.StructuralInformation.T2FrameEnergy.restricted_double_frame_energy
#print axioms Nightfall.StructuralInformation.T2FrameEnergy.restricted_double_frame_energy_of_opNorm

end Nightfall.StructuralInformation.T2FrameEnergy
