import Mathlib

/-!
# Compatibility-to-smooth-manifold gluing of actual local interval charts

Mathlib's IsManifold.isManifold_of_contDiffOn requires a ChartedSpace on
the given subtype. This module builds that structure using genuine
open partial homeomorphisms whose sources cover the original topology,
and then checks that all chart transitions are C-infinity.

Theorem scope is conditional on an actual covering and explicit smooth
overlaps. It does NOT install a fabricated manifold instance on the
zero fiber nor prove ProductSphereZero.
-/

open scoped Topology Manifold
open Manifold

namespace Nightfall.ProductBUCompatibleAtlas
noncomputable section

/-- Construct a charted space with the original topology from a complete
family of actual open partial homeomorphisms. -/
def chartedSpaceOfCoveringCharts
    {X : Type*} [TopologicalSpace X]
    {ι : Type*}
    (charts : ι → OpenPartialHomeomorph X (EuclideanHalfSpace 1))
    (cover : ∀ x : X, ∃ i : ι, x ∈ (charts i).source) :
    ChartedSpace (EuclideanHalfSpace 1) X where
  atlas := Set.range charts
  chartAt x := charts (Classical.choose (cover x))
  mem_chart_source x := Classical.choose_spec (cover x)
  chart_mem_atlas x := ⟨Classical.choose (cover x), rfl⟩

/-- Compatible, covering local charts yield a genuine smooth
one-manifold with boundary on the already fixed topological space.
No theorem-shaped equivariant zero assumption is used. -/
theorem smooth_manifold_of_compatible_covering_charts
    {X : Type*} [TopologicalSpace X]
    {ι : Type*}
    (charts : ι → OpenPartialHomeomorph X (EuclideanHalfSpace 1))
    (cover : ∀ x : X, ∃ i : ι, x ∈ (charts i).source)
    (compatible : ∀ i j : ι,
      ContDiffOn ℝ (∞ : ℕ∞ω)
        ((𝓡∂ 1) ∘ (charts i).symm ≫ₕ charts j ∘ (𝓡∂ 1).symm)
        ((𝓡∂ 1).symm ⁻¹'
            ((charts i).symm ≫ₕ charts j).source ∩ range (𝓡∂ 1))) :
    letI : ChartedSpace (EuclideanHalfSpace 1) X :=
      chartedSpaceOfCoveringCharts charts cover
    IsManifold (𝓡∂ 1) ∞ X := by
  letI : ChartedSpace (EuclideanHalfSpace 1) X :=
    chartedSpaceOfCoveringCharts charts cover
  apply IsManifold.isManifold_of_contDiffOn (𝓡∂ 1) ∞ X
  intro e e' he he'
  change e ∈ Set.range charts at he
  change e' ∈ Set.range charts at he'
  rcases he with ⟨i, rfl⟩
  rcases he' with ⟨j, rfl⟩
  exact compatible i j

#check chartedSpaceOfCoveringCharts
#print axioms chartedSpaceOfCoveringCharts
#check smooth_manifold_of_compatible_covering_charts
#print axioms smooth_manifold_of_compatible_covering_charts

end
end Nightfall.ProductBUCompatibleAtlas
