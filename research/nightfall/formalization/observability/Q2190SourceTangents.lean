import Q2190RotationParams
import ActualSourceSingletonProjection
import ActualSourceMeanSectionJensen
import ActualProductSourceDerivedStar

/-!
# The actual source canonical first chaos is the tangent density

No positive-mass assumption, no extra finite oracle h_i.
Every h_i here is the real original law sourceCenteredSingleton
of the original f. Equality of norms is literal Fubini.
-/

namespace Nightfall.Q2190
open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductSourceDerivedStar
open Nightfall.Observability.ActualSourceSingletonProjection
open Nightfall.Observability.ActualSourceMeanSectionJensen

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

noncomputable def originalH
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) : α → ℝ := sourceCenteredSingleton p f i

theorem originalH_centered
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a)=1)
    (f : (ι → α) → ℝ) (i : ι) :
    (∑ a : α, p i a * originalH p f i a) = 0 := by
  exact actual_source_derived_singleton_centered p hp1 f i

theorem actualSingletonNorm_eq_siteNorm
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a)=1)
    (f : (ι → α) → ℝ) (i : ι) :
    originalSingletonNorm p f i =
      siteNorm (p i) (originalH p f i) := by
  unfold originalSingletonNorm siteNorm siteEnergy originalH
  congr 1
  apply Finset.sum_congr rfl
  intro a _
  have hsource :=
    actual_source_singleton_eq_mean_section p hp1 f i a
  simp only [sourceCenteredSection]
  rw [← hsource]

/-- Exact source dual pairing: the signed spherical tangent contributes
the actual canonical original-source singleton norm. -/
theorem actualSingletonTangent_pairs_to_norm
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a)=1)
    (f : (ι → α) → ℝ) (i : ι) :
    (∑ a : α,
        signedTangent (p i) (originalH p f i) a *
          originalH p f i a) =
      originalSingletonNorm p f i := by
  rw [actualSingletonNorm_eq_siteNorm p hp1 f i]
  exact signedTangent_pairs_to_norm (p i) (originalH p f i) (hp i)

end Nightfall.Q2190
