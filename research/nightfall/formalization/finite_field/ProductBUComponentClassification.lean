import ProductBUGlobalBoundary
import Mathlib.Geometry.Manifold.IsManifold.InteriorBoundary

/-!
# Global geometry: selected boundary component of a compact 1D smooth fiber

This theorem replaces an assumed interval component by an actual derivation:
the connected component of any boundary point of a compact smooth 1D
manifold-with-boundary is itself a compact, connected open smooth manifold
with nonempty boundary, hence an interval by the ATLAS global classification.

The result is generic: it does not assert the concrete augmented product-sphere
zero fiber carries the required smooth manifold structure. The latter is the
remaining global chart/gluing and derivative-equivalence obligation.
-/

open scoped Topology Manifold
open Manifold

namespace Nightfall.ProductBUComponentClassification
noncomputable section

/-- In a genuine compact smooth 1D boundary manifold, a connected
component containing a boundary point is a closed interval.
This builds the selected component from the actual ambient topology,
rather than asking for an interval equivalence as an input. -/
theorem boundary_connected_component_is_interval
    (Z : Type*) [TopologicalSpace Z]
    [ChartedSpace (EuclideanHalfSpace 1) Z]
    [IsManifold (𝓡∂ 1) ∞ Z]
    [T2Space Z] [CompactSpace Z] [SecondCountableTopology Z]
    (p : Z) (hp : (𝓡∂ 1).IsBoundaryPoint p) :
    Nonempty ((connectedComponent p) ≃ₜ
      Nightfall.ProductBUInterval.I01) := by
  letI : LocallyConnectedSpace Z :=
    ChartedSpace.locallyConnectedSpace (H := EuclideanHalfSpace 1)
  have hOpen : IsOpen (connectedComponent p) :=
    isOpen_connectedComponent
  let U : TopologicalSpace.Opens Z := ⟨connectedComponent p, hOpen⟩
  have hcompact : IsCompact (connectedComponent p) :=
    isClosed_connectedComponent.isCompact
  have hcompactU : IsCompact (U : Set Z) := by
    simpa [U] using hcompact
  letI : CompactSpace U := isCompact_iff_compactSpace.mp hcompactU
  have hconnected : IsConnected (U : Set Z) := by
    simpa [U] using (isConnected_connectedComponent (x := p))
  letI : ConnectedSpace U :=
    isConnected_iff_connectedSpace.mp hconnected
  have hpU : (⟨p, mem_connectedComponent⟩ : U) ∈
      ModelWithCorners.boundary (I := 𝓡∂ 1) U := by
    exact (ModelWithCorners.isBoundaryPoint_iff_isBoundaryPoint_val).2 hp
  have hbd : (ModelWithCorners.boundary (I := 𝓡∂ 1) U).Nonempty :=
    ⟨⟨p, mem_connectedComponent⟩, hpU⟩
  obtain ⟨e⟩ :=
    Nightfall.ProductBUGlobalBoundary.boundary_component_homeomorphic_closed_interval U hbd
  exact ⟨e⟩

#check boundary_connected_component_is_interval
#print axioms boundary_connected_component_is_interval

end
end Nightfall.ProductBUComponentClassification
