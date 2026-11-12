import WrightActualIncrementRho
import WrightSharpLimitBridge

/-!
# Wright's true total resampling increment, conditional on a pointwise
# finite-degree sensitivity certificate.

This module closes the finite-sum aggregation of the now formalized
sharp single-fiber inequality, in the *real* pincr normalization.

The remaining nonlinear proof obligation is the actual degree-d
FHKL bound, sum_j radius f j x <= 2*d^2, together with construction of
optimal invariant fiber endpoints. These are explicit hypotheses.
-/

namespace Nightfall.Wright.TotalIncrement
open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.Wright.ActualIncrement

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- The pointwise sensitivity condition implies the needed average budget
under the real finite product mass, even with zero-mass entries. -/
theorem radius_energy_of_pointwise_budget
    (p : ι → α → ℝ) (hp : ∀ i b, 0 ≤ p i b)
    (hp1 : ∀ i, ∑ b, p i b = 1)
    (f : (ι → α) → ℝ) (lo hi : (ι → α) → ι → ℝ)
    (d : ℕ)
    (hpoint : ∀ x : ι → α, ∑ j, radius f lo hi x j ≤ 2 * (d : ℝ) ^ 2) :
    (∑ j, ∑ x : ι → α, prodMass p x * radius f lo hi x j) ≤
      2 * (d : ℝ) ^ 2 := by
  have hrew :
      (∑ j, ∑ x : ι → α, prodMass p x * radius f lo hi x j) =
      (∑ x : ι → α, prodMass p x * (∑ j, radius f lo hi x j)) := by
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro x _
    rw [Finset.mul_sum]
  rw [hrew]
  calc
    (∑ x : ι → α, prodMass p x * (∑ j, radius f lo hi x j)) ≤
      (∑ x : ι → α, prodMass p x * (2 * (d : ℝ) ^ 2)) := by
        apply Finset.sum_le_sum
        intro x _
        exact mul_le_mul_of_nonneg_left (hpoint x) (prodMass_nonneg' p hp x)
    _ = 2 * (d : ℝ) ^ 2 := by
        rw [← Finset.sum_mul, sum_prodMass p hp1, one_mul]

/-- The manuscript's L(f) = 2 * sum pincr normalization, with the exact
rho factor. The hypothesis is the actual weighted endpoint-radius energy;
we do not assume the entire final influence theorem. -/
theorem total_increment_of_radius_energy
    (p : ι → α → ℝ) (hp : ∀ i b, 0 ≤ p i b)
    (hp1 : ∀ i, ∑ b, p i b = 1)
    (f : (ι → α) → ℝ)
    (lo hi : (ι → α) → ι → ℝ)
    (hlohi : ∀ x j, lo x j ≤ hi x j)
    (hlo : ∀ x j b, lo x j ≤ f (Function.update x j b))
    (hhi : ∀ x j b, f (Function.update x j b) ≤ hi x j)
    (hlofix : ∀ x j b, lo (Function.update x j b) j = lo x j)
    (hhifix : ∀ x j b, hi (Function.update x j b) j = hi x j)
    (d : ℕ)
    (hbudget : (∑ j, ∑ x : ι → α, prodMass p x * radius f lo hi x j) ≤
      2 * (d : ℝ) ^ 2) :
    2 * (∑ j, pincr p f j) ≤
      4 * (4 - 2 * Real.sqrt 3) * (d : ℝ) ^ 2 := by
  let r : ℝ := 4 - 2 * Real.sqrt 3
  have hr : 0 ≤ r := by
    simpa [r, Nightfall.Wright.SharpLimit.rho] using
      Nightfall.Wright.SharpLimit.rho_nonnegative
  have hsum : (∑ j, pincr p f j) ≤
      ∑ j, r * (∑ x : ι → α, prodMass p x * radius f lo hi x j) := by
    apply Finset.sum_le_sum
    intro j _
    exact actual_pincr_le_rho_radius p hp hp1 f lo hi hlohi hlo hhi hlofix hhifix j
  have hbudget' : r * (∑ j, ∑ x : ι → α,
      prodMass p x * radius f lo hi x j) ≤ r * (2 * (d : ℝ) ^ 2) :=
    mul_le_mul_of_nonneg_left hbudget hr
  have hcoef : (∑ j, r *
      (∑ x : ι → α, prodMass p x * radius f lo hi x j)) =
      r * (∑ j, ∑ x : ι → α, prodMass p x * radius f lo hi x j) := by
    rw [Finset.mul_sum]
  calc
    2 * (∑ j, pincr p f j) ≤
      2 * (∑ j, r *
        (∑ x : ι → α, prodMass p x * radius f lo hi x j)) := by
          linarith
    _ = 2 * (r * (∑ j, ∑ x : ι → α,
      prodMass p x * radius f lo hi x j)) := by rw [hcoef]
    _ ≤ 2 * (r * (2 * (d : ℝ) ^ 2)) := by linarith
    _ = 4 * (4 - 2 * Real.sqrt 3) * (d : ℝ) ^ 2 := by dsimp [r]; ring

/-- The strongest direct consequence conditional on the pointwise FHKL
certificate: Wright's exact sharp global increment, for actual pincr. -/
theorem total_increment_of_pointwise_sensitivity
    (p : ι → α → ℝ) (hp : ∀ i b, 0 ≤ p i b)
    (hp1 : ∀ i, ∑ b, p i b = 1)
    (f : (ι → α) → ℝ)
    (lo hi : (ι → α) → ι → ℝ)
    (hlohi : ∀ x j, lo x j ≤ hi x j)
    (hlo : ∀ x j b, lo x j ≤ f (Function.update x j b))
    (hhi : ∀ x j b, f (Function.update x j b) ≤ hi x j)
    (hlofix : ∀ x j b, lo (Function.update x j b) j = lo x j)
    (hhifix : ∀ x j b, hi (Function.update x j b) j = hi x j)
    (d : ℕ)
    (hpoint : ∀ x : ι → α, ∑ j, radius f lo hi x j ≤ 2 * (d : ℝ) ^ 2) :
    2 * (∑ j, pincr p f j) ≤
      4 * (4 - 2 * Real.sqrt 3) * (d : ℝ) ^ 2 :=
  total_increment_of_radius_energy p hp hp1 f lo hi
    hlohi hlo hhi hlofix hhifix d
    (radius_energy_of_pointwise_budget p hp hp1 f lo hi d hpoint)

end Nightfall.Wright.TotalIncrement


/-!
## Canonical endpoint construction (finite alphabets)

This removes the assumed endpoint functions from the total increment theorem.
It does not remove the still-open pointwise sensitivity estimate required of
the original bounded Hoeffding-degree-d input.
-/
namespace Nightfall.Wright.CanonicalFiber
open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.Wright.ProductFiber
open Nightfall.Wright.ActualIncrement
open Nightfall.Wright.TotalIncrement

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

noncomputable def fiberLo (f : (ι → α) → ℝ)
    (x : ι → α) (j : ι) : ℝ :=
  (Finset.univ : Finset α).inf' Finset.univ_nonempty
    (fun b => f (Function.update x j b))

noncomputable def fiberHi (f : (ι → α) → ℝ)
    (x : ι → α) (j : ι) : ℝ :=
  (Finset.univ : Finset α).sup' Finset.univ_nonempty
    (fun b => f (Function.update x j b))

theorem fiberLo_le (f : (ι → α) → ℝ)
    (x : ι → α) (j : ι) (b : α) :
    fiberLo f x j ≤ f (Function.update x j b) := by
  unfold fiberLo
  exact Finset.inf'_le _ (Finset.mem_univ b)

theorem le_fiberHi (f : (ι → α) → ℝ)
    (x : ι → α) (j : ι) (b : α) :
    f (Function.update x j b) ≤ fiberHi f x j := by
  unfold fiberHi
  exact Finset.le_sup' (fun c : α => f (Function.update x j c)) (Finset.mem_univ b)

theorem fiberLo_update (f : (ι → α) → ℝ)
    (x : ι → α) (j : ι) (b : α) :
    fiberLo f (Function.update x j b) j = fiberLo f x j := by
  unfold fiberLo
  have hfun :
      (fun c : α => f (Function.update (Function.update x j b) j c)) =
      (fun c : α => f (Function.update x j c)) := by
    funext c
    rw [update_twice]
  exact congrArg
    (fun g : α → ℝ => (Finset.univ : Finset α).inf' Finset.univ_nonempty g) hfun

theorem fiberHi_update (f : (ι → α) → ℝ)
    (x : ι → α) (j : ι) (b : α) :
    fiberHi f (Function.update x j b) j = fiberHi f x j := by
  unfold fiberHi
  have hfun :
      (fun c : α => f (Function.update (Function.update x j b) j c)) =
      (fun c : α => f (Function.update x j c)) := by
    funext c
    rw [update_twice]
  exact congrArg
    (fun g : α → ℝ => (Finset.univ : Finset α).sup' Finset.univ_nonempty g) hfun

/-- Total actual resampling from the canonical fiber extrema, with no
extra supplied endpoint data. The only remaining functional premise is
the explicit FHKL pointwise sensitivity budget for this same f. -/
theorem total_increment_of_canonical_sensitivity
    (p : ι → α → ℝ) (hp : ∀ i b, 0 ≤ p i b)
    (hp1 : ∀ i, ∑ b, p i b = 1)
    (f : (ι → α) → ℝ) (d : ℕ)
    (hpoint : ∀ x : ι → α,
      ∑ j, radius f (fiberLo f) (fiberHi f) x j ≤
        2 * (d : ℝ) ^ 2) :
    2 * (∑ j, pincr p f j) ≤
      4 * (4 - 2 * Real.sqrt 3) * (d : ℝ) ^ 2 := by
  apply total_increment_of_pointwise_sensitivity p hp hp1 f
    (fiberLo f) (fiberHi f)
  · intro x j
    let b : α := Classical.choice (inferInstance : Nonempty α)
    exact (fiberLo_le f x j b).trans (le_fiberHi f x j b)
  · intro x j b
    exact fiberLo_le f x j b
  · intro x j b
    exact le_fiberHi f x j b
  · intro x j b
    exact fiberLo_update f x j b
  · intro x j b
    exact fiberHi_update f x j b
  · exact hpoint

end Nightfall.Wright.CanonicalFiber
