import Mathlib
import QuadraticMatchedParity

/-!
# Finite quadratic switching: exact independent-selector derivative certificate

All finite heterogeneous alphabets, arbitrary input values, and dense
pairwise interaction graphs.  This module proves the elementary but
load-bearing exact two-draw switching identity in which the four
uniform selector averages determine the first-order switching
coefficient.  It makes no assumption on fair *input* distributions.
It is not the full all-law quadratic influence theorem.
-/

namespace Nightfall.Observability.QuadraticSwitching
open Finset
open Nightfall.Observability.QuadraticMatching
open Nightfall.Observability.ParityBlocks

variable {ι α E : Type*}
  [Fintype ι] [DecidableEq ι] [Fintype E]

/-- A coordinatewise switch between two arbitrary categorical inputs. -/
def switched (x y : ι → α) (σ : ι → Bool) : ι → α :=
  fun i => if σ i then y i else x i

theorem selector_pair_four
    (F : Bool → Bool → ℝ) (i j : ι) (hij : i ≠ j) :
    (4 : ℝ) * (∑ σ : ι → Bool, F (σ i) (σ j)) =
      (Fintype.card (ι → Bool) : ℝ) *
        (F false false + F false true + F true false + F true true) := by
  let a : ι → Bool → Bool := fun _ b => b
  have h10 : (∑ σ : ι → Bool, F (σ i) (σ j)) =
      (∑ σ : ι → Bool, F (!(σ i)) (σ j)) := by
    simpa [a] using (cross_block_all_sides a a a a F i j hij true false)
  have h01 : (∑ σ : ι → Bool, F (σ i) (σ j)) =
      (∑ σ : ι → Bool, F (σ i) (!(σ j))) := by
    simpa [a] using (cross_block_all_sides a a a a F i j hij false true)
  have h11 : (∑ σ : ι → Bool, F (σ i) (σ j)) =
      (∑ σ : ι → Bool, F (!(σ i)) (!(σ j))) := by
    simpa [a] using (cross_block_all_sides a a a a F i j hij true true)
  have hp (σ : ι → Bool) :
      F (σ i) (σ j) + F (!(σ i)) (σ j) +
        F (σ i) (!(σ j)) + F (!(σ i)) (!(σ j)) =
        F false false + F false true + F true false + F true true := by
    cases hi : σ i <;> cases hj : σ j <;> simp [hi, hj] <;> ring
  calc
    (4 : ℝ) * (∑ σ : ι → Bool, F (σ i) (σ j)) =
      (∑ σ : ι → Bool, F (σ i) (σ j)) +
        (∑ σ : ι → Bool, F (!(σ i)) (σ j)) +
        (∑ σ : ι → Bool, F (σ i) (!(σ j))) +
        (∑ σ : ι → Bool, F (!(σ i)) (!(σ j))) := by
          rw [← h10, ← h01, ← h11]
          ring
    _ = ∑ σ : ι → Bool,
        (F (σ i) (σ j) + F (!(σ i)) (σ j) +
          F (σ i) (!(σ j)) + F (!(σ i)) (!(σ j))) := by
          simp only [Finset.sum_add_distrib]
    _ = ∑ _σ : ι → Bool,
        (F false false + F false true + F true false + F true true) := by
          apply Finset.sum_congr rfl
          intro σ _
          exact hp σ
    _ = (Fintype.card (ι → Bool) : ℝ) *
        (F false false + F false true + F true false + F true true) := by
          simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul] <;> ring

/-- Switching average on a single coordinate, without assuming any
input distribution. -/
theorem selector_one_two
    (G : Bool → ℝ) (i : ι) :
    (2:ℝ) * (∑ σ : ι → Bool, G (σ i)) =
      (Fintype.card (ι → Bool) : ℝ) * (G false + G true) :=
  selector_double_sum i G


/-- Pointwise first-order algebra commutes with arbitrary finite sums. -/
theorem sum_linear_switch_algebra
    (a b : ι → ℝ) (N : ℝ) :
    N * (∑ t : ι, b t - a t) =
      -3 * N * (∑ t : ι, a t) +
        N * (∑ t : ι, 2 * (a t + b t)) -
        N * (∑ t : ι, b t) := by
  calc
    N * (∑ t : ι, b t - a t) =
        ∑ t : ι, N * (b t - a t) := by rw [Finset.mul_sum]
    _ = ∑ t : ι,
        (-3 * N * a t + N * (2 * (a t + b t)) - N * b t) := by
          apply Finset.sum_congr rfl
          intro t _
          ring
    _ = -3 * N * (∑ t : ι, a t) +
        N * (∑ t : ι, 2 * (a t + b t)) -
        N * (∑ t : ι, b t) := by
          simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib,
            Finset.mul_sum]
          ring

/-- The corresponding exact finite-sum quadratic algebra. -/
theorem sum_pair_switch_algebra
    (a b c d : E → ℝ) (N : ℝ) :
    N * (∑ t : E, c t + b t - 2 * a t) =
      -3 * N * (∑ t : E, a t) +
        N * (∑ t : E, a t + b t + c t + d t) -
        N * (∑ t : E, d t) := by
  calc
    N * (∑ t : E, c t + b t - 2 * a t) =
        ∑ t : E, N * (c t + b t - 2 * a t) := by
          rw [Finset.mul_sum]
    _ = ∑ t : E,
        (-3 * N * a t + N * (a t + b t + c t + d t) - N * d t) := by
          apply Finset.sum_congr rfl
          intro t _
          ring
    _ = -3 * N * (∑ t : E, a t) +
        N * (∑ t : E, a t + b t + c t + d t) -
        N * (∑ t : E, d t) := by
          simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib,
            Finset.mul_sum]
          ring

/-- Actual degree-two pointwise representation on an arbitrary
finite product alphabet with an arbitrary oriented edge family. -/
noncomputable def quadratic
    (u v : E → ι) (c : ℝ) (h : ι → α → ℝ)
    (k : E → α → α → ℝ) (x : ι → α) : ℝ :=
  c + (∑ i : ι, h i (x i)) +
    ∑ e : E, k e (x (u e)) (x (v e))

/-- The coefficient of the first-order simultaneous switching
perturbation. This will later be identified with the sum of actual
one-coordinate replacement differences. -/
noncomputable def firstSwitch
    (u v : E → ι) (h : ι → α → ℝ)
    (k : E → α → α → ℝ) (x y : ι → α) : ℝ :=
  (∑ i : ι, (h i (y i) - h i (x i))) +
    (∑ e : E,
      (k e (y (u e)) (x (v e)) +
       k e (x (u e)) (y (v e)) -
       2 * k e (x (u e)) (x (v e))))

/-- Exact combinatorial identity for any genuine degree-two function,
with no independent laws or bound assumptions. -/
theorem quadratic_first_switch_identity
    (u v : E → ι) (hne : ∀ e, u e ≠ v e)
    (c : ℝ) (h : ι → α → ℝ)
    (k : E → α → α → ℝ) (x y : ι → α) :
    (Fintype.card (ι → Bool) : ℝ) * firstSwitch u v h k x y =
      -3 * (Fintype.card (ι → Bool) : ℝ) * quadratic u v c h k x +
       4 * (∑ σ : ι → Bool, quadratic u v c h k (switched x y σ)) -
       (Fintype.card (ι → Bool) : ℝ) * quadratic u v c h k y := by
  let N : ℝ := Fintype.card (ι → Bool)
  have hc : (∑ _σ : ι → Bool, c) = N * c := by simp [N]
  have hs (i : ι) :
      2 * (∑ σ : ι → Bool, h i ((switched x y σ) i)) =
         N * (h i (x i) + h i (y i)) := by
    calc
      2 * (∑ σ : ι → Bool, h i ((switched x y σ) i)) =
          2 * (∑ σ : ι → Bool,
            if σ i then h i (y i) else h i (x i)) := by
            apply congrArg (fun t : ℝ => 2 * t)
            apply Finset.sum_congr rfl
            intro σ _
            dsimp [switched]
            cases σ i <;> rfl
      _ = N * (h i (x i) + h i (y i)) := by
            simpa [N] using
              (selector_one_two (fun b => if b then h i (y i) else h i (x i)) i)
  have hp (e : E) :
      4 * (∑ σ : ι → Bool,
        k e ((switched x y σ) (u e)) ((switched x y σ) (v e))) =
        N * (k e (x (u e)) (x (v e)) +
          k e (x (u e)) (y (v e)) +
          k e (y (u e)) (x (v e)) +
          k e (y (u e)) (y (v e))) := by
    simpa [switched, N] using
      (selector_pair_four
        (fun a b => k e (if a then y (u e) else x (u e))
                         (if b then y (v e) else x (v e)))
        (u e) (v e) (hne e))
  have hsing :
      4 * (∑ σ : ι → Bool, ∑ i : ι,
        h i ((switched x y σ) i)) =
        N * (∑ i : ι, 2 * (h i (x i) + h i (y i))) := by
    calc
      4 * (∑ σ : ι → Bool, ∑ i : ι,
        h i ((switched x y σ) i)) =
          ∑ i : ι, 2 * (2 * (∑ σ : ι → Bool,
            h i ((switched x y σ) i))) := by
            rw [Finset.sum_comm, Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro i _
            ring
      _ = ∑ i : ι, 2 * (N * (h i (x i) + h i (y i))) := by
            apply Finset.sum_congr rfl
            intro i _
            rw [hs]
      _ = N * (∑ i : ι, 2 * (h i (x i) + h i (y i))) := by
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro i _
            ring
  have hpair :
      4 * (∑ σ : ι → Bool, ∑ e : E,
        k e ((switched x y σ) (u e)) ((switched x y σ) (v e))) =
       N * (∑ e : E,
          (k e (x (u e)) (x (v e)) +
           k e (x (u e)) (y (v e)) +
           k e (y (u e)) (x (v e)) +
           k e (y (u e)) (y (v e)))) := by
    calc
      4 * (∑ σ : ι → Bool, ∑ e : E,
        k e ((switched x y σ) (u e)) ((switched x y σ) (v e))) =
        ∑ e : E, 4 * (∑ σ : ι → Bool,
          k e ((switched x y σ) (u e)) ((switched x y σ) (v e))) := by
            rw [Finset.sum_comm, Finset.mul_sum]
      _ = ∑ e : E,
          N * (k e (x (u e)) (x (v e)) +
           k e (x (u e)) (y (v e)) +
           k e (y (u e)) (x (v e)) +
           k e (y (u e)) (y (v e))) := by
            apply Finset.sum_congr rfl
            intro e _
            rw [hp]
      _ = _ := by rw [Finset.mul_sum]
  have hmean :
      4 * (∑ σ : ι → Bool,
        quadratic u v c h k (switched x y σ)) =
        4 * (N * c) +
        N * (∑ i : ι, 2 * (h i (x i) + h i (y i))) +
        N * (∑ e : E,
          (k e (x (u e)) (x (v e)) +
           k e (x (u e)) (y (v e)) +
           k e (y (u e)) (x (v e)) +
           k e (y (u e)) (y (v e)))) := by
    calc
      4 * (∑ σ : ι → Bool,
        quadratic u v c h k (switched x y σ)) =
          4 * (∑ _σ : ι → Bool, c) +
          4 * (∑ σ : ι → Bool, ∑ i : ι,
            h i ((switched x y σ) i)) +
          4 * (∑ σ : ι → Bool, ∑ e : E,
            k e ((switched x y σ) (u e))
              ((switched x y σ) (v e))) := by
            simp only [quadratic, Finset.sum_add_distrib]
            ring
      _ = _ := by rw [hc, hsing, hpair]
  have ha := sum_linear_switch_algebra
    (fun i : ι => h i (x i)) (fun i : ι => h i (y i)) N
  have hb := sum_pair_switch_algebra
    (fun e : E => k e (x (u e)) (x (v e)))
    (fun e : E => k e (x (u e)) (y (v e)))
    (fun e : E => k e (y (u e)) (x (v e)))
    (fun e : E => k e (y (u e)) (y (v e))) N
  rw [hmean]
  dsimp [quadratic, firstSwitch]
  linear_combination ha + hb
end Nightfall.Observability.QuadraticSwitching
