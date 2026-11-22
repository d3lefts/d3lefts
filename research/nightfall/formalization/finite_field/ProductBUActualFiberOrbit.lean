import Mathlib
import ProductBUFiberFreeAction
import ProductBUComponentOrbit

/-!
# Actual zero-fiber orbit-to-interval contradiction, without a free-action axiom

This module composes two separately kernel-checked sources:
- ProductBUFiberFreeAction (original #1082, direct-main #1085):
  genuine zero-preserving independent antipodal homeomorphisms on the exact
  homotopy zero-fiber subtype, each with a proved absence of fixed points.
- ProductBUComponentOrbit (original #1057, source-preserved here):
  a single four-point orbit at the boundary of a connected interval component
  forces a nonidentity group element to preserve the interval; a fixed point
  is unavoidable and contradicts freeness.

No free action, equivariant zero theorem, or manifold property is assumed
under another name. Geometry not yet supplied: existence of a regular
compact connected interval component and its two endpoints in the
reference four-point boundary orbit. The global ProductSphereZero theorem
is not derived by this conditional composition.
-/

namespace Nightfall.ProductBUActualFiberOrbit

open Nightfall.ProductBUCompactFiber
open Nightfall.ProductBUFiberFreeAction
open Nightfall.ProductBUComponentOrbit
open Nightfall.ProductBUInterval

/-- On the **actual compact homotopy zero-fiber** every chosen nontrivial
independent antipodal action is fixed-point-free. A connected component
homeomorphic to an interval cannot have both endpoints in the single
four-point reference orbit.

The only remaining geometric assumptions are that such a component and
such two distinct points exist and exhaust the specified reference
boundary orbit. All three free involutions are constructed, not assumed. -/
theorem reference_orbit_cannot_bound_actual_interval
    (n m : ℕ) (F : SpaceTime n → Values m)
    (hFU : ∀ x, F x = 0 → F (flipU x) = 0)
    (hFV : ∀ x, F x = 0 → F (flipV x) = 0)
    (hFUV : ∀ x, F x = 0 → F (flipUV x) = 0)
    (boundary : Set (Z n m F))
    (p q : Z n m F)
    (hboundary : ∀ z ∈ boundary,
      z = p ∨ z = eU n m F hFU p ∨
      z = eV n m F hFV p ∨
      z = eUV n m F hFUV p)
    (hqboundary : q ∈ boundary)
    (hqne : q ≠ p)
    (hqcomponent : q ∈ connectedComponent p)
    (hinterval : (connectedComponent p) ≃ₜ I01) : False := by
  exact no_free_single_four_orbit_boundary_component
    (eU n m F hFU) (eV n m F hFV) (eUV n m F hFUV)
    boundary p q hboundary hqboundary hqne hqcomponent hinterval
    (fun x _ => eU_no_fixed n m F hFU x)
    (fun x _ => eV_no_fixed n m F hFV x)
    (fun x _ => eUV_no_fixed n m F hFUV x)

#check reference_orbit_cannot_bound_actual_interval
#print axioms reference_orbit_cannot_bound_actual_interval

end Nightfall.ProductBUActualFiberOrbit
