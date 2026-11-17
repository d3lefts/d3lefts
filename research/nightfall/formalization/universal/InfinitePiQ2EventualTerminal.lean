import InfinitePiQ2Limit

/-!
# Unconditional epsilon-limit for arbitrary original products

A finite-table approximation need not preserve a Q2 source inequality
EXACTLY at finite resolution. It suffices to establish it eventually
with an arbitrarily small error under the SAME original infinitePi law.

This theorem discharges the entire limiting/squaring/epsilon passage,
without countability or a positive atom floor and without postulating
the density of finite-coordinate observables.

The remaining step for unconditional Q2 is to derive the actual
finite-resolution inequality from a bounded pointwise quadratic source
f using a finite-cell table with a source-faithful influence comparison.
-/

namespace Nightfall.InfinitePiQ2EventualTerminal
open MeasureTheory
open Nightfall.InfinitePiQ2Density
open Nightfall.InfinitePiQ2Limit

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- Every genuine original-product source variance is nonnegative,
including after conditional expectation onto finite coordinates. -/
theorem source_variance_nonneg
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
    0 ≤ sourceL2Variance μ f := by
  rw [sourceL2Variance_eq_actual_variance]
  exact ProbabilityTheory.variance_nonneg (fun x => f x)
    (Measure.infinitePi μ)

/-- Arbitrary-product Q2 passage under EVENTUALLY valid finite-information
Q2 bounds with additive error tending to zero. Unlike the earlier
source_q2_quadratic_limit, the condition is only eventual along the
directed finite-coordinate net; no exact bound for every finite F is
required. Variance and all approximants use the original source law. -/
theorem eventual_q2_source_limit
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (R : ℝ) (hR : 0 ≤ R)
    (hfinite : ∀ ε : ℝ, 0 < ε →
      ∃ F : Finset ι, ∀ G : Finset ι, F ⊆ G →
        (sourceL2Variance μ
          (condExpL2 ℝ ℝ
            (sourceFiniteCoordinateSigma_le (X := X) G) f :
              Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))) ^ 2 ≤ R + ε) :
    (sourceL2Variance μ f) ^ 2 ≤ R := by
  classical
  let V := sourceL2Variance μ f
  have hV : 0 ≤ V := source_variance_nonneg μ f
  by_contra hn
  have hgap : 0 < V ^ 2 - R := by
    dsimp [V]
    linarith
  let δ : ℝ := (V ^ 2 - R) / (4 * (2 * V + 1))
  have hden : 0 < 4 * (2 * V + 1) := by positivity
  have hδ : 0 < δ := div_pos hgap hden
  have hδid : δ * (2 * V + 1) = (V ^ 2 - R) / 4 := by
    dsimp [δ]
    field_simp
  obtain ⟨Fa, ha⟩ := source_finite_info_variance_approx μ f δ hδ
  obtain ⟨Fb, hb⟩ := hfinite δ hδ
  let G : Finset ι := Fa ∪ Fb
  have hFaG : Fa ⊆ G := Finset.subset_union_left
  have hFbG : Fb ⊆ G := Finset.subset_union_right
  let P : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) :=
    (condExpL2 ℝ ℝ
      (sourceFiniteCoordinateSigma_le (X := X) G) f :
        Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
  let W := sourceL2Variance μ P
  have hW : 0 ≤ W := source_variance_nonneg μ P
  have hWle : W ≤ V := source_finite_info_variance_le μ G f
  have hVle : V ≤ W + δ := by
    simpa only [V, W, P] using ha G hFaG
  have hWsq : W ^ 2 ≤ R + δ := by
    simpa only [W, P] using hb G hFbG
  have hdiff : V - W ≤ δ := by linarith
  have hsum : V + W ≤ 2 * V := by linarith
  have hstep1 :
      (V - W) * (V + W) ≤ δ * (V + W) :=
    mul_le_mul_of_nonneg_right hdiff (add_nonneg hV hW)
  have hstep2 : δ * (V + W) ≤ δ * (2 * V) :=
    mul_le_mul_of_nonneg_left hsum hδ.le
  have hvar : V ^ 2 ≤ W ^ 2 + δ * (2 * V) := by
    nlinarith
  have hterminal : V ^ 2 ≤ R + δ * (2 * V + 1) := by
    nlinarith
  rw [hδid] at hterminal
  linarith

#print axioms Nightfall.InfinitePiQ2EventualTerminal.source_variance_nonneg
#print axioms Nightfall.InfinitePiQ2EventualTerminal.eventual_q2_source_limit

end Nightfall.InfinitePiQ2EventualTerminal
