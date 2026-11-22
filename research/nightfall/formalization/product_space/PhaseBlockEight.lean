import Mathlib

/-!
NIGHTFALL Phase retrieval / Route 1 exact finite decoder, 2026-11-22.

The four rows are squared-linear intensities of eight distinct real
signal representatives up to global sign:
(1,-3),(1,-1),(1,1),(1,3),(3,-3),(3,-1),(3,1),(3,3).

All results quantify over exactly these four *allowed* measurement rows.
They do NOT establish lower bounds against arbitrary real measurement
families, or the complete Route 1 simulation theorem.
-/

namespace Nightfall.PhaseBlockEight

/-- Symbol order:
0 ↦ (1,-3), 1 ↦ (1,-1), 2 ↦ (1,1), 3 ↦ (1,3),
4 ↦ (3,-3), 5 ↦ (3,-1), 6 ↦ (3,1), 7 ↦ (3,3).

Measurement rows: x₁², x₂², (x₁+x₂)², (x₁−x₂)². -/
def reading (s : Fin 8) (j : Fin 4) : ℕ :=
  match s.val with
  | 0 => if j.val = 0 then 1 else if j.val = 1 then 9 else if j.val = 2 then 4 else 16
  | 1 => if j.val = 0 then 1 else if j.val = 1 then 1 else if j.val = 2 then 0 else 4
  | 2 => if j.val = 0 then 1 else if j.val = 1 then 1 else if j.val = 2 then 4 else 0
  | 3 => if j.val = 0 then 1 else if j.val = 1 then 9 else if j.val = 2 then 16 else 4
  | 4 => if j.val = 0 then 9 else if j.val = 1 then 9 else if j.val = 2 then 0 else 36
  | 5 => if j.val = 0 then 9 else if j.val = 1 then 1 else if j.val = 2 then 4 else 16
  | 6 => if j.val = 0 then 9 else if j.val = 1 then 1 else if j.val = 2 then 16 else 4
  | _ => if j.val = 0 then 9 else if j.val = 1 then 9 else if j.val = 2 then 36 else 0

/-- Every choice of three different permitted rows identifies the state. -/
theorem any_three_separate :
    ∀ (omitted : Fin 4) (s t : Fin 8),
      (∀ j : Fin 4, j ≠ omitted → reading s j = reading t j) → s = t := by
  decide

/-- Each possible first query has a specific outcome whose remaining states
cannot all be distinguished by any choice of second query. -/
def hardFirstOutcome (j : Fin 4) : ℕ :=
  if j.val = 0 ∨ j.val = 1 then 1 else 4

/-- Exhaustive counterexample to every deterministic adaptive two-reading
strategy limited to the four listed measurements.

After first row first produces hardFirstOutcome, any second row
(possibly equal) still collides on two distinct states. -/
theorem adaptive_two_readings_not_enough :
    ∀ (first second : Fin 4),
      ∃ s t : Fin 8,
        s ≠ t ∧
        reading s first = hardFirstOutcome first ∧
        reading t first = hardFirstOutcome first ∧
        reading s second = reading t second := by
  decide

/-- As a support-code criterion, no two distinct symbols can differ in only
one raw reading: equivalently, every three rows separate. -/
theorem no_axis_adjacent_codewords :
    ∀ (s t : Fin 8) (omitted : Fin 4),
      s ≠ t →
      (∀ j : Fin 4, j ≠ omitted → reading s j = reading t j) →
      False := by
  intro s t omitted hne heq
  exact hne (any_three_separate omitted s t heq)

#print axioms Nightfall.PhaseBlockEight.any_three_separate
#print axioms Nightfall.PhaseBlockEight.adaptive_two_readings_not_enough
#print axioms Nightfall.PhaseBlockEight.no_axis_adjacent_codewords

end Nightfall.PhaseBlockEight
