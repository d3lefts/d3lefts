import InfinitePiQ2InfluenceStability
import InfinitePiQ2Density

/-!
# Arbitrary-product Q2: eventual uniform source-coordinate influence control

For any arbitrary (even uncountable) product index and original product
measure, genuine finite-information conditional expectations approach f in
L². Crucially the bound on coordinate-resampling residuals holds for *all*
coordinates simultaneously, with no factor depending on |F| or |I|.

All source influences are calculated under Measure.infinitePi μ.
This is the quantitative uniform influence/approximation bridge, not the
unproved discrete finite-table/source-influence comparison or terminal Q2.
-/

namespace Nightfall.InfinitePiQ2UniformInfluence
open MeasureTheory
open Nightfall.InfinitePiQ2Density
open Nightfall.InfinitePiQ2InfluenceStability

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- One finite source-information set controls the coordinate influence
residual error for EVERY original coordinate, including those outside it. -/
theorem finite_info_residuals_uniform
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (T ε : ℝ)
    (hε : 0 < ε)
    (hT : ∀ i : ι, ‖sourceCoordinateResidual μ i f‖ ≤ T) :
    ∃ F : Finset ι, ∀ G : Finset ι, F ⊆ G →
      ∀ i : ι,
        ‖sourceCoordinateResidual μ i
          (condExpL2 ℝ ℝ
            (sourceFiniteCoordinateSigma_le (X := X) G) f :
              Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))‖ ≤
          T + 2 * ε := by
  obtain ⟨F, hF⟩ := source_finite_info_L2_approx μ f ε hε
  refine ⟨F, ?_⟩
  intro G hFG i
  let g : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) :=
    (condExpL2 ℝ ℝ
      (sourceFiniteCoordinateSigma_le (X := X) G) f :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
  have hnorm : ‖g - f‖ < ε := by
    rw [norm_sub_rev]
    exact hF G hFG
  have hlip := sourceCoordinateResidual_lipschitz μ i f g
  have hcap := hT i
  dsimp only [g] at hlip ⊢
  linarith

/-- The *same* finite set gives all source-coordinate squared influences a
uniform bound, without a supremum over the (possibly uncountable) index. -/
theorem finite_info_influences_uniform
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (T ε : ℝ)
    (hε : 0 < ε)
    (hT : ∀ i : ι, ‖sourceCoordinateResidual μ i f‖ ≤ T) :
    ∃ F : Finset ι, ∀ G : Finset ι, F ⊆ G →
      ∀ i : ι,
        sourceCoordinateInfluence μ i
          (condExpL2 ℝ ℝ
            (sourceFiniteCoordinateSigma_le (X := X) G) f :
              Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) ≤
          (T + 2 * ε) ^ 2 := by
  obtain ⟨F, hF⟩ :=
    finite_info_residuals_uniform μ f T ε hε hT
  refine ⟨F, ?_⟩
  intro G hFG i
  unfold sourceCoordinateInfluence
  exact pow_le_pow_left₀ (norm_nonneg _) (hF G hFG i) 2

#print axioms Nightfall.InfinitePiQ2UniformInfluence.finite_info_residuals_uniform
#print axioms Nightfall.InfinitePiQ2UniformInfluence.finite_info_influences_uniform

end Nightfall.InfinitePiQ2UniformInfluence
