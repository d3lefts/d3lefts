import SCIFExactTableTransport

/-!
# SCIF exact original-source singleton transport

For arbitrary finite-product f, if only the source law at k changes,
the genuine Efron–Stein singleton {k} changes only by the shift in
the true global source mean. This is pointwise exact, including
zero-mass source symbols. It is not a synthetic pair-table identity,
and no degree bound is assumed.

The bound on cost of a sparse implementation and the other singleton
coordinates are distinct obligations.
-/
namespace Nightfall.SCIFCanonicalSingleton
open Finset
open Nightfall.SCIFCanonicalSourceBridge
open Nightfall.SCIFExactTableTransport
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualProductMergeTower

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

noncomputable def sourceMean
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) : ℝ :=
  ∑ y : ι → α, originalMass p y * f y

theorem condExp_empty_eq_sourceMean
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (x : ι → α) :
    condExp p ∅ f x = sourceMean p f := by
  unfold condExp sourceMean
  apply Finset.sum_congr rfl
  intro y _
  simp [merge]

theorem esComp_empty_eq_sourceMean
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (x : ι → α) :
    esComp p ∅ f x = sourceMean p f := by
  rw [show esComp p ∅ f x = condExp p ∅ f x by
    simp [esComp]]
  exact condExp_empty_eq_sourceMean p f x

theorem esComp_singleton_eq_sub
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (k : ι) (x : ι → α) :
    esComp p ({k} : Finset ι) f x =
      condExp p ({k} : Finset ι) f x - sourceMean p f := by
  rw [← condExp_empty_eq_sourceMean p f x]
  simp only [esComp, Finset.powerset_singleton]
  simp
  ring

/-- The conditional table given the source coordinate k itself is
completely unchanged when only its own marginal is edited. -/
theorem condExp_edited_coordinate_invariant
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (k : ι) (q : α → ℝ)
    (hq1 : (∑ a : α, q a) = 1)
    (x : ι → α) :
    condExp (editLaw p k q) ({k} : Finset ι) f x =
      condExp p ({k} : Finset ι) f x := by
  unfold condExp
  apply source_integral_invariant_if_ignores_k p hp1 k q hq1
  intro y a
  congr 1
  funext i
  by_cases hi : i = k
  · subst i
    simp [merge]
  · simp [merge, hi, Function.update_of_ne hi]

/-- True source mean and first-order canonical component re-center
by exactly opposite amounts. No degree assumption is necessary. -/
theorem source_mean_and_edited_singleton_recenter
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (k : ι) (q : α → ℝ)
    (hq1 : (∑ a : α, q a) = 1)
    (x : ι → α) :
    esComp (editLaw p k q) ({k} : Finset ι) f x =
      esComp p ({k} : Finset ι) f x -
        (sourceMean (editLaw p k q) f - sourceMean p f) := by
  rw [esComp_singleton_eq_sub, esComp_singleton_eq_sub]
  rw [condExp_edited_coordinate_invariant p hp1 f k q hq1 x]
  ring

end Nightfall.SCIFCanonicalSingleton
