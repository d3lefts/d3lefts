import ProductBULocalGraphChart
import Mathlib.Geometry.Manifold.Instances.Real

/-!
# Genuine half-space boundary chart on a time-restricted zero graph

The local chart constructed in ProductBULocalGraphChart has target A,
which is not automatically a manifold-with-boundary model space.

For a time-oriented graph on the ACTUAL fiber subtype represented in
(Set.Icc 0 1) × E, compose this genuine chart with Mathlib's genuine
left endpoint chart IccLeftChart 0 1.  This yields an actual
OpenPartialHomeomorph to EuclideanHalfSpace 1, not an assumed
ChartedSpace/IsManifold instance or an abstract local immersion.

This operator handles time-zero endpoint neighborhoods when supplied
with an exact continuous graph and its local open neighborhood.
The zero-fiber domain still must be identified with the physical
augmented product-sphere zero set; an interior regular chart and
global covering/overlap conditions are separate obligations.

Sources: Mathlib.Geometry.Manifold.Instances.Real,
Nightfall.ProductBULocalGraphChart from #1139.
-/

open scoped Topology Manifold ContDiff
open Manifold

namespace Nightfall.ProductBUTimeHalfspaceChart

variable {E : Type*} [TopologicalSpace E]

abbrev TimeSlab := Set.Icc (0 : ℝ) 1

/-- The concrete half-space coordinate change from an exact
time-graph chart on an actual time-restricted fiber subtype.
At the time-zero face, the canonical left interval chart has
target boundary coordinate 0; away from t=1 it preserves the
topology inherited from the time-slab subtype. -/
noncomputable def actual_time_graph_halfspace_chart
    (s : Set (TimeSlab × E))
    (U : Set TimeSlab)
    (V : Set (TimeSlab × E))
    (g : TimeSlab → E)
    (hU : IsOpen U) (hV : IsOpen V)
    (hg : ContinuousOn g U)
    (hshape : ∀ z ∈ V,
      (z ∈ s ↔ z.1 ∈ U ∧ z.2 = g z.1))
    (x₀ : s) :
    OpenPartialHomeomorph s (EuclideanHalfSpace 1) := by
  letI : Fact ((0 : ℝ) < 1) := ⟨by norm_num⟩
  exact
    (Nightfall.ProductBULocalGraphChart.actual_local_graph_chart
      s U V g hU hV hg hshape x₀).trans
      (IccLeftChart (0 : ℝ) 1)

#check actual_time_graph_halfspace_chart
#print axioms actual_time_graph_halfspace_chart

end Nightfall.ProductBUTimeHalfspaceChart
