import Mathlib
import InfiniteFieldSignedStep
import InfiniteFieldFixedLower
import InfiniteFieldFixedUpper
import InfiniteFieldAdaptiveLower
import InfiniteFieldLegalUpper

/-!
# Infinite-field squared-linear phase retrieval: source-exact terminal

Certifies, using the exact causal squared-linear oracle:
* n+1 adaptive measurements suffice for all signals modulo global sign;
* every adaptive strategy with at most n readings fails, n>=2;
* 2n-1 fixed measurements suffice;
* every fixed strategy with fewer than 2n-1 readings fails.

The closed result is over every infinite field where 2 != 0. No noise or
computational-efficiency guarantee is claimed. No prior-art novelty claim.
-/

namespace Nightfall.InfiniteFieldPhase.Terminal
noncomputable section
variable {K : Type*} [Field K] [Infinite K] [NeZero (2 : K)]

theorem adaptive_lower_all_short
    {k m : ℕ} (hk : 1 ≤ k) (hm : m ≤ k+1)
    (policy : List K → Fin (k+1) → K) :
    ∃ x y : Fin (k+1) → K,
      x ≠ y ∧ x ≠ -y ∧
      AdaptiveLower.history policy x m = AdaptiveLower.history policy y m := by
  rcases lt_or_eq_of_le hm with hlt | heq
  · exact AdaptiveLower.short_adaptive_strategy_fails hlt policy
  · subst m
    exact AdaptiveLower.critical_adaptive_strategy_fails hk policy

theorem fixed_lower_all_short
    {k m : ℕ} (hk : 1 ≤ k)
    (rows : Fin m → Fin (k+1) → K)
    (hsep : FixedLower.fixedSquareSeparates rows) :
    2 * (k+1) - 1 ≤ m := by
  exact FixedLower.same_oracle_nonadaptive_lower
    (by omega) rows (NeZero.ne _) hsep

theorem exists_fixed_upper (k : ℕ) :
    ∃ rows : Fin (2 * (k+1) - 1) → Fin (k+1) → K,
      FixedLower.fixedSquareSeparates rows := by
  obtain ⟨rows, hr⟩ :=
    FixedUpper.exists_fixed_design (K := K) (k+1) (by omega)
  refine ⟨rows, ?_⟩
  intro x y hread
  apply hr x y
  intro i
  exact hread i

/-- Complete source-level phase retrieval terminal. The first component
is the actual adaptively chosen n+1 query transcript injection. The
second excludes every causal strategy of <=n queries; the third/fourth
are the fixed upper construction and lower obstruction. -/
theorem infinite_field_phase_retrieval_terminal (k : ℕ) (hk : 1 ≤ k) :
    (∀ x y : Fin (k+1) → K,
        adaptiveTranscript x = adaptiveTranscript y →
        x = y ∨ x = -y) ∧
    (∀ (m : ℕ), m ≤ k+1 →
      ∀ (policy : List K → Fin (k+1) → K),
        ∃ x y : Fin (k+1) → K,
          x ≠ y ∧ x ≠ -y ∧
          AdaptiveLower.history policy x m =
          AdaptiveLower.history policy y m) ∧
    (∃ rows : Fin (2 * (k+1) - 1) → Fin (k+1) → K,
        FixedLower.fixedSquareSeparates rows) ∧
    (∀ (m : ℕ) (rows : Fin m → Fin (k+1) → K),
        FixedLower.fixedSquareSeparates rows →
        2 * (k+1) - 1 ≤ m) := by
  refine ⟨?_, ?_, exists_fixed_upper k, ?_⟩
  · intro x y h
    exact adaptiveTranscript_injective_mod_sign x y h
  · intro m hm policy
    exact adaptive_lower_all_short hk hm policy
  · intro m rows hsep
    exact fixed_lower_all_short hk rows hsep

/-- The concrete n+1-query adaptive design is a legal history-only policy. -/
theorem exists_causal_adaptive_upper (k : ℕ) :
    ∃ policy : List K → Fin (k+1) → K,
      ∀ x y : Fin (k+1) → K,
        AdaptiveLower.history policy x ((k+1)+1) =
          AdaptiveLower.history policy y ((k+1)+1) →
        x = y ∨ x = -y := by
  refine ⟨LegalUpper.legalPolicy (n := k+1), ?_⟩
  intro x y h
  exact LegalUpper.legal_history_injective_mod_sign x y h

/-- Exact optimal query counts in ONE causally modeled squared-linear oracle.
For n=k+1≥2, n+1 adaptive readings are necessary and sufficient;
2n-1 fixed readings are necessary and sufficient. -/
theorem infinite_field_phase_retrieval_causal_terminal (k : ℕ) (hk : 1 ≤ k) :
    (∃ policy : List K → Fin (k+1) → K,
      ∀ x y : Fin (k+1) → K,
        AdaptiveLower.history policy x ((k+1)+1) =
          AdaptiveLower.history policy y ((k+1)+1) →
        x = y ∨ x = -y) ∧
    (∀ (m : ℕ), m ≤ k+1 →
      ∀ (policy : List K → Fin (k+1) → K),
        ∃ x y : Fin (k+1) → K,
          x ≠ y ∧ x ≠ -y ∧
          AdaptiveLower.history policy x m =
          AdaptiveLower.history policy y m) ∧
    (∃ rows : Fin (2 * (k+1) - 1) → Fin (k+1) → K,
        FixedLower.fixedSquareSeparates rows) ∧
    (∀ (m : ℕ) (rows : Fin m → Fin (k+1) → K),
        FixedLower.fixedSquareSeparates rows →
        2 * (k+1) - 1 ≤ m) := by
  refine ⟨exists_causal_adaptive_upper k, ?_, exists_fixed_upper k, ?_⟩
  · intro m hm policy
    exact adaptive_lower_all_short hk hm policy
  · intro m rows hsep
    exact fixed_lower_all_short hk rows hsep

#print axioms Nightfall.InfiniteFieldPhase.Terminal.exists_causal_adaptive_upper
#print axioms Nightfall.InfiniteFieldPhase.Terminal.infinite_field_phase_retrieval_causal_terminal

#print axioms Nightfall.InfiniteFieldPhase.Terminal.adaptive_lower_all_short
#print axioms Nightfall.InfiniteFieldPhase.Terminal.fixed_lower_all_short
#print axioms Nightfall.InfiniteFieldPhase.Terminal.exists_fixed_upper
#print axioms Nightfall.InfiniteFieldPhase.Terminal.infinite_field_phase_retrieval_terminal

end
end Nightfall.InfiniteFieldPhase.Terminal
