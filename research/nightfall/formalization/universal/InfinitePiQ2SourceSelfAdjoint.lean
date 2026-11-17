import InfinitePiQ2InfluenceStability
import Mathlib

/-!
# Exact original infinite-product Hilbert heat bath is self-adjoint

The true source-other coordinate L² conditional expectation is the
orthogonal projection onto the source-other measurable Hilbert subspace.
Its self-adjointness is established from pinned Mathlib, not assumed
as a table/source comparison hypothesis.

This discharges the SOURCE-side hS operator premise of the generic
Hilbert adjoint/range projection transfer; the table-side projection
and original-source intertwining remain separately typed gates.
-/

namespace Nightfall.InfinitePiQ2SourceSelfAdjoint

open MeasureTheory
open Nightfall.InfinitePiQ2InfluenceStability

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- The exact original-product coordinate heat bath as a Hilbert
continuous-linear map, not a supplied or surrogate operator. -/
noncomputable def sourceOtherProjectionCLM (i : ι) :
    Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) →L[ℝ]
      Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) :=
  (condExpL2 ℝ ℝ (sourceOtherSigma_le (X := X) i) :
    Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) →L[ℝ]
      Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))

/-- The map really is the exact source conditional expectation on
each L² observable. -/
theorem sourceOtherProjectionCLM_apply (i : ι)
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    sourceOtherProjectionCLM μ i f = sourceOtherProjection μ i f := rfl

/-- Genuine original-source L² heat baths are self-adjoint even when
the product index is uncountable and individual source coordinates have
nonatomic or zero-probability events. -/
theorem sourceOtherProjectionCLM_adjoint (i : ι) :
    (sourceOtherProjectionCLM μ i).adjoint =
      sourceOtherProjectionCLM μ i := by
  haveI : Fact (sourceOtherSigma (X := X) i ≤
      (inferInstance : MeasurableSpace ((j : ι) → X j))) :=
    ⟨sourceOtherSigma_le (X := X) i⟩
  let K : Submodule ℝ
      (Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :=
    lpMeas ℝ ℝ (sourceOtherSigma (X := X) i)
      (2 : ENNReal) (Measure.infinitePi μ)
  change (K.starProjection).adjoint = K.starProjection
  exact ContinuousLinearMap.isSelfAdjoint_iff'.mp
    (isSelfAdjoint_starProjection K)

#print axioms Nightfall.InfinitePiQ2SourceSelfAdjoint.sourceOtherProjectionCLM_apply
#print axioms Nightfall.InfinitePiQ2SourceSelfAdjoint.sourceOtherProjectionCLM_adjoint

end Nightfall.InfinitePiQ2SourceSelfAdjoint
