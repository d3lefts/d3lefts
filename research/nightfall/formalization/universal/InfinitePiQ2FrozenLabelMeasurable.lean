import InfinitePiQ2FiniteRankConditional
import InfinitePiQ2OriginalHeatBath

/-!
# Finite-label frozen sections are original-complement measurable

The finite-rank conditional-expectation theorem needs a product
decomposition in which the factor at site i is a label indicator and
the remaining factor is the original finite-label table with i frozen.
This file verifies that the frozen factor is measurable with respect
to the actual other-coordinate sigma algebra, not merely the full
source product measurable space.

No source conditional-projection commutation, assumed source influence,
positive atom floors, or final infinite Q2 inequality.
-/

namespace Nightfall.InfinitePiQ2FrozenLabelMeasurable

open MeasureTheory
open Nightfall.InfinitePiQ2InfluenceStability
open Nightfall.InfinitePiQ2OriginalLabelTransport

universe u v w
variable {ι : Type u} {X : ι → Type v} {Y : ι → Type w}
variable [∀ i, MeasurableSpace (X i)]
variable [∀ i, MeasurableSpace (Y i)]
variable [DecidableEq ι]

/-- A coordinate j≠i is measurable from exactly the source
information at all sites other than i. -/
theorem source_other_coordinate_measurable
    (i j : ι) (hji : j ≠ i) :
    Measurable[sourceOtherSigma (X := X) i]
      (fun x : ((k : ι) → X k) => x j) := by
  let r : ((k : ι) → X k) →
      ((k : sourceOtherIndices i) → X k) :=
    fun x => (sourceOtherIndices i).restrict x
  have hr : Measurable[sourceOtherSigma (X := X) i] r := by
    change Measurable[MeasurableSpace.comap r
      (inferInstance : MeasurableSpace
        ((k : sourceOtherIndices i) → X k))] r
    exact comap_measurable r
  have hj : Measurable
      (fun z : ((k : sourceOtherIndices i) → X k) =>
        z (⟨j, hji⟩ : sourceOtherIndices i)) := by
    fun_prop
  have hcomp : Measurable[sourceOtherSigma (X := X) i]
      (fun x : ((k : ι) → X k) => (r x) (⟨j, hji⟩ : sourceOtherIndices i)) :=
    hj.comp hr
  simpa only [r] using hcomp

/-- Every coordinate of the frozen finite-label word is measurable
using only the original-source complement of the frozen coordinate. -/
theorem source_frozen_label_word_measurable
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    (i : ι) (a : Y i) :
    Measurable[sourceOtherSigma (X := X) i]
      (fun x : ((k : ι) → X k) =>
        Function.update (sourceLabelMap φ x) i a) := by
  apply measurable_pi_iff.mpr
  intro j
  by_cases h : j = i
  · subst j
    simpa only [Function.update_same] using
      (measurable_const :
        Measurable[sourceOtherSigma (X := X) i]
          (fun _ : ((k : ι) → X k) => a))
  · have hj :=
      source_other_coordinate_measurable (X := X) i j h
    have hc : Measurable[sourceOtherSigma (X := X) i]
        (fun x : ((k : ι) → X k) => φ j (x j)) :=
      (hφ j).comp hj
    simpa only [Function.update_of_ne h, sourceLabelMap] using hc

/-- The table section with i frozen at a is a genuine
complement-measurable scalar factor. This is the missing measurability
premise for finite-rank original-law conditional expectation. -/
theorem source_frozen_label_factor_stronglyMeasurable
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    (i : ι) (a : Y i)
    (g : ((j : ι) → Y j) → ℝ) (hg : Measurable g) :
    StronglyMeasurable[sourceOtherSigma (X := X) i]
      (fun x : ((k : ι) → X k) =>
        g (Function.update (sourceLabelMap φ x) i a)) := by
  exact (hg.comp
    (source_frozen_label_word_measurable φ hφ i a)).stronglyMeasurable

#print axioms Nightfall.InfinitePiQ2FrozenLabelMeasurable.source_other_coordinate_measurable
#print axioms Nightfall.InfinitePiQ2FrozenLabelMeasurable.source_frozen_label_word_measurable
#print axioms Nightfall.InfinitePiQ2FrozenLabelMeasurable.source_frozen_label_factor_stronglyMeasurable

end Nightfall.InfinitePiQ2FrozenLabelMeasurable
