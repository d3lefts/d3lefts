import Mathlib

/-!
# NIGHTFALL: finite spectral determinant product lower bound

This is the exact nonnegative-eigenvalue product inequality appearing
in the PSD Gaussian sign-moment argument. It formalizes the determinant
factor comparison (at the eigenvalue level), NOT Gaussian integration or
the whole PSD exponential-moment theorem.
-/

namespace Nightfall.Observability.PSD

open Finset

variable {κ : Type*} [DecidableEq κ]

/-- For nonnegative factors x_i <= 1, product(1-x_i) >= 1-sum x_i.
This is the finite union bound expressed multiplicatively. -/
theorem product_one_sub_lower (s : Finset κ) :
    ∀ (x : κ → ℝ),
      (∀ j ∈ s, 0 ≤ x j) →
      (∀ j ∈ s, x j ≤ 1) →
      1 - (∑ j ∈ s, x j) ≤ ∏ j ∈ s, (1 - x j) := by
  induction s using Finset.induction_on with
  | empty =>
      intro x hx0 hx1
      simp
  | @insert a s ha ih =>
      intro x hx0 hx1
      have h0s : ∀ j ∈ s, 0 ≤ x j := by
        intro j hj
        exact hx0 j (Finset.mem_insert_of_mem hj)
      have h1s : ∀ j ∈ s, x j ≤ 1 := by
        intro j hj
        exact hx1 j (Finset.mem_insert_of_mem hj)
      have ha0 : 0 ≤ x a := hx0 a (Finset.mem_insert_self a s)
      have ha1 : x a ≤ 1 := hx1 a (Finset.mem_insert_self a s)
      have hsum0 : 0 ≤ ∑ j ∈ s, x j :=
        Finset.sum_nonneg (fun j hj => h0s j hj)
      have hp := ih x h0s h1s
      have hmult :
          (1 - x a) * (1 - (∑ j ∈ s, x j)) ≤
          (1 - x a) * (∏ j ∈ s, (1 - x j)) :=
        mul_le_mul_of_nonneg_left hp (by linarith)
      simp only [Finset.sum_insert ha, Finset.prod_insert ha]
      nlinarith [mul_nonneg ha0 hsum0, hmult]

/-- For a PSD eigenvalue list lambda with trace s>0,
the Gaussian determinant product satisfies
  prod_j (1-lambda_j/(2s)) >= 1/2.
The input is the eigenvalue spectral representation; no matrix
diagonalization or Gaussian integral is asserted here. -/
theorem spectral_product_half
    [Fintype κ] (lam : κ → ℝ) (s : ℝ) (hs : 0 < s)
    (hlam : ∀ j, 0 ≤ lam j)
    (htrace : (∑ j : κ, lam j) = s) :
    (1 / 2 : ℝ) ≤ ∏ j : κ, (1 - lam j / (2 * s)) := by
  classical
  let x : κ → ℝ := fun j => lam j / (2 * s)
  have h0 : ∀ j ∈ (Finset.univ : Finset κ), 0 ≤ x j := by
    intro j hj
    exact div_nonneg (hlam j) (by positivity)
  have h1 : ∀ j ∈ (Finset.univ : Finset κ), x j ≤ 1 := by
    intro j hj
    have hl : lam j ≤ ∑ k : κ, lam k :=
      Finset.single_le_sum (fun k _ => hlam k) (Finset.mem_univ j)
    rw [htrace] at hl
    dsimp [x]
    apply (div_le_iff₀ (by positivity : 0 < 2 * s)).mpr
    nlinarith [hl]
  have hprod := product_one_sub_lower (Finset.univ : Finset κ) x h0 h1
  have hhalf : (∑ j : κ, x j) = (1 / 2 : ℝ) := by
    change (∑ j : κ, lam j / (2 * s)) = (1 / 2 : ℝ)
    rw [← Finset.sum_div, htrace]
    field_simp
    <;> ring
  have hbase : (1 / 2 : ℝ) ≤ ∏ j : κ, (1 - x j) := by
    have hcalc : 1 - (∑ j : κ, x j) = (1 / 2 : ℝ) := by
      rw [hhalf]
      norm_num
    rw [hcalc] at hprod
    exact hprod
  simpa [x] using hbase

end Nightfall.Observability.PSD
