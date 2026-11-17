import InfinitePiQ2SourceBoundedCondExp
import Mathlib.MeasureTheory.Function.ConditionalExpectation.Basic

/-!
# Genuine original-product L² label projection preserves essential bounds

The earlier original-source conditional expectation boundedness theorem
was in L¹, whereas finite-label Q2 constructs its approximation using
the true Hilbert orthogonal condExpL2. The two are the same almost
everywhere for original-product L² observables. This module closes
that exact bridge via Mathlib's MemLp.condExpL2_ae_eq_condExp and
our original-source essential-bound theorem.

The result is uniform for arbitrary index sets and arbitrary sub-sigma
algebras of the genuine original product, including actual finite
measurable label partitions. No positive atom floor, source replacement
or finite-Q2 premise is assumed.
-/

namespace Nightfall.InfinitePiQ2SourceL2BoundedProjection

open MeasureTheory
open Nightfall.InfinitePiQ2SourceBoundedCondExp

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- Exact essential L∞ bound of the TRUE original-product L²
conditional expectation onto any original sub-sigma algebra,
including the source finite-label sigma algebra. -/
theorem source_condExpL2_essential_bound
    (m : MeasurableSpace ((j : ι) → X j))
    (hm : m ≤ (MeasurableSpace.pi :
      MeasurableSpace ((j : ι) → X j)))
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (B : ℝ)
    (hbound : ∀ᵐ x ∂(Measure.infinitePi μ), |f x| ≤ B) :
    ∀ᵐ x ∂(Measure.infinitePi μ),
      |(condExpL2 ℝ ℝ hm f :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) x| ≤ B := by
  let ν := Measure.infinitePi μ
  have hmem : MemLp (fun x => f x) (2 : ENNReal) ν :=
    Lp.memLp f
  have hint : Integrable (fun x => f x) ν :=
    memLp_one_iff_integrable.mp (hmem.mono_exponent one_le_two)
  have hL1 :
      ∀ᵐ x ∂ν, |ν[(fun x => f x) | m] x| ≤ B :=
    source_subSigma_condExp_essential_bound μ m hm
      (fun x => f x) B hint hbound
  have hEq :
      (condExpL2 ℝ ℝ hm f : ((j : ι) → X j) → ℝ) =ᵐ[ν]
        ν[(fun x => f x) | m] := by
    simpa only [Lp.toLp_coeFn] using
      (hmem.condExpL2_ae_eq_condExp hm)
  filter_upwards [hEq, hL1] with x hx hb
  simpa only [hx] using hb

#print axioms Nightfall.InfinitePiQ2SourceL2BoundedProjection.source_condExpL2_essential_bound

end Nightfall.InfinitePiQ2SourceL2BoundedProjection
