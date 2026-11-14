import ActualProductResampleBridge
import ActualProductSourceDerivedStar

/-!
# Two-site source marginal transport and source-derived Möbius pair

This derives the conditional expectation identities for the genuine
sourceOneSiteTable and sourceTwoSiteTable associated to ONE original
input function f. It does not assume a pair kernel or independence
between synthetic copies. It includes deterministic coordinate laws
and zero-probability atoms.

All source identities are exact on the full finite table; no Q2
inequality or energy hypothesis is assumed.
-/

namespace Nightfall.Observability.ActualSourceCanonicalPair

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductResampleBridge
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.ActualProductSourceDerivedStar
open Nightfall.Observability.ActualSourceANOVA

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Updating two distinct original coordinates commutes. -/
theorem distinct_source_updates_commute
    (x : ι → α) (j k : ι) (hjk : j ≠ k) (a b : α) :
    Function.update (Function.update x j a) k b =
      Function.update (Function.update x k b) j a := by
  funext t
  by_cases htj : t = j
  · subst t
    simp [hjk]
  · by_cases htk : t = k
    · subst t
      simp [hjk, htj]
    · simp [htj, htk]

/-- The first genuine coordinate marginal of a source-extracted
two-site conditional table is the exact one-site source table on k. -/
theorem actual_source_two_site_average_first
    (p : ι → α → ℝ)
    (hp1 : ∀ t, (∑ a : α, p t a) = 1)
    (f : (ι → α) → ℝ) (j k : ι) (hjk : j ≠ k)
    (b : α) :
    (∑ a : α, p j a * sourceTwoSiteTable p f j k a b) =
      sourceOneSiteTable p f k b := by
  classical
  unfold sourceTwoSiteTable sourceOneSiteTable
  calc
    (∑ a : α, p j a *
       (∑ y : ι → α, originalMass p y *
         f (Function.update (Function.update y j a) k b))) =
       ∑ a : α, ∑ y : ι → α,
         originalMass p y *
           (p j a * f (Function.update (Function.update y j a) k b)) := by
         apply Finset.sum_congr rfl
         intro a _
         rw [Finset.mul_sum]
         apply Finset.sum_congr rfl
         intro y _
         ring
    _ = ∑ y : ι → α, ∑ a : α,
          originalMass p y *
            (p j a * f (Function.update (Function.update y j a) k b)) :=
        Finset.sum_comm
    _ = ∑ y : ι → α, originalMass p y *
          (∑ a : α, p j a *
            f (Function.update (Function.update y j a) k b)) := by
        apply Finset.sum_congr rfl
        intro y _
        rw [Finset.mul_sum]
    _ = ∑ y : ι → α, originalMass p y *
          f (Function.update y k b) :=
        actual_source_resample_sum p hp1 j
          (fun y => f (Function.update y k b))

/-- The second genuine coordinate marginal of the source two-site
conditional table is the one-site source table on j. -/
theorem actual_source_two_site_average_second
    (p : ι → α → ℝ)
    (hp1 : ∀ t, (∑ a : α, p t a) = 1)
    (f : (ι → α) → ℝ) (j k : ι) (hjk : j ≠ k)
    (a : α) :
    (∑ b : α, p k b * sourceTwoSiteTable p f j k a b) =
      sourceOneSiteTable p f j a := by
  classical
  unfold sourceTwoSiteTable sourceOneSiteTable
  calc
    (∑ b : α, p k b *
       (∑ y : ι → α, originalMass p y *
         f (Function.update (Function.update y j a) k b))) =
       ∑ b : α, ∑ y : ι → α,
         originalMass p y *
           (p k b * f (Function.update (Function.update y j a) k b)) := by
         apply Finset.sum_congr rfl
         intro b _
         rw [Finset.mul_sum]
         apply Finset.sum_congr rfl
         intro y _
         ring
    _ = ∑ y : ι → α, ∑ b : α,
          originalMass p y *
            (p k b * f (Function.update (Function.update y j a) k b)) :=
        Finset.sum_comm
    _ = ∑ y : ι → α, originalMass p y *
          (∑ b : α, p k b *
            f (Function.update (Function.update y k b) j a)) := by
        apply Finset.sum_congr rfl
        intro y _
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro b _
        rw [distinct_source_updates_commute y j k hjk a b]
    _ = ∑ y : ι → α, originalMass p y *
          f (Function.update y j a) :=
        actual_source_resample_sum p hp1 k
          (fun y => f (Function.update y j a))

/-- Single source marginal averages back to the original full mean. -/
theorem actual_source_one_site_total_mean
    (p : ι → α → ℝ)
    (hp1 : ∀ t, (∑ a : α, p t a) = 1)
    (f : (ι → α) → ℝ) (j : ι) :
    (∑ a : α, p j a * sourceOneSiteTable p f j a) =
      ∑ y : ι → α, originalMass p y * f y := by
  classical
  unfold sourceOneSiteTable
  calc
    (∑ a : α, p j a *
      (∑ y : ι → α, originalMass p y *
        f (Function.update y j a))) =
      ∑ a : α, ∑ y : ι → α,
        originalMass p y * (p j a * f (Function.update y j a)) := by
          apply Finset.sum_congr rfl
          intro a _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro y _
          ring
    _ = ∑ y : ι → α, ∑ a : α,
      originalMass p y * (p j a * f (Function.update y j a)) :=
        Finset.sum_comm
    _ = ∑ y : ι → α, originalMass p y *
      (∑ a : α, p j a * f (Function.update y j a)) := by
          apply Finset.sum_congr rfl
          intro y _
          rw [Finset.mul_sum]
    _ = ∑ y : ι → α, originalMass p y * f y :=
      actual_source_resample_sum p hp1 j f

/-- The table derived from f by *double source centering* is exactly
the degree-two conditional-expectation inclusion-exclusion formula.
This identity includes the actual global mean: it uses no synthetic
pair source and no assumed energy identities. -/
theorem actual_source_doublecenter_eq_mobius_pair
    (p : ι → α → ℝ)
    (hp1 : ∀ t, (∑ a : α, p t a) = 1)
    (f : (ι → α) → ℝ) (j k : ι) (hjk : j ≠ k)
    (a b : α) :
    sourceDoubleCenteredPair p f j k a b =
      sourceTwoSiteTable p f j k a b -
      sourceOneSiteTable p f k b -
      sourceOneSiteTable p f j a +
      (∑ y : ι → α, originalMass p y * f y) := by
  classical
  have hdouble :
      (∑ u : α, p j u *
        (∑ v : α, p k v * sourceTwoSiteTable p f j k u v)) =
        ∑ y : ι → α, originalMass p y * f y := by
    calc
      (∑ u : α, p j u *
        (∑ v : α, p k v * sourceTwoSiteTable p f j k u v)) =
        ∑ u : α, p j u * sourceOneSiteTable p f j u := by
          apply Finset.sum_congr rfl
          intro u _
          rw [actual_source_two_site_average_second p hp1 f j k hjk u]
      _ = ∑ y : ι → α, originalMass p y * f y :=
          actual_source_one_site_total_mean p hp1 f j
  unfold sourceDoubleCenteredPair doubleCenter
  rw [actual_source_two_site_average_first p hp1 f j k hjk b,
      actual_source_two_site_average_second p hp1 f j k hjk a,
      hdouble]

end Nightfall.Observability.ActualSourceCanonicalPair
