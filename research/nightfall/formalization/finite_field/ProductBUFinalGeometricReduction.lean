import ProductBUGlobalAssembly
import ProductBUTimeZeroOrbit

/-!
# Single geometric interface for the maximal product-sphere contradiction

After source-preserving composition with the original algebraic
reference-zero classification, the actual zero fiber contradiction
requires no abstract four-point orbit hypothesis, no component
homeomorphism, no second boundary endpoint and no free-action axiom.

EXPLICIT REMAINING INPUTS:
* an actual smooth 1-manifold-with-boundary structure on the exact
  product-sphere zero-fiber subtype (not merely one local immersion);
* its boundary is contained in the t=0 face (t=1 already excluded);
* the actual augmented homotopy at t=0 has the reference zero equations;
* the physical sign characters preserve zeros.

Once those conditions are *proved* for the constructed generic Sard
family, this theorem gives the contradiction required for the maximal
ProductSphereZero terminal. They are not declared unconditionally here.
-/

open scoped Manifold Topology
open Manifold

namespace Nightfall.ProductBUFinalGeometricReduction
noncomputable section

open Nightfall.ProductBUCompactFiber
open Nightfall.ProductBUFiberFreeAction
open Nightfall.ProductBUGlobalAssembly
open Nightfall.ProductBUTimeZeroOrbit
open Nightfall.ProductBUParity

/-- The final (source-explicit) geometry reduction: actual smooth zero
fiber + correct t=0 boundary + canonical reference map is impossible
with a zero-free equivariant terminal slice. No fake interval/endpoint/
orbit assumptions or topology axioms. -/
theorem actual_smooth_time_boundary_zero_fiber_impossible
    (k m : ℕ) (F : SpaceTime (k + 1) → Values m)
    (hF : Continuous F)
    [ChartedSpace (EuclideanHalfSpace 1) (Z (k + 1) m F)]
    [IsManifold (𝓡∂ 1) ∞ (Z (k + 1) m F)]
    (hF0 : ∀ u v, UnitVec (k + 1) u → UnitVec (k + 1) v →
      F ((u,v), 0) = 0 →
      (∀ i : Fin k, refU k u v i = 0) ∧
      (∀ i : Fin k, refV k u v i = 0))
    (hFU : ∀ x, F x = 0 → F (flipU x) = 0)
    (hFV : ∀ x, F x = 0 → F (flipV x) = 0)
    (hFUV : ∀ x, F x = 0 → F (flipUV x) = 0)
    (p : Z (k + 1) m F)
    (hp : (𝓡∂ 1).IsBoundaryPoint p)
    (hboundary_time : ∀ z : Z (k + 1) m F,
      (𝓡∂ 1).IsBoundaryPoint z → z.1.2 = 0) : False := by
  apply actual_smooth_four_orbit_zero_fiber_impossible
    (k + 1) m F hF hFU hFV hFUV p hp
  intro z hz
  exact time_zero_real_fiber_one_orbit
    k m F hF0 hFU hFV hFUV p z
    (hboundary_time p hp) (hboundary_time z hz)

#check actual_smooth_time_boundary_zero_fiber_impossible
#print axioms actual_smooth_time_boundary_zero_fiber_impossible

end
end Nightfall.ProductBUFinalGeometricReduction
