import Mathlib

/-!
# Arbitrary-index maximum influence: no countability hypothesis

This is the final order-theoretic step of Wright's product-space influence
manuscript, once the Efron–Stein energy bound is given:
  forall finite S, sum_{i in S} influence(i) <= d * variance.
For every positive threshold, only finitely many coordinates can exceed it.
Consequently, any positive supremum of influences is an actual maximum,
even on an uncountable index type.

The theorem does not manufacture the Efron–Stein energy premise; it proves
the abstract arbitrary-index attainment conclusion with no hidden finite
index assumption.
-/

namespace Nightfall.Wright.ArbitraryIndex

open Finset

theorem finite_positive_superlevel
    {J : Type*} (I : J → ℝ) (C δ : ℝ)
    (hδ : 0 < δ)
    (hcap : ∀ s : Finset J, (∑ i ∈ s, I i) ≤ C) :
    {i : J | δ ≤ I i}.Finite := by
  classical
  by_contra hfinite
  have hinf : ({i : J | δ ≤ I i}).Infinite := hfinite
  obtain ⟨n, hn⟩ := exists_nat_gt (C / δ)
  obtain ⟨s, hs, hcard⟩ := hinf.exists_subset_card_eq n
  have hsum : (s.card : ℝ) * δ ≤ (∑ i ∈ s, I i) := by
    calc
      (s.card : ℝ) * δ = ∑ i ∈ s, δ := by simp
      _ ≤ ∑ i ∈ s, I i := by
        apply Finset.sum_le_sum
        intro i hi
        exact hs hi
  have hnC : C < (n : ℝ) * δ := (div_lt_iff₀ hδ).mp hn
  rw [hcard] at hsum
  have hupper := hcap s
  linarith

/-- Positive influence plus a uniform bound on all finite partial sums
forces a maximizing coordinate, without a countable index set. -/
theorem arbitrary_index_maximum_attained
    {J : Type*} (I : J → ℝ) (C : ℝ)
    (hcap : ∀ s : Finset J, (∑ i ∈ s, I i) ≤ C)
    (j₀ : J) (hj₀ : 0 < I j₀) :
    ∃ j : J, ∀ i : J, I i ≤ I j := by
  classical
  let T : Set J := {i | I j₀ ≤ I i}
  have hT : T.Finite := finite_positive_superlevel I C (I j₀) hj₀ hcap
  let S : Finset J := hT.toFinset
  have hj₀mem : j₀ ∈ S := by
    simpa [S, T] using (show j₀ ∈ T from le_refl _)
  have hSn : S.Nonempty := ⟨j₀, hj₀mem⟩
  obtain ⟨j, hjS, hmax⟩ := Finset.exists_max_image S I hSn
  have hjT : I j₀ ≤ I j := by
    have h : j ∈ T := by simpa [S] using hjS
    exact h
  refine ⟨j, ?_⟩
  intro i
  by_cases hi : I j₀ ≤ I i
  · have hiS : i ∈ S := by simpa [S, T] using hi
    exact hmax i hiS
  · have hlt : I i < I j₀ := lt_of_not_ge hi
    exact (le_of_lt hlt).trans hjT

end Nightfall.Wright.ArbitraryIndex
