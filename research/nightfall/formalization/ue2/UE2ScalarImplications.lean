import Mathlib

/-!
# UE2 scalar implication gates (unconditional deductions between *assumed* claims)

These are theorems of real arithmetic, not proofs of N-UE2(2), N-UE2(6),
the unrestricted cubic problem, nor finite-to-infinite original law transfer.
The analytic hypotheses explicitly supply the conjectured inequality at the
source function where it is needed.

Influence conversion: for uniform signs, square-flip influence equals
four times the original conditional-variance (resampling) influence.
The [0,1] to [-1,1] affine map g = 2 p - 1 yields the factor 16.
-/

namespace Nightfall.UE2.ScalarImplications

/-- The sharp-degree d² claim implies the conservative d⁶ claim with
the same constant. This does not assert the d² hypothesis. -/
theorem degree_two_cost_implies_degree_six_cost
    (C B M V : ℝ) (d : ℕ)
    (hC : 0 ≤ C) (hM : 0 ≤ M) (hd : 1 ≤ d)
    (h2 : V ^ 2 ≤ C * (d : ℝ) ^ 2 * B ^ 2 * M) :
    V ^ 2 ≤ C * (d : ℝ) ^ 6 * B ^ 2 * M := by
  have hdreal : (1 : ℝ) ≤ (d : ℝ) := by exact_mod_cast hd
  have hd4 : (1 : ℝ) ≤ (d : ℝ) ^ 4 := one_le_pow₀ hdreal
  have hdegree : (d : ℝ) ^ 2 ≤ (d : ℝ) ^ 6 := by
    calc
      (d : ℝ) ^ 2 = (d : ℝ) ^ 2 * 1 := by ring
      _ ≤ (d : ℝ) ^ 2 * (d : ℝ) ^ 4 :=
        mul_le_mul_of_nonneg_left hd4 (sq_nonneg (d : ℝ))
      _ = (d : ℝ) ^ 6 := by ring
  have hcoeff : 0 ≤ C * B ^ 2 * M := by positivity
  have hscaled := mul_le_mul_of_nonneg_left hdegree hcoeff
  calc
    V ^ 2 ≤ C * (d : ℝ) ^ 2 * B ^ 2 * M := h2
    _ = (C * B ^ 2 * M) * (d : ℝ) ^ 2 := by ring
    _ ≤ (C * B ^ 2 * M) * (d : ℝ) ^ 6 := hscaled
    _ = C * (d : ℝ) ^ 6 * B ^ 2 * M := by ring

/-- For a fair bit, the source conditional variance of the two values
a,b is (a-b)²/4, whereas full squared-flip influence is (a-b)². -/
theorem fair_flip_equals_four_resample (a b : ℝ) :
    (a - b) ^ 2 = 4 * ((a - b) ^ 2 / 4) := by ring

/-- Quantitative original AA [0,1] implication, expressed in a form
avoiding division by the conjectured constant. Here V=Var(p),
I=Inf_flip(p)=Inf_resample(2p-1), and B bounds the half-range of 2p-1.
The premise is **the conjectured source inequality at g=2p-1**. -/
theorem six_cost_implies_aa_flip
    (C B V I : ℝ) (d : ℕ)
    (hC : 0 ≤ C) (hI : 0 ≤ I)
    (hB : 0 ≤ B) (hB1 : B ≤ 1)
    (hsource : (4 * V) ^ 2 ≤ C * (d : ℝ) ^ 6 * B ^ 2 * I) :
    16 * V ^ 2 ≤ C * (d : ℝ) ^ 6 * I := by
  have hBsq : B ^ 2 ≤ 1 := by nlinarith
  have hcoeff : 0 ≤ C * (d : ℝ) ^ 6 * I := by positivity
  calc
    16 * V ^ 2 = (4 * V) ^ 2 := by ring
    _ ≤ C * (d : ℝ) ^ 6 * B ^ 2 * I := hsource
    _ = (C * (d : ℝ) ^ 6 * I) * B ^ 2 := by ring
    _ ≤ (C * (d : ℝ) ^ 6 * I) * 1 :=
      mul_le_mul_of_nonneg_left hBsq hcoeff
    _ = C * (d : ℝ) ^ 6 * I := by ring

/-- Scalar dominance of Turturean's exponent 5/2 whenever
the proposed AA coefficient obeys C*t<=32 and V<=1/4.
This theorem never supplies the UE2 premise itself. -/
theorem aa_flip_implies_five_halves_at_threshold
    (C t V I : ℝ) (d : ℕ)
    (hC : 0 ≤ C) (ht : 0 ≤ t)
    (hV : 0 ≤ V) (hVmax : V ≤ 1 / 4)
    (hI : 0 ≤ I) (hCt : C * t ≤ 32)
    (hAA : 16 * V ^ 2 ≤ C * (d : ℝ) ^ 6 * I) :
    t * V ^ 2 * Real.sqrt V ≤ (d : ℝ) ^ 6 * I := by
  let z : ℝ := (d : ℝ) ^ 6 * I
  have hz : 0 ≤ z := by dsimp [z]; positivity
  have hroot0 : 0 ≤ Real.sqrt V := Real.sqrt_nonneg _
  have hroot2 : (Real.sqrt V) ^ 2 = V := Real.sq_sqrt hV
  have hrootBound : Real.sqrt V ≤ 1 / 2 := by nlinarith
  have hCtRoot : C * t * Real.sqrt V ≤ 16 := by
    have hh := mul_le_mul_of_nonneg_right hCt hroot0
    nlinarith
  have htr : 0 ≤ t * Real.sqrt V := mul_nonneg ht hroot0
  have hscaled := mul_le_mul_of_nonneg_right hAA htr
  have hfactor := mul_le_mul_of_nonneg_right hCtRoot hz
  have hresult : 16 * (t * V ^ 2 * Real.sqrt V) ≤ 16 * z := by
    calc
      16 * (t * V ^ 2 * Real.sqrt V) =
          (16 * V ^ 2) * (t * Real.sqrt V) := by ring
      _ ≤ (C * z) * (t * Real.sqrt V) := by
          exact hscaled
      _ = (C * t * Real.sqrt V) * z := by ring
      _ ≤ 16 * z := hfactor
  dsimp [z] at hresult
  linarith

/-- Exact constant conversion for Turturean's printed flip-influence
t = 8 sqrt(15)/(125 pi^4) and the dominance threshold
C <= 500 pi^4/sqrt(15). -/
theorem turturean_threshold_constant
    (C : ℝ)
    (hC : C ≤ 500 * Real.pi ^ 4 / Real.sqrt 15) :
    C * (8 * Real.sqrt 15 / (125 * Real.pi ^ 4)) ≤ 32 := by
  have hnonneg : 0 ≤ 8 * Real.sqrt 15 / (125 * Real.pi ^ 4) := by
    positivity
  calc
    C * (8 * Real.sqrt 15 / (125 * Real.pi ^ 4)) ≤
        (500 * Real.pi ^ 4 / Real.sqrt 15) *
          (8 * Real.sqrt 15 / (125 * Real.pi ^ 4)) :=
            mul_le_mul_of_nonneg_right hC hnonneg
    _ = 32 := by
      have hpi : Real.pi ≠ 0 := ne_of_gt Real.pi_pos
      have hs : Real.sqrt (15 : ℝ) ≠ 0 :=
        ne_of_gt (Real.sqrt_pos.2 (by norm_num))
      field_simp [hpi, hs]
      <;> ring

end Nightfall.UE2.ScalarImplications
