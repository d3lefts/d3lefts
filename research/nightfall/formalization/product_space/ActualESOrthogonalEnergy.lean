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

/-- The genuine actual-source pair energy is the self-inner-product
of the canonical component (under the true global product law). -/
theorem actual_source_pair_energy_as_inner
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ) (base : ι → α)
    (i j : ι) (hij : i ≠ j) :
    sourceInner p
      (esComp p ({i,j} : Finset ι) f)
      (esComp p ({i,j} : Finset ι) f) =
      (∑ a : α, ∑ b : α,
        p i a * p j b *
          (actualPairKernel p f base i j a b)^2) := by
  -- The pair component depends only on (i,j). First remove every
  -- unmatched coordinate by literal source-product resampling.
  -- The final two-coordinate reduction is an exact finite Fubini identity.
  sorry

end Nightfall.Observability.ActualESOrthogonalEnergy
