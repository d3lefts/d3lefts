import WrightFiniteIntervalRho
import WrightProductFiberIdentity

/-! # Actual finite-product increment controlled by the sharp rho inequality.

This consumes the real pincr definition in the pinned product-space code.
Requires actual fiber endpoint data and conditional invariance. Does NOT
prove the pointwise degree-d sensitivity bound or the existence of endpoints.
-/

namespace Nightfall.Wright.ActualIncrement
open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.Wright.ProductFiber
open Nightfall.Wright.FiniteInterval

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

noncomputable def radius (f : (ι → α) → ℝ)
    (lo hi : (ι → α) → ι → ℝ) (x : ι → α) (j : ι) : ℝ :=
  max (f x - lo x j) (hi x j - f x)

/-- A sharp bound for the genuine one-coordinate resampling increment. -/
theorem actual_pincr_le_rho_radius
    (p : ι → α → ℝ) (hp : ∀ i b, 0 ≤ p i b)
    (hp1 : ∀ i, ∑ b, p i b = 1)
    (f : (ι → α) → ℝ)
    (lo hi : (ι → α) → ι → ℝ)
    (hlohi : ∀ x j, lo x j ≤ hi x j)
    (hlo : ∀ x j b, lo x j ≤ f (Function.update x j b))
    (hhi : ∀ x j b, f (Function.update x j b) ≤ hi x j)
    (hlofix : ∀ x j b, lo (Function.update x j b) j = lo x j)
    (hhifix : ∀ x j b, hi (Function.update x j b) j = hi x j)
    (j : ι) :
    pincr p f j ≤
      (4 - 2 * Real.sqrt 3) *
        (∑ x : ι → α, prodMass p x * radius f lo hi x j) := by
  let r : ℝ := 4 - 2 * Real.sqrt 3
  have hlocal (x : ι → α) :
      (∑ b, ∑ c, p j b * p j c *
        |f (Function.update x j b) - f (Function.update x j c)|) ≤
      r * (∑ b, p j b * radius f lo hi (Function.update x j b) j) := by
    have h := sharp_rho_finite_closed_interval (p j) (hp j) (hp1 j)
      (fun b => f (Function.update x j b)) (lo x j) (hi x j)
      (hlohi x j) (hlo x j) (hhi x j)
    change _ ≤ r * (∑ b, p j b *
       max (f (Function.update x j b) - lo x j)
           (hi x j - f (Function.update x j b))) at h
    convert h using 1
    congr 1
    apply Finset.sum_congr rfl
    intro b _
    rw [radius, hlofix x j b, hhifix x j b]
  have hrewrite (x : ι → α) :
      (∑ b, ∑ c, prodMass p x * p j b * p j c *
        |f (Function.update x j b) - f (Function.update x j c)|) =
      prodMass p x * (∑ b, ∑ c, p j b * p j c *
        |f (Function.update x j b) - f (Function.update x j c)|) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro b _
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro c _
    ring
  have hmid :
      (∑ x : ι → α, prodMass p x *
        (∑ b, p j b * radius f lo hi (Function.update x j b) j)) =
      (∑ x : ι → α, prodMass p x * radius f lo hi x j) := by
    calc
      (∑ x : ι → α, prodMass p x *
        (∑ b, p j b * radius f lo hi (Function.update x j b) j)) =
        (∑ x : ι → α, ∑ b, prodMass p x * p j b *
          radius f lo hi (Function.update x j b) j) := by
            apply Finset.sum_congr rfl
            intro x _
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro b _
            ring
      _ = _ := resample_sum p hp1 j (fun y => radius f lo hi y j)
  have hbound :
      (∑ x : ι → α, prodMass p x *
        (∑ b, ∑ c, p j b * p j c *
          |f (Function.update x j b) - f (Function.update x j c)|)) ≤
      (∑ x : ι → α, prodMass p x *
        (r * ∑ b, p j b * radius f lo hi (Function.update x j b) j)) := by
    apply Finset.sum_le_sum
    intro x _
    exact mul_le_mul_of_nonneg_left (hlocal x) (prodMass_nonneg' p hp x)
  calc
    pincr p f j =
        (∑ x : ι → α, ∑ b, ∑ c,
          prodMass p x * p j b * p j c *
          |f (Function.update x j b) - f (Function.update x j c)|) :=
        pincr_eq_fiber_pair_average p hp1 f j
    _ = (∑ x : ι → α, prodMass p x *
      (∑ b, ∑ c, p j b * p j c *
        |f (Function.update x j b) - f (Function.update x j c)|)) := by
          apply Finset.sum_congr rfl
          intro x _
          exact hrewrite x
    _ ≤ (∑ x : ι → α, prodMass p x *
        (r * ∑ b, p j b * radius f lo hi (Function.update x j b) j)) := hbound
    _ = r * (∑ x : ι → α, prodMass p x *
        (∑ b, p j b * radius f lo hi (Function.update x j b) j)) := by
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro x _
          ring
    _ = r * (∑ x : ι → α, prodMass p x * radius f lo hi x j) := by rw [hmid]

end Nightfall.Wright.ActualIncrement
