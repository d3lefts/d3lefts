import EfronSteinDegree
import ProductInfluence

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

namespace Nightfall.Observability.ActualESConditionalSection

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.Transfer

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
  ∑ y : ι → α, prodMass p y * sourceSection p f i (merge S x y) a

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
      (∑ y : ι → α, prodMass p y *
          f (Function.update (merge S x y) i a)) =
        condExp p (insert i S) f (Function.update x i a) := by
    unfold condExp
    apply Finset.sum_congr rfl
    intro y _
    rw [merge_insert_update_free S i hi x y a]
  have hright :
      (∑ y : ι → α, prodMass p y *
        (∑ b : α, p i b *
           f (Function.update (merge S x y) i b))) =
        condExp p S f x := by
    calc
      (∑ y : ι → α, prodMass p y *
        (∑ b : α, p i b *
           f (Function.update (merge S x y) i b))) =
          ∑ y : ι → α, ∑ b : α,
            prodMass p y * p i b *
               f (merge S x (Function.update y i b)) := by
          apply Finset.sum_congr rfl
          intro y _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro b _
          rw [merge_update_free S i hi x y b]
          ring
      _ = ∑ y : ι → α, prodMass p y * f (merge S x y) := by
          exact resample_sum p hp1 i (fun y => f (merge S x y))
      _ = condExp p S f x := rfl
  unfold averageSourceSection sourceSection
  simp only [mul_sub, Finset.sum_sub_distrib]
  rw [hleft, hright]

/-- Exact weighted scalar Jensen on a finite normalized nonnegative
measure: it permits zero atoms and imposes no positive atom floor. -/
theorem finite_weighted_jensen_square
    {Ω : Type*} [Fintype Ω]
    (μ : Ω → ℝ) (G : Ω → ℝ)
    (hμ : ∀ y, 0 ≤ μ y)
    (hμ1 : (∑ y : Ω, μ y) = 1) :
    (∑ y : Ω, μ y * G y) ^ 2 ≤
      ∑ y : Ω, μ y * (G y)^2 := by
  classical
  have h := Finset.sum_sq_le_sum_mul_sum_of_sq_eq_mul
    (s := (Finset.univ : Finset Ω))
    (r := fun y => μ y * G y)
    (f := μ)
    (g := fun y => μ y * G y ^ 2)
    (fun y _ => hμ y)
    (fun y _ => mul_nonneg (hμ y) (sq_nonneg (G y)))
    (fun y _ => by ring)
  rw [hμ1, one_mul] at h
  exact h

/-- Conditional expectations on the actual product law satisfy
pointwise Jensen. No boundedness, degree, full support or independence
of a synthetic neighbor stream is required beyond the source product law. -/
theorem actual_condExp_jensen_square
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (S : Finset ι) (g : (ι → α) → ℝ)
    (x : ι → α) :
    (condExp p S g x)^2 ≤
      condExp p S (fun y => (g y)^2) x := by
  unfold condExp
  exact finite_weighted_jensen_square
    (prodMass p) (fun y => g (merge S x y))
    (prodMass_nonneg' p hp) (sum_prodMass p hp1)

/-- Scalar conditional Jensen for a concrete true centered section. -/
theorem actual_section_conditional_jensen_square
    (p : ι → α → ℝ)
    (hp : ∀ k a, 0 ≤ p k a)
    (hp1 : ∀ k, (∑ a : α, p k a) = 1)
    (f : (ι → α) → ℝ) (i : ι)
    (S : Finset ι) (x : ι → α) (a : α) :
    (averageSourceSection p f i S x a)^2 ≤
      ∑ y : ι → α, prodMass p y *
        (sourceSection p f i (merge S x y) a)^2 := by
  unfold averageSourceSection
  exact finite_weighted_jensen_square
    (prodMass p) (fun y => sourceSection p f i (merge S x y) a)
    (prodMass_nonneg' p hp) (sum_prodMass p hp1)

end Nightfall.Observability.ActualESConditionalSection
