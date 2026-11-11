import Mathlib

/-!
NIGHTFALL spectral observation: the optimal sorted-tail inequality.

This is the exact deterministic optimization step converting a bound
on the sum of coordinate standard deviations into a nonadaptive
squared-error guarantee. No probability law or Hoeffding-to-observation
representation is assumed or proved here.

For head H and tail T, suppose each head weight >= u and each
nonnegative tail weight <= u, and total L1 budget <= A.
Then 4|H| * (tail squared L2 energy) <= A^2.

For |H|=q>0, this implies tail energy <= A^2/(4q), with the
constant 1/4 optimal for 2q equal weights. The inequality is
independent of the number of ambient coordinates.
-/

namespace Nightfall.Observability.SortedTail

open Finset

variable {ι : Type*} [DecidableEq ι]

/-- The exact head/tail split optimization, without hidden rank or
alphabet assumptions. For a sorted sequence, use H for q largest
weights and T for the unselected coordinates. -/
theorem tail_sq_four_card_bound
    (H T : Finset ι) (b : ι → ℝ) (u A : ℝ)
    (hu : 0 ≤ u)
    (hH : ∀ i ∈ H, u ≤ b i)
    (hT0 : ∀ i ∈ T, 0 ≤ b i)
    (hTu : ∀ i ∈ T, b i ≤ u)
    (hA : (∑ i ∈ H, b i) + (∑ i ∈ T, b i) ≤ A) :
    4 * (H.card : ℝ) * (∑ i ∈ T, (b i)^2) ≤ A ^ 2 := by
  have hHead : (H.card : ℝ) * u ≤ ∑ i ∈ H, b i := by
    calc
      (H.card : ℝ) * u = ∑ i ∈ H, u := by simp
      _ ≤ ∑ i ∈ H, b i :=
        Finset.sum_le_sum (fun i hi => hH i hi)
  have hTail : (∑ i ∈ T, (b i)^2) ≤ u * (∑ i ∈ T, b i) := by
    calc
      (∑ i ∈ T, (b i)^2) ≤ ∑ i ∈ T, u * b i := by
        apply Finset.sum_le_sum
        intro i hi
        have h0 := hT0 i hi
        have hh := hTu i hi
        nlinarith [mul_nonneg h0 (sub_nonneg.mpr hh)]
      _ = u * (∑ i ∈ T, b i) := by rw [Finset.mul_sum]
  have htailA : (∑ i ∈ T, b i) ≤ A - (H.card : ℝ) * u := by
    linarith
  have htailBound :
      (∑ i ∈ T, (b i)^2) ≤ u * (A - (H.card : ℝ) * u) := by
    exact le_trans hTail (mul_le_mul_of_nonneg_left htailA hu)
  have hcard : (0 : ℝ) ≤ (H.card : ℝ) := by positivity
  have hscaled :
      4 * (H.card : ℝ) * (∑ i ∈ T, (b i)^2) ≤
      4 * (H.card : ℝ) *
        (u * (A - (H.card : ℝ) * u)) := by
    exact mul_le_mul_of_nonneg_left htailBound (by positivity)
  nlinarith [sq_nonneg (A - 2 * (H.card : ℝ) * u)]

/-- The conventional q-query error bound, obtained by dividing the
exact four-card inequality by the positive count. -/
theorem tail_sq_bound
    (H T : Finset ι) (b : ι → ℝ) (u A : ℝ)
    (hcard : 0 < H.card)
    (hu : 0 ≤ u)
    (hH : ∀ i ∈ H, u ≤ b i)
    (hT0 : ∀ i ∈ T, 0 ≤ b i)
    (hTu : ∀ i ∈ T, b i ≤ u)
    (hA : (∑ i ∈ H, b i) + (∑ i ∈ T, b i) ≤ A) :
    (∑ i ∈ T, (b i)^2) ≤ A ^ 2 / (4 * (H.card : ℝ)) := by
  have hb := tail_sq_four_card_bound H T b u A hu hH hT0 hTu hA
  have hp : 0 < (4 : ℝ) * (H.card : ℝ) := by
    have hc : (0 : ℝ) < H.card := by exact_mod_cast hcard
    positivity
  exact (le_div_iff₀ hp).2 (by nlinarith [hb])

end Nightfall.Observability.SortedTail
