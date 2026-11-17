import InfinitePiQ2FiniteTestLabelRealization
import InfinitePiQ2InactiveFiniteLabel

/-!
# Common original-product finite-label L² measurability for finite cells

This uses the already developed actual source Boolean-test realization,
not a second implementation of finite-coordinate labels. Every finite
family of original finite Boolean-cell events is measurable under ONE
genuine original-source finite-label sub-sigma algebra. Thus its source
L² indicators are fixed by the corresponding actual condExpL2
orthogonal projection. No finite-density, projection, or law hypothesis
is supplied by the theorem caller.
-/

namespace Nightfall.InfinitePiQ2CellLabelProjection

open MeasureTheory
open Nightfall.InfinitePiQ2Density
open Nightfall.InfinitePiQ2FiniteCellDensity
open Nightfall.InfinitePiQ2FiniteBooleanTestFactor
open Nightfall.InfinitePiQ2FiniteTestLabelRealization
open Nightfall.InfinitePiQ2OriginalLabelTransport
open Nightfall.InfinitePiQ2InactiveFiniteLabel

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]

/-- A finite family of original-product Boolean-cell events is
simultaneously measurable in a common finite-source-coordinate
finite-label sigma algebra, whose law is the actual original
pushforward marginal product. -/
theorem finiteFamily_sourceCells_measurable_in_site_labels
    (S : Finset (Set ((i : ι) → X i)))
    (hS : ∀ s ∈ S, s ∈ sourceFiniteCellAlgebra (X := X)) :
    ∃ F : Finset ι, ∃ T : Finset (CoordinateTest (X := X)),
      ∀ s ∈ S, @MeasurableSet ((i : ι) → X i)
        (sourceFiniteLabelSigma (X := X) F
          (fun i => sourceTestLabel T i)) s := by
  classical
  obtain ⟨T, hT⟩ := finiteFamily_sourceCells_factor_finiteLabel S hS
  let F : Finset ι := sourceTestSupport T
  refine ⟨F, T, ?_⟩
  intro s hs
  obtain ⟨U, hU⟩ := hT s hs
  let V : Set ((j : F) → (T → Bool)) :=
    {w | readSourceTests T w ∈ U}
  have hV : MeasurableSet V := (Set.toFinite V).measurableSet
  have heq :
      s =
        (fun x : (i : ι) → X i =>
          F.restrict (sourceLabelMap (fun i => sourceTestLabel T i) x)) ⁻¹' V := by
    ext x
    exact hU x
  change @MeasurableSet ((i : ι) → X i)
    (MeasurableSpace.comap
      (fun x : (i : ι) → X i =>
        F.restrict (sourceLabelMap (fun i => sourceTestLabel T i) x))
      (inferInstance : MeasurableSpace ((j : F) → (T → Bool)))) s
  rw [heq]
  exact ⟨V, hV, rfl⟩

/-- In particular every individual event in the original finite-cell
algebra belongs to a genuine finite site-label sigma algebra. -/
theorem sourceCell_measurable_in_finite_site_labels
    (s : Set ((i : ι) → X i))
    (hs : s ∈ sourceFiniteCellAlgebra (X := X)) :
    ∃ F : Finset ι, ∃ T : Finset (CoordinateTest (X := X)),
      @MeasurableSet ((i : ι) → X i)
        (sourceFiniteLabelSigma (X := X) F
          (fun i => sourceTestLabel T i)) s := by
  classical
  have hS : ∀ t ∈ ({s} : Finset (Set ((i : ι) → X i))),
      t ∈ sourceFiniteCellAlgebra (X := X) := by
    intro t ht
    have heq : t = s := Finset.mem_singleton.mp ht
    simpa [heq] using hs
  obtain ⟨F, T, h⟩ :=
    finiteFamily_sourceCells_measurable_in_site_labels
      (S := ({s} : Finset (Set ((i : ι) → X i)))) hS
  exact ⟨F, T, h s (Finset.mem_singleton_self s)⟩

variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- The actual original product L² projection onto source-finite
labels fixes every original-source finite-cell indicator exactly.
No source substitution, label law postulate, or conditional-expectation
identity hypothesis. -/
theorem sourceCellIndicator_fixed_by_finite_site_labels
    (s : Set ((i : ι) → X i))
    (hs : s ∈ sourceFiniteCellAlgebra (X := X))
    (c : ℝ) :
    ∃ F : Finset ι, ∃ T : Finset (CoordinateTest (X := X)),
      (condExpL2 ℝ ℝ
        ((sourceFiniteLabelSigma_le_coordinate F
          (fun i => sourceTestLabel T i)
          (fun i => sourceTestLabel_measurable T i)).trans
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
          (fun i => sourceTestLabel T i)
          (fun i => sourceTestLabel_measurable T i)).trans
        (sourceFiniteCoordinateSigma_le (X := X) F))
      hmeas (measure_ne_top (Measure.infinitePi μ) s) c)

#print axioms Nightfall.InfinitePiQ2CellLabelProjection.finiteFamily_sourceCells_measurable_in_site_labels
#print axioms Nightfall.InfinitePiQ2CellLabelProjection.sourceCell_measurable_in_finite_site_labels
#print axioms Nightfall.InfinitePiQ2CellLabelProjection.sourceCellIndicator_fixed_by_finite_site_labels

end Nightfall.InfinitePiQ2CellLabelProjection
