import SCIFLocalSourceInfluence

/-!
# SCIF exact original-source singleton transport

For arbitrary finite-product f, if only the source law at k changes,
the genuine Efron–Stein singleton {k} changes only by the shift in
the true global source mean. This is pointwise exact, including
zero-mass source symbols. It is not a synthetic pair-table identity,
and no degree bound is assumed.

The full beta identity also derives the updated mean from the original
source singleton and the changed marginal. The bound on cost of a sparse
implementation and the other singleton coordinates are distinct obligations.
-/
namespace Nightfall.SCIFCanonicalSingleton
open Finset
open Nightfall.SCIFCanonicalSourceBridge
open Nightfall.SCIFExactTableTransport
open Nightfall.SCIFLocalSourceInfluence
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
  have hm : merge (∅ : Finset ι) x y = y := by
    funext i
    simp [merge]
  rw [hm]

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
  have hpow : ({k} : Finset ι).powerset =
      ({∅, {k}} : Finset (Finset ι)) := by
    change (insert k (∅ : Finset ι)).powerset =
      ({∅, {k}} : Finset (Finset ι))
    rw [Finset.powerset_insert]
    simp
  unfold esComp
  rw [hpow]
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


/-- The actual new source expectation is computed using ONLY the
old source's conditional k-projection and the new k marginal.
No new full-product oracle is supplied. -/
theorem source_mean_after_edit_as_old_conditional
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (k : ι) (q : α → ℝ) (x : ι → α) :
    sourceMean (editLaw p k q) f =
      ∑ a : α, q a *
        condExp p ({k} : Finset ι) f (Function.update x k a) := by
  classical
  calc
    sourceMean (editLaw p k q) f =
        ∑ y : ι → α, originalMass p y *
          (∑ a : α, q a * f (Function.update y k a)) := by
            exact source_integral_after_one_law_edit p hp1 k q f
    _ = ∑ y : ι → α, ∑ a : α,
          q a * (originalMass p y * f (Function.update y k a)) := by
            apply Finset.sum_congr rfl
            intro y _
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro a _
            ring
    _ = ∑ a : α, ∑ y : ι → α,
          q a * (originalMass p y * f (Function.update y k a)) :=
            Finset.sum_comm
    _ = ∑ a : α, q a *
          (∑ y : ι → α, originalMass p y *
            f (Function.update y k a)) := by
            apply Finset.sum_congr rfl
            intro a _
            rw [Finset.mul_sum]
    _ = ∑ a : α, q a *
          condExp p ({k} : Finset ι) f (Function.update x k a) := by
            apply Finset.sum_congr rfl
            intro a _
            congr 1
            unfold condExp
            apply Finset.sum_congr rfl
            intro y _
            congr 1
            have hmerge :
                merge ({k} : Finset ι) (Function.update x k a) y =
                  Function.update y k a := by
              funext i
              by_cases hi : i = k
              · subst i
                simp [merge]
              · simp [merge, hi, Function.update_of_ne hi]
            rw [hmerge]

/-- Exact change in the true original-product mean is the new marginal
average of the OLD genuine canonical singleton, pointwise at all old
symbol atoms. -/
theorem source_mean_shift_eq_old_singleton
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (k : ι) (q : α → ℝ)
    (hq1 : (∑ a : α, q a) = 1)
    (x : ι → α) :
    sourceMean (editLaw p k q) f - sourceMean p f =
      ∑ a : α, q a *
        esComp p ({k} : Finset ι) f (Function.update x k a) := by
  classical
  have hsum :
      (∑ a : α, q a *
        esComp p ({k} : Finset ι) f (Function.update x k a)) =
      (∑ a : α, q a *
        condExp p ({k} : Finset ι) f (Function.update x k a)) -
      sourceMean p f := by
    calc
      _ = ∑ a : α, q a *
          (condExp p ({k} : Finset ι) f (Function.update x k a) -
            sourceMean p f) := by
              apply Finset.sum_congr rfl
              intro a _
              rw [esComp_singleton_eq_sub]
      _ = (∑ a : α, q a *
            condExp p ({k} : Finset ι) f (Function.update x k a)) -
          (∑ a : α, q a) * sourceMean p f := by
            simp_rw [mul_sub]
            rw [Finset.sum_sub_distrib, ← Finset.sum_mul]
      _ = _ := by rw [hq1, one_mul]
  calc
    sourceMean (editLaw p k q) f - sourceMean p f =
      (∑ a : α, q a *
        condExp p ({k} : Finset ι) f (Function.update x k a)) -
      sourceMean p f := by
        rw [source_mean_after_edit_as_old_conditional p hp1 f k q x]
    _ = _ := hsum.symm

/-- Full source-derived mean and edited canonical singleton update,
without any degree-two assumption or positivity lower bound. -/
theorem source_mean_and_singleton_exact_repair
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (k : ι) (q : α → ℝ)
    (hq1 : (∑ a : α, q a) = 1)
    (x : ι → α) :
    (sourceMean (editLaw p k q) f =
      sourceMean p f +
        ∑ a : α, q a *
          esComp p ({k} : Finset ι) f (Function.update x k a)) ∧
    (esComp (editLaw p k q) ({k} : Finset ι) f x =
      esComp p ({k} : Finset ι) f x -
        ∑ a : α, q a *
          esComp p ({k} : Finset ι) f (Function.update x k a)) := by
  have hb := source_mean_shift_eq_old_singleton p hp1 f k q hq1 x
  constructor
  · linarith
  · rw [source_mean_and_edited_singleton_recenter p hp1 f k q hq1 x, hb]

end Nightfall.SCIFCanonicalSingleton
