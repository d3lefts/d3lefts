import MathlibExt.Geometry.Manifold.OneDimensional
import ProductBUIntervalStabilizer

/-!
# Global geometry: a compact connected smooth boundary component is an interval

This module closes the circle-or-interval branch of the source-pinned
ATLAS 1D classification using the actual nonempty boundary rather than
assuming a homeomorphism to an interval. Then it composes classification
with NIGHTFALL's already-certified IVT fixed-point theorem to rule out
fixed-point-free homeomorphisms of such a component.

Remaining full theorem obligations: construct the smooth boundary-manifold
instance on the real regular zero fiber, show the selected connected component
inherits compactness and the manifold structure, and instantiate a genuine
free stabilizing sign action. No ProductSphereZero assertion is made.

Original ATLAS source: facebookresearch/atlas-lean at
7857a2e8c32088b5002f7cafe29a21d936baf704 (Apache-2.0).
Original interval theorem: NIGHTFALL merged PR #1061.
-/

open scoped Manifold Topology
open Manifold

namespace Nightfall.ProductBUGlobalBoundary
noncomputable section

abbrev I01 := Nightfall.ProductBUInterval.I01

/-- Nonempty boundary excludes the circle branch of ATLAS classification. -/
theorem boundary_component_homeomorphic_closed_interval
    (M : Type*) [TopologicalSpace M]
    [ChartedSpace (EuclideanHalfSpace 1) M]
    [IsManifold (𝓡∂ 1) ∞ M]
    [T2Space M] [CompactSpace M] [ConnectedSpace M]
    [SecondCountableTopology M]
    (hboundary : (ModelWithCorners.boundary (I := 𝓡∂ 1) M).Nonempty) :
    Nonempty (M ≃ₜ I01) := by
  obtain ⟨x, hx⟩ := hboundary
  rcases
      MathlibExt.Geometry.Manifold.OneDimensionalWanted.compact_connected_one_manifold_with_boundary_classification M
    with ⟨e⟩ | ⟨e⟩
  · have hpre : e ⁻¹' (ModelWithCorners.boundary (I := 𝓡 1) Circle) =
        ModelWithCorners.boundary (I := 𝓡∂ 1) M := by
      exact e.preimage_boundary (by simp)
    have hx' : e x ∈ ModelWithCorners.boundary (I := 𝓡 1) Circle := by
      have hh : x ∈ e ⁻¹' (ModelWithCorners.boundary (I := 𝓡 1) Circle) := by
        rw [hpre]
        exact hx
      exact hh
    have hC : ModelWithCorners.boundary (I := 𝓡 1) Circle = ∅ :=
      ModelWithCorners.Boundaryless.boundary_eq_empty
    rw [hC] at hx'
    exact False.elim (Set.not_mem_empty _ hx')
  · exact ⟨e.toHomeomorph⟩

/-- A fixed-point-free homeomorphism of a compact connected smooth
1-manifold with nonempty boundary is impossible by the real IVT. -/
theorem no_free_homeomorphism_of_compact_boundary_component
    (M : Type*) [TopologicalSpace M]
    [ChartedSpace (EuclideanHalfSpace 1) M]
    [IsManifold (𝓡∂ 1) ∞ M]
    [T2Space M] [CompactSpace M] [ConnectedSpace M]
    [SecondCountableTopology M]
    (hboundary : (ModelWithCorners.boundary (I := 𝓡∂ 1) M).Nonempty)
    (g : M ≃ₜ M) (hfree : ∀ x : M, g x ≠ x) : False := by
  obtain ⟨hI⟩ := boundary_component_homeomorphic_closed_interval M hboundary
  let f : I01 → I01 := fun t => hI (g (hI.symm t))
  have hf : Continuous f :=
    hI.continuous.comp (g.continuous.comp hI.symm.continuous)
  obtain ⟨t, ht⟩ :=
    Nightfall.ProductBUInterval.interval_endomap_has_fixed_point f hf
  have hfixed : g (hI.symm t) = hI.symm t := by
    apply hI.injective
    simpa [f] using ht
  exact hfree (hI.symm t) hfixed

#check boundary_component_homeomorphic_closed_interval
#print axioms boundary_component_homeomorphic_closed_interval
#check no_free_homeomorphism_of_compact_boundary_component
#print axioms no_free_homeomorphism_of_compact_boundary_component

end
end Nightfall.ProductBUGlobalBoundary
