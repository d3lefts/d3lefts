import Mathlib

/-!
# NIGHTFALL: biased two-point quadratic product family

This file models the actual finite i.i.d. two-point source by repeatedly
splitting every weighted world into independent +1 and -1 children.
No asymptotic limit or Gaussian approximation is required.

The objective is a LOWER obstruction C₂ ≥ 4. The universal UPPER
inequality with coefficient 4 is not claimed.
-/

namespace Nightfall.Q2BernsteinLower

private def branch (p : ℝ) (xs : List (ℝ × ℝ)) : List (ℝ × ℝ) :=
  xs.flatMap (fun w => [(w.1 * p, w.2 + 1), (w.1 * (1-p), w.2 - 1)])

private def moment (k : ℕ) : List (ℝ × ℝ) → ℝ
  | [] => 0
  | w :: ws => w.1 * w.2 ^ k + moment k ws

private theorem branch_cons (p : ℝ) (w : ℝ × ℝ)
    (xs : List (ℝ × ℝ)) :
    branch p (w :: xs) =
      (w.1*p,w.2+1) :: (w.1*(1-p),w.2-1) :: branch p xs := by
  rfl

private theorem m0_step (p : ℝ) (xs : List (ℝ × ℝ)) :
    moment 0 (branch p xs) = moment 0 xs := by
  induction xs with
  | nil => simp [branch, moment]
  | cons w xs ih =>
      rw [branch_cons]
      simp only [moment, pow_zero, mul_one]
      rw [ih]
      ring

private theorem m1_step (p : ℝ) (xs : List (ℝ × ℝ)) :
    moment 1 (branch p xs) =
      moment 1 xs + (2*p-1)*moment 0 xs := by
  induction xs with
  | nil => simp [branch, moment]
  | cons w xs ih =>
      rw [branch_cons]
      simp only [moment, pow_one]
      rw [ih]
      ring

private theorem m2_step (p : ℝ) (xs : List (ℝ × ℝ)) :
    moment 2 (branch p xs) =
      moment 2 xs + 2*(2*p-1)*moment 1 xs + moment 0 xs := by
  induction xs with
  | nil => simp [branch, moment]
  | cons w xs ih =>
      rw [branch_cons]
      simp only [moment]
      rw [ih]
      ring

private theorem m3_step (p : ℝ) (xs : List (ℝ × ℝ)) :
    moment 3 (branch p xs) =
      moment 3 xs + 3*(2*p-1)*moment 2 xs +
        3*moment 1 xs + (2*p-1)*moment 0 xs := by
  induction xs with
  | nil => simp [branch, moment]
  | cons w xs ih =>
      rw [branch_cons]
      simp only [moment]
      rw [ih]
      ring

private theorem m4_step (p : ℝ) (xs : List (ℝ × ℝ)) :
    moment 4 (branch p xs) =
      moment 4 xs + 4*(2*p-1)*moment 3 xs + 6*moment 2 xs +
        4*(2*p-1)*moment 1 xs + moment 0 xs := by
  induction xs with
  | nil => simp [branch, moment]
  | cons w xs ih =>
      rw [branch_cons]
      simp only [moment]
      rw [ih]
      ring

/-- Every list member is an original product world: its first
coordinate is the product source mass and its second is the sign sum. -/
def source (p : ℝ) : ℕ → List (ℝ × ℝ)
  | 0 => [(1,0)]
  | n+1 => branch p (source p n)

def sourceMoment (p : ℝ) (n k : ℕ) : ℝ := moment k (source p n)

private theorem ms0 (p : ℝ) (n : ℕ) :
    sourceMoment p (n+1) 0 = sourceMoment p n 0 := by
  change moment 0 (branch p (source p n)) = moment 0 (source p n)
  exact m0_step p (source p n)

private theorem ms1 (p : ℝ) (n : ℕ) :
    sourceMoment p (n+1) 1 =
      sourceMoment p n 1 + (2*p-1)*sourceMoment p n 0 := by
  change moment 1 (branch p (source p n)) =
    moment 1 (source p n) + (2*p-1)*moment 0 (source p n)
  exact m1_step p (source p n)

private theorem ms2 (p : ℝ) (n : ℕ) :
    sourceMoment p (n+1) 2 =
      sourceMoment p n 2 + 2*(2*p-1)*sourceMoment p n 1 +
        sourceMoment p n 0 := by
  change moment 2 (branch p (source p n)) =
    moment 2 (source p n) + 2*(2*p-1)*moment 1 (source p n) +
      moment 0 (source p n)
  exact m2_step p (source p n)

private theorem ms3 (p : ℝ) (n : ℕ) :
    sourceMoment p (n+1) 3 =
      sourceMoment p n 3 + 3*(2*p-1)*sourceMoment p n 2 +
        3*sourceMoment p n 1 + (2*p-1)*sourceMoment p n 0 := by
  change moment 3 (branch p (source p n)) =
    moment 3 (source p n) + 3*(2*p-1)*moment 2 (source p n) +
      3*moment 1 (source p n) + (2*p-1)*moment 0 (source p n)
  exact m3_step p (source p n)

private theorem ms4 (p : ℝ) (n : ℕ) :
    sourceMoment p (n+1) 4 =
      sourceMoment p n 4 + 4*(2*p-1)*sourceMoment p n 3 +
        6*sourceMoment p n 2 + 4*(2*p-1)*sourceMoment p n 1 +
        sourceMoment p n 0 := by
  change moment 4 (branch p (source p n)) =
    moment 4 (source p n) + 4*(2*p-1)*moment 3 (source p n) +
      6*moment 2 (source p n) + 4*(2*p-1)*moment 1 (source p n) +
      moment 0 (source p n)
  exact m4_step p (source p n)

/-- Full, law-specific moment identities from the actual 2^n
source worlds; the construction is not a Gaussian approximation. -/
theorem original_source_moments (p : ℝ) (n : ℕ) :
    let r := 2*p-1
    sourceMoment p n 0 = 1 ∧
    sourceMoment p n 1 = (n:ℝ)*r ∧
    sourceMoment p n 2 = (n:ℝ) + (n:ℝ)*((n:ℝ)-1)*r^2 ∧
    sourceMoment p n 3 = (n:ℝ)*r +
      3*(n:ℝ)*((n:ℝ)-1)*r +
      (n:ℝ)*((n:ℝ)-1)*((n:ℝ)-2)*r^3 ∧
    sourceMoment p n 4 = (n:ℝ) +
      4*(n:ℝ)*((n:ℝ)-1)*r^2 + 3*(n:ℝ)*((n:ℝ)-1) +
      6*(n:ℝ)*((n:ℝ)-1)*((n:ℝ)-2)*r^2 +
      (n:ℝ)*((n:ℝ)-1)*((n:ℝ)-2)*((n:ℝ)-3)*r^4 := by
  dsimp
  induction n with
  | zero =>
      norm_num [sourceMoment, source, moment]
  | succ n ih =>
      rcases ih with ⟨h0,h1,h2,h3,h4⟩
      have hn : ((n+1:ℕ):ℝ) = (n:ℝ)+1 := by push_cast; ring
      refine ⟨?_, ?_, ?_, ?_, ?_⟩
      · rw [ms0, h0]
      · rw [ms1, h0, h1, hn]
        ring
      · rw [ms2, h0, h1, h2, hn]
        ring
      · rw [ms3, h0, h1, h2, h3, hn]
        ring
      · rw [ms4, h0, h1, h2, h3, h4, hn]
        ring

/-- Choose the unique positive mean of magnitude 1/sqrt(2),
which is the quadratic Bernstein extremal bias. -/
noncomputable def extremalMean : ℝ := Real.sqrt (1/2)

theorem extremal_mean_square : extremalMean ^ 2 = (1/2:ℝ) := by
  unfold extremalMean
  rw [Real.sq_sqrt (by norm_num)]

def extremalBias : ℝ := (1+extremalMean)/2

theorem extremal_bias_mean : 2*extremalBias-1 = extremalMean := by
  unfold extremalBias
  ring

theorem extremal_bias_variance :
    extremalBias*(1-extremalBias) = (1/8:ℝ) := by
  rw [show extremalBias = (1+extremalMean)/2 from rfl]
  nlinarith [extremal_mean_square]

/-- These are the exact, unnormalised variance and conditional
resampling influence derived from the first four source moments.
The source function is f(s) = 2s² - n², and B ≤ n². -/
def varianceFormula (n : ℕ) : ℝ :=
  4*(sourceMoment extremalBias n 4 -
       (sourceMoment extremalBias n 2)^2)

def influenceFormula (n : ℕ) : ℝ :=
  64*extremalBias*(1-extremalBias)*
    sourceMoment extremalBias (n-1) 2

theorem variance_formula_closed (n : ℕ) :
    varianceFormula n =
      2*(n:ℝ)*((n:ℝ)-1)*(2*(n:ℝ)-1) := by
  obtain ⟨h0,h1,h2,h3,h4⟩ :=
    original_source_moments extremalBias n
  unfold varianceFormula
  rw [h2, h4, extremal_bias_mean]
  have hm := extremal_mean_square
  nlinarith [hm]

theorem influence_formula_closed (n : ℕ) (hn : 1 ≤ n) :
    influenceFormula n = 4*(n:ℝ)*((n:ℝ)-1) := by
  obtain ⟨h0,h1,h2,h3,h4⟩ :=
    original_source_moments extremalBias (n-1)
  unfold influenceFormula
  rw [h2, extremal_bias_mean, extremal_bias_variance]
  have hm := extremal_mean_square
  have hcast : (((n-1:ℕ):ℝ)) = (n:ℝ)-1 := by
    exact Nat.cast_sub hn  -- coerces the natural subtraction
  rw [hcast]
  nlinarith [hm]

/-- The necessary coefficient ratio of this exact moment family
converges algebraically to 4. No limit theorem is assumed. -/
theorem exact_ratio_identity (n : ℕ) (hn : 2 ≤ n) :
    varianceFormula n ^ 2 =
      (((n:ℝ)-1)*(2*(n:ℝ)-1)^2/(n:ℝ)^3) *
      (n:ℝ)^4 * influenceFormula n := by
  rw [variance_formula_closed, influence_formula_closed n (by omega)]
  have hn0 : (n:ℝ) ≠ 0 := by exact_mod_cast (show n ≠ 0 by omega)
  field_simp
  ring

theorem arbitrarily_close_to_four (C : ℝ) (hC : C < 4) :
    ∃ n : ℕ, 2 ≤ n ∧
      C*(n:ℝ)^3 < ((n:ℝ)-1)*(2*(n:ℝ)-1)^2 := by
  have hdelta : 0 < 4-C := by linarith
  obtain ⟨n, hn⟩ := exists_nat_gt (8/(4-C)+3)
  have hratio : 8/(4-C)+3 < (n:ℝ) := hn
  have hdiv : 0 ≤ 8/(4-C) := div_nonneg (by norm_num) (le_of_lt hdelta)
  have hn2r : (2:ℝ) ≤ (n:ℝ) := by linarith
  have hn2 : 2 ≤ n := by exact_mod_cast hn2r
  have hmult := mul_lt_mul_of_pos_left hratio hdelta
  have hcancel : (4-C)*(8/(4-C)) = (8:ℝ) := by
    field_simp
    ring
  have hstrong : (8:ℝ) < (4-C)*(n:ℝ) := by nlinarith
  have hpos : (0:ℝ) < ((4-C)*(n:ℝ)-8)*(n:ℝ)^2 :=
    mul_pos (by linarith) (sq_pos_of_pos (by linarith))
  refine ⟨n, hn2, ?_⟩
  nlinarith

/-- The all-n source-moment inequality with bound B=n²
cannot hold with any constant C < 4. This is the precise
sharpness obstruction, not the conjectural universal upper bound. -/
theorem coefficient_at_least_four (C : ℝ)
    (h : ∀ n : ℕ, 2 ≤ n →
      varianceFormula n ^ 2 ≤
        C*(n:ℝ)^4*influenceFormula n) : 4 ≤ C := by
  by_contra hc
  have hclt : C < 4 := by linarith
  obtain ⟨n, hn, hbad⟩ := arbitrarily_close_to_four C hclt
  have hineq := h n hn
  rw [variance_formula_closed,
    influence_formula_closed n (by omega)] at hineq
  have hn2 : (2:ℝ) ≤ (n:ℝ) := by exact_mod_cast hn
  have hpos : (0:ℝ) <
      4*(n:ℝ)^2*((n:ℝ)-1) := by positivity
  have hfail : 0 <
      (4*(n:ℝ)^2*((n:ℝ)-1)) *
        (((n:ℝ)-1)*(2*(n:ℝ)-1)^2-C*(n:ℝ)^3) :=
    mul_pos hpos (sub_pos.mpr hbad)
  nlinarith [hfail]

#print axioms Nightfall.Q2BernsteinLower.original_source_moments
#print axioms Nightfall.Q2BernsteinLower.extremal_mean_square
#print axioms Nightfall.Q2BernsteinLower.variance_formula_closed
#print axioms Nightfall.Q2BernsteinLower.influence_formula_closed
#print axioms Nightfall.Q2BernsteinLower.exact_ratio_identity
#print axioms Nightfall.Q2BernsteinLower.arbitrarily_close_to_four
#print axioms Nightfall.Q2BernsteinLower.coefficient_at_least_four

end Nightfall.Q2BernsteinLower
