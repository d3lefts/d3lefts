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
open Nightfall.ProductSpace.Mixture
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

/-- A noncanonical transcript has zero mass under every observed-source
product law: all unobserved coordinates are fixed to the dummy atom. -/
theorem observedMass_zero_off_canonical
    (S : Finset ι) (a0 : α) (p : ι → α → ℝ) (x : ι → α)
    (hnoncanonical : canonicalObservation S a0 x ≠ x) :
    prodMass (observedLaw S a0 p) x = 0 := by
  classical
  have hex : ∃ i : ι, i ∉ S ∧ x i ≠ a0 := by
    by_contra hnone
    apply hnoncanonical
    funext i
    by_cases hi : i ∈ S
    · simp [canonicalObservation, hi]
    · have hxi : x i = a0 := by
        by_contra hneq
        exact hnone ⟨i, hi, hneq⟩
      simp [canonicalObservation, hi, hxi]
  obtain ⟨i, hi, hneq⟩ := hex
  have hz : observedLaw S a0 p i (x i) = 0 := by
    simp [observedLaw, hi, delta, Ne.symm hneq]
  unfold prodMass
  exact Finset.prod_eq_zero (Finset.mem_univ i) hz

/-- The actual observed-source two-sided failure mass is unchanged
when the likelihood decision rule canonically replaces all unqueried
symbols by a dummy value. This upgrades algebraic overlap into a
decision which provably does not query outside S. -/
theorem canonical_likelihood_error_eq_overlap
    (S : Finset ι) (a0 : α) (p q : ι → α → ℝ) :
    (∑ x : ι → α,
      if chooseP
          (prodMass (observedLaw S a0 p))
          (prodMass (observedLaw S a0 q))
          (canonicalObservation S a0 x)
      then prodMass (observedLaw S a0 q) x
      else prodMass (observedLaw S a0 p) x) =
      (∑ x : ι → α,
        min (prodMass (observedLaw S a0 p) x)
          (prodMass (observedLaw S a0 q) x)) := by
  classical
  let P : (ι → α) → ℝ := prodMass (observedLaw S a0 p)
  let Q : (ι → α) → ℝ := prodMass (observedLaw S a0 q)
  change (∑ x : ι → α,
    if chooseP P Q (canonicalObservation S a0 x) then Q x else P x) =
      ∑ x : ι → α, min (P x) (Q x)
  calc
    (∑ x : ι → α,
      if chooseP P Q (canonicalObservation S a0 x) then Q x else P x) =
        ∑ x : ι → α, if chooseP P Q x then Q x else P x := by
          apply Finset.sum_congr rfl
          intro x hx
          by_cases hc : canonicalObservation S a0 x = x
          · simp [hc]
          · have hP : P x = 0 :=
              observedMass_zero_off_canonical S a0 p x hc
            have hQ : Q x = 0 :=
              observedMass_zero_off_canonical S a0 q x hc
            simp [hP, hQ]
    _ = (∑ x : ι → α, min (P x) (Q x)) :=
      likelihood_two_sided_error_eq_overlap P Q

end Nightfall.MarginFreeLikelihood
