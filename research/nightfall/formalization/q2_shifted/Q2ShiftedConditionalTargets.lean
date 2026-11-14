import Mathlib

/-!
# Q2 shifted-owner: explicit conditional terminal gates at 107 and 99

All source-specific Hilbert probabilistic assumptions remain explicit.
This file certifies algebraic terminal implications, not the original-source
Hilbert fourth moment, independent-coordinate switching, or K_opt.

The 107 coefficient requires the proved *scalar* c/4 shifted lemma
PLUS the unproved source-level fourth-moment and sharp section bridges.
The 99 coefficient requires a strictly stronger, presently unproved
c/5 shifted L1 assertion. The old fourth-moment envelope does NOT
imply it: an exact rational witness is checked below.
-/

namespace Nightfall.Q2Shifted.ConditionalTargets

open Finset

variable {ι : Type*} [Fintype ι]

/-- General finite owner-energy telescope. The hshift premise is
    explicit; do not interpret it as a consequence of source bounds. -/
theorem conditional_shifted_budget
    (e u c : ι → ℝ)
    (B M V U β : ℝ)
    (hB : 0 ≤ B) (hM : 0 ≤ M)
    (hU : 0 ≤ U) (hβ : 0 ≤ β)
    (he : ∀ i, 0 ≤ e i)
    (hcap : ∀ i, e i ≤ M)
    (hshift : ∀ i, Real.sqrt (e i) ≤ Real.sqrt 3 * u i + β * c i)
    (hsection : (∑ i : ι, u i) ≤ U * B)
    (hcover : (∑ i : ι, c i) ≤ 8 * B)
    (hvariance : V = ∑ i : ι, e i) :
    V^2 ≤ (Real.sqrt 3 * U + 8 * β)^2 * B^2 * M := by
  classical
  let r : ℝ := Real.sqrt 3
  have hr : 0 ≤ r := Real.sqrt_nonneg _
  have hrootM : 0 ≤ Real.sqrt M := Real.sqrt_nonneg _
  have hlocal (i : ι) :
      e i ≤ Real.sqrt M * (r * u i + β * c i) := by
    have heq : (Real.sqrt (e i))^2 = e i := Real.sq_sqrt (he i)
    have hrootle : Real.sqrt (e i) ≤ Real.sqrt M :=
      Real.sqrt_le_sqrt (hcap i)
    calc
      e i = Real.sqrt (e i) * Real.sqrt (e i) := by nlinarith [heq]
      _ ≤ Real.sqrt M * Real.sqrt (e i) :=
        mul_le_mul_of_nonneg_right hrootle (Real.sqrt_nonneg _)
      _ ≤ Real.sqrt M * (r * u i + β * c i) :=
        mul_le_mul_of_nonneg_left (by simpa only [r] using hshift i) hrootM
  have hsum : V ≤ Real.sqrt M *
      (r * (∑ i : ι, u i) + β * (∑ i : ι, c i)) := by
    calc
      V = ∑ i : ι, e i := hvariance
      _ ≤ ∑ i : ι, Real.sqrt M * (r * u i + β * c i) :=
        Finset.sum_le_sum (fun i _ => hlocal i)
      _ = Real.sqrt M *
          (r * (∑ i : ι, u i) + β * (∑ i : ι, c i)) := by
            simp only [mul_add, Finset.mul_sum, Finset.sum_add_distrib]
  have hUb : r * (∑ i : ι, u i) ≤ r * (U * B) :=
    mul_le_mul_of_nonneg_left hsection hr
  have hCb : β * (∑ i : ι, c i) ≤ β * (8 * B) :=
    mul_le_mul_of_nonneg_left hcover hβ
  have hbudget :
      r * (∑ i : ι, u i) + β * (∑ i : ι, c i) ≤
      (r * U + 8 * β) * B := by
    nlinarith [hUb, hCb]
  have hbound : V ≤ (r * U + 8 * β) * B * Real.sqrt M := by
    calc
      V ≤ Real.sqrt M *
          (r * (∑ i : ι, u i) + β * (∑ i : ι, c i)) := hsum
      _ ≤ Real.sqrt M * ((r * U + 8 * β) * B) :=
        mul_le_mul_of_nonneg_left hbudget hrootM
      _ = (r * U + 8 * β) * B * Real.sqrt M := by ring
  have hV0 : 0 ≤ V := by
    rw [hvariance]
    exact Finset.sum_nonneg (fun i _ => he i)
  have hR0 : 0 ≤ (r * U + 8 * β) * B * Real.sqrt M := by
    have hcoeff : 0 ≤ r * U + 8 * β :=
      add_nonneg (mul_nonneg hr hU) (mul_nonneg (by norm_num) hβ)
    exact mul_nonneg (mul_nonneg hcoeff hB) hrootM
  have hvsq : V^2 ≤ ((r * U + 8 * β) * B * Real.sqrt M)^2 := by
    nlinarith [mul_nonneg (sub_nonneg.mpr hbound) (add_nonneg hR0 hV0)]
  calc
    V^2 ≤ ((r * U + 8 * β) * B * Real.sqrt M)^2 := hvsq
    _ = (Real.sqrt 3 * U + 8 * β)^2 * B^2 * M := by
      dsimp [r]
      calc
        ((Real.sqrt 3 * U + 8 * β) * B * Real.sqrt M)^2 =
            (Real.sqrt 3 * U + 8 * β)^2 * B^2 * (Real.sqrt M)^2 := by ring
        _ = (Real.sqrt 3 * U + 8 * β)^2 * B^2 * M := by
          rw [Real.sq_sqrt hM]

/-- A coefficient-107.393... statement, *conditional* on both
    the per-owner c/4 moment inequality and the sharp original-source
    section budget, neither derived here. -/
theorem conditional_coefficient_107
    (e u c : ι → ℝ) (B M V : ℝ)
    (hB : 0 ≤ B) (hM : 0 ≤ M)
    (he : ∀ i, 0 ≤ e i)
    (hcap : ∀ i, e i ≤ M)
    (hshift4 : ∀ i, Real.sqrt (e i) ≤
      Real.sqrt 3 * u i + (1/4 : ℝ) * c i)
    (hsection : (∑ i : ι, u i) ≤
      2 * (1 + Real.sqrt 2) * B)
    (hcover : (∑ i : ι, c i) ≤ 8 * B)
    (hvariance : V = ∑ i : ι, e i) :
    V^2 ≤ (2 * Real.sqrt 3 * (1 + Real.sqrt 2) + 2)^2 *
      B^2 * M := by
  have hU : 0 ≤ 2 * (1 + Real.sqrt 2) := by positivity
  have hβ : (0 : ℝ) ≤ 1/4 := by norm_num
  have h := conditional_shifted_budget
    e u c B M V (2 * (1 + Real.sqrt 2)) (1/4 : ℝ)
    hB hM hU hβ he hcap hshift4 hsection hcover hvariance
  convert h using 1 <;> ring

/-- Coefficient-99.263... is *conditional* on a stronger
    hypothetical c/5 L1 correction. This is NOT currently proved
    for independent Hilbert sums by any source lemma in this repo. -/
theorem conditional_coefficient_99
    (e u c : ι → ℝ) (B M V : ℝ)
    (hB : 0 ≤ B) (hM : 0 ≤ M)
    (he : ∀ i, 0 ≤ e i)
    (hcap : ∀ i, e i ≤ M)
    (hshift5 : ∀ i, Real.sqrt (e i) ≤
      Real.sqrt 3 * u i + (1/5 : ℝ) * c i)
    (hsection : (∑ i : ι, u i) ≤
      2 * (1 + Real.sqrt 2) * B)
    (hcover : (∑ i : ι, c i) ≤ 8 * B)
    (hvariance : V = ∑ i : ι, e i) :
    V^2 ≤ (2 * Real.sqrt 3 * (1 + Real.sqrt 2) + 8/5)^2 *
      B^2 * M := by
  have hU : 0 ≤ 2 * (1 + Real.sqrt 2) := by positivity
  have hβ : (0 : ℝ) ≤ 1/5 := by norm_num
  have h := conditional_shifted_budget
    e u c B M V (2 * (1 + Real.sqrt 2)) (1/5 : ℝ)
    hB hM hU hβ he hcap hshift5 hsection hcover hvariance
  convert h using 1 <;> ring

/-- Exact rational negative value:
    the c/5 NORMALIZED FOURTH-MOMENT ENVELOPE is false at x=1/4,d=3/4.
    This does not disprove the stronger L1 property of actual sums. -/
theorem fifth_envelope_counterexample_exact :
    (3 : ℝ) - (1 - (3/4 : ℝ)/5)^2 *
      (3 - 2*(1/4 : ℝ)^4 +
         4*(1/4 : ℝ)*(1-(1/4 : ℝ)^2)*(3/4 : ℝ) +
         (1-(1/4 : ℝ)^2)*(3/4 : ℝ)^2)
      = -(5209 : ℝ)/102400 := by
  norm_num

theorem fifth_envelope_not_universal :
    ¬ ((1 - (3/4 : ℝ)/5)^2 *
      (3 - 2*(1/4 : ℝ)^4 +
         4*(1/4 : ℝ)*(1-(1/4 : ℝ)^2)*(3/4 : ℝ) +
         (1-(1/4 : ℝ)^2)*(3/4 : ℝ)^2)
      ≤ 3) := by
  norm_num

end Nightfall.Q2Shifted.ConditionalTargets
