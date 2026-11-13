import ActualESPairMatchingBridge

/-!
# Exact conditional projection of genuine source Hoeffding components

A canonical Efron–Stein component supported inside an observed
coordinate set survives that set's actual conditional expectation.
A component depending on at least one unobserved coordinate vanishes
under that conditional expectation, by *proved* source centering and
finite product resampling. No orthogonality, conditional expectation
contractivity, or energy inequality is assumed.

This identity is a load-bearing representation bridge for the actual
owned-neighbor Jensen/ANOVA proof, not a terminal Q2 theorem.
-/

namespace Nightfall.Observability.ActualESConditionalProjection

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.Observability.ActualESPairMatching

variable {ι α : Type}
  [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Resampling an unobserved coordinate commutes with the literal
finite conditional-product merge. -/
theorem merge_update_outside
    (N : Finset ι) (k : ι) (hk : k ∉ N)
    (x y : ι → α) (a : α) :
    merge N x (Function.update y k a) =
      Function.update (merge N x y) k a := by
  funext t
  by_cases ht : t = k
  · subst t
    simp [merge, hk]
  · by_cases hN : t ∈ N
    · simp [merge, hN, ht]
    · simp [merge, hN, ht]

/-- If the canonical support is observed, the actual conditional
expectation preserves the canonical component pointwise. -/
theorem actual_condExp_esComp_subset
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (N U : Finset ι) (hsub : U ⊆ N)
    (x : ι → α) :
    condExp p N (esComp p U f) x = esComp p U f x := by
  have hconst (y : ι → α) :
      esComp p U f (merge N x y) = esComp p U f x := by
    apply esComp_dependsOn p U f
    intro k hk
    simp [merge, hsub hk]
  unfold condExp
  simp_rw [hconst]
  rw [← Finset.sum_mul, sum_prodMass' p hp1, one_mul]

/-- If one of its centered canonical coordinates is hidden, the
conditional expectation of an actual Efron–Stein component is zero.
The proof uses the real source-product mass and not an ideal oracle. -/
theorem actual_condExp_esComp_missing
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (N U : Finset ι)
    (k : ι) (hkU : k ∈ U) (hkN : k ∉ N)
    (x : ι → α) :
    condExp p N (esComp p U f) x = 0 := by
  have hcenter (y : ι → α) :
      (∑ a : α, p k a * esComp p U f
        (Function.update (merge N x y) k a)) = 0 :=
    actual_esComp_centered p hp1 f U k hkU (merge N x y)
  unfold condExp
  calc
    (∑ y : ι → α, prodMass p y * esComp p U f (merge N x y)) =
      (∑ y : ι → α, ∑ a : α,
        prodMass p y * p k a *
          esComp p U f (merge N x (Function.update y k a))) :=
        (resample_sum p hp1 k
          (fun y => esComp p U f (merge N x y))).symm
    _ = ∑ y : ι → α, prodMass p y *
        (∑ a : α, p k a *
          esComp p U f
            (Function.update (merge N x y) k a)) := by
        apply Finset.sum_congr rfl
        intro y _
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro a _
        rw [merge_update_outside N k hkN x y a]
        ring
    _ = 0 := by simp [hcenter]

/-- Exact finite linearity of actual product conditional expectation. -/
theorem actual_condExp_sum
    {J : Type} [Fintype J]
    (p : ι → α → ℝ) (N : Finset ι)
    (G : J → (ι → α) → ℝ) (x : ι → α) :
    condExp p N (fun y => ∑ j : J, G j y) x =
      ∑ j : J, condExp p N (G j) x := by
  unfold condExp
  simp only [Finset.mul_sum]
  rw [Finset.sum_comm]

end Nightfall.Observability.ActualESConditionalProjection
