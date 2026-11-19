import LatentComponentProductAffinity

/-! Product-level Hellinger testing bound with arbitrary zero-mass atoms.
    The explicit logarithmic budget and low-TV branch are proved elsewhere. -/
namespace Nightfall.ProductSpace.LatentComponent

open Finset
variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]

theorem finite_product_overlap_le_power
    (p q : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a) (hq : ∀ i a, 0 ≤ q i a)
    (hp1 : ∀ i, ∑ a, p i a = 1) (hq1 : ∀ i, ∑ a, q i a = 1)
    (θ : ℝ) (hθ : 0 ≤ θ)
    (hsep : ∀ i, θ ≤ finiteTV (p i) (q i)) :
    finiteProductOverlap p q ≤
       (1 - θ ^ 2 / 2) ^ (Fintype.card ι) := by
  have hcoord (i : ι) :
      finiteAffinity (p i) (q i) ≤ 1 - θ ^ 2 / 2 := by
    have h₁ := finiteAffinity_le_one_sub_half_tv_sq (p i) (q i)
      (hp i) (hq i) (hp1 i) (hq1 i)
    have h₂ := pow_le_pow_left₀ hθ (hsep i) 2
    linarith
  have hprod : finiteProductAffinity p q ≤
      ∏ i : ι, (1 - θ ^ 2 / 2) := by
    unfold finiteProductAffinity
    apply Finset.prod_le_prod
    · intro i hi
      exact finiteAffinity_nonneg (p i) (q i)
    · intro i hi
      exact hcoord i
  calc
    finiteProductOverlap p q ≤ finiteProductAffinity p q :=
      finite_product_overlap_le_affinity p q hp hq
    _ ≤ ∏ i : ι, (1 - θ ^ 2 / 2) := hprod
    _ = (1 - θ ^ 2 / 2) ^ (Fintype.card ι) := by simp

end Nightfall.ProductSpace.LatentComponent
