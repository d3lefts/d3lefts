import ComponentIdentificationWeightedTournament

/-!
# Likelihood-ratio classifier: exact unnormalized Bayes error

This is a finite kernel proof of the *actual deterministic test*, not merely an
upper bound on abstract overlaps. It works for arbitrary nonnegative masses,
including zeros and unequal transcript priors. The analytic work required to
bound the resulting overlap is separately stated as the cell-cost hypothesis.

The conditional weighted overlap proof is imported from
ComponentIdentificationWeightedTournament.lean (same pinned compilation).
-/

namespace Nightfall.LatentLikelihoodRatio

open Finset

/-- If p(x) < q(x), choose Q and incur P error p(x).
Otherwise choose P and incur Q error q(x). The combined error
is exactly the overlap, even for subprobability masses. -/
theorem likelihood_two_sided_error_eq_overlap
    {Ω : Type*} [Fintype Ω] (p q : Ω → ℝ) :
    (∑ x : Ω, if p x < q x then p x else 0) +
    (∑ x : Ω, if p x < q x then 0 else q x) =
      ∑ x : Ω, min (p x) (q x) := by
  classical
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro x hx
  by_cases h : p x < q x
  · simp [h, min_eq_left (le_of_lt h)]
  · have hqp : q x ≤ p x := le_of_not_gt h
    simp [h, min_eq_right hqp]

/-- A genuinely constructed deterministic likelihood-ratio test inherits
the weighted failure-budget bound. No equal transcript-weight assumption
is used, and no positive atom floor is needed. -/
theorem likelihood_error_le_weighted_budget
    {Ω : Type*} [Fintype Ω]
    (p q badP badQ : Ω → ℝ) (gap budgetP budgetQ : ℝ)
    (hp : ∀ x, 0 ≤ p x) (hq : ∀ x, 0 ≤ q x)
    (hbadP : ∀ x, 0 ≤ badP x) (hbadQ : ∀ x, 0 ≤ badQ x)
    (hgap : 0 < gap)
    (hcost : ∀ x, gap ≤ badP x + badQ x)
    (hbudgetP : (∑ x : Ω, p x * badP x) ≤ budgetP)
    (hbudgetQ : (∑ x : Ω, q x * badQ x) ≤ budgetQ) :
    (∑ x : Ω, if p x < q x then p x else 0) +
    (∑ x : Ω, if p x < q x then 0 else q x) ≤
      (budgetP + budgetQ) / gap := by
  classical
  rw [likelihood_two_sided_error_eq_overlap]
  exact Nightfall.ComponentIdentification.WeightedTournament.weighted_overlap_le_failure_div
    p q badP badQ gap budgetP budgetQ hp hq hbadP hbadQ hgap hcost hbudgetP hbudgetQ

end Nightfall.LatentLikelihoodRatio
