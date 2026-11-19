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

end Nightfall.StrongSimulation.SeedFixing
