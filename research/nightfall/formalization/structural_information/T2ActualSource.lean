import T2FirstStageLight
import T2PathEnergy

/-!
# NIGHTFALL T2 — unrestricted initial state, genuine p-light/q-light four-slot energy

Previous staged proofs of the first-light frame required an orthonormal
family u_a supplied as an input. Here that extra hypothesis is removed:
given any genuine initial quantum vector psi in a complex Hilbert
direct sum and any intervening linear unitary U, the first-query
sector a is the literal coordinate projection psi_a.

The source may have zero-mass sectors. No normalization of individual
psi_a is needed, so there is no division-by-zero or nonexistent
unit-vector problem. The p-light estimate is derived directly by
sectorwise complex Cauchy–Schwarz, applied after the inverse unitary.
The total path mass equals ‖psi‖² and is <= 1 for a normalized source.

As a result, for any arbitrary positive effect 0 <= P <= I,
both p-light and q-light four-slot complex coefficient energies
are <= eta. This formalizes the physical core of paper equations
(1)--(3), with no finite-dimensionality or effect rank hypothesis
*within the common-fiber direct-sum representation*.

The bridge from an arbitrary heterogeneous projector family on a
physical Hilbert H to this canonical direct sum is still separate,
as are grouped B/C Fourier estimates and the complete T2-31 terminal.
-/

namespace Nightfall.StructuralInformation.T2ActualSource

open Finset
open Nightfall.StructuralInformation.T2FirstStageLight
open Nightfall.StructuralInformation.T2SecondStageLight
open Nightfall.StructuralInformation.T2PathEnergy

variable {D : Type*} [Fintype D] [DecidableEq D]
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- Input sector restriction of an arbitrary state, including zero
components: the actual source need not have full support. -/
noncomputable def psiSector (psi : H D E) (a : D) : H D E :=
  T2FirstStageLight.block a psi

/-- Actual source path after an arbitrary fixed unitary and second
orthogonal sector selection. -/
noncomputable def sourcePath
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E)
    (b a : D) : E :=
  (U (psiSector psi a)) b

theorem psi_sector_inner (psi x : H D E) (a : D) :
    inner ℂ (psiSector psi a) x = inner ℂ (psi a) (x a) := by
  rw [PiLp.inner_apply]
  change (∑ d : D, inner ℂ (if d = a then psi a else 0) (x d)) =
    inner ℂ (psi a) (x a)
  calc
    _ = ∑ d : D, (if d = a then inner ℂ (psi a) (x d) else 0) := by
      apply Finset.sum_congr rfl
      intro d _
      split_ifs <;> simp
    _ = inner ℂ (psi a) (x a) := by simp

/-- **Physical p-light frame without normalized sector vectors.**
No unit vector is chosen in a zero-mass input sector. -/
theorem source_input_light_frame
    (psi : H D E)
    (L : Finset D) (eta : ℝ) (heta : 0 ≤ eta)
    (hlight : ∀ a ∈ L, ‖psi a‖ ^ 2 ≤ eta)
    (x : H D E) :
    (∑ a ∈ L, ‖inner ℂ (psiSector psi a) x‖ ^ 2) ≤
      eta * ‖x‖ ^ 2 := by
  calc
    (∑ a ∈ L, ‖inner ℂ (psiSector psi a) x‖ ^ 2) ≤
        ∑ a ∈ L, ‖psi a‖ ^ 2 * ‖x a‖ ^ 2 := by
      apply Finset.sum_le_sum
      intro a _
      rw [psi_sector_inner]
      exact T2SecondStageLight.norm_inner_sq_le (psi a) (x a)
    _ ≤ ∑ a ∈ L, eta * ‖x a‖ ^ 2 := by
      apply Finset.sum_le_sum
      intro a ha
      exact mul_le_mul_of_nonneg_right (hlight a ha) (sq_nonneg _)
    _ = eta * (∑ a ∈ L, ‖x a‖ ^ 2) := by rw [Finset.mul_sum]
    _ ≤ eta * (∑ a : D, ‖x a‖ ^ 2) := by
      apply mul_le_mul_of_nonneg_left _ heta
      exact Finset.sum_le_sum_of_subset_of_nonneg
        (Finset.subset_univ L) (fun a ha hnot => sq_nonneg _)
    _ = eta * ‖x‖ ^ 2 := by rw [← PiLp.norm_sq_eq_of_L2]

/-- The exact unitary adjoint matrix-element identity, without
any commutation hypothesis between U and sector projections. -/
theorem source_path_unitary_inner
    (psi x : H D E)
    (U : H D E ≃ₗᵢ[ℂ] H D E) (b a : D) :
    inner ℂ (T2SecondStageLight.path (sourcePath psi U) b a) x =
      inner ℂ (psiSector psi a)
        (U.symm (T2FirstStageLight.block b x)) := by
  calc
    _ = inner ℂ (U (psiSector psi a)) (T2FirstStageLight.block b x) := by
      rw [T2SecondStageLight.path_inner, T2FirstStageLight.inner_block_right]
      rfl
    _ = inner ℂ (psiSector psi a)
        (U.symm (T2FirstStageLight.block b x)) := by
      have h := U.inner_map_map (psiSector psi a)
        (U.symm (T2FirstStageLight.block b x))
      simpa only [U.apply_symm_apply] using h

/-- **Physical first-stage light frame after the actual unitary.**
All original source vectors allowed, including zero components. -/
theorem first_light_after_unitary_actual_source
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E)
    (L : Finset D) (eta : ℝ) (heta : 0 ≤ eta)
    (hlight : ∀ a ∈ L, ‖psi a‖ ^ 2 ≤ eta)
    (x : H D E) :
    (∑ a ∈ L, ∑ b : D,
       ‖inner ℂ
          (T2SecondStageLight.path (sourcePath psi U) b a) x‖ ^ 2) ≤
      eta * ‖x‖ ^ 2 := by
  have hsum :
      (∑ a ∈ L, ∑ b : D,
        ‖inner ℂ
          (T2SecondStageLight.path (sourcePath psi U) b a) x‖ ^ 2) =
      (∑ b : D, ∑ a ∈ L,
        ‖inner ℂ (psiSector psi a)
          (U.symm (T2FirstStageLight.block b x))‖ ^ 2) := by
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro b _
    apply Finset.sum_congr rfl
    intro a _
    rw [source_path_unitary_inner]
  rw [hsum]
  calc
    _ ≤ ∑ b : D, eta *
        ‖U.symm (T2FirstStageLight.block b x)‖ ^ 2 := by
      apply Finset.sum_le_sum
      intro b _
      exact source_input_light_frame psi L eta heta hlight
        (U.symm (T2FirstStageLight.block b x))
    _ = eta * (∑ b : D, ‖T2FirstStageLight.block b x‖ ^ 2) := by
      simp_rw [U.symm.norm_map]
      rw [Finset.mul_sum]
    _ = eta * (∑ b : D, ‖x b‖ ^ 2) := by
      simp_rw [T2FirstStageLight.block_norm_sq]
    _ = eta * ‖x‖ ^ 2 := by rw [← PiLp.norm_sq_eq_of_L2]

/-- Actual unitary source exactly preserves the complete incoherent
path mass, with no sector-by-sector normalization or rank bound. -/
theorem source_path_mass_eq
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E) :
    (∑ b : D, ∑ a : D, ‖sourcePath psi U b a‖ ^ 2) =
      ‖psi‖ ^ 2 := by
  rw [Finset.sum_comm]
  calc
    (∑ a : D, ∑ b : D, ‖sourcePath psi U b a‖ ^ 2) =
        ∑ a : D, ‖U (psiSector psi a)‖ ^ 2 := by
      apply Finset.sum_congr rfl
      intro a _
      exact (PiLp.norm_sq_eq_of_L2 _ (U (psiSector psi a))).symm
    _ = ∑ a : D, ‖psiSector psi a‖ ^ 2 := by
      simp_rw [U.norm_map]
    _ = ∑ a : D, ‖psi a‖ ^ 2 := by
      simp_rw [psiSector, T2FirstStageLight.block_norm_sq]
    _ = ‖psi‖ ^ 2 := (PiLp.norm_sq_eq_of_L2 _ psi).symm

/-- Paper equation (3): actual unrestricted initial complex state,
arbitrary fixed unitary, original first-stage light labels, actual
positive nonprojective terminal effect; no supplied light-frame axiom. -/
theorem actual_first_light_four_slot_energy
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E)
    (hpsi : ‖psi‖ ^ 2 ≤ 1)
    (L : Finset D) (eta : ℝ) (heta : 0 ≤ eta)
    (hlight : ∀ a ∈ L, ‖psi a‖ ^ 2 ≤ eta)
    (P : H D E →L[ℂ] H D E)
    (hP0 : 0 ≤ P) (hP1 : P ≤ 1) :
    (∑ ba ∈ (Finset.univ : Finset D).product L,
       ∑ cd : D × D,
       ‖inner ℂ
         (fullPath (sourcePath psi U) ba)
         (P (fullPath (sourcePath psi U) cd))‖ ^ 2) ≤ eta := by
  apply first_light_four_slot_energy (sourcePath psi U)
    L P hP0 hP1 eta heta
  · simpa only [source_path_mass_eq] using hpsi
  · intro x
    exact first_light_after_unitary_actual_source psi U L eta heta hlight x

/-- The same unrestricted initial state and arbitrary physical positive
effect, with the actual q_b masses controlling second-light sectors. -/
theorem actual_second_light_four_slot_energy
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E)
    (hpsi : ‖psi‖ ^ 2 ≤ 1)
    (L : Finset D) (eta : ℝ) (heta : 0 ≤ eta)
    (hlight : ∀ b ∈ L,
      (∑ a : D, ‖sourcePath psi U b a‖ ^ 2) ≤ eta)
    (P : H D E →L[ℂ] H D E)
    (hP0 : 0 ≤ P) (hP1 : P ≤ 1) :
    (∑ ba ∈ L.product (Finset.univ : Finset D),
       ∑ cd : D × D,
       ‖inner ℂ
         (fullPath (sourcePath psi U) ba)
         (P (fullPath (sourcePath psi U) cd))‖ ^ 2) ≤ eta := by
  apply second_light_four_slot_energy (sourcePath psi U)
    L P hP0 hP1 eta heta
  · simpa only [source_path_mass_eq] using hpsi
  · exact hlight

#print axioms Nightfall.StructuralInformation.T2ActualSource.psi_sector_inner
#print axioms Nightfall.StructuralInformation.T2ActualSource.source_input_light_frame
#print axioms Nightfall.StructuralInformation.T2ActualSource.source_path_unitary_inner
#print axioms Nightfall.StructuralInformation.T2ActualSource.first_light_after_unitary_actual_source
#print axioms Nightfall.StructuralInformation.T2ActualSource.source_path_mass_eq
#print axioms Nightfall.StructuralInformation.T2ActualSource.actual_first_light_four_slot_energy
#print axioms Nightfall.StructuralInformation.T2ActualSource.actual_second_light_four_slot_energy

end Nightfall.StructuralInformation.T2ActualSource
