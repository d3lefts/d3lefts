import QuadraticOscillationBound

/-!
# Joint two-direction quadratic switching

Unlike the classical one-sided 8B Markov bound applied twice (16B),
subtract the two switched source polynomials BEFORE estimating their
averages. Both share the identical initial source value, cancelling
the costly -3 f(x) term. The fair-selector identity gives 10B.

The sharper 4(1+sqrt 2)B claim uses the entire biased Bernoulli
switching polynomial and is NOT certified by this file.
-/

namespace Nightfall.Observability.QuadraticSwitching

open Finset

variable {ι α E : Type*}
  [Fintype ι] [DecidableEq ι] [Fintype E]

theorem quadratic_joint_first_switch_le_ten
    (u v : E → ι) (hne : ∀ e, u e ≠ v e)
    (c : ℝ) (h : ι → α → ℝ) (k : E → α → α → ℝ)
    (B : ℝ) (hbounded : ∀ x : ι → α,
      |quadratic u v c h k x| ≤ B)
    (x y z : ι → α) :
    firstSwitch u v h k x y - firstSwitch u v h k x z ≤
      10 * B := by
  classical
  let N : ℝ := Fintype.card (ι → Bool)
  let F : (ι → α) → ℝ := quadratic u v c h k
  have hN : 0 < N := by
    dsimp [N]
    exact_mod_cast Fintype.card_pos_iff.mpr ⟨fun _ => false⟩
  have hs (σ : ι → Bool) :
      F (switched x y σ) - F (switched x z σ) ≤ 2 * B := by
    have hy := (abs_le.mp (hbounded (switched x y σ))).2
    have hz := (abs_le.mp (hbounded (switched x z σ))).1
    dsimp [F]
    linarith
  have hsum :
      (∑ σ : ι → Bool,
        (F (switched x y σ)-F (switched x z σ))) ≤
        N * (2 * B) := by
    calc
      _ ≤ ∑ _σ : ι → Bool, (2 * B) :=
        Finset.sum_le_sum (fun σ _ => hs σ)
      _ = N * (2 * B) := by simp [N]
  have hend : F z - F y ≤ 2 * B := by
    have hy := (abs_le.mp (hbounded y)).1
    have hz := (abs_le.mp (hbounded z)).2
    dsimp [F]
    linarith
  have hfirsty := quadratic_first_switch_identity u v hne c h k x y
  have hfirstz := quadratic_first_switch_identity u v hne c h k x z
  have hident :
      N * (firstSwitch u v h k x y - firstSwitch u v h k x z) =
      4 * (∑ σ : ι → Bool,
        (F (switched x y σ)-F (switched x z σ))) +
      N * (F z - F y) := by
    dsimp [N, F] at *
    rw [Finset.sum_sub_distrib]
    nlinarith [hfirsty, hfirstz]
  have hupper :
      N * (firstSwitch u v h k x y - firstSwitch u v h k x z) ≤
        N * (10 * B) := by
    nlinarith [hident, hsum, hend, mul_le_mul_of_nonneg_left hend hN.le]
  by_contra hbad
  have hgt : 10 * B <
      firstSwitch u v h k x y - firstSwitch u v h k x z :=
    lt_of_not_ge hbad
  exact (not_lt_of_ge hupper) (mul_lt_mul_of_pos_left hgt hN)

theorem quadratic_total_range_ten
    (u v : E → ι) (hne : ∀ e, u e ≠ v e)
    (c : ℝ) (h : ι → α → ℝ)
    (k : E → α → α → ℝ) (B : ℝ)
    (hbounded : ∀ w : ι → α,
      |quadratic u v c h k w| ≤ B)
    (x y z : ι → α) :
    (∑ i : ι,
      (quadratic u v c h k (singleSwitched x y i) -
       quadratic u v c h k (singleSwitched x z i))) ≤
      10 * B := by
  have hy := quadratic_actual_switch_sum u v hne c h k x y
  have hz := quadratic_actual_switch_sum u v hne c h k x z
  have hsum :
      (∑ i : ι,
        (quadratic u v c h k (singleSwitched x y i) -
         quadratic u v c h k (singleSwitched x z i))) =
      firstSwitch u v h k x y - firstSwitch u v h k x z := by
    rw [← hy, ← hz, ← Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl
    intro i _
    ring
  rw [hsum]
  exact quadratic_joint_first_switch_le_ten
    u v hne c h k B hbounded x y z

end Nightfall.Observability.QuadraticSwitching
