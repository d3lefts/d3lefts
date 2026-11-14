import QuadraticBernoulliIdentity
import QuadraticSwitchDifferenceTen

/-!
# Exact optimal Bernoulli switching of bounded finite quadratics
At t=sqrt(2)-1 the two-direction first-switch difference is
at most 4*(1+sqrt(2))*B, with all input laws untouched.
-/
namespace Nightfall.Observability.QuadraticBernoulli
open Finset
open Nightfall.Observability.QuadraticSwitching
open Nightfall.Observability.ActualProductSoftNoise

variable {ι α E : Type*} [Fintype ι] [DecidableEq ι] [Fintype E]

theorem bernoulliMean_sub (t : ℝ) (F G : (ι → Bool) → ℝ) :
    bernoulliMean t (fun σ => F σ - G σ) =
      bernoulliMean t F - bernoulliMean t G := by
  classical
  unfold bernoulliMean
  simp only [mul_sub, Finset.sum_sub_distrib]

theorem quadratic_bernoulli_switch_difference
    (u v : E → ι) (hne : ∀ e, u e ≠ v e)
    (c : ℝ) (h : ι → α → ℝ) (k : E → α → α → ℝ)
    (x y z : ι → α) (t : ℝ) :
    bernoulliMean t (fun σ =>
      quadratic u v c h k (switched x y σ) -
        quadratic u v c h k (switched x z σ)) =
      t*(1-t)*(firstSwitch u v h k x y - firstSwitch u v h k x z) +
        t^2*(quadratic u v c h k y - quadratic u v c h k z) := by
  rw [bernoulliMean_sub]
  rw [bernoulli_quadratic_expansion u v hne c h k x y t,
    bernoulli_quadratic_expansion u v hne c h k x z t]
  ring

theorem quadratic_first_switch_difference_sharp
    (u v : E → ι) (hne : ∀ e, u e ≠ v e)
    (c : ℝ) (h : ι → α → ℝ) (k : E → α → α → ℝ)
    (B : ℝ) (hbounded : ∀ w : ι → α,
      |quadratic u v c h k w| ≤ B)
    (x y z : ι → α) :
    firstSwitch u v h k x y - firstSwitch u v h k x z ≤
      4*(1+Real.sqrt 2)*B := by
  classical
  let r : ℝ := Real.sqrt 2
  let t : ℝ := r - 1
  let D : ℝ := firstSwitch u v h k x y - firstSwitch u v h k x z
  let Δ : ℝ := quadratic u v c h k y - quadratic u v c h k z
  have hr0 : 0 ≤ r := Real.sqrt_nonneg _
  have hr2 : r^2 = 2 := Real.sq_sqrt (by norm_num)
  have hr1 : 1 < r := by nlinarith
  have hrup : r < 2 := by nlinarith
  have ht0 : 0 < t := by dsimp [t]; linarith
  have ht1 : t < 1 := by dsimp [t]; linarith
  have hden : 0 < t*(1-t) := mul_pos ht0 (sub_pos.mpr ht1)
  have hroot : (1+r)*(r-1) = 1 := by nlinarith [hr2]
  have hrad : 1+t^2 = 2*(1+r)*t*(1-t) := by
    dsimp [t]
    calc
      1+(r-1)^2 = 2*(2-r) := by nlinarith [hr2]
      _ = 2*((1+r)*(r-1))*(2-r) := by rw [hroot]; ring
      _ = 2*(1+r)*(r-1)*(1-(r-1)) := by ring
  have hw (σ : ι → Bool) :
      0 ≤ maskWeight (fun _ : ι => t) σ :=
    maskWeight_nonneg (fun _ : ι => t)
      (fun _ => le_of_lt ht0) (fun _ => le_of_lt ht1) σ
  have hb (σ : ι → Bool) :
      quadratic u v c h k (switched x y σ) -
        quadratic u v c h k (switched x z σ) ≤ 2*B := by
    have hy := (abs_le.mp (hbounded (switched x y σ))).2
    have hz := (abs_le.mp (hbounded (switched x z σ))).1
    linarith
  have hmean :
      bernoulliMean t (fun σ =>
        quadratic u v c h k (switched x y σ) -
          quadratic u v c h k (switched x z σ)) ≤ 2*B := by
    unfold bernoulliMean
    calc
      (∑ σ : ι → Bool, maskWeight (fun _ => t) σ *
        (quadratic u v c h k (switched x y σ) -
          quadratic u v c h k (switched x z σ))) ≤
          ∑ σ : ι → Bool, maskWeight (fun _ => t) σ * (2*B) :=
            Finset.sum_le_sum (fun σ _ =>
              mul_le_mul_of_nonneg_left (hb σ) (hw σ))
      _ = 2*B := by
            rw [← Finset.sum_mul, maskWeight_total_one]
            ring
  have hΔ : -(2*B) ≤ Δ := by
    dsimp [Δ]
    have hy := (abs_le.mp (hbounded y)).1
    have hz := (abs_le.mp (hbounded z)).2
    linarith
  have hΔscaled : -(2*B)*t^2 ≤ Δ*t^2 :=
    mul_le_mul_of_nonneg_right hΔ (sq_nonneg t)
  have hexact :
      bernoulliMean t (fun σ =>
        quadratic u v c h k (switched x y σ) -
          quadratic u v c h k (switched x z σ)) =
        t*(1-t)*D + t^2*Δ := by
    simpa only [D, Δ] using
      (quadratic_bernoulli_switch_difference u v hne c h k x y z t)
  have hmain : t*(1-t)*D ≤ 2*B*(1+t^2) := by
    nlinarith [hmean, hexact, hΔscaled]
  have hfactor :
      t*(1-t)*D ≤ t*(1-t)*(4*(1+r)*B) := by
    calc
      t*(1-t)*D ≤ 2*B*(1+t^2) := hmain
      _ = t*(1-t)*(4*(1+r)*B) := by rw [hrad]; ring
  have hD : D ≤ 4*(1+r)*B := by
    by_contra hbad
    have hgt : 4*(1+r)*B < D := lt_of_not_ge hbad
    have hm := mul_lt_mul_of_pos_left hgt hden
    exact (not_lt_of_ge hfactor) hm
  simpa only [D, r] using hD

theorem quadratic_total_range_sharp
    (u v : E → ι) (hne : ∀ e, u e ≠ v e)
    (c : ℝ) (h : ι → α → ℝ)
    (k : E → α → α → ℝ) (B : ℝ)
    (hbounded : ∀ w : ι → α,
      |quadratic u v c h k w| ≤ B)
    (x y z : ι → α) :
    (∑ i : ι,
      (quadratic u v c h k (singleSwitched x y i) -
       quadratic u v c h k (singleSwitched x z i))) ≤
      4*(1+Real.sqrt 2)*B := by
  have hy := quadratic_actual_switch_sum u v hne c h k x y
  have hz := quadratic_actual_switch_sum u v hne c h k x z
  have heq :
      (∑ i : ι,
        (quadratic u v c h k (singleSwitched x y i) -
         quadratic u v c h k (singleSwitched x z i))) =
      firstSwitch u v h k x y - firstSwitch u v h k x z := by
    rw [← hy, ← hz, ← Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl
    intro i _
    ring
  rw [heq]
  exact quadratic_first_switch_difference_sharp u v hne c h k B hbounded x y z

end Nightfall.Observability.QuadraticBernoulli
