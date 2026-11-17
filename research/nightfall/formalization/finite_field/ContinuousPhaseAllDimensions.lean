import Mathlib
import ContinuousPhaseOracleObstruction

/-!
# Continuity barrier for coordinate-first squared-linear phase retrieval

A universal n+1 coordinate-first policy with a continuous final row
would restrict to a three-coordinate policy, contradicting the
kernel-certified intermediate-value support-transfer theorem.

The continuity assumption is needed only for two coordinate coefficients
along a one-parameter path of actually reachable square observations.
-/

namespace Nightfall.ContinuousPhaseObstruction
noncomputable section

/-- The first three signal coordinates; all others are zero. -/
def lift3 (k : ℕ) (x y z : ℝ) : Fin (k + 3) → ℝ :=
  Fin.cons x (Fin.cons y (Fin.cons z (fun _ : Fin k => 0)))

/-- Coordinate-square data along the support-changing path. -/
def pathData (k : ℕ) (t : ℝ) : Fin (k+3) → ℝ :=
  lift3 k (t^2) ((1-t)^2) 1

/-- The square-data identity on three-coordinate supported signals. -/
theorem lift3_square (k : ℕ) (x y z : ℝ) :
    (fun i : Fin (k+3) => (lift3 k x y z i)^2) =
      lift3 k (x^2) (y^2) (z^2) := by
  funext i
  induction i using Fin.cases with
  | zero => rfl
  | succ i =>
      induction i using Fin.cases with
      | zero => rfl
      | succ i =>
          induction i using Fin.cases with
          | zero => rfl
          | succ i => simp [lift3]

/-- The squared-linear dot product reduces to the first three terms. -/
theorem dot_lift3 (k : ℕ) (row : Fin (k+3) → ℝ) (x y z : ℝ) :
    (∑ i : Fin (k+3), row i * lift3 k x y z i) =
      row 0 * x + row 1 * y + row 2 * z := by
  simp [lift3, Fin.sum_univ_succ, add_assoc]

/-- The exact last-row separation predicate, with that row chosen only
from previously observed coordinate squares. -/
def CoordinatesThenOneSeparates (k : ℕ)
    (row : (Fin (k+3) → ℝ) → Fin (k+3) → ℝ) : Prop :=
  ∀ X Y : Fin (k+3) → ℝ,
    (∀ i, (X i)^2 = (Y i)^2) →
    (∑ i, row (fun j => (X j)^2) i * X i)^2 =
      (∑ i, row (fun j => (Y j)^2) i * Y i)^2 →
    X = Y ∨ X = -Y

/-- The exact obstruction transfers to EVERY signal dimension n=k+3.
Continuity only along the physically observed square-data path is used. -/
theorem no_continuous_final_row_all_dimensions (k : ℕ)
    (row : (Fin (k+3) → ℝ) → Fin (k+3) → ℝ)
    (h0 : Continuous (fun t : ℝ => row (pathData k t) 0))
    (h1 : Continuous (fun t : ℝ => row (pathData k t) 1)) :
    ¬ CoordinatesThenOneSeparates k row := by
  intro hsep
  let a : ℝ → ℝ := fun t => row (pathData k t) 0
  let b : ℝ → ℝ := fun t => row (pathData k t) 1
  let c : ℝ → ℝ := fun t => row (pathData k t) 2
  have hs : SeparatesThreeSquareFiber a b c := by
    intro t ht0 ht1 x y x' y' hx hy hx' hy' hread
    let X : Fin (k+3) → ℝ := lift3 k x y 1
    let Y : Fin (k+3) → ℝ := lift3 k x' y' 1
    have hsX : (fun i : Fin (k+3) => (X i)^2) = pathData k t := by
      change (fun i : Fin (k+3) => (lift3 k x y 1 i)^2) = pathData k t
      rw [lift3_square]
      simp only [pathData, hx, hy, one_pow]
    have hsY : (fun i : Fin (k+3) => (Y i)^2) = pathData k t := by
      change (fun i : Fin (k+3) => (lift3 k x' y' 1 i)^2) = pathData k t
      rw [lift3_square]
      simp only [pathData, hx', hy', one_pow]
    have hsq : ∀ i, (X i)^2 = (Y i)^2 := by
      intro i
      exact congrArg (fun f : Fin (k+3) → ℝ => f i) (hsX.trans hsY.symm)
    have hreadX :
        (∑ i, row (fun j => (X j)^2) i * X i)^2 =
          lastSquare a b c t x y := by
      rw [hsX]
      change (∑ i, row (pathData k t) i * lift3 k x y 1 i)^2 =
        lastSquare a b c t x y
      rw [dot_lift3]
      simp [lastSquare, a, b, c]
    have hreadY :
        (∑ i, row (fun j => (Y j)^2) i * Y i)^2 =
          lastSquare a b c t x' y' := by
      rw [hsY]
      change (∑ i, row (pathData k t) i * lift3 k x' y' 1 i)^2 =
        lastSquare a b c t x' y'
      rw [dot_lift3]
      simp [lastSquare, a, b, c]
    have hh : (∑ i, row (fun j => (X j)^2) i * X i)^2 =
        (∑ i, row (fun j => (Y j)^2) i * Y i)^2 := by
      exact hreadX.trans (hread.trans hreadY.symm)
    rcases hsep X Y hsq hh with hXY | hXY
    · constructor
      · have hi := congrArg (fun f : Fin (k+3) → ℝ => f 0) hXY
        simpa [X, Y, lift3] using hi
      · have hi := congrArg (fun f : Fin (k+3) → ℝ => f 1) hXY
        simpa [X, Y, lift3] using hi
    · let idx2 : Fin (k+3) :=
        Fin.succ (Fin.succ (0 : Fin (k+1)))
      have hi := congrArg (fun f : Fin (k+3) → ℝ => f idx2) hXY
      have hXval : X idx2 = (1 : ℝ) := by
        rfl
      have hYval : Y idx2 = (1 : ℝ) := by
        rfl
      have hbad : (1:ℝ) = -1 := by
        simpa [Pi.neg_apply, hXval, hYval] using hi
      norm_num at hbad
  exact no_continuous_coordinate_first_single_last a b c h0 h1 hs

#print axioms Nightfall.ContinuousPhaseObstruction.no_continuous_final_row_all_dimensions

end
end Nightfall.ContinuousPhaseObstruction
