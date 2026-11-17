import InfinitePiQ2DegreeRetraction
import Mathlib

/-!
# Finite-coordinate anchored restriction of a genuinely arbitrary product

Fixing all source coordinates outside a finite set at an arbitrary anchor
produces a finite-coordinate observable. This theorem proves that both its
global bound and all mixed third-difference identities are preserved
pointwise, including for null source configurations. The anchor can later
be chosen by a probabilistic L² approximation argument; no assumption on
the cardinality of the full index set or the coordinate alphabets occurs.

This is one algebraic bridge, NOT a full infinite-product Q2 certificate.
-/

namespace Nightfall.InfinitePiQ2AnchoredRestriction

open Nightfall.InfinitePiQ2DegreeRetraction

universe u v
variable {ι : Type u} [DecidableEq ι]
variable {A : ι → Type v}

/-- Extend a finite-coordinate word using a fixed ambient product anchor. -/
def embedAt (F : Finset ι) (base : (i : ι) → A i)
    (x : (i : F) → A i) : (i : ι) → A i :=
  fun i => if h : i ∈ F then x ⟨i, h⟩ else base i

/-- Updating a retained coordinate before or after embedding agrees. -/
theorem embedAt_update (F : Finset ι) (base : (i : ι) → A i)
    (x : (i : F) → A i) (i : F) (a : A i) :
    embedAt F base (Function.update x i a) =
      Function.update (embedAt F base x) (i : ι) a := by
  funext j
  by_cases hji : j = (i : ι)
  · subst j
    simp [embedAt]
  · by_cases hjF : j ∈ F
    · have hsub : (⟨j, hjF⟩ : F) ≠ i := by
        intro h
        exact hji (congrArg Subtype.val h)
      simp [embedAt, hjF, Function.update_of_ne hji,
        Function.update_of_ne hsub]
    · simp [embedAt, hjF, Function.update_of_ne hji]

/-- The first mixed difference on a finite restriction is the ambient
source-coordinate difference evaluated at the anchored configuration. -/
theorem delta_embedAt (F : Finset ι) (base : (i : ι) → A i)
    (f : ((i : ι) → A i) → ℝ)
    (x : (j : F) → A j) (i : F) (a b : A i) :
    delta i a b (fun z => f (embedAt F base z)) x =
      delta (i : ι) a b f (embedAt F base x) := by
  simp only [delta, embedAt_update]

/-- Three disjoint finite-coordinate differences commute with anchoring.
The identity is pointwise, not merely almost-everywhere. -/
theorem delta_three_embedAt (F : Finset ι)
    (base : (i : ι) → A i)
    (f : ((i : ι) → A i) → ℝ)
    (x : (m : F) → A m)
    (i j k : F)
    (a a' : A i) (b b' : A j) (c c' : A k) :
    delta i a a' (delta j b b' (delta k c c'
      (fun z => f (embedAt F base z)))) x =
      delta (i : ι) a a' (delta (j : ι) b b'
        (delta (k : ι) c c' f)) (embedAt F base x) := by
  simp only [delta, embedAt_update]

/-- A pointwise degree-two observable remains degree two after finite
coordinate restriction with ANY fixed external product anchor. -/
theorem degree_two_under_anchor
    (F : Finset ι) (base : (i : ι) → A i)
    (f : ((i : ι) → A i) → ℝ)
    (hf : PointwiseDegreeTwo f) :
    PointwiseDegreeTwo (fun x : (i : F) → A i =>
      f (embedAt F base x)) := by
  intro i j k hij hik hjk a a' b b' c c' x
  rw [delta_three_embedAt]
  exact hf (i : ι) (j : ι) (k : ι)
    (fun h => hij (Subtype.ext h))
    (fun h => hik (Subtype.ext h))
    (fun h => hjk (Subtype.ext h))
    a a' b b' c c' (embedAt F base x)

/-- The global original source bound survives every finite anchored
restriction, without a positive-mass, finiteness or symmetry premise. -/
theorem bound_under_anchor
    (F : Finset ι) (base : (i : ι) → A i)
    (f : ((i : ι) → A i) → ℝ)
    (B : ℝ) (hf : ∀ x, |f x| ≤ B) :
    ∀ x : (i : F) → A i, |f (embedAt F base x)| ≤ B :=
  fun x => hf _

end Nightfall.InfinitePiQ2AnchoredRestriction
