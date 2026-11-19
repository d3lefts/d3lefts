import Mathlib

/-!
# An elementary initial separator for the strong failure smoother

Set B_k(z) = 1 - (1-z²)^k.
For 0 < ε ≤ 1/2, let k = floor(2/(5 ε²)).
We prove the endpoint comparison using *only* Bernoulli's inequality
and a finite induction; no probability distribution, Hoeffding lemma,
Markov/Bernstein assumption, or asymptotic theorem is needed.

The cubic amplifier in StrongSmoothingAmplifier can subsequently
turn the fixed [0,2/5]/[3/5,1] separation into arbitrary confidence.
-/

namespace Nightfall.StrongSimulation.SmoothingBase

open Finset

noncomputable def base (k : ℕ) (z : ℝ) : ℝ :=
  1 - (1 - z ^ 2) ^ k

/-- The classical Bernoulli inequality, elementary induction only. -/
theorem one_sub_pow_lower (n : ℕ) (p : ℝ)
    (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    1 - (n : ℝ) * p ≤ (1 - p) ^ n := by
  induction n with
  | zero => norm_num
  | succ n ih =>
      have hq : 0 ≤ 1 - p := by linarith
      have hm := mul_le_mul_of_nonneg_right ih hq
      have hpn : 0 ≤ (n : ℝ) * p ^ 2 :=
        mul_nonneg (Nat.cast_nonneg _) (sq_nonneg _)
      rw [pow_succ]
      push_cast
      nlinarith

/-- A second elementary Bernoulli estimate, in the direction useful
for the large-error branch. -/
theorem one_sub_pow_product_upper (n : ℕ) (x : ℝ)
    (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    (1 - x) ^ n * (1 + (n : ℝ) * x) ≤ 1 := by
  induction n with
  | zero => norm_num
  | succ n ih =>
      have hb : 0 ≤ (1 - x) ^ n := pow_nonneg (by linarith) n
      have hstep : (1 - x) * (1 + ((n : ℝ) + 1) * x) ≤
          1 + (n : ℝ) * x := by
        have hsq : 0 ≤ ((n : ℝ) + 1) * x ^ 2 :=
          mul_nonneg (by positivity) (sq_nonneg _)
        nlinarith
      have hm := mul_le_mul_of_nonneg_left hstep hb
      rw [pow_succ]
      push_cast
      nlinarith

theorem base_mono (k : ℕ) (p q : ℝ)
    (hp0 : 0 ≤ p) (hpq : p ≤ q) (hq1 : q ≤ 1) :
    1 - (1 - p) ^ k ≤ 1 - (1 - q) ^ k := by
  have h1 : 0 ≤ 1 - q := by linarith
  have h2 : 1 - q ≤ 1 - p := by linarith
  have hpow := pow_le_pow_left₀ h1 h2 k
  linarith

/-- A completely algebraic separation using only inequalities for
the chosen integer k. The upper branch is a union bound, while the
lower branch uses (1-x)^n(1+nx)≤1.

The p variable is ε², but is kept abstract to make this useful elsewhere. -/
theorem base_gap_of_integer_budget
    (k : ℕ) (p : ℝ)
    (hp0 : 0 < p) (hp1 : p ≤ 1 / 4)
    (hk : 1 ≤ k)
    (hkUpper : (k : ℝ) * p ≤ 2 / 5)
    (hkLower : 2 / 5 ≤ ((k : ℝ) + 1) * p) :
    (1 - (1 - p) ^ k ≤ 2 / 5) ∧
    (3 / 5 ≤ 1 - (1 - 4 * p) ^ k) := by
  have hpunit : p ≤ 1 := by linarith
  have hsmall := one_sub_pow_lower k p (le_of_lt hp0) hpunit
  have hlow : 1 - (1 - p) ^ k ≤ 2 / 5 := by linarith
  let n := k - 1
  have hnk : n + 1 = k := Nat.sub_add_cancel hk
  have hnr : (n : ℝ) + 1 = (k : ℝ) := by exact_mod_cast hnk
  have hx0 : 0 ≤ 4 * p := by positivity
  have hx1 : 4 * p ≤ 1 := by linarith
  have hproduct := one_sub_pow_product_upper n (4 * p) hx0 hx1
  have hcoef : 0 ≤ p * ((8 : ℝ) * (k : ℝ) + 12 -
      (15 / 2) * ((k : ℝ) + 1)) := by
    have hk0 : 0 ≤ (k : ℝ) := Nat.cast_nonneg _
    have hfactor : 0 ≤ (8 : ℝ) * (k : ℝ) + 12 -
        (15 / 2) * ((k : ℝ) + 1) := by nlinarith
    exact mul_nonneg (le_of_lt hp0) hfactor
  have hthreshold : 3 ≤ (2 * (k : ℝ) + 3) * (4 * p) := by
    nlinarith [hkLower, hcoef]
  have hthreshold_n : 1 - 4 * p ≤
      (2 / 5 : ℝ) * (1 + (n : ℝ) * (4 * p)) := by
    nlinarith [hthreshold]
  have hmul :
      (1 - 4 * p) ^ k * (1 + (n : ℝ) * (4 * p)) ≤ 1 - 4 * p := by
    calc
      (1 - 4 * p) ^ k * (1 + (n : ℝ) * (4 * p)) =
        ((1 - 4 * p) ^ n * (1 + (n : ℝ) * (4 * p))) *
        (1 - 4 * p) := by
          rw [← hnk, pow_succ]
          ring
      _ ≤ 1 * (1 - 4 * p) :=
        mul_le_mul_of_nonneg_right hproduct (by linarith)
      _ = 1 - 4 * p := by ring
  have hden : 0 < 1 + (n : ℝ) * (4 * p) := by
    have hn0 : 0 ≤ (n : ℝ) := Nat.cast_nonneg _
    positivity
  have hb : (1 - 4 * p) ^ k ≤ 2 / 5 := by
    have hm : (1 - 4 * p) ^ k * (1 + (n : ℝ) * (4 * p)) ≤
        (2 / 5 : ℝ) * (1 + (n : ℝ) * (4 * p)) :=
      le_trans hmul hthreshold_n
    by_contra hnle
    have hh : (2 / 5 : ℝ) < (1 - 4 * p) ^ k := lt_of_not_ge hnle
    have hc : 0 < ((1 - 4 * p) ^ k - (2 / 5 : ℝ)) *
        (1 + (n : ℝ) * (4 * p)) :=
      mul_pos (sub_pos.mpr hh) hden
    nlinarith
  exact ⟨hlow, by linarith⟩

/-- Concrete integer selection, no circular choice. -/
noncomputable def thresholdCount (ε : ℝ) : ℕ :=
  ⌊(2 / 5 : ℝ) / ε ^ 2⌋₊

theorem thresholdCount_budget (ε : ℝ)
    (hε : 0 < ε) (hε1 : ε ≤ 1 / 2) :
    1 ≤ thresholdCount ε ∧
    ((thresholdCount ε : ℕ) : ℝ) * ε ^ 2 ≤ 2 / 5 ∧
    2 / 5 ≤ (((thresholdCount ε : ℕ) : ℝ) + 1) * ε ^ 2 := by
  have hp : 0 < ε ^ 2 := pow_pos hε _
  have hp1 : ε ^ 2 ≤ 1 / 4 := by nlinarith
  have hq : (1 : ℝ) ≤ (2 / 5 : ℝ) / ε ^ 2 := by
    apply (le_div_iff₀ hp).2
    nlinarith
  have hpos : 0 ≤ (2 / 5 : ℝ) / ε ^ 2 := by positivity
  have hfloor : (thresholdCount ε : ℝ) ≤ (2 / 5 : ℝ) / ε ^ 2 := by
    exact Nat.floor_le hpos
  have hnext : (2 / 5 : ℝ) / ε ^ 2 < (thresholdCount ε : ℝ) + 1 := by
    simpa only [thresholdCount, Nat.cast_add, Nat.cast_one] using
      (Nat.lt_floor_add_one ((2 / 5 : ℝ) / ε ^ 2))
  have hcount : 1 ≤ thresholdCount ε := by
    unfold thresholdCount
    exact Nat.le_floor (show ((1 : ℕ) : ℝ) ≤ (2 / 5 : ℝ) / ε ^ 2 by simpa using hq)
  constructor
  · exact hcount
  constructor
  · have h := mul_le_mul_of_nonneg_right hfloor (le_of_lt hp)
    rwa [div_mul_cancel₀ (2 / 5 : ℝ) (ne_of_gt hp)] at h
  · have h := mul_lt_mul_of_pos_right hnext hp
    rw [div_mul_cancel₀ (2 / 5 : ℝ) (ne_of_gt hp)] at h
    exact le_of_lt h

theorem base_separator (ε z : ℝ)
    (hε : 0 < ε) (hε1 : ε ≤ 1 / 2)
    (hz : |z| ≤ 1) :
    (|z| ≤ ε → base (thresholdCount ε) z ≤ 2 / 5) ∧
    (2 * ε ≤ |z| → 3 / 5 ≤ base (thresholdCount ε) z) := by
  have hbudget := thresholdCount_budget ε hε hε1
  have hgap := base_gap_of_integer_budget (thresholdCount ε) (ε ^ 2)
    (pow_pos hε _) (by nlinarith) hbudget.1 hbudget.2.1 hbudget.2.2
  have hzsq : z ^ 2 ≤ 1 := by
    have ha := (abs_le.mp hz)
    nlinarith [mul_nonneg (sub_nonneg.mpr ha.2) (by linarith [ha.1] : 0 ≤ 1 + z)]
  have hsq0 : 0 ≤ z ^ 2 := sq_nonneg _
  constructor
  · intro hsmall
    have hsq : z ^ 2 ≤ ε ^ 2 := by
      have hh := mul_nonneg (sub_nonneg.mpr hsmall)
        (add_nonneg (le_of_lt hε) (abs_nonneg z))
      nlinarith [hh, sq_abs z]
    unfold base
    have hm := base_mono (thresholdCount ε) (z ^ 2) (ε ^ 2)
      hsq0 hsq (by nlinarith)
    exact le_trans hm hgap.1
  · intro hlarge
    have hsq : 4 * ε ^ 2 ≤ z ^ 2 := by
      have hh := mul_nonneg (sub_nonneg.mpr hlarge)
        (add_nonneg (abs_nonneg z) (by positivity : 0 ≤ 2 * ε))
      nlinarith [hh, sq_abs z]
    unfold base
    have hm := base_mono (thresholdCount ε) (4 * ε ^ 2) (z ^ 2)
      (by positivity) hsq hzsq
    exact le_trans hgap.2 hm

end Nightfall.StrongSimulation.SmoothingBase
