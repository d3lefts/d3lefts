import ActualSourceCanonicalPair

/-!
# Exact source-derived pair as the canonical four-term ANOVA kernel

This composes strictly source-derived pair marginals with the
independently ported genuine-product finite Efron–Stein conditional
operators. No decomposition, source moment, pair kernel or influence
hypothesis is introduced to identify the canonical two-site projector.
-/

namespace Nightfall.Observability.ActualSourceCanonicalIdentification

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductSoftNoise
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.ActualProductSourceDerivedStar
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceCanonicalPair

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- The actual product conditioning on one coordinate is exactly
the source-extracted one-coordinate table. -/
theorem actual_conditional_singleton_eq_source_table
    (p : ι → α → ℝ)
    (f : (ι → α) → ℝ) (j : ι) (x : ι → α) :
    sourceConditional p ({j} : Finset ι) f x =
      sourceOneSiteTable p f j (x j) := by
  classical
  have hpoint (y : ι → α) :
      keepSource ({j} : Finset ι) x y =
        Function.update y j (x j) := by
    funext t
    by_cases ht : t = j
    · subst t
      simp [keepSource]
    · simp [keepSource, ht]
  unfold sourceConditional sourceOneSiteTable
  apply Finset.sum_congr rfl
  intro y _
  rw [hpoint y]
  rfl

/-- The actual product conditioning on two distinct original
coordinates equals the source-extracted two-coordinate table. -/
theorem actual_conditional_pair_eq_source_table
    (p : ι → α → ℝ)
    (f : (ι → α) → ℝ)
    (j k : ι) (hjk : j ≠ k) (x : ι → α) :
    sourceConditional p ({j,k} : Finset ι) f x =
      sourceTwoSiteTable p f j k (x j) (x k) := by
  classical
  have hpoint (y : ι → α) :
      keepSource ({j,k} : Finset ι) x y =
        Function.update (Function.update y j (x j)) k (x k) := by
    funext t
    by_cases htj : t = j
    · subst t
      simp [keepSource, hjk]
    · by_cases htk : t = k
      · subst t
        simp [keepSource, htj]
      · simp [keepSource, htj, htk]
  unfold sourceConditional sourceTwoSiteTable
  apply Finset.sum_congr rfl
  intro y _
  rw [hpoint y]
  rfl

/-- Actual source conditioning on no coordinates is the full
original product expectation, including zero-mass atoms. -/
theorem actual_conditional_empty_eq_source_mean
    (p : ι → α → ℝ)
    (f : (ι → α) → ℝ) (x : ι → α) :
    sourceConditional p (∅ : Finset ι) f x =
      ∑ y : ι → α, originalMass p y * f y := by
  classical
  unfold sourceConditional
  simp only [smul_eq_mul]
  apply Finset.sum_congr rfl
  intro y _
  have h : keepSource (∅ : Finset ι) x y = y := by
    funext t
    simp [keepSource]
  rw [h]

/-- The fully derived pair term equals the **canonical degree-two
Möbius inclusion-exclusion projector** of the original finite source.
The four conditional expectations are defined from originalMass p;
none is a free input premise. -/
theorem actual_pair_is_canonical_mobius_four_term
    (p : ι → α → ℝ)
    (hp1 : ∀ t, (∑ a : α, p t a) = 1)
    (f : (ι → α) → ℝ) (j k : ι) (hjk : j ≠ k)
    (x : ι → α) :
    (ActualSourceANOVA.condExp p ({j,k} : Finset ι) f x -
      ActualSourceANOVA.condExp p ({j} : Finset ι) f x -
      ActualSourceANOVA.condExp p ({k} : Finset ι) f x +
      ActualSourceANOVA.condExp p (∅ : Finset ι) f x) =
      sourceDoubleCenteredPair p f j k (x j) (x k) := by
  classical
  simp only [canonical_condExp_eq_sourceConditional]
  rw [actual_conditional_pair_eq_source_table p f j k hjk x,
    actual_conditional_singleton_eq_source_table p f j x,
    actual_conditional_singleton_eq_source_table p f k x,
    actual_conditional_empty_eq_source_mean p f x]
  have h := (actual_source_doublecenter_eq_mobius_pair
    p hp1 f j k hjk (x j) (x k)).symm
  convert h using 1 <;> ring


/-- Exact source-derived pair equals the canonical order-two
Efron–Stein/Möbius component for a genuine pair of distinct sites.
This upgrades the four-term identity to the *actual esComp type*,
rather than only recognizing its analytic formula. -/
theorem actual_source_esComp_pair_eq_derived
    (p : ι → α → ℝ)
    (hp1 : ∀ t, (∑ a : α, p t a) = 1)
    (f : (ι → α) → ℝ) (j k : ι) (hjk : j ≠ k)
    (x : ι → α) :
    ActualSourceANOVA.esComp p ({j,k} : Finset ι) f x =
      sourceDoubleCenteredPair p f j k (x j) (x k) := by
  classical
  have h4 := actual_pair_is_canonical_mobius_four_term p hp1 f j k hjk x
  have hsingle :
      (({k} : Finset ι).powerset) =
      ({∅, {k}} : Finset (Finset ι)) := by
    rw [show ({k} : Finset ι) = insert k ∅ by simp,
      Finset.powerset_insert]
    simp
  have hpowerset :
      (({j,k} : Finset ι).powerset) =
      ({∅, {j}, {k}, {j,k}} : Finset (Finset ι)) := by
    rw [Finset.powerset_insert, hsingle]
    simp [Finset.insert_comm, Finset.union_comm, Finset.union_assoc]
  have hjpair : ({j} : Finset ι) ≠ {j,k} := by
    intro h
    have hk : k ∈ ({j} : Finset ι) := by
      rw [h]
      simp
    have hkj : k = j := by simpa using hk
    exact hjk hkj.symm
  have hkpair : ({k} : Finset ι) ≠ {j,k} := by
    intro h
    have hj : j ∈ ({k} : Finset ι) := by
      rw [h]
      simp
    have hje : j = k := by simpa using hj
    exact hjk hje
  have hjne : ({j} : Finset ι) ≠ {k} := by
    simpa using hjk
  have hnepair : (∅ : Finset ι) ≠ {j,k} := by
    intro heq
    have hmem : j ∈ (∅ : Finset ι) := by
      rw [heq]
      simp
    simpa using hmem
  have h0 : (∅ : Finset ι) ∉
      ({ {j}, {k}, {j,k} } : Finset (Finset ι)) := by
    simp [hnepair]
  have h1 : ({j} : Finset ι) ∉
      ({ {k}, {j,k} } : Finset (Finset ι)) := by
    simp [hjne, hjpair]
  have h2 : ({k} : Finset ι) ∉
      ({ {j,k} } : Finset (Finset ι)) := by
    simp [hkpair]
  unfold ActualSourceANOVA.esComp
  rw [hpowerset, Finset.sum_insert h0, Finset.sum_insert h1,
    Finset.sum_insert h2, Finset.sum_singleton]
  simp [hjk]
  linarith [h4]

end Nightfall.Observability.ActualSourceCanonicalIdentification
