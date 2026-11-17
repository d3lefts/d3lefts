import Mathlib.MeasureTheory.Measure.Filter
import Mathlib.MeasureTheory.Function.LpSpace.Basic

/-!
# Exact positive-atom extraction from genuine almost-everywhere claims

These source-independent measure lemmas convert an a.e. statement
into a pointwise statement at any atom of positive mass. They do
not assume a uniform positive-atom floor, and therefore apply to
native finite label tables with arbitrarily small positive cells.

The lemmas are the missing finite-table interface for:
* bounded conditional averages on every positive table cell;
* pointwise vanishing of finite-table degree residuals on support.
-/

namespace Nightfall.InfinitePiQ2PositiveAtomExtraction

open MeasureTheory

variable {α : Type*} [MeasurableSpace α]

/-- An almost-everywhere absolute bound holds at every positive-mass
singleton, with no atom floor or bounded-away-from-zero condition. -/
theorem ae_abs_bound_at_positive_atom
    (μ : Measure α) (g : α → ℝ) (B : ℝ)
    (hbound : ∀ᵐ x ∂μ, |g x| ≤ B)
    (y : α) (hy : 0 < μ {y}) :
    |g y| ≤ B := by
  by_contra hbad
  have hsubset : ({y} : Set α) ⊆ {x | ¬ |g x| ≤ B} := by
    intro x hx
    have hxy : x = y := Set.mem_singleton_iff.mp hx
    simpa [hxy] using hbad
  have hzero : μ {x | ¬ |g x| ≤ B} = 0 := by
    simpa only [Set.compl_setOf] using (mem_ae_iff.mp hbound)
  have hle := measure_mono hsubset
  exact (not_lt_of_ge (hle.trans_eq hzero)) hy

/-- Two almost-everywhere equal functions have identical values at
every positive-mass singleton, including under a non-discrete source
measure. -/
theorem ae_eq_at_positive_atom
    (μ : Measure α) (f g : α → ℝ)
    (heq : f =ᵐ[μ] g)
    (y : α) (hy : 0 < μ {y}) :
    f y = g y := by
  by_contra hbad
  have hsubset : ({y} : Set α) ⊆ {x | f x ≠ g x} := by
    intro x hx
    have hxy : x = y := Set.mem_singleton_iff.mp hx
    simpa [hxy] using hbad
  have hzero : μ {x | f x ≠ g x} = 0 := by
    simpa only [Set.compl_setOf] using (mem_ae_iff.mp heq)
  have hle := measure_mono hsubset
  exact (not_lt_of_ge (hle.trans_eq hzero)) hy

#print axioms Nightfall.InfinitePiQ2PositiveAtomExtraction.ae_abs_bound_at_positive_atom
#print axioms Nightfall.InfinitePiQ2PositiveAtomExtraction.ae_eq_at_positive_atom

end Nightfall.InfinitePiQ2PositiveAtomExtraction
