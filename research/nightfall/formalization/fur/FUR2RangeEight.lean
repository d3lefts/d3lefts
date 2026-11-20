import QuadraticRealizedRangeBudget

/-!
# Genuine degree-two global fiber-oscillation budget eight

For bounded f in [0,1] with an explicit unary-plus-binary quadratic
representation on arbitrary finite alphabets, coordinate section oscillations
have total mass at most 8, independent of coordinate count.

This is the existing genuine source switching theorem at the sharp
centering B=1/2. A missing representation equivalence remains between
generic RowBound.HasProdDegreeLE f 2 and the quadratic source parametrization.
-/
namespace Nightfall.MixtureAA.FUR2

open Finset
open Nightfall.Observability.QuadraticSwitching

variable {ι α E : Type*}
  [Fintype ι] [DecidableEq ι] [Fintype α] [Nonempty α] [Fintype E]

theorem quadratic_coordinate_range_eight
    (u v : E → ι) (hne : ∀ e, u e ≠ v e)
    (c : ℝ) (h : ι → α → ℝ)
    (k : E → α → α → ℝ)
    (hf : ∀ w : ι → α,
      0 ≤ quadratic u v c h k w ∧ quadratic u v c h k w ≤ 1)
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
         quadratic u v c h k (singleSwitched x z i))) ≤ 8 := by
  have hshift (w : ι → α) :
      quadratic u v (c - 1 / 2) h k w =
        quadratic u v c h k w - 1 / 2 := by
    dsimp [quadratic]
    ring
  have hcenter : ∀ w : ι → α,
      |quadratic u v (c - 1 / 2) h k w| ≤ (1 / 2 : ℝ) := by
    intro w
    rw [hshift]
    have hw := hf w
    apply abs_le.mpr
    constructor <;> linarith
  obtain ⟨y, z, hmax, hmin, hsum⟩ :=
    quadratic_actual_all_section_ranges_le_sixteen
      u v hne (c - 1 / 2) h k (1 / 2) hcenter x
  refine ⟨y, z, ?_, ?_, ?_⟩
  · intro i a
    have hi := hmax i a
    rw [hshift, hshift] at hi
    linarith
  · intro i a
    have hi := hmin i a
    rw [hshift, hshift] at hi
    linarith
  · calc
      (∑ i : ι,
        (quadratic u v c h k (singleSwitched x y i) -
         quadratic u v c h k (singleSwitched x z i))) =
      (∑ i : ι,
        (quadratic u v (c - 1 / 2) h k (singleSwitched x y i) -
         quadratic u v (c - 1 / 2) h k (singleSwitched x z i))) := by
          apply Finset.sum_congr rfl
          intro i _
          rw [hshift, hshift]
          ring
      _ ≤ 16 * (1 / 2 : ℝ) := hsum
      _ = 8 := by norm_num

end Nightfall.MixtureAA.FUR2
