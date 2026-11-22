import ProductBUComponentClassification
import ProductBUComponentEndpoints
import ProductBUActualFiberOrbit

/-!
# Global geometric assembly terminal on the ACTUAL compact zero fiber

This theorem removes all formerly assumed existence of an interval component,
a second boundary endpoint, and abstract freeness of the three sign actions.
It uses:
1. actual compactness of the continuous product-sphere zero fiber (#1080);
2. an inherited smooth 1-manifold-with-boundary charted-space structure;
3. the global ATLAS interval classification and genuine second-endpoint
   extraction from an actual boundary component (this branch);
4. genuine free zero-preserving sign actions (merged #1085);
5. the single-orbit interval stabilizer contradiction (#1057/#1086).

The remaining full-topology proof obligation is concrete and isolated:
CONSTRUCT (rather than assume) the smooth boundary-manifold structure on
the actual regular zero fiber from the augmented Sard and local graph
lemmas, and prove that its boundary exactly equals the four reference
t=0 zeros. Then instantiate this theorem to prove ProductSphereZero.

The present result is a conditional global geometric composition and NOT
a certificate for ProductSphereZero by itself.
-/

open scoped Manifold Topology
open Manifold

namespace Nightfall.ProductBUGlobalAssembly
noncomputable section

open Nightfall.ProductBUCompactFiber
open Nightfall.ProductBUFiberFreeAction
open Nightfall.ProductBUActualFiberOrbit
open Nightfall.ProductBUComponentClassification
open Nightfall.ProductBUComponentEndpoints

/-- For the actual compact homotopy zero fiber, a genuine compact
smooth one-manifold-with-boundary structure plus a single four-element
boundary orbit contradicts the three physical free sign homeomorphisms.
No abstract interval-component, second-endpoint, or freeness premise. -/
theorem actual_smooth_four_orbit_zero_fiber_impossible
    (n m : ℕ) (F : SpaceTime n → Values m) (hF : Continuous F)
    [ChartedSpace (EuclideanHalfSpace 1) (Z n m F)]
    [IsManifold (𝓡∂ 1) ∞ (Z n m F)]
    (hFU : ∀ x, F x = 0 → F (flipU x) = 0)
    (hFV : ∀ x, F x = 0 → F (flipV x) = 0)
    (hFUV : ∀ x, F x = 0 → F (flipUV x) = 0)
    (p : Z n m F)
    (hp : (𝓡∂ 1).IsBoundaryPoint p)
    (hboundary : ∀ z : Z n m F,
      (𝓡∂ 1).IsBoundaryPoint z →
        z = p ∨ z = eU n m F hFU p ∨
        z = eV n m F hFV p ∨
        z = eUV n m F hFUV p) : False := by
  letI : CompactSpace (Z n m F) :=
    isCompact_iff_compactSpace.mp (zeroFiber_isCompact n m F hF)
  obtain ⟨q, hqcomponent, hqboundary, hqne⟩ :=
    exists_second_endpoint_of_smooth_boundary_component
      (Z n m F) p hp
  obtain ⟨hI⟩ :=
    boundary_connected_component_is_interval (Z n m F) p hp
  exact reference_orbit_cannot_bound_actual_interval
    n m F hFU hFV hFUV
    (ModelWithCorners.boundary (I := 𝓡∂ 1) (Z n m F))
    p q hboundary hqboundary hqne hqcomponent hI

#check actual_smooth_four_orbit_zero_fiber_impossible
#print axioms actual_smooth_four_orbit_zero_fiber_impossible

end
end Nightfall.ProductBUGlobalAssembly
