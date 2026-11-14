import ActualSourceCanonicalOrthogonality

/-!
# Exact source-product Efron-Stein variance energy identity

Genuine finite product source f; no supplied ANOVA energy assumptions.
Derives the Parseval identity for canonical Mobius components, with
degree-two specialization. The result uses the source-derived
off-diagonal orthogonality proved in ActualESOrthogonality.lean.

This is a standard classical identity formalized as a missing *source*
bridge for Q2. It does not finish the assigned-pair source energy bound
or arbitrary-measurable-product lifting.
-/

namespace Nightfall.Observability.ActualSourceCanonicalVarianceEnergy

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceCanonicalOrthogonality

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Exact first moment under the true finite original product mass. -/
noncomputable def actualSourceExpectation
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) : ℝ :=
  ∑ x : ι → α, originalMass p x * f x

/-- Actual variance of f under the original independent product law. -/
noncomputable def actualSourceVariance
    (p : ι → α → ℝ) (f : (ι → α) → ℝ) : ℝ :=
  ∑ x : ι → α, originalMass p x *
    (f x - actualSourceExpectation p f)^2

/-- An abstract finite orthogonal-family sum-of-squares identity,
proved from finite sum algebra, not assumed as a probability theorem. -/
theorem weighted_orthogonal_sum_sq
    {Ω E : Type*} [Fintype Ω] [Fintype E]
    (μ : Ω → ℝ) (Y : E → Ω → ℝ)
    (horth : ∀ e d : E, e ≠ d →
      (∑ x : Ω, μ x * Y e x * Y d x) = 0) :
    (∑ x : Ω, μ x * (∑ e : E, Y e x)^2) =
      ∑ e : E, ∑ x : Ω, μ x * (Y e x)^2 := by
  classical
  have hpoint (x : Ω) :
      (∑ e : E, Y e x)^2 =
        ∑ e : E, ∑ d : E, Y e x * Y d x := by
    calc
      (∑ e : E, Y e x)^2 =
          (∑ e : E, Y e x) * (∑ d : E, Y d x) := by ring
      _ = ∑ e : E, Y e x * (∑ d : E, Y d x) := by
            rw [Finset.sum_mul]
      _ = ∑ e : E, ∑ d : E, Y e x * Y d x := by
            apply Finset.sum_congr rfl
            intro e _
            rw [Finset.mul_sum]
  calc
    (∑ x : Ω, μ x * (∑ e : E, Y e x)^2) =
        ∑ x : Ω, ∑ e : E, ∑ d : E,
          μ x * Y e x * Y d x := by
          apply Finset.sum_congr rfl
          intro x _
          rw [hpoint x, Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro e _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro d _
          ring
    _ = ∑ e : E, ∑ d : E, ∑ x : Ω,
          μ x * Y e x * Y d x := by
          rw [Finset.sum_comm]
          apply Finset.sum_congr rfl
          intro e _
          rw [Finset.sum_comm]
    _ = ∑ e : E, ∑ x : Ω, μ x * (Y e x)^2 := by
          apply Finset.sum_congr rfl
          intro e _
          rw [Finset.sum_eq_single e]
          · apply Finset.sum_congr rfl
            intro x _
            ring
          · intro d _ hd
            exact horth e d (Ne.symm hd)
          · intro hfalse
            exact (hfalse (Finset.mem_univ e)).elim

/-- The empty canonical Efron-Stein component is the source mean. -/
theorem esComp_empty_eq_source_mean
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (x : ι → α) :
    esComp p ∅ f x = actualSourceExpectation p f := by
  have hmerge (y : ι → α) : merge (∅ : Finset ι) x y = y := by
    funext k
    simp [merge]
  simp [esComp, condExp, actualSourceExpectation, hmerge]

/-- Center the ACTUAL source function using its entire canonical
Efron-Stein decomposition. -/
theorem source_centered_es_sum
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (x : ι → α) :
    f x - actualSourceExpectation p f =
      ∑ T : Finset ι,
        if T = ∅ then 0 else esComp p T f x := by
  let h : Finset ι → ℝ := fun T => esComp p T f x
  have hsing :
      (∑ T : Finset ι, if T = ∅ then h ∅ else 0) = h ∅ := by
    simp
  have hsum :
      (∑ T : Finset ι, if T = ∅ then 0 else h T) =
      (∑ T : Finset ι, h T) - h ∅ := by
    calc
      (∑ T : Finset ι, if T = ∅ then 0 else h T) =
        ∑ T : Finset ι, (h T - if T = ∅ then h ∅ else 0) := by
          apply Finset.sum_congr rfl
          intro T _
          by_cases ht : T = ∅ <;> simp [ht]
      _ = (∑ T : Finset ι, h T) -
        (∑ T : Finset ι, if T = ∅ then h ∅ else 0) := by
          rw [Finset.sum_sub_distrib]
      _ = (∑ T : Finset ι, h T) - h ∅ := by
          rw [hsing]
  calc
    f x - actualSourceExpectation p f =
        (∑ T : Finset ι, esComp p T f x) -
          esComp p ∅ f x := by
            rw [es_decomp p hp1 f x, esComp_empty_eq_source_mean]
    _ = ∑ T : Finset ι, if T = ∅ then 0 else esComp p T f x := by
          simpa only [h] using hsum.symm

/-- Parseval/ANOVA energy of the ACTUAL finite source.
All interaction orders are covered, with no degree restriction or
externally supplied orthogonality budget. -/
theorem actual_source_variance_es_energy
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) :
    actualSourceVariance p f =
      ∑ T : Finset ι,
        if T = ∅ then 0 else
          (∑ x : ι → α, originalMass p x * (esComp p T f x)^2) := by
  classical
  let Y : Finset ι → (ι → α) → ℝ :=
    fun T x => if T = ∅ then 0 else esComp p T f x
  have horth : ∀ T U : Finset ι, T ≠ U →
      (∑ x : ι → α, originalMass p x * Y T x * Y U x) = 0 := by
    intro T U hne
    by_cases ht : T = ∅
    · simp [Y, ht]
    · by_cases hu : U = ∅
      · simp [Y, hu]
      · simpa only [Y, if_neg ht, if_neg hu] using
          actual_esComp_orthogonal p hp1 f T U hne
  have hparseval := weighted_orthogonal_sum_sq
    (originalMass p) Y horth
  unfold actualSourceVariance
  calc
    (∑ x : ι → α, originalMass p x * (f x - actualSourceExpectation p f)^2) =
      ∑ x : ι → α, originalMass p x * (∑ T : Finset ι, Y T x)^2 := by
        apply Finset.sum_congr rfl
        intro x _
        rw [source_centered_es_sum p hp1 f x]
    _ = ∑ T : Finset ι, ∑ x : ι → α,
      originalMass p x * (Y T x)^2 := hparseval
    _ = ∑ T : Finset ι,
      if T = ∅ then 0 else
        (∑ x : ι → α, originalMass p x * (esComp p T f x)^2) := by
        apply Finset.sum_congr rfl
        intro T _
        by_cases ht : T = ∅ <;> simp [Y, ht]

/-- For genuine degree-two sources, the variance has exactly the
empty-excluded singleton-plus-pair canonical energy, with no outside
ANOVA variance-equality assumption. -/
theorem actual_degree_two_source_variance_energy
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2) :
    actualSourceVariance p f =
      ∑ T : Finset ι,
        if T ≠ ∅ ∧ T.card ≤ 2 then
          (∑ x : ι → α, originalMass p x * (esComp p T f x)^2)
        else 0 := by
  rw [actual_source_variance_es_energy p hp1 f]
  apply Finset.sum_congr rfl
  intro T _
  by_cases he : T = ∅
  · simp [he]
  · by_cases hc : T.card ≤ 2
    · simp [he, hc]
    · have hz (x : ι → α) :
        esComp p T f x = 0 := hdegree T (by omega) x
      simp [he, hc, hz]

end Nightfall.Observability.ActualSourceCanonicalVarianceEnergy
