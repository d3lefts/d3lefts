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
        cases h : C y <;> simp [h]
    _ = ∑ y : ι → α, min (P y) (Q y) := by
      exact likelihood_two_sided_error_eq_overlap P Q

/-- ACTUAL INPUT-SOURCE BOUNDED-K CLASSIFIER TERMINAL.

For known finite P,Q product components satisfying the explicit
concentration/margin/interaction-degree hypotheses, there exists
a queried coordinate set of size at most K. The canonical likelihood
decision reads *only those coordinates* and its genuine total source
classification error under P plus under Q is bounded by the same
Hellinger-or-low-TV budget.

No quantum circuit or BDST theorem is hidden in the assumptions. -/
theorem bounded_K_original_source_classifier
    (a0 : α) (p q : ι → α → ℝ)
    (hp0 : ∀ i a, 0 ≤ p i a) (hq0 : ∀ i a, 0 ≤ q i a)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (hq1 : ∀ i, ∑ a, q i a = 1)
    (γ ζ ε : ℝ) (hγ : 0 < γ) (hζ : 0 < ζ) (hε : 0 ≤ ε)
    (K : ℕ)
    (hK : Real.log (1 / ζ) ≤ (K : ℝ) * (γ ^ 2 / 2))
    (d : ℕ) (hd : 1 ≤ d) (f : (ι → α) → ℝ)
    (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hdegree : HasProdDegreeLE f d)
    (hbudget : 16 * (d : ℝ) ^ 2 * γ ≤ ε)
    (u v ρP ρQ : ℝ)
    (hu : 0 ≤ u ∧ u ≤ 1) (hv : 0 ≤ v ∧ v ≤ 1)
    (hsep : 3 * ε < |u - v|)
    (hfailP : ∑ y ∈ (Finset.univ : Finset (ι → α)).filter
      (fun y => ε < |f y - u|), prodMass p y ≤ ρP)
    (hfailQ : ∑ y ∈ (Finset.univ : Finset (ι → α)).filter
      (fun y => ε < |f y - v|), prodMass q y ≤ ρQ) :
    ∃ A : Finset ι, A.card ≤ K ∧
      (∀ x y : ι → α, (∀ i ∈ A, x i = y i) →
        chooseP (prodMass (observedLaw A a0 p))
          (prodMass (observedLaw A a0 q))
          (canonicalObservation A a0 x) =
        chooseP (prodMass (observedLaw A a0 p))
          (prodMass (observedLaw A a0 q))
          (canonicalObservation A a0 y)) ∧
      ((∑ x : ι → α, prodMass p x *
        (if chooseP (prodMass (observedLaw A a0 p))
            (prodMass (observedLaw A a0 q))
            (canonicalObservation A a0 x) then (0 : ℝ) else 1)) +
      (∑ x : ι → α, prodMass q x *
        (if chooseP (prodMass (observedLaw A a0 p))
            (prodMass (observedLaw A a0 q))
            (canonicalObservation A a0 x) then (1 : ℝ) else 0)))
        ≤ max ζ ((ρP + ρQ) / (|u - v| - 3 * ε)) := by
  obtain ⟨A, hsize, hlocal, hErrObs⟩ :=
    bounded_K_actual_source_classifier a0 p q
      hp0 hq0 hp1 hq1 γ ζ ε hγ hζ hε K hK
      d hd f hf hdegree hbudget
      u v ρP ρQ hu hv hsep hfailP hfailQ
  refine ⟨A, hsize, hlocal, ?_⟩
  rw [original_likelihood_error_eq_overlap A a0 p q hp1 hq1]
  rw [canonical_likelihood_error_eq_overlap A a0 p q] at hErrObs
  exact hErrObs

end Nightfall.MarginFreeOriginalClassifier
