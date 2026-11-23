import Mathlib

/-!
# A genuine open partial homeomorphism from an exact local zero graph

For a subset s of A × B, suppose an open neighborhood V meets s
exactly in the graph of a function g over an open set U in A, and
g is continuous on U. Then the ACTUAL subset s has a genuine local
open partial homeomorphism with A, via the first coordinate.

This builds real chart data rather than taking a ChartedSpace,
IsManifold or pre-existing local homeomorphism as a hypothesis.

The physical product-sphere zero fiber still needs to instantiate the
graph conditions at its regular interior and time-zero boundary,
and this chart has target A, not yet EuclideanHalfSpace 1.
-/

namespace Nightfall.ProductBULocalGraphChart

open Set

variable {A B : Type*} [TopologicalSpace A] [TopologicalSpace B]

/-- Real parameter domain where the graph stays inside the local
ambient neighborhood V. -/
def graphTarget (U : Set A) (V : Set (A × B)) (g : A → B) : Set A :=
  U ∩ (fun a => (a, g a)) ⁻¹' V

/-- Actual source points in the zero fiber contained in the local
ambient neighborhood V. -/
def graphSource (s : Set (A × B)) (V : Set (A × B)) : Set s :=
  (Subtype.val : s → A × B) ⁻¹' V

/-- A continuous exact graph presentation gives an open chart on the
ACTUAL fiber subtype, not just an immersed parameter curve. -/
noncomputable def actual_local_graph_chart
    (s : Set (A × B))
    (U : Set A) (V : Set (A × B)) (g : A → B)
    (hU : IsOpen U) (hV : IsOpen V)
    (hg : ContinuousOn g U)
    (hshape : ∀ z ∈ V,
      (z ∈ s ↔ z.1 ∈ U ∧ z.2 = g z.1))
    (x₀ : s) : OpenPartialHomeomorph s A := by
  classical
  let S : Set s := graphSource s V
  let T : Set A := graphTarget U V g
  have hSopen : IsOpen S := hV.preimage continuous_subtype_val
  have hgraphOn : ContinuousOn (fun a : A => (a, g a)) U :=
    continuousOn_id.prodMk hg
  have hTopen : IsOpen T := hgraphOn.isOpen_inter_preimage hU hV
  let fromTarget : T → s := fun a =>
    ⟨(a.val, g a.val),
      (hshape (a.val, g a.val) a.2.2).mpr ⟨a.2.1, rfl⟩⟩
  have hTsubset : T ⊆ U := inter_subset_left
  have hgraphT : Continuous (fun a : T => (a.val, g a.val)) := by
    exact (continuousOn_iff_continuous_restrict).mp (hgraphOn.mono hTsubset)
  have hfromTarget : Continuous fromTarget := by
    apply Continuous.subtype_mk
    exact hgraphT
  let inv : A → s := fun a =>
    if ha : a ∈ T then fromTarget ⟨a, ha⟩ else x₀
  have hInvContinuous : ContinuousOn inv T := by
    apply (continuousOn_iff_continuous_domRestrict).mpr
    have heq : (fun a : T => inv a.val) = fromTarget := by
      funext a
      simp [inv, a.2]
    change Continuous (fun a : T => inv a.val)
    rw [heq]
    exact hfromTarget
  have hToContinuous : Continuous (fun z : s => z.val.1) :=
    continuous_fst.comp continuous_subtype_val
  refine {
    toPartialHomeomorph := {
      toPartialEquiv := {
        toFun := fun z => z.val.1
        invFun := inv
        source := S
        target := T
        map_source' := by
          intro x hx
          change x.val ∈ V at hx
          have hsx := (hshape x.val hx).mp x.property
          refine ⟨hsx.1, ?_⟩
          change (x.val.1, g x.val.1) ∈ V
          have hpair : (x.val.1, g x.val.1) = x.val :=
            Prod.ext rfl hsx.2.symm
          rw [hpair]
          exact hx
        map_target' := by
          intro a ha
          change (inv a).val ∈ V
          have hinv : inv a = fromTarget ⟨a, ha⟩ := by
            simp [inv, ha]
          rw [hinv]
          exact ha.2
        left_inv' := by
          intro x hx
          change x.val ∈ V at hx
          have hsx := (hshape x.val hx).mp x.property
          have ht : x.val.1 ∈ T := by
            refine ⟨hsx.1, ?_⟩
            change (x.val.1, g x.val.1) ∈ V
            have hpair : (x.val.1, g x.val.1) = x.val :=
              Prod.ext rfl hsx.2.symm
            rw [hpair]
            exact hx
          change inv x.val.1 = x
          rw [show inv x.val.1 = fromTarget ⟨x.val.1, ht⟩ by simp [inv, ht]]
          apply Subtype.ext
          apply Prod.ext
          · rfl
          · exact hsx.2.symm
        right_inv' := by
          intro a ha
          change (inv a).val.1 = a
          simp [inv, ha, fromTarget]
      }
      continuousOn_toFun := hToContinuous.continuousOn.mono (by intro z hz; trivial)
      continuousOn_invFun := hInvContinuous
    }
    open_source := hSopen
    open_target := hTopen
  }

#check actual_local_graph_chart
#print axioms actual_local_graph_chart

end Nightfall.ProductBULocalGraphChart
