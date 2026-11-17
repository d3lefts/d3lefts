import InfinitePiQ2LabelAtomMass
import Mathlib.Probability.ProductMeasure

/-!
# Bounded original source / native label heat-bath intertwining

For an arbitrary original product law, the source coordinate
conditional expectation of a bounded measurable finite-label pullback
agrees almost everywhere with the pullback of the true conditional
expectation under the label's original pushforward product law.

Unlike a generic adjoint premise, this theorem computes both sides
using the original source and original pushforward marginals. No
product-law replacement, positive atom bound, independence oracle
or assumed source-label intertwining.

This is the L¹ representative equality needed to construct the
genuine L² operator intertwining. That latter identification and
the full unconditional Q2 terminal remain separate gates.
-/

namespace Nightfall.InfinitePiQ2BoundedLabelIntertwining

open MeasureTheory
open Nightfall.InfinitePiQ2InfluenceStability
open Nightfall.InfinitePiQ2OriginalLabelTransport
open Nightfall.InfinitePiQ2LabelAtomMass

universe u v w
variable {ι : Type u} {X : ι → Type v} {Y : ι → Type w}
variable [∀ i, MeasurableSpace (X i)] [∀ i, MeasurableSpace (Y i)]
variable [∀ i, MeasurableSingletonClass (Y i)]
variable [DecidableEq ι]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- The exact original source conditional-expectation intertwining
on bounded finite-at-i native labels. The conditional expectation
on the right is under the TRUE independent pushforward label law.
No table expectation or measure-preserving identity is presumed. -/
theorem source_condExp_lift_intertwines_bounded
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    (g : ((j : ι) → Y j) → ℝ) (hg : Measurable g)
    (B : ℝ) (hB : 0 ≤ B) (hbound : ∀ y, |g y| ≤ B)
    (i : ι) [Fintype (Y i)] [DecidableEq (Y i)] :
    (Measure.infinitePi μ)[
      (fun x => g (sourceLabelMap φ x)) |
      sourceOtherSigma (X := X) i] =ᵐ[Measure.infinitePi μ]
      (fun x => (Measure.infinitePi (fun j => (μ j).map (φ j)))[
          g | sourceOtherSigma (X := Y) i] (sourceLabelMap φ x)) := by
  classical
  let q : (j : ι) → Measure (Y j) := fun j => (μ j).map (φ j)
  have hsource :=
    source_condExp_lifted_label_atom_sum μ φ hφ g hg B hB hbound i
  have htable :
      (Measure.infinitePi q)[g | sourceOtherSigma (X := Y) i]
        =ᵐ[Measure.infinitePi q]
      (fun y => ∑ a : Y i, (q i).real {a} *
        g (Function.update y i a)) := by
    have h :=
      source_condExp_lifted_label_atom_sum q
        (fun j => (id : Y j → Y j))
        (fun j => (measurable_id : Measurable (id : Y j → Y j)))
        g hg B hB hbound i
    have hid : sourceLabelMap (fun j => (id : Y j → Y j)) =
        (id : ((j : ι) → Y j) → ((j : ι) → Y j)) := by
      funext y j
      rfl
    rw [hid] at h
    simpa only [id_eq, Measure.map_id] using h
  have hmp : MeasurePreserving (sourceLabelMap φ)
      (Measure.infinitePi μ) (Measure.infinitePi q) := by
    exact ⟨sourceLabelMap_measurable φ hφ,
      sourceLabelLaw_exact μ φ hφ⟩
  have hlift :
      ((Measure.infinitePi q)[g | sourceOtherSigma (X := Y) i] ∘
        sourceLabelMap φ) =ᵐ[Measure.infinitePi μ]
      ((fun y => ∑ a : Y i, (q i).real {a} *
        g (Function.update y i a)) ∘ sourceLabelMap φ) :=
    hmp.quasiMeasurePreserving.ae_eq_comp htable
  have hsumform :
      (fun x : ((j : ι) → X j) =>
        ∑ a : Y i, (q i).real {a} *
          g (Function.update (sourceLabelMap φ x) i a)) =
      ((fun y : ((j : ι) → Y j) =>
        ∑ a : Y i, (q i).real {a} *
          g (Function.update y i a)) ∘ sourceLabelMap φ) := rfl
  rw [← hsumform] at hlift
  exact hsource.trans hlift.symm

#print axioms Nightfall.InfinitePiQ2BoundedLabelIntertwining.source_condExp_lift_intertwines_bounded

end Nightfall.InfinitePiQ2BoundedLabelIntertwining
