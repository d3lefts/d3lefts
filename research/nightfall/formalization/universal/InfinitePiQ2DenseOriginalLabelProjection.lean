import InfinitePiQ2CellLabelProjection
import InfinitePiQ2FiniteCellDensity
import Mathlib.LinearAlgebra.Finsupp.LinearCombination

/-!
# Original-product L² density of actual finite-label orthogonal projections

This closes the representation-density step without an approximation
oracle: finite Boolean source-cell indicators are L² dense, finite
linear combinations form the algebraic span, and the same original
source-product finite-label conditional expectation fixes every term
of such a combination. Hilbert contraction then approximates any
original-product L² function to arbitrary precision.

Arbitrary index types (including uncountable), heterogeneous measurable
source alphabets and zero-probability cells are admitted. No replacement
measure or finite Q2 inequality is assumed. Boundedness, quadratic
degree and coordinate influence of the finite-label table are
distinct terminal obligations.
-/

namespace Nightfall.InfinitePiQ2DenseOriginalLabelProjection

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

/-- Every original-product L² observable can be approximated by its
ACTUAL Hilbert conditional expectation onto a finite family of
original-coordinate finite-valued Boolean test labels, with no
countability of the source index or an atom-probability floor. -/
theorem source_finite_label_projection_L2_approx
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (ε : ℝ) (hε : 0 < ε) :
    ∃ F : Finset ι, ∃ T : Finset (CoordinateTest (X := X)),
      ‖f -
        (condExpL2 ℝ ℝ
          ((sourceFiniteLabelSigma_le_coordinate F
            (fun i => sourceTestLabel T i)
            (fun i => sourceTestLabel_measurable T i)).trans
            (sourceFiniteCoordinateSigma_le (X := X) F)) f :
          Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))‖ < ε := by
  classical
  obtain ⟨g, hg, hclose⟩ :=
    sourceFiniteCellAlgebra_L2_approx μ f (ε / 2) (by linarith)
  obtain ⟨n, a, w, hrepr⟩ :=
    (Submodule.mem_span_set' (R := ℝ)).mp hg
  have hgen (i : Fin n) :
      ∃ (s : Set ((j : ι) → X j))
        (hs : s ∈ sourceFiniteCellAlgebra (X := X)) (c : ℝ),
        (w i).1 = sourceCellIndicator μ s hs c :=
    (w i).2
  choose s hs c hw using hgen
  let S : Finset (Set ((j : ι) → X j)) := Finset.univ.image s
  have hS : ∀ t ∈ S, t ∈ sourceFiniteCellAlgebra (X := X) := by
    intro t ht
    rcases Finset.mem_image.mp ht with ⟨i, _, rfl⟩
    exact hs i
  obtain ⟨F, T, hmeas⟩ :=
    finiteFamily_sourceCells_measurable_in_site_labels S hS
  let hle :=
    (sourceFiniteLabelSigma_le_coordinate F
      (fun i => sourceTestLabel T i)
      (fun i => sourceTestLabel_measurable T i)).trans
      (sourceFiniteCoordinateSigma_le (X := X) F)
  have hfix (i : Fin n) :
      (condExpL2 ℝ ℝ hle (w i).1 :
         Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) = (w i).1 := by
    rw [hw i]
    have himem : s i ∈ S :=
      Finset.mem_image.mpr ⟨i, Finset.mem_univ _, rfl⟩
    simpa only [sourceCellIndicator] using
      (condExpL2_indicator_of_measurable hle
        (hmeas (s i) himem)
        (measure_ne_top (Measure.infinitePi μ) (s i)) (c i))
  have hfixed :
      (condExpL2 ℝ ℝ hle g :
         Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) = g := by
    rw [← hrepr]
    simp only [map_sum, map_smul, hfix]
  have hsub :
      (condExpL2 ℝ ℝ hle (f - g) :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) =
      (condExpL2 ℝ ℝ hle f :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) -
      (condExpL2 ℝ ℝ hle g :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) := by
    simp
  have hidentity :
      f - (condExpL2 ℝ ℝ hle f :
          Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) =
      (f - g) -
        (condExpL2 ℝ ℝ hle (f - g) :
          Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) := by
    rw [hsub, hfixed]
    abel
  have hcontract :=
    norm_condExpL2_coe_le hle (f - g)
  refine ⟨F, T, ?_⟩
  change ‖f - (condExpL2 ℝ ℝ hle f :
    Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))‖ < ε
  calc
    ‖f - (condExpL2 ℝ ℝ hle f :
      Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))‖ =
      ‖(f - g) - (condExpL2 ℝ ℝ hle (f - g) :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))‖ := by rw [hidentity]
    _ ≤ ‖f - g‖ + ‖(condExpL2 ℝ ℝ hle (f - g) :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))‖ := norm_sub_le _ _
    _ ≤ 2 * ‖f - g‖ := by linarith
    _ < ε := by linarith

#print axioms Nightfall.InfinitePiQ2DenseOriginalLabelProjection.source_finite_label_projection_L2_approx

end Nightfall.InfinitePiQ2DenseOriginalLabelProjection
