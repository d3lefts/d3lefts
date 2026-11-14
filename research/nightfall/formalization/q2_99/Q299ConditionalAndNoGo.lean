import Mathlib

/-!
# NIGHTFALL Q2: exact c/5 shifted-budget implication, not a source theorem

The main theorem has TWO explicitly unproved source-level premises:
  (1) each owner has the genuine c/5 shifted-Hilbert L1 bound;
  (2) the true original-law source section budget is 2(1+sqrt 2)*B.
It proves only the algebraic/finite summation conclusion C99.

A separate exact rational countermodel demonstrates that (1) does NOT
follow from the existing fourth-moment envelope + Holder hypotheses.
No sorry/admit/nonstandard axiom and no novelty claim.
-/

namespace Nightfall.Q299
open Finset

variable {ι : Type*} [Fintype ι]

/-- The complete *conditional* c/5 scalar summation, with no hidden
source-side claim. The genuine source theorem must discharge BOTH
hshift and hsection with old original p and f. -/
theorem conditional_shifted_c5_budget_99
    (e u c : ι → ℝ) (B M V : ℝ)
    (hB : 0 ≤ B) (hM : 0 ≤ M)
    (he : ∀ i, 0 ≤ e i)
    (hu : ∀ i, 0 ≤ u i)
    (hc : ∀ i, 0 ≤ c i)
    (hcap : ∀ i, e i ≤ M)
    (hshift : ∀ i, Real.sqrt (e i) ≤
      Real.sqrt 3 * u i + c i / 5)
    (hsection : (∑ i : ι, u i) ≤
      2 * (1 + Real.sqrt 2) * B)
    (hcover : (∑ i : ι, c i) ≤ 8 * B)
    (hvariance : V = ∑ i : ι, e i) :
    V^2 ≤ (2 * Real.sqrt 3 * (1 + Real.sqrt 2) + 8 / 5)^2
      * B^2 * M := by
  classical
  let r : ℝ := Real.sqrt 3
  let K : ℝ := 2 * r * (1 + Real.sqrt 2) + 8 / 5
  have hr : 0 ≤ r := Real.sqrt_nonneg _
  have hrootM : 0 ≤ Real.sqrt M := Real.sqrt_nonneg _
  have hlocal (i : ι) :
      e i ≤ Real.sqrt M * (r * u i + c i / 5) := by
    have hrootE : 0 ≤ Real.sqrt (e i) := Real.sqrt_nonneg _
    have hrootOrder : Real.sqrt (e i) ≤ Real.sqrt M :=
      Real.sqrt_le_sqrt (hcap i)
    have henergy : (Real.sqrt (e i))^2 = e i :=
      Real.sq_sqrt (he i)
    calc
      e i = Real.sqrt (e i) * Real.sqrt (e i) := by
        rw [← pow_two, henergy]
      _ ≤ Real.sqrt M * Real.sqrt (e i) :=
        mul_le_mul_of_nonneg_right hrootOrder hrootE
      _ ≤ Real.sqrt M * (r * u i + c i / 5) :=
        mul_le_mul_of_nonneg_left (hshift i) hrootM
  have hsum : V ≤
      Real.sqrt M * (r * (∑ i : ι, u i) +
        (∑ i : ι, c i) / 5) := by
    calc
      V = ∑ i : ι, e i := hvariance
      _ ≤ ∑ i : ι, Real.sqrt M * (r * u i + c i / 5) :=
        Finset.sum_le_sum (fun i _ => hlocal i)
      _ = Real.sqrt M * (r * (∑ i : ι, u i) +
          (∑ i : ι, c i) / 5) := by
            simp only [mul_add, Finset.sum_add_distrib,
              Finset.sum_div, ← Finset.mul_sum]
  have hUb :
      r * (∑ i : ι, u i) ≤
        r * (2 * (1 + Real.sqrt 2) * B) :=
    mul_le_mul_of_nonneg_left hsection hr
  have hCb :
      (∑ i : ι, c i) / 5 ≤ (8 * B) / 5 := by
    linarith [hcover]
  have hbudget :
      r * (∑ i : ι, u i) + (∑ i : ι, c i) / 5
        ≤ K * B := by
    dsimp [K]
    nlinarith [hUb, hCb]
  have hVbound : V ≤ K * B * Real.sqrt M := by
    calc
      V ≤ Real.sqrt M *
          (r * (∑ i : ι, u i) +
            (∑ i : ι, c i) / 5) := hsum
      _ ≤ Real.sqrt M * (K * B) :=
        mul_le_mul_of_nonneg_left hbudget hrootM
      _ = K * B * Real.sqrt M := by ring
  have hV0 : 0 ≤ V := by
    rw [hvariance]
    exact Finset.sum_nonneg (fun i _ => he i)
  have hroot2 : 0 ≤ Real.sqrt 2 := Real.sqrt_nonneg _
  have hK0 : 0 ≤ K := by
    dsimp [K]
    positivity
  have hR0 : 0 ≤ K * B * Real.sqrt M :=
    mul_nonneg (mul_nonneg hK0 hB) hrootM
  have hsq :
      V^2 ≤ (K * B * Real.sqrt M)^2 := by
    nlinarith [mul_nonneg (sub_nonneg.mpr hVbound)
      (add_nonneg hR0 hV0)]
  calc
    V^2 ≤ (K * B * Real.sqrt M)^2 := hsq
    _ = (2 * Real.sqrt 3 * (1 + Real.sqrt 2) + 8 / 5)^2
        * B^2 * (Real.sqrt M)^2 := by
      dsimp [K, r]
      ring
    _ = (2 * Real.sqrt 3 * (1 + Real.sqrt 2) + 8 / 5)^2
        * B^2 * M := by
      rw [Real.sq_sqrt hM]

/-- Exact no-go: the old fourth-moment/Hölder scalar envelope is
insufficient to prove the new c/5 shifted-owner estimate.
This counterexample is an ABSTRACT SCALAR ASSIGNMENT, NOT a valid
independent-increment probability model or counterexample to Q2(99).
-/
theorem c5_not_implied_by_old_moment_envelope :
    ((1:ℝ)^2 = (1/2:ℝ)^2 + 3/4) ∧
    ((1:ℝ)^6 ≤ (9/20:ℝ)^2 * (41/8)) ∧
    ((41/8:ℝ) ≤ 3*(1:ℝ)^4-2*(1/2:ℝ)^4+
      4*(1/2)*(1)*(3/4)+(1:ℝ)^2*(3/4)) ∧
    ¬ ((1:ℝ) ≤ Real.sqrt 3 * (9/20) + (1:ℝ)/5) := by
  have hr0 : 0 ≤ Real.sqrt 3 := Real.sqrt_nonneg _
  have hr2 : (Real.sqrt 3)^2 = (3:ℝ) :=
    Real.sq_sqrt (by norm_num)
  have hr_lt : Real.sqrt 3 < (16:ℝ)/9 := by
    nlinarith
  constructor
  · norm_num
  constructor
  · norm_num
  constructor
  · norm_num
  · intro h
    have hlin : (16:ℝ)/9 ≤ Real.sqrt 3 := by
      nlinarith [h]
    linarith

/-- The proposed c/5 normal-form polynomial fails at x=1/2,d=1.
It is an exact rational refutation of an attempted proof technique,
not of the actual independent-increment inequality. -/
theorem old_c5_polynomial_claim_false :
    (3:ℝ) <
      (1 - (1:ℝ)/5)^2 *
       (3 - 2*(1/2:ℝ)^4 +
         4*(1/2:ℝ)*(1-(1/2:ℝ)^2)*1 +
         (1-(1/2:ℝ)^2)*(1:ℝ)^2) := by
  norm_num

end Nightfall.Q299
