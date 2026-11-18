import HeterogeneousAlphabets

/-!
# Correlated block influence: actual finite product-space AA kernel composition

The grouped *block symbols* form an independent finite product with a law q.
We explicitly assume an interface from each block-resampling influence
to a sum of original-site influences. That interface is what a within-block
Poincare/spectral-gap inequality must establish for a concrete correlated
source. No global density bound is needed.

This module composes the real finite heterogeneous product AA theorem
rather than taking it as an uninterpreted scalar hypothesis. It does NOT
yet prove the map from a given original-coordinate joint distribution to
the grouped independent product, nor the block-to-site conditional
variance identity. Those remain distinct formalization gates.
-/

namespace Nightfall.ProductSpace.BlockInfluenceTerminal

open Finset Nightfall.ProductSpace.Heterogeneous

variable {κ σ : Type} [Fintype κ] [DecidableEq κ]
  [Fintype σ] [DecidableEq σ]
  {β : κ → Type} [∀ k, Fintype (β k)] [∀ k, DecidableEq (β k)]

theorem finite_block_aa_of_site_poincare
    (q : ∀ k, β k → ℝ)
    (hq : ∀ k a, 0 ≤ q k a)
    (hq1 : ∀ k, ∑ a, q k a = 1)
    (d : ℕ) (F : (∀ k, β k) → ℝ)
    (hF : ∀ y : ∀ k, β k, (∀ k, 0 < q k (y k)) → |F y| ≤ 1)
    (hdeg : DepDegreeLE F d)
    (blocks : κ → Finset σ) (C : κ → ℝ) (siteInfl : σ → ℝ)
    (M Λ : ℝ) (hM : 0 ≤ M)
    (hsite : ∀ i, 0 ≤ siteInfl i ∧ siteInfl i ≤ M)
    (hC : ∀ k, 0 ≤ C k)
    (hsize : ∀ k, C k * ((blocks k).card : ℝ) ≤ Λ)
    (hPoincare : ∀ k,
        dinfl q F k ≤ C k * ∑ i ∈ blocks k, siteInfl i)
    (hV : 0 < dvar q F) :
    3 * dvar q F ^ 5 ≤
      12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 6 * (Λ * M) ^ 2 := by
  obtain ⟨k, hk⟩ := heterogeneous_influence q hq hq1 d F hF hdeg hV
  have hsum : (∑ i ∈ blocks k, siteInfl i) ≤ ((blocks k).card : ℝ) * M := by
    calc
      (∑ i ∈ blocks k, siteInfl i) ≤ ∑ i ∈ blocks k, M := by
        apply Finset.sum_le_sum
        intro i hi
        exact (hsite i).2
      _ = ((blocks k).card : ℝ) * M := by simp
  have hbound : dinfl q F k ≤ Λ * M := by
    calc
      dinfl q F k ≤ C k * ∑ i ∈ blocks k, siteInfl i := hPoincare k
      _ ≤ C k * (((blocks k).card : ℝ) * M) :=
        mul_le_mul_of_nonneg_left hsum (hC k)
      _ = (C k * ((blocks k).card : ℝ)) * M := by ring
      _ ≤ Λ * M := mul_le_mul_of_nonneg_right (hsize k) hM
  have hdinfl0 : 0 ≤ dinfl q F k := by
    unfold dinfl
    apply Finset.sum_nonneg
    intro y hy
    apply Finset.sum_nonneg
    intro b hb
    apply mul_nonneg
    · apply mul_nonneg
      · unfold dMass
        exact Finset.prod_nonneg (fun j _ => hq j (y j))
      · exact hq k b
    · exact div_nonneg (sq_nonneg _) (by norm_num)
  have hsq : dinfl q F k ^ 2 ≤ (Λ * M) ^ 2 :=
    pow_le_pow_left₀ hdinfl0 hbound 2
  calc
    3 * dvar q F ^ 5 ≤
      12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 6 * dinfl q F k ^ 2 := hk
    _ ≤ 12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 6 * (Λ * M) ^ 2 :=
      mul_le_mul_of_nonneg_left hsq (by positivity)

end Nightfall.ProductSpace.BlockInfluenceTerminal
