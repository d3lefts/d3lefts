import Mathlib

/-!
# NIGHTFALL FUR(2): kernel-checkable algebraic transport gates

This file does NOT prove the FUR(2) construction. It proves two independent
pieces of the proposed argument without sorry or added axioms:
* the elementary four-point real bound used after the degree-two
  Fourier/remainder identity;
* the passage from any finite pointwise anchored row-cover to an
  expectation bound under an arbitrary nonnegative joint law.

The existence of a maximal independent-coordinate coupling, its mismatch
factorization, the indicator-degree-two transition identity, and the FUR(2)
row construction remain separate obligations.
-/

namespace Nightfall.ProductSpace.FUR2TransportAudit

open Finset

theorem four_point_bound (u v m : ℝ)
    (hu : 0 ≤ u ∧ u ≤ 1) (hv : 0 ≤ v ∧ v ≤ 1)
    (hm : 0 ≤ m ∧ m ≤ 1) :
    |2 * (u + v) - 4 * m| ≤ 4 := by
  rw [abs_le]
  constructor <;> linarith

section FiniteCoupling

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

def firstWord (z : ι → α × α) : ι → α := fun i => (z i).1
def secondWord (z : ι → α × α) : ι → α := fun i => (z i).2

noncomputable def jointMass (κ : ι → α × α → ℝ) (z : ι → α × α) : ℝ :=
  ∏ i, κ i (z i)

theorem jointMass_nonneg (κ : ι → α × α → ℝ)
    (hκ : ∀ i p, 0 ≤ κ i p) (z : ι → α × α) :
    0 ≤ jointMass κ z := by
  exact Finset.prod_nonneg (fun i _ => hκ i (z i))

/-- Fully finite row-cover to joint-law transport; no coupling independence
    is required for this elementary part. -/
theorem joint_transport_of_rows
    (f : (ι → α) → ℝ) (a : ι → (ι → α) → ℝ)
    (hrow : ∀ x y, |f x - f y| ≤
      ∑ i, if x i = y i then (0 : ℝ) else a i x)
    (κ : ι → α × α → ℝ) (hκ : ∀ i p, 0 ≤ κ i p) :
    |(∑ z : ι → α × α, jointMass κ z * f (secondWord z)) -
      (∑ z : ι → α × α, jointMass κ z * f (firstWord z))|
      ≤ ∑ i, ∑ z : ι → α × α, jointMass κ z *
          (if (firstWord z) i = (secondWord z) i then (0 : ℝ)
           else a i (firstWord z)) := by
  have hdiff :
      (∑ z : ι → α × α, jointMass κ z * f (secondWord z)) -
      (∑ z : ι → α × α, jointMass κ z * f (firstWord z)) =
      ∑ z : ι → α × α, jointMass κ z *
        (f (secondWord z) - f (firstWord z)) := by
    rw [← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl ?_
    intro z _
    ring
  rw [hdiff]
  calc
    |∑ z : ι → α × α, jointMass κ z *
       (f (secondWord z) - f (firstWord z))|
        ≤ ∑ z : ι → α × α,
          |jointMass κ z * (f (secondWord z) - f (firstWord z))| :=
          Finset.abs_sum_le_sum_abs _ _
    _ = ∑ z : ι → α × α,
          jointMass κ z * |f (secondWord z) - f (firstWord z)| := by
        refine Finset.sum_congr rfl ?_
        intro z _
        rw [abs_mul, abs_of_nonneg (jointMass_nonneg κ hκ z)]
    _ ≤ ∑ z : ι → α × α, jointMass κ z *
          (∑ i, if (firstWord z) i = (secondWord z) i then (0 : ℝ)
                  else a i (firstWord z)) := by
        refine Finset.sum_le_sum ?_
        intro z _
        apply mul_le_mul_of_nonneg_left _ (jointMass_nonneg κ hκ z)
        simpa only [abs_sub_comm] using hrow (firstWord z) (secondWord z)
    _ = ∑ i, ∑ z : ι → α × α, jointMass κ z *
          (if (firstWord z) i = (secondWord z) i then (0 : ℝ)
           else a i (firstWord z)) := by
        simp_rw [Finset.mul_sum]
        rw [Finset.sum_comm]

/-- Conditional fixed-weight transport. The factorization equations
    are explicitly hypotheses, NOT silently asserted.
    Independent-coordinate maximal coupling remains a separate theorem. -/
theorem fixed_weight_of_coupling_factorization
    (f : (ι → α) → ℝ) (a : ι → (ι → α) → ℝ)
    (hrow : ∀ x y, |f x - f y| ≤
      ∑ i, if x i = y i then (0 : ℝ) else a i x)
    (κ : ι → α × α → ℝ) (hκ : ∀ i p, 0 ≤ κ i p)
    (w tv : ι → ℝ)
    (hfactor : ∀ i,
      (∑ z : ι → α × α, jointMass κ z *
        (if (firstWord z) i = (secondWord z) i then (0 : ℝ)
         else a i (firstWord z))) = w i * tv i) :
    |(∑ z : ι → α × α, jointMass κ z * f (secondWord z)) -
      (∑ z : ι → α × α, jointMass κ z * f (firstWord z))|
      ≤ ∑ i, w i * tv i := by
  calc
    _ ≤ ∑ i, ∑ z : ι → α × α, jointMass κ z *
        (if (firstWord z) i = (secondWord z) i then (0 : ℝ)
         else a i (firstWord z)) :=
        joint_transport_of_rows f a hrow κ hκ
    _ = ∑ i, w i * tv i := by
      apply Finset.sum_congr rfl
      intro i _
      exact hfactor i

end FiniteCoupling

end Nightfall.ProductSpace.FUR2TransportAudit

#print axioms Nightfall.ProductSpace.FUR2TransportAudit.four_point_bound
#print axioms Nightfall.ProductSpace.FUR2TransportAudit.joint_transport_of_rows
#print axioms Nightfall.ProductSpace.FUR2TransportAudit.fixed_weight_of_coupling_factorization
