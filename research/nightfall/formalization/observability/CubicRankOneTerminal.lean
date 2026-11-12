import Mathlib

/-!
# Exact rank-one cubic selector: the terminal mean-energy step

This module certifies the finite-dimensional arithmetic after a vector-control
influence bound and the independent centered-leaf energy decomposition have
already been proved. It does **NOT** prove the fair-sign quadratic vector
Khintchine inequality, the leaf-range inequality, or the full cubic theorem.
There are no untrusted axioms, admitted goals, or numerical tests.
-/

namespace Nightfall.Observability.CubicRankOneTerminal

open Finset

variable {κ : Type*} [Fintype κ]

/-- A coordinate-wise squared-energy cap controls the ℓ₂ energy by the
ℓ₁ amplitude, with the exact sharp coefficient one. -/
theorem mean_energy_le_sqrt_mul_l1
    (a : κ → ℝ) (M : ℝ)
    (hM : 0 ≤ M)
    (hcap : ∀ k : κ, a k ^ 2 ≤ M) :
    (∑ k : κ, a k ^ 2) ≤
      Real.sqrt M * (∑ k : κ, |a k|) := by
  have hterm (k : κ) :
      a k ^ 2 ≤ Real.sqrt M * |a k| := by
    have hsquare : a k ^ 2 ≤ (Real.sqrt M) ^ 2 := by
      simpa only [Real.sq_sqrt hM] using hcap k
    have hle : |a k| ≤ Real.sqrt M :=
      abs_le_of_sq_le_sq hsquare (Real.sqrt_nonneg M)
    calc
      a k ^ 2 = |a k| ^ 2 := (sq_abs (a k)).symm
      _ = |a k| * |a k| := by ring
      _ ≤ Real.sqrt M * |a k| :=
        mul_le_mul_of_nonneg_right hle (abs_nonneg (a k))
  calc
    (∑ k : κ, a k ^ 2) ≤
        (∑ k : κ, Real.sqrt M * |a k|) := by
          exact Finset.sum_le_sum (fun k _ => hterm k)
    _ = Real.sqrt M * (∑ k : κ, |a k|) := by rw [Finset.mul_sum]

/-- Full unconditional finite-array mean-energy inequality. -/
theorem mean_energy_le_budget
    (a : κ → ℝ) (B M : ℝ)
    (hM : 0 ≤ M)
    (hcap : ∀ k : κ, a k ^ 2 ≤ M)
    (hl1 : (∑ k : κ, |a k|) ≤ B) :
    (∑ k : κ, a k ^ 2) ≤ B * Real.sqrt M := by
  have h0 := mean_energy_le_sqrt_mul_l1 a M hM hcap
  have h1 : Real.sqrt M * (∑ k : κ, |a k|) ≤
      Real.sqrt M * B :=
    mul_le_mul_of_nonneg_left hl1 (Real.sqrt_nonneg M)
  nlinarith

/-- Exact terminal implication for rank-one cubic selectors.

The hypotheses hvector and hvariance are *premises*: they must be separately
instantiated from the actual fair-sign degree-two vector theorem and the
independent centered-leaf variance identity. This declaration cannot serve
as an end-to-end certificate for either of those premises. -/
theorem rank_one_cubic_five_transfer
    (a : κ → ℝ) (B M W V : ℝ)
    (hM : 0 ≤ M)
    (hcap : ∀ k : κ, a k ^ 2 ≤ M)
    (hl1 : (∑ k : κ, |a k|) ≤ B)
    (hvector : W ≤ 4 * B * Real.sqrt M)
    (hvariance : V = W + ∑ k : κ, a k ^ 2) :
    V ≤ 5 * B * Real.sqrt M := by
  have hmean := mean_energy_le_budget a B M hM hcap hl1
  nlinarith

end Nightfall.Observability.CubicRankOneTerminal
