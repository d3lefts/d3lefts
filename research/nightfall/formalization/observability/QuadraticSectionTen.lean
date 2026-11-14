import QuadraticSwitchDifferenceTen
import QuadraticRealizedRangeBudget

/-! Original-source finite quadratic switching ranges, simultaneously
compared before application of a boundedness estimate. -/

namespace Nightfall.Observability.QuadraticSwitching
open Finset

variable {ι α E : Type*}
  [Fintype ι] [DecidableEq ι] [Fintype E]

theorem quadratic_actual_all_section_ranges_le_ten
    [Fintype α] [Nonempty α]
    (u v : E → ι) (hne : ∀ e, u e ≠ v e)
    (c : ℝ) (h : ι → α → ℝ)
    (k : E → α → α → ℝ) (B : ℝ)
    (hbounded : ∀ w : ι → α, |quadratic u v c h k w| ≤ B)
    (x : ι → α) :
    ∃ y z : ι → α,
      (∀ i a,
        quadratic u v c h k (singleSwitched x (fun _ => a) i) ≤
          quadratic u v c h k (singleSwitched x y i)) ∧
      (∀ i a,
        quadratic u v c h k (singleSwitched x z i) ≤
          quadratic u v c h k (singleSwitched x (fun _ => a) i)) ∧
      (∑ i : ι,
        (quadratic u v c h k (singleSwitched x y i) -
         quadratic u v c h k (singleSwitched x z i))) ≤ 10 * B := by
  obtain ⟨y,z,hy,hz,_⟩ :=
    quadratic_actual_all_section_ranges_le_sixteen
      u v hne c h k B hbounded x
  refine ⟨y,z,hy,hz,?_⟩
  exact quadratic_total_range_ten u v hne c h k B hbounded x y z

end Nightfall.Observability.QuadraticSwitching
