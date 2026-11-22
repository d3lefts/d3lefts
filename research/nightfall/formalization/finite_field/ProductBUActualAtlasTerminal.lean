import Mathlib
import ProductBUCompatibleAtlas
import ProductBUAxisBoundaryTerminal

/-!
# Actual product-sphere zero fiber: explicit chart-to-obstruction assembly

This composes the source-pinned global one-dimensional compact-boundary
component classification, the physical four-point axis reference orbit and
the three free antipodal fiber homeomorphisms with the COMPATIBLE CHART
constructor on the original zero-fiber subtype.

Unlike ProductBUAxisBoundaryTerminal, this theorem DOES NOT take a
ChartedSpace or IsManifold instance as a premise. It builds both from
an explicit genuine covering family of smooth-compatible halfspace charts
on the actual topological zero-fiber.

The assumptions still requiring separate construction from the actual
augmented Euclidean family are: the covering halfspace charts and their
smooth transition law; their geometric boundary equals the reference
t=0 time face; the exact reference response and physical sign laws.
This source never asserts ProductSphereZero as an axiom, hypothesis or
conclusion. Its purpose is to make the remaining concrete geometry
proof obligations fully visible in a single checked Lean theorem.
-/

open scoped Topology Manifold ContDiff
open Manifold

namespace Nightfall.ProductBUActualAtlasTerminal

open Nightfall.ProductBUCompactFiber
open Nightfall.ProductBUFiberFreeAction
open Nightfall.ProductBUParity
open Nightfall.ProductSphereObstruction
open Nightfall.ProductBUCompatibleAtlas

noncomputable section

/-- One fully explicit geometric interface: actual genuine halfspace
charts covering the physical zero-fiber, compatible C-infinity overlaps,
physical t=0 reference zeros, free sign symmetries, and the boundary
time-face identity imply a contradiction. No assumed manifold instance.

The requested universal ProductSphereZero still needs the actual
construction of these charts and the generic regular Sard parameter. -/
theorem impossible_of_actual_covering_halfspace_atlas
    {ι : Type*}
    (k m : ℕ) (F : SpaceTime (k + 1) → Values m)
    (hF : Continuous F)
    (charts : ι → OpenPartialHomeomorph
      (Z (k + 1) m F) (EuclideanHalfSpace 1))
    (cover : ∀ x : Z (k + 1) m F,
      ∃ i : ι, x ∈ (charts i).source)
    (compatible : ∀ i j : ι,
      ContDiffOn ℝ (∞ : ℕ∞ω)
        ((𝓡∂ 1) ∘ (charts i).symm ≫ₕ charts j ∘ (𝓡∂ 1).symm)
        ((𝓡∂ 1).symm ⁻¹'
          ((charts i).symm ≫ₕ charts j).source ∩
            Set.range (𝓡∂ 1)))
    (hF0 : ∀ z ∈ SpherePair (k + 1),
      (F (z, 0) = 0 ↔
        (∀ i : Fin k, refU k z.1 z.2 i = 0) ∧
        (∀ i : Fin k, refV k z.1 z.2 i = 0)))
    (hFU : ∀ x, F x = 0 → F (flipU x) = 0)
    (hFV : ∀ x, F x = 0 → F (flipV x) = 0)
    (hFUV : ∀ x, F x = 0 → F (flipUV x) = 0)
    (hboundary :
      letI : ChartedSpace (EuclideanHalfSpace 1)
        (Z (k + 1) m F) :=
        chartedSpaceOfCoveringCharts charts cover
      ∀ z : Z (k + 1) m F,
        (𝓡∂ 1).IsBoundaryPoint z ↔ z.1.2 = 0) : False := by
  letI : ChartedSpace (EuclideanHalfSpace 1)
      (Z (k + 1) m F) :=
    chartedSpaceOfCoveringCharts charts cover
  letI : IsManifold (𝓡∂ 1) ∞
      (Z (k + 1) m F) :=
    smooth_manifold_of_compatible_covering_charts charts cover compatible
  exact Nightfall.ProductBUAxisBoundaryTerminal.actual_smooth_reference_boundary_impossible
    k m F hF hF0 hFU hFV hFUV hboundary

#check impossible_of_actual_covering_halfspace_atlas
#print axioms impossible_of_actual_covering_halfspace_atlas

end
end Nightfall.ProductBUActualAtlasTerminal
