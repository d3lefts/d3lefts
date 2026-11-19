import Mathlib

/-!
# Conditional latent-product transfer: weighted decision-tree accounting

This file formalizes *finite arithmetic implications* used by the
component-identification/tournament proof. It does NOT formalize:
(1) Bernstein polynomial interpolation,
(2) the product-law Hellinger tensorization interface,
(3) the quantum coherent encoding and BDST simulator,
or (4) the construction of the likelihood-ratio test itself.

Every analytic or probabilistic obligation appears as a Lean hypothesis.
This is a partial certificate, not an unconditional simulation theorem.

Paper: research/nightfall/strong_simulation_progress/
  STRONG_TRANSFER_CLOSURE_20261119.md
-/

namespace Nightfall.ComponentIdentification.WeightedTournament

open Finset BigOperators

/-- The correct unnormalized Bayes overlap inequality. In particular, the
weights p and q can incorporate *unequal* preliminary-transcript priors.
The wrong factorization min(priorP, priorQ) * conditionalOverlap is not used. -/
theorem weighted_overlap_from_pointwise_cost
    {Ω : Type*} [Fintype Ω]
    (p q badP badQ : Ω → ℝ) (Δ : ℝ)
    (hp : ∀ x, 0 ≤ p x) (hq : ∀ x, 0 ≤ q x)
    (hbadP : ∀ x, 0 ≤ badP x) (hbadQ : ∀ x, 0 ≤ badQ x)
    (hcost : ∀ x, Δ ≤ badP x + badQ x) :
    Δ * (∑ x : Ω, min (p x) (q x)) ≤
      (∑ x : Ω, p x * badP x) + (∑ x : Ω, q x * badQ x) := by
  have hterm : ∀ x : Ω,
      Δ * min (p x) (q x) ≤
        p x * badP x + q x * badQ x := by
    intro x
    have hm : 0 ≤ min (p x) (q x) := le_min (hp x) (hq x)
    calc
      Δ * min (p x) (q x) = min (p x) (q x) * Δ := by ring
      _ ≤ min (p x) (q x) * (badP x + badQ x) :=
        mul_le_mul_of_nonneg_left (hcost x) hm
      _ = min (p x) (q x) * badP x + min (p x) (q x) * badQ x := by ring
      _ ≤ p x * badP x + q x * badQ x := by
        apply add_le_add
        · exact mul_le_mul_of_nonneg_right (min_le_left _ _) (hbadP x)
        · exact mul_le_mul_of_nonneg_right (min_le_right _ _) (hbadQ x)
  calc
    Δ * (∑ x : Ω, min (p x) (q x))
        = ∑ x : Ω, Δ * min (p x) (q x) := by rw [Finset.mul_sum]
    _ ≤ ∑ x : Ω, (p x * badP x + q x * badQ x) :=
      Finset.sum_le_sum (fun x _ => hterm x)
    _ = (∑ x : Ω, p x * badP x) +
          (∑ x : Ω, q x * badQ x) := Finset.sum_add_distrib

/-- Conditional likelihood-ratio testing, with arbitrary unequal masses. -/
theorem weighted_overlap_le_failure_div
    {Ω : Type*} [Fintype Ω]
    (p q badP badQ : Ω → ℝ) (Δ budgetP budgetQ : ℝ)
    (hp : ∀ x, 0 ≤ p x) (hq : ∀ x, 0 ≤ q x)
    (hbadP : ∀ x, 0 ≤ badP x) (hbadQ : ∀ x, 0 ≤ badQ x)
    (hΔ : 0 < Δ)
    (hcost : ∀ x, Δ ≤ badP x + badQ x)
    (hbudgetP : (∑ x : Ω, p x * badP x) ≤ budgetP)
    (hbudgetQ : (∑ x : Ω, q x * badQ x) ≤ budgetQ) :
    (∑ x : Ω, min (p x) (q x)) ≤
      (budgetP + budgetQ) / Δ := by
  apply (le_div_iff₀ hΔ).2
  have h := weighted_overlap_from_pointwise_cost
    p q badP badQ Δ hp hq hbadP hbadQ hcost
  nlinarith

/-- Abstract conditional pair-test budget. The "small" branch is controlled
by weighted conditional failure costs; the "large" branch is controlled by
a nonnegative affinity factor with total affinity at most one. All excluded
transcripts have zero test error. This theorem does not assume that all
conditional leaf failure probabilities are individually small. -/
theorem pair_error_budget_scaled
    {Λ : Type*} [Fintype Λ]
    (err badP badQ affinity : Λ → ℝ)
    (decisive small : Λ → Prop) (ε η : ℝ)
    (hε : 0 < ε) (hη : 0 ≤ η)
    (hpos : ∀ l, 0 ≤ badP l ∧ 0 ≤ badQ l ∧ 0 ≤ affinity l)
    (hzero : ∀ l, ¬ decisive l → err l = 0)
    (hsmall : ∀ l, decisive l → small l →
       ε * err l ≤ badP l + badQ l)
    (hbig : ∀ l, decisive l → ¬ small l →
       err l ≤ η * affinity l)
    (hbadP : (∑ l : Λ, badP l) ≤ η)
    (hbadQ : (∑ l : Λ, badQ l) ≤ η)
    (haff : (∑ l : Λ, affinity l) ≤ 1) :
    ε * (∑ l : Λ, err l) ≤ η * (2 + ε) := by
  have hpoint : ∀ l : Λ,
      ε * err l ≤ badP l + badQ l + ε * η * affinity l := by
    intro l
    have hn := hpos l
    have hab : 0 ≤ badP l + badQ l := add_nonneg hn.1 hn.2.1
    have hac : 0 ≤ ε * η * affinity l :=
      mul_nonneg (mul_nonneg (le_of_lt hε) hη) hn.2.2
    by_cases hd : decisive l
    · by_cases hs : small l
      · linarith [hsmall l hd hs]
      · have h := mul_le_mul_of_nonneg_left (hbig l hd hs) (le_of_lt hε)
        nlinarith
    · rw [hzero l hd]
      nlinarith
  have hsum :
      ε * (∑ l : Λ, err l) ≤
      (∑ l : Λ, badP l) + (∑ l : Λ, badQ l) +
        ε * η * (∑ l : Λ, affinity l) := by
    calc
      ε * (∑ l : Λ, err l) = ∑ l : Λ, ε * err l := by rw [Finset.mul_sum]
      _ ≤ ∑ l : Λ, (badP l + badQ l + ε * η * affinity l) :=
        Finset.sum_le_sum (fun l _ => hpoint l)
      _ = (∑ l : Λ, badP l) + (∑ l : Λ, badQ l) +
            ε * η * (∑ l : Λ, affinity l) := by
          simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
  have hbound : ε * η * (∑ l : Λ, affinity l) ≤ ε * η := by
    have h := mul_le_mul_of_nonneg_left haff
      (mul_nonneg (le_of_lt hε) hη)
    nlinarith
  nlinarith

/-- The same bound in the paper's requested pairwise error units. -/
theorem pair_error_budget
    {Λ : Type*} [Fintype Λ]
    (err badP badQ affinity : Λ → ℝ)
    (decisive small : Λ → Prop) (ε η : ℝ)
    (hε : 0 < ε) (hη : 0 ≤ η)
    (hpos : ∀ l, 0 ≤ badP l ∧ 0 ≤ badQ l ∧ 0 ≤ affinity l)
    (hzero : ∀ l, ¬ decisive l → err l = 0)
    (hsmall : ∀ l, decisive l → small l →
       ε * err l ≤ badP l + badQ l)
    (hbig : ∀ l, decisive l → ¬ small l →
       err l ≤ η * affinity l)
    (hbadP : (∑ l : Λ, badP l) ≤ η)
    (hbadQ : (∑ l : Λ, badQ l) ≤ η)
    (haff : (∑ l : Λ, affinity l) ≤ 1) :
    (∑ l : Λ, err l) ≤ η * (1 + 2 / ε) := by
  have h := pair_error_budget_scaled err badP badQ affinity
    decisive small ε η hε hη hpos hzero hsmall hbig hbadP hbadQ haff
  have hnonzero : ε ≠ 0 := ne_of_gt hε
  apply (le_div_iff₀ hε).2
  calc
    (∑ l : Λ, err l) * ε = ε * (∑ l : Λ, err l) := by ring
    _ ≤ η * (2 + ε) := h
    _ = (η * (1 + 2 / ε)) * ε := by
      field_simp
      ring

/-- Error bookkeeping for the event-polynomial rounding argument.
All probabilistic statements are intentionally passed as hypotheses. -/
theorem strong_rounding_four_eta
    (failureP failureRounded expectedP expectedRounded η : ℝ)
    (hevent : failureP ≤ expectedP + η)
    (hinterp : expectedP ≤ expectedRounded + η)
    (hsandwich : expectedRounded ≤ failureRounded + η)
    (huniform : failureRounded ≤ η) :
    failureP ≤ 4 * η := by
  linarith

/-- Output correctness of an undefeated near-component. The decisive-pair
logic supplying hclose is separate from this scalar geometric conclusion. -/
theorem undefeated_output_accuracy
    (f trueOutput selectedOutput ε : ℝ)
    (hcorrect : |f - trueOutput| ≤ ε)
    (hclose : |trueOutput - selectedOutput| < 4 * ε) :
    |f - selectedOutput| < 5 * ε := by
  have ht := abs_add_le (f - trueOutput) (trueOutput - selectedOutput)
  have hid : f - selectedOutput =
      (f - trueOutput) + (trueOutput - selectedOutput) := by ring
  rw [hid]
  linarith

end Nightfall.ComponentIdentification.WeightedTournament
