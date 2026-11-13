import Mathlib

/-!
# Q2: exact finite numerical closure of the source energy budgets

This module is an algebraic lemma, NOT a proof of the source-level
quadratic influence theorem. In the terminal theorem all parameters
below must be constructed from the actual Efron-Stein source. In
particular the matching, energy and fourth-moment premises here are
NOT allowed at the terminal theorem boundary.

The constant 256(1 + sqrt 3)^2 is obtained without assuming the
separate sharper additive oscillation bound.
-/

namespace Nightfall.Observability.Q2FiniteArithmeticClosure

open Finset

variable {ι : Type*} [Fintype ι]

/-- Assemble the final energy inequality once all original-source
budgets have been derived, with no constant-optimization assumptions. -/
theorem energy_variance_bound
    (B M V : ℝ)
    (hB : 0 ≤ B) (hM : 0 ≤ M)
    (c z s t : ι → ℝ)
    (hc : ∀ i, 0 ≤ c i)
    (hz : ∀ i, 0 ≤ z i)
    (ht : ∀ i, 0 ≤ t i)
    (hsmallz : ∀ i, z i ≤ Real.sqrt M)
    (hsmallt : ∀ i, t i ≤ Real.sqrt M)
    (hmoment : ∀ i, s i ≤ z i * (c i + Real.sqrt (3 * M)))
    (hcost : (∑ i : ι, c i) ≤ 8 * B)
    (hsec : (∑ i : ι, t i) ≤ 8 * B)
    (hJensen : (∑ i : ι, z i) ≤ 16 * B)
    (hVar : V = (∑ i : ι, (t i)^2) + (∑ i : ι, s i)) :
    V ≤ 16 * (1 + Real.sqrt 3) * B * Real.sqrt M := by
  classical
  have hsqrtM : 0 ≤ Real.sqrt M := Real.sqrt_nonneg _
  have hsqrt3 : 0 ≤ Real.sqrt (3 : ℝ) := Real.sqrt_nonneg _
  have hsqrt3M : Real.sqrt (3 * M) =
      Real.sqrt 3 * Real.sqrt M := by
    exact Real.sqrt_mul (by norm_num : (0 : ℝ) ≤ 3) M
  have ht2 (i : ι) : (t i)^2 ≤ Real.sqrt M * t i := by
    have h := mul_nonneg (ht i)
      (sub_nonneg.mpr (hsmallt i))
    nlinarith
  have hzc (i : ι) : z i * c i ≤ Real.sqrt M * c i := by
    exact mul_le_mul_of_nonneg_right (hsmallz i) (hc i)
  have htsum :
      (∑ i : ι, (t i)^2) ≤ Real.sqrt M * (∑ i : ι, t i) := by
    calc
      (∑ i : ι, (t i)^2) ≤
          ∑ i : ι, Real.sqrt M * t i :=
        Finset.sum_le_sum (fun i _ => ht2 i)
      _ = Real.sqrt M * (∑ i : ι, t i) := by
          rw [Finset.mul_sum]
  have hssum :
      (∑ i : ι, s i) ≤
        Real.sqrt M * (∑ i : ι, c i) +
          Real.sqrt (3 * M) * (∑ i : ι, z i) := by
    calc
      (∑ i : ι, s i) ≤
          ∑ i : ι, z i * (c i + Real.sqrt (3 * M)) :=
            Finset.sum_le_sum (fun i _ => hmoment i)
      _ = (∑ i : ι, z i * c i) +
          Real.sqrt (3 * M) * (∑ i : ι, z i) := by
            simp only [mul_add, Finset.sum_add_distrib]
            rw [Finset.mul_sum]
            apply congrArg (fun x : ℝ => (∑ i : ι, z i * c i) + x)
            apply Finset.sum_congr rfl
            intro i _
            ring
      _ ≤ Real.sqrt M * (∑ i : ι, c i) +
          Real.sqrt (3 * M) * (∑ i : ι, z i) := by
            gcongr
            calc
              (∑ i : ι, z i * c i) ≤
                (∑ i : ι, Real.sqrt M * c i) :=
                  Finset.sum_le_sum (fun i _ => hzc i)
              _ = Real.sqrt M * (∑ i : ι, c i) := by
                rw [Finset.mul_sum]
  have h1 := mul_le_mul_of_nonneg_left hsec hsqrtM
  have h2 := mul_le_mul_of_nonneg_left hcost hsqrtM
  have h3 := mul_le_mul_of_nonneg_left hJensen (Real.sqrt_nonneg (3 * M))
  rw [hsqrt3M] at *
  calc
    V = (∑ i : ι, (t i)^2) + (∑ i : ι, s i) := hVar
    _ ≤ Real.sqrt M * (∑ i : ι, t i) +
          (Real.sqrt M * (∑ i : ι, c i) +
            Real.sqrt 3 * Real.sqrt M * (∑ i : ι, z i)) :=
              add_le_add htsum hssum
    _ ≤ 16 * (1 + Real.sqrt 3) * B * Real.sqrt M := by
          nlinarith [h1, h2, h3]

/-- The squared quadratic-influence form follows from the original
variance-energy decomposition and elementary nonnegative squaring. -/
theorem energy_variance_squared_bound
    (B M V : ℝ)
    (hB : 0 ≤ B) (hM : 0 ≤ M) (hV : 0 ≤ V)
    (c z s t : ι → ℝ)
    (hc : ∀ i, 0 ≤ c i)
    (hz : ∀ i, 0 ≤ z i)
    (ht : ∀ i, 0 ≤ t i)
    (hsmallz : ∀ i, z i ≤ Real.sqrt M)
    (hsmallt : ∀ i, t i ≤ Real.sqrt M)
    (hmoment : ∀ i, s i ≤ z i * (c i + Real.sqrt (3 * M)))
    (hcost : (∑ i : ι, c i) ≤ 8 * B)
    (hsec : (∑ i : ι, t i) ≤ 8 * B)
    (hJensen : (∑ i : ι, z i) ≤ 16 * B)
    (hVar : V = (∑ i : ι, (t i)^2) + (∑ i : ι, s i)) :
    V^2 ≤ 256 * (1 + Real.sqrt 3)^2 * B^2 * M := by
  have h := energy_variance_bound B M V hB hM c z s t
    hc hz ht hsmallz hsmallt hmoment hcost hsec hJensen hVar
  let C : ℝ := 16 * (1 + Real.sqrt 3) * B * Real.sqrt M
  have hC : 0 ≤ C := by
    dsimp [C]
    positivity
  have hv2 : V^2 ≤ C^2 := by
    have hprod := mul_nonneg (sub_nonneg.mpr h)
      (add_nonneg hC hV)
    dsimp [C] at *
    nlinarith
  have hCsq : C^2 = 256 * (1 + Real.sqrt 3)^2 * B^2 * M := by
    dsimp [C]
    rw [show 16 * (1 + Real.sqrt 3) * B * Real.sqrt M =
      (16 * (1 + Real.sqrt 3) * B) * Real.sqrt M by ring]
    rw [mul_pow, Real.sq_sqrt hM]
    ring
  exact hv2.trans_eq hCsq

end Nightfall.Observability.Q2FiniteArithmeticClosure
