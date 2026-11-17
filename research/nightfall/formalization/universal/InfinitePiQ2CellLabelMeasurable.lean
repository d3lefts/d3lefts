import InfinitePiQ2FiniteTestSiteLabels
import InfinitePiQ2InactiveFiniteLabel

/-!
# Every original finite Boolean source cell is genuinely finite-label measurable

This is the source-specific L² density-to-finite-table representation gate.
Every original-product source-cell event has finite per-coordinate labels
whose actual source pullback sigma algebra contains that event. Therefore
the genuine Hilbert conditional expectation onto those labels fixes its
source L² indicator. No conditional projection, density, or identity oracle
is given by the caller.
-/

namespace Nightfall.InfinitePiQ2CellLabelMeasurable

open MeasureTheory
open Nightfall.InfinitePiQ2FiniteCellDensity
open Nightfall.InfinitePiQ2FiniteBooleanTestFactor
open Nightfall.InfinitePiQ2FiniteTestSiteLabels
open Nightfall.InfinitePiQ2InactiveFiniteLabel
open Nightfall.InfinitePiQ2Density
open Nightfall.InfinitePiQ2OriginalLabelTransport

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]

/-- Every original finite Boolean source-cell event belongs to the
pulled-back sigma algebra of finite labels on a finite set of actual
original source coordinates. The alphabet is T→Bool for a finite T. -/
theorem sourceCell_measurable_in_finite_site_labels
    (s : Set ((i : ι) → X i))
    (hs : s ∈ sourceFiniteCellAlgebra (X := X)) :
    ∃ F : Finset ι, ∃ T : Finset (CoordinateTest (X := X)),
      @MeasurableSet ((i : ι) → X i)
        (sourceFiniteLabelSigma (X := X) F
          (siteTestLabelFamily T)) s := by
  classical
  obtain ⟨F, T, U, hU⟩ :=
    sourceFiniteCellAlgebra_factors_through_finite_site_labels s hs
  have hmeas : MeasurableSet U :=
    (Set.toFinite U).measurableSet
  have hset :
      s =
        (fun x : (i : ι) → X i =>
          F.restrict (sourceLabelMap (siteTestLabelFamily T) x)) ⁻¹' U := by
    ext x
    change x ∈ s ↔ (fun j : F => siteTestLabel T j (x j)) ∈ U
    exact hU x
  refine ⟨F, T, ?_⟩
  change @MeasurableSet ((i : ι) → X i)
    (MeasurableSpace.comap
      (fun x : (i : ι) → X i =>
        F.restrict (sourceLabelMap (siteTestLabelFamily T) x))
      (inferInstance : MeasurableSpace ((j : F) → (T → Bool)))) s
  rw [hset]
  exact ⟨U, hmeas, rfl⟩

variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- The ACTUAL original-law L² conditional projection onto finite site
labels fixes every indicator of the original finite Boolean source-cell
algebra. This is a genuine Mathlib condExpL2 identity, not an assumed
finite-cell approximation hypothesis. -/
theorem sourceCellIndicator_fixed_by_finite_site_labels
    (s : Set ((i : ι) → X i))
    (hs : s ∈ sourceFiniteCellAlgebra (X := X))
    (c : ℝ) :
    ∃ F : Finset ι, ∃ T : Finset (CoordinateTest (X := X)),
      (condExpL2 ℝ ℝ
        ((sourceFiniteLabelSigma_le_coordinate F
          (siteTestLabelFamily T) (siteTestLabelFamily_measurable T)).trans
          (sourceFiniteCoordinateSigma_le (X := X) F))
        (sourceCellIndicator μ s hs c) :
          Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) =
      sourceCellIndicator μ s hs c := by
  classical
  obtain ⟨F, T, hmeas⟩ :=
    sourceCell_measurable_in_finite_site_labels s hs
  refine ⟨F, T, ?_⟩
  simpa only [sourceCellIndicator] using
    (condExpL2_indicator_of_measurable
      ((sourceFiniteLabelSigma_le_coordinate F
          (siteTestLabelFamily T) (siteTestLabelFamily_measurable T)).trans
        (sourceFiniteCoordinateSigma_le (X := X) F))
      hmeas
      (measure_ne_top (Measure.infinitePi μ) s) c)

#print axioms Nightfall.InfinitePiQ2CellLabelMeasurable.sourceCell_measurable_in_finite_site_labels
#print axioms Nightfall.InfinitePiQ2CellLabelMeasurable.sourceCellIndicator_fixed_by_finite_site_labels

end Nightfall.InfinitePiQ2CellLabelMeasurable
