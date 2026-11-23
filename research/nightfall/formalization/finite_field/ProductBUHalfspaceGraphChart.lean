import Mathlib
import ProductBULocalGraphChart

/-!
# Genuine local graph chart composed with the canonical one-dimensional halfspace chart

On the PHYSICAL closed time slab, the source's local graph chart has
time parameter in Icc 0 1. The Mathlib IccLeftChart takes precisely
that interval to EuclideanHalfSpace 1 on the relatively open left part.

This constructs a bona fide OpenPartialHomeomorph on the ACTUAL graph
subtype, with no assumed ChartedSpace or IsManifold instance.
The chart is local: it automatically discards the t=1 endpoint and
does not assert a covering family over the full product-sphere zero fiber.

Its hypotheses remain exact graph data. Instantiating those from the
concrete augmented product-BU homotopy, verifying all overlaps and
proving the physical boundary equals t=0 are still separate Lean goals.

Attribution: original #1136/#1139 graph constructor and Mathlib's
IccLeftChart. This composition is formal proof infrastructure, not
a new abstract product Borsuk-Ulam theorem.
-/

open scoped Topology Manifold

namespace Nightfall.ProductBUHalfspaceGraphChart

open Nightfall.ProductBULocalGraphChart

abbrev I01 := Set.Icc (0 : ℝ) 1

/-- From genuine exact local graph data on a closed time slab,
construct a true partial homeomorphism into EuclideanHalfSpace 1.
The target is the manifold-with-boundary model, not all of real space.

The explicit local graph hypotheses cannot be confused with a
pre-existing manifold or with the unproved ProductSphereZero theorem. -/
noncomputable def actual_left_halfspace_chart
    {B : Type*} [TopologicalSpace B]
    (s : Set (I01 × B))
    (U : Set I01) (V : Set (I01 × B)) (g : I01 → B)
    (hU : IsOpen U) (hV : IsOpen V)
    (hg : ContinuousOn g U)
    (hshape : ∀ z ∈ V,
      (z ∈ s ↔ z.1 ∈ U ∧ z.2 = g z.1))
    (x₀ : s) :
    OpenPartialHomeomorph s (EuclideanHalfSpace 1) := by
  letI : Fact ((0 : ℝ) < 1) := ⟨by norm_num⟩
  exact (actual_local_graph_chart s U V g hU hV hg hshape x₀) ≫ₕ
    IccLeftChart (0 : ℝ) 1

#check actual_left_halfspace_chart
#print axioms actual_left_halfspace_chart

end Nightfall.ProductBUHalfspaceGraphChart
