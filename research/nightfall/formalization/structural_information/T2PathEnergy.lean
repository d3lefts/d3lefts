import T2FirstStageLight
import T2SecondStageLight
import T2FrameEnergy
import T2EffectOrder

/-!
# NIGHTFALL T2 — physical four-slot coefficient-energy bound (eq. 3)

This formalization composes genuinely derived p-light/q-light Hilbert
path frames with the rank-free double-frame energy theorem. Quantum
paths are *literally* indexed by original ordered sector pairs (b,a)
and live in the arbitrary-dimensional physical direct sum PiLp(2).

For any noncommuting positive physical measurement effect 0 <= P <= I,
the square energy of all coefficients with a first-stage or second-stage
light sector is <= eta, under source mass <= 1.

The subsequent nonzero-frequency four-slot grouping, crossed six
pair-equality estimates, four zero-triple survivor grouped bounds,
and Walsh tail remain separate proof obligations.
-/

namespace Nightfall.StructuralInformation.T2PathEnergy

open Finset
open Nightfall.StructuralInformation.T2FirstStageLight
open Nightfall.StructuralInformation.T2SecondStageLight
open Nightfall.StructuralInformation.T2FrameEnergy
open Nightfall.StructuralInformation.T2EffectOrder

variable {D : Type*} [Fintype D] [DecidableEq D]
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- Physical path from first sector a to second sector b, treated as an
original ordered pair rather than a synthetic Fourier frequency. -/
noncomputable def fullPath (t : D → D → E) (ba : D × D) : H D E :=
  T2SecondStageLight.path t ba.1 ba.2

theorem fullPath_norm_sq
    (t : D → D → E) (ba : D × D) :
    ‖fullPath t ba‖ ^ 2 = ‖t ba.1 ba.2‖ ^ 2 := by
  rw [PiLp.norm_sq_eq_of_L2]
  simp [fullPath, T2SecondStageLight.path]

/-- Normalize the full physical path family using actual path masses.
For a unitary circuit this mass is one, but no path orthogonality
is assumed and no rank parameter is introduced. -/
theorem fullPath_mass_le
    (t : D → D → E)
    (hmass : (∑ b : D, ∑ a : D, ‖t b a‖ ^ 2) ≤ 1) :
    (∑ ba : D × D, ‖fullPath t ba‖ ^ 2) ≤ 1 := by
  simpa only [Fintype.sum_prod_type, fullPath_norm_sq] using hmass

/-- First-light subselection is exactly the original pair family
in which a (not b) belongs to the legal heavy-complement set. -/
theorem first_frame_pair
    (t : D → D → E) (L : Finset D) (eta : ℝ)
    (hframe : ∀ x : H D E,
       (∑ a ∈ L, ∑ b : D,
          ‖inner ℂ (T2SecondStageLight.path t b a) x‖ ^ 2) ≤ eta * ‖x‖ ^ 2)
    (x : H D E) :
    (∑ ba ∈ (Finset.univ : Finset D).product L,
        ‖inner ℂ (fullPath t ba) x‖ ^ 2) ≤ eta * ‖x‖ ^ 2 := by
  have heq :
      (∑ ba ∈ (Finset.univ : Finset D).product L,
          ‖inner ℂ (fullPath t ba) x‖ ^ 2) =
      (∑ a ∈ L, ∑ b : D,
          ‖inner ℂ (T2SecondStageLight.path t b a) x‖ ^ 2) := by
    simp only [Finset.sum_product, fullPath]
    rw [Finset.sum_comm]
  rw [heq]
  exact hframe x

/-- Second-light subselection uses the actual output sector b. -/
theorem second_frame_pair
    (t : D → D → E) (L : Finset D) (eta : ℝ)
    (hframe : ∀ x : H D E,
       (∑ b ∈ L, ∑ a : D,
          ‖inner ℂ (T2SecondStageLight.path t b a) x‖ ^ 2) ≤ eta * ‖x‖ ^ 2)
    (x : H D E) :
    (∑ ba ∈ L.product (Finset.univ : Finset D),
        ‖inner ℂ (fullPath t ba) x‖ ^ 2) ≤ eta * ‖x‖ ^ 2 := by
  have heq :
      (∑ ba ∈ L.product (Finset.univ : Finset D),
          ‖inner ℂ (fullPath t ba) x‖ ^ 2) =
      (∑ b ∈ L, ∑ a : D,
          ‖inner ℂ (T2SecondStageLight.path t b a) x‖ ^ 2) := by
    simp only [Finset.sum_product, fullPath]
  rw [heq]
  exact hframe x

/-- Noncommuting physical effect and source mass imply the exact
double energy estimate for any proven first-light path frame. -/
theorem first_light_four_slot_energy
    (t : D → D → E)
    (L : Finset D)
    (P : H D E →L[ℂ] H D E)
    (hP0 : 0 ≤ P) (hP1 : P ≤ 1)
    (eta : ℝ) (heta : 0 ≤ eta)
    (hmass : (∑ b : D, ∑ a : D, ‖t b a‖ ^ 2) ≤ 1)
    (hframe : ∀ x : H D E,
       (∑ a ∈ L, ∑ b : D,
          ‖inner ℂ (T2SecondStageLight.path t b a) x‖ ^ 2) ≤ eta * ‖x‖ ^ 2) :
    (∑ ba ∈ (Finset.univ : Finset D).product L,
       ∑ cd : D × D,
         ‖inner ℂ (fullPath t ba) (P (fullPath t cd))‖ ^ 2) ≤ eta := by
  exact restricted_double_frame_energy_of_opNorm
    ((Finset.univ : Finset D).product L)
    (fullPath t) P (effect_norm_le_one P hP0 hP1)
    eta heta (first_frame_pair t L eta hframe)
    (fullPath_mass_le t hmass)

/-- The corresponding actual second-light four-slot energy theorem. -/
theorem second_light_four_slot_energy
    (t : D → D → E)
    (L : Finset D)
    (P : H D E →L[ℂ] H D E)
    (hP0 : 0 ≤ P) (hP1 : P ≤ 1)
    (eta : ℝ) (heta : 0 ≤ eta)
    (hmass : (∑ b : D, ∑ a : D, ‖t b a‖ ^ 2) ≤ 1)
    (hlight : ∀ b ∈ L, (∑ a : D, ‖t b a‖ ^ 2) ≤ eta) :
    (∑ ba ∈ L.product (Finset.univ : Finset D),
       ∑ cd : D × D,
         ‖inner ℂ (fullPath t ba) (P (fullPath t cd))‖ ^ 2) ≤ eta := by
  exact restricted_double_frame_energy_of_opNorm
    (L.product (Finset.univ : Finset D))
    (fullPath t) P (effect_norm_le_one P hP0 hP1)
    eta heta (second_frame_pair t L eta
      (fun x => second_light_path_frame t L eta heta hlight x))
    (fullPath_mass_le t hmass)

#print axioms Nightfall.StructuralInformation.T2PathEnergy.fullPath_norm_sq
#print axioms Nightfall.StructuralInformation.T2PathEnergy.fullPath_mass_le
#print axioms Nightfall.StructuralInformation.T2PathEnergy.first_frame_pair
#print axioms Nightfall.StructuralInformation.T2PathEnergy.second_frame_pair
#print axioms Nightfall.StructuralInformation.T2PathEnergy.first_light_four_slot_energy
#print axioms Nightfall.StructuralInformation.T2PathEnergy.second_light_four_slot_energy

end Nightfall.StructuralInformation.T2PathEnergy
