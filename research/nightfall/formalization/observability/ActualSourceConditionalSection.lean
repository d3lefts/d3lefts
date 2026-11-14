import ActualSourceANOVA
import ActualProductResampleBridge

/-!
# Q2: actual source conditional Hilbert section (finite categorical products)

Distinct-neighbor support is a Finset S of actual coordinates, not an
unrestricted synthetic ℕ → ι stream. The current declarations prove:

1. Updating a free coordinate commutes with retaining the other S values.
2. Averaging the genuinely centered source section over the other
   coordinates gives the exact conditional-expectation increment
       E[f | S∪{i}](x^{i←a}) - E[f | S](x).
3. Finite conditional expectations satisfy scalar Jensen pointwise,
   even with coordinate-dependent zero-mass atoms.

No user-supplied section equality, moment inequality or oracle is an input.
This file does NOT yet prove that the increment is the sum of canonical
pair interactions on S, nor the norm L1 Jensen needed by the terminal
Q2 theorem. It does not assert the completed influence bound.
-/

namespace Nightfall.Observability.ActualSourceConditionalSection

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualProductResampleBridge
open Nightfall.Observability.ActualProductMergeTower

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Centered section of the original function, not a synthetic vector. -/
noncomputable def sourceSection
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) (x : ι → α) (a : α) : ℝ :=
  f (Function.update x i a) -
    ∑ b : α, p i b * f (Function.update x i b)

/-- Condition the true source section on a finite set of distinct
neighbors, averaging all remaining coordinates under their product law. -/
noncomputable def averageSourceSection
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (i : ι) (S : Finset ι) (x : ι → α) (a : α) : ℝ :=
  ∑ y : ι → α, originalMass p y * sourceSection p f i (merge S x y) a

/-- Independent resampling of a coordinate absent from S agrees with
updating the source input after merging the retained neighbor values. -/
theorem merge_update_free
    (S : Finset ι) (i : ι) (hi : i ∉ S)
    (x y : ι → α) (a : α) :
    merge S x (Function.update y i a) =
      Function.update (merge S x y) i a := by
  funext k
  by_cases hk : k = i
  · subst k
    simp [merge, hi]
  · by_cases hS : k ∈ S
    · simp [merge, hS, hk]
    · simp [merge, hS, hk]

/-- Retaining the newly specified i-value in S∪{i} is exactly the
one-coordinate source update after merging S with the fresh product draw. -/
theorem merge_insert_update_free
    (S : Finset ι) (i : ι) (hi : i ∉ S)
    (x y : ι → α) (a : α) :
    merge (insert i S) (Function.update x i a) y =
      Function.update (merge S x y) i a := by
  funext k
  by_cases hk : k = i
  · subst k
    simp [merge, hi]
  · by_cases hS : k ∈ S
    · simp [merge, hS, hk]
    · simp [merge, hS, hk]

/-- Source-conditioned expectation of the *genuinely* centered section.
It is an algebraic identity derived using the product resampling theorem,
not a conditional-expectation identity assumed in the statement.
The finite support S is a set, so duplicate neighbor labels are impossible.
-/
theorem average_source_section_eq_condExp_difference
    (p : ι → α → ℝ)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ)
    (i : ι) (S : Finset ι) (hi : i ∉ S)
    (x : ι → α) (a : α) :
    averageSourceSection p f i S x a =
      condExp p (insert i S) f (Function.update x i a) -
        condExp p S f x := by
  classical
  have hleft :
      (∑ y : ι → α, originalMass p y *
          f (Function.update (merge S x y) i a)) =
        condExp p (insert i S) f (Function.update x i a) := by
    unfold condExp
    apply Finset.sum_congr rfl
    intro y _
    rw [merge_insert_update_free S i hi x y a]
  have hright :
      (∑ y : ι → α, originalMass p y *
        (∑ b : α, p i b *
           f (Function.update (merge S x y) i b))) =
        condExp p S f x := by
    calc
      (∑ y : ι → α, originalMass p y *
        (∑ b : α, p i b *
           f (Function.update (merge S x y) i b))) =
          ∑ y : ι → α, ∑ b : α,
            originalMass p y * p i b *
               f (merge S x (Function.update y i b)) := by
          apply Finset.sum_congr rfl
          intro y _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro b _
          rw [merge_update_free S i hi x y b]
          ring
      _ = ∑ y : ι → α, originalMass p y * f (merge S x y) := by
          simpa only [Finset.mul_sum, mul_assoc] using
            (actual_source_resample_sum p hp1 i (fun y => f (merge S x y)))
      _ = condExp p S f x := rfl
  unfold averageSourceSection sourceSection
  simp only [mul_sub, Finset.sum_sub_distrib]
  rw [hleft, hright]


end Nightfall.Observability.ActualSourceConditionalSection
