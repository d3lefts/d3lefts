import ProductBUGlobalBoundary
import Mathlib.Geometry.Manifold.IsManifold.InteriorBoundary

/-!
# The second endpoint of the actual connected component

Within an actual compact smooth 1-manifold-with-boundary Z, the connected
component of a boundary point p is a compact connected open submanifold.
By the source-pinned ATLAS 1D classification its two distinct boundary
points are the inverse images of the endpoints of [0,1]. This extracts
the OTHER boundary point as a member of connectedComponent p.

No abstract interval homeomorphism, connected-component existence axiom,
or unverified smoothness of the specific product-sphere zero fiber is hidden.
The latter global geometric construction remains a separate obligation.
-/

open scoped Topology Manifold
open Manifold

namespace Nightfall.ProductBUComponentEndpoints
noncomputable section

abbrev I01 := Nightfall.ProductBUInterval.I01

/-- A selected boundary point in any compact smooth one-dimensional
manifold has a *distinct* boundary point within its actual connected
component. This is exactly the second-endpoint obligation previously
assumed in the product-sphere boundary-orbit contradiction. -/
theorem exists_second_endpoint_of_smooth_boundary_component
    (Z : Type*) [TopologicalSpace Z]
    [ChartedSpace (EuclideanHalfSpace 1) Z]
    [IsManifold (𝓡∂ 1) ∞ Z]
    [T2Space Z] [CompactSpace Z] [SecondCountableTopology Z]
    (p : Z) (hp : (𝓡∂ 1).IsBoundaryPoint p) :
    ∃ q : Z, q ∈ connectedComponent p ∧
      (𝓡∂ 1).IsBoundaryPoint q ∧ q ≠ p := by
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
  let pU : U := ⟨p, mem_connectedComponent⟩
  have hpU : pU ∈ ModelWithCorners.boundary (I := 𝓡∂ 1) U :=
    (ModelWithCorners.isBoundaryPoint_iff_isBoundaryPoint_val).2 hp
  have hbd : (ModelWithCorners.boundary (I := 𝓡∂ 1) U).Nonempty :=
    ⟨pU, hpU⟩
  obtain ⟨e⟩ :=
    Nightfall.ProductBUGlobalBoundary.boundary_component_diffeomorphic_closed_interval U hbd
  have hpre : e ⁻¹' ModelWithCorners.boundary (I := 𝓡∂ 1) I01 =
      ModelWithCorners.boundary (I := 𝓡∂ 1) U :=
    e.preimage_boundary (by simp)
  have hpI : e pU ∈ ModelWithCorners.boundary (I := 𝓡∂ 1) I01 := by
    have h : pU ∈ e ⁻¹' ModelWithCorners.boundary (I := 𝓡∂ 1) I01 := by
      rw [hpre]
      exact hpU
    exact h
  let target : I01 := if e pU = ⊥ then ⊤ else ⊥
  have htargetB : target ∈ ModelWithCorners.boundary (I := 𝓡∂ 1) I01 := by
    dsimp [target]
    split_ifs with h
    · exact Icc_isBoundaryPoint_top
    · exact Icc_isBoundaryPoint_bot
  have hneq : target ≠ e pU := by
    by_cases hb : e pU = (⊥ : I01)
    · intro h
      have he : (⊤ : I01) = ⊥ := by
        simpa [target, hb] using h.trans hb
      have he' := congrArg (fun z : I01 => (z : ℝ)) he
      norm_num at he'
    · intro h
      have he : (⊥ : I01) = e pU := by
        simpa [target, hb] using h
      exact hb he.symm
  let qU : U := e.symm target
  have hqU : qU ∈ ModelWithCorners.boundary (I := 𝓡∂ 1) U := by
    rw [← hpre]
    change e qU ∈ ModelWithCorners.boundary (I := 𝓡∂ 1) I01
    simpa [qU] using htargetB
  have hqn : (qU : Z) ≠ p := by
    intro h
    have heq : qU = pU := Subtype.ext h
    have he : target = e pU := by
      have h' := congrArg e heq
      simpa [qU] using h'
    exact hneq he
  exact ⟨qU.1, qU.2,
    (ModelWithCorners.isBoundaryPoint_iff_isBoundaryPoint_val).1 hqU,
    hqn⟩

#check exists_second_endpoint_of_smooth_boundary_component
#print axioms exists_second_endpoint_of_smooth_boundary_component

end
end Nightfall.ProductBUComponentEndpoints
