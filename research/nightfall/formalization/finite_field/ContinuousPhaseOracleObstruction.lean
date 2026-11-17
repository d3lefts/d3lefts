import Mathlib
import ContinuousPhaseCrossing

/-!
# Continuous last-row policies cannot close a three-coordinate square fiber

This is an unconditional, real-valued, exact squared-linear obstruction.
For a coordinate-first protocol, the final row sees only the three
previous coordinate-square observations. Restrict signals to the
support-changing path (t, 1-t, 1), 0 ≤ t ≤ 1.

Rows need only be continuous ALONG this path; no continuity assumption
is placed on an arbitrary reconstruction algorithm.
-/

namespace Nightfall.ContinuousPhaseObstruction

/-- The last quadratic reading, when its coefficient functions along a
history path are a, b, c and the third signal coordinate is fixed to 1. -/
def lastSquare (a b c : ℝ → ℝ) (t x y : ℝ) : ℝ :=
  (a t * x + b t * y + c t)^2

/-- Necessary condition for universal recovery after three coordinate-square
queries, restricted to signals (x,y,1). Global sign cannot identify
two such signals unless the first two coordinates agree. -/
def SeparatesThreeSquareFiber (a b c : ℝ → ℝ) : Prop :=
  ∀ t : ℝ, 0 ≤ t → t ≤ 1 →
    ∀ x y x' y' : ℝ,
      x^2 = t^2 → y^2 = (1-t)^2 →
      (x')^2 = t^2 → (y')^2 = (1-t)^2 →
      lastSquare a b c t x y = lastSquare a b c t x' y' →
      x = x' ∧ y = y'

/-- A continuous last-row policy cannot separate all support and sign
patterns after reading three coordinate squares. This is stronger than
the projective-space embedding obstruction in dimension 3 because it
uses the actual squared-linear architecture. -/
theorem no_continuous_coordinate_first_single_last
    (a b c : ℝ → ℝ) (ha : Continuous a) (hb : Continuous b) :
    ¬ SeparatesThreeSquareFiber a b c := by
  intro hsep
  have hb0 : b 0 ≠ 0 := by
    intro hzero
    have hsame := hsep 0 (by norm_num) (by norm_num)
      0 1 0 (-1)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num)
      (by simp [lastSquare, hzero])
    have impossible : (1:ℝ) = -1 := hsame.2
    norm_num at impossible
  have ha1 : a 1 ≠ 0 := by
    intro hzero
    have hsame := hsep 1 (by norm_num) (by norm_num)
      1 0 (-1) 0
      (by norm_num) (by norm_num) (by norm_num) (by norm_num)
      (by simp [lastSquare, hzero])
    have impossible : (1:ℝ) = -1 := hsame.1
    norm_num at impossible
  let u : ℝ → ℝ := fun t => t * a t
  let v : ℝ → ℝ := fun t => (1-t) * b t
  have hu : Continuous u := continuous_id.mul ha
  have hv : Continuous v := (continuous_const.sub continuous_id).mul hb
  have hu0 : u 0 = 0 := by simp [u]
  have hv1 : v 1 = 0 := by simp [v]
  have hv0 : v 0 ≠ 0 := by simpa [v] using hb0
  have hu1 : u 1 ≠ 0 := by simpa [u] using ha1
  obtain ⟨t, ht0, ht1, hcross⟩ :=
    signed_contributions_cross u v hu hv hu0 hv1 hv0 hu1
  rcases hcross with hplus | hminus
  · have heq :
        lastSquare a b c t t (-(1-t)) =
        lastSquare a b c t (-t) (1-t) := by
      have hh : t*a t = (1-t)*b t := hplus
      unfold lastSquare
      have hlinear :
          a t * t + b t * (-(1-t)) + c t =
          a t * (-t) + b t * (1-t) + c t := by
        nlinarith [hh]
      rw [hlinear]
    have hsame := hsep t (le_of_lt ht0) (le_of_lt ht1)
      t (-(1-t)) (-t) (1-t)
      (by ring) (by ring) (by ring) (by ring) heq
    have impossible : t = -t := hsame.1
    linarith
  · have heq :
        lastSquare a b c t t (1-t) =
        lastSquare a b c t (-t) (-(1-t)) := by
      have hh : t*a t = -((1-t)*b t) := hminus
      unfold lastSquare
      have hlinear :
          a t * t + b t * (1-t) + c t =
          a t * (-t) + b t * (-(1-t)) + c t := by
        nlinarith [hh]
      rw [hlinear]
    have hsame := hsep t (le_of_lt ht0) (le_of_lt ht1)
      t (1-t) (-t) (-(1-t))
      (by ring) (by ring) (by ring) (by ring) heq
    have impossible : t = -t := hsame.1
    linarith

#print axioms Nightfall.ContinuousPhaseObstruction.no_continuous_coordinate_first_single_last

end Nightfall.ContinuousPhaseObstruction
