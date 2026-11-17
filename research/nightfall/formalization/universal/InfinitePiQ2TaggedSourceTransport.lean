import InfinitePiQ2HeterogeneousAlphabet
import ActualProductMergeTower

/-!
# Exact original finite-source expectation under heterogeneous alphabet tagging

The common tagged alphabet from InfinitePiQ2HeterogeneousAlphabet
introduces zero-mass wrong-tag values. This module proves a weighted
change of variables, *for every finite source observable*, under
literal originalMass finite product laws.

This is the exact original-source transport needed to reuse the
common-alphabet Q2 terminal with heterogeneous finite source labels.
No uniformity, positive atom-floor, normalized source replacement,
or symbolic distributional oracle is assumed.
-/

namespace Nightfall.InfinitePiQ2TaggedSourceTransport

open Finset
open Nightfall.InfinitePiQ2HeterogeneousAlphabet
open Nightfall.InfinitePiQ2DegreeRetraction
open Nightfall.Observability.ActualProductMergeTower

variable {ι : Type} [Fintype ι] [DecidableEq ι]
variable (A : ι → Type) [∀ i, Fintype (A i)] [∀ i, Nonempty (A i)]

/-- Every source coordinate of a correctly tagged product word has its
own coordinate index as its Sigma tag. -/
def CorrectTags (w : ι → CommonLetter A) : Prop :=
  ∀ i, (w i).1 = i

/-- The exact native-to-common-alphabet source embedding. -/
def embedWord (x : (i : ι) → A i) :
    ι → CommonLetter A := fun i => embedLetter A i (x i)

theorem embedWord_correct (x : (i : ι) → A i) :
    CorrectTags A (embedWord A x) := by
  intro i
  rfl

theorem decode_embedWord (x : (i : ι) → A i) :
    decodeWord A (embedWord A x) = x :=
  decode_embed_word A x

/-- A correctly tagged word is entirely recovered from its decoded
native values. No information remains in the redundant common alphabet. -/
theorem embed_decode_correct
    (w : ι → CommonLetter A)
    (hw : CorrectTags A w) :
    embedWord A (decodeWord A w) = w := by
  funext i
  change embedLetter A i (decodeLetter A i (w i)) = w i
  cases hwi : w i with
  | mk j a =>
    have hj : j = i := by
      simpa only [hwi] using hw i
    subst j
    simp [decodeLetter, embedLetter, hwi]

/-- Any wrong tag makes the complete tagged original source weight
EXACTLY zero; no normalization or positivity assumption is needed. -/
theorem originalMass_wrong_tag_zero
    (p : (i : ι) → A i → ℝ)
    (w : ι → CommonLetter A)
    (hw : ¬ CorrectTags A w) :
    originalMass (taggedMass A p) w = 0 := by
  have hh : ∃ i, (w i).1 ≠ i := by
    simpa only [CorrectTags, not_forall] using hw
  obtain ⟨i, hi⟩ := hh
  unfold originalMass
  apply Finset.prod_eq_zero (Finset.mem_univ i)
  exact taggedMass_wrong_tag A p i (w i) hi

/-- On correctly tagged words, product source weights are literally
identical to native heterogeneous product source weights. -/
theorem originalMass_correct_tags
    (p : (i : ι) → A i → ℝ)
    (w : ι → CommonLetter A)
    (hw : CorrectTags A w) :
    originalMass (taggedMass A p) w =
      ∏ i : ι, p i ((decodeWord A w) i) := by
  unfold originalMass
  apply Finset.prod_congr rfl
  intro i _
  have hi := hw i
  simp [taggedMass, decodeWord, decodeLetter, mapInputs, hi]

/-- Exact original source mass of an encoded native word. -/
theorem originalMass_embedWord
    (p : (i : ι) → A i → ℝ)
    (x : (i : ι) → A i) :
    originalMass (taggedMass A p) (embedWord A x) =
      ∏ i : ι, p i (x i) := by
  rw [originalMass_correct_tags A p (embedWord A x) (embedWord_correct A x)]
  rw [decode_embedWord]

/-- All heterogeneous original-source finite weighted expectations are
identical after common-alphabet tagging. Valid for arbitrary weights,
not merely nonnegative normalized probabilities. -/
theorem originalSource_sum_tagged_exact
    (p : (i : ι) → A i → ℝ)
    (H : ((i : ι) → A i) → ℝ) :
    (∑ w : ι → CommonLetter A,
       originalMass (taggedMass A p) w * H (decodeWord A w)) =
      ∑ x : (i : ι) → A i,
        (∏ i : ι, p i (x i)) * H x := by
  classical
  let W := ι → CommonLetter A
  let G : W → ℝ := fun w =>
    originalMass (taggedMass A p) w * H (decodeWord A w)
  have hz (w : W) (hw : ¬ CorrectTags A w) : G w = 0 := by
    simp [G, originalMass_wrong_tag_zero A p w hw]
  have hfilter :
      (∑ w : W, G w) =
      ∑ w ∈ (Finset.univ.filter (CorrectTags A)), G w := by
    simp only [Finset.sum_filter]
    apply Finset.sum_congr rfl
    intro w _
    by_cases hw : CorrectTags A w
    · simp [hw]
    · simp [hw, hz w hw]
  change (∑ w : W, G w) =
    ∑ x : (i : ι) → A i, (∏ i : ι, p i (x i)) * H x
  rw [hfilter]
  refine Finset.sum_bij (fun w hw => decodeWord A w) ?_ ?_ ?_ ?_
  · intro w hw
    exact Finset.mem_univ _
  · intro w hw v hv hEq
    have hwgood : CorrectTags A w := (Finset.mem_filter.mp hw).2
    have hvgood : CorrectTags A v := (Finset.mem_filter.mp hv).2
    calc
      w = embedWord A (decodeWord A w) :=
        (embed_decode_correct A w hwgood).symm
      _ = embedWord A (decodeWord A v) := by rw [hEq]
      _ = v := embed_decode_correct A v hvgood
  · intro x hx
    refine ⟨embedWord A x, ?_, ?_⟩
    · exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, embedWord_correct A x⟩
    · exact decode_embedWord A x
  · intro w hw
    have hgood : CorrectTags A w := (Finset.mem_filter.mp hw).2
    change originalMass (taggedMass A p) w * H (decodeWord A w) =
      (∏ i : ι, p i ((decodeWord A w) i)) * H (decodeWord A w)
    rw [originalMass_correct_tags A p w hgood]

end Nightfall.InfinitePiQ2TaggedSourceTransport
