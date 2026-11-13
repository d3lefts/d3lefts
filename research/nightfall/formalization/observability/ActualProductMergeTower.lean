import Mathlib

/-!
# Exact product-source merge tower: no synthetic neighbor independence

An original source input X and a second independent original-law draw Y
are combined by retaining X on a finite coordinate set S and Y outside.
The merged input has EXACTLY the original source product law. This is
proved as a finite sum identity by a measure-preserving involution on
pairs of full source inputs, not assumed as an oracle or expectation
operator axiom. Nonuniform laws, zero weights and even signed normalized
coordinate weights are supported by the algebra.

This gives the missing *integrated* conditional-Jensen operator law:
taking a weighted conditional source norm and then averaging over the
true source law cannot increase the unconditional mean norm.

The separate canonical owner-neighbor identification must still link
the projected source section to a given greedy-owned pair sum; this
module does not assert the terminal Q2 theorem.
-/

namespace Nightfall.Observability.ActualProductMergeTower

open Finset

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype α]

/-- The literal finite original-product density at a source input. -/
noncomputable def originalMass
    (p : ι → α → ℝ) (x : ι → α) : ℝ :=
  ∏ i : ι, p i (x i)

/-- Retain coordinates in S from x and replace all others from y. -/
noncomputable def keepSource
    (S : Finset ι) (x y : ι → α) : ι → α :=
  fun i => if i ∈ S then x i else y i

/-- Exchange the two original inputs *outside S*. Involution on
complete source pairs; all input coordinates remain original sites. -/
noncomputable def exchangeOutside
    (S : Finset ι) : ((ι → α) × (ι → α)) ≃
      ((ι → α) × (ι → α)) where
  toFun z := (keepSource S z.1 z.2, keepSource S z.2 z.1)
  invFun z := (keepSource S z.1 z.2, keepSource S z.2 z.1)
  left_inv := by
    rintro ⟨x, y⟩
    apply Prod.ext
    · funext i
      by_cases hi : i ∈ S <;> simp [keepSource, hi]
    · funext i
      by_cases hi : i ∈ S <;> simp [keepSource, hi]
  right_inv := by
    rintro ⟨x, y⟩
    apply Prod.ext
    · funext i
      by_cases hi : i ∈ S <;> simp [keepSource, hi]
    · funext i
      by_cases hi : i ∈ S <;> simp [keepSource, hi]

/-- Exact product-law weight preservation under the pair exchange.
No nonzero coordinate masses, atom floor, or inequality premise. -/
theorem exchangeOutside_preserves_pair_mass
    (p : ι → α → ℝ) (S : Finset ι)
    (x y : ι → α) :
    originalMass p x * originalMass p y =
      originalMass p (keepSource S x y) *
        originalMass p (keepSource S y x) := by
  unfold originalMass
  rw [← Finset.prod_mul_distrib, ← Finset.prod_mul_distrib]
  apply Finset.prod_congr rfl
  intro i _
  by_cases hi : i ∈ S
  · simp [keepSource, hi]
  · simp [keepSource, hi, mul_comm]

/-- Exact two-input law of any observable F after replacing the
unobserved coordinates by a true independent product sample. -/
theorem exchangeOutside_double_expectation
    (p : ι → α → ℝ) (S : Finset ι)
    (F : (ι → α) → ℝ) :
    (∑ x : ι → α, ∑ y : ι → α,
      originalMass p x * originalMass p y *
        F (keepSource S x y)) =
      (∑ x : ι → α, originalMass p x * F x) *
        (∑ y : ι → α, originalMass p y) := by
  classical
  have hswap := Fintype.sum_equiv (exchangeOutside S)
    (fun z : (ι → α) × (ι → α) =>
      originalMass p z.1 * originalMass p z.2 *
        F (keepSource S z.1 z.2))
    (fun z : (ι → α) × (ι → α) =>
      originalMass p z.1 * originalMass p z.2 * F z.1)
    (by
      rintro ⟨x, y⟩
      change originalMass p x * originalMass p y *
        F (keepSource S x y) =
        originalMass p (keepSource S x y) *
          originalMass p (keepSource S y x) *
            F (keepSource S x y)
      rw [exchangeOutside_preserves_pair_mass p S x y])
  rw [Fintype.sum_prod_type, Fintype.sum_prod_type] at hswap
  calc
    (∑ x : ι → α, ∑ y : ι → α,
      originalMass p x * originalMass p y *
        F (keepSource S x y)) =
      ∑ x : ι → α, ∑ y : ι → α,
        originalMass p x * originalMass p y * F x := hswap
    _ = ∑ x : ι → α,
        (originalMass p x * F x) *
          (∑ y : ι → α, originalMass p y) := by
          apply Finset.sum_congr rfl
          intro x _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro y _
          ring
    _ = (∑ x : ι → α, originalMass p x * F x) *
        (∑ y : ι → α, originalMass p y) := by
          rw [Finset.sum_mul]

/-- Normalized coordinate masses induce a normalized original full
product law. Zero probability atoms are allowed. -/
theorem originalMass_total_one
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1) :
    (∑ x : ι → α, originalMass p x) = 1 := by
  classical
  unfold originalMass
  rw [← Fintype.prod_sum]
  simp [hp1]

/-- EXACT SOURCE TOWER: averaging an observable over the true product
law after conditioning on *any* finite original-coordinate set S
recovers its unconditional expectation, with no supplied tower axiom.
-/
theorem actual_product_merge_tower
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (S : Finset ι) (F : (ι → α) → ℝ) :
    (∑ x : ι → α, originalMass p x *
      (∑ y : ι → α, originalMass p y *
        F (keepSource S x y))) =
      ∑ x : ι → α, originalMass p x * F x := by
  classical
  calc
    (∑ x : ι → α, originalMass p x *
      (∑ y : ι → α, originalMass p y *
        F (keepSource S x y))) =
      ∑ x : ι → α, ∑ y : ι → α,
        originalMass p x * originalMass p y *
          F (keepSource S x y) := by
          apply Finset.sum_congr rfl
          intro x _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro y _
          ring
    _ = (∑ x : ι → α, originalMass p x * F x) *
      (∑ y : ι → α, originalMass p y) :=
        exchangeOutside_double_expectation p S F
    _ = ∑ x : ι → α, originalMass p x * F x := by
          rw [originalMass_total_one p hp1, mul_one]

/-- Global Jensen conversion, abstracted from the pointwise norm
inequality: for ANY scalar source observables G,H, if G is pointwise
at most the original product conditional average of H, then the
original product expectation of G is bounded by that of H.
This is the exact operator bridge needed to sum owner source sections.
-/
theorem integrated_source_jensen
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (S : Finset ι)
    (G H : (ι → α) → ℝ)
    (hpoint : ∀ x,
      G x ≤ ∑ y : ι → α, originalMass p y *
        H (keepSource S x y)) :
    (∑ x : ι → α, originalMass p x * G x) ≤
      ∑ x : ι → α, originalMass p x * H x := by
  classical
  have hm (x : ι → α) : 0 ≤ originalMass p x := by
    unfold originalMass
    exact Finset.prod_nonneg (fun i _ => hp i (x i))
  calc
    (∑ x : ι → α, originalMass p x * G x) ≤
      ∑ x : ι → α, originalMass p x *
        (∑ y : ι → α, originalMass p y *
          H (keepSource S x y)) := by
          apply Finset.sum_le_sum
          intro x _
          exact mul_le_mul_of_nonneg_left (hpoint x) (hm x)
    _ = ∑ x : ι → α, originalMass p x * H x :=
      actual_product_merge_tower p hp1 S H

end Nightfall.Observability.ActualProductMergeTower
