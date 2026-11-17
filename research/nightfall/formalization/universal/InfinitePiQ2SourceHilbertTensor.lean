import InfinitePiQ2ConditionalSourceTest
import Mathlib.MeasureTheory.Function.ConditionalExpectation.Basic

/-!
# Original infinite-product L² conditional projection on source tensors

This is the explicit bridge between the source-coordinate pointwise
conditional expectation and the *actual* Hilbert-space projection
sourceOtherProjection = condExpL2, under Measure.infinitePi μ.

The theorem is scoped to L² tensor tests h(x_i)*v(x_-i), with the
necessary genuine integrability assumptions. It is NOT a theorem
for arbitrary L² functions, not a finite-label P_Y commuting square,
and not the unconditional infinite-product Q2 terminal.
-/

namespace Nightfall.InfinitePiQ2SourceHilbertTensor

open MeasureTheory
open Nightfall.InfinitePiQ2InfluenceStability
open Nightfall.InfinitePiQ2ConditionalSourceTest

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- Actual original-source Hilbert projection on one-coordinate ×
complement tensor tests, with no postulated projection identity.
The source σ-algebra and source product measure are unmodified. -/
theorem sourceOtherProjection_tensor_ae
    (i : ι) (h : X i → ℝ) (hh : Measurable h)
    (v : ((j : ι) → X j) → ℝ)
    (hv : StronglyMeasurable[sourceOtherSigma (X := X) i] v)
    (hui : Integrable (sourceOneCoordTest i h) (Measure.infinitePi μ))
    (huv : Integrable (sourceOneCoordTest i h * v) (Measure.infinitePi μ))
    (hf : MemLp (sourceOneCoordTest i h * v) (2 : ENNReal)
      (Measure.infinitePi μ)) :
    (↑↑↑(sourceOtherProjection μ i hf.toLp)) =ᵐ[Measure.infinitePi μ]
      (fun x => (∫ a : X i, h a ∂ μ i) * v x) := by
  have hL2 :=
    MemLp.condExpL2_ae_eq_condExp
      (sourceOtherSigma_le (X := X) i) hf
  have hTensor :=
    source_condExp_coordinate_mul_other μ i h hh v hv hui huv
  exact hL2.trans hTensor

#print axioms Nightfall.InfinitePiQ2SourceHilbertTensor.sourceOtherProjection_tensor_ae

end Nightfall.InfinitePiQ2SourceHilbertTensor
