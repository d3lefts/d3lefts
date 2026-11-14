import ActualSourceQuadraticRectangles

/-!
# SCIF: exact algebraic graph invariance of canonical original-source pairs

Unlike the abstract finite pair-table module, this theorem is stated
directly for the repository's genuine Efron–Stein component
`esComp p {i,j} f` of one actual full-product function f.

Both source laws have explicitly assumed pointwise degree at most two.
The separate implication that a single law change preserves this
degree hypothesis is not proved here.
-/

namespace Nightfall.Observability.SCIFSourceGraph

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceQuadraticRectangles

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- The canonical Efron–Stein pair sector carries an algebraic
four-corner witness at the actual full-product source. -/
def HasCanonicalPairRectangle
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i j : ι) : Prop :=
  ∃ x : ι → α, ∃ a0 a1 b0 b1 : α,
    sourceRectangle (esComp p ({i,j} : Finset ι) f)
      x i j a0 a1 b0 b1 ≠ 0

/-- Exact *actual source* interaction-graph invariance under
arbitrary changes of normalized coordinate masses, including
zero-mass atoms, conditional on pointwise degree two for both laws. -/
theorem canonical_pair_graph_invariant
    (p q : ι → α → ℝ)
    (hp1 : ∀ t, (∑ a : α, p t a) = 1)
    (hq1 : ∀ t, (∑ a : α, q t a) = 1)
    (f : (ι → α) → ℝ)
    (hdp : ESDegreeLE p f 2)
    (hdq : ESDegreeLE q f 2)
    (i j : ι) (hij : i ≠ j) :
    HasCanonicalPairRectangle p f i j ↔
      HasCanonicalPairRectangle q f i j := by
  constructor
  · rintro ⟨x, a0, a1, b0, b1, h⟩
    refine ⟨x, a0, a1, b0, b1, ?_⟩
    have hOld := actual_quadratic_rectangle_eq_es_pair
      p hp1 f hdp i j hij x a0 a1 b0 b1
    have hNew := actual_quadratic_rectangle_eq_es_pair
      q hq1 f hdq i j hij x a0 a1 b0 b1
    rw [← hOld] at h
    rw [← hNew]
    exact h
  · rintro ⟨x, a0, a1, b0, b1, h⟩
    refine ⟨x, a0, a1, b0, b1, ?_⟩
    have hOld := actual_quadratic_rectangle_eq_es_pair
      p hp1 f hdp i j hij x a0 a1 b0 b1
    have hNew := actual_quadratic_rectangle_eq_es_pair
      q hq1 f hdq i j hij x a0 a1 b0 b1
    rw [← hNew] at h
    rw [← hOld]
    exact h

end Nightfall.Observability.SCIFSourceGraph
