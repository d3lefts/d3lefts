import InfinitePiQ2CellLabelProjection

/-!
# Finite source-cell linear combinations have a single exact label projection

The finite-cell algebra is L² dense under the actual original infinite
product. It is insufficient to know that each individual indicator has
some finite-label projection: all indicators in an arbitrary finite sum
need a *common* finite test-label sigma algebra.

This module constructs that common genuine original-source projection
and proves that it fixes every finite linear combination of original
source-cell indicators. No finite Q2 inequality or density of these
projections is assumed. The subsequent closure-to-all-L² operator
statement remains a separate theorem.
-/

namespace Nightfall.InfinitePiQ2CellSpanProjection

open MeasureTheory
open Nightfall.InfinitePiQ2Density
open Nightfall.InfinitePiQ2FiniteCellDensity
open Nightfall.InfinitePiQ2FiniteBooleanTestFactor
open Nightfall.InfinitePiQ2FiniteTestLabelRealization
open Nightfall.InfinitePiQ2InactiveFiniteLabel
open Nightfall.InfinitePiQ2CellLabelProjection

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- A finite real linear combination of exact original-source
Boolean-cell indicators is fixed by ONE actual finite-label
conditional expectation. Its index set can be empty; zero cells
and uncountable original index sets are admitted. -/
theorem sourceFiniteCellSum_fixed_by_one_finite_label
    (S : Finset (Set ((i : ι) → X i)))
    (hS : ∀ s ∈ S, s ∈ sourceFiniteCellAlgebra (X := X))
    (c : Set ((i : ι) → X i) → ℝ) :
    ∃ F : Finset ι, ∃ T : Finset (CoordinateTest (X := X)),
      (condExpL2 ℝ ℝ
        ((sourceFiniteLabelSigma_le_coordinate F
          (fun i => sourceTestLabel T i)
          (fun i => sourceTestLabel_measurable T i)).trans
          (sourceFiniteCoordinateSigma_le (X := X) F))
        (∑ s : S, sourceCellIndicator μ s.1 (hS s.1 s.2) (c s.1)) :
          Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) =
       ∑ s : S, sourceCellIndicator μ s.1 (hS s.1 s.2) (c s.1) := by
  classical
  obtain ⟨F, T, hmeas⟩ :=
    finiteFamily_sourceCells_measurable_in_site_labels S hS
  refine ⟨F, T, ?_⟩
  let hle :=
    (sourceFiniteLabelSigma_le_coordinate F
      (fun i => sourceTestLabel T i)
      (fun i => sourceTestLabel_measurable T i)).trans
      (sourceFiniteCoordinateSigma_le (X := X) F)
  change
      (condExpL2 ℝ ℝ hle
        (∑ s : S, sourceCellIndicator μ s.1 (hS s.1 s.2) (c s.1)) :
          Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) =
        ∑ s : S, sourceCellIndicator μ s.1 (hS s.1 s.2) (c s.1)
  simp only [map_sum, Submodule.coe_sum]
  apply Finset.sum_congr rfl
  intro s hs
  exact (condExpL2_indicator_of_measurable hle
    (hmeas s.1 s.2)
    (measure_ne_top (Measure.infinitePi μ) s.1) (c s.1))

#print axioms Nightfall.InfinitePiQ2CellSpanProjection.sourceFiniteCellSum_fixed_by_one_finite_label

end Nightfall.InfinitePiQ2CellSpanProjection
