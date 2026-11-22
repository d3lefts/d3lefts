import Mathlib
import ProductBUParityReference

/-!
# Product-sphere parity reference: complete zero-orbit classification

Extends the source-pinned #1024 reference calculation beyond merely
classifying the *first-coordinate signs*: every unit-sphere zero of the
reference map is proved to lie in the single independent-antipode orbit
of the pair of positive first-coordinate axes.

A useful topological proof has TWO independent ingredients:

1. Exact zero-orbit and local Jacobian of the reference map — finite algebra.
2. Invariance modulo 2 of zero-orbit count under equivariant homotopy,
   using relative transversality and compact 1-manifold boundary parity —
   **NOT** proved in this file or the current NIGHTFALL Lean environment.

This module completes (1)'s global zero-set classification only, not
transversality or (2). It does not assume ProductSphereZero.
-/

namespace Nightfall.ProductBUOrbit
open Nightfall.ProductSphereObstruction
open Nightfall.ProductBUParity

/-- The positive first-coordinate axis on the unit sphere in R^(k+1). -/
def axis (k : ℕ) : Fin (k + 1) → ℝ := Fin.cons 1 (fun _ => 0)

theorem axis_unit (k : ℕ) : UnitVec (k + 1) (axis k) := by
  simp [UnitVec, axis, Fin.sum_univ_succ]

theorem axis_tail (k : ℕ) (i : Fin k) : axis k i.succ = 0 := by
  simp [axis]

/-- For each unit vector whose entire tail vanishes, there are exactly
two possibilities (the positive and negative first-coordinate axes). -/
theorem unit_tail_zero_eq_axis_or_neg (k : ℕ)
    (u : Fin (k + 1) → ℝ)
    (hu : UnitVec (k + 1) u)
    (htail : ∀ i : Fin k, u i.succ = 0) :
    u = axis k ∨ u = -axis k := by
  rcases unit_tail_zero_first_sign k u hu htail with h | h
  · left
    funext i
    refine Fin.cases ?_ ?_ i
    · simpa [axis] using h
    · intro j
      simpa [axis] using htail j
  · right
    funext i
    refine Fin.cases ?_ ?_ i
    · simpa [axis] using h
    · intro j
      simpa [axis] using htail j

/-- The reference map's entire zero set is contained in the four
independent signed choices of the two axis vectors. -/
theorem reference_zero_axis_classification (k : ℕ)
    (u v : Fin (k + 1) → ℝ)
    (hu : UnitVec (k + 1) u) (hv : UnitVec (k + 1) v)
    (hU : ∀ i : Fin k, refU k u v i = 0)
    (hV : ∀ i : Fin k, refV k u v i = 0) :
    (u = axis k ∨ u = -axis k) ∧
    (v = axis k ∨ v = -axis k) := by
  exact ⟨unit_tail_zero_eq_axis_or_neg k u hu (fun i => hU i),
    unit_tail_zero_eq_axis_or_neg k v hv (fun i => hV i)⟩

/-- Conversely, both positive axes are a valid zero of the reference map. -/
theorem reference_axis_is_zero (k : ℕ) :
    UnitVec (k + 1) (axis k) ∧
    (∀ i : Fin k, refU k (axis k) (axis k) i = 0) ∧
    (∀ i : Fin k, refV k (axis k) (axis k) i = 0) := by
  refine ⟨axis_unit k, ?_, ?_⟩
  · intro i
    simp [refU, axis_tail]
  · intro i
    simp [refV, axis_tail]

/-- Two vectors in the axis sign class differ by at most an antipode. -/
theorem axis_orbit_unique (k : ℕ) (u w : Fin (k + 1) → ℝ)
    (hu : u = axis k ∨ u = -axis k)
    (hw : w = axis k ∨ w = -axis k) :
    w = u ∨ w = -u := by
  rcases hu with hu | hu
  · rcases hw with hw | hw
    · exact Or.inl (by simp [hu, hw])
    · exact Or.inr (by simp [hu, hw])
  · rcases hw with hw | hw
    · exact Or.inr (by simp [hu, hw])
    · exact Or.inl (by simp [hu, hw])

/-- Stronger than the four sign possibilities alone: any two reference
zeros on S^k x S^k lie in the SAME orbit of independent antipodes.
This is the exact single-orbit reference input used in #1024's
*paper-level* mod-two cobordism proof. -/
theorem reference_zeros_one_orbit (k : ℕ)
    (u v u' v' : Fin (k + 1) → ℝ)
    (hu : UnitVec (k + 1) u) (hv : UnitVec (k + 1) v)
    (hu' : UnitVec (k + 1) u') (hv' : UnitVec (k + 1) v')
    (hU : ∀ i : Fin k, refU k u v i = 0)
    (hV : ∀ i : Fin k, refV k u v i = 0)
    (hU' : ∀ i : Fin k, refU k u' v' i = 0)
    (hV' : ∀ i : Fin k, refV k u' v' i = 0) :
    (u' = u ∨ u' = -u) ∧ (v' = v ∨ v' = -v) := by
  obtain ⟨huA, hvA⟩ :=
    reference_zero_axis_classification k u v hu hv hU hV
  obtain ⟨huA', hvA'⟩ :=
    reference_zero_axis_classification k u' v' hu' hv' hU' hV'
  exact ⟨axis_orbit_unique k u u' huA huA',
    axis_orbit_unique k v v' hvA hvA'⟩

#print axis_unit
#print axioms axis_unit
#print unit_tail_zero_eq_axis_or_neg
#print axioms unit_tail_zero_eq_axis_or_neg
#print reference_zero_axis_classification
#print axioms reference_zero_axis_classification
#print reference_axis_is_zero
#print axioms reference_axis_is_zero
#print axis_orbit_unique
#print axioms axis_orbit_unique
#print reference_zeros_one_orbit
#print axioms reference_zeros_one_orbit

end Nightfall.ProductBUOrbit
