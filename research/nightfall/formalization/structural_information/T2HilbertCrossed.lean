import Mathlib

/-!
# NIGHTFALL T2: arbitrary complex-normed sector crossed-slot frame

The decisive operator-factorization mechanism of equation (8), now with
each oracle sector containing an *arbitrary complex normed vector space* E,
including infinite-dimensional Hilbert spaces.

D is finite (finite original query alphabet). The direct-sum Hilbert energy
is the sum of sector norm-squares. P is an arbitrary complex-linear map
acting jointly across all sectors, assumed contractive in that energy.
No assumption of diagonality, commuting with sector projections, low rank,
finite dimension of E, or projectivity is made.

The individual proof is independent of the paper's four-slot XOR grouping.
It does NOT yet identify an arbitrary physical Hilbert-space projector
decomposition with this direct-sum representation, nor prove that the
physical effect 0 <= P <= I induces the required energy contraction.
Those source-to-operator steps and the full Fourier/query terminal remain
distinct formalization obligations.
-/

namespace Nightfall.StructuralInformation.T2HilbertCrossed

open Finset

variable {D : Type*} [Fintype D] [DecidableEq D]
variable {E : Type*}
variable [NormedAddCommGroup E] [NormedSpace ℂ E]

/-- An arbitrary complex-normed vector in each output oracle sector. -/
abbrev SectorH (D E : Type*) := D → E

/-- Actual direct-sum Hilbert energy: no ambient dimension parameter. -/
noncomputable def energy (x : SectorH D E) : ℝ :=
  ∑ d : D, ‖x d‖ ^ 2

theorem energy_nonneg (x : SectorH D E) :
    0 ≤ energy x := by
  unfold energy
  exact Finset.sum_nonneg (fun d _ => sq_nonneg _)

theorem single_sector_energy_le (x : SectorH D E) (a : D) :
    ‖x a‖ ^ 2 ≤ energy x := by
  unfold energy
  exact Finset.single_le_sum
    (fun b _ => sq_nonneg _) (Finset.mem_univ a)

/-- The elementary Hilbert-energy pinching across different input rows.
P can mix all sectors in a noncommuting manner. -/
theorem selected_sector_contraction
    (P : SectorH D E → SectorH D E)
    (hP : ∀ x, energy (P x) ≤ energy x)
    (w : D → SectorH D E) :
    (∑ a : D, ‖(P (w a)) a‖ ^ 2) ≤
       ∑ a : D, energy (w a) := by
  apply Finset.sum_le_sum
  intro a _
  exact (single_sector_energy_le (P (w a)) a).trans (hP (w a))

/-- The actual fixed-first-slot complex weighted second-stage path. -/
noncomputable def crossedInput (T : D → D → E)
    (beta : D → ℂ) (a : D) : SectorH D E :=
  fun b => beta b • T b a

/-- Analytic T2 crossed-slot bound for general complex-normed E.
The only operator assumption is its actual Hilbert-energy contraction;
all other inequalities and the pair-frequency charge are derived. -/
theorem crossed_energy_le
    (P : SectorH D E → SectorH D E)
    (hP : ∀ x, energy (P x) ≤ energy x)
    (T : D → D → E) (beta : D → ℂ) :
    (∑ a : D, ‖(P (crossedInput T beta a)) a‖ ^ 2) ≤
      ∑ b : D, ‖beta b‖ ^ 2 *
        (∑ a : D, ‖T b a‖ ^ 2) := by
  calc
    _ ≤ ∑ a : D, energy (crossedInput T beta a) :=
       selected_sector_contraction P hP (crossedInput T beta)
    _ = ∑ a : D, ∑ b : D,
          ‖beta b‖ ^ 2 * ‖T b a‖ ^ 2 := by
        simp only [energy, crossedInput, norm_smul, mul_pow]
    _ = ∑ b : D, ‖beta b‖ ^ 2 *
        (∑ a : D, ‖T b a‖ ^ 2) := by
        rw [Finset.sum_comm]
        simp only [← Finset.mul_sum]

/-- One original quantum path is supported on its actual output sector. -/
noncomputable def path (T : D → D → E) (b a : D) : SectorH D E :=
  fun d => if d = b then T b a else 0

theorem weighted_path_sum
    (T : D → D → E) (beta : D → ℂ) (a : D) :
    (∑ b : D, beta b • path T b a) =
      crossedInput T beta a := by
  classical
  funext d
  simp [path, crossedInput, Finset.sum_apply, Pi.smul_apply]

/-- Crossed-slot synthesis is the actual linear image of path sums.
This *derives* its coefficient regrouping from the given P, rather than
assuming a conclusion of the paper as a separate theorem premise. -/
noncomputable def crossedF
    (P : SectorH D E →ₗ[ℂ] SectorH D E)
    (T : D → D → E) (b a : D) : E :=
  (P (path T b a)) a

theorem crossed_synthesis
    (P : SectorH D E →ₗ[ℂ] SectorH D E)
    (T : D → D → E) (beta : D → ℂ) (a : D) :
    (∑ b : D, beta b • crossedF P T b a) =
      (P (crossedInput T beta a)) a := by
  classical
  calc
    _ = (∑ b : D, (P (beta b • path T b a)) a) := by
      simp [crossedF, map_smul, Pi.smul_apply]
    _ = (P (∑ b : D, beta b • path T b a)) a := by
      rw [map_sum]
      simp only [Finset.sum_apply]
    _ = (P (crossedInput T beta a)) a := by
      rw [weighted_path_sum]

/-- Source equation (8): arbitrary complex test vector beta, any number
of sectors, arbitrary complex-normed (including infinite-dimensional)
sector fiber, and arbitrary *noncommuting* linear P contractive in
the direct-sum Hilbert energy. -/
theorem noncommuting_crossed_slot_bound
    (P : SectorH D E →ₗ[ℂ] SectorH D E)
    (hP : ∀ x, energy (P x) ≤ energy x)
    (T : D → D → E) (beta : D → ℂ) :
    (∑ a : D, ‖∑ b : D, beta b • crossedF P T b a‖ ^ 2) ≤
      ∑ b : D, ‖beta b‖ ^ 2 * (∑ a : D, ‖T b a‖ ^ 2) := by
  calc
    _ = ∑ a : D, ‖(P (crossedInput T beta a)) a‖ ^ 2 := by
      apply Finset.sum_congr rfl
      intro a _
      rw [crossed_synthesis]
    _ ≤ _ := crossed_energy_le P hP T beta

#print axioms Nightfall.StructuralInformation.T2HilbertCrossed.energy_nonneg
#print axioms Nightfall.StructuralInformation.T2HilbertCrossed.single_sector_energy_le
#print axioms Nightfall.StructuralInformation.T2HilbertCrossed.selected_sector_contraction
#print axioms Nightfall.StructuralInformation.T2HilbertCrossed.crossed_energy_le
#print axioms Nightfall.StructuralInformation.T2HilbertCrossed.weighted_path_sum
#print axioms Nightfall.StructuralInformation.T2HilbertCrossed.crossed_synthesis
#print axioms Nightfall.StructuralInformation.T2HilbertCrossed.noncommuting_crossed_slot_bound

end Nightfall.StructuralInformation.T2HilbertCrossed
