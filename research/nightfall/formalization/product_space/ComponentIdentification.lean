import Mathlib

/-!
# Component identification for product laws: finite combinatorial core

Paper: `research/nightfall/strong_simulation_progress/COMPONENT_IDENTIFICATION_20261119.md`, Lemma 1.

This file certifies Steps 3–5 of the paper proof. Step 2, the Bernstein
inequality on the bias segment, enters as an explicit hypothesis `hBern`: for
each cell, the mean shift is at most `ε`.

* `mean_near`       : |E g - u| ≤ ε + (failure mass)  for g ∈ [0,1].
* `cell_cost`       : the mean-shift bound forces δ_P + δ_Q ≥ |u - v| - 3ε in every cell.
* `pay_per_cell`    : summing the per-cell cost gives Σ min(P, Q) ≤ 2δ / Δ.
* `component_identification_core` : the three steps above combined.
* `min_le_sqrt_mul`, `prod_one_sub_le_exp`, `hellinger_K_le` : Step 5.
-/

namespace Nightfall.ComponentIdentification

open Finset BigOperators

/-- Step 3a. A [0,1]-valued function has mean within `ε + d` of `u`, where `d` is
the mass of `{|g - u| > ε}`. -/
theorem mean_near {ι : Type*} (s : Finset ι) (w g : ι → ℝ) (u ε : ℝ)
    (hw : ∀ i ∈ s, 0 ≤ w i) (hsum : ∑ i ∈ s, w i = 1)
    (hg : ∀ i ∈ s, 0 ≤ g i ∧ g i ≤ 1) (hu : 0 ≤ u ∧ u ≤ 1) (hε : 0 ≤ ε) :
    |∑ i ∈ s, w i * g i - u| ≤
      ε + ∑ i ∈ s.filter (fun i => ε < |g i - u|), w i := by
  have hrw : ∑ i ∈ s, w i * g i - u = ∑ i ∈ s, w i * (g i - u) := by
    have : ∑ i ∈ s, w i * (g i - u) = ∑ i ∈ s, w i * g i - (∑ i ∈ s, w i) * u := by
      rw [Finset.sum_mul, ← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl (fun i _ => by ring)
    rw [this, hsum, one_mul]
  rw [hrw]
  have hpt : ∀ i ∈ s, |w i * (g i - u)| ≤
      w i * ε + (if ε < |g i - u| then w i else 0) := by
    intro i hi
    have hwi := hw i hi
    rw [abs_mul, abs_of_nonneg hwi]
    have hb : |g i - u| ≤ 1 := by
      rw [abs_le]; obtain ⟨h1, h2⟩ := hg i hi; constructor <;> linarith [hu.1, hu.2]
    split_ifs with h
    · nlinarith [mul_le_mul_of_nonneg_left hb hwi, mul_nonneg hwi hε]
    · have h := not_lt.mp h; nlinarith [mul_le_mul_of_nonneg_left h hwi]
  calc |∑ i ∈ s, w i * (g i - u)|
      ≤ ∑ i ∈ s, |w i * (g i - u)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i ∈ s, (w i * ε + (if ε < |g i - u| then w i else 0)) :=
        Finset.sum_le_sum hpt
    _ = ε + ∑ i ∈ s.filter (fun i => ε < |g i - u|), w i := by
        rw [Finset.sum_add_distrib, ← Finset.sum_mul, hsum, one_mul, Finset.sum_filter]

/-- Step 3b. In each cell, the mean shift is at most `ε` (Bernstein), and each
mean is near its centre. So the failure masses pay for the separation. -/
theorem cell_cost (EP EQ u v ε dP dQ : ℝ)
    (hBern : |EP - EQ| ≤ ε) (hP : |EP - u| ≤ ε + dP) (hQ : |EQ - v| ≤ ε + dQ) :
    |u - v| - 3 * ε ≤ dP + dQ := by
  have h1 : |u - v| ≤ |u - EP| + |EP - EQ| + |EQ - v| := by
    calc |u - v| = |(u - EP) + (EP - EQ) + (EQ - v)| := by ring_nf
      _ ≤ |(u - EP) + (EP - EQ)| + |EQ - v| := abs_add_le _ _
      _ ≤ |u - EP| + |EP - EQ| + |EQ - v| := by gcongr; exact abs_add_le _ _
  rw [abs_sub_comm u EP] at h1
  linarith

/-- Step 4. Summing the per-cell cost gives the total-variation bound. -/
theorem pay_per_cell {ι : Type*} (s : Finset ι) (P Q dP dQ : ι → ℝ) (Δ δ : ℝ)
    (hP0 : ∀ i ∈ s, 0 ≤ P i) (hQ0 : ∀ i ∈ s, 0 ≤ Q i)
    (hdP : ∀ i ∈ s, 0 ≤ dP i) (hdQ : ∀ i ∈ s, 0 ≤ dQ i)
    (hΔ : 0 < Δ) (hcell : ∀ i ∈ s, Δ ≤ dP i + dQ i)
    (hfailP : ∑ i ∈ s, P i * dP i ≤ δ) (hfailQ : ∑ i ∈ s, Q i * dQ i ≤ δ) :
    ∑ i ∈ s, min (P i) (Q i) ≤ 2 * δ / Δ := by
  rw [le_div_iff₀ hΔ]
  calc (∑ i ∈ s, min (P i) (Q i)) * Δ
      = ∑ i ∈ s, min (P i) (Q i) * Δ := Finset.sum_mul _ _ _
    _ ≤ ∑ i ∈ s, (P i * dP i + Q i * dQ i) := by
        apply Finset.sum_le_sum; intro i hi
        have hm0 : 0 ≤ min (P i) (Q i) := le_min (hP0 i hi) (hQ0 i hi)
        calc min (P i) (Q i) * Δ ≤ min (P i) (Q i) * (dP i + dQ i) :=
              mul_le_mul_of_nonneg_left (hcell i hi) hm0
          _ = min (P i) (Q i) * dP i + min (P i) (Q i) * dQ i := by ring
          _ ≤ P i * dP i + Q i * dQ i := by
              gcongr
              · exact hdP i hi
              · exact min_le_left _ _
              · exact hdQ i hi
              · exact min_le_right _ _
    _ = ∑ i ∈ s, P i * dP i + ∑ i ∈ s, Q i * dQ i := Finset.sum_add_distrib
    _ ≤ 2 * δ := by linarith

/-- Steps 3–4 combined. Cells are the assignments `x_L` of the large-gap
coordinates. `EP i` and `EQ i` are the conditional means of the restricted
function. `dP i` and `dQ i` are the conditional failure masses. -/
theorem component_identification_core {ι : Type*} (s : Finset ι)
    (P Q dP dQ EP EQ : ι → ℝ) (u v ε δ : ℝ)
    (hP0 : ∀ i ∈ s, 0 ≤ P i) (hQ0 : ∀ i ∈ s, 0 ≤ Q i)
    (hdP : ∀ i ∈ s, 0 ≤ dP i) (hdQ : ∀ i ∈ s, 0 ≤ dQ i)
    (hBern : ∀ i ∈ s, |EP i - EQ i| ≤ ε)
    (hmeanP : ∀ i ∈ s, |EP i - u| ≤ ε + dP i)
    (hmeanQ : ∀ i ∈ s, |EQ i - v| ≤ ε + dQ i)
    (hsep : 3 * ε < |u - v|)
    (hfailP : ∑ i ∈ s, P i * dP i ≤ δ) (hfailQ : ∑ i ∈ s, Q i * dQ i ≤ δ) :
    ∑ i ∈ s, min (P i) (Q i) ≤ 2 * δ / (|u - v| - 3 * ε) :=
  pay_per_cell s P Q dP dQ _ δ hP0 hQ0 hdP hdQ (by linarith)
    (fun i hi => cell_cost _ _ u v ε _ _ (hBern i hi) (hmeanP i hi) (hmeanQ i hi))
    hfailP hfailQ

/-- Step 5a. The Bayes error is at most the Bhattacharyya coefficient, pointwise. -/
theorem min_le_sqrt_mul (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    min a b ≤ Real.sqrt (a * b) := by
  rw [show min a b = Real.sqrt (min a b * min a b) by
        rw [Real.sqrt_mul_self (le_min ha hb)]]
  apply Real.sqrt_le_sqrt
  exact mul_le_mul (min_le_left _ _) (min_le_right _ _) (le_min ha hb) ha

/-- Step 5b. A product of Bhattacharyya coefficients `1 - h_i` is at most `exp(-Σ h_i)`. -/
theorem prod_one_sub_le_exp {ι : Type*} (s : Finset ι) (h : ι → ℝ)
    (h1 : ∀ i ∈ s, h i ≤ 1) :
    ∏ i ∈ s, (1 - h i) ≤ Real.exp (-∑ i ∈ s, h i) := by
  rw [← Finset.sum_neg_distrib, Real.exp_sum]
  exact Finset.prod_le_prod₀ (fun i hi => by linarith [h1 i hi])
    (fun i _ => by linarith [Real.add_one_le_exp (-h i)])

/-- Step 5c. Suppose each of `K` coordinates carries squared Hellinger distance
at least `η²/2`, and `K η²/2 ≥ log(1/δ)`. Then the product Bhattacharyya
coefficient is at most `δ`. -/
theorem hellinger_K_le {ι : Type*} (s : Finset ι) (h : ι → ℝ) (η δ : ℝ)
    (hδ : 0 < δ) (h1 : ∀ i ∈ s, h i ≤ 1) (hη : ∀ i ∈ s, η ^ 2 / 2 ≤ h i)
    (hK : Real.log (1 / δ) ≤ s.card * (η ^ 2 / 2)) :
    ∏ i ∈ s, (1 - h i) ≤ δ := by
  refine (prod_one_sub_le_exp s h h1).trans ?_
  have hsum : (s.card : ℝ) * (η ^ 2 / 2) ≤ ∑ i ∈ s, h i := by
    rw [← nsmul_eq_mul, ← Finset.sum_const]; exact Finset.sum_le_sum hη
  calc Real.exp (-∑ i ∈ s, h i) ≤ Real.exp (-Real.log (1 / δ)) := by
        apply Real.exp_le_exp.mpr; linarith
    _ = δ := by
        rw [one_div, Real.log_inv, neg_neg, Real.exp_log hδ]

end Nightfall.ComponentIdentification
