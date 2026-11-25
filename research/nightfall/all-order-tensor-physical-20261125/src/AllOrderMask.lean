import AllOrderCore
import Mathlib.Data.Fintype.Pi
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.BigOperators.GroupWithZero.Action

namespace Nightfall.AllOrder
open Finset
variable {I A W : Type*} [Fintype I] [DecidableEq I] [Fintype A] [Fintype W]

noncomputable def cubeForm (c : (I → A) → ℝ) (u : I → A → ℝ) : ℝ :=
  ∑ a, c a * ∏ i, u i (a i)

noncomputable def maskRep (w : W → ℝ) (m : W → I → A → ℝ) (a : I → A) : ℝ :=
  ∑ t, w t * ∏ i, m t i (a i)

/-- Exact coefficient mask action on the full d-linear cube form. -/
theorem cube_mask_expansion (c : (I → A) → ℝ) (u : I → A → ℝ)
    (w : W → ℝ) (m : W → I → A → ℝ) :
    cubeForm (fun a => c a * maskRep w m a) u =
      ∑ t, w t * cubeForm c (fun i a => m t i a * u i a) := by
  classical
  unfold cubeForm maskRep
  simp_rw [Finset.mul_sum, Finset.sum_mul]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro t _
  apply Finset.sum_congr rfl
  intro a _
  rw [Finset.prod_mul_distrib]
  ring

/-- The actual masked form has norm at most the signed mask cost times
    the unmasked cube bound. All argument blocks are independent. -/
theorem cube_mask_bound (c : (I → A) → ℝ) (u : I → A → ℝ)
    (w : W → ℝ) (m : W → I → A → ℝ) (K : ℝ)
    (hK : 0 ≤ K) (hc : ∀ v : I → A → ℝ, (∀ i a, |v i a| ≤ 1) → |cubeForm c v| ≤ K)
    (hu : ∀ i a, |u i a| ≤ 1) (hm : ∀ t i a, |m t i a| ≤ 1) :
    |cubeForm (fun a => c a * maskRep w m a) u| ≤ (∑ t, |w t|) * K := by
  rw [cube_mask_expansion]
  apply signed_average_bound _ _ _ hK
  intro t
  apply hc
  intro i a
  rw [abs_mul]
  exact mul_le_one₀ (hm t i a) (abs_nonneg _) (hu i a)

/-- Fix inactive slot vectors to 1, keeping all active argument blocks
    free. This is the norm-controlled coherent contraction. -/
theorem cube_contracted_mask_bound
    (c : (I → A) → ℝ) (u : I → A → ℝ) (active : Finset I)
    (w : W → ℝ) (m : W → I → A → ℝ) (K : ℝ)
    (hK : 0 ≤ K) (hc : ∀ v : I → A → ℝ, (∀ i a, |v i a| ≤ 1) → |cubeForm c v| ≤ K)
    (hu : ∀ i a, |u i a| ≤ 1) (hm : ∀ t i a, |m t i a| ≤ 1) :
    |cubeForm (fun a => c a * maskRep w m a) (fun i a => if i ∈ active then u i a else 1)|
      ≤ (∑ t, |w t|) * K := by
  apply cube_mask_bound _ _ _ _ _ hK hc _ hm
  intro i a
  split
  · exact hu i a
  · simp

#print axioms cube_mask_expansion
#print axioms cube_mask_bound
#print axioms cube_contracted_mask_bound
end Nightfall.AllOrder
