import Mathlib

/-!
# Exact four-site 5B obstruction to improving the Q2 source owner cover

This is a *purely discrete* mathematical certificate:
* an explicit quadratic Boolean polynomial with all 16 values in {-1,0,1};
* the six exact mixed second differences are (-1,2,1,1,-2,-1);
* any nonnegative vertex costs whose endpoint maximum covers each edge
  have total cost at least 5, attained by (2,2,1,0).

The separate identification of these differences with canonical
Efron--Stein pair kernels under a degenerate source law is still an
unformalized SOURCE-level transfer. This file alone is not the
unrestricted 5B lower-bound theorem in the original p,f formalization
and does not refute the potential 6B cover or certify C96.
-/

namespace Nightfall.Q2FiveCoverObstruction

open Finset

def bit (x : Fin 4 → Bool) (i : Fin 4) : ℤ :=
  if x i then 1 else 0

def quadratic (x : Fin 4 → Bool) : ℤ :=
  let a := bit x 0
  let b := bit x 1
  let c := bit x 2
  let d := bit x 3
  (0 : ℤ) - a + b - c + d - a*b + 2*a*c + a*d + b*c - 2*b*d - c*d

/-- Exact exhaustive Boolean enumeration; no real-number roundoff. -/
theorem quadratic_pointwise_bounded :
    ∀ x : Fin 4 → Bool, |quadratic x| ≤ 1 := by
  intro x
  cases h0 : x 0 <;> cases h1 : x 1 <;>
    cases h2 : x 2 <;> cases h3 : x 3 <;>
    norm_num [quadratic, bit, h0, h1, h2, h3]

def single (i : Fin 4) : Fin 4 → Bool :=
  fun j => decide (j = i)

def double (i j : Fin 4) : Fin 4 → Bool :=
  fun k => decide (k = i ∨ k = j)

def zero : Fin 4 → Bool := fun _ => false

def secondDifference (i j : Fin 4) : ℤ :=
  quadratic (double i j) -
    quadratic (single i) - quadratic (single j) + quadratic zero

/-- Original-base mixed quadratic second differences on six actual edges. -/
theorem six_mixed_second_differences :
    secondDifference 0 1 = -1 ∧
    secondDifference 0 2 = 2 ∧
    secondDifference 0 3 = 1 ∧
    secondDifference 1 2 = 1 ∧
    secondDifference 1 3 = -2 ∧
    secondDifference 2 3 = -1 := by
  norm_num [secondDifference, quadratic, bit, double, single, zero]

/-- Any endpoint-max owner cover for amplitudes (1,2,1,1,2,1)
costs at least 5. A nonnegative cost vector cannot cover the two
disjoint heavy edges of weight 2 without leaving one light
transversal edge that costs at least 1 more. -/
theorem owner_cover_cost_ge_five
    (c : Fin 4 → ℝ)
    (hc : ∀ i, 0 ≤ c i)
    (h01 : 1 ≤ max (c 0) (c 1))
    (h02 : 2 ≤ max (c 0) (c 2))
    (h03 : 1 ≤ max (c 0) (c 3))
    (h12 : 1 ≤ max (c 1) (c 2))
    (h13 : 2 ≤ max (c 1) (c 3))
    (h23 : 1 ≤ max (c 2) (c 3)) :
    5 ≤ c 0 + c 1 + c 2 + c 3 := by
  rcases (le_max_iff.mp h02) with h0 | h2
  · rcases (le_max_iff.mp h13) with h1 | h3
    · rcases (le_max_iff.mp h23) with h2' | h3'
      · linarith [hc 3]
      · linarith [hc 2]
    · rcases (le_max_iff.mp h12) with h1' | h2'
      · linarith [hc 2]
      · linarith [hc 1]
  · rcases (le_max_iff.mp h13) with h1 | h3
    · rcases (le_max_iff.mp h03) with h0' | h3'
      · linarith [hc 3]
      · linarith [hc 0]
    · rcases (le_max_iff.mp h01) with h0' | h1'
      · linarith [hc 1]
      · linarith [hc 0]

def attainedCost : Fin 4 → ℝ :=
  fun i => if i = 0 then 2 else if i = 1 then 2 else if i = 2 then 1 else 0

theorem owner_cover_five_attained :
    (∀ i, 0 ≤ attainedCost i) ∧
    1 ≤ max (attainedCost 0) (attainedCost 1) ∧
    2 ≤ max (attainedCost 0) (attainedCost 2) ∧
    1 ≤ max (attainedCost 0) (attainedCost 3) ∧
    1 ≤ max (attainedCost 1) (attainedCost 2) ∧
    2 ≤ max (attainedCost 1) (attainedCost 3) ∧
    1 ≤ max (attainedCost 2) (attainedCost 3) ∧
    (attainedCost 0 + attainedCost 1 +
      attainedCost 2 + attainedCost 3 = 5) := by
  constructor
  · intro i
    fin_cases i <;> norm_num [attainedCost]
  · norm_num [attainedCost]

end Nightfall.Q2FiveCoverObstruction
