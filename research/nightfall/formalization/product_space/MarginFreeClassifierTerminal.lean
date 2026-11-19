import MarginFreeBoundedK
import MarginFreeLikelihoodDecision

/-!
# Actual-source bounded-K component classifier

The finite classifier construction is now terminal at the *source*
level: for any two known finite product laws satisfying the degree,
concentration and positive center-margin assumptions, it constructs
a deterministic Boolean decision from at most K observed coordinate
values and proves its actual two-sided source classification error.

This theorem does not include quantum-oracle transfer, uniform-bit
BDST or the final M-component tournament.
-/

namespace Nightfall.MarginFreeClassifier

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.RowBound
open Nightfall.MarginFreeBoundedK
open Nightfall.MarginFreeDisintegration
open Nightfall.MarginFreeLikelihood

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- The classifier is computed from the canonicalized observed word:
true selects P, false selects Q. It is invariant under changing any
of the coordinates outside the chosen set A. -/
theorem bounded_K_actual_source_classifier
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
      (∑ x : ι → α,
        if chooseP (prodMass (observedLaw A a0 p))
            (prodMass (observedLaw A a0 q))
            (canonicalObservation A a0 x)
        then prodMass (observedLaw A a0 q) x
        else prodMass (observedLaw A a0 p) x)
        ≤ max ζ ((ρP + ρQ) / (|u - v| - 3 * ε)) := by
  obtain ⟨A, hsize, hoverlap⟩ := bounded_K_component_overlap
    a0 p q hp0 hq0 hp1 hq1 γ ζ ε hγ hζ hε
    K hK d hd f hf hdegree hbudget
    u v ρP ρQ hu hv hsep hfailP hfailQ
  refine ⟨A, hsize, ?_, ?_⟩
  · intro x y hxy
    exact likelihood_observed_locality A a0 p q x y hxy
  · rw [canonical_likelihood_error_eq_overlap A a0 p q]
    exact hoverlap

end Nightfall.MarginFreeClassifier
