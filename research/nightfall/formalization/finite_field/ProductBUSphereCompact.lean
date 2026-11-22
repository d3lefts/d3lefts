import Mathlib
import ProductSphereObstruction
import ProductBUSphereExtension
import ProductBUOrbitCertificate

/-!
# Compactness of the *exact* product-sphere topology domain

Certified geometric prerequisite for obtaining a positive uniform lower
bound from a continuous nowhere-zero separately equivariant block map.

This module does not assert any zero of a continuous equivariant map and
does not import a topological ProductSphereZero proof.
-/

namespace Nightfall.ProductBUSphereCompact

open Nightfall.ProductSphereObstruction
open Nightfall.ProductBUSphereExtension
open Nightfall.ProductBUOrbit

abbrev V (n : ℕ) := Fin n → ℝ

theorem unitVec_coordinate_abs_le_one (n : ℕ)
    (u : V n) (hu : UnitVec n u) (i : Fin n) :
    |u i| ≤ 1 := by
  have hs : (u i)^2 ≤ ∑ j : Fin n, (u j)^2 := by
    exact Finset.single_le_sum (fun j _ => sq_nonneg (u j)) (Finset.mem_univ i)
  have hunit : (∑ j : Fin n, (u j)^2) = 1 := hu
  have : (u i)^2 ≤ 1 := hs.trans_eq hunit
  exact (sq_le_one_iff_abs_le_one (u i)).mp this

theorem unitVec_coordinate_mem_Icc (n : ℕ)
    (u : V n) (hu : UnitVec n u) (i : Fin n) :
    u i ∈ Set.Icc (-1 : ℝ) 1 := by
  exact abs_le.mp (unitVec_coordinate_abs_le_one n u hu i)

/-- A fixed compact cube contains every exact unit sphere. -/
theorem unitSphere_isCompact (n : ℕ) :
    IsCompact {u : V n | UnitVec n u} := by
  let C : Set (V n) :=
    {u | ∀ i : Fin n, u i ∈ Set.Icc (-1 : ℝ) 1}
  have hC : IsCompact C := by
    simpa [C] using
      (isCompact_pi_infinite
        (s := fun _ : Fin n => Set.Icc (-1 : ℝ) 1)
        (fun _ => isCompact_Icc))
  have hclosed : IsClosed {u : V n | UnitVec n u} := by
    have hsum : Continuous (fun u : V n => ∑ i : Fin n, u i ^ 2) := by
      fun_prop
    simpa [UnitVec] using
      (isClosed_eq hsum
        (continuous_const : Continuous (fun _ : V n => (1 : ℝ))))
  apply IsCompact.of_isClosed_subset hC hclosed
  intro u hu
  change ∀ i : Fin n, u i ∈ Set.Icc (-1 : ℝ) 1
  exact fun i => unitVec_coordinate_mem_Icc n u hu i

/-- Compactness of the precise SpherePair domain in ProductSphereZero. -/
theorem spherePair_isCompact (n : ℕ) :
    IsCompact (SpherePair n) := by
  have h : IsCompact
      ({u : V n | UnitVec n u} ×ˢ {v : V n | UnitVec n v}) :=
    (unitSphere_isCompact n).prod (unitSphere_isCompact n)
  simpa [SpherePair, Set.prod, Set.mem_setOf_eq] using h

/-- For n=k+1 the product sphere is genuinely nonempty. -/
theorem spherePair_nonempty (k : ℕ) :
    (SpherePair (k + 1)).Nonempty := by
  refine ⟨(axis k, axis k), ?_⟩
  exact ⟨axis_unit k, axis_unit k⟩

#print axioms unitVec_coordinate_abs_le_one
#print axioms unitVec_coordinate_mem_Icc
#print axioms unitSphere_isCompact
#print axioms spherePair_isCompact
#print axioms spherePair_nonempty

end Nightfall.ProductBUSphereCompact
