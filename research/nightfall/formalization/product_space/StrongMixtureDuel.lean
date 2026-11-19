import Mathlib

/-!
# Strong mixture simulation: weighted finite posterior-duel and tournament core

No global axioms, sorry, opaque simulator assumption, or probability-model
assumption is introduced. This file proves deterministic arithmetic reductions:
the weighted per-leaf **two-case** error estimates imply a global testing budget,
and an undefeated approximate component produces a 5ε-accurate output.

**Certification scope:** conditional on the two per-leaf inequalities. Neither the
bias-free product mean stability inequality nor strong product simulation is
proved here. Those dependencies must not be suppressed in the paper theorem.

Reference: research/nightfall/strong_simulation_progress/
BIAS_FREE_ROUNDING_AUDIT_20261119.md
-/

namespace Nightfall.StrongMixtureDuel

open Finset

/-- When each leaf is controlled either by a Hellinger-like affinity budget
or by its unnormalized concentration-failure budget, the *global*
two-sided testing error is bounded without assuming small conditional
failure probabilities at every leaf. Both component leaf-mass sums may
be subprobabilities, so this applies when we only test separated leaves.
The test's error masses can be unnormalized. -/
theorem weighted_posterior_duel
    {ι : Type*} (s : Finset ι)
    (p q badP badQ testErr : ι → ℝ)
    (largeGap : ι → Prop) (ε ζ ρP ρQ : ℝ)
    (hε : 0 < ε) (hζ : 0 ≤ ζ)
    (hp : ∑ i ∈ s, p i ≤ 1)
    (hp0 : ∀ i ∈ s, 0 ≤ p i)
    (hq : ∑ i ∈ s, q i ≤ 1)
    (hq0 : ∀ i ∈ s, 0 ≤ q i)
    (hbadP : ∀ i ∈ s, 0 ≤ badP i)
    (hbadQ : ∀ i ∈ s, 0 ≤ badQ i)
    (hlarge : ∀ i ∈ s, largeGap i →
        testErr i ≤ ζ * (p i + q i) / 2)
    (hsmall : ∀ i ∈ s, ¬ largeGap i →
        ε * testErr i ≤ badP i + badQ i)
    (hbudgetP : ∑ i ∈ s, badP i ≤ ρP)
    (hbudgetQ : ∑ i ∈ s, badQ i ≤ ρQ) :
    ε * (∑ i ∈ s, testErr i) ≤ ε * ζ + ρP + ρQ := by
  have hpoint : ∀ i ∈ s,
      ε * testErr i ≤
        (ε * ζ / 2) * (p i + q i) + badP i + badQ i := by
    intro i hi
    by_cases h : largeGap i
    · have hh := hlarge i hi h
      have ht := mul_le_mul_of_nonneg_left hh (le_of_lt hε)
      have hn : 0 ≤ badP i + badQ i :=
        add_nonneg (hbadP i hi) (hbadQ i hi)
      nlinarith
    · have hh := hsmall i hi h
      have hn : 0 ≤ ε * ζ / 2 := div_nonneg (mul_nonneg (le_of_lt hε) hζ) (by norm_num)
      have hpq : 0 ≤ p i + q i :=
        add_nonneg (hp0 i hi) (hq0 i hi)
      nlinarith [mul_nonneg hn hpq]
  have hsum :
      ε * (∑ i ∈ s, testErr i) ≤
        (ε * ζ / 2) * ((∑ i ∈ s, p i) + (∑ i ∈ s, q i)) +
        (∑ i ∈ s, badP i) + (∑ i ∈ s, badQ i) := by
    calc
      ε * (∑ i ∈ s, testErr i) =
          ∑ i ∈ s, ε * testErr i := by rw [Finset.mul_sum]
      _ ≤ ∑ i ∈ s,
          ((ε * ζ / 2) * (p i + q i) + badP i + badQ i) := by
            exact Finset.sum_le_sum hpoint
      _ = (ε * ζ / 2) * ((∑ i ∈ s, p i) + (∑ i ∈ s, q i)) +
          (∑ i ∈ s, badP i) + (∑ i ∈ s, badQ i) := by
            simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
  have hs : (∑ i ∈ s, p i) + (∑ i ∈ s, q i) ≤ (2 : ℝ) := by linarith
  have hc : 0 ≤ ε * ζ / 2 :=
    div_nonneg (mul_nonneg (le_of_lt hε) hζ) (by norm_num)
  have hb := mul_le_mul_of_nonneg_left hs hc
  nlinarith

/-- Given an accurate true-component value and a competing value
within 4ε, their discrepancy from the target is at most 5ε. -/
theorem five_epsilon_from_agreement
    {ι : Type*} (a : ι → ℝ) (θ j : ι) (f ε : ℝ)
    (htrue : |f - a θ| ≤ ε)
    (hagrees : |a θ - a j| ≤ 4 * ε) :
    |f - a j| ≤ 5 * ε := by
  have ht : |f - a j| ≤ |f - a θ| + |a θ - a j| := by
    calc
      |f - a j| = |(f - a θ) + (a θ - a j)| := by ring
      _ ≤ |f - a θ| + |a θ - a j| := abs_add_le _ _
  linarith

/-- The tournament's deterministic correctness argument. Every
candidate at distance ≥4ε from the true candidate is defeated.
Therefore an undefeated candidate is 5ε-accurate whenever the
true candidate's own estimate is ε-accurate. -/
theorem undefeated_is_accurate
    {ι : Type*} (a : ι → ℝ) (defeated : ι → Prop)
    (θ j : ι) (f ε : ℝ)
    (htrue : |f - a θ| ≤ ε)
    (hdefeat : ∀ k, 4 * ε ≤ |a k - a θ| → defeated k)
    (hundefeated : ¬ defeated j) :
    |f - a j| ≤ 5 * ε := by
  have hgap : |a j - a θ| < 4 * ε := by
    by_contra hh
    exact hundefeated (hdefeat j (le_of_not_gt hh))
  have hgap' : |a θ - a j| ≤ 4 * ε :=
    le_of_lt (by simpa [abs_sub_comm] using hgap)
  exact five_epsilon_from_agreement a θ j f ε htrue hgap'

end Nightfall.StrongMixtureDuel
