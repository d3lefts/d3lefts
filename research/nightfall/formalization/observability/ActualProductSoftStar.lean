import ActualProductPairSector

/-!
# Source-preserving soft action on an actual separately centered pair star

This is the exact source-law soft-noise operator identity needed by the
Q2 soft-ownership reduction: one distinguished center coordinate and
distinct original neighbor coordinates (the finite type ι), with
the genuine heterogeneous independent coordinate law.

It is not an end-to-end Q2 inequality: no canonical decomposition
of an arbitrary degree-two f, matching amplitude cover, variance
Parseval, or fourth-moment closure is established here.
-/

namespace Nightfall.Observability.ActualProductSoftStar

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductSoftNoise
open Nightfall.Observability.ActualProductSourceMarginal
open Nightfall.Observability.ActualProductPairSector

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Additivity is derived from the literal original-product
conditional mixtures, not supplied as a separate noise axiom. -/
theorem actual_soft_noise_add
    (p : ι → α → ℝ) (retain : ι → ℝ)
    (F G : (ι → α) → ℝ) (x : ι → α) :
    softSourceNoise p retain (fun z => F z + G z) x =
      softSourceNoise p retain F x + softSourceNoise p retain G x := by
  classical
  unfold softSourceNoise sourceConditionalMixture sourceConditional
  simp only [smul_eq_mul, mul_add, Finset.sum_add_distrib]

/-- Finite linearity across genuine original-coordinate sections. -/
theorem actual_soft_noise_sum
    {β : Type*} [Fintype β]
    (p : ι → α → ℝ) (retain : ι → ℝ)
    (F : β → (ι → α) → ℝ) (x : ι → α) :
    softSourceNoise p retain (fun z => ∑ b : β, F b z) x =
      ∑ b : β, softSourceNoise p retain (F b) x := by
  classical
  have hcond (mask : ι → Bool) :
      sourceConditional p (maskSites mask)
        (fun z => ∑ b : β, F b z) x =
      ∑ b : β, sourceConditional p (maskSites mask) (F b) x := by
    unfold sourceConditional
    simp only [smul_eq_mul, Finset.mul_sum]
    rw [Finset.sum_comm]
  unfold softSourceNoise sourceConditionalMixture
  simp only [smul_eq_mul]
  calc
    (∑ mask : ι → Bool, maskWeight retain mask *
      sourceConditional p (maskSites mask)
        (fun z => ∑ b : β, F b z) x) =
      ∑ mask : ι → Bool, maskWeight retain mask *
        (∑ b : β, sourceConditional p (maskSites mask) (F b) x) := by
          apply Finset.sum_congr rfl
          intro mask _
          rw [hcond mask]
    _ = ∑ b : β, ∑ mask : ι → Bool,
        maskWeight retain mask *
          sourceConditional p (maskSites mask) (F b) x := by
          simp only [Finset.mul_sum]
          rw [Finset.sum_comm]

/-- The exact Q2 star-section noise identity for a source-centered
singleton plus separately centered genuine neighbor pairs. The
original coordinate indices are used literally, with no duplicated
neighbor list or independent synthetic neighbor stream.

The owner retention rate is arbitrary; setting retain i = 1 gives
the operator D1 of the source-preserving soft-ownership argument. -/
theorem actual_soft_noise_centered_star_eigen
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (retain : ι → ℝ)
    (i : ι)
    (g : α → ℝ)
    (hcenter : (∑ a : α, p i a * g a) = 0)
    (H : ι → α → α → ℝ)
    (hcenteri : ∀ j, j ≠ i →
      ∀ b : α, (∑ a : α, p i a * H j a b) = 0)
    (hcenterj : ∀ j, j ≠ i →
      ∀ a : α, (∑ b : α, p j b * H j a b) = 0)
    (x : ι → α) :
    softSourceNoise p retain
      (fun z : ι → α =>
        g (z i) + ∑ j : ι, if j = i then 0 else H j (z i) (z j)) x =
      retain i * g (x i) +
        ∑ j : ι, if j = i then 0 else
          (retain i * retain j) * H j (x i) (x j) := by
  classical
  calc
    softSourceNoise p retain
      (fun z : ι → α =>
        g (z i) + ∑ j : ι, if j = i then 0 else H j (z i) (z j)) x =
      softSourceNoise p retain (fun z => g (z i)) x +
      softSourceNoise p retain
        (fun z : ι → α =>
          ∑ j : ι, if j = i then 0 else H j (z i) (z j)) x := by
          exact actual_soft_noise_add p retain
            (fun z => g (z i))
            (fun z => ∑ j : ι, if j = i then 0 else H j (z i) (z j)) x
    _ = retain i * g (x i) +
      ∑ j : ι, softSourceNoise p retain
        (fun z : ι → α =>
          if j = i then 0 else H j (z i) (z j)) x := by
          rw [actual_soft_noise_centered_singleton_eigen
            p hp1 retain i g hcenter x]
          rw [actual_soft_noise_sum]
    _ = retain i * g (x i) +
        ∑ j : ι, if j = i then 0 else
          (retain i * retain j) * H j (x i) (x j) := by
          apply congrArg (fun t : ℝ => retain i * g (x i) + t)
          apply Finset.sum_congr rfl
          intro j _
          by_cases hji : j = i
          · subst j
            simp [softSourceNoise, sourceConditionalMixture,
              sourceConditional]
          · simpa [hji] using
              (actual_soft_noise_centered_pair_eigen
                p hp1 retain i j (Ne.symm hji) (H j)
                (hcenteri j hji) (hcenterj j hji) x)

end Nightfall.Observability.ActualProductSoftStar
