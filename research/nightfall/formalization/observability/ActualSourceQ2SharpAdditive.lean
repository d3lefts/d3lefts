import ActualSourceNoiseEfronStein
import ActualSourceSingletonEnergyBridge
import ActualSourceSectionBudgetEight

/-!
# Original-source Q2 sharp additive coefficient: source proof in development

The exact scalar interpolation and homogeneous soft-refresh multiplier
are proved first, rather than taking a source additive budget as an axiom.
The remaining theorem must construct the degree-two spectral decomposition,
attain the actual singleton coordinate extrema and apply weighted Popoviciu.
No terminal theorem is claimed merely from this component.
-/

namespace Nightfall.Observability.ActualSourceQ2SharpAdditive

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductSourceDerivedStar
open Nightfall.Observability.ActualProductSoftNoise
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceNoiseEfronStein
open Nightfall.Observability.ActualSourceSingletonEnergyBridge
open Nightfall.Observability.ActualSourceMeanSectionJensen
open Nightfall.Observability.ActualSourceSectionBudgetEight

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- Uniform original-source retention has exact degree-|S| multiplier. -/
theorem original_uniform_mask_weight (t : ℝ) (S : Finset ι) :
    (∏ i : ι, if i ∈ S then t else 1) = t ^ S.card := by
  classical
  rw [Finset.prod_ite_mem_eq]
  simp

/-- Exact scalar Chebyshev interpolation for bounded degree-two noise.
This lemma has no source/model assumptions and is an independently
checkable algebraic gate. -/
theorem quadratic_noise_linear_coefficient_le
    (B U W : ℝ) (hB : 0 ≤ B)
    (h1 : |U + W| ≤ 2 * B)
    (hs : |(Real.sqrt 2 - 1) * U +
            (Real.sqrt 2 - 1)^2 * W| ≤ 2 * B) :
    |U| ≤ 4 * (1 + Real.sqrt 2) * B := by
  let q : ℝ := Real.sqrt 2
  let t : ℝ := q - 1
  have hq0 : 0 ≤ q := Real.sqrt_nonneg 2
  have hq2 : q ^ 2 = 2 := by
    dsimp [q]
    exact Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 2)
  have hq1 : 1 < q := by nlinarith
  have hqU : q < 2 := by nlinarith
  have ht0 : 0 < t := by dsimp [t]; linarith
  have ht1 : t < 1 := by dsimp [t]; linarith
  have ha : 0 < t - t^2 := by
    have hprod : 0 < t * (1 - t) :=
      mul_pos ht0 (by linarith)
    nlinarith
  have ht2 : t^2 = 3 - 2 * q := by
    dsimp [t]
    nlinarith [hq2]
  have hcoef : (t - t^2) * (4 * (1 + q)) = 2 * (1 + t^2) := by
    rw [ht2]
    dsimp [t]
    nlinarith [hq2]
  have hquad : |t * U + t^2 * W| ≤ 2 * B := by
    simpa only [t, q] using hs
  have hident :
      (t - t^2) * U = (t * U + t^2 * W) - t^2 * (U + W) := by
    ring
  have htriangle :
      |(t - t^2) * U| ≤
        |t * U + t^2 * W| + |t^2 * (U + W)| := by
    rw [hident]
    exact abs_sub_le (t * U + t^2 * W) (t^2 * (U + W))
  have hweighted : |t^2 * (U + W)| ≤ t^2 * (2 * B) := by
    rw [abs_mul, abs_of_nonneg (sq_nonneg t)]
    exact mul_le_mul_of_nonneg_left h1 (sq_nonneg t)
  have hlinear :
      (t - t^2) * |U| ≤ (t - t^2) * (4 * (1 + q) * B) := by
    have hscale : (t - t^2) * (4 * (1 + q) * B) =
        2 * B + t^2 * (2 * B) := by
      calc
        (t - t^2) * (4 * (1 + q) * B) =
            ((t - t^2) * (4 * (1 + q))) * B := by ring
        _ = (2 * (1 + t^2)) * B := by rw [hcoef]
        _ = 2 * B + t^2 * (2 * B) := by ring
    calc
      (t - t^2) * |U| = |(t - t^2) * U| := by
        rw [abs_mul, abs_of_nonneg (le_of_lt ha)]
      _ ≤ |t * U + t^2 * W| + |t^2 * (U + W)| := htriangle
      _ ≤ 2 * B + t^2 * (2 * B) := add_le_add hquad hweighted
      _ = (t - t^2) * (4 * (1 + q) * B) := hscale.symm
  have hresult : |U| ≤ 4 * (1 + q) * B := by
    by_contra hn
    have hgt : 4 * (1 + q) * B < |U| := lt_of_not_ge hn
    have hgtmul := mul_lt_mul_of_pos_left hgt ha
    exact (not_lt_of_ge hlinear) hgtmul
  simpa only [q] using hresult

end Nightfall.Observability.ActualSourceQ2SharpAdditive
