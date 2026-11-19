import Mathlib

/-!
# Cubic Q3: finite original-law anchored energy transfer

This formalizes the *complete deterministic recombination step* behind PR #804.
The nontrivial rowwise Rademacher/Khinchin--Kahane L1/L2 lower bound is
EXPLICIT as \`hRow\`, not an axiom or a claimed theorem. The source-specific
anchor range budget is separately kernel checked in AnchoredRangeBudget.lean.

The weights \`w\` are genuine external finite probability weights. No
exchange of expectation and maximum is used. The strength \`K\` is arbitrary;
\`K = 2\` is the cubic sharp two-block target, if its analytic L1/L2
hypothesis is independently proved.
-/

namespace Nightfall.CubicQ3.AnchoredEnergy
open Finset

/-- Given a pointwise anchor-row L² budget and a genuine rowwise averaged
Rademacher L1/L2 lower bound, the mixed L1(L2) influence bound follows.
This is NOT the proof of the Rademacher lower bound. -/
theorem mixed_norm_from_row_budget
    {ι σ : Type*} [Fintype ι] [Fintype σ]
    (w : σ → ℝ) (s : ι → σ → ℝ) (q : ι → ℝ)
    (B K : ℝ)
    (hw : ∀ t, 0 ≤ w t)
    (hwnorm : (∑ t, w t) = 1)
    (hbudget : ∀ t, (∑ i, s i t) ≤ B)
    (hrow : ∀ i, Real.sqrt (q i) ≤
      K * (∑ t, w t * s i t))
    (hK : 0 ≤ K) :
    (∑ i, Real.sqrt (q i)) ≤ K * B := by
  have hsum : (∑ i, Real.sqrt (q i)) ≤
      (∑ i, K * (∑ t, w t * s i t)) := by
    apply Finset.sum_le_sum
    intro i _
    exact hrow i
  have hswap :
      (∑ i, K * (∑ t, w t * s i t)) =
        K * (∑ t, w t * (∑ i, s i t)) := by
    calc
      (∑ i, K * (∑ t, w t * s i t)) =
          K * (∑ i, ∑ t, w t * s i t) := by rw [Finset.mul_sum]
      _ = K * (∑ t, ∑ i, w t * s i t) := by
        rw [Finset.sum_comm]
      _ = K * (∑ t, w t * (∑ i, s i t)) := by
        congr 1
        apply Finset.sum_congr rfl
        intro t _
        rw [Finset.mul_sum]
  have havg : (∑ t, w t * (∑ i, s i t)) ≤ B := by
    calc
      (∑ t, w t * (∑ i, s i t)) ≤
          (∑ t, w t * B) := by
        apply Finset.sum_le_sum
        intro t _
        exact mul_le_mul_of_nonneg_left (hbudget t) (hw t)
      _ = B := by
        rw [← Finset.sum_mul, hwnorm, one_mul]
  calc
    (∑ i, Real.sqrt (q i)) ≤
        (∑ i, K * (∑ t, w t * s i t)) := hsum
    _ = K * (∑ t, w t * (∑ i, s i t)) := hswap
    _ ≤ K * B := mul_le_mul_of_nonneg_left havg hK

/-- Final sharp-constant algebra: row energies sum to V and are bounded by
the largest ORIGINAL anchor influence M. This lemma proves the exponent-two
estimate with constant K², conditional ONLY on the named source-specific
row-L1 assumption and pointwise range budget above. -/
theorem anchored_exponent_two_from_row_khintchine
    {ι σ : Type*} [Fintype ι] [Fintype σ]
    (w : σ → ℝ) (s : ι → σ → ℝ) (q : ι → ℝ)
    (B K M : ℝ)
    (hw : ∀ t, 0 ≤ w t)
    (hwnorm : (∑ t, w t) = 1)
    (hbudget : ∀ t, (∑ i, s i t) ≤ B)
    (hrow : ∀ i, Real.sqrt (q i) ≤
      K * (∑ t, w t * s i t))
    (hK : 0 ≤ K) (hB : 0 ≤ B) (hM : 0 ≤ M)
    (hq : ∀ i, 0 ≤ q i)
    (hmax : ∀ i, q i ≤ M) :
    ((∑ i, q i) ^ 2) ≤ K ^ 2 * B ^ 2 * M := by
  have hsqrt : (∑ i, Real.sqrt (q i)) ≤ K * B :=
    mixed_norm_from_row_budget w s q B K hw hwnorm hbudget hrow hK
  have hsqrtM : 0 ≤ Real.sqrt M := Real.sqrt_nonneg _
  have hsqrtSq : Real.sqrt M ^ 2 = M := Real.sq_sqrt hM
  have hqsum : (∑ i, q i) ≤ Real.sqrt M * (∑ i, Real.sqrt (q i)) := by
    calc
      (∑ i, q i) ≤
          (∑ i, Real.sqrt M * Real.sqrt (q i)) := by
        apply Finset.sum_le_sum
        intro i _
        have hqi : Real.sqrt (q i) ≤ Real.sqrt M :=
          Real.sqrt_le_sqrt (hmax i)
        have hqi0 : 0 ≤ Real.sqrt (q i) := Real.sqrt_nonneg _
        have hqisq : (Real.sqrt (q i)) ^ 2 = q i :=
          Real.sq_sqrt (hq i)
        have hmul := mul_nonneg (sub_nonneg.mpr hqi) hqi0
        nlinarith
      _ = Real.sqrt M * (∑ i, Real.sqrt (q i)) := by
        rw [Finset.mul_sum]
  have hsum0 : 0 ≤ (∑ i, q i) := by
    apply Finset.sum_nonneg
    intro i _
    exact hq i
  have hupper : (∑ i, q i) ≤ K * B * Real.sqrt M := by
    have hh := mul_le_mul_of_nonneg_left hsqrt hsqrtM
    nlinarith [hqsum, hh]
  have hsq : (∑ i, q i) ^ 2 ≤ (K * B * Real.sqrt M) ^ 2 := by
    have he : 0 ≤ K * B * Real.sqrt M :=
      mul_nonneg (mul_nonneg hK hB) hsqrtM
    nlinarith [mul_nonneg (sub_nonneg.mpr hupper) (add_nonneg he hsum0)]
  calc
    (∑ i, q i) ^ 2 ≤ (K * B * Real.sqrt M) ^ 2 := hsq
    _ = K ^ 2 * B ^ 2 * M := by
      rw [mul_pow, mul_pow, Real.sq_sqrt hM]

/-- Exact cubic coefficient 4 follows with no algebraic loose ends, if the
analytic rowwise two-sign-block Khintchine input yields K=2. -/
theorem cubic_anchored_four_from_row_khintchine
    {ι σ : Type*} [Fintype ι] [Fintype σ]
    (w : σ → ℝ) (s : ι → σ → ℝ) (q : ι → ℝ)
    (B M : ℝ)
    (hw : ∀ t, 0 ≤ w t)
    (hwnorm : (∑ t, w t) = 1)
    (hbudget : ∀ t, (∑ i, s i t) ≤ B)
    (hrow : ∀ i, Real.sqrt (q i) ≤
      2 * (∑ t, w t * s i t))
    (hB : 0 ≤ B) (hM : 0 ≤ M)
    (hq : ∀ i, 0 ≤ q i)
    (hmax : ∀ i, q i ≤ M) :
    ((∑ i, q i) ^ 2) ≤ 4 * B ^ 2 * M := by
  convert anchored_exponent_two_from_row_khintchine
    w s q B 2 M hw hwnorm hbudget hrow (by norm_num)
    hB hM hq hmax using 1 <;> norm_num

end Nightfall.CubicQ3.AnchoredEnergy
