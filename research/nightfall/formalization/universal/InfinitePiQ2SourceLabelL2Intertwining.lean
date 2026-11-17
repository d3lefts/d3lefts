import InfinitePiQ2BoundedLabelIntertwining
import InfinitePiQ2GenuineLabelIsometry
import Mathlib.MeasureTheory.Function.ConditionalExpectation.Basic

/-!
# Actual source / label L² heat-bath intertwining on bounded finite-label tables

Upgrades certified original-source bounded L¹ conditional-expectation
intertwining to the genuine Hilbert condExpL2 projection. The label law
is the original marginal pushforward product; the pullback is the
genuine measure-preserving isometry.

This lemma is an a.e. L² representative identity for bounded measurable
label observables with genuine MemLp evidence. Extension to all L²
vectors and finite-cell adjoint/boundedness remains separate.
-/

namespace Nightfall.InfinitePiQ2SourceLabelL2Intertwining

open MeasureTheory
open Nightfall.InfinitePiQ2InfluenceStability
open Nightfall.InfinitePiQ2OriginalLabelTransport
open Nightfall.InfinitePiQ2GenuineLabelIsometry
open Nightfall.InfinitePiQ2BoundedLabelIntertwining

universe u v w
variable {ι : Type u} {X : ι → Type v} {Y : ι → Type w}
variable [∀ i, MeasurableSpace (X i)] [∀ i, MeasurableSpace (Y i)]
variable [∀ i, MeasurableSingletonClass (Y i)]
variable [DecidableEq ι]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- The genuine source Hilbert heat-bath of a bounded finite-label
pullback equals the original-pushforward table Hilbert heat-bath pulled
back to source, almost everywhere. No assumed operator intertwining,
surrogate product law, positive atom floor, or finite index set. -/
theorem sourceOtherProjection_lift_intertwines_bounded_ae
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    (g : ((j : ι) → Y j) → ℝ) (hg : Measurable g)
    (B : ℝ) (hB : 0 ≤ B) (hbound : ∀ y, |g y| ≤ B)
    (i : ι) [Fintype (Y i)] [DecidableEq (Y i)]
    (hg2 : MemLp g (2 : ENNReal)
      (Measure.infinitePi (fun j => (μ j).map (φ j))))
    (hlift2 : MemLp (fun x => g (sourceLabelMap φ x)) (2 : ENNReal)
      (Measure.infinitePi μ)) :
    (↑↑↑(sourceOtherProjection μ i hlift2.toLp)) =ᵐ[Measure.infinitePi μ]
      (fun x => (↑↑↑(sourceOtherProjection
        (fun j => (μ j).map (φ j)) i hg2.toLp))
        (sourceLabelMap φ x)) := by
  let q : (j : ι) → Measure (Y j) := fun j => (μ j).map (φ j)
  have hsourceL2 :
      (↑↑↑(sourceOtherProjection μ i hlift2.toLp)) =ᵐ[Measure.infinitePi μ]
        (Measure.infinitePi μ)[
          (fun x => g (sourceLabelMap φ x)) |
          sourceOtherSigma (X := X) i] := by
    exact MemLp.condExpL2_ae_eq_condExp (E := ℝ) (𝕜 := ℝ)
      (sourceOtherSigma_le (X := X) i) hlift2
  have htableL2 :
      (↑↑↑(sourceOtherProjection q i hg2.toLp)) =ᵐ[Measure.infinitePi q]
        (Measure.infinitePi q)[g | sourceOtherSigma (X := Y) i] := by
    exact MemLp.condExpL2_ae_eq_condExp (E := ℝ) (𝕜 := ℝ)
      (sourceOtherSigma_le (X := Y) i) hg2
  have hmp : MeasurePreserving (sourceLabelMap φ)
      (Measure.infinitePi μ) (Measure.infinitePi q) :=
    original_infinite_label_measurePreserving μ φ hφ
  have htableLift :
      (fun x => (↑↑↑(sourceOtherProjection q i hg2.toLp))
        (sourceLabelMap φ x)) =ᵐ[Measure.infinitePi μ]
      (fun x => (Measure.infinitePi q)[g |
        sourceOtherSigma (X := Y) i] (sourceLabelMap φ x)) := by
    simpa only [Function.comp_def] using
      (hmp.quasiMeasurePreserving.ae_eq_comp htableL2)
  have hsource :=
    source_condExp_lift_intertwines_bounded μ φ hφ g hg B hB hbound i
  exact hsourceL2.trans (hsource.trans htableLift.symm)

#print axioms Nightfall.InfinitePiQ2SourceLabelL2Intertwining.sourceOtherProjection_lift_intertwines_bounded_ae

end Nightfall.InfinitePiQ2SourceLabelL2Intertwining
