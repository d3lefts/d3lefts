import InfinitePiQ2DenseLabelLimit

/-!
# Original-product Q2: vanishing finite-model influence slack is enough

The genuine source Hilbert stability estimate bounds a finite-label
approximant's source influence by (sqrt M + 2 ε)² rather than by
M exactly. Requiring every finite model to satisfy the *exact* M cap
is an unnecessary and generally false intermediate obligation.

This theorem proves the robust final limit with two independent
arbitrarily small parameters: L² approximation error ε and variance
certificate slack C η. It uses the existing source-specific L²
mean-preserving closure theorem at each η, then eliminates η by
an exact real-order contradiction. No countability, atom floor,
limiting sequence, approximation oracle or finite numerical Q2
inequality is introduced by this theorem.
-/

namespace Nightfall.InfinitePiQ2RobustLabelLimit

open MeasureTheory
open Nightfall.InfinitePiQ2Density
open Nightfall.InfinitePiQ2DenseLabelLimit

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- If source L² approximants retain the true mean and obey a uniform
quadratic variance bound with arbitrarily small nonnegative linear
slack, the original infinite-product observable obeys the exact bound.
No exact finite-resolution inequality is required. -/
theorem source_q2_bound_with_vanishing_finite_model_slack
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (R C : ℝ) (hC : 0 ≤ C)
    (happrox : ∀ ε : ℝ, 0 < ε → ∀ η : ℝ, 0 < η →
      ∃ g : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ),
        ‖f - g‖ < ε ∧
        (∫ x, g x ∂ Measure.infinitePi μ) =
          (∫ x, f x ∂ Measure.infinitePi μ) ∧
        (sourceL2Variance μ g)^2 ≤ R + C * η) :
    (sourceL2Variance μ f)^2 ≤ R := by
  have hb (η : ℝ) (hη : 0 < η) :
      (sourceL2Variance μ f)^2 ≤ R + C * η := by
    apply source_q2_bound_of_approximate_finite_labels μ f (R + C * η)
    intro ε hε
    exact happrox ε hε η hη
  by_contra hn
  have hgap : 0 < (sourceL2Variance μ f)^2 - R := by
    have := lt_of_not_ge hn
    linarith
  let d : ℝ := 2 * (C + 1)
  have hd0 : 0 < d := by
    dsimp [d]
    linarith
  have hdn : d ≠ 0 := ne_of_gt hd0
  let η : ℝ := ((sourceL2Variance μ f)^2 - R) / d
  have hη : 0 < η := div_pos hgap hd0
  have hprod : d * η = (sourceL2Variance μ f)^2 - R := by
    dsimp [η]
    field_simp
  have hfin := hb η hη
  dsimp [d] at hprod
  nlinarith

#print axioms Nightfall.InfinitePiQ2RobustLabelLimit.source_q2_bound_with_vanishing_finite_model_slack

end Nightfall.InfinitePiQ2RobustLabelLimit
