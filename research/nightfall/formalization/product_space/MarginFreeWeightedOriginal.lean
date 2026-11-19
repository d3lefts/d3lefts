import MarginFreeOriginalClassifier

/-!
# Weighted likelihood classifier on the *original* finite product sources

In a frozen multi-component simulation transcript, source components can have
different transcript weights. The correct likelihood decision compares
wP * P(observed word) with wQ * Q(observed word), not the unweighted
P/Q likelihood. This module gives the exact source-input semantics of
that weighted decision, with zero atoms and arbitrary nonnegative weights.

No artificial per-transcript concentration hypothesis is used here.
This is a sourced finite probability identity and queried-coordinate
locality theorem, to be paired with the bounded-K weighted overlap budget.
-/

namespace Nightfall.MarginFreeWeightedOriginal

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.MarginFreeLikelihood
open Nightfall.MarginFreeDisintegration
open Nightfall.MarginFreeObservationPushforward
open Nightfall.MarginFreeOriginalClassifier

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- True means choose P. Ties deterministically go to Q. -/
noncomputable def choosePWeighted {Ω : Type*}
    (wP wQ : ℝ) (P Q : Ω → ℝ) (y : Ω) : Bool :=
  if wP * P y ≤ wQ * Q y then false else true

/-- The unequal-weight Bayes likelihood rule has error exactly equal
to the total pointwise weighted overlap, without division by atoms. -/
theorem weighted_likelihood_error_eq_overlap
    {Ω : Type*} [Fintype Ω]
    (wP wQ : ℝ) (P Q : Ω → ℝ) :
    (∑ y : Ω, if choosePWeighted wP wQ P Q y
      then wQ * Q y else wP * P y) =
    (∑ y : Ω, min (wP * P y) (wQ * Q y)) := by
  classical
  apply Finset.sum_congr rfl
  intro y hy
  by_cases h : wP * P y ≤ wQ * Q y
  · simp [choosePWeighted, h, min_eq_left h]
  · have hh : wQ * Q y ≤ wP * P y := le_of_lt (lt_of_not_ge h)
    simp [choosePWeighted, h, min_eq_right hh]

/-- The actual weighted decision accesses only S, even if the full input
contains symbols not present in one of the source supports. -/
theorem weighted_original_locality
    (S : Finset ι) (a0 : α) (p q : ι → α → ℝ)
    (wP wQ : ℝ) (x y : ι → α)
    (hxy : ∀ i ∈ S, x i = y i) :
    choosePWeighted wP wQ
      (prodMass (observedLaw S a0 p))
      (prodMass (observedLaw S a0 q))
      (canonicalObservation S a0 x) =
    choosePWeighted wP wQ
      (prodMass (observedLaw S a0 p))
      (prodMass (observedLaw S a0 q))
      (canonicalObservation S a0 y) := by
  rw [canonicalObservation_agrees S a0 x y hxy]

/-- Exact two-source *original input* weighted Bayes error.
The two weights are arbitrary reals (hence also include unequal or
zero posterior masses); the equality is algebraic. In applications
they are nonnegative transcript masses.

The left-hand side is the sum of the true-source errors of the
deterministic queried-coordinate likelihood rule, not an assumed
or idealized observed-source risk. -/
theorem weighted_original_likelihood_error_eq_overlap
    (S : Finset ι) (a0 : α)
    (p q : ι → α → ℝ)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (hq1 : ∀ i, ∑ a, q i a = 1)
    (wP wQ : ℝ) :
    wP * (∑ x : ι → α, prodMass p x *
      (if choosePWeighted wP wQ
          (prodMass (observedLaw S a0 p))
          (prodMass (observedLaw S a0 q))
          (canonicalObservation S a0 x) then (0 : ℝ) else 1)) +
    wQ * (∑ x : ι → α, prodMass q x *
      (if choosePWeighted wP wQ
          (prodMass (observedLaw S a0 p))
          (prodMass (observedLaw S a0 q))
          (canonicalObservation S a0 x) then (1 : ℝ) else 0)) =
    (∑ y : ι → α,
      min (wP * prodMass (observedLaw S a0 p) y)
          (wQ * prodMass (observedLaw S a0 q) y)) := by
  classical
  let P : (ι → α) → ℝ := prodMass (observedLaw S a0 p)
  let Q : (ι → α) → ℝ := prodMass (observedLaw S a0 q)
  let C : (ι → α) → Bool := choosePWeighted wP wQ P Q
  have hP := source_canonical_expectation S a0 p hp1
    (fun y => if C y then (0 : ℝ) else 1)
  have hQ := source_canonical_expectation S a0 q hq1
    (fun y => if C y then (1 : ℝ) else 0)
  change
    wP * (∑ x : ι → α, prodMass p x *
      (if C (canonicalObservation S a0 x) then (0 : ℝ) else 1)) +
    wQ * (∑ x : ι → α, prodMass q x *
      (if C (canonicalObservation S a0 x) then (1 : ℝ) else 0)) =
    ∑ y : ι → α, min (wP * P y) (wQ * Q y)
  rw [hP, hQ]
  calc
    wP * (∑ y : ι → α, P y * (if C y then (0 : ℝ) else 1)) +
    wQ * (∑ y : ι → α, Q y * (if C y then (1 : ℝ) else 0)) =
      ∑ y : ι → α,
        (if C y then wQ * Q y else wP * P y) := by
          rw [Finset.mul_sum, Finset.mul_sum,
            ← Finset.sum_add_distrib]
          apply Finset.sum_congr rfl
          intro y hy
          by_cases h : C y <;> simp [h] <;> ring
    _ = ∑ y : ι → α, min (wP * P y) (wQ * Q y) :=
      weighted_likelihood_error_eq_overlap wP wQ P Q

#print axioms Nightfall.MarginFreeWeightedOriginal.weighted_likelihood_error_eq_overlap
#print axioms Nightfall.MarginFreeWeightedOriginal.weighted_original_locality
#print axioms Nightfall.MarginFreeWeightedOriginal.weighted_original_likelihood_error_eq_overlap

end Nightfall.MarginFreeWeightedOriginal
