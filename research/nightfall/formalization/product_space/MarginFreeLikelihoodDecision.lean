import MarginFreeProductDisintegration

/-!
# Concrete optimal likelihood rule for finite observed transcripts

The finite likelihood rule chooses P when its observed point mass exceeds
Q's, and Q otherwise (ties go to Q). Its sum of two-sided classification
error masses is exactly the Bayes overlap, without atom floors.

We also certify that the canonicalized decision accesses only the
chosen observed coordinates. The bounded-K selection of those coordinates
is supplied separately by MarginFreeBoundedK.
-/

namespace Nightfall.MarginFreeLikelihood

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.MarginFreeDisintegration

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- True selects P; false selects Q. In case of a tie select Q. -/
noncomputable def chooseP {Ω : Type*} (P Q : Ω → ℝ) (x : Ω) : Bool :=
  if P x ≤ Q x then false else true

/-- The actual error from the likelihood rule is *exactly* the sum of
pointwise overlaps; no likelihood-ratio denominator is used. -/
theorem likelihood_two_sided_error_eq_overlap
    {Ω : Type*} [Fintype Ω] (P Q : Ω → ℝ) :
    (∑ x : Ω, if chooseP P Q x then Q x else P x) =
      (∑ x : Ω, min (P x) (Q x)) := by
  classical
  apply Finset.sum_congr rfl
  intro x hx
  by_cases h : P x ≤ Q x
  · simp [chooseP, h, min_eq_left h]
  · have hh : Q x ≤ P x := le_of_lt (lt_of_not_ge h)
    simp [chooseP, h, min_eq_right hh]

/-- Put a queried transcript in its canonical representation: coordinates
outside S are deterministic dummy values. -/
noncomputable def canonicalObservation
    (S : Finset ι) (a0 : α) (x : ι → α) : ι → α :=
  fun i => if i ∈ S then x i else a0

theorem canonicalObservation_agrees
    (S : Finset ι) (a0 : α) (x y : ι → α)
    (hxy : ∀ i ∈ S, x i = y i) :
    canonicalObservation S a0 x = canonicalObservation S a0 y := by
  funext i
  by_cases hi : i ∈ S
  · simp [canonicalObservation, hi, hxy i hi]
  · simp [canonicalObservation, hi]

/-- The likelihood classifier, when run on canonical transcripts,
queries no coordinates outside S. -/
theorem likelihood_observed_locality
    (S : Finset ι) (a0 : α)
    (p q : ι → α → ℝ) (x y : ι → α)
    (hxy : ∀ i ∈ S, x i = y i) :
    chooseP
      (prodMass (observedLaw S a0 p))
      (prodMass (observedLaw S a0 q))
      (canonicalObservation S a0 x) =
    chooseP
      (prodMass (observedLaw S a0 p))
      (prodMass (observedLaw S a0 q))
      (canonicalObservation S a0 y) := by
  rw [canonicalObservation_agrees S a0 x y hxy]

end Nightfall.MarginFreeLikelihood
