import MarginFreeLikelihoodDecision

/-!
# Exact source-to-observation pushforward

The observed source law on a fixed query set S is the exact distribution
of the canonical transcript obtained by asking only the coordinates S
of an original source input. No atom-positivity floor is used.

This removes the last source-semantics ambiguity between an observed
product measure and an actual classical nonadaptive coordinate-query
algorithm. The quantum-oracle and BDST transfer are still separate.
-/

namespace Nightfall.MarginFreeObservationPushforward

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Mixture
open Nightfall.ProductSpace.RowBound
open Nightfall.MarginFreeDisintegration
open Nightfall.MarginFreeLikelihood

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- The Boolean indicator of complete canonical transcript equality
factors into one-coordinate indicators. -/
theorem canonical_eq_indicator_factors
    (S : Finset ι) (a0 : α) (x y : ι → α) :
    (if canonicalObservation S a0 x = y then (1 : ℝ) else 0) =
      ∏ i : ι,
        (if canonicalObservation S a0 x i = y i then (1 : ℝ) else 0) := by
  classical
  by_cases h : canonicalObservation S a0 x = y
  · rw [if_pos h]
    symm
    apply Finset.prod_eq_one
    intro i hi
    exact if_pos (congrFun h i)
  · rw [if_neg h]
    have hex : ∃ i : ι, canonicalObservation S a0 x i ≠ y i := by
      by_contra hnone
      apply h
      funext i
      by_contra hneq
      exact hnone ⟨i, hneq⟩
    obtain ⟨i, hi⟩ := hex
    symm
    apply Finset.prod_eq_zero (Finset.mem_univ i)
    exact if_neg hi

/-- Exact pushforward point-mass equality.
If X is sampled from the *original* finite product law p and we read
only S, replacing unqueried coordinates by a fixed dummy a0, then
the distribution of the resulting transcript Y is observedLaw S a0 p.

All sums are finite and the theorem remains true with zero atoms. -/
theorem observedLaw_eq_canonical_pushforward
    (S : Finset ι) (a0 : α) (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a, p i a = 1) (y : ι → α) :
    (∑ x : ι → α, prodMass p x *
      (if canonicalObservation S a0 x = y then (1 : ℝ) else 0)) =
        prodMass (observedLaw S a0 p) y := by
  let G : ι → α → ℝ := fun i a =>
    if (if i ∈ S then a else a0) = y i then (1 : ℝ) else 0
  have hrow (i : ι) :
      (∑ a : α, p i a * G i a) =
        observedLaw S a0 p i (y i) := by
    by_cases hi : i ∈ S
    · simp [G, observedLaw, hi]
    · by_cases hy : a0 = y i
      · simp [G, observedLaw, hi, hy, hp1 i, delta]
      · simp [G, observedLaw, hi, hy, delta]
  calc
    (∑ x : ι → α, prodMass p x *
      (if canonicalObservation S a0 x = y then (1 : ℝ) else 0)) =
        (∑ x : ι → α, ∏ i : ι, p i (x i) * G i (x i)) := by
          apply Finset.sum_congr rfl
          intro x hx
          rw [canonical_eq_indicator_factors S a0 x y]
          simp only [prodMass]
          rw [← Finset.prod_mul_distrib]
          apply Finset.prod_congr rfl
          intro i hi
          rfl
    _ = (∏ i : ι, ∑ a : α, p i a * G i a) :=
        Nightfall.ProductSpace.RowBound.sum_prod_eq_prod_sum
          (fun i a => p i a * G i a)
    _ = ∏ i : ι, observedLaw S a0 p i (y i) :=
      Finset.prod_congr rfl (fun i _ => hrow i)
    _ = prodMass (observedLaw S a0 p) y := rfl

end Nightfall.MarginFreeObservationPushforward
