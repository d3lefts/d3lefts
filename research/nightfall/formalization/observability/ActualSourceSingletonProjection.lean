import ActualSourceCanonicalPair

/-!
# Genuine-source centered singleton = mean of its actual coordinate section

This is the mathematical interface for replacing a separate
additive-oscillation budget with original-law Jensen. No arbitrary
singleton component or source mean is supplied by the caller.
Finite alphabets may have zero-mass atoms.

The norm-Jensen inequality and the full Q2 source section estimate
remain separate strictly checked gates; this file asserts no Q2.
-/

namespace Nightfall.Observability.ActualSourceSingletonProjection

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductResampleBridge
open Nightfall.Observability.ActualProductSourceDerivedStar
open Nightfall.Observability.ActualSourceCanonicalPair

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Actual centered one-site section of f, before integrating the
other original coordinates (and not an auxiliary synthetic table). -/
noncomputable def originalSourceSection
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) (x : ι → α) (a : α) : ℝ :=
  f (Function.update x i a) -
    ∑ b : α, p i b * f (Function.update x i b)

/-- Every singleton table extracted from f by original-law
conditioning is exactly the true-source mean of its centered
coordinate section. This is the load-bearing additive Jensen bridge. -/
theorem actual_source_singleton_eq_mean_section
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ) (i : ι) (a : α) :
    sourceCenteredSingleton p f i a =
      ∑ x : ι → α, originalMass p x *
        originalSourceSection p f i x a := by
  classical
  calc
    sourceCenteredSingleton p f i a =
      sourceOneSiteTable p f i a -
        ∑ x : ι → α, originalMass p x * f x := by
          unfold sourceCenteredSingleton
          rw [actual_source_one_site_total_mean p hp1 f i]
    _ = (∑ x : ι → α, originalMass p x *
          f (Function.update x i a)) -
        (∑ x : ι → α, originalMass p x *
          (∑ b : α, p i b * f (Function.update x i b))) := by
          rw [actual_source_resample_sum p hp1 i f]
          rfl
    _ = ∑ x : ι → α, originalMass p x *
          originalSourceSection p f i x a := by
          rw [← Finset.sum_sub_distrib]
          apply Finset.sum_congr rfl
          intro x _
          unfold originalSourceSection
          ring

/-- Genuine source norm-Jensen starts with the finite actual mass.
There is no positive-mass assumption or conditional oracle involved.
This generic vector inequality is reusable for future Hilbert-valued
source sections and trust-weighted observation models. -/
theorem actual_source_vector_mean_norm_le_mean_norm
    {H : Type*} [NormedAddCommGroup H] [NormedSpace ℝ H]
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (G : (ι → α) → H) :
    ‖∑ x : ι → α, (originalMass p x) • G x‖ ≤
      ∑ x : ι → α, originalMass p x * ‖G x‖ := by
  classical
  have hm (x : ι → α) : 0 ≤ originalMass p x := by
    unfold originalMass
    exact Finset.prod_nonneg (fun i _ => hp i (x i))
  calc
    ‖∑ x : ι → α, (originalMass p x) • G x‖ ≤
      ∑ x : ι → α, ‖(originalMass p x) • G x‖ :=
      norm_sum_le _ _
    _ = ∑ x : ι → α, originalMass p x * ‖G x‖ := by
        apply Finset.sum_congr rfl
        intro x _
        rw [norm_smul, Real.norm_eq_abs, abs_of_nonneg (hm x)]

end Nightfall.Observability.ActualSourceSingletonProjection
