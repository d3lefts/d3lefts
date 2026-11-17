import InfinitePiQ2OriginalIndependence
import Mathlib.Probability.ConditionalExpectation
import Mathlib.MeasureTheory.Function.ConditionalExpectation.PullOut

/-!
# Exact conditional expectation of a source-coordinate test

The original product law's independence of a site from its *entire*
complement is now kernel-certified in InfinitePiQ2OriginalIndependence.
Here we use that independence and conditional-expectation uniqueness to
identify the genuine source condExp on coordinate test functions with
the integral under the actual marginal μ i. This is a building block for
the eventual source-other L² heat-bath identification, not that full
identification for arbitrary f.
-/

namespace Nightfall.InfinitePiQ2ConditionalSourceTest

set_option maxHeartbeats 1200000

open MeasureTheory ProbabilityTheory
open Nightfall.InfinitePiQ2InfluenceStability
open Nightfall.InfinitePiQ2OriginalIndependence

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- The single-site σ-algebra and all-other-sites σ-algebra are independent
under the actual infinite product measure, without countability or atom floors. -/
theorem source_coordinate_other_sigma_indep (i : ι) :
    Indep
      (MeasurableSpace.comap
        (fun x : (j : ι) → X j => x i)
        (inferInstance : MeasurableSpace (X i)))
      (sourceOtherSigma (X := X) i)
      (Measure.infinitePi μ) := by
  change IndepFun (fun x : (j : ι) → X j => x i)
    (fun x : (j : ι) → X j =>
      (sourceOtherIndices i).restrict x)
    (Measure.infinitePi μ)
  have hfun :
      (fun x : (j : ι) → X j =>
        (sourceOtherIndices i).restrict x) =
      (fun x : (j : ι) → X j =>
        (fun j : sourceOtherIndices i => x j)) := by
    funext x j
    rfl
  rw [hfun]
  exact source_coordinate_other_indepFun μ i

/-- Exact original law of any measurable single-site real test. -/
theorem original_source_coordinate_integral
    (i : ι) (h : X i → ℝ) (hh : Measurable h) :
    (∫ x : (j : ι) → X j, h (x i) ∂ Measure.infinitePi μ) =
      ∫ a : X i, h a ∂ μ i := by
  have heval :
      Measurable (fun x : (j : ι) → X j => x i) := by fun_prop
  calc
    (∫ x : (j : ι) → X j, h (x i) ∂ Measure.infinitePi μ) =
        ∫ a : X i, h a ∂
          (Measure.infinitePi μ).map (fun x : (j : ι) → X j => x i) := by
            exact (integral_map heval.aemeasurable hh.aestronglyMeasurable).symm
    _ = ∫ a : X i, h a ∂ μ i := by
      rw [Measure.infinitePi_map_eval]

/-- A one-site observable on the actual source product. -/
def sourceOneCoordTest (i : ι) (h : X i → ℝ)
    (x : (j : ι) → X j) : ℝ := h (x i)

/-- Original-product conditional expectation of a one-site source test
given ALL the other sites is its original marginal integral. This
is a genuine conditional expectation, not an assumed heat-bath operator. -/
theorem source_condExp_coordinate_test
    (i : ι) (h : X i → ℝ) (hh : Measurable h) :
    MeasureTheory.condExp (sourceOtherSigma (X := X) i)
        (Measure.infinitePi μ) (sourceOneCoordTest i h)
      =ᵐ[Measure.infinitePi μ]
        (fun _ : (j : ι) → X j => ∫ a : X i, h a ∂ μ i) := by
  let e : ((j : ι) → X j) → X i := fun x => x i
  have hmeval : Measurable e := by
    dsimp [e]
    fun_prop
  have h₁ :
      MeasurableSpace.comap e (inferInstance : MeasurableSpace (X i)) ≤
        (inferInstance : MeasurableSpace ((j : ι) → X j)) := hmeval.comap_le
  have h₂ :
      sourceOtherSigma (X := X) i ≤
        (inferInstance : MeasurableSpace ((j : ι) → X j)) :=
    sourceOtherSigma_le (X := X) i
  have hstrong :
      StronglyMeasurable[MeasurableSpace.comap e
        (inferInstance : MeasurableSpace (X i))]
        (sourceOneCoordTest i h) := by
    change StronglyMeasurable[MeasurableSpace.comap e
        (inferInstance : MeasurableSpace (X i))] (fun x => h (e x))
    exact (hh.comp (comap_measurable e)).stronglyMeasurable
  have hind : Indep
      (MeasurableSpace.comap e (inferInstance : MeasurableSpace (X i)))
      (sourceOtherSigma (X := X) i) (Measure.infinitePi μ) := by
    exact source_coordinate_other_sigma_indep μ i
  have heq := condExp_indep_eq h₁ h₂ hstrong hind
  have hint := original_source_coordinate_integral μ i h hh
  simpa only [e, sourceOneCoordTest, hint] using heq

/-- True source-product one-coordinate test times an arbitrary
complement-measurable factor: the conditional expectation is the
original marginal integral times that factor. No abstract comparison
law or caller-provided independence hypothesis. -/
theorem source_condExp_coordinate_mul_other
    (i : ι) (h : X i → ℝ) (hh : Measurable h)
    (v : ((j : ι) → X j) → ℝ)
    (hv : StronglyMeasurable[sourceOtherSigma (X := X) i] v)
    (hui : Integrable (sourceOneCoordTest i h) (Measure.infinitePi μ))
    (huv : Integrable (sourceOneCoordTest i h * v) (Measure.infinitePi μ)) :
    (Measure.infinitePi μ)[sourceOneCoordTest i h * v |
        sourceOtherSigma (X := X) i] =ᵐ[Measure.infinitePi μ]
      (fun x => (∫ a : X i, h a ∂ μ i) * v x) := by
  have hpull :
      (Measure.infinitePi μ)[sourceOneCoordTest i h * v |
          sourceOtherSigma (X := X) i] =ᵐ[Measure.infinitePi μ]
        ((Measure.infinitePi μ)[sourceOneCoordTest i h |
          sourceOtherSigma (X := X) i] * v) :=
    condExp_mul_of_stronglyMeasurable_right hv huv hui
  have hmean :
      (Measure.infinitePi μ)[sourceOneCoordTest i h |
          sourceOtherSigma (X := X) i] =ᵐ[Measure.infinitePi μ]
        (fun _ : (j : ι) → X j => ∫ a : X i, h a ∂ μ i) :=
    source_condExp_coordinate_test μ i h hh
  exact hpull.trans (hmean.mul (Filter.EventuallyEq.rfl))

#print axioms Nightfall.InfinitePiQ2ConditionalSourceTest.source_coordinate_other_sigma_indep
#print axioms Nightfall.InfinitePiQ2ConditionalSourceTest.original_source_coordinate_integral
#print axioms Nightfall.InfinitePiQ2ConditionalSourceTest.source_condExp_coordinate_test
#print axioms Nightfall.InfinitePiQ2ConditionalSourceTest.source_condExp_coordinate_mul_other

end Nightfall.InfinitePiQ2ConditionalSourceTest
