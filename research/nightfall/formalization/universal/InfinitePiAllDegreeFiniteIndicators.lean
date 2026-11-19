import ActualSourceANOVA
import Mathlib

/-!
# Finite ANOVA degree d -> indicator-monomial degree d (algebraic bridge)

For a nonempty common finite alphabet, the canonical Efron–Stein
components of order at most d are each finite sums of indicator
monomials on their own supports. The construction uses one fixed
background word for the unused symbols. This avoids any denominator
or smallest-atom assumption, and is exact for every degree d.

The target predicate in this file is intentionally *definitionally
parallel* to ProductSpace.RowBound.HasProdDegreeLE. Integration with
that historical Lean 4.33 module on the current Lean pin is a
separate compile gate. This file does not claim the full AA terminal.
-/

namespace Nightfall.InfinitePiAllDegreeFiniteIndicators

open Finset
open Nightfall.Observability.ActualSourceANOVA

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Exact indicator monomial on finite coordinate support T. -/
noncomputable def indicatorMono (T : Finset ι)
    (τ x : ι → α) : ℝ :=
  ∏ i ∈ T, if x i = τ i then (1 : ℝ) else 0

/-- Finite indicator-span degree at most d. This has the same
coefficient/monomial shape as RowBound.HasProdDegreeLE. -/
def HasIndicatorDegreeLE (f : (ι → α) → ℝ) (d : ℕ) : Prop :=
  ∃ a : Finset ι → (ι → α) → ℝ,
    (∀ T, d < T.card → ∀ τ, a T τ = 0) ∧
    ∀ x, f x = ∑ T, ∑ τ, a T τ * indicatorMono T τ x

/-- A function depending on T can be expanded exactly into T-supported
indicator monomials, fixing all unused symbols to a background word.
No probability mass or division enters the coefficients. -/
theorem indicator_expansion_of_dependsOn
    (T : Finset ι) (g : (ι → α) → ℝ)
    (hg : DependsOn T g) (base x : ι → α) :
    (∑ τ : ι → α,
      (if ∀ i, i ∉ T → τ i = base i then g τ else 0) *
        indicatorMono T τ x) = g x := by
  classical
  let w : ι → α := merge T x base
  have hw : ∀ i, i ∉ T → w i = base i := by
    intro i hi
    simp [w, merge, hi]
  have hmono : indicatorMono T w x = 1 := by
    unfold indicatorMono
    apply Finset.prod_eq_one
    intro i hi
    simp [w, merge, hi]
  calc
    (∑ τ : ι → α,
      (if ∀ i, i ∉ T → τ i = base i then g τ else 0) *
        indicatorMono T τ x) =
      (if ∀ i, i ∉ T → w i = base i then g w else 0) *
        indicatorMono T w x := by
          apply Finset.sum_eq_single w
          · intro τ _ hτ
            obtain ⟨i, hi⟩ : ∃ i, τ i ≠ w i := by
              by_contra h
              push_neg at h
              apply hτ
              funext j
              exact h j
            by_cases hT : i ∈ T
            · have hx : x i ≠ τ i := by
                intro he
                apply hi
                rw [← he]
                simp [w, merge, hT]
              have hz : indicatorMono T τ x = 0 := by
                unfold indicatorMono
                apply Finset.prod_eq_zero hT
                simp [hx]
              simp [hz]
            · have hm : ¬ (∀ j, j ∉ T → τ j = base j) := by
                intro hh
                apply hi
                calc
                  τ i = base i := hh i hT
                  _ = w i := by simp [w, merge, hT]
              simp [hm]
          · intro hnot
            exact False.elim (hnot (Finset.mem_univ w))
    _ = g x := by
      simp only [if_pos hw, hmono, mul_one]
      exact hg w x (by
        intro i hi
        simp [w, merge, hi])

/-- Any genuine source-law canonical ANOVA degree d observable has
an exact indicator-monomial expansion of the *same* degree d.
All heterogeneous positive/zero mass source weights are permitted;
only normalization and nonempty finite alphabet are required. -/
theorem esDegreeLE_implies_indicatorDegreeLE
    [Nonempty α] (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a : α, p i a = 1)
    (f : (ι → α) → ℝ) (d : ℕ)
    (hdegree : ESDegreeLE p f d) :
    HasIndicatorDegreeLE f d := by
  classical
  let base : ι → α := fun _ => Classical.choice (inferInstance : Nonempty α)
  let a : Finset ι → (ι → α) → ℝ :=
    fun T τ => if d < T.card then 0
      else if ∀ i, i ∉ T → τ i = base i then esComp p T f τ else 0
  refine ⟨a, ?_, ?_⟩
  · intro T hT τ
    simp [a, hT]
  · intro x
    calc
      f x = ∑ T : Finset ι, esComp p T f x :=
        (es_decomp p hp1 f x).symm
      _ = ∑ T : Finset ι, ∑ τ : ι → α,
          a T τ * indicatorMono T τ x := by
        apply Finset.sum_congr rfl
        intro T _
        by_cases hT : d < T.card
        · have hz : esComp p T f x = 0 := hdegree T hT x
          simp [a, hT, hz]
        · have hrep :=
            indicator_expansion_of_dependsOn T (esComp p T f)
              (esComp_dependsOn p T f) base x
          simpa only [a, if_neg hT] using hrep.symm

#print axioms Nightfall.InfinitePiAllDegreeFiniteIndicators.indicator_expansion_of_dependsOn
#print axioms Nightfall.InfinitePiAllDegreeFiniteIndicators.esDegreeLE_implies_indicatorDegreeLE

end Nightfall.InfinitePiAllDegreeFiniteIndicators
