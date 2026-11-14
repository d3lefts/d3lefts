import Mathlib

/-!
# NIGHTFALL: all-horizon source-reuse authorization cost

Formal scalar Bellman problem for one stable fair Boolean evidence source B and
n fresh fair Boolean evidence sources A_t, with exact OR authorization.

The recurrence is the *specified* Bellman model. These declarations certify
its closed solution and the exact root-query threshold. They do not by
themselves formalize the reduction from arbitrary operational policies to
this Bellman recurrence, nor effect-time enforcement.
-/

namespace Nightfall.AuthorityHorizon

/-- Cost of reading and retaining the stable evidence source first. -/
def stableCost (n : ℕ) (x y : ℚ) : ℚ :=
  y + (n : ℚ) * x / 2

/-- Read fresh sources first, reading B only at the first failed volatile proof. -/
def volatileCost : ℕ → ℚ → ℚ → ℚ
  | 0, _, _ => 0
  | n + 1, x, y =>
      x + y / 2 + (n : ℚ) * x / 4 + volatileCost n x y / 2

/-- The specified Bellman optimum: first read B, or first read A. -/
def bellmanCost : ℕ → ℚ → ℚ → ℚ
  | 0, _, _ => 0
  | n + 1, x, y =>
      min (stableCost (n + 1) x y)
        (x + y / 2 + (n : ℚ) * x / 4 + bellmanCost n x y / 2)

/-- Explicit volatile-first policy cost; powers are rational powers. -/
def volatileClosed (n : ℕ) (x y : ℚ) : ℚ :=
  ((n : ℚ) / 2 + 1 - (1 / 2 : ℚ) ^ n) * x +
    (1 - (1 / 2 : ℚ) ^ n) * y

private theorem affine_min (c a b : ℚ) :
    c + min a b / 2 = min (c + a / 2) (c + b / 2) := by
  rcases le_total a b with hab | hba
  · rw [min_eq_left hab, min_eq_left (by linarith : c + a / 2 ≤ c + b / 2)]
  · rw [min_eq_right hba, min_eq_right (by linarith : c + b / 2 ≤ c + a / 2)]

private theorem stable_step (n : ℕ) (x y : ℚ) :
    x + y / 2 + (n : ℚ) * x / 4 + stableCost n x y / 2 =
      stableCost (n + 1) x y + x / 2 := by
  simp only [stableCost, Nat.cast_add, Nat.cast_one]
  ring

/-- Exact minimization of the entire finite-horizon Bellman recurrence. -/
theorem bellman_eq_min (n : ℕ) (x y : ℚ)
    (hx : 0 ≤ x) (hy : 0 ≤ y) :
    bellmanCost n x y = min (stableCost n x y) (volatileCost n x y) := by
  induction n with
  | zero =>
      simp [bellmanCost, stableCost, volatileCost, min_eq_right hy]
  | succ n ih =>
      change min (stableCost (n + 1) x y)
        (x + y / 2 + (n : ℚ) * x / 4 + bellmanCost n x y / 2) =
          min (stableCost (n + 1) x y) (volatileCost (n + 1) x y)
      rw [ih]
      rw [affine_min, stable_step]
      change min (stableCost (n + 1) x y)
        (min (stableCost (n + 1) x y + x / 2) (volatileCost (n + 1) x y)) =
          min (stableCost (n + 1) x y) (volatileCost (n + 1) x y)
      rw [← min_assoc]
      have h : stableCost (n + 1) x y ≤ stableCost (n + 1) x y + x / 2 := by
        linarith
      rw [min_eq_left h]

/-- Exact closed formula for the volatile-first strategy for all n. -/
theorem volatile_eq_closed (n : ℕ) (x y : ℚ) :
    volatileCost n x y = volatileClosed n x y := by
  induction n with
  | zero =>
      simp [volatileCost, volatileClosed]
  | succ n ih =>
      change x + y / 2 + (n : ℚ) * x / 4 + volatileCost n x y / 2 =
        volatileClosed (n + 1) x y
      rw [ih]
      simp only [volatileClosed, Nat.cast_add, Nat.cast_one, pow_succ]
      ring

/-- Formal closed-form all-horizon cost identity (under the Bellman model). -/
theorem all_horizon_cost (n : ℕ) (x y : ℚ)
    (hx : 0 ≤ x) (hy : 0 ≤ y) :
    bellmanCost n x y =
      min (y + (n : ℚ) * x / 2)
        (((n : ℚ) / 2 + 1 - (1 / 2 : ℚ) ^ n) * x +
          (1 - (1 / 2 : ℚ) ^ n) * y) := by
  rw [bellman_eq_min n x y hx hy, volatile_eq_closed]
  rfl

private theorem geometric_inverse (n : ℕ) :
    (1 / 2 : ℚ) ^ n * (2 : ℚ) ^ n = 1 := by
  rw [← mul_pow]
  norm_num

private theorem scaled_difference (n : ℕ) (x y : ℚ) :
    (volatileClosed n x y - stableCost n x y) * (2 : ℚ) ^ n =
      ((2 : ℚ) ^ n - 1) * x - y := by
  have hi := geometric_inverse n
  dsimp [volatileClosed, stableCost]
  calc
    ((((n : ℚ) / 2 + 1 - (1 / 2 : ℚ) ^ n) * x +
      (1 - (1 / 2 : ℚ) ^ n) * y) -
      (y + (n : ℚ) * x / 2)) * (2 : ℚ) ^ n =
        ((2 : ℚ) ^ n - (1 / 2 : ℚ) ^ n * (2 : ℚ) ^ n) * x -
          ((1 / 2 : ℚ) ^ n * (2 : ℚ) ^ n) * y := by ring
    _ = ((2 : ℚ) ^ n - 1) * x - y := by rw [hi]; ring

/-- B first is optimal exactly up to the exponential threshold; equality is a tie. -/
theorem stable_first_iff (n : ℕ) (x y : ℚ) :
    stableCost n x y ≤ volatileClosed n x y ↔
      y ≤ ((2 : ℚ) ^ n - 1) * x := by
  have hp : 0 < (2 : ℚ) ^ n := pow_pos (by norm_num) n
  have hd := scaled_difference n x y
  constructor
  · intro hs
    have hnon : 0 ≤ volatileClosed n x y - stableCost n x y := sub_nonneg.mpr hs
    have hscaled : 0 ≤ (volatileClosed n x y - stableCost n x y) * (2 : ℚ) ^ n :=
      mul_nonneg hnon (le_of_lt hp)
    rw [hd] at hscaled
    exact sub_nonneg.mp hscaled
  · intro ht
    have hnon : 0 ≤ ((2 : ℚ) ^ n - 1) * x - y := sub_nonneg.mpr ht
    rw [← hd] at hnon
    have hnon' : 0 ≤ volatileClosed n x y - stableCost n x y := by
      by_contra hh
      have hneg : volatileClosed n x y - stableCost n x y < 0 := lt_of_not_ge hh
      have hnegprod :
          (volatileClosed n x y - stableCost n x y) * (2 : ℚ) ^ n < 0 :=
        mul_neg_of_neg_of_pos hneg hp
      linarith
    exact sub_nonneg.mp hnon'

/-- Strictly below threshold B is the uniquely cheaper first-query branch. -/
theorem stable_first_strict (n : ℕ) (x y : ℚ)
    (h : y < ((2 : ℚ) ^ n - 1) * x) :
    stableCost n x y < volatileClosed n x y := by
  have hp : 0 < (2 : ℚ) ^ n := pow_pos (by norm_num) n
  have hd := scaled_difference n x y
  have hpositive : 0 < ((2 : ℚ) ^ n - 1) * x - y := sub_pos.mpr h
  rw [← hd] at hpositive
  by_contra hn
  have hle : volatileClosed n x y - stableCost n x y ≤ 0 := by linarith
  have hprod : (volatileClosed n x y - stableCost n x y) * (2 : ℚ) ^ n ≤ 0 :=
    mul_nonpos_of_nonpos_of_nonneg hle (le_of_lt hp)
  linarith

end Nightfall.AuthorityHorizon
