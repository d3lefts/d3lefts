import Mathlib

/-!
# Fair-cubic rainbow: kernel-certified downstream algebra

This file is deliberately scoped. The original-source degree-three theorem in
PR #807 is NOT obtained here from Fourier coefficients or source conditional
expectations. The sector bounds and source Poincare estimate must be supplied
as hypotheses. In particular the anchored multipartite Khintchine step in
PR #804 is NOT assumed as an axiom or silently declared proved.

Named declarations certify:
* the parity/count obstruction underlying 2- and 3-color projectors;
* exact recombination of the three sector estimates, including coefficient
  152 + 48 sqrt 2, strictly smaller than 220;
* the finite-k algebraic hybrid transfer, CONDITIONAL on its actual analytic
  fair-sector and source-Poincare prerequisites.

No `sorry`, custom `axiom`, or unsafe proof shortcuts are permitted by CI.
-/

namespace Nightfall.CubicQ3.FairRainbow

/-- Two odd color-class counts with total degree at most three force degree two. -/
theorem two_odd_colors_force_degree_two
    (a b : ℕ) (ha : a % 2 = 1) (hb : b % 2 = 1)
    (hdeg : a + b ≤ 3) : a + b = 2 := by
  omega

/-- Three odd color-class counts with total degree at most three force degree three. -/
theorem three_odd_colors_force_degree_three
    (a b c : ℕ) (ha : a % 2 = 1) (hb : b % 2 = 1)
    (hc : c % 2 = 1) (hdeg : a + b + c ≤ 3) :
    a + b + c = 3 := by
  omega

private theorem square_le_of_nonneg_le (a b : ℝ)
    (ha : 0 ≤ a) (hab : a ≤ b) : a ^ 2 ≤ b ^ 2 := by
  have hb : 0 ≤ b := le_trans ha hab
  have hd : 0 ≤ (b - a) * (b + a) :=
    mul_nonneg (sub_nonneg.mpr hab) (add_nonneg hb ha)
  nlinarith

private theorem sqrt_two_bound :
    Real.sqrt (2 : ℝ) ≤ (283 / 200 : ℝ) := by
  have hs : (Real.sqrt (2 : ℝ)) ^ 2 = 2 := by
    rw [Real.sq_sqrt (by norm_num)]
  have hn : 0 ≤ Real.sqrt (2 : ℝ) := Real.sqrt_nonneg _
  nlinarith

/-- Pure algebraic sector recombination. This is NOT a derivation of the three
sector estimates; they are explicit quantified hypotheses. -/
theorem fair_cubic_from_sector_bounds
    (B M V₁ V₂ V₃ : ℝ)
    (hB : 0 ≤ B) (hM : 0 ≤ M)
    (hV₁ : 0 ≤ V₁) (hV₂ : 0 ≤ V₂) (hV₃ : 0 ≤ V₃)
    (h₁ : V₁ ≤ 3 * (B * Real.sqrt M))
    (h₂ : V₂ ≤ 2 * Real.sqrt (2 : ℝ) * (B * Real.sqrt M))
    (h₃ : V₃ ≤ 9 * (B * Real.sqrt M)) :
    (V₁ + V₂ + V₃) ^ 2 ≤
      (152 + 48 * Real.sqrt (2 : ℝ)) * B ^ 2 * M := by
  let z : ℝ := B * Real.sqrt M
  have hz : 0 ≤ z := mul_nonneg hB (Real.sqrt_nonneg _)
  have h₁' : V₁ ≤ 3 * z := h₁
  have h₂' : V₂ ≤ (2 * Real.sqrt (2 : ℝ)) * z := h₂
  have h₃' : V₃ ≤ 9 * z := h₃
  have hsum : V₁ + V₂ + V₃ ≤ (12 + 2 * Real.sqrt (2 : ℝ)) * z := by
    nlinarith [h₁', h₂', h₃']
  have hsum0 : 0 ≤ V₁ + V₂ + V₃ := by
    linarith
  have hsq :=
    square_le_of_nonneg_le (V₁ + V₂ + V₃)
      ((12 + 2 * Real.sqrt (2 : ℝ)) * z) hsum0 hsum
  have hroot : (Real.sqrt (2 : ℝ)) ^ 2 = 2 := by
    rw [Real.sq_sqrt (by norm_num)]
  have hcoef : (12 + 2 * Real.sqrt (2 : ℝ)) ^ 2 =
      152 + 48 * Real.sqrt (2 : ℝ) := by
    nlinarith [hroot]
  calc
    (V₁ + V₂ + V₃) ^ 2 ≤
        ((12 + 2 * Real.sqrt (2 : ℝ)) * z) ^ 2 := hsq
    _ = (152 + 48 * Real.sqrt (2 : ℝ)) * B ^ 2 * M := by
      rw [mul_pow, hcoef]
      dsimp [z]
      rw [mul_pow, Real.sq_sqrt hM]
      ring

/-- The displayed exact d=3 coefficient is strictly smaller than 220. -/
theorem cubic_coefficient_lt_220 :
    152 + 48 * Real.sqrt (2 : ℝ) < 220 := by
  have h := sqrt_two_bound
  norm_num at *
  linarith

/-- Coarse rational terminal estimate for the same conditional sector data. -/
theorem fair_cubic_220_from_sector_bounds
    (B M V₁ V₂ V₃ : ℝ)
    (hB : 0 ≤ B) (hM : 0 ≤ M)
    (hV₁ : 0 ≤ V₁) (hV₂ : 0 ≤ V₂) (hV₃ : 0 ≤ V₃)
    (h₁ : V₁ ≤ 3 * (B * Real.sqrt M))
    (h₂ : V₂ ≤ 2 * Real.sqrt (2 : ℝ) * (B * Real.sqrt M))
    (h₃ : V₃ ≤ 9 * (B * Real.sqrt M)) :
    (V₁ + V₂ + V₃) ^ 2 ≤ 220 * B ^ 2 * M := by
  have hmain := fair_cubic_from_sector_bounds
    B M V₁ V₂ V₃ hB hM hV₁ hV₂ hV₃ h₁ h₂ h₃
  have hcoeff := le_of_lt cubic_coefficient_lt_220
  have hBM : 0 ≤ B ^ 2 * M := mul_nonneg (sq_nonneg _) hM
  calc
    _ ≤ (152 + 48 * Real.sqrt (2 : ℝ)) * (B ^ 2 * M) := by
      convert hmain using 1 <;> ring
    _ ≤ 220 * (B ^ 2 * M) :=
      mul_le_mul_of_nonneg_right hcoeff hBM
    _ = 220 * B ^ 2 * M := by ring

/-- Downstream finite-k algebraic hybrid, with the source Poincare residual
and fair-cube estimate both EXPLICIT hypotheses. Nothing in this theorem
proves those hypotheses for an arbitrary original-product function. -/
theorem hybrid_from_fair_and_poincare
    (k : ℕ) (B M V Vfair S : ℝ)
    (hB : 0 ≤ B) (hM : 0 ≤ M) (hV : 0 ≤ V) (hVfair : 0 ≤ Vfair)
    (hfair : Vfair ^ 2 ≤ 220 * B ^ 2 * M)
    (hPoincare : V ≤ Vfair + S)
    (hS : S ≤ (k : ℝ) * M)
    (hMcap : M ≤ B ^ 2) :
    V ^ 2 ≤ (Real.sqrt (220 : ℝ) + (k : ℝ)) ^ 2 * B ^ 2 * M := by
  let s : ℝ := Real.sqrt M
  let z : ℝ := B * s
  let t : ℝ := Real.sqrt (220 : ℝ) * z
  have hs0 : 0 ≤ s := Real.sqrt_nonneg _
  have hs2 : s ^ 2 = M := Real.sq_sqrt hM
  have h2202 : (Real.sqrt (220 : ℝ)) ^ 2 = 220 :=
    Real.sq_sqrt (by norm_num)
  have hz0 : 0 ≤ z := mul_nonneg hB hs0
  have ht0 : 0 ≤ t :=
    mul_nonneg (Real.sqrt_nonneg _) hz0
  have ht2 : t ^ 2 = 220 * B ^ 2 * M := by
    dsimp [t, z, s]
    rw [mul_pow, mul_pow, h2202, Real.sq_sqrt hM]
    ring
  have hVfairle : Vfair ≤ t := by
    nlinarith [hfair]
  have hsB : s ≤ B := by
    nlinarith [hs2, hMcap]
  have hMz : M ≤ z := by
    have hmul := mul_le_mul_of_nonneg_right hsB hs0
    dsimp [z]
    nlinarith [hs2, hmul]
  have hSle : S ≤ (k : ℝ) * z :=
    le_trans hS (mul_le_mul_of_nonneg_left hMz (Nat.cast_nonneg _))
  have hupper : V ≤ (Real.sqrt (220 : ℝ) + (k : ℝ)) * z := by
    dsimp [t] at hVfairle
    nlinarith [hPoincare, hVfairle, hSle]
  have hsq := square_le_of_nonneg_le V
    ((Real.sqrt (220 : ℝ) + (k : ℝ)) * z) hV hupper
  calc
    V ^ 2 ≤ ((Real.sqrt (220 : ℝ) + (k : ℝ)) * z) ^ 2 := hsq
    _ = (Real.sqrt (220 : ℝ) + (k : ℝ)) ^ 2 * B ^ 2 * M := by
      rw [mul_pow]
      dsimp [z, s]
      rw [mul_pow, Real.sq_sqrt hM]
      ring

end Nightfall.CubicQ3.FairRainbow
