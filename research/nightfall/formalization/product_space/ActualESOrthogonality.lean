import ActualESPairMatchingBridge

/-!
# Actual finite-law Efron-Stein source orthogonality

Two canonical Efron-Stein components with different supports are
orthogonal in the ORIGINAL finite independent product law. The proof
uses coordinate resampling of a centered source interaction, rather
than importing a formal covariance/orthogonality premise.

No positive-atom floor, no quadratic-degree cap, and no supplied
moment/influence certificate. This is one required building block for
the variance and influence ANOVA energy equality, but the full global
decomposition/terminal Q2 inequality is not stated in this module.
-/

namespace Nightfall.Observability.ActualESOrthogonality

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.Transfer
open Nightfall.Observability.ActualESPairMatching

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- A genuine product expectation of a coordinate-centered section
vanishes when multiplied by an observable ignoring that coordinate. -/
theorem centered_orthogonal_to_dependsOn
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (g h : (ι → α) → ℝ)
    (S : Finset ι) (hdep : DependsOn S g)
    (k : ι) (hk : k ∉ S)
    (hcenter : ∀ x : ι → α,
      (∑ a : α, p k a * h (Function.update x k a)) = 0) :
    (∑ x : ι → α, prodMass p x * g x * h x) = 0 := by
  have hfix (x : ι → α) (a : α) :
      g (Function.update x k a) = g x := by
    apply hdep
    intro j hj
    have hjk : j ≠ k := by
      intro heq
      exact hk (heq ▸ hj)
    exact Function.update_of_ne hjk a x
  calc
    (∑ x : ι → α, prodMass p x * g x * h x) =
      ∑ x : ι → α, prodMass p x * (g x * h x) := by
        apply Finset.sum_congr rfl
        intro x _
        ring
    _ = ∑ x : ι → α, ∑ a : α, prodMass p x * p k a *
        (g (Function.update x k a) * h (Function.update x k a)) := by
          exact (resample_sum p hp1 k (fun x => g x * h x)).symm
    _ = ∑ x : ι → α, prodMass p x * g x *
        (∑ a : α, p k a * h (Function.update x k a)) := by
          apply Finset.sum_congr rfl
          intro x _
          simp only [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro a _
          rw [hfix x a]
          ring
    _ = 0 := by
          simp only [hcenter, mul_zero, Finset.sum_const_zero]

/-- Two distinct canonical interaction supports have zero product-law
inner product. Both kernels arise from the same genuine source f. -/
theorem actual_esComp_orthogonal
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (S T : Finset ι) (hne : S ≠ T) :
    (∑ x : ι → α, prodMass p x *
      esComp p S f x * esComp p T f x) = 0 := by
  classical
  by_cases hTS : T ⊆ S
  · have hST : ¬S ⊆ T := by
      intro hh
      exact hne (Finset.Subset.antisymm hh hTS)
    have hmiss : ∃ k ∈ S, k ∉ T := by
      by_contra h
      push_neg at h
      exact hST (fun k hk => h k hk)
    obtain ⟨k,hkS,hkT⟩ := hmiss
    have horth := centered_orthogonal_to_dependsOn
      p hp1 (esComp p T f) (esComp p S f)
      T (esComp_dependsOn p T f)
      k hkT (fun x => actual_esComp_centered p hp1 f S k hkS x)
    calc
      (∑ x : ι → α, prodMass p x *
         esComp p S f x * esComp p T f x) =
        ∑ x : ι → α, prodMass p x *
          esComp p T f x * esComp p S f x := by
            apply Finset.sum_congr rfl
            intro x _
            ring
      _ = 0 := horth
  · have hmiss : ∃ k ∈ T, k ∉ S := by
      by_contra h
      push_neg at h
      exact hTS (fun k hk => h k hk)
    obtain ⟨k,hkT,hkS⟩ := hmiss
    exact centered_orthogonal_to_dependsOn
      p hp1 (esComp p S f) (esComp p T f)
      S (esComp_dependsOn p S f)
      k hkS (fun x => actual_esComp_centered p hp1 f T k hkT x)

end Nightfall.Observability.ActualESOrthogonality
