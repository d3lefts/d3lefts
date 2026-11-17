import InfinitePiQ2ActiveFiniteLabelCondExp
import Mathlib.MeasureTheory.Integral.Bochner.Set

/-!
# Actual finite-label cell probabilities in the original-source heat-bath

The exact original-product active-coordinate conditional expectation from
InfinitePiQ2ActiveFiniteLabelCondExp is rewritten in the finite product's
canonical atom probabilities q_i(a)=((μ i).map (φ i)).real {a}.
This is the missing scalar identification connecting the original Hilbert
heat-bath formula with the source-proven finite-table product law.

No positive-atom premise or source-law replacement is used.
-/

namespace Nightfall.InfinitePiQ2LabelAtomMass

open MeasureTheory
open Nightfall.InfinitePiQ2InfluenceStability
open Nightfall.InfinitePiQ2OriginalLabelTransport
open Nightfall.InfinitePiQ2ActiveFiniteLabelCondExp

universe u v w
variable {ι : Type u} {X : ι → Type v} {Y : ι → Type w}
variable [∀ i, MeasurableSpace (X i)] [∀ i, MeasurableSpace (Y i)]
variable [∀ i, MeasurableSingletonClass (Y i)]
variable [DecidableEq ι]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- The source indicator integral is exactly the original marginal's
image atom mass, including zero-probability label cells. -/
theorem source_label_indicator_integral_eq_atom
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    (i : ι) (a : Y i) [DecidableEq (Y i)] :
    (∫ b : X i, (if φ i b = a then (1 : ℝ) else 0) ∂ μ i) =
      ((μ i).map (φ i)).real {a} := by
  classical
  let s : Set (X i) := (φ i) ⁻¹' {a}
  have hs : MeasurableSet s := (hφ i) (measurableSet_singleton a)
  have hpoint : ∀ b : X i,
      (if φ i b = a then (1 : ℝ) else 0) =
        s.indicator (fun _ => (1 : ℝ)) b := by
    intro b
    by_cases hb : φ i b = a
    · simp [s, hb, Set.indicator]
    · simp [s, hb, Set.indicator]
  calc
    (∫ b : X i, (if φ i b = a then (1 : ℝ) else 0) ∂ μ i) =
        ∫ b : X i, s.indicator (fun _ => (1 : ℝ)) b ∂ μ i := by
          exact integral_congr_ae (Filter.Eventually.of_forall hpoint)
    _ = (μ i).real s := integral_indicator_one hs
    _ = ((μ i).map (φ i)).real {a} := by
      unfold Measure.real
      rw [Measure.map_apply (hφ i) (measurableSet_singleton a)]

/-- The actual source conditional expectation of a bounded label
observable is exactly the table's finite atom-weight heat-bath sum,
with q_i=the original pushforward of μ_i. No unknown kernel or law. -/
theorem source_condExp_lifted_label_atom_sum
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    (g : ((j : ι) → Y j) → ℝ) (hg : Measurable g)
    (B : ℝ) (hB : 0 ≤ B) (hbound : ∀ y, |g y| ≤ B)
    (i : ι) [Fintype (Y i)] [DecidableEq (Y i)] :
    (Measure.infinitePi μ)[
      (fun x => g (sourceLabelMap φ x)) |
      sourceOtherSigma (X := X) i] =ᵐ[Measure.infinitePi μ]
      (fun x => ∑ a : Y i,
        ((μ i).map (φ i)).real {a} *
          g (Function.update (sourceLabelMap φ x) i a)) := by
  classical
  have hcore :=
    source_condExp_lifted_finite_label μ φ hφ g hg B hB hbound i
  have htarget : ∀ x : ((j : ι) → X j),
      (∑ a : Y i,
        (∫ b : X i, (if φ i b = a then (1 : ℝ) else 0) ∂ μ i) *
          g (Function.update (sourceLabelMap φ x) i a)) =
      (∑ a : Y i,
        ((μ i).map (φ i)).real {a} *
          g (Function.update (sourceLabelMap φ x) i a)) := by
    intro x
    apply Finset.sum_congr rfl
    intro a _
    rw [source_label_indicator_integral_eq_atom μ φ hφ i a]
  exact hcore.trans (Filter.Eventually.of_forall htarget)

/-- The genuine original-product L² Hilbert heat-bath, not merely L¹
conditional expectation, is the exact finite-table atom-weight
heat-bath expression. The bounded lift's L² witness is constructed
within the theorem statement, with no caller projection oracle. -/
theorem sourceOtherProjection_lifted_label_atom_sum_ae
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    (g : ((j : ι) → Y j) → ℝ) (hg : Measurable g)
    (B : ℝ) (hB : 0 ≤ B)
    (hbound : ∀ y, |g y| ≤ B)
    (i : ι) [Fintype (Y i)] [DecidableEq (Y i)] :
    let f : ((j : ι) → X j) → ℝ :=
      fun x => g (sourceLabelMap φ x)
    let hmem : MemLp f (2 : ENNReal) (Measure.infinitePi μ) :=
      MemLp.of_bound
        ((hg.comp (sourceLabelMap_measurable φ hφ)).aestronglyMeasurable)
        B (Filter.Eventually.of_forall (fun x => by
          simpa only [Real.norm_eq_abs, Function.comp_apply] using
            hbound (sourceLabelMap φ x)))
    (↑↑↑(sourceOtherProjection μ i hmem.toLp)) =ᵐ[Measure.infinitePi μ]
      (fun x => ∑ a : Y i,
        ((μ i).map (φ i)).real {a} *
          g (Function.update (sourceLabelMap φ x) i a)) := by
  dsimp only
  have hcore :=
    sourceOtherProjection_lifted_finite_label_ae
      μ φ hφ g hg B hB hbound i
  have htarget : ∀ x : ((j : ι) → X j),
      (∑ a : Y i,
        (∫ b : X i, (if φ i b = a then (1 : ℝ) else 0) ∂ μ i) *
          g (Function.update (sourceLabelMap φ x) i a)) =
      (∑ a : Y i,
        ((μ i).map (φ i)).real {a} *
          g (Function.update (sourceLabelMap φ x) i a)) := by
    intro x
    apply Finset.sum_congr rfl
    intro a _
    rw [source_label_indicator_integral_eq_atom μ φ hφ i a]
  exact hcore.trans (Filter.Eventually.of_forall htarget)

#print axioms Nightfall.InfinitePiQ2LabelAtomMass.source_label_indicator_integral_eq_atom
#print axioms Nightfall.InfinitePiQ2LabelAtomMass.sourceOtherProjection_lifted_label_atom_sum_ae
#print axioms Nightfall.InfinitePiQ2LabelAtomMass.source_condExp_lifted_label_atom_sum

end Nightfall.InfinitePiQ2LabelAtomMass
