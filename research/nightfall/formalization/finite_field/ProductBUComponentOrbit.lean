import Mathlib
import ProductBUIntervalStabilizer

/-!
# Product-sphere topological closure: a boundary orbit forces an interval stabilizer

This file composes the exact fixed-point-free interval obstruction from the
credited parallel ProductBUIntervalStabilizer module with the existing Mathlib
connected-component transport theorem. It discharges a *nontrivial intermediate*
topological dependency of the product-sphere cobordism route.

It does not construct the zero fiber, its smooth manifold structure, its
boundary, or a compact interval component; those are separate geometric
obligations. No ProductSphereZero axiom or theorem is assumed.
-/

namespace Nightfall.ProductBUComponentOrbit

open Nightfall.ProductBUInterval

/-- A homeomorphism which takes the base point to another point of its
connected component must preserve that entire component. A free such map
cannot exist when the component is homeomorphic to a closed interval. -/
theorem no_free_component_point_exchange
    {X : Type*} [TopologicalSpace X]
    (e : X ≃ₜ X) (p q : X)
    (hq : q ∈ connectedComponent p)
    (he : e p = q)
    (hinterval : (connectedComponent p) ≃ₜ I01)
    (hfree : ∀ x ∈ connectedComponent p, e x ≠ x) : False := by
  have hcomp : connectedComponent (e p) = connectedComponent p := by
    rw [he]
    exact (connectedComponent_eq hq).symm
  have hmaps : Set.MapsTo e (connectedComponent p) (connectedComponent p) := by
    intro x hx
    have hmem : e x ∈ e '' connectedComponent p :=
      ⟨x, hx, rfl⟩
    have him := e.continuous.image_connectedComponent_subset p hmem
    rwa [hcomp] at him
  exact no_fixedpoint_free_invariant_interval
    (connectedComponent p) hinterval e e.continuous hmaps hfree

/-- The four-point boundary orbit obtained from the product-sphere reference
zero locus is incompatible with a free action whenever the component of a
boundary point is a closed interval containing a second boundary point.

The assumptions on the boundary set and component are deliberately explicit:
this lemma does not assert a manifold structure or regularity of a zero locus.
-/
theorem no_free_single_four_orbit_boundary_component
    {X : Type*} [TopologicalSpace X]
    (eU eV eUV : X ≃ₜ X)
    (boundary : Set X) (p q : X)
    (hboundary : ∀ z ∈ boundary,
      z = p ∨ z = eU p ∨ z = eV p ∨ z = eUV p)
    (hqboundary : q ∈ boundary)
    (hqne : q ≠ p)
    (hqcomponent : q ∈ connectedComponent p)
    (hinterval : (connectedComponent p) ≃ₜ I01)
    (hfreeU : ∀ x ∈ connectedComponent p, eU x ≠ x)
    (hfreeV : ∀ x ∈ connectedComponent p, eV x ≠ x)
    (hfreeUV : ∀ x ∈ connectedComponent p, eUV x ≠ x) : False := by
  rcases hboundary q hqboundary with h | h | h | h
  · exact hqne h
  · exact no_free_component_point_exchange eU p q
      hqcomponent h.symm hinterval hfreeU
  · exact no_free_component_point_exchange eV p q
      hqcomponent h.symm hinterval hfreeV
  · exact no_free_component_point_exchange eUV p q
      hqcomponent h.symm hinterval hfreeUV

#check no_free_component_point_exchange
#print axioms no_free_component_point_exchange
#check no_free_single_four_orbit_boundary_component
#print axioms no_free_single_four_orbit_boundary_component

end Nightfall.ProductBUComponentOrbit
