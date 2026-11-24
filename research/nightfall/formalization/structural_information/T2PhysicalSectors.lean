import Mathlib

/-!
# NIGHTFALL T2 — heterogeneous physical orthogonal projector sectors

The unrestricted complex two-query theorem allows arbitrary mutually
orthogonal projections Π_d summing to I on a possibly infinite-dimensional
complex Hilbert H. Their ranges may have different Hilbert dimensions
(including the zero subspace). Replacing each range by a common
copy of E without justification would narrow the theorem.

Mathlib provides the exact canonical Hilbert isometry of a finite
internal orthogonal direct-sum of *dependent* submodule ranges.
We expose it as a source-bound bridge from the physical ambient space
to actual dependent PiLp2 fibers. This is not finite-dimensionality
or a choice of orthonormal basis.

The model identifies every physical vector, unitary state, and inner
product without changing quantum probabilities or sector energies.
Constructing the projector-range family from the concrete Π operators
and transporting the complete grouped T2-31 Fourier proof remain
separate exact formalization steps.
-/

namespace Nightfall.StructuralInformation.T2PhysicalSectors

open Finset

variable {D : Type*} [Fintype D] [DecidableEq D]
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- The actual heterogeneous orthogonal-sector direct sum; every
fiber is the possibly zero-dimensional range subspace F d. -/
abbrev PhysicalSectorSum (F : D → Submodule ℂ E) :=
  PiLp 2 (fun d => F d)

/-- An internal orthogonal sector family identifies the *entire*
physical H with the heterogeneous Hilbert direct sum of ranges. -/
noncomputable def sectorIsometry
    (F : D → Submodule ℂ E)
    (hinternal : DirectSum.IsInternal F)
    (horth : OrthogonalFamily ℂ (fun d => F d)
      (fun d => (F d).subtypeₗᵢ)) :
    E ≃ₗᵢ[ℂ] PhysicalSectorSum F :=
  hinternal.isometryL2OfOrthogonalFamily horth

/-- Exact physical Hilbert norm squared equals the sum of the squared
norms of dependent sector coordinates, including zero ranges. -/
theorem norm_sq_eq_sum_physical_sectors
    (F : D → Submodule ℂ E)
    (hinternal : DirectSum.IsInternal F)
    (horth : OrthogonalFamily ℂ (fun d => F d)
      (fun d => (F d).subtypeₗᵢ))
    (x : E) :
    ‖x‖ ^ 2 =
      ∑ d : D, ‖(sectorIsometry F hinternal horth x) d‖ ^ 2 := by
  calc
    ‖x‖ ^ 2 = ‖sectorIsometry F hinternal horth x‖ ^ 2 := by
      rw [LinearIsometryEquiv.norm_map]
    _ = ∑ d : D, ‖(sectorIsometry F hinternal horth x) d‖ ^ 2 :=
      PiLp.norm_sq_eq_of_L2 _ _

/-- The physical inner product is exactly the dependent sector sum;
no commutation or rank assumption on any terminal effect is used. -/
theorem inner_eq_sum_physical_sectors
    (F : D → Submodule ℂ E)
    (hinternal : DirectSum.IsInternal F)
    (horth : OrthogonalFamily ℂ (fun d => F d)
      (fun d => (F d).subtypeₗᵢ))
    (x y : E) :
    inner ℂ x y =
      ∑ d : D, inner ℂ
        ((sectorIsometry F hinternal horth x) d)
        ((sectorIsometry F hinternal horth y) d) := by
  calc
    inner ℂ x y =
      inner ℂ (sectorIsometry F hinternal horth x)
        (sectorIsometry F hinternal horth y) := by
          rw [LinearIsometryEquiv.inner_map_map]
    _ = _ := by
      exact PiLp.inner_apply
        (sectorIsometry F hinternal horth x)
        (sectorIsometry F hinternal horth y)

/-- Any arbitrary physical unitary becomes a genuine unitary of
the dependent physical sector direct sum, without forcing equal
dimensions across the Π_d ranges. -/
noncomputable def transportedUnitary
    (F : D → Submodule ℂ E)
    (hinternal : DirectSum.IsInternal F)
    (horth : OrthogonalFamily ℂ (fun d => F d)
      (fun d => (F d).subtypeₗᵢ))
    (U : E ≃ₗᵢ[ℂ] E) :
    PhysicalSectorSum F ≃ₗᵢ[ℂ] PhysicalSectorSum F :=
  ((sectorIsometry F hinternal horth).symm.trans U).trans
    (sectorIsometry F hinternal horth)

/-- The transported arbitrary physical unitary preserves the
actual sector-sum Hilbert energy in all dimensions. -/
theorem transportedUnitary_norm_eq
    (F : D → Submodule ℂ E)
    (hinternal : DirectSum.IsInternal F)
    (horth : OrthogonalFamily ℂ (fun d => F d)
      (fun d => (F d).subtypeₗᵢ))
    (U : E ≃ₗᵢ[ℂ] E)
    (x : PhysicalSectorSum F) :
    ‖transportedUnitary F hinternal horth U x‖ = ‖x‖ := by
  exact LinearIsometryEquiv.norm_map _ _

#print axioms Nightfall.StructuralInformation.T2PhysicalSectors.norm_sq_eq_sum_physical_sectors
#print axioms Nightfall.StructuralInformation.T2PhysicalSectors.inner_eq_sum_physical_sectors
#print axioms Nightfall.StructuralInformation.T2PhysicalSectors.transportedUnitary_norm_eq

end Nightfall.StructuralInformation.T2PhysicalSectors
