import QuadraticBernoulliMoment

/-!
# Exact finite Bernoulli-t switching polynomial

A categorical quadratic has a mask mean of exact degree two.
This is the complete algebraic interpolation, not merely a numerical fit.
-/
namespace Nightfall.Observability.QuadraticBernoulli
open Finset
open Nightfall.Observability.QuadraticSwitching

variable {ι α E : Type} [Fintype ι] [DecidableEq ι] [Fintype E]

theorem bernoulli_quadratic_expansion
    (u v : E → ι) (hne : ∀ e, u e ≠ v e)
    (c : ℝ) (h : ι → α → ℝ) (k : E → α → α → ℝ)
    (x y : ι → α) (t : ℝ) :
    bernoulliMean t (fun σ => quadratic u v c h k (switched x y σ)) =
      quadratic u v c h k x + t * firstSwitch u v h k x y +
        t^2 * (quadratic u v c h k y - quadratic u v c h k x -
          firstSwitch u v h k x y) := by
  classical
  have hsingle (i : ι) :
      bernoulliMean t (fun σ => h i ((switched x y σ) i)) =
        h i (x i) + t * (h i (y i) - h i (x i)) := by
    have hpoint (σ : ι → Bool) :
        h i ((switched x y σ) i) =
          h i (x i) + maskBit σ i * (h i (y i) - h i (x i)) := by
      cases hi : σ i <;> simp [switched, maskBit, hi]
    calc
      bernoulliMean t (fun σ => h i ((switched x y σ) i)) =
          bernoulliMean t (fun σ =>
            h i (x i) + maskBit σ i * (h i (y i) - h i (x i))) := by
              apply congrArg (bernoulliMean t)
              funext σ
              exact hpoint σ
      _ = h i (x i) + t * (h i (y i) - h i (x i)) := by
          rw [bernoulliMean_add, bernoulliMean_const,
            bernoulliMean_mul_right, bernoulliMean_bit]
  have hpair (e : E) :
      bernoulliMean t (fun σ =>
        k e ((switched x y σ) (u e)) ((switched x y σ) (v e))) =
        k e (x (u e)) (x (v e)) +
        t * (k e (y (u e)) (x (v e)) +
          k e (x (u e)) (y (v e)) - 2 * k e (x (u e)) (x (v e))) +
        t^2 * (k e (y (u e)) (y (v e)) -
          k e (y (u e)) (x (v e)) -
          k e (x (u e)) (y (v e)) + k e (x (u e)) (x (v e))) := by
    let A := k e (x (u e)) (x (v e))
    let B := k e (y (u e)) (x (v e))
    let C := k e (x (u e)) (y (v e))
    let D := k e (y (u e)) (y (v e))
    have hpoint (σ : ι → Bool) :
        k e ((switched x y σ) (u e)) ((switched x y σ) (v e)) =
        A + maskBit σ (u e) * (B - A) + maskBit σ (v e) * (C - A) +
          (maskBit σ (u e) * maskBit σ (v e)) * (D - B - C + A) := by
      cases hi : σ (u e) <;> cases hj : σ (v e) <;>
        simp [switched, maskBit, hi, hj, A, B, C, D] <;> ring
    calc
      bernoulliMean t (fun σ =>
        k e ((switched x y σ) (u e)) ((switched x y σ) (v e))) =
          bernoulliMean t (fun σ =>
            A + maskBit σ (u e) * (B-A) + maskBit σ (v e) * (C-A) +
            (maskBit σ (u e) * maskBit σ (v e)) * (D-B-C+A)) := by
              apply congrArg (bernoulliMean t)
              funext σ
              exact hpoint σ
      _ = A + t * (B - A) + t * (C - A) + t^2 * (D-B-C+A) := by
          rw [bernoulliMean_add, bernoulliMean_add, bernoulliMean_add,
            bernoulliMean_const]
          rw [bernoulliMean_mul_right, bernoulliMean_mul_right,
            bernoulliMean_mul_right]
          rw [bernoulliMean_bit, bernoulliMean_bit,
            bernoulliMean_pair t (u e) (v e) (hne e)]
      _ = k e (x (u e)) (x (v e)) +
          t * (k e (y (u e)) (x (v e)) +
            k e (x (u e)) (y (v e)) - 2 * k e (x (u e)) (x (v e))) +
          t^2 * (k e (y (u e)) (y (v e)) -
            k e (y (u e)) (x (v e)) -
            k e (x (u e)) (y (v e)) + k e (x (u e)) (x (v e))) := by
            dsimp [A,B,C,D]
            ring
  have hmean :
      bernoulliMean t (fun σ => quadratic u v c h k (switched x y σ)) =
        c + (∑ i : ι, (h i (x i) + t * (h i (y i) - h i (x i)))) +
          ∑ e : E, (k e (x (u e)) (x (v e)) +
            t * (k e (y (u e)) (x (v e)) +
              k e (x (u e)) (y (v e)) - 2 * k e (x (u e)) (x (v e))) +
            t^2 * (k e (y (u e)) (y (v e)) -
              k e (y (u e)) (x (v e)) -
              k e (x (u e)) (y (v e)) + k e (x (u e)) (x (v e)))) := by
    calc
      bernoulliMean t (fun σ => quadratic u v c h k (switched x y σ)) =
        bernoulliMean t (fun σ => c +
          (∑ i : ι, h i ((switched x y σ) i)) +
          ∑ e : E, k e ((switched x y σ) (u e)) ((switched x y σ) (v e))) := rfl
      _ = c + (∑ i : ι, bernoulliMean t (fun σ => h i ((switched x y σ) i))) +
          ∑ e : E, bernoulliMean t (fun σ =>
            k e ((switched x y σ) (u e)) ((switched x y σ) (v e))) := by
              rw [bernoulliMean_add, bernoulliMean_add,
                bernoulliMean_const, bernoulliMean_sum, bernoulliMean_sum]
      _ = _ := by
        have hsums :
            (∑ i : ι, bernoulliMean t (fun σ => h i ((switched x y σ) i))) =
              ∑ i : ι, (h i (x i) + t * (h i (y i) - h i (x i))) :=
          Finset.sum_congr rfl (fun i _ => hsingle i)
        have hpairs :
            (∑ e : E, bernoulliMean t (fun σ =>
              k e ((switched x y σ) (u e)) ((switched x y σ) (v e)))) =
            ∑ e : E, (k e (x (u e)) (x (v e)) +
              t * (k e (y (u e)) (x (v e)) +
                k e (x (u e)) (y (v e)) - 2 * k e (x (u e)) (x (v e))) +
              t^2 * (k e (y (u e)) (y (v e)) -
                k e (y (u e)) (x (v e)) -
                k e (x (u e)) (y (v e)) + k e (x (u e)) (x (v e)))) :=
          Finset.sum_congr rfl (fun e _ => hpair e)
        rw [hsums, hpairs]
  calc
    bernoulliMean t (fun σ => quadratic u v c h k (switched x y σ)) = _ := hmean
    _ = quadratic u v c h k x + t * firstSwitch u v h k x y +
        t^2 * (quadratic u v c h k y - quadratic u v c h k x -
          firstSwitch u v h k x y) := by
            simp only [quadratic, firstSwitch, Finset.sum_add_distrib,
              Finset.sum_sub_distrib, Finset.mul_sum, Finset.sum_mul]
            ring_nf

end Nightfall.Observability.QuadraticBernoulli
