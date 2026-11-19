import Mathlib
import ComponentIdentification
import MarginFreeCertificate
import LatentProductInterpolationDegree

/-!
# Finite likelihood testing and confidence transfer for margin-free components

All statements are finite algebraic theorems; no bounded-degree analytic
claim is smuggled into assumptions. This certifies the likelihood-rule choice
for known, possibly unnormalized measures, and a finite first-moment tail bound.

Missing from a full theorem: Markov/Bernstein low-degree expectation
stability, tensorization of finite-alphabet Bhattacharyya affinity, and
coherent quantum-oracle simulation.
-/

namespace Nightfall.MarginFreeFiniteTests

open Finset

/-- The likelihood test's two-sided Bayes loss is the overlap of two
(possibly unnormalized) nonnegative weight functions. Ties can go either way. -/
theorem likelihood_cost_eq_overlap {ι : Type*} (s : Finset ι) (p q : ι → ℝ) :
    (∑ i ∈ s, if p i ≤ q i then p i else q i) =
      ∑ i ∈ s, min (p i) (q i) := by
  apply Finset.sum_congr rfl
  intro i _
  by_cases h : p i ≤ q i
  · simp [h, min_eq_left h]
  · have h' : q i ≤ p i := le_of_lt (lt_of_not_ge h)
    simp [h, min_eq_right h']

/-- No arbitrary deterministic test can improve its two-sided loss below
the min-overlap bound, including when transcript priors are unequal. -/
theorem overlap_le_any_test {ι : Type*} (s : Finset ι)
    (p q : ι → ℝ) (chooseP : ι → Bool) :
    (∑ i ∈ s, min (p i) (q i)) ≤
      ∑ i ∈ s, if chooseP i then q i else p i := by
  apply Finset.sum_le_sum
  intro i _
  cases h : chooseP i with
  | false => simpa [h] using (min_le_left (p i) (q i))
  | true => simpa [h] using (min_le_right (p i) (q i))

/-- Finite Markov transfer: when a weighted nonnegative loss has expectation
at most τ η, its mass above threshold τ is at most η. No assumption that
the total mass is one, so this also works on conditional transcript leaves. -/
theorem weighted_markov_tail {ι : Type*} (s : Finset ι)
    (p loss : ι → ℝ) (τ η : ℝ)
    (hτ : 0 < τ)
    (hp : ∀ i ∈ s, 0 ≤ p i)
    (hloss : ∀ i ∈ s, 0 ≤ loss i)
    (hmoment : (∑ i ∈ s, p i * loss i) ≤ τ * η) :
    (∑ i ∈ s.filter (fun i => τ ≤ loss i), p i) ≤ η := by
  have hb :
      τ * (∑ i ∈ s.filter (fun i => τ ≤ loss i), p i) ≤
        ∑ i ∈ s, p i * loss i := by
    rw [Finset.sum_filter, Finset.mul_sum]
    apply Finset.sum_le_sum
    intro i hi
    by_cases h : τ ≤ loss i
    · simp only [if_pos h]
      have := mul_le_mul_of_nonneg_left h (hp i hi)
      nlinarith
    · simp only [if_neg h, mul_zero]
      exact mul_nonneg (hp i hi) (hloss i hi)
  nlinarith

end Nightfall.MarginFreeFiniteTests
