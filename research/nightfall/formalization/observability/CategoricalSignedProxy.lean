import Mathlib

/-!
NIGHTFALL spectral observability, new formalization boundary:
the arbitrary-finite-categorical signed-proxy construction used by
the nonadaptive degree-d observability argument.

This is not the full Chebyshev extrapolation argument or the
Hilbert spectral prediction theorem. It kernel-certifies the exact
pointwise algebra for all finite alphabet sizes, no atom lower bound.

Given nonnegative weights w with sum of squares 1 and signs eps with
eps^2=1, p_s=w_s^2, S=sum_s w_s eps_s, define
  Z_s=p_s+w_s eps_s-p_s S.
Then sum Z=1, the signed weighted-chi-square identity is exact,
and ||Z||_1^2 <= m+1. No mistaken PDF extraction correction is claimed:
v5 already states the square-root extrapolation parameter correctly.
-/

namespace Nightfall.Observability.Categorical

open Finset

variable {α : Type*} [Fintype α] [DecidableEq α]

def signedSum (w eps : α → ℝ) : ℝ :=
  ∑ a, w a * eps a

def signedLift (w eps : α → ℝ) (a : α) : ℝ :=
  w a + eps a - w a * signedSum w eps

def signedProxy (w eps : α → ℝ) (a : α) : ℝ :=
  w a * signedLift w eps a

/-- The signed categorical proxy retains total mass one, although its
individual coordinates need not be positive. -/
theorem signedProxy_mass_one (w eps : α → ℝ)
    (hw : (∑ a, (w a)^2) = 1) :
    (∑ a, signedProxy w eps a) = 1 := by
  have hrewrite :
      (∑ a, signedProxy w eps a) =
      (∑ a, (w a ^ 2 + w a * eps a -
        signedSum w eps * w a ^ 2)) := by
    apply Finset.sum_congr rfl
    intro a _
    simp only [signedProxy, signedLift]
    ring
  rw [hrewrite, Finset.sum_sub_distrib, Finset.sum_add_distrib,
      ← Finset.mul_sum]
  rw [hw]
  simp only [signedSum]
  ring

/-- Exact weighted squared-radius identity before any approximation. -/
theorem signedLift_square_sum (w eps : α → ℝ)
    (hw : (∑ a, (w a)^2) = 1)
    (heps : ∀ a, (eps a)^2 = 1) :
    (∑ a, (signedLift w eps a)^2) =
      (Fintype.card α : ℝ) + 1 - (signedSum w eps)^2 := by
  let S := signedSum w eps
  have hpoint (a : α) :
      (signedLift w eps a)^2 =
        (1 - S)^2 * (w a)^2 +
        2 * (1 - S) * (w a * eps a) + (eps a)^2 := by
    simp only [signedLift, S]
    ring
  calc
    (∑ a, (signedLift w eps a)^2) =
        ∑ a, ((1 - S)^2 * (w a)^2 +
           2 * (1 - S) * (w a * eps a) + (eps a)^2) := by
             apply Finset.sum_congr rfl
             intro a _
             exact hpoint a
    _ = (1-S)^2 * (∑ a, (w a)^2) +
        2*(1-S) * (∑ a, w a * eps a) +
        (∑ a, (eps a)^2) := by
          rw [Finset.sum_add_distrib, Finset.sum_add_distrib,
              ← Finset.mul_sum, ← Finset.mul_sum]
    _ = (Fintype.card α : ℝ) + 1 - (signedSum w eps)^2 := by
          have hepssum : (∑ a, (eps a)^2) = (Fintype.card α : ℝ) := by
            simp [heps]
          rw [hw, hepssum]
          change (1-S)^2 * 1 + 2*(1-S)*S +
              (Fintype.card α : ℝ) =
              (Fintype.card α : ℝ) + 1 - S^2
          ring

/-- Dimension-sharp pointwise categorical signed-proxy radius.
For p_s=w_s^2>0, sqrt(m+1) bounds the L1 norm of Z. This is
precisely the input used in the manuscript's Chebyshev step. -/
theorem signedProxy_l1_sq_bound (w eps : α → ℝ)
    (hw : (∑ a, (w a)^2) = 1)
    (hw0 : ∀ a, 0 ≤ w a)
    (heps : ∀ a, (eps a)^2 = 1) :
    (∑ a, |signedProxy w eps a|)^2 ≤
      (Fintype.card α : ℝ) + 1 := by
  have habs :
      (∑ a, |signedProxy w eps a|) =
        ∑ a, w a * |signedLift w eps a| := by
    apply Finset.sum_congr rfl
    intro a _
    simp [signedProxy, abs_mul, abs_of_nonneg (hw0 a)]
  have hsqabs :
      (∑ a, (|signedLift w eps a|)^2) =
        ∑ a, (signedLift w eps a)^2 := by
    apply Finset.sum_congr rfl
    intro a _
    exact sq_abs _
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq
      (Finset.univ : Finset α)
      w (fun a => |signedLift w eps a|)
  rw [← habs, hw, hsqabs, signedLift_square_sum w eps hw heps] at hcs
  nlinarith [sq_nonneg (signedSum w eps)]

/-- Under the usual nonnegative radius, the nonsquared form of the
correct extrapolation parameter is sqrt(m+1). -/
theorem signedProxy_l1_bound (w eps : α → ℝ)
    (hw : (∑ a, (w a)^2) = 1)
    (hw0 : ∀ a, 0 ≤ w a)
    (heps : ∀ a, (eps a)^2 = 1) :
    (∑ a, |signedProxy w eps a|) ≤
      Real.sqrt ((Fintype.card α : ℝ) + 1) := by
  have h := signedProxy_l1_sq_bound w eps hw hw0 heps
  have hnon : 0 ≤ ∑ a, |signedProxy w eps a| :=
    Finset.sum_nonneg (fun a _ => abs_nonneg _)
  have hr : 0 ≤ (Fintype.card α : ℝ) + 1 := by positivity
  nlinarith [Real.sq_sqrt hr, Real.sqrt_nonneg
    ((Fintype.card α : ℝ) + 1)]

end Nightfall.Observability.Categorical
