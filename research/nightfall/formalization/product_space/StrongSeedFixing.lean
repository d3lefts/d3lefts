import Mathlib

/-!
# Finite random-tape fixing for strong quantum-to-classical reductions

If a randomized simulator is a finite mixture of deterministic decision
trees sharing the same worst-case depth, averaging its source failure
mass yields a deterministic tree with no larger failure mass.

This module proves the real-valued averaging/selection step only. It
does not assume a quantum oracle, a valid conditional-seed decoder,
or the BDST simulation theorem. No implementation of random seed
sampling is hidden inside the conclusion.
-/

namespace Nightfall.StrongSimulation.SeedFixing

open Finset

/-- When the mean of finitely many real failure masses is bounded,
at least one deterministic seed has no larger failure mass. -/
theorem exists_seed_le_average
    {S : Type*} [Fintype S] [Nonempty S]
    (failure : S → ℝ) (δ : ℝ)
    (hmean : (∑ s : S, failure s) ≤ (Fintype.card S : ℝ) * δ) :
    ∃ s : S, failure s ≤ δ := by
  classical
  by_contra hnone
  push_neg at hnone
  have hpositive : 0 < (∑ s : S, (failure s - δ)) := by
    apply Finset.sum_pos
    · intro s hs
      exact le_of_lt (sub_pos.mpr (hnone s))
    · let s₀ : S := Classical.choice inferInstance
      exact ⟨s₀, Finset.mem_univ _, sub_pos.mpr (hnone s₀)⟩
  have hidentity :
      (∑ s : S, failure s - δ) =
        (∑ s : S, failure s) - (Fintype.card S : ℝ) * δ := by
    simp only [Finset.sum_sub_distrib, Finset.sum_const,
      Finset.card_univ, nsmul_eq_mul]
  rw [hidentity] at hpositive
  linarith

/-- A direct finite-law formulation. The seed-indexed approximants may
depend on the complete input. A seed exists whose original-source
failure mass is no larger than the joint seed-averaged failure mass. -/
theorem exists_deterministic_seed
    {S Ω : Type*} [Fintype S] [Nonempty S] [Fintype Ω]
    (mass : Ω → ℝ) (bad : S → Ω → Prop)
    (δ : ℝ)
    (hjoint :
      (∑ s : S, ∑ x : Ω, mass x *
        (if bad s x then (1 : ℝ) else 0)) ≤
          (Fintype.card S : ℝ) * δ) :
    ∃ s : S,
      (∑ x : Ω, mass x *
        (if bad s x then (1 : ℝ) else 0)) ≤ δ := by
  classical
  exact exists_seed_le_average
    (fun s => ∑ x : Ω, mass x *
      (if bad s x then (1 : ℝ) else 0))
    δ hjoint


/-- Exact weighted seed fixing. This is the version required for
conditional decoders with arbitrary real transition probabilities:
the seed distribution need not be uniform or rational. -/
theorem exists_weighted_seed
    {S : Type*} [Fintype S]
    (weight failure : S → ℝ) (δ : ℝ)
    (hw : ∀ s, 0 ≤ weight s)
    (hsum : (∑ s : S, weight s) = 1)
    (haverage : (∑ s : S, weight s * failure s) ≤ δ) :
    ∃ s : S, 0 < weight s ∧ failure s ≤ δ := by
  classical
  by_contra hnone
  push_neg at hnone
  have hex : ∃ s : S, 0 < weight s := by
    by_contra hnot
    push_neg at hnot
    have hz : ∀ s, weight s = 0 := by
      intro s
      exact le_antisymm (hnot s) (hw s)
    have hzero : (∑ s : S, weight s) = 0 := by simp [hz]
    linarith
  have hterm (s : S) : 0 ≤ weight s * (failure s - δ) := by
    by_cases hzero : weight s = 0
    · simp [hzero]
    · have hs : 0 < weight s := lt_of_le_of_ne (hw s) (Ne.symm hzero)
      exact mul_nonneg (hw s) (le_of_lt (sub_pos.mpr (hnone s hs)))
  have hpositive : 0 < (∑ s : S, weight s * (failure s - δ)) := by
    apply Finset.sum_pos
    · intro s hs
      exact hterm s
    · obtain ⟨s, hs⟩ := hex
      exact ⟨s, Finset.mem_univ s,
        mul_pos hs (sub_pos.mpr (hnone s hs))⟩
  have hidentity : (∑ s : S, weight s * (failure s - δ)) =
      (∑ s : S, weight s * failure s) - δ := by
    calc
      (∑ s : S, weight s * (failure s - δ)) =
          ∑ s : S, (weight s * failure s - weight s * δ) := by
            apply Finset.sum_congr rfl
            intro s hs
            ring
      _ = (∑ s : S, weight s * failure s) -
          (∑ s : S, weight s * δ) := Finset.sum_sub_distrib
      _ = (∑ s : S, weight s * failure s) - δ := by
            rw [← Finset.sum_mul, hsum, one_mul]
  rw [hidentity] at hpositive
  linarith

/-- A finite real-valued random kernel can be represented exactly
as a weighted mixture over deterministic maps from inputs to outputs.
The normalization holds even when the transition probabilities are
irrational or have zeros. -/
noncomputable def deterministicMapWeight
    {A U : Type*} [Fintype A] [Fintype U]
    (kernel : A → U → ℝ) (seed : A → U) : ℝ :=
  ∏ a : A, kernel a (seed a)

theorem deterministicMapWeights_nonneg
    {A U : Type*} [Fintype A] [Fintype U]
    (kernel : A → U → ℝ) (hk : ∀ a u, 0 ≤ kernel a u) :
    ∀ seed : A → U, 0 ≤ deterministicMapWeight kernel seed := by
  intro seed
  unfold deterministicMapWeight
  exact Finset.prod_nonneg (fun a ha => hk a (seed a))

theorem deterministicMapWeights_sum_one
    {A U : Type*} [Fintype A] [Fintype U]
    (kernel : A → U → ℝ)
    (hk : ∀ a, (∑ u : U, kernel a u) = 1) :
    (∑ seed : A → U, deterministicMapWeight kernel seed) = 1 := by
  unfold deterministicMapWeight
  calc
    (∑ seed : A → U, ∏ a : A, kernel a (seed a)) =
        ∏ a : A, ∑ u : U, kernel a u :=
          (Fintype.prod_sum (fun a (u : U) => kernel a u)).symm
    _ = 1 := by simp [hk]


/-- Marginal reconstruction for the weighted deterministic-map
representation. Choosing a finite random function before observing
the input reproduces the original kernel at every input atom. -/
theorem deterministicMapWeights_marginal
    {A U : Type*} [Fintype A] [Fintype U]
    (kernel : A → U → ℝ)
    (hk : ∀ a, (∑ u : U, kernel a u) = 1)
    (a : A) (u : U) :
    (∑ seed : A → U,
      if seed a = u then deterministicMapWeight kernel seed else 0) =
      kernel a u := by
  classical
  let F : A → U → ℝ := fun b v =>
    if b = a then (if v = u then kernel b v else 0) else kernel b v
  have hseed (seed : A → U) :
      (∏ b : A, F b (seed b)) =
        (if seed a = u then deterministicMapWeight kernel seed else 0) := by
    by_cases h : seed a = u
    · simp only [if_pos h]
      unfold deterministicMapWeight
      apply Finset.prod_congr rfl
      intro b hb
      by_cases he : b = a
      · subst b
        simp [F, h]
      · simp [F, he]
    · have hz : F a (seed a) = 0 := by simp [F, h]
      have hp : (∏ b : A, F b (seed b)) = 0 :=
        Finset.prod_eq_zero (Finset.mem_univ a) hz
      simp [h, hp]
  have hrow (b : A) :
      (∑ v : U, F b v) =
        (if b = a then kernel a u else 1) := by
    by_cases he : b = a
    · subst b
      simp [F]
    · simp [F, he, hk b]
  calc
    (∑ seed : A → U,
      if seed a = u then deterministicMapWeight kernel seed else 0) =
        ∑ seed : A → U, ∏ b : A, F b (seed b) := by
          apply Finset.sum_congr rfl
          intro seed hs
          exact (hseed seed).symm
    _ = ∏ b : A, ∑ v : U, F b v :=
      (Fintype.prod_sum F).symm
    _ = ∏ b : A, if b = a then kernel a u else 1 :=
      Finset.prod_congr rfl (fun b hb => hrow b)
    _ = kernel a u := by
      simp


end Nightfall.StrongSimulation.SeedFixing
