import Mathlib

/-!
# Strong product simulation: conditional decoder kernel composition

Given an original source law p, a one-symbol coupling C producing a dyadic
symbol law q, and a seed decoder kernel D producing a uniform seed law r,
we construct the composed source-to-seed kernel K and certify:
(1) normalization and nonnegativity;
(2) exact original-source → seed pushforward;
(3) tensorization to the full independent coordinate product, with zero atoms.

These are true finite-probability identities, without a lower atom bound.
They do NOT yet prove that the chosen dyadic q and conditional D exist for
every target p, nor the adaptive lazy-query cost, nor BDST quantum simulation.
-/

namespace Nightfall.StrongSeedKernel

open Finset

variable {X Y U : Type*} [Fintype X] [Fintype Y] [Fintype U]

/-- First sample an encoded symbol using C, then its compatible seed
using D. No division or positive-atom assumptions enter the definition. -/
noncomputable def composeKernel
    (C : X → Y → ℝ) (D : Y → U → ℝ) (x : X) (u : U) : ℝ :=
  ∑ y : Y, C x y * D y u

theorem composeKernel_nonneg
    (C : X → Y → ℝ) (D : Y → U → ℝ)
    (hC : ∀ x y, 0 ≤ C x y) (hD : ∀ y u, 0 ≤ D y u)
    (x : X) (u : U) :
    0 ≤ composeKernel C D x u := by
  unfold composeKernel
  exact Finset.sum_nonneg (fun y _ => mul_nonneg (hC x y) (hD y u))

/-- A composite of two row-stochastic kernels remains row-stochastic. -/
theorem composeKernel_sum_one
    (C : X → Y → ℝ) (D : Y → U → ℝ)
    (hC : ∀ x, (∑ y : Y, C x y) = 1)
    (hD : ∀ y, (∑ u : U, D y u) = 1)
    (x : X) :
    (∑ u : U, composeKernel C D x u) = 1 := by
  unfold composeKernel
  calc
    (∑ u : U, ∑ y : Y, C x y * D y u)
       = ∑ y : Y, ∑ u : U, C x y * D y u :=
          Finset.sum_comm
    _ = ∑ y : Y, C x y * (∑ u : U, D y u) := by
          apply Finset.sum_congr rfl
          intro y _
          rw [Finset.mul_sum]
    _ = ∑ y : Y, C x y := by simp [hD]
    _ = 1 := hC x

/-- If p→q under C and q→r under D, then p→r under their composition.
In particular the conditional seed sampler is *exactly uniform* whenever
r is the uniform bit-block distribution. -/
theorem composeKernel_pushforward
    (p : X → ℝ) (q : Y → ℝ) (r : U → ℝ)
    (C : X → Y → ℝ) (D : Y → U → ℝ)
    (hC : ∀ y, (∑ x : X, p x * C x y) = q y)
    (hD : ∀ u, (∑ y : Y, q y * D y u) = r u)
    (u : U) :
    (∑ x : X, p x * composeKernel C D x u) = r u := by
  unfold composeKernel
  calc
    (∑ x : X, p x * (∑ y : Y, C x y * D y u))
      = ∑ x : X, ∑ y : Y, p x * (C x y * D y u) := by
          apply Finset.sum_congr rfl
          intro x _
          rw [Finset.mul_sum]
    _ = ∑ y : Y, ∑ x : X, (p x * C x y) * D y u := by
          rw [Finset.sum_comm]
          apply Finset.sum_congr rfl
          intro y _
          apply Finset.sum_congr rfl
          intro x _
          ring
    _ = ∑ y : Y, (∑ x : X, p x * C x y) * D y u := by
          apply Finset.sum_congr rfl
          intro y _
          rw [Finset.sum_mul]
    _ = ∑ y : Y, q y * D y u := by simp [hC]
    _ = r u := hD u

/-- Independent conditional seed kernels preserve the full product law
coordinatewise. This is the crucial joint-law equality for a cached
block-per-coordinate sampler; marginal correctness alone is insufficient. -/
theorem productKernel_pushforward
    {ι A B : Type*} [Fintype ι] [DecidableEq ι] [Fintype A] [Fintype B]
    (p : ι → A → ℝ) (K : ι → A → B → ℝ) (r : ι → B → ℝ)
    (hpush : ∀ i u,
      (∑ x : A, p i x * K i x u) = r i u)
    (seed : ι → B) :
    (∑ x : ι → A,
      (∏ i : ι, p i (x i)) *
      (∏ i : ι, K i (x i) (seed i))) =
    ∏ i : ι, r i (seed i) := by
  classical
  calc
    (∑ x : ι → A,
      (∏ i : ι, p i (x i)) *
      (∏ i : ι, K i (x i) (seed i))) =
      ∑ x : ι → A,
        ∏ i : ι, p i (x i) * K i (x i) (seed i) := by
          apply Finset.sum_congr rfl
          intro x _
          rw [Finset.prod_mul_distrib]
    _ = ∏ i : ι, ∑ a : A, p i a * K i a (seed i) :=
          (Fintype.prod_sum
            (fun i (a : A) => p i a * K i a (seed i))).symm
    _ = ∏ i : ι, r i (seed i) := by simp [hpush]

/-- Uniformity is a special case of the exact joint product pushforward. -/
theorem uniformProductSeed
    {ι A B : Type*} [Fintype ι] [DecidableEq ι] [Fintype A] [Fintype B]
    (p : ι → A → ℝ) (K : ι → A → B → ℝ)
    (hpush : ∀ i u,
      (∑ x : A, p i x * K i x u) = 1 / (Fintype.card B : ℝ))
    (seed : ι → B) :
    (∑ x : ι → A,
      (∏ i : ι, p i (x i)) *
      (∏ i : ι, K i (x i) (seed i))) =
    ∏ _i : ι, (1 / (Fintype.card B : ℝ)) := by
  exact productKernel_pushforward p K
    (fun _ _ => 1 / (Fintype.card B : ℝ)) hpush seed

end Nightfall.StrongSeedKernel

#print axioms Nightfall.StrongSeedKernel.composeKernel_nonneg
#print axioms Nightfall.StrongSeedKernel.composeKernel_sum_one
#print axioms Nightfall.StrongSeedKernel.composeKernel_pushforward
#print axioms Nightfall.StrongSeedKernel.productKernel_pushforward
#print axioms Nightfall.StrongSeedKernel.uniformProductSeed
