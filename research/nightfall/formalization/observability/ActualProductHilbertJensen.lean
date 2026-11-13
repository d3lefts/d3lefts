import ActualProductMergeTower

/-!
# Integrated Hilbert norm contraction on the genuine original product law

The source-product merge tower is already strict-kernel-certified on
the active Lean 4.36.0-rc2 Mathlib pin (commit 2dbfdf7, receipt
43502226556). This module upgrades its scalar integrated Jensen
principle to any real normed vector space.

There is NO synthetic independent-neighbor premise, no dimension
factor, no positive-probability atom floor and no source-Q2 energy
hypothesis. The source weights are the exact original product law.

The declaration is a general operator statement, not the terminal
quadratic influence theorem. The actual Efron-Stein greedy-owned
conditional section must be identified separately.
-/

namespace Nightfall.Observability.ActualProductHilbertJensen

open Finset
open Nightfall.Observability.ActualProductMergeTower

variable {ι α : Type*}
  [Fintype ι] [DecidableEq ι] [Fintype α]

/-- Pointwise weighted norm Jensen on the original source's actual
conditional operator. No normalization is needed for this step. -/
theorem actual_product_conditional_vector_norm_jensen
    {H : Type*} [NormedAddCommGroup H] [NormedSpace ℝ H]
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (S : Finset ι) (G : (ι → α) → H)
    (x : ι → α) :
    ‖∑ y : ι → α,
        (originalMass p y) • G (keepSource S x y)‖ ≤
      ∑ y : ι → α,
        originalMass p y * ‖G (keepSource S x y)‖ := by
  classical
  have hm (y : ι → α) : 0 ≤ originalMass p y := by
    unfold originalMass
    exact Finset.prod_nonneg (fun i _ => hp i (y i))
  calc
    ‖∑ y : ι → α, (originalMass p y) •
        G (keepSource S x y)‖ ≤
      ∑ y : ι → α,
        ‖(originalMass p y) • G (keepSource S x y)‖ :=
          norm_sum_le _ _
    _ = ∑ y : ι → α,
        originalMass p y * ‖G (keepSource S x y)‖ := by
          apply Finset.sum_congr rfl
          intro y _
          rw [norm_smul, Real.norm_eq_abs, abs_of_nonneg (hm y)]

/-- The actual product-source conditional expectation is an L1
contraction on H-valued observables, for any finite observation set.
The proof derives the global integration through the certified
original-source merge tower; it does not assume a tower identity.
-/
theorem integrated_source_hilbert_jensen
    {H : Type*} [NormedAddCommGroup H] [NormedSpace ℝ H]
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (S : Finset ι) (G : (ι → α) → H) :
    (∑ x : ι → α, originalMass p x *
      ‖∑ y : ι → α,
        (originalMass p y) • G (keepSource S x y)‖) ≤
      ∑ x : ι → α, originalMass p x * ‖G x‖ := by
  exact integrated_source_jensen p hp hp1 S
    (fun x => ‖∑ y : ι → α,
      (originalMass p y) • G (keepSource S x y)‖)
    (fun x => ‖G x‖)
    (actual_product_conditional_vector_norm_jensen p hp S G)

end Nightfall.Observability.ActualProductHilbertJensen
