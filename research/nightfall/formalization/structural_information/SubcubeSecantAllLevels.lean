import SubcubeSecantTransfer
import SubcubeSharpScalar

set_option maxRecDepth 12000
set_option maxHeartbeats 4000000

namespace Nightfall.StructuralInformation.SubcubeSecantAllLevels

open Nightfall.StructuralInformation.SubcubeAllSpacesL3
open Nightfall.StructuralInformation.SubcubeAllLevels
open Nightfall.StructuralInformation.SubcubeAffineAllLevels
open Nightfall.StructuralInformation.SubcubeSecantSlices
open Nightfall.StructuralInformation.SubcubeSecantMixed
open Nightfall.StructuralInformation.SubcubeSecantTransfer
open Nightfall.StructuralInformation.SubcubeSharpScalar

/-- Integer dimension-budget scalar inequality for quartic secants, obtained
    from the already kernel-certified real three-slice convexity theorem. -/
theorem triple_fourth (q a b c : Nat)
    (hab : a+b ≤ q) (hac : a+c ≤ q) (hbc : b+c ≤ q) :
    a^4+b^4+c^4 ≤ q^4 := by
  have hr : (a:ℝ)^(4:ℝ) + (b:ℝ)^(4:ℝ) +
      (c:ℝ)^(4:ℝ) ≤ (q:ℝ)^(4:ℝ) :=
    triple_rpow (4:ℝ) (q:ℝ) (a:ℝ) (b:ℝ) (c:ℝ)
      (by norm_num) (by norm_num)
      (by positivity) (by positivity) (by positivity) (by positivity)
      (by exact_mod_cast hab) (by exact_mod_cast hac)
      (by exact_mod_cast hbc)
  norm_num [Real.rpow_natCast] at hr
  exact_mod_cast hr

theorem secant_level_zero (W : Submodule K (E 0)) :
    nonzeroHits (pairSums (R 0)) W = 0 := by
  classical
  have h : pairSums (R 0) = ({0} : Finset (E 0)) := by decide
  simp [nonzeroHits, h]

/-- New all-depth polynomial subspace bound for NONZERO secants,
    conditional on no extra source, frame, or small-doubling assumptions. -/
theorem all_levels_nonzero_secants_quartic (n : Nat)
    (W : Submodule K (E n)) :
    nonzeroHits (pairSums (R n)) W ≤
      12*n*(Module.finrank K W)^4 := by
  induction n with
  | zero =>
      simp [secant_level_zero W]
  | succ n ih =>
      let q : Nat := Module.finrank K W
      let a : Nat := Module.finrank K (slice W inl)
      let b : Nat := Module.finrank K (slice W inr)
      let c : Nat := Module.finrank K (slice W diag)
      have hlin : ∀ P : Submodule K (E n),
          rowHits (R n) P ≤ Module.finrank K P * Module.finrank K P :=
        all_levels_quadratic n
      have haffine : ∀ (Q : Submodule K (E n)) (x : E n),
          affineRowHits (R n) Q x ≤
          (Module.finrank K Q + 1)*(Module.finrank K Q + 1) := by
        intro Q x
        simpa only [affineRowHits, affineHits] using
          all_levels_affine_quadratic n Q x
      have hstep := nonzero_secant_step_quartic (R n) hlin haffine W
      obtain ⟨hab, hac, hbc⟩ := slice_rank_pairs W
      have hscalar : a^4+b^4+c^4 ≤ q^4 :=
        triple_fourth q a b c hab hac hbc
      have hA := ih (slice W inl)
      have hB := ih (slice W inr)
      have hC := ih (slice W diag)
      have hmul : (12*n)*(a^4+b^4+c^4) ≤ (12*n)*q^4 :=
        Nat.mul_le_mul_left _ hscalar
      change nonzeroHits (pairSums (rowsUp (R n))) W ≤
        12*(n+1)*q^4
      calc
        _ ≤ nonzeroHits (pairSums (R n)) (slice W inl) +
            nonzeroHits (pairSums (R n)) (slice W inr) +
            nonzeroHits (pairSums (R n)) (slice W diag) +
            12*q^4 := hstep
        _ ≤ (12*n)*a^4 + (12*n)*b^4 + (12*n)*c^4 + 12*q^4 := by
            simpa [a, b, c] using
              (Nat.add_le_add_right
                (Nat.add_le_add (Nat.add_le_add hA hB) hC) (12*q^4))
        _ = (12*n)*(a^4+b^4+c^4)+12*q^4 := by ring
        _ ≤ (12*n)*q^4+12*q^4 := Nat.add_le_add_right hmul _
        _ = 12*(n+1)*q^4 := by ring

#print axioms Nightfall.StructuralInformation.SubcubeSecantAllLevels.triple_fourth
#print axioms Nightfall.StructuralInformation.SubcubeSecantAllLevels.all_levels_nonzero_secants_quartic

end Nightfall.StructuralInformation.SubcubeSecantAllLevels
