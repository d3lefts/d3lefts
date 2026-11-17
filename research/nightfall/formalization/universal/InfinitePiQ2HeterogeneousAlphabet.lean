import InfinitePiQ2DegreeRetraction
import Mathlib

/-!
# Exact heterogeneous finite-alphabet embedding for original source Q2

The merged finite C105.416 Lean terminal accepts one common finite
alphabet, although actual arbitrary source products may have different
finite cell alphabets in different coordinates.

Take the common tagged-disjoint-union alphabet Σ i, A i.
Encode each coordinate i's source value as a tag i and its native
letter; give all wrong-tag letters original-source probability zero.
This has no atom floor or artificial positive weights.

The diagonal decoder is coordinatewise and therefore preserves all
pointwise third mixed-difference identities and original absolute
bounds. Exact source moment/influence change-of-variables under this
encoding remains a separate terminal obligation.
-/

namespace Nightfall.InfinitePiQ2HeterogeneousAlphabet

open Finset
open Nightfall.InfinitePiQ2DegreeRetraction

variable {ι : Type} [Fintype ι] [DecidableEq ι]
variable (A : ι → Type) [∀ i, Fintype (A i)] [∀ i, Nonempty (A i)]

/-- A single common alphabet containing every original finite alphabet
as a coordinate-tagged summand. -/
abbrev CommonLetter := Sigma A

def embedLetter (i : ι) (a : A i) : CommonLetter A :=
  ⟨i, a⟩

/-- Outside the tagged summand for i, choose any default native value.
Wrong-tag letters have zero mass under i's induced source law. -/
noncomputable def decodeLetter (i : ι) (s : CommonLetter A) : A i :=
  if h : s.1 = i then h ▸ s.2 else Classical.choice (inferInstance : Nonempty (A i))

theorem decode_embed (i : ι) (a : A i) :
    decodeLetter A i (embedLetter A i a) = a := by
  simp [decodeLetter, embedLetter]

noncomputable def taggedMass (p : (i : ι) → A i → ℝ)
    (i : ι) (s : CommonLetter A) : ℝ :=
  if h : s.1 = i then p i (h ▸ s.2) else 0

theorem taggedMass_embed (p : (i : ι) → A i → ℝ)
    (i : ι) (a : A i) :
    taggedMass A p i (embedLetter A i a) = p i a := by
  simp [taggedMass, embedLetter]

theorem taggedMass_wrong_tag (p : (i : ι) → A i → ℝ)
    (i : ι) (s : CommonLetter A) (h : s.1 ≠ i) :
    taggedMass A p i s = 0 := by
  simp [taggedMass, h]

theorem taggedMass_nonneg
    (p : (i : ι) → A i → ℝ) (hp : ∀ i a, 0 ≤ p i a)
    (i : ι) (s : CommonLetter A) :
    0 ≤ taggedMass A p i s := by
  unfold taggedMass
  split_ifs with h
  · exact hp i (h ▸ s.2)
  · exact le_refl _

/-- Each coordinate's tagged source law has exactly total mass 1. -/
theorem taggedMass_normalized
    (p : (i : ι) → A i → ℝ)
    (hp1 : ∀ i, (∑ a : A i, p i a) = 1)
    (i : ι) :
    (∑ s : CommonLetter A, taggedMass A p i s) = 1 := by
  classical
  simp [taggedMass, Fintype.sum_sigma, hp1 i]

/-- Decode every coordinate separately. Changing one tagged input
letter can change only one native source coordinate. -/
noncomputable def decodeWord (w : ι → CommonLetter A) :
    (i : ι) → A i :=
  mapInputs (decodeLetter A) w

/-- An original native source word roundtrips exactly. -/
theorem decode_embed_word
    (x : (i : ι) → A i) :
    decodeWord A (fun i => embedLetter A i (x i)) = x := by
  funext i
  exact decode_embed A i (x i)

/-- The heterogeneous-to-common-alphabet conversion is pointwise
degree-preserving, including every wrong-tag zero-mass source word. -/
theorem degree_two_under_common_alphabet
    (f : ((i : ι) → A i) → ℝ)
    (hf : PointwiseDegreeTwo f) :
    PointwiseDegreeTwo (fun w : ι → CommonLetter A =>
      f (decodeWord A w)) :=
  degree_two_under_coordinate_maps (decodeLetter A) f hf

/-- No loss in the absolute bound during common-alphabet conversion. -/
theorem bound_under_common_alphabet
    (f : ((i : ι) → A i) → ℝ)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B) :
    ∀ w : ι → CommonLetter A, |f (decodeWord A w)| ≤ B :=
  bound_under_coordinate_maps (decodeLetter A) f B hf

end Nightfall.InfinitePiQ2HeterogeneousAlphabet
