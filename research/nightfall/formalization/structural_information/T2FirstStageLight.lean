import T2LightFrame
import T2SecondStageLight

/-!
# NIGHTFALL T2: genuine first-stage p-light frame after arbitrary unitary

Represent the complete oracle workspace as a finite orthogonal L2 sum
of arbitrary complex Hilbert fibers E; no finite dimension condition.
An orthonormal family u_a of input vectors, scaled by actual amplitudes
r_a with |r_a|²<=eta, is subjected to an arbitrary fixed linear unitary
U. Each two-query path is the b-th output coordinate of r_a U u_a.

Prove from Mathlib's Bessel inequality and exact PiLp geometry:
  sum_{a in L,b} |<t_{ba}, x>|² <= eta ||x||².
The result is a genuine source-to-light-frame bridge, not a postulated
frame property, and does not assume that different output-sector paths
are orthogonal when their output labels coincide.

Only the actual normalized input-sector representation of arbitrary
psi in an orthogonal projector decomposition remains to be connected.
-/

namespace Nightfall.StructuralInformation.T2FirstStageLight

open Finset
open Nightfall.StructuralInformation.T2SecondStageLight
open Nightfall.StructuralInformation.T2LightFrame

variable {D : Type*} [Fintype D] [DecidableEq D]
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- One physical output-sector block of an arbitrary Hilbert vector. -/
noncomputable def block (b : D) (x : H D E) : H D E :=
  WithLp.toLp 2 (fun d : D => if d = b then x b else 0)

theorem block_norm_sq (b : D) (x : H D E) :
    ‖block b x‖ ^ 2 = ‖x b‖ ^ 2 := by
  rw [PiLp.norm_sq_eq_of_L2]
  simp [block]

/-- Adjointness of the sector selector expressed directly as a
finite inner-product sum, without assuming selectors commute with P. -/
theorem inner_block_right (u x : H D E) (b : D) :
    inner ℂ u (block b x) = inner ℂ (u b) (x b) := by
  rw [PiLp.inner_apply]
  simp [block]

/-- The p-light first-stage frame on actual two-query Hilbert paths.
The only hypotheses are orthonormal input family u and the literal
light coefficients r. No restriction on the fiber dimension. -/
theorem first_light_path_frame
    (u : D → H D E) (hu : Orthonormal ℂ u)
    (r : D → ℂ) (L : Finset D)
    (eta : ℝ) (heta : 0 ≤ eta)
    (hr : ∀ a ∈ L, ‖r a‖ ^ 2 ≤ eta)
    (x : H D E) :
    (∑ a ∈ L, ∑ b : D,
        ‖inner ℂ (path (fun b a => (r a • u a) b) b a) x‖ ^ 2)
      ≤ eta * ‖x‖ ^ 2 := by
  have hsum : (∑ a ∈ L, ∑ b : D,
      ‖inner ℂ (path (fun b a => (r a • u a) b) b a) x‖ ^ 2) =
      ∑ b : D, ∑ a ∈ L, ‖inner ℂ (r a • u a) (block b x)‖ ^ 2 := by
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro b _
    apply Finset.sum_congr rfl
    intro a _
    rw [path_inner, inner_block_right]
  rw [hsum]
  calc
    _ ≤ ∑ b : D, eta * ‖block b x‖ ^ 2 := by
      apply Finset.sum_le_sum
      intro b _
      exact orthonormal_light_frame_energy u hu r L eta heta hr (block b x)
    _ = eta * (∑ b : D, ‖x b‖ ^ 2) := by
      simp_rw [block_norm_sq]
      rw [Finset.mul_sum]
    _ = eta * ‖x‖ ^ 2 := by rw [← PiLp.norm_sq_eq_of_L2]

/-- An arbitrary fixed unitary U preserves the orthonormal initial
family; hence the complete first-stage light-frame inequality follows
for the *actual* path `(U (r_a • u_a))_b`. The unitary is not chosen
to commute with the terminal measurement effect. -/
theorem first_light_after_unitary
    (u : D → H D E) (hu : Orthonormal ℂ u)
    (U : H D E ≃ₗᵢ[ℂ] H D E)
    (r : D → ℂ) (L : Finset D)
    (eta : ℝ) (heta : 0 ≤ eta)
    (hr : ∀ a ∈ L, ‖r a‖ ^ 2 ≤ eta)
    (x : H D E) :
    (∑ a ∈ L, ∑ b : D,
        ‖inner ℂ
          (path (fun b a => (U (r a • u a)) b) b a) x‖ ^ 2)
      ≤ eta * ‖x‖ ^ 2 := by
  have hUv : Orthonormal ℂ (fun a => U (u a)) := by
    simpa only [Function.comp_def] using hu.comp_linearIsometryEquiv U
  have hpath (a b : D) :
      (U (r a • u a)) b = (r a • U (u a)) b := by
    rw [map_smul]
  simpa only [hpath] using
    first_light_path_frame (fun a => U (u a)) hUv r L eta heta hr x

#print axioms Nightfall.StructuralInformation.T2FirstStageLight.block_norm_sq
#print axioms Nightfall.StructuralInformation.T2FirstStageLight.inner_block_right
#print axioms Nightfall.StructuralInformation.T2FirstStageLight.first_light_path_frame
#print axioms Nightfall.StructuralInformation.T2FirstStageLight.first_light_after_unitary

end Nightfall.StructuralInformation.T2FirstStageLight
