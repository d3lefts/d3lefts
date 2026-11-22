import Mathlib

/-!
# Exact finite real phase-retrieval block: eight signals, four intensities

Source-level implementation of the literal real squared-linear oracle:
  (a,b) ↦ a², b², (a+b)², (a-b)²
on eight pairwise distinct sign-classes, with one representative having
positive first coordinate.

The following universal finite statements are kernel-checked:
* any three different reading indices decode the signal;
* for every first index there exists an output fiber that no possible
  single second reading separates, so no depth-2 adaptive decoder can
  exactly identify the signal from these four legal readings.

These are **finite exact** claims. They do NOT prove any real-signals
unrestricted-query lower bound, the all-B Wyner entropy formula, or the
Route 1 simulation composition.
-/

namespace Nightfall.PhaseRoute1Finite

/-- Eight positive-first-coordinate representatives, one from each
global ± sign class in the selected finite model. -/
def signal (i : Fin 8) : ℤ × ℤ :=
  match i.val with
  | 0 => (1, -1)
  | 1 => (1, 1)
  | 2 => (1, -3)
  | 3 => (1, 3)
  | 4 => (3, -1)
  | 5 => (3, 1)
  | 6 => (3, -3)
  | _ => (3, 3)

/-- Exactly one of the four allowed squared-linear measurements.
The code operates directly on integers, not a precomputed truth table. -/
def reading (i : Fin 8) (j : Fin 4) : ℤ :=
  let x := (signal i).1
  let y := (signal i).2
  match j.val with
  | 0 => x ^ 2
  | 1 => y ^ 2
  | 2 => (x + y) ^ 2
  | _ => (x - y) ^ 2

/-- Every choice of three of the four *actual* oracle readings
injectively identifies all eight signal classes. -/
theorem any_three_decode :
    ∀ (omitted : Fin 4) (x y : Fin 8),
      (∀ j : Fin 4, j ≠ omitted → reading x j = reading y j) → x = y := by
  decide

/-- Chosen bad output fiber for each possible first query. -/
def hardOutcome (first : Fin 4) : ℤ :=
  if first.val < 2 then 1 else 4

/-- For each first query, some output fiber is still ambiguous after
*every* legal choice of a second query. This negates every deterministic
adaptive tree of depth ≤2 on the given four-element measurement family. -/
theorem no_adaptive_two_decode :
    ∀ first second : Fin 4,
      ∃ x y : Fin 8,
        x ≠ y ∧
        reading x first = hardOutcome first ∧
        reading y first = hardOutcome first ∧
        reading x second = reading y second := by
  decide

/-- Raw support has no nontrivial one-coordinate flip: two distinct
signals must differ outside every chosen omitted coordinate. -/
theorem no_single_coordinate_flip :
    ∀ x y : Fin 8, x ≠ y →
      ∀ omitted : Fin 4,
        ∃ j : Fin 4, j ≠ omitted ∧ reading x j ≠ reading y j := by
  decide

#print axioms any_three_decode
#print axioms no_adaptive_two_decode
#print axioms no_single_coordinate_flip

end Nightfall.PhaseRoute1Finite
