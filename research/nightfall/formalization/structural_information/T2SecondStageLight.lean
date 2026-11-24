import Mathlib

/-!
# NIGHTFALL T2 — exact second-stage light frame on arbitrary Hilbert fibers

This is the physical (not postulated) q_b-light half of manuscript (2).
For finite oracle sectors D, arbitrary complex inner-product fibers E
(including infinite dimensions), and actual path amplitudes t_{b,a}
in output sector b, define q_b = sum_a ‖t_{b,a}‖².

For any set L of second-light sectors with q_b <= eta, the restricted
physical frame has squared matrix-element energy <= eta*‖x‖².
This requires no orthogonality of different a-paths in the same
output sector, no effect commutativity, and no finite-rank assumption.

The proof is direct inner-product Cauchy–Schwarz followed by the
literal PiLp(2) orthogonal direct-sum norm identity.
-/

namespace Nightfall.StructuralInformation.T2SecondStageLight

open Finset

variable {D : Type*} [Fintype D] [DecidableEq D]
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

abbrev H (D E : Type*) := PiLp 2 (fun _ : D => E)

noncomputable def path (t : D → D → E) (b a : D) : H D E :=
  WithLp.toLp 2 (fun d : D => if d = b then t b a else 0)

/-- The path vector is literally supported on one physical output sector. -/
theorem path_inner (t : D → D → E) (b a : D) (x : H D E) :
    inner ℂ (path t b a) x = inner ℂ (t b a) (x b) := by
  rw [PiLp.inner_apply]
  change (∑ i : D, inner ℂ (if i = b then t b a else 0) (x i)) =
    inner ℂ (t b a) (x b)
  calc
    _ = ∑ i : D, (if i = b then inner ℂ (t b a) (x i) else 0) := by
      apply Finset.sum_congr rfl
      intro i _
      split_ifs <;> simp
    _ = inner ℂ (t b a) (x b) := by simp

/-- Squared Hilbert inner products are dominated by product squared norms,
with no collinearity or path-orthogonality hypothesis. -/
theorem norm_inner_sq_le (u v : E) :
    ‖inner ℂ u v‖ ^ 2 ≤ ‖u‖ ^ 2 * ‖v‖ ^ 2 := by
  have h : ‖inner ℂ u v‖ ≤ ‖u‖ * ‖v‖ :=
    norm_inner_le_norm (𝕜 := ℂ) u v
  have hs : ‖inner ℂ u v‖ ^ 2 ≤ (‖u‖ * ‖v‖) ^ 2 :=
    (sq_le_sq₀ (norm_nonneg _) (mul_nonneg (norm_nonneg _) (norm_nonneg _))).mpr h
  simpa only [mul_pow] using hs

/-- The actual q_b path-mass contractive-frame estimate, at a fixed output
sector b, with no implicit assumption that a-paths are orthogonal. -/
theorem block_frame_energy
    (t : D → D → E) (b : D) (x : E) :
    (∑ a : D, ‖inner ℂ (t b a) x‖ ^ 2) ≤
      (∑ a : D, ‖t b a‖ ^ 2) * ‖x‖ ^ 2 := by
  calc
    _ ≤ ∑ a : D, ‖t b a‖ ^ 2 * ‖x‖ ^ 2 := by
      apply Finset.sum_le_sum
      intro a _
      exact norm_inner_sq_le (t b a) x
    _ = (∑ a : D, ‖t b a‖ ^ 2) * ‖x‖ ^ 2 := by
      rw [Finset.sum_mul]

/-- Full q-light physical path-frame inequality in the genuine direct sum.
The restriction L is on *actual* second-stage labels, not synthetic XORs. -/
theorem second_light_path_frame
    (t : D → D → E)
    (L : Finset D) (eta : ℝ) (heta : 0 ≤ eta)
    (hlight : ∀ b ∈ L, (∑ a : D, ‖t b a‖ ^ 2) ≤ eta)
    (x : H D E) :
    (∑ b ∈ L, ∑ a : D,
        ‖inner ℂ (path t b a) x‖ ^ 2) ≤ eta * ‖x‖ ^ 2 := by
  have hblocks : (∑ b ∈ L, ∑ a : D,
       ‖inner ℂ (path t b a) x‖ ^ 2) ≤
      ∑ b ∈ L, eta * ‖x b‖ ^ 2 := by
    apply Finset.sum_le_sum
    intro b hb
    calc
      (∑ a : D, ‖inner ℂ (path t b a) x‖ ^ 2) =
          ∑ a : D, ‖inner ℂ (t b a) (x b)‖ ^ 2 := by
            apply Finset.sum_congr rfl
            intro a _
            rw [path_inner]
      _ ≤ (∑ a : D, ‖t b a‖ ^ 2) * ‖x b‖ ^ 2 :=
        block_frame_energy t b (x b)
      _ ≤ eta * ‖x b‖ ^ 2 :=
        mul_le_mul_of_nonneg_right (hlight b hb) (sq_nonneg _)
  calc
    _ ≤ ∑ b ∈ L, eta * ‖x b‖ ^ 2 := hblocks
    _ = eta * (∑ b ∈ L, ‖x b‖ ^ 2) := by rw [Finset.mul_sum]
    _ ≤ eta * (∑ b : D, ‖x b‖ ^ 2) := by
      apply mul_le_mul_of_nonneg_left _ heta
      exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ L)
        (fun b hb hnot => sq_nonneg (‖x b‖))
    _ = eta * ‖x‖ ^ 2 := by
      rw [← PiLp.norm_sq_eq_of_L2]

#print axioms Nightfall.StructuralInformation.T2SecondStageLight.path_inner
#print axioms Nightfall.StructuralInformation.T2SecondStageLight.norm_inner_sq_le
#print axioms Nightfall.StructuralInformation.T2SecondStageLight.block_frame_energy
#print axioms Nightfall.StructuralInformation.T2SecondStageLight.second_light_path_frame

end Nightfall.StructuralInformation.T2SecondStageLight
