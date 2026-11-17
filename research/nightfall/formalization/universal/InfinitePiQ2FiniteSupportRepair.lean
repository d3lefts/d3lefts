import InfinitePiQ2DegreeRetraction
import Mathlib

/-!
# Exact finite zero-atom support repair for source Q2

The finite original-source Q2 terminal requires pointwise degree <= 2
and a pointwise global absolute bound, including zero-probability words.
On a finite product law each coordinate has a positive-mass letter.
Coordinatewise retraction of all zero-mass letters to such a letter
preserves every positive-support source word and converts a quadratic
function bounded *on support* into a globally bounded, pointwise
quadratic finite table.

This does not by itself identify source L2 variance or influence before
and after the retraction; their zero-mass cancellation is the next gate.
-/

namespace Nightfall.InfinitePiQ2FiniteSupportRepair

open Finset
open Nightfall.InfinitePiQ2DegreeRetraction

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
    [Fintype α] [DecidableEq α]

/-- Any finite real-valued normalized original law has a positive
coordinate letter. Zero-probability letters are allowed. -/
theorem exists_positive_original_letter
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (i : ι) :
    ∃ a : α, 0 < p i a := by
  by_contra hn
  have hnonpos : ∀ a : α, p i a ≤ 0 := by
    intro a
    exact le_of_not_gt (fun h => hn ⟨a,h⟩)
  have hsum : (∑ a : α, p i a) ≤ 0 :=
    Finset.sum_nonpos (fun a _ => hnonpos a)
  linarith [hp1 i]

/-- A fixed positive-probability default, chosen once per source
coordinate. Choice is harmless because no value is returned to a client. -/
noncomputable def positiveDefault
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (i : ι) : α :=
  Classical.choose (exists_positive_original_letter p hp1 i)

theorem positiveDefault_pos
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (i : ι) :
    0 < p i (positiveDefault p hp1 i) := by
  exact Classical.choose_spec (exists_positive_original_letter p hp1 i)

/-- Keep each positive-mass letter intact and replace every null or
nonpositive letter by a positive default from the original source. -/
noncomputable def retractToPositive
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (i : ι) (a : α) : α :=
  if 0 < p i a then a else positiveDefault p hp1 i

theorem retractToPositive_pos
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (i : ι) (a : α) :
    0 < p i (retractToPositive p hp1 i a) := by
  unfold retractToPositive
  split_ifs with h
  · exact h
  · exact positiveDefault_pos p hp1 i

theorem retractToPositive_eq_of_pos
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (i : ι) (a : α) (ha : 0 < p i a) :
    retractToPositive p hp1 i a = a := by
  simp [retractToPositive, ha]

def SourceSupported (p : ι → α → ℝ)
    (x : ι → α) : Prop :=
  ∀ i, 0 < p i (x i)

/-- Pointwise vanishing of all mixed third differences whenever
the base word AND all six replacement letters lie on the genuine
positive support. -/
def SupportedDegreeTwo
    (p : ι → α → ℝ)
    (f : (ι → α) → ℝ) : Prop :=
  ∀ (i j k : ι) (_ : i ≠ j) (_ : i ≠ k) (_ : j ≠ k)
    (a a' b b' c c' : α) (x : ι → α),
    SourceSupported p x →
    0 < p i a → 0 < p i a' →
    0 < p j b → 0 < p j b' →
    0 < p k c → 0 < p k c' →
    delta i a a' (delta j b b' (delta k c c' f)) x = 0

/-- Every retracted word is supported at every source coordinate. -/
theorem mapped_word_supported
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (x : ι → α) :
    SourceSupported p (mapInputs (retractToPositive p hp1) x) := by
  intro i
  exact retractToPositive_pos p hp1 i (x i)

/-- On a genuine positive-support word the retraction is the identity,
including all coordinates simultaneously. -/
theorem mapped_word_eq_of_supported
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (x : ι → α) (hx : SourceSupported p x) :
    mapInputs (retractToPositive p hp1) x = x := by
  funext i
  exact retractToPositive_eq_of_pos p hp1 i (x i) (hx i)

/-- Zero-cell repair converts degree two ON genuine source support
into the exact full pointwise degree-two predicate of the finite Q2
terminal theorem, even at words with null source mass. -/
theorem supported_degree_two_retraction
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hf : SupportedDegreeTwo p f) :
    PointwiseDegreeTwo
      (fun x => f (mapInputs (retractToPositive p hp1) x)) := by
  intro i j k hij hik hjk a a' b b' c c' x
  rw [delta_three_comp]
  exact hf i j k hij hik hjk
    (retractToPositive p hp1 i a)
    (retractToPositive p hp1 i a')
    (retractToPositive p hp1 j b)
    (retractToPositive p hp1 j b')
    (retractToPositive p hp1 k c)
    (retractToPositive p hp1 k c')
    (mapInputs (retractToPositive p hp1) x)
    (mapped_word_supported p hp1 x)
    (retractToPositive_pos p hp1 i a)
    (retractToPositive_pos p hp1 i a')
    (retractToPositive_pos p hp1 j b)
    (retractToPositive_pos p hp1 j b')
    (retractToPositive_pos p hp1 k c)
    (retractToPositive_pos p hp1 k c')

/-- A source-observable bound known only on positive-probability
configurations becomes a bound on ALL finite words after retraction. -/
theorem supported_bound_retraction
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (B : ℝ)
    (hf : ∀ x, SourceSupported p x → |f x| ≤ B) :
    ∀ x, |f (mapInputs (retractToPositive p hp1) x)| ≤ B := by
  intro x
  exact hf _ (mapped_word_supported p hp1 x)

end Nightfall.InfinitePiQ2FiniteSupportRepair
