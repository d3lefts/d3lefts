import QuadraticHoeffdingBridge
import QuadraticRealizedRangeBudget

/-!
# Source-level finite quadratic joint theorem — scoped actual function

This file combines two fully proved, non-oracle inputs under a SINGLE
Lean 4.33 / pinned Turturean project:
1. the classical exponent-5/2 influence bound for a genuine normalized
   bounded finite-product Hoeffding-degree-two function;
2. the exact 16B pointwise coordinate-section range budget obtained by
   constructing actual maximizing/minimizing replacements.

The additional structural hypothesis hpoly states that the SAME actual
function f has an explicit quadratic representation. It is not a matching,
moment, influence or posterior certificate, but the implication
ESDegreeLE -> quadratic representation is not produced by this module.
The variance-squared exponent-two influence inequality is NOT proved.
No custom axioms, sorry, or proof holes.
-/

namespace Nightfall.Observability.QuadraticUnifiedFinite

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.Observability.QuadraticSwitching

variable {ι α E : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]
  [Fintype E]

/-- Joint actual-function certificate with no assumed matching, range or
moment budgets. Gives the inherited influence (5/2) result and derives
the full 16B section range from finite extrema of the *same* f.
This is NOT the exponent-two endpoint. -/
theorem actual_degree_two_baseline_and_all_sections
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ)
    (hf : ∀ x, |f x| ≤ 1)
    (hdegree : ESDegreeLE p f 2)
    (u v : E → ι) (hne : ∀ e, u e ≠ v e)
    (c : ℝ) (h : ι → α → ℝ) (k : E → α → α → ℝ)
    (hpoly : ∀ x, f x = quadratic u v c h k x) :
    (pvar p f = 0 ∨
      ∃ j : ι,
        3 * pvar p f ^ 5 ≤
          12500 * (Real.pi ^ 2 * (2 : ℝ) ^ 2) ^ 6 *
            pinfl p f j ^ 2) ∧
    (∀ x : ι → α, ∃ y z : ι → α,
      (∀ i a,
        f (singleSwitched x (fun _ => a) i) ≤
          f (singleSwitched x y i)) ∧
      (∀ i a,
        f (singleSwitched x z i) ≤
          f (singleSwitched x (fun _ => a) i)) ∧
      (∑ i : ι,
        (f (singleSwitched x y i) -
         f (singleSwitched x z i))) ≤ 16) := by
  constructor
  · exact Nightfall.Observability.QuadraticANOVA.quadratic_actual_product_influence_e2e
      p hp hp1 f hf hdegree
  · intro x
    have hb : ∀ w : ι → α, |quadratic u v c h k w| ≤ (1 : ℝ) := by
      intro w
      rw [← hpoly w]
      exact hf w
    obtain ⟨y, z, hy, hz, hrange⟩ :=
      quadratic_actual_all_section_ranges_le_sixteen
        u v hne c h k 1 hb x
    refine ⟨y, z, ?_, ?_, ?_⟩
    · intro i a
      simpa only [hpoly] using hy i a
    · intro i a
      simpa only [hpoly] using hz i a
    · simpa only [hpoly, mul_one] using hrange

end Nightfall.Observability.QuadraticUnifiedFinite
