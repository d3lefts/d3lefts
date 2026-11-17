import ActualSourceInfluenceEnergy
import InfinitePiQ2FiniteSupportRepair

/-!
# Exact source variance and influence invariance under zero-cell repair

For arbitrary finite heterogeneous normalized original product laws
(including zero-mass atoms), two functions agreeing on every
positive-probability source word have IDENTICAL original finite-source
mean, variance and every Efron–Stein coordinate influence.

This proves the numerical half of the Q2 positive-support retraction,
not just pointwise degree/bound preservation. The proof uses literal
originalMass weighted finite sums, not an abstract invariant oracle.
-/

namespace Nightfall.InfinitePiQ2ZeroCellSourceInvariance

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy
open Nightfall.InfinitePiQ2DegreeRetraction
open Nightfall.InfinitePiQ2FiniteSupportRepair

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α]

/-- Any word outside positive coordinate support has *exactly zero*
probability under the original finite product, not a small error. -/
theorem originalMass_zero_of_unsupported
    (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (x : ι → α) (hx : ¬ SourceSupported p x) :
    originalMass p x = 0 := by
  change ¬ ∀ i, 0 < p i (x i) at hx
  obtain ⟨i, hi⟩ := not_forall.mp hx
  have hz : p i (x i) = 0 :=
    le_antisymm (le_of_not_gt hi) (hp i (x i))
  unfold originalMass
  exact Finset.prod_eq_zero (Finset.mem_univ i) hz

/-- A one-coordinate replacement by a positive-mass letter preserves
positive support of the ambient source configuration. -/
theorem supported_update
    (p : ι → α → ℝ)
    (x : ι → α) (hx : SourceSupported p x)
    (i : ι) (a : α) (ha : 0 < p i a) :
    SourceSupported p (Function.update x i a) := by
  intro j
  by_cases h : j = i
  · subst j
    simpa using ha
  · simpa only [Function.update_of_ne h] using hx j

/-- If two observables agree on genuine original-source support,
their exact source mean is unchanged. -/
theorem sourceMean_congr_on_support
    (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (f g : (ι → α) → ℝ)
    (hfg : ∀ x, SourceSupported p x → f x = g x) :
    sourceMean p f = sourceMean p g := by
  unfold sourceMean
  apply Finset.sum_congr rfl
  intro x _
  by_cases hx : SourceSupported p x
  · rw [hfg x hx]
  · rw [originalMass_zero_of_unsupported p hp x hx]
    simp

/-- Exact original-source variance is insensitive to all null words,
including a simultaneous repair of an arbitrary number of null cells. -/
theorem sourceVariance_congr_on_support
    (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (f g : (ι → α) → ℝ)
    (hfg : ∀ x, SourceSupported p x → f x = g x) :
    sourceVariance p f = sourceVariance p g := by
  unfold sourceVariance
  rw [sourceMean_congr_on_support p hp f g hfg]
  apply Finset.sum_congr rfl
  intro x _
  by_cases hx : SourceSupported p x
  · rw [hfg x hx]
  · rw [originalMass_zero_of_unsupported p hp x hx]
    simp

/-- Exact source heat-bath influence is likewise insensitive to null
words, both in its outer source integration and in the inner i-refresh
sum: positive refresh letters stay on support, zero letters weigh zero. -/
theorem sourceInfluence_congr_on_support
    (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (f g : (ι → α) → ℝ)
    (hfg : ∀ x, SourceSupported p x → f x = g x)
    (i : ι) :
    sourceInfluence p f i = sourceInfluence p g i := by
  have hinner (x : ι → α) (hx : SourceSupported p x) :
      (∑ b : α, p i b * f (Function.update x i b)) =
      (∑ b : α, p i b * g (Function.update x i b)) := by
    apply Finset.sum_congr rfl
    intro b _
    by_cases hb : 0 < p i b
    · rw [hfg (Function.update x i b) (supported_update p x hx i b hb)]
    · have hz : p i b = 0 :=
        le_antisymm (le_of_not_gt hb) (hp i b)
      simp [hz]
  unfold sourceInfluence
  apply Finset.sum_congr rfl
  intro x _
  by_cases hx : SourceSupported p x
  · rw [hfg x hx, hinner x hx]
  · rw [originalMass_zero_of_unsupported p hp x hx]
    simp

/-- Original variance is **exactly preserved** by source-positive
retraction. No coefficient loss, discarded atom term or alternative law. -/
theorem sourceVariance_retractToPositive_exact
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ) :
    sourceVariance p
      (fun x => f (mapInputs (retractToPositive p hp1) x)) =
      sourceVariance p f := by
  apply sourceVariance_congr_on_support p hp
  intro x hx
  rw [mapped_word_eq_of_supported p hp1 x hx]

/-- Every original coordinate influence is **exactly preserved** by
the same retraction, including resampling into null letters. -/
theorem sourceInfluence_retractToPositive_exact
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ) (i : ι) :
    sourceInfluence p
      (fun x => f (mapInputs (retractToPositive p hp1) x)) i =
      sourceInfluence p f i := by
  apply sourceInfluence_congr_on_support p hp
  intro x hx
  rw [mapped_word_eq_of_supported p hp1 x hx]

end Nightfall.InfinitePiQ2ZeroCellSourceInvariance
