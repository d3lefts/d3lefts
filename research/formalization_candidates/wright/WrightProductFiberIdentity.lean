import ProductInfluence

/-!
# Actual finite-product coordinate-fiber pair identity

The existing pinned definition
  pincr p f j = E_{X,B_j}|f(X)-f(X_{-j},B_j)|
is converted without extra assumptions to a double iid fiber expectation:
  E_X E_{B,C~p_j}|f(X_{-j},B)-f(X_{-j},C)|.
This is the exact functional interface for applying the newly proven
sharp finite-marginal rho theorem to Wright's total L bound.
Zero-mass atoms and all finite coordinate-dependent probability tables
are allowed; the alphabet here is the common finite type used in PR 317.
-/

namespace Nightfall.Wright.ProductFiber

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Double-resampling identity for the *actual* product-space increment. -/
theorem pincr_eq_fiber_pair_average
    (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ) (j : ι) :
    pincr p f j =
      ∑ x, ∑ b, ∑ c, prodMass p x * p j b * p j c *
        |f (Function.update x j b) -
          f (Function.update x j c)| := by
  let g : (ι → α) → ℝ :=
    fun y => ∑ c, p j c * |f y - f (Function.update y j c)|
  have hres := resample_sum p hp1 j g
  calc
    pincr p f j = ∑ x, prodMass p x * g x := by
      unfold pincr
      apply Finset.sum_congr rfl
      intro x _
      dsimp [g]
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro c _
      ring
    _ = ∑ x, ∑ b, prodMass p x * p j b *
          g (Function.update x j b) := hres.symm
    _ = ∑ x, ∑ b, ∑ c, prodMass p x * p j b * p j c *
          |f (Function.update x j b) -
            f (Function.update x j c)| := by
      apply Finset.sum_congr rfl
      intro x _
      apply Finset.sum_congr rfl
      intro b _
      dsimp [g]
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro c _
      simp only [Function.update_update]
      ring

end Nightfall.Wright.ProductFiber
