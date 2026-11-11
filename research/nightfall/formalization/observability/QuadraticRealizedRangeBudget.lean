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


/-- Full, actual pointwise coordinate section oscillation budget.
For every bounded quadratic observable over a finite nonempty categorical
alphabet, we CONSTRUCT coordinatewise maximum and minimum replacement
vectors.  Their differences realize every section's full range, so the
global 16B bound is not conditional on supplied range witnesses.
No input mass, atom floor, random sampling or posterior certificate is
assumed; this is the finite all-alphabet switching-to-section interface. -/
theorem quadratic_actual_all_section_ranges_le_sixteen
    [Nonempty α]
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
         quadratic u v c h k (singleSwitched x z i))) ≤ 16 * B := by
  classical
  let F : (ι → α) → ℝ := quadratic u v c h k
  have hext (i : ι) :
      ∃ a b : α,
        (∀ t : α, F (singleSwitched x (fun _ => t) i) ≤
          F (singleSwitched x (fun _ => a) i)) ∧
        (∀ t : α, F (singleSwitched x (fun _ => b) i) ≤
          F (singleSwitched x (fun _ => t) i)) := by
    obtain ⟨a, _, hmax⟩ :=
      Finset.exists_max_image (Finset.univ : Finset α)
        (fun t : α => F (singleSwitched x (fun _ => t) i))
        Finset.univ_nonempty
    obtain ⟨b, _, hmin⟩ :=
      Finset.exists_max_image (Finset.univ : Finset α)
        (fun t : α => -F (singleSwitched x (fun _ => t) i))
        Finset.univ_nonempty
    refine ⟨a, b, ?_, ?_⟩
    · intro t
      exact hmax t (Finset.mem_univ t)
    · intro t
      have ht := hmin t (Finset.mem_univ t)
      linarith
  choose y z hchoice using hext
  have hconst (g : ι → α) (i : ι) :
      singleSwitched x g i =
        singleSwitched x (fun _ => g i) i := by
    funext j
    by_cases hj : j = i <;> simp [singleSwitched, hj]
  refine ⟨y, z, ?_, ?_, ?_⟩
  · intro i a
    have hi := (hchoice i).1 a
    simpa only [hconst y i] using hi
  · intro i a
    have hi := (hchoice i).2 a
    simpa only [hconst z i] using hi
  · exact quadratic_total_range_sixteen u v hne c h k B
      hbounded x y z

end Nightfall.Observability.QuadraticSwitching
