import InfinitePiQ2OriginalLabelTransport

/-!
# Exact original-source heat-bath intertwining for arbitrary cell labels

For each source coordinate i, refresh it under its ORIGINAL marginal
measure μ i. For the coordinatewise image under measurable labels φ i,
refresh under the genuine pushforward (μ i).map (φ i).

The commuting square E_source U = U E_label is an exact pointwise
identity for every measurable labeled observable g, arbitrary index
sets, arbitrary measurable coordinate spaces, heterogeneous marginals,
and zero-probability cells.

This is the source-specific heat-bath step missing from the generic
adjoint transfer. It does NOT itself identify the integral-based Markov
heat-bath with the conditional L² orthogonal projection, identify the
adjoint with conditional fiber averages, or prove the infinite-product
Q2 terminal.
-/

namespace Nightfall.InfinitePiQ2OriginalHeatBath

open MeasureTheory
open Nightfall.InfinitePiQ2OriginalLabelTransport

universe u v w
variable {ι : Type u} {X : ι → Type v} {Y : ι → Type w}
variable [∀ i, MeasurableSpace (X i)] [∀ i, MeasurableSpace (Y i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- Exact original-product one-site heat-bath, defined from μ i itself. -/
noncomputable def sourceHeatBath (i : ι)
    (f : ((j : ι) → X j) → ℝ)
    (x : (j : ι) → X j) : ℝ :=
  ∫ a, f (Function.update x i a) ∂ μ i

/-- One-site heat-bath on the ACTUAL pushforward coordinate measure. -/
noncomputable def labelHeatBath
    (φ : ∀ i, X i → Y i)
    (i : ι)
    (g : ((j : ι) → Y j) → ℝ)
    (y : (j : ι) → Y j) : ℝ :=
  ∫ b, g (Function.update y i b) ∂ (μ i).map (φ i)

/-- Coordinate label maps strictly commute with refreshing one coordinate. -/
theorem sourceLabelMap_update
    (φ : ∀ i, X i → Y i)
    (i : ι) (a : X i) (x : (j : ι) → X j) :
    sourceLabelMap φ (Function.update x i a) =
      Function.update (sourceLabelMap φ x) i (φ i a) := by
  funext j
  by_cases h : j = i
  · subst j
    simp [sourceLabelMap]
  · simp [sourceLabelMap, Function.update_of_ne h]

/-- The LABEL-SIDE one-coordinate section is measurable, with no
disintegration or atom-positivity assumption. -/
theorem measurable_label_section
    (φ : ∀ i, X i → Y i)
    (g : ((j : ι) → Y j) → ℝ)
    (hg : Measurable g) (i : ι)
    (x : (j : ι) → X j) :
    Measurable (fun b : Y i =>
      g (Function.update (sourceLabelMap φ x) i b)) := by
  have hupdate :
      Measurable (fun b : Y i =>
        Function.update (sourceLabelMap φ x) i b) :=
    measurable_update'.comp (measurable_const.prodMk measurable_id)
  exact hg.comp hupdate

/-- MAIN SOURCE-SPECIFIC INTERTWINING THEOREM.

The original source heat-bath of a lifted measurable label observable
equals the lift of the true finite-label heat-bath. No hypothetical
intertwining premise, alternative source law, positive-cell floor,
countability assumption, or extra variance/influence bound occurs. -/
theorem source_heatBath_intertwines_label
    (φ : ∀ i, X i → Y i)
    (hφ : ∀ i, Measurable (φ i))
    (g : ((j : ι) → Y j) → ℝ) (hg : Measurable g)
    (i : ι) (x : (j : ι) → X j) :
    sourceHeatBath μ i (fun z => g (sourceLabelMap φ z)) x =
      labelHeatBath μ φ i g (sourceLabelMap φ x) := by
  have hG : AEStronglyMeasurable
      (fun b : Y i => g (Function.update (sourceLabelMap φ x) i b))
      ((μ i).map (φ i)) :=
    (measurable_label_section μ φ g hg i x).aestronglyMeasurable
  calc
    sourceHeatBath μ i (fun z => g (sourceLabelMap φ z)) x =
      ∫ a, g (Function.update (sourceLabelMap φ x) i (φ i a)) ∂ μ i := by
        unfold sourceHeatBath
        apply integral_congr_ae
        exact Filter.Eventually.of_forall (fun a => by
          rw [sourceLabelMap_update (φ := φ) i a x])
    _ = ∫ b, g (Function.update (sourceLabelMap φ x) i b)
          ∂ ((μ i).map (φ i)) := by
        exact (integral_map (hφ i).aemeasurable hG).symm
    _ = labelHeatBath μ φ i g (sourceLabelMap φ x) := rfl

/-- Restricting a coordinatewise source label word to a finite set
commutes with the same original-site refresh when the site is in it. -/
theorem restrict_sourceLabelMap_update
    (F : Finset ι)
    (φ : ∀ i, X i → Y i)
    (i : ι) (hi : i ∈ F)
    (a : X i) (x : (j : ι) → X j) :
    F.restrict (sourceLabelMap φ (Function.update x i a)) =
      Function.update (F.restrict (sourceLabelMap φ x))
        (⟨i, hi⟩ : F) (φ i a) := by
  rw [sourceLabelMap_update]
  funext j
  by_cases h : (j : ι) = i
  · have hj : j = (⟨i, hi⟩ : F) := Subtype.ext h
    subst j
    simp
  · have hj : j ≠ (⟨i, hi⟩ : F) := by
      intro heq
      apply h
      exact congrArg Subtype.val heq
    simp [Finset.restrict, Function.update_of_ne h,
      Function.update_of_ne hj]

/-- The finite table uses only finitely many extracted source labels,
not an artificial full-index finite alphabet. -/
noncomputable def finiteLabelHeatBath
    (F : Finset ι)
    (φ : ∀ i, X i → Y i)
    (i : F)
    (g : ((j : F) → Y j) → ℝ)
    (y : (j : F) → Y j) : ℝ :=
  ∫ b, g (Function.update y i b) ∂ (μ i).map (φ i)

/-- Exact heat-bath intertwining on every finite-coordinate label table.
The coordinate is an ACTUAL original coordinate i ∈ F. -/
theorem source_finiteLabel_heatBath_intertwines
    (F : Finset ι)
    (φ : ∀ i, X i → Y i)
    (hφ : ∀ i, Measurable (φ i))
    (g : ((j : F) → Y j) → ℝ) (hg : Measurable g)
    (i : ι) (hi : i ∈ F) (x : (j : ι) → X j) :
    sourceHeatBath μ i
        (fun z => g (F.restrict (sourceLabelMap φ z))) x =
      finiteLabelHeatBath μ F φ (⟨i, hi⟩ : F) g
        (F.restrict (sourceLabelMap φ x)) := by
  let G : ((j : ι) → Y j) → ℝ :=
    fun y => g (F.restrict y)
  have hG : Measurable G :=
    hg.comp (Finset.measurable_restrict F)
  have hmain :=
    source_heatBath_intertwines_label μ φ hφ G hG i x
  change sourceHeatBath μ i (fun z => G (sourceLabelMap φ z)) x =
    labelHeatBath μ φ i G (sourceLabelMap φ x) at hmain
  rw [hmain]
  unfold labelHeatBath finiteLabelHeatBath G
  apply integral_congr_ae
  exact Filter.Eventually.of_forall (fun b => by
    congr 1
    funext j
    by_cases h : (j : ι) = i
    · have hj : j = (⟨i, hi⟩ : F) := Subtype.ext h
      subst j
      simp
    · have hj : j ≠ (⟨i, hi⟩ : F) := by
        intro heq
        exact h (congrArg Subtype.val heq)
      simp [Finset.restrict, Function.update_of_ne h,
        Function.update_of_ne hj])

end Nightfall.InfinitePiQ2OriginalHeatBath
