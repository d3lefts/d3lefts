import ProductBUTimeHalfspaceChart
import ProductBUTimeOrientedIFT

/-!
# A *derived* time-zero half-space chart of the actual constrained zero set

This advances the global product-sphere zero-fiber atlas by eliminating
the previously assumed local graph at a time-zero zero. Starting from
the smooth augmented equation and the invertible *spatial derivative*,
the pinned implicit-function theorem supplies its actual graph on a
neighborhood. Restricting that neighborhood to the genuine closed time
slab, the checked local-graph chart gives an OpenPartialHomeomorph into
EuclideanHalfSpace 1 with the actual base zero in its source.

This is an endpoint local theorem, not the global atlas or ProductSphereZero.
Interior turning points still require adapted linear splitting, and
C-infinity chart overlaps remain to be established.
-/

open scoped Topology Manifold ContDiff
open Manifold

namespace Nightfall.ProductBUTimeZeroFromIFT

open Nightfall.ProductBUTimeHalfspaceChart
open Nightfall.ProductBUTimeOrientedIFT

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
  [CompleteSpace E]

/-- The exact constrained zero set of the augmented equation on the
physical time slab, with no assumed regularity or atlas. -/
def actualSlabZero (F : ℝ × E → E) : Set (TimeSlab × E) :=
  {z | F (z.1.val, z.2) = 0}

/-- Every spatially regular time-zero root of a smooth augmented
equation has an actual local open half-space chart containing it.
Neither an exact graph nor a half-space chart is an input. -/
theorem exists_actual_time_zero_halfspace_chart
    (F : ℝ × E → E) (x₀ : E)
    (hF : ContDiffAt ℝ (∞ : ℕ∞ω) F ((0 : ℝ), x₀))
    (hzero : F (0, x₀) = 0)
    (hspatial : (fderiv ℝ F ((0 : ℝ), x₀) ∘L
      ContinuousLinearMap.inr ℝ ℝ E).IsInvertible) :
    ∃ chart : OpenPartialHomeomorph
      (actualSlabZero F) (EuclideanHalfSpace 1),
      (⟨((⟨0, by norm_num⟩ : TimeSlab), x₀), hzero⟩ :
        actualSlabZero F) ∈ chart.source := by
  classical
  obtain ⟨g, hg0, hgAt, hgraph⟩ :=
    exists_time_oriented_zero_graph F 0 x₀ hF hzero hspatial
  have hgAt1 : ContDiffAt ℝ 1 g 0 := hgAt.of_le (by norm_num)
  obtain ⟨T, hT, hgT⟩ := hgAt1.contDiffOn (m := 1) le_rfl (by simp)
  obtain ⟨U, hUT, hUopen, h0U⟩ := mem_nhds_iff.mp hT
  have hgCont : ContinuousOn g U :=
    hgT.continuousOn.mono hUT
  obtain ⟨W, hW, hWopen, h0W⟩ := eventually_nhds_iff.mp hgraph
  let gSlab : TimeSlab → E := fun t => g t.val
  let Uslab : Set TimeSlab :=
    (Subtype.val : TimeSlab → ℝ) ⁻¹' U
  let emb : TimeSlab × E → ℝ × E :=
    fun z => (z.1.val, z.2)
  let V : Set (TimeSlab × E) :=
    emb ⁻¹' W ∩ (Prod.fst : TimeSlab × E → TimeSlab) ⁻¹' Uslab
  have hUslab : IsOpen Uslab := hUopen.preimage continuous_subtype_val
  have hemb : Continuous emb :=
    (continuous_subtype_val.comp continuous_fst).prodMk continuous_snd
  have hV : IsOpen V :=
    (hWopen.preimage hemb).inter (hUslab.preimage continuous_fst)
  have hgSlab : ContinuousOn gSlab Uslab := by
    apply hgCont.comp (continuous_subtype_val.continuousOn)
    intro t ht
    exact ht
  have hshape : ∀ z ∈ V,
      (z ∈ actualSlabZero F ↔ z.1 ∈ Uslab ∧ z.2 = gSlab z.1) := by
    intro z hz
    have hw : F (z.1.val, z.2) = 0 ↔ z.2 = g z.1.val :=
      hW (emb z) hz.1
    constructor
    · intro h
      exact ⟨hz.2, hw.mp h⟩
    · intro h
      exact hw.mpr h.2
  let p₀ : actualSlabZero F :=
    ⟨((⟨0, by norm_num⟩ : TimeSlab), x₀), hzero⟩
  have hpV : p₀.val ∈ V := by
    constructor
    · exact h0W
    · exact h0U
  letI : Fact ((0 : ℝ) < 1) := ⟨by norm_num⟩
  let baseChart :=
    Nightfall.ProductBULocalGraphChart.actual_local_graph_chart
      (actualSlabZero F) Uslab V gSlab hUslab hV hgSlab
      hshape p₀
  let chart : OpenPartialHomeomorph
      (actualSlabZero F) (EuclideanHalfSpace 1) :=
    baseChart.trans (IccLeftChart (0 : ℝ) 1)
  refine ⟨chart, ?_⟩
  change p₀ ∈ baseChart.source ∧
    baseChart p₀ ∈ (IccLeftChart (0 : ℝ) 1).source
  constructor
  · exact hpV
  · change (0 : ℝ) < 1
    norm_num

#check exists_actual_time_zero_halfspace_chart
#print axioms exists_actual_time_zero_halfspace_chart

end Nightfall.ProductBUTimeZeroFromIFT
