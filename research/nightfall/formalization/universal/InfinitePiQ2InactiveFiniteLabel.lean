import InfinitePiQ2InactiveSourceSigma
import InfinitePiQ2OriginalLabelTransport
import Mathlib

/-!
# Original-source finite-label conditional L² projections fix inactive sites

This is the exact inactive-index branch required by finite-cell
source/table influence transport for arbitrary (including uncountable)
independent-product sources. No assumed heat-bath intertwining, no
countable index, no atom floor, and no substituted label product law.

It extends the already kernel-certified inactive coordinate projection
identity from #712 to arbitrary sub-σ-algebras and actual finite-cell
label σ-algebras, using the nested Hilbert conditional projection
fixpoint of pinned Mathlib.
-/

namespace Nightfall.InfinitePiQ2InactiveFiniteLabel

set_option maxHeartbeats 1200000

open MeasureTheory
open Nightfall.InfinitePiQ2Density
open Nightfall.InfinitePiQ2InfluenceStability
open Nightfall.InfinitePiQ2InactiveSourceSigma
open Nightfall.InfinitePiQ2OriginalLabelTransport

universe u v w
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- Any original-source Hilbert conditional projection onto a σ-algebra
contained in the all-other-sites σ-algebra is unchanged by refreshing i. -/
theorem sourceOtherProjection_fixes_subSigma_projection
    (m : MeasurableSpace ((j : ι) → X j))
    (hm : m ≤ (MeasurableSpace.pi : MeasurableSpace ((j : ι) → X j)))
    (i : ι) (hmi : m ≤ sourceOtherSigma (X := X) i)
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    sourceOtherProjection μ i
      (condExpL2 ℝ ℝ (μ := Measure.infinitePi μ) (m := m) hm f :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) =
      (condExpL2 ℝ ℝ (μ := Measure.infinitePi μ) (m := m) hm f :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) := by
  letI : MeasurableSpace ((j : ι) → X j) := MeasurableSpace.pi
  let g : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) :=
    (condExpL2 ℝ ℝ (μ := Measure.infinitePi μ) (m := m) hm f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
  have hsmall : AEStronglyMeasurable[m]
      (g : ((j : ι) → X j) → ℝ) (Measure.infinitePi μ) := by
    exact aestronglyMeasurable_condExpL2 hm f
  have hlarge : AEStronglyMeasurable[sourceOtherSigma (X := X) i]
      (g : ((j : ι) → X j) → ℝ) (Measure.infinitePi μ) :=
    hsmall.mono hmi
  have hmem : g ∈ lpMeas ℝ ℝ (sourceOtherSigma (X := X) i)
      (2 : ENNReal) (Measure.infinitePi μ) :=
    mem_lpMeas_iff_aestronglyMeasurable.mpr hlarge
  change
    (condExpL2 ℝ ℝ (sourceOtherSigma_le (X := X) i) g :
      Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) = g
  rw [condExpL2]
  haveI : Fact (sourceOtherSigma (X := X) i ≤
      (MeasurableSpace.pi : MeasurableSpace ((j : ι) → X j))) :=
    ⟨sourceOtherSigma_le (X := X) i⟩
  let gg : lpMeas ℝ ℝ (sourceOtherSigma (X := X) i)
      (2 : ENNReal) (Measure.infinitePi μ) := ⟨g, hmem⟩
  have h_coe_gg :
      (gg : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) = g := rfl
  have hfix := Submodule.orthogonalProjectionOnto_mem_subspace_eq_self gg
  rw [← h_coe_gg, hfix]

variable {Y : ι → Type w} [∀ j, MeasurableSpace (Y j)]

/-- Genuine finite-coordinate cell σ-algebra on the ORIGINAL source word. -/
def sourceFiniteLabelSigma (F : Finset ι)
    (φ : ∀ j, X j → Y j) :
    MeasurableSpace ((j : ι) → X j) :=
  MeasurableSpace.comap
    (fun x : (j : ι) → X j => F.restrict (sourceLabelMap φ x))
    (inferInstance : MeasurableSpace ((j : F) → Y j))

/-- Every finite cell label is measurable from its underlying original
finite set of source coordinates. This holds with arbitrary source types
and finite-label types, including cells with zero probability. -/
theorem sourceFiniteLabelSigma_le_coordinate
    (F : Finset ι) (φ : ∀ j, X j → Y j)
    (hφ : ∀ j, Measurable (φ j)) :
    sourceFiniteLabelSigma (X := X) F φ ≤
      sourceFiniteCoordinateSigma (X := X) F := by
  have hg : Measurable (fun z : (j : F) → X j =>
      (fun j : F => φ j (z j))) := by
    fun_prop
  unfold sourceFiniteLabelSigma sourceFiniteCoordinateSigma
  refine MeasurableSpace.comap_le_comap_of_eq_comp
    (fun z : (j : F) → X j => (fun j : F => φ j (z j))) hg ?_
  funext x j
  rfl

/-- Cell label information over F never depends on an original source
coordinate outside F. -/
theorem sourceFiniteLabelSigma_le_other_of_not_mem
    (F : Finset ι) (φ : ∀ j, X j → Y j)
    (hφ : ∀ j, Measurable (φ j))
    (i : ι) (hi : i ∉ F) :
    sourceFiniteLabelSigma (X := X) F φ ≤ sourceOtherSigma (X := X) i := by
  exact (sourceFiniteLabelSigma_le_coordinate F φ hφ).trans
    (sourceFiniteCoordinateSigma_le_other_of_not_mem (X := X) F i hi)

/-- For EVERY original source f∈L² and EVERY measurable finite cell
label map, refreshing a site outside F fixes the actual original-law
L² conditional projection onto those finite labels. -/
theorem sourceOtherProjection_fixes_inactive_labelProjection
    (F : Finset ι) (φ : ∀ j, X j → Y j)
    (hφ : ∀ j, Measurable (φ j))
    (i : ι) (hi : i ∉ F)
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    sourceOtherProjection μ i
      (condExpL2 ℝ ℝ
        ((sourceFiniteLabelSigma_le_coordinate F φ hφ).trans
          (sourceFiniteCoordinateSigma_le (X := X) F)) f :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) =
      (condExpL2 ℝ ℝ
        ((sourceFiniteLabelSigma_le_coordinate F φ hφ).trans
          (sourceFiniteCoordinateSigma_le (X := X) F)) f :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) := by
  exact sourceOtherProjection_fixes_subSigma_projection μ
    (sourceFiniteLabelSigma (X := X) F φ)
    ((sourceFiniteLabelSigma_le_coordinate F φ hφ).trans
      (sourceFiniteCoordinateSigma_le (X := X) F))
    i (sourceFiniteLabelSigma_le_other_of_not_mem F φ hφ i hi) f

/-- No source-coordinate influence at all is introduced by a finite
label observation from sites other than i. No limiting argument. -/
theorem sourceCoordinateInfluence_inactive_labelProjection_zero
    (F : Finset ι) (φ : ∀ j, X j → Y j)
    (hφ : ∀ j, Measurable (φ j))
    (i : ι) (hi : i ∉ F)
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    sourceCoordinateInfluence μ i
      (condExpL2 ℝ ℝ
        ((sourceFiniteLabelSigma_le_coordinate F φ hφ).trans
          (sourceFiniteCoordinateSigma_le (X := X) F)) f :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) = 0 := by
  unfold sourceCoordinateInfluence sourceCoordinateResidual
  rw [sourceOtherProjection_fixes_inactive_labelProjection μ F φ hφ i hi f]
  simp

#print axioms Nightfall.InfinitePiQ2InactiveFiniteLabel.sourceOtherProjection_fixes_subSigma_projection
#print axioms Nightfall.InfinitePiQ2InactiveFiniteLabel.sourceFiniteLabelSigma_le_coordinate
#print axioms Nightfall.InfinitePiQ2InactiveFiniteLabel.sourceFiniteLabelSigma_le_other_of_not_mem
#print axioms Nightfall.InfinitePiQ2InactiveFiniteLabel.sourceOtherProjection_fixes_inactive_labelProjection
#print axioms Nightfall.InfinitePiQ2InactiveFiniteLabel.sourceCoordinateInfluence_inactive_labelProjection_zero

end Nightfall.InfinitePiQ2InactiveFiniteLabel
