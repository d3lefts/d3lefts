import InfinitePiQ2SourceLabelL2Intertwining
import Mathlib.MeasureTheory.Function.LpSpace.Basic

/-!
# Genuine source/label L² equality on bounded finite-label observables

Converts the exact a.e. conditional-expectation identity from the
source-specific L² bridge into an equality of genuine Hilbert L² vectors,
using the exact original-source measure-preserving isometry and
MemLp.toLp representatives. No caller-supplied intertwining equation.
-/

namespace Nightfall.InfinitePiQ2SourceLabelLpIntertwining

open MeasureTheory
open Nightfall.InfinitePiQ2InfluenceStability
open Nightfall.InfinitePiQ2OriginalLabelTransport
open Nightfall.InfinitePiQ2GenuineLabelIsometry
open Nightfall.InfinitePiQ2SourceLabelL2Intertwining

universe u v w
variable {ι : Type u} {X : ι → Type v} {Y : ι → Type w}
variable [∀ i, MeasurableSpace (X i)] [∀ i, MeasurableSpace (Y i)]
variable [∀ i, MeasurableSingletonClass (Y i)]
variable [DecidableEq ι]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- The actual original-product Hilbert heat bath intertwines with
the genuine source-to-label L² isometry for every bounded measurable
finite-at-i label test, as an L² vector equality (not just an a.e.
formula for an arbitrary representative). -/
theorem sourceOtherProjection_lift_intertwines_bounded_Lp
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    (g : ((j : ι) → Y j) → ℝ) (hg : Measurable g)
    (B : ℝ) (hB : 0 ≤ B) (hbound : ∀ y, |g y| ≤ B)
    (i : ι) [Fintype (Y i)] [DecidableEq (Y i)]
    (hg2 : MemLp g (2 : ENNReal)
      (Measure.infinitePi (fun j => (μ j).map (φ j))))
    (hlift2 : MemLp (fun x => g (sourceLabelMap φ x)) (2 : ENNReal)
      (Measure.infinitePi μ)) :
    sourceOtherProjection μ i
      (original_infinite_label_lift μ φ hφ hg2.toLp) =
    original_infinite_label_lift μ φ hφ
      (sourceOtherProjection (fun j => (μ j).map (φ j)) i hg2.toLp) := by
  let q : (j : ι) → Measure (Y j) := fun j => (μ j).map (φ j)
  have hmp : MeasurePreserving (sourceLabelMap φ)
      (Measure.infinitePi μ) (Measure.infinitePi q) :=
    original_infinite_label_measurePreserving μ φ hφ
  have htableRep :
      (fun x => (↑(hg2.toLp) : ((j : ι) → Y j) → ℝ) (sourceLabelMap φ x))
        =ᵐ[Measure.infinitePi μ]
      (fun x => g (sourceLabelMap φ x)) := by
    simpa only [Function.comp_def] using
      (hmp.quasiMeasurePreserving.ae_eq_comp (MemLp.coeFn_toLp hg2))
  have hsrcRep :
      (↑(hlift2.toLp) : ((j : ι) → X j) → ℝ) =ᵐ[Measure.infinitePi μ]
        (fun x => g (sourceLabelMap φ x)) :=
    MemLp.coeFn_toLp hlift2
  have hURep :=
    original_infinite_label_lift_ae μ φ hφ hg2.toLp
  have hsrcEq : hlift2.toLp =
      original_infinite_label_lift μ φ hφ hg2.toLp := by
    apply Lp.ext_iff.mpr
    exact hsrcRep.trans (hURep.trans htableRep).symm
  have hproj :=
    sourceOtherProjection_lift_intertwines_bounded_ae μ φ hφ
      g hg B hB hbound i hg2 hlift2
  have hUProj :=
    original_infinite_label_lift_ae μ φ hφ
      (sourceOtherProjection q i hg2.toLp)
  rw [← hsrcEq]
  exact Lp.ext_iff.mpr (hproj.trans hUProj.symm)

#print axioms Nightfall.InfinitePiQ2SourceLabelLpIntertwining.sourceOtherProjection_lift_intertwines_bounded_Lp

end Nightfall.InfinitePiQ2SourceLabelLpIntertwining
