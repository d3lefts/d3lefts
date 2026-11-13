import ActualESPairMatchingBridge
import ActualESQuadraticRectangles

/-!
# Actual product-law orthogonality of Efron–Stein source components

Proof by genuine resampling: a canonical component is mean-zero in
each coordinate in its support, and a second component that does not
depend on that coordinate remains fixed. Their product expectation
vanishes. This is the missing actual-source L2 orthogonality interface
for the source variance/influence bookkeeping.

Only normalized marginals are used; no supplied orthogonality or
energy certificate is assumed. The separately constructed global
sum-of-energies identity is the next stage.
-/

namespace Nightfall.Observability.ActualESOrthogonalEnergy

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.Observability.ActualESPairMatching
open Nightfall.Observability.ActualESQuadraticRectangles

variable {ι α : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Exact source inner-product expectation. -/
noncomputable def sourceInner
    (p : ι → α → ℝ)
    (g h : (ι → α) → ℝ) : ℝ :=
  ∑ x : ι → α, prodMass p x * (g x * h x)

/-- If g is actually centered at k and h genuinely ignores k,
the full product-law inner product is zero. -/
theorem source_inner_zero_of_centered_hidden
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (g h : (ι → α) → ℝ)
    (S : Finset ι) (hdep : DependsOn S h)
    (k : ι) (hk : k ∉ S)
    (hcent : ∀ x : ι → α,
      (∑ a : α, p k a * g (Function.update x k a)) = 0) :
    sourceInner p g h = 0 := by
  have hconst (x : ι → α) (a : α) :
      h (Function.update x k a) = h x :=
    dependsOn_update_outside S h hdep k hk x a
  unfold sourceInner
  calc
    (∑ x : ι → α, prodMass p x * (g x * h x)) =
      (∑ x : ι → α, ∑ a : α,
        prodMass p x * p k a *
          (g (Function.update x k a) *
            h (Function.update x k a))) :=
        (resample_sum p hp1 k (fun x => g x * h x)).symm
    _ = (∑ x : ι → α, prodMass p x *
      ((∑ a : α, p k a * g (Function.update x k a)) * h x)) := by
        apply Finset.sum_congr rfl
        intro x _
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro a _
        rw [hconst x a]
        ring
    _ = 0 := by simp [hcent]

/-- Genuine canonical Efron–Stein components with a support
coordinate present in U and absent from V are orthogonal. -/
theorem actual_esComp_orthogonal_missing
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (U V : Finset ι)
    (k : ι) (hkU : k ∈ U) (hkV : k ∉ V) :
    sourceInner p (esComp p U f) (esComp p V f) = 0 := by
  exact source_inner_zero_of_centered_hidden
    p hp1 (esComp p U f) (esComp p V f)
    V (esComp_dependsOn p V f) k hkV
    (fun x => actual_esComp_centered p hp1 f U k hkU x)

/-! Further pair-energy Fubini reduction is intentionally omitted until proven. -/

/-- Commutativity of the actual weighted source inner product. -/
theorem sourceInner_comm
    (p : ι → α → ℝ)
    (g h : (ι → α) → ℝ) :
    sourceInner p g h = sourceInner p h g := by
  unfold sourceInner
  apply Finset.sum_congr rfl
  intro x _
  ring

/-- ANY two distinct canonical Efron–Stein support components of the
same genuine source function are orthogonal under the true product
mass. No independent orthogonality certificate is given. -/
theorem actual_esComp_orthogonal_distinct
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (U V : Finset ι) (hne : U ≠ V) :
    sourceInner p (esComp p U f) (esComp p V f) = 0 := by
  classical
  by_cases hsub : U ⊆ V
  · have hnsub : ¬ V ⊆ U := by
      intro hVU
      exact hne (Finset.Subset.antisymm hsub hVU)
    have hmiss : ∃ k : ι, k ∈ V ∧ k ∉ U := by
      by_contra hnot
      apply hnsub
      intro k hkV
      by_contra hkU
      exact hnot ⟨k, hkV, hkU⟩
    obtain ⟨k, hkV, hkU⟩ := hmiss
    rw [sourceInner_comm]
    exact actual_esComp_orthogonal_missing p hp1 f V U k hkV hkU
  · have hmiss : ∃ k : ι, k ∈ U ∧ k ∉ V := by
      by_contra hnot
      apply hsub
      intro k hkU
      by_contra hkV
      exact hnot ⟨k, hkU, hkV⟩
    obtain ⟨k, hkU, hkV⟩ := hmiss
    exact actual_esComp_orthogonal_missing p hp1 f U V k hkU hkV

end Nightfall.Observability.ActualESOrthogonalEnergy
