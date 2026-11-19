import LatentComponentHellinger

/-! Exact tensorization of finite product Hellinger affinity, allowing zero-probability
atoms, and the likelihood overlap upper bound. -/
namespace Nightfall.ProductSpace.LatentComponent

open Finset

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]

noncomputable def finiteProductMass (p : ι → α → ℝ) (x : ι → α) : ℝ :=
  ∏ i, p i (x i)

noncomputable def finiteProductAffinity (p q : ι → α → ℝ) : ℝ :=
  ∏ i, finiteAffinity (p i) (q i)

noncomputable def finiteProductOverlap (p q : ι → α → ℝ) : ℝ :=
  ∑ x : ι → α, min (finiteProductMass p x) (finiteProductMass q x)

theorem finite_product_affinity_factor
    (p q : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hq : ∀ i a, 0 ≤ q i a) :
    finiteAffinity (finiteProductMass p) (finiteProductMass q) =
      finiteProductAffinity p q := by
  unfold finiteAffinity finiteProductMass finiteProductAffinity
  calc
    (∑ x : ι → α, Real.sqrt (∏ i, p i (x i)) *
        Real.sqrt (∏ i, q i (x i))) =
      ∑ x : ι → α, ∏ i, Real.sqrt (p i (x i)) * Real.sqrt (q i (x i)) := by
        refine Finset.sum_congr rfl (fun x _ => ?_)
        rw [Real.sqrt_prod univ (fun i _ => hp i (x i)),
          Real.sqrt_prod univ (fun i _ => hq i (x i)),
          Finset.prod_mul_distrib]
    _ = ∏ i, ∑ a : α, Real.sqrt (p i a) * Real.sqrt (q i a) :=
      (Fintype.prod_sum (fun i (a : α) => Real.sqrt (p i a) * Real.sqrt (q i a))).symm

theorem min_le_sqrt_mul_sqrt (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    min a b ≤ Real.sqrt a * Real.sqrt b := by
  rcases le_total a b with h | h
  · calc
      min a b = a := min_eq_left h
      _ = Real.sqrt a * Real.sqrt a := (Real.mul_self_sqrt ha).symm
      _ ≤ Real.sqrt a * Real.sqrt b :=
        mul_le_mul_of_nonneg_left (Real.sqrt_le_sqrt h) (Real.sqrt_nonneg a)
  · calc
      min a b = b := min_eq_right h
      _ = Real.sqrt b * Real.sqrt b := (Real.mul_self_sqrt hb).symm
      _ ≤ Real.sqrt a * Real.sqrt b :=
        mul_le_mul_of_nonneg_right (Real.sqrt_le_sqrt h) (Real.sqrt_nonneg b)

theorem finite_product_overlap_le_affinity
    (p q : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hq : ∀ i a, 0 ≤ q i a) :
    finiteProductOverlap p q ≤ finiteProductAffinity p q := by
  have hpm (x : ι → α) : 0 ≤ finiteProductMass p x :=
    Finset.prod_nonneg (fun i _ => hp i (x i))
  have hqm (x : ι → α) : 0 ≤ finiteProductMass q x :=
    Finset.prod_nonneg (fun i _ => hq i (x i))
  unfold finiteProductOverlap
  calc
    (∑ x : ι → α, min (finiteProductMass p x) (finiteProductMass q x)) ≤
      ∑ x : ι → α, Real.sqrt (finiteProductMass p x) *
        Real.sqrt (finiteProductMass q x) :=
        Finset.sum_le_sum (fun x _ => min_le_sqrt_mul_sqrt _ _ (hpm x) (hqm x))
    _ = finiteProductAffinity p q := finite_product_affinity_factor p q hp hq

end Nightfall.ProductSpace.LatentComponent
