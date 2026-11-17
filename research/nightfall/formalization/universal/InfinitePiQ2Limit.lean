import InfinitePiQ2Density

/-!
# Arbitrary-index quadratic Q2 limit: source-measure bridge

The finite-information conditional expectations and the final quadratic
limit both refer to the genuine Measure.infinitePi source law. This file
proves the entire epsilon/squaring limit, without any finite-index,
countability, or atom-floor condition.

The hypothesis that each finite-information projection obeys the SAME
source Q2 inequality is explicit. It must be discharged by constructing
and verifying the finite table under the actual source before a fully
unconditional Q2 terminal is claimed. This lemma does not assume an
approximation/density axiom: source_finite_info_variance_approx is proved
in InfinitePiQ2Density.
-/

namespace Nightfall.InfinitePiQ2Limit

open MeasureTheory
open Nightfall.InfinitePiQ2Density

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- Finite-information projection is variance-contracting under the
genuine original product law, without assuming f has mean zero. -/
theorem source_finite_info_variance_le
    (F : Finset ι)
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    sourceL2Variance μ
      (condExpL2 ℝ ℝ (sourceFiniteCoordinateSigma_le (X := X) F) f :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) ≤
      sourceL2Variance μ f := by
  have hnorm := source_finite_info_L2_contract μ F f
  have hmean := source_finite_info_preserves_mean μ F f
  unfold sourceL2Variance
  rw [hmean]
  nlinarith [norm_nonneg f,
    norm_nonneg (condExpL2 ℝ ℝ (sourceFiniteCoordinateSigma_le (X := X) F) f :
      Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))]

/-- The full arbitrary-product quadratic limit: if every genuine
finite-information projection satisfies a COMMON bound R, the actual
unprojected infinite-product variance satisfies the identical bound.

No cardinality, countability, boundedness, approximation or finite-mass
hypothesis is supplied by the caller. The source-measure projection
convergence and its variance inequality are genuine proved dependencies. -/
theorem source_q2_quadratic_limit
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (R : ℝ) (hR : 0 ≤ R)
    (hfinite : ∀ F : Finset ι,
      (sourceL2Variance μ
        (condExpL2 ℝ ℝ (sourceFiniteCoordinateSigma_le (X := X) F) f :
          Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))) ^ 2 ≤ R) :
    (sourceL2Variance μ f) ^ 2 ≤ R := by
  let r : ℝ := Real.sqrt R
  have hr0 : 0 ≤ r := Real.sqrt_nonneg _
  have hr2 : r ^ 2 = R := Real.sq_sqrt hR
  have hproj : ∀ F : Finset ι,
      -r ≤ sourceL2Variance μ
        (condExpL2 ℝ ℝ (sourceFiniteCoordinateSigma_le (X := X) F) f :
          Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) ∧
      sourceL2Variance μ
        (condExpL2 ℝ ℝ (sourceFiniteCoordinateSigma_le (X := X) F) f :
          Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) ≤ r := by
    intro F
    have h := hfinite F
    constructor <;> nlinarith
  have hlower : -r ≤ sourceL2Variance μ f := by
    exact (hproj ∅).1.trans (source_finite_info_variance_le μ ∅ f)
  have hupper : sourceL2Variance μ f ≤ r := by
    by_contra hn
    have hgap : 0 < (sourceL2Variance μ f - r) / 2 := by
      have hneg : r < sourceL2Variance μ f := lt_of_not_ge hn
      linarith
    obtain ⟨F, happrox⟩ :=
      source_finite_info_variance_approx μ f
        ((sourceL2Variance μ f - r) / 2) hgap
    have hF := happrox F (Finset.Subset.refl F)
    have hbound := (hproj F).2
    linarith
  nlinarith

end Nightfall.InfinitePiQ2Limit
