import WrightV8PointwiseFour

/-!
# Unconditional quantitative Aaronson--Ambainis finite-product upgrade

Combines the genuine, source-derived canonical radius budget
  2 (sum pincr_j) <= 8 rho d²
with the previously kernel-certified finite product influence theorem
  3 Var^5 <= 12500 K^4 (sum pincr_j)^2 Inf_j^2
and existing K <= pi² d² product row.

This is an unconditional improvement over the old
K^6 endpoint, but does NOT claim the v8-sharp coefficient
(the missing 2d² FHKL theorem still matters).

Exact square-form coefficient improvement:
  c_old = sqrt(3/12500) / pi^6,
  c_new = sqrt(3/12500) / (4 rho pi^4),
  ratio = pi² / (4 rho) ~ 4.6042.
-/

namespace Nightfall.Wright.UnconditionalFour

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Influence

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

theorem finite_product_influence_rho_four
    (p : ι → α → ℝ) (hp : ∀ i b, 0 ≤ p i b)
    (hp1 : ∀ i, ∑ b, p i b = 1)
    (d : ℕ) (f : (ι → α) → ℝ)
    (hf : ∀ x, |f x| ≤ 1) (hd : HasProdDegreeLE f d)
    (hV : 0 < pvar p f) :
    ∃ j, 3 * pvar p f ^ 5 ≤
      12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 4 *
      (4 * (4 - 2 * Real.sqrt 3) * (d : ℝ) ^ 2) ^ 2 *
      pinfl p f j ^ 2 := by
  have hrow := fun x => product_row_bound d f hf hd x
  choose a ha0 hacost hacov using hrow
  have hr : RealRow f a :=
    ⟨fun x j => ha0 x j, fun x y => hacov x y⟩
  obtain ⟨j, hj⟩ := influence_bound p hp hp1 f a hr
    (Real.pi ^ 2 * (d : ℝ) ^ 2) hacost hV
  have hL : 2 * (∑ k, pincr p f k) ≤
      8 * (4 - 2 * Real.sqrt 3) * (d : ℝ) ^ 2 :=
    actual_total_increment_four p hp hp1 d f hf hd
  have hLbound : (∑ k, pincr p f k) ≤
      4 * (4 - 2 * Real.sqrt 3) * (d : ℝ) ^ 2 := by
    linarith
  have hL0 : 0 ≤ ∑ k, pincr p f k :=
    Finset.sum_nonneg (fun k _ => pincr_nonneg p hp f k)
  have hsq :
      (∑ k, pincr p f k) ^ 2 ≤
      (4 * (4 - 2 * Real.sqrt 3) * (d : ℝ) ^ 2) ^ 2 :=
    pow_le_pow_left₀ hL0 hLbound 2
  have hK4 : 0 ≤
      12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 4 := by positivity
  have hstep :=
    mul_le_mul_of_nonneg_right
      (mul_le_mul_of_nonneg_left hsq hK4)
      (sq_nonneg (pinfl p f j))
  refine ⟨j, hj.trans ?_⟩
  exact hstep

end Nightfall.Wright.UnconditionalFour
