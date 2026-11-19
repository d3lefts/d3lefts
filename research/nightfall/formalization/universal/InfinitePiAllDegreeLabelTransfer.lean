import InfinitePiQ2OriginalLabelResidualTransfer
import InfinitePiQ2RangeProjectionTransfer
import Mathlib

/-!
# All-degree source residual transfer through genuine finite-label averaging

This generalizes the triple-residual Hilbert transfer of
`InfinitePiQ2RangeProjectionTransfer` to **every finite ordered word**
of source coordinates. The generic result is an exact identity, not an
estimate or a reduction that grows with degree. The original-source
instantiation uses the actual infinitePi law, literal label pushforward,
and the all-L² heat-bath intertwining already proved in this repository.

Scope: preservation of genuine source L² residual degree by finite-label
conditional averaging. The remaining independent gate for NF-PS-FINITE
is converting the supported finite-label ANOVA degree of the table into
`RowBound.HasProdDegreeLE` on its common tagged alphabet. No all-degree
infinite-product influence theorem is claimed in this file.
-/

namespace Nightfall.InfinitePiAllDegreeLabelTransfer

open MeasureTheory
open Nightfall.InfinitePiQ2InfluenceStability
open Nightfall.InfinitePiQ2OriginalLabelTransport
open Nightfall.InfinitePiQ2GenuineLabelIsometry
open Nightfall.InfinitePiQ2AllL2LabelIntertwining
open Nightfall.InfinitePiQ2AdjointTransfer
open Nightfall.InfinitePiQ2RangeProjectionTransfer
open Nightfall.InfinitePiQ2OriginalLabelResidualTransfer

section Abstract

variable {H K : Type*}
variable [NormedAddCommGroup H] [InnerProductSpace ℝ H] [CompleteSpace H]
variable [NormedAddCommGroup K] [InnerProductSpace ℝ K] [CompleteSpace K]

/-- Ordered finite residual word; repeated coordinates are allowed.
Distinctness belongs to the intended degree predicate, not this identity. -/
noncomputable def iterResidual {ι : Type*}
    (E : ι → K →L[ℝ] K) : List ι → K → K
  | [], f => f
  | i :: rest, f => residual (E i) (iterResidual E rest f)

/-- Every ordered residual word commutes exactly with the genuine
orthogonal label-range projection, provided the *per-coordinate*
self-adjoint intertwining is certified. This subsumes the three-site
transfer, without fixing the polynomial degree in advance. -/
theorem iterResidual_labelRangeProjection
    {ι : Type*} (U : H →ₗᵢ[ℝ] K)
    (Etable : ι → H →L[ℝ] H)
    (Esource : ι → K →L[ℝ] K)
    (hT : ∀ i, (Etable i).adjoint = Etable i)
    (hS : ∀ i, (Esource i).adjoint = Esource i)
    (hI : ∀ i, Esource i ∘L U.toContinuousLinearMap =
      U.toContinuousLinearMap ∘L Etable i)
    (sites : List ι) (f : K) :
    iterResidual Esource sites (labelRangeProjection U f) =
      labelRangeProjection U (iterResidual Esource sites f) := by
  induction sites with
  | nil => rfl
  | cons i rest ih =>
      change residual (Esource i)
        (iterResidual Esource rest (labelRangeProjection U f)) =
        labelRangeProjection U
          (residual (Esource i) (iterResidual Esource rest f))
      rw [ih]
      exact labelRangeProjection_residual U (Etable i) (Esource i)
        (hT i) (hS i) (hI i) (iterResidual Esource rest f)

/-- The all-degree zero-residual predicate survives label averaging.
The conclusion is an actual equality in Hilbert space. -/
theorem iterResidual_zero_after_labelRangeProjection
    {ι : Type*} (U : H →ₗᵢ[ℝ] K)
    (Etable : ι → H →L[ℝ] H)
    (Esource : ι → K →L[ℝ] K)
    (hT : ∀ i, (Etable i).adjoint = Etable i)
    (hS : ∀ i, (Esource i).adjoint = Esource i)
    (hI : ∀ i, Esource i ∘L U.toContinuousLinearMap =
      U.toContinuousLinearMap ∘L Etable i)
    (sites : List ι) (f : K)
    (hf : iterResidual Esource sites f = 0) :
    iterResidual Esource sites (labelRangeProjection U f) = 0 := by
  rw [iterResidual_labelRangeProjection U Etable Esource hT hS hI sites f, hf]
  exact map_zero (labelRangeProjection U)


/-- Exact all-degree transfer into the *finite label table itself*.
The adjoint of the genuine source-to-label L² isometry is conditional
cell averaging; this identity replaces the old degree-two-only triple
adjoint theorem with an arbitrary residual word. -/
theorem iterResidual_labelAdjoint
    {ι : Type*} (U : H →ₗᵢ[ℝ] K)
    (Etable : ι → H →L[ℝ] H)
    (Esource : ι → K →L[ℝ] K)
    (hT : ∀ i, (Etable i).adjoint = Etable i)
    (hS : ∀ i, (Esource i).adjoint = Esource i)
    (hI : ∀ i, Esource i ∘L U.toContinuousLinearMap =
      U.toContinuousLinearMap ∘L Etable i)
    (sites : List ι) (f : K) :
    iterResidual Etable sites (U.toContinuousLinearMap.adjoint f) =
      U.toContinuousLinearMap.adjoint (iterResidual Esource sites f) := by
  induction sites with
  | nil => rfl
  | cons i rest ih =>
      change residual (Etable i)
        (iterResidual Etable rest (U.toContinuousLinearMap.adjoint f)) =
        U.toContinuousLinearMap.adjoint
          (residual (Esource i) (iterResidual Esource rest f))
      rw [ih]
      exact isometryAdjoint_residual U (Etable i) (Esource i)
        (hT i) (hS i) (hI i) (iterResidual Esource rest f)

/-- If a source residual word vanishes, the corresponding finite-label
table residual word vanishes, with no d-dependent loss. -/
theorem iterResidual_labelAdjoint_zero
    {ι : Type*} (U : H →ₗᵢ[ℝ] K)
    (Etable : ι → H →L[ℝ] H)
    (Esource : ι → K →L[ℝ] K)
    (hT : ∀ i, (Etable i).adjoint = Etable i)
    (hS : ∀ i, (Esource i).adjoint = Esource i)
    (hI : ∀ i, Esource i ∘L U.toContinuousLinearMap =
      U.toContinuousLinearMap ∘L Etable i)
    (sites : List ι) (f : K)
    (hf : iterResidual Esource sites f = 0) :
    iterResidual Etable sites (U.toContinuousLinearMap.adjoint f) = 0 := by
  rw [iterResidual_labelAdjoint U Etable Esource hT hS hI sites f, hf]
  exact map_zero U.toContinuousLinearMap.adjoint

end Abstract

section OriginalSource

universe u v w
variable {ι : Type u} {X : ι → Type v} {Y : ι → Type w}
variable [∀ i, MeasurableSpace (X i)] [∀ i, MeasurableSpace (Y i)]
variable [∀ i, MeasurableSingletonClass (Y i)]
variable [DecidableEq ι]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- Ordered residual on the actual source product L² space. -/
noncomputable def sourceIterResidual
    (μ : (i : ι) → Measure (X i)) [∀ i, IsProbabilityMeasure (μ i)] :
    List ι →
      Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) →
      Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)
  | [], f => f
  | i :: rest, f =>
      sourceCoordinateResidual μ i (sourceIterResidual μ rest f)

/-- The abstract operator representation coincides exactly with the
existing native source-coordinate residual operator. -/
theorem iterResidual_eq_source (sites : List ι)
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    iterResidual (sourceOtherProjectionCLM μ) sites f =
      sourceIterResidual μ sites f := by
  induction sites with
  | nil => rfl
  | cons i rest ih =>
      change residual (sourceOtherProjectionCLM μ i)
        (iterResidual (sourceOtherProjectionCLM μ) rest f) =
        sourceCoordinateResidual μ i (sourceIterResidual μ rest f)
      rw [ih]
      rfl

/-- **Actual-law all-degree finite-label transfer.** For every finite
word of coordinates (hence in particular for each distinct word of
length d+1), finite-label conditional averaging commutes with the
genuine original source L² residual word. No lower atom bound, finite
index-set hypothesis, or caller-provided intertwining is introduced. -/
theorem original_source_label_all_degree
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    [∀ i, Fintype (Y i)] [∀ i, DecidableEq (Y i)]
    (sites : List ι)
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    sourceIterResidual μ sites
        (labelRangeProjection (original_infinite_label_lift μ φ hφ) f) =
      labelRangeProjection (original_infinite_label_lift μ φ hφ)
        (sourceIterResidual μ sites f) := by
  let q : (i : ι) → Measure (Y i) := fun i => (μ i).map (φ i)
  have hT : ∀ i, (sourceOtherProjectionCLM q i).adjoint =
      sourceOtherProjectionCLM q i :=
    fun i => sourceOtherProjectionCLM_selfAdjoint q i
  have hS : ∀ i, (sourceOtherProjectionCLM μ i).adjoint =
      sourceOtherProjectionCLM μ i :=
    fun i => sourceOtherProjectionCLM_selfAdjoint μ i
  have hI : ∀ i, sourceOtherProjectionCLM μ i ∘L
      (original_infinite_label_lift μ φ hφ).toContinuousLinearMap =
      (original_infinite_label_lift μ φ hφ).toContinuousLinearMap ∘L
        sourceOtherProjectionCLM q i :=
    fun i => sourceOtherProjectionCLM_intertwines_all_L2 μ φ hφ i
  have htransfer :=
    iterResidual_labelRangeProjection
      (original_infinite_label_lift μ φ hφ)
      (fun i => sourceOtherProjectionCLM q i)
      (fun i => sourceOtherProjectionCLM μ i)
      hT hS hI sites f
  calc
    sourceIterResidual μ sites
        (labelRangeProjection (original_infinite_label_lift μ φ hφ) f) =
      iterResidual (sourceOtherProjectionCLM μ) sites
        (labelRangeProjection (original_infinite_label_lift μ φ hφ) f) :=
          (iterResidual_eq_source μ sites _).symm
    _ = labelRangeProjection (original_infinite_label_lift μ φ hφ)
          (iterResidual (sourceOtherProjectionCLM μ) sites f) := htransfer
    _ = labelRangeProjection (original_infinite_label_lift μ φ hφ)
          (sourceIterResidual μ sites f) := by
            rw [iterResidual_eq_source μ sites f]

/-- The genuine infinite-product source degree-d zero-residual
hypothesis is preserved at every finite-label resolution, for every
ordered word, including all pairwise-distinct (d+1)-words. -/
theorem original_source_label_all_degree_zero
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    [∀ i, Fintype (Y i)] [∀ i, DecidableEq (Y i)]
    (sites : List ι)
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (hf : sourceIterResidual μ sites f = 0) :
    sourceIterResidual μ sites
        (labelRangeProjection (original_infinite_label_lift μ φ hφ) f) = 0 := by
  rw [original_source_label_all_degree μ φ hφ sites f, hf]
  exact map_zero (labelRangeProjection (original_infinite_label_lift μ φ hφ))


/-- **Actual finite-cell average theorem, arbitrary degree.**
For the literal pushforward product law q, the cell-averaged table
U† f has its entire iterated table residual equal to U† of the original
source iterated residual. Thus any zero (d+1)-word is inherited with
exactly the same d. -/
theorem original_cell_average_all_degree
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    [∀ i, Fintype (Y i)] [∀ i, DecidableEq (Y i)]
    (sites : List ι)
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    iterResidual
        (sourceOtherProjectionCLM (fun i => (μ i).map (φ i))) sites
        ((original_infinite_label_lift μ φ hφ).toContinuousLinearMap.adjoint f) =
      (original_infinite_label_lift μ φ hφ).toContinuousLinearMap.adjoint
        (sourceIterResidual μ sites f) := by
  let q : (i : ι) → Measure (Y i) := fun i => (μ i).map (φ i)
  have hT : ∀ i, (sourceOtherProjectionCLM q i).adjoint =
      sourceOtherProjectionCLM q i :=
    fun i => sourceOtherProjectionCLM_selfAdjoint q i
  have hS : ∀ i, (sourceOtherProjectionCLM μ i).adjoint =
      sourceOtherProjectionCLM μ i :=
    fun i => sourceOtherProjectionCLM_selfAdjoint μ i
  have hI : ∀ i, sourceOtherProjectionCLM μ i ∘L
      (original_infinite_label_lift μ φ hφ).toContinuousLinearMap =
      (original_infinite_label_lift μ φ hφ).toContinuousLinearMap ∘L
        sourceOtherProjectionCLM q i :=
    fun i => sourceOtherProjectionCLM_intertwines_all_L2 μ φ hφ i
  have htransfer :=
    iterResidual_labelAdjoint
      (original_infinite_label_lift μ φ hφ)
      (fun i => sourceOtherProjectionCLM q i)
      (fun i => sourceOtherProjectionCLM μ i)
      hT hS hI sites f
  calc
    iterResidual (sourceOtherProjectionCLM q) sites
        ((original_infinite_label_lift μ φ hφ).toContinuousLinearMap.adjoint f) =
      (original_infinite_label_lift μ φ hφ).toContinuousLinearMap.adjoint
        (iterResidual (sourceOtherProjectionCLM μ) sites f) := htransfer
    _ = (original_infinite_label_lift μ φ hφ).toContinuousLinearMap.adjoint
        (sourceIterResidual μ sites f) := by
          rw [iterResidual_eq_source μ sites f]

/-- Native L² residual-degree preservation for the cell average;
all finite words (particularly distinct lists of length d+1) transfer. -/
theorem original_cell_average_all_degree_zero
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    [∀ i, Fintype (Y i)] [∀ i, DecidableEq (Y i)]
    (sites : List ι)
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (hf : sourceIterResidual μ sites f = 0) :
    iterResidual
        (sourceOtherProjectionCLM (fun i => (μ i).map (φ i))) sites
        ((original_infinite_label_lift μ φ hφ).toContinuousLinearMap.adjoint f) = 0 := by
  rw [original_cell_average_all_degree μ φ hφ sites f, hf]
  exact map_zero (original_infinite_label_lift μ φ hφ).toContinuousLinearMap.adjoint

end OriginalSource

#print axioms Nightfall.InfinitePiAllDegreeLabelTransfer.iterResidual_labelRangeProjection
#print axioms Nightfall.InfinitePiAllDegreeLabelTransfer.iterResidual_zero_after_labelRangeProjection
#print axioms Nightfall.InfinitePiAllDegreeLabelTransfer.iterResidual_labelAdjoint
#print axioms Nightfall.InfinitePiAllDegreeLabelTransfer.iterResidual_labelAdjoint_zero
#print axioms Nightfall.InfinitePiAllDegreeLabelTransfer.iterResidual_eq_source
#print axioms Nightfall.InfinitePiAllDegreeLabelTransfer.original_source_label_all_degree
#print axioms Nightfall.InfinitePiAllDegreeLabelTransfer.original_source_label_all_degree_zero
#print axioms Nightfall.InfinitePiAllDegreeLabelTransfer.original_cell_average_all_degree
#print axioms Nightfall.InfinitePiAllDegreeLabelTransfer.original_cell_average_all_degree_zero

end Nightfall.InfinitePiAllDegreeLabelTransfer
