import MarginFreeObservationPushforward
import MarginFreeClassifierTerminal

/-!
# The queried-coordinate likelihood classifier on original source inputs

This completes the finite probabilistic semantics: the actual input X
is drawn from the original product law, the classifier reads only A,
canonically fills unqueried symbols with a fixed dummy, then applies
the likelihood rule. Its TWO-SIDED original-source error equals the
Bayes overlap of the observed transcript distributions.

Separate gates: bounded-K decision certificate (already another module),
conditional M-component tournament, quantum coherent oracle, BDST.
-/

namespace Nightfall.MarginFreeOriginalClassifier

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.RowBound
open Nightfall.MarginFreeLikelihood
open Nightfall.MarginFreeDisintegration
open Nightfall.MarginFreeObservationPushforward
open Nightfall.MarginFreeClassifier

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Integrating an arbitrary real-valued statistic of the transcript
under the original source law is exactly integration under its
observed-source pushforward. -/
theorem source_canonical_expectation
    (S : Finset ι) (a0 : α)
    (p : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (g : (ι → α) → ℝ) :
    (∑ x : ι → α, prodMass p x *
      g (canonicalObservation S a0 x)) =
    (∑ y : ι → α, prodMass (observedLaw S a0 p) y * g y) := by
  classical
  have hsingle (x : ι → α) :
      (∑ y : ι → α,
        (if canonicalObservation S a0 x = y then (1 : ℝ) else 0) * g y) =
          g (canonicalObservation S a0 x) := by
    simp
  calc
    (∑ x : ι → α, prodMass p x *
      g (canonicalObservation S a0 x)) =
      ∑ x : ι → α, prodMass p x *
        (∑ y : ι → α,
          (if canonicalObservation S a0 x = y then (1 : ℝ) else 0) * g y) := by
            apply Finset.sum_congr rfl
            intro x hx
            rw [hsingle]
    _ = ∑ x : ι → α, ∑ y : ι → α,
        (prodMass p x *
          (if canonicalObservation S a0 x = y then (1 : ℝ) else 0)) * g y := by
          apply Finset.sum_congr rfl
          intro x hx
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro y hy
          ring
    _ = ∑ y : ι → α, ∑ x : ι → α,
        (prodMass p x *
          (if canonicalObservation S a0 x = y then (1 : ℝ) else 0)) * g y :=
            Finset.sum_comm
    _ = ∑ y : ι → α,
        (∑ x : ι → α,
          prodMass p x *
          (if canonicalObservation S a0 x = y then (1 : ℝ) else 0)) * g y := by
            apply Finset.sum_congr rfl
            intro y hy
            rw [Finset.sum_mul]
    _ = (∑ y : ι → α,
        prodMass (observedLaw S a0 p) y * g y) := by
          apply Finset.sum_congr rfl
          intro y hy
          rw [observedLaw_eq_canonical_pushforward S a0 p hp1 y]

/-- EXACT ORIGINAL-SOURCE ERROR, not a hypothetical transcript error.

Choosing P on a queried word is an error under Q, and choosing Q
is an error under P. The combined two-sided original-source error is
exactly the Bayes overlap of their observed transcript laws. -/
theorem original_likelihood_error_eq_overlap
    (S : Finset ι) (a0 : α) (p q : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (hq1 : ∀ i, ∑ a, q i a = 1) :
    (∑ x : ι → α, prodMass p x *
      (if chooseP (prodMass (observedLaw S a0 p))
          (prodMass (observedLaw S a0 q))
          (canonicalObservation S a0 x) then (0 : ℝ) else 1)) +
    (∑ x : ι → α, prodMass q x *
      (if chooseP (prodMass (observedLaw S a0 p))
          (prodMass (observedLaw S a0 q))
          (canonicalObservation S a0 x) then (1 : ℝ) else 0)) =
      (∑ y : ι → α,
        min (prodMass (observedLaw S a0 p) y)
          (prodMass (observedLaw S a0 q) y)) := by
  classical
  let P := prodMass (observedLaw S a0 p)
  let Q := prodMass (observedLaw S a0 q)
  let C := chooseP P Q
  have hP := source_canonical_expectation S a0 p hp1
    (fun y => if C y then (0 : ℝ) else 1)
  have hQ := source_canonical_expectation S a0 q hq1
    (fun y => if C y then (1 : ℝ) else 0)
  change
    (∑ x : ι → α, prodMass p x *
        (if C (canonicalObservation S a0 x) then (0 : ℝ) else 1)) +
    (∑ x : ι → α, prodMass q x *
        (if C (canonicalObservation S a0 x) then (1 : ℝ) else 0)) =
      ∑ y : ι → α, min (P y) (Q y)
  rw [hP, hQ]
  calc
    (∑ y : ι → α, P y * (if C y then (0 : ℝ) else 1)) +
      (∑ y : ι → α, Q y * (if C y then (1 : ℝ) else 0)) =
      ∑ y : ι → α, (if C y then Q y else P y) := by
        rw [← Finset.sum_add_distrib]
        apply Finset.sum_congr rfl
        intro y hy
        by_cases h : C y <;> simp [h]
    _ = ∑ y : ι → α, min (P y) (Q y) := by
      exact likelihood_two_sided_error_eq_overlap P Q

end Nightfall.MarginFreeOriginalClassifier
