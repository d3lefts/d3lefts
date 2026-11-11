import QuadraticSingleReplacement

/-!
# Genuine degree-two bounded switching and global pointwise range budget

For every finite independent-input alphabet representation (the proof
itself uses NO input probabilities), every real bounded degree-two
quadratic polynomial with an arbitrary dense oriented nonloop graph,
and every two global comparison configurations, prove:

  |sum_j (f(x_{j <- y_j}) - f(x))| <= 8 B,
  sum_j (f(x_{j <- y_j}) - f(x_{j <- z_j})) <= 16 B.

The proof uses exact selector averages and first-order finite-difference
identities previously compiled; no Markov bound is assumed.

This is a pointwise switching subtheorem, not an end-to-end influence bound.
-/
namespace Nightfall.Observability.QuadraticSwitching
open Finset

variable {ι α E : Type*}
  [Fintype ι] [DecidableEq ι] [Fintype E]

theorem quadratic_switch_sum_abs_le_eight
    (u v : E → ι) (hne : ∀ e, u e ≠ v e)
    (c : ℝ) (h : ι → α → ℝ)
    (k : E → α → α → ℝ) (B : ℝ)
    (hbounded : ∀ z : ι → α, |quadratic u v c h k z| ≤ B)
    (x y : ι → α) :
    |(∑ j : ι,
      (quadratic u v c h k (singleSwitched x y j) -
       quadratic u v c h k x))| ≤ 8 * B := by
  classical
  let N : ℝ := Fintype.card (ι → Bool)
  let f := quadratic u v c h k
  have hN : 0 < N := by
    dsimp [N]
    exact_mod_cast Fintype.card_pos_iff.mpr ⟨fun _ => false⟩
  have hsumUpper :
      (∑ σ : ι → Bool, f (switched x y σ)) ≤ N * B := by
    calc
      (∑ σ : ι → Bool, f (switched x y σ)) ≤
          ∑ _σ : ι → Bool, B := by
          apply Finset.sum_le_sum
          intro σ _
          exact (abs_le.mp (hbounded (switched x y σ))).2
      _ = N * B := by simp [N]
  have hsumLower :
      -(N * B) ≤ (∑ σ : ι → Bool, f (switched x y σ)) := by
    have h :
        (∑ _σ : ι → Bool, -B) ≤
        ∑ σ : ι → Bool, f (switched x y σ) := by
      apply Finset.sum_le_sum
      intro σ _
      exact (abs_le.mp (hbounded (switched x y σ))).1
    have hc : (∑ _σ : ι → Bool, -B) = -(N * B) := by
      simp [N]
    rw [hc] at h
    exact h
  have hfxlo : -B ≤ f x := (abs_le.mp (hbounded x)).1
  have hfxhi : f x ≤ B := (abs_le.mp (hbounded x)).2
  have hfylo : -B ≤ f y := (abs_le.mp (hbounded y)).1
  have hfyhi : f y ≤ B := (abs_le.mp (hbounded y)).2
  have hq := quadratic_first_switch_identity u v hne c h k x y
  have hxlo : 0 ≤ N * (f x + B) :=
    mul_nonneg hN.le (by linarith)
  have hylo : 0 ≤ N * (f y + B) :=
    mul_nonneg hN.le (by linarith)
  have hxhi : 0 ≤ N * (B - f x) :=
    mul_nonneg hN.le (by linarith)
  have hyhi : 0 ≤ N * (B - f y) :=
    mul_nonneg hN.le (by linarith)
  have hupper :
      N * firstSwitch u v h k x y ≤ N * (8 * B) := by
    have heq : N * firstSwitch u v h k x y =
        -3 * N * f x +
         4 * (∑ σ : ι → Bool, f (switched x y σ)) -
         N * f y := hq
    nlinarith [heq, hsumUpper, hxlo, hylo]
  have hlower :
      N * (-(8 * B)) ≤ N * firstSwitch u v h k x y := by
    have heq : N * firstSwitch u v h k x y =
        -3 * N * f x +
         4 * (∑ σ : ι → Bool, f (switched x y σ)) -
         N * f y := hq
    nlinarith [heq, hsumLower, hxhi, hyhi]
  have hu : firstSwitch u v h k x y ≤ 8 * B := by
    by_contra hbad
    have hd : 0 < firstSwitch u v h k x y - 8 * B :=
      sub_pos.mpr (lt_of_not_ge hbad)
    have hprod := mul_pos hN hd
    nlinarith [hupper, hprod]
  have hl : -(8 * B) ≤ firstSwitch u v h k x y := by
    by_contra hbad
    have hd : 0 < -(8 * B) - firstSwitch u v h k x y :=
      sub_pos.mpr (lt_of_not_ge hbad)
    have hprod := mul_pos hN hd
    nlinarith [hlower, hprod]
  rw [quadratic_actual_switch_sum u v hne c h k x y]
  exact abs_le.mpr ⟨hl, hu⟩

/-- The all-coordinate oscillation budget, simultaneously and pointwise
for ANY two coordinate replacement vectors y and z. In particular,
taking coordinatewise maximizers/minimizers yields the 16B sum of ranges. -/
theorem quadratic_total_range_sixteen
    (u v : E → ι) (hne : ∀ e, u e ≠ v e)
    (c : ℝ) (h : ι → α → ℝ)
    (k : E → α → α → ℝ) (B : ℝ)
    (hbounded : ∀ z : ι → α, |quadratic u v c h k z| ≤ B)
    (x y z : ι → α) :
    (∑ j : ι,
      (quadratic u v c h k (singleSwitched x y j) -
       quadratic u v c h k (singleSwitched x z j))) ≤ 16 * B := by
  have hplus := (abs_le.mp
    (quadratic_switch_sum_abs_le_eight u v hne c h k B hbounded x y)).2
  have hminus := (abs_le.mp
    (quadratic_switch_sum_abs_le_eight u v hne c h k B hbounded x z)).1
  have heq :
      (∑ j : ι,
        (quadratic u v c h k (singleSwitched x y j) -
         quadratic u v c h k (singleSwitched x z j))) =
      (∑ j : ι,
        (quadratic u v c h k (singleSwitched x y j) -
         quadratic u v c h k x)) -
      (∑ j : ι,
        (quadratic u v c h k (singleSwitched x z j) -
         quadratic u v c h k x)) := by
    rw [← Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl
    intro j _
    ring
  rw [heq]
  linarith
end Nightfall.Observability.QuadraticSwitching
