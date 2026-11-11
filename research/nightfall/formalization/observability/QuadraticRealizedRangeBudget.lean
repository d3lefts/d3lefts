import QuadraticOscillationBound

/-!
# Actual quadratic coordinate-range budget

A direct consequence of the kernel-checked 16B switching theorem.
The witnesses `y` and `z` are actual replacement configurations.
Finite coordinate extrema and the L² variance/range estimate are
separate interfaces, not hidden hypotheses of the switching theorem.
-/
namespace Nightfall.Observability.QuadraticSwitching

open Finset

variable {ι α E : Type*}
  [Fintype ι] [DecidableEq ι] [Fintype E]

/-- Any coordinatewise range bounds realized by two actual replacement
configurations have total mass at most 16B. -/
theorem quadratic_realized_range_budget
    (u v : E → ι) (hne : ∀ e, u e ≠ v e)
    (c : ℝ) (h : ι → α → ℝ)
    (k : E → α → α → ℝ) (B : ℝ)
    (hbounded : ∀ w : ι → α, |quadratic u v c h k w| ≤ B)
    (x y z : ι → α) (R : ι → ℝ)
    (hR : ∀ i,
      R i ≤ quadratic u v c h k (singleSwitched x y i) -
            quadratic u v c h k (singleSwitched x z i)) :
    (∑ i : ι, R i) ≤ 16 * B := by
  calc
    (∑ i : ι, R i) ≤
        ∑ i : ι,
          (quadratic u v c h k (singleSwitched x y i) -
           quadratic u v c h k (singleSwitched x z i)) := by
          apply Finset.sum_le_sum
          intro i _
          exact hR i
    _ ≤ 16 * B :=
      quadratic_total_range_sixteen u v hne c h k B hbounded x y z

/-- A section-size budget from actual replacement witnesses.
The `twoNorm` hypothesis is precisely the remaining analytic
variance-to-range interface; no probabilistic theorem is claimed here. -/
theorem quadratic_realized_half_range_budget
    (u v : E → ι) (hne : ∀ e, u e ≠ v e)
    (c : ℝ) (h : ι → α → ℝ)
    (k : E → α → α → ℝ) (B : ℝ)
    (hbounded : ∀ w : ι → α, |quadratic u v c h k w| ≤ B)
    (x y z : ι → α) (twoNorm : ι → ℝ)
    (hNorm : ∀ i,
      twoNorm i ≤ quadratic u v c h k (singleSwitched x y i) -
                  quadratic u v c h k (singleSwitched x z i)) :
    (∑ i : ι, twoNorm i) ≤ 16 * B :=
  quadratic_realized_range_budget u v hne c h k B hbounded x y z twoNorm hNorm

end Nightfall.Observability.QuadraticSwitching
