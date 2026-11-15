import Mathlib

/-!
# Shifted Hilbert c/5: exact sufficient condition and moment-method obstruction

Scope: real-scalar consequences of a PROPOSED (not assumed to be true)
first-to-second-moment comparison for any independent centered Hilbert sum.

If e=E||h+ΣY_j||², u=E||h+ΣY_j||, ||Y_j||≤c,
the still-unproved PROBABILISTIC condition is e ≤ 2*u²+c*u.
From this explicit premise we prove a correction strictly better than c/5.

We independently show that Jensen a≤u, shifted energy e=a²+s,
the currently certified strong fourth-moment upper bound, and Holder
e³≤u²*q do NOT alone imply c/5: a rational pseudo-moment satisfies
every such constraint and violates the claimed conclusion.
This is not a counterexample from a genuine independent distribution.
-/

namespace Nightfall.Q2Shifted.C5MomentBridge

noncomputable def beta : ℝ := (Real.sqrt 3 - 1) / 4

theorem root3_ge_one : (1 : ℝ) ≤ Real.sqrt 3 := by
  have hsq : (Real.sqrt (3 : ℝ))^2 = 3 := Real.sq_sqrt (by norm_num)
  have h0 := Real.sqrt_nonneg (3 : ℝ)
  nlinarith

theorem root3_lt_nine_fifths : Real.sqrt (3 : ℝ) < 9/5 := by
  have hsq : (Real.sqrt (3 : ℝ))^2 = 3 := Real.sq_sqrt (by norm_num)
  have h0 := Real.sqrt_nonneg (3 : ℝ)
  nlinarith

theorem beta_nonneg : 0 ≤ beta := by
  unfold beta
  nlinarith [root3_ge_one]

theorem beta_lt_fifth : beta < (1/5 : ℝ) := by
  unfold beta
  nlinarith [root3_lt_nine_fifths]

theorem beta_linear_identity :
    2 * Real.sqrt 3 * beta + 2 * beta = 1 := by
  have hr2 : (Real.sqrt (3 : ℝ))^2 = 3 :=
    Real.sq_sqrt (by norm_num)
  unfold beta
  nlinarith [hr2]

/-- Exact SOS for the candidate quadratic comparison.
No probability is presumed or implied by this algebraic identity. -/
theorem first_second_sos (u c : ℝ) :
    (Real.sqrt 3 * u + beta * c)^2 - (2*u^2 + c*u) =
      (u-beta*c)^2 := by
  have hr2 : (Real.sqrt (3 : ℝ))^2 = 3 :=
    Real.sq_sqrt (by norm_num)
  have hbeta := beta_linear_identity
  calc
    _ = ((Real.sqrt 3)^2-3)*u^2 +
        (2*Real.sqrt 3*beta+2*beta-1)*u*c +
        (u-beta*c)^2 := by ring
    _ = (u-beta*c)^2 := by rw [hr2, hbeta]; ring

/-- STRONGER THAN c/5, CONDITIONAL:
Any scalar energy obeying e ≤ 2u²+cu has shifted-L1 correction beta*c,
where beta=(sqrt 3-1)/4 < 1/5.
The missing work is proving the first-to-second comparison for actual
independent centered Hilbert sums, not this algebraic implication. -/
theorem c5_from_first_second_comparison
    (e u c : ℝ)
    (he : 0 ≤ e) (hu : 0 ≤ u) (hc : 0 ≤ c)
    (hcomparison : e ≤ 2*u^2+c*u) :
    Real.sqrt e ≤ Real.sqrt 3*u + beta*c := by
  have hsos := first_second_sos u c
  have hroot : 0 ≤ Real.sqrt (3 : ℝ) := Real.sqrt_nonneg _
  have hrhs : 0 ≤ Real.sqrt 3*u+beta*c :=
    add_nonneg (mul_nonneg hroot hu) (mul_nonneg beta_nonneg hc)
  have hq : e ≤ (Real.sqrt 3*u+beta*c)^2 := by
    nlinarith [sq_nonneg (u-beta*c)]
  have heq : (Real.sqrt e)^2 = e := Real.sq_sqrt he
  have hleft : 0 ≤ Real.sqrt e := Real.sqrt_nonneg _
  nlinarith

theorem universal_fifth_from_first_second_comparison
    (e u c : ℝ)
    (he : 0 ≤ e) (hu : 0 ≤ u) (hc : 0 ≤ c)
    (hcomparison : e ≤ 2*u^2+c*u) :
    Real.sqrt e ≤ Real.sqrt 3*u + c/5 := by
  have hstrong :=
    c5_from_first_second_comparison e u c he hu hc hcomparison
  have hgap : beta*c ≤ c/5 := by
    have h := mul_le_mul_of_nonneg_right (le_of_lt beta_lt_fifth) hc
    nlinarith
  linarith

/-- All original quartic/Holder and Jensen numeric constraints hold
for a rational pseudo-moment; these are not a probability law. -/
theorem rational_pseudo_jensen_holder_fourth :
    ((1 : ℝ)^2 = (2/5)^2 + (21/25)) ∧
    ((2/5 : ℝ) ≤ 5/12) ∧
    ((1 : ℝ)^6 ≤ (5/12)^2*(59/10)) ∧
    ((59/10 : ℝ) ≤
      3*(1 : ℝ)^4 - 2*(2/5)^4 +
      4*(2/5)*(5/4)*(21/25)+(5/4)^2*(21/25)) := by
  constructor
  · norm_num
  constructor
  · norm_num
  constructor
  · norm_num
  · norm_num

/-- Jensen and the sharp fourth moment plus Holder do NOT logically
imply the universal c/5 estimate. This is a proof-method obstruction,
NOT a counterexample to the independent-sum distributional theorem. -/
theorem rational_pseudo_violates_c5 :
    ¬ ((1 : ℝ) ≤ Real.sqrt 3*(5/12)+(5/4)/5) := by
  intro h
  have hr := root3_lt_nine_fifths
  nlinarith

end Nightfall.Q2Shifted.C5MomentBridge
