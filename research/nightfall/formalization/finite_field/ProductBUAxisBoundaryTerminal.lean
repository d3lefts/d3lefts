import ProductBUFinalGeometricReduction
import ProductBUReferenceFace

/-!
# Source-explicit regular-fiber geometric contradiction without a chosen boundary point

Further closes the global assembly's input interface: the reference axis
zero exists by merged ProductBUReferenceFace, so there is no need to
assume existence of an arbitrary manifold boundary point or a separately
selected member of the reference orbit. All free actions, connected
component selection, interval classification and second endpoint are
already constructed in the preceding source modules.

The remaining *geometric* obligations are precisely
1. the actual zero fiber has a C∞ 1D manifold-with-boundary structure
   compatible with its subtype topology;
2. its manifold boundary coincides with the t=0 points;
3. the concrete smooth equivariant homotopy has the reference t=0
   response and physical sign symmetries.

This does not assert unconditional ProductSphereZero or introduce an axiom.
-/

open scoped Manifold Topology
open Manifold

namespace Nightfall.ProductBUAxisBoundaryTerminal
noncomputable section

open Nightfall.ProductSphereObstruction
open Nightfall.ProductBUOrbit
open Nightfall.ProductBUParity
open Nightfall.ProductBUCompactFiber
open Nightfall.ProductBUFiberFreeAction
open Nightfall.ProductBUReferenceFace
open Nightfall.ProductBUFinalGeometricReduction

/-- The actual four-axis reference t=0 fiber supplies its own boundary
point. Consequently the global contradiction no longer assumes
one such point as an input. -/
theorem actual_smooth_reference_boundary_impossible
    (k m : ℕ) (F : SpaceTime (k + 1) → Values m)
    (hF : Continuous F)
    [ChartedSpace (EuclideanHalfSpace 1) (Z (k + 1) m F)]
    [IsManifold (𝓡∂ 1) ∞ (Z (k + 1) m F)]
    (hF0 : ∀ z ∈ SpherePair (k + 1),
      (F (z, 0) = 0 ↔
        (∀ i : Fin k, refU k z.1 z.2 i = 0) ∧
        (∀ i : Fin k, refV k z.1 z.2 i = 0)))
    (hFU : ∀ x, F x = 0 → F (flipU x) = 0)
    (hFV : ∀ x, F x = 0 → F (flipV x) = 0)
    (hFUV : ∀ x, F x = 0 → F (flipUV x) = 0)
    (hboundary : ∀ z : Z (k + 1) m F,
      (𝓡∂ 1).IsBoundaryPoint z ↔ z.1.2 = 0) : False := by
  let a : PairSpace (k + 1) := (axis k, axis k)
  have ha : a ∈ signedAxes k := by
    change (a.1 = axis k ∨ a.1 = -axis k) ∧
      (a.2 = axis k ∨ a.2 = -axis k)
    exact ⟨Or.inl rfl, Or.inl rfl⟩
  have hpoint : (a, (0 : ℝ)) ∈ zeroFiber (k + 1) m F :=
    (zeroFiber_time_zero_iff k m F hF0 a).mpr ha
  let p : Z (k + 1) m F := ⟨(a, 0), hpoint⟩
  have hp : (𝓡∂ 1).IsBoundaryPoint p :=
    (hboundary p).mpr rfl
  apply actual_smooth_time_boundary_zero_fiber_impossible
    k m F hF (fun u v hu hv hzero =>
      (hF0 (u, v) ⟨hu, hv⟩).mp hzero)
    hFU hFV hFUV p hp
  intro z hz
  exact (hboundary z).mp hz

#check actual_smooth_reference_boundary_impossible
#print axioms actual_smooth_reference_boundary_impossible

end
end Nightfall.ProductBUAxisBoundaryTerminal
