import Mathlib

/-!
NIGHTFALL sharp degree-one influence: exact range-to-variance algebra.

Sources: Wright, Bias-independent influence on product spaces, Theorem 2,
and Wright, Two Restricted Optimal-Variance Influence Bounds, Lemma 1.

For bounded additive functions on independent products, the analytic
inputs are: sum of coordinate oscillations <= 2B, Popoviciu variance
bounds I_i <= oscillation_i^2/4, additive ANOVA variance identity,
and I_i <= max influence M. This file certifies the entire quantitative
implication from those explicit analytic premises. It does NOT prove
the probability-space premises or the full degree-one theorem.
-/

namespace Nightfall.Restricted

open Finset

/-- The coordinate oscillation budget bounds the sum of influence
square roots, uniformly in the number of coordinates. -/
theorem root_influence_budget {n : ℕ}
    (I radius : Fin n → ℝ) (B : ℝ)
    (hI : ∀ i, 0 ≤ I i)
    (hradius : ∀ i, 0 ≤ radius i)
    (hvar : ∀ i, I i ≤ (radius i / 2) ^ 2)
    (hrange : (∑ i, radius i) ≤ 2 * B) :
    (∑ i, Real.sqrt (I i)) ≤ B := by
  have hcoordinate : ∀ i : Fin n, Real.sqrt (I i) ≤ radius i / 2 := by
    intro i
    have hs : (Real.sqrt (I i)) ^ 2 = I i := Real.sq_sqrt (hI i)
    have hpos : 0 ≤ Real.sqrt (I i) := Real.sqrt_nonneg _
    have hr : 0 ≤ radius i := hradius i
    have hb := hvar i
    nlinarith
  have hsum : (∑ i, Real.sqrt (I i)) ≤ ∑ i, radius i / 2 := by
    exact Finset.sum_le_sum (fun i _ => hcoordinate i)
  have hres : (∑ i, radius i / 2) = (∑ i, radius i) / 2 := by
    rw [Finset.sum_div]
  linarith

/-- Abstract sharp quantitative conclusion of the degree-one theorem,
with a general range bound |f| <= B. All analytic assumptions are
displayed: independent additive variance and range/variance bounds. -/
theorem sharp_additive_variance_bound {n : ℕ}
    (I radius : Fin n → ℝ) (V M B : ℝ)
    (hI : ∀ i, 0 ≤ I i)
    (hradius : ∀ i, 0 ≤ radius i)
    (hvar : ∀ i, I i ≤ (radius i / 2) ^ 2)
    (hrange : (∑ i, radius i) ≤ 2 * B)
    (hM : 0 ≤ M)
    (hmax : ∀ i, I i ≤ M)
    (hV : V = ∑ i, I i) :
    V ^ 2 ≤ B ^ 2 * M := by
  have hbudget : (∑ i, Real.sqrt (I i)) ≤ B :=
    root_influence_budget I radius B hI hradius hvar hrange
  have hpoint : ∀ i : Fin n,
      I i ≤ Real.sqrt M * Real.sqrt (I i) := by
    intro i
    have hs : Real.sqrt (I i) ≤ Real.sqrt M :=
      Real.sqrt_le_sqrt (hmax i)
    have hs0 : 0 ≤ Real.sqrt (I i) := Real.sqrt_nonneg _
    calc
      I i = (Real.sqrt (I i)) ^ 2 := (Real.sq_sqrt (hI i)).symm
      _ = Real.sqrt (I i) * Real.sqrt (I i) := pow_two _
      _ ≤ Real.sqrt M * Real.sqrt (I i) :=
        mul_le_mul_of_nonneg_right hs hs0
  have hsum : (∑ i, I i) ≤
      Real.sqrt M * ∑ i, Real.sqrt (I i) := by
    calc
      (∑ i, I i) ≤ ∑ i, Real.sqrt M * Real.sqrt (I i) :=
        Finset.sum_le_sum (fun i _ => hpoint i)
      _ = Real.sqrt M * ∑ i, Real.sqrt (I i) := by
        rw [Finset.mul_sum]
  have hV0 : 0 ≤ V := by
    rw [hV]
    exact Finset.sum_nonneg (fun i _ => hI i)
  have hVB : V ≤ Real.sqrt M * B := by
    calc
      V = ∑ i, I i := hV
      _ ≤ Real.sqrt M * ∑ i, Real.sqrt (I i) := hsum
      _ ≤ Real.sqrt M * B :=
        mul_le_mul_of_nonneg_left hbudget (Real.sqrt_nonneg _)
  have hB0 : 0 ≤ B := by
    have hR0 : 0 ≤ ∑ i, radius i :=
      Finset.sum_nonneg (fun i _ => hradius i)
    linarith
  have hbound : V ^ 2 ≤ (Real.sqrt M * B) ^ 2 := by
    nlinarith [Real.sqrt_nonneg M]
  calc
    V ^ 2 ≤ (Real.sqrt M * B) ^ 2 := hbound
    _ = B ^ 2 * M := by
      rw [mul_pow, Real.sq_sqrt hM]
      ring

/-- With |f| <= 1 and total oscillation <= 2, the sharp exponent-two
constant one follows, conditional on the displayed analytic inputs. -/
theorem sharp_degree_one_consequence {n : ℕ}
    (I radius : Fin n → ℝ) (V M : ℝ)
    (hI : ∀ i, 0 ≤ I i)
    (hradius : ∀ i, 0 ≤ radius i)
    (hvar : ∀ i, I i ≤ (radius i / 2) ^ 2)
    (hrange : (∑ i, radius i) ≤ 2)
    (hM : 0 ≤ M)
    (hmax : ∀ i, I i ≤ M)
    (hV : V = ∑ i, I i) :
    V ^ 2 ≤ M := by
  have h := sharp_additive_variance_bound I radius V M (1 : ℝ)
    hI hradius hvar (by simpa using hrange) hM hmax hV
  norm_num at h ⊢
  exact h

end Nightfall.Restricted
