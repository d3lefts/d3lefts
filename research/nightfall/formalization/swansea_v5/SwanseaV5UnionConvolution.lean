import Mathlib

/-!
# Swansea V5: union convolution and finite refresh actions

Source: *Convolution and the Cost of Knowing*, Swansea V5 omnibus,
Part II, section 11 (12 November 2026).

This file certifies the **finite algebraic semilattice layer**:
  * convolution of weights indexed by refresh-coordinate subsets;
  * conservation of total weight under convolution;
  * nonnegativity of convolved nonnegative weights;
  * composition of a weighted refresh action with a union-composition law.

The hypothesis `hrefresh` is the refresh-action composition identity.
It is NOT a derivation from conditional expectations on a probability space.
No Hoeffding decomposition, quadratic influence inequality Q2, posterior
observation theorem, measurable-product extension, or novelty claim is
formalized here. These are classical algebraic baseline results.
-/

namespace Nightfall.SwanseaV5

open Finset

variable {ι Ω : Type*} [Fintype ι] [DecidableEq ι]

/-- Convolution in the finite union semilattice of refresh subsets. -/
noncomputable def unionConvolution
    (ν η : Finset ι → ℝ) (C : Finset ι) : ℝ :=
  ∑ A : Finset ι, ∑ B : Finset ι,
    if A ∪ B = C then ν A * η B else 0

/-- Weighted action of a family of coordinate-refresh maps. -/
noncomputable def weightedRefresh
    (refresh : Finset ι → Ω → Ω)
    (ν : Finset ι → ℝ) (f : Ω → ℝ) (x : Ω) : ℝ :=
  ∑ A : Finset ι, ν A * f (refresh A x)

/-- Rearrangement of three complete finite sums. -/
private theorem triple_sum_reorder
    (h : Finset ι → Finset ι → Finset ι → ℝ) :
    (∑ A : Finset ι, ∑ B : Finset ι, ∑ C : Finset ι, h A B C) =
      ∑ C : Finset ι, ∑ A : Finset ι, ∑ B : Finset ι, h A B C := by
  calc
    _ = ∑ A : Finset ι, ∑ C : Finset ι, ∑ B : Finset ι, h A B C := by
      apply Finset.sum_congr rfl
      intro A _
      exact Finset.sum_comm
    _ = _ := Finset.sum_comm

/-- Union convolution preserves the product of total masses. -/
theorem unionConvolution_total_mass
    (ν η : Finset ι → ℝ) :
    (∑ C : Finset ι, unionConvolution ν η C) =
      (∑ A : Finset ι, ν A) * (∑ B : Finset ι, η B) := by
  classical
  unfold unionConvolution
  calc
    (∑ C : Finset ι, ∑ A : Finset ι, ∑ B : Finset ι,
        if A ∪ B = C then ν A * η B else 0) =
      ∑ A : Finset ι, ∑ B : Finset ι, ∑ C : Finset ι,
        if A ∪ B = C then ν A * η B else 0 :=
          (triple_sum_reorder (fun A B C =>
            if A ∪ B = C then ν A * η B else 0)).symm
    _ = ∑ A : Finset ι, ∑ B : Finset ι, ν A * η B := by
      apply Finset.sum_congr rfl
      intro A _
      apply Finset.sum_congr rfl
      intro B _
      simp
    _ = ∑ A : Finset ι, ν A * (∑ B : Finset ι, η B) := by
      apply Finset.sum_congr rfl
      intro A _
      rw [Finset.mul_sum]
    _ = _ := (Finset.sum_mul).symm

/-- Nonnegative refresh weights remain nonnegative after union convolution. -/
theorem unionConvolution_nonneg
    (ν η : Finset ι → ℝ)
    (hν : ∀ A, 0 ≤ ν A) (hη : ∀ B, 0 ≤ η B)
    (C : Finset ι) :
    0 ≤ unionConvolution ν η C := by
  classical
  unfold unionConvolution
  apply Finset.sum_nonneg
  intro A _
  apply Finset.sum_nonneg
  intro B _
  split_ifs
  · exact mul_nonneg (hν A) (hη B)
  · exact le_refl 0

/-- Finite action identity: T_ν(T_η f)=T_(ν *_union η)f.

The only operator assumption is the explicitly stated composition law
for refresh maps. Verifying that a probabilistic conditional-averaging
operator satisfies the corresponding law is a distinct theorem obligation.
-/
theorem weightedRefresh_union_comp
    (refresh : Finset ι → Ω → Ω)
    (hrefresh : ∀ A B : Finset ι, ∀ x : Ω,
      refresh B (refresh A x) = refresh (A ∪ B) x)
    (ν η : Finset ι → ℝ) (f : Ω → ℝ) (x : Ω) :
    weightedRefresh refresh ν (weightedRefresh refresh η f) x =
      weightedRefresh refresh (unionConvolution ν η) f x := by
  classical
  change
    (∑ A : Finset ι, ν A *
      (∑ B : Finset ι, η B * f (refresh B (refresh A x)))) =
    ∑ C : Finset ι,
      (∑ A : Finset ι, ∑ B : Finset ι,
        if A ∪ B = C then ν A * η B else 0) * f (refresh C x)
  calc
    (∑ A : Finset ι, ν A *
      (∑ B : Finset ι, η B * f (refresh B (refresh A x)))) =
      ∑ A : Finset ι, ∑ B : Finset ι,
        (ν A * η B) * f (refresh (A ∪ B) x) := by
          simp_rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro A _
          apply Finset.sum_congr rfl
          intro B _
          rw [hrefresh A B x]
          ring
    _ = ∑ A : Finset ι, ∑ B : Finset ι, ∑ C : Finset ι,
          if A ∪ B = C then (ν A * η B) * f (refresh C x) else 0 := by
          apply Finset.sum_congr rfl
          intro A _
          apply Finset.sum_congr rfl
          intro B _
          simp
    _ = ∑ C : Finset ι, ∑ A : Finset ι, ∑ B : Finset ι,
          if A ∪ B = C then (ν A * η B) * f (refresh C x) else 0 :=
          triple_sum_reorder _
    _ = ∑ C : Finset ι,
          (∑ A : Finset ι, ∑ B : Finset ι,
            if A ∪ B = C then ν A * η B else 0) * f (refresh C x) := by
          apply Finset.sum_congr rfl
          intro C _
          rw [Finset.sum_mul]
          apply Finset.sum_congr rfl
          intro A _
          rw [Finset.sum_mul]
          apply Finset.sum_congr rfl
          intro B _
          split_ifs <;> ring

end Nightfall.SwanseaV5
