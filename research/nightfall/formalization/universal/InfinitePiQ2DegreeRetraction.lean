import Mathlib

/-!
# Pointwise degree-two closure under arbitrary coordinatewise retractions

Finite-cell quantization, zero-cell repair, and heterogeneous-to-common
alphabet embeddings all act coordinatewise. This module proves once and
for all that such maps preserve vanishing of every threefold mixed
difference and preserve a global pointwise bound.

All result statements apply to arbitrary dependent coordinate alphabets
and arbitrary index types. There is no probability or countability
hypothesis, and no unverified compiler claim.
-/

namespace Nightfall.InfinitePiQ2DegreeRetraction

universe u v w

variable {ι : Type u} [DecidableEq ι]
variable {A : ι → Type v} {B : ι → Type w}

def mapInputs (φ : ∀ i, A i → B i)
    (x : (i : ι) → A i) : (i : ι) → B i :=
  fun i => φ i (x i)

theorem mapInputs_update
    (φ : ∀ i, A i → B i) (i : ι) (a : A i)
    (x : (j : ι) → A j) :
    mapInputs φ (Function.update x i a) =
      Function.update (mapInputs φ x) i (φ i a) := by
  funext j
  by_cases h : j = i
  · subst j
    simp [mapInputs]
  · simp [mapInputs, Function.update_of_ne h]

noncomputable def delta
    (i : ι) (a b : A i) (f : ((j : ι) → A j) → ℝ)
    (x : (j : ι) → A j) : ℝ :=
  f (Function.update x i a) - f (Function.update x i b)

theorem delta_comp
    (φ : ∀ i, A i → B i) (i : ι) (a b : A i)
    (f : ((j : ι) → B j) → ℝ)
    (x : (j : ι) → A j) :
    delta i a b (fun z => f (mapInputs φ z)) x =
      delta i (φ i a) (φ i b) f (mapInputs φ x) := by
  simp only [delta, mapInputs_update]

theorem delta_three_comp
    (φ : ∀ i, A i → B i)
    (i j k : ι)
    (a a' : A i) (b b' : A j) (c c' : A k)
    (f : ((m : ι) → B m) → ℝ)
    (x : (m : ι) → A m) :
    delta i a a' (delta j b b' (delta k c c'
      (fun z => f (mapInputs φ z)))) x =
    delta i (φ i a) (φ i a')
      (delta j (φ j b) (φ j b')
        (delta k (φ k c) (φ k c') f))
      (mapInputs φ x) := by
  simp only [delta, mapInputs_update]

/-- Pointwise Efron-Stein interaction degree at most two: every
mixed third coordinate difference vanishes, even at null configurations. -/
def PointwiseDegreeTwo (f : ((i : ι) → B i) → ℝ) : Prop :=
  ∀ (i j k : ι) (_ : i ≠ j) (_ : i ≠ k) (_ : j ≠ k)
    (a a' : B i) (b b' : B j) (c c' : B k)
    (x : (m : ι) → B m),
    delta i a a' (delta j b b' (delta k c c' f)) x = 0

/-- An arbitrary coordinatewise measurable-cell sampling or zero-cell
retraction preserves pointwise degree ≤ 2 with no support assumptions. -/
theorem degree_two_under_coordinate_maps
    (φ : ∀ i, A i → B i)
    (f : ((i : ι) → B i) → ℝ)
    (hf : PointwiseDegreeTwo f) :
    PointwiseDegreeTwo (fun x => f (mapInputs φ x)) := by
  intro i j k hij hik hjk a a' b b' c c' x
  rw [delta_three_comp]
  exact hf i j k hij hik hjk
    (φ i a) (φ i a') (φ j b) (φ j b')
    (φ k c) (φ k c') (mapInputs φ x)

/-- A pointwise bound survives arbitrary coordinatewise retraction. -/
theorem bound_under_coordinate_maps
    (φ : ∀ i, A i → B i)
    (f : ((i : ι) → B i) → ℝ)
    (M : ℝ) (hM : ∀ x, |f x| ≤ M) :
    ∀ x, |f (mapInputs φ x)| ≤ M :=
  fun x => hM _

end Nightfall.InfinitePiQ2DegreeRetraction
