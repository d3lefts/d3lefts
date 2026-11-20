import SubcubeSharpScalar
import SubcubeAffineAllLevels

set_option maxRecDepth 10000
set_option maxHeartbeats 4000000

namespace Nightfall.StructuralInformation.SubcubeSharpAllLevels

open Nightfall.StructuralInformation.SubcubeSharpScalar
open Nightfall.StructuralInformation.SubcubeAllSpacesL3
open Nightfall.StructuralInformation.SubcubeAllLevels
open Nightfall.StructuralInformation.SubcubeAffineAllLevels

private theorem cap0_le_rpow (q : Nat) :
    (cap0 q : ℝ) ≤ (q : ℝ) ^ alpha := by
  by_cases hq : q = 0
  · subst q
    simp [cap0, Real.zero_rpow (ne_of_gt (by linarith [alpha_gt_one] : 0 < alpha))]
  · have hq1 : (1:ℝ) ≤ q := by
      exact_mod_cast Nat.one_le_iff_ne_zero.mpr hq
    have hp := Real.rpow_le_rpow (by norm_num : (0:ℝ) ≤ 1) hq1
      (by linarith [alpha_gt_one] : 0 ≤ alpha)
    simpa [cap0, hq, Real.one_rpow] using hp

/-- Sharp real-exponent bound for EVERY subspace at EVERY tensor level.
    The proof is a kernel-checked geometric induction, not a finite enumeration.
    Sharpness of the exponent is a separate lower-bound assertion. -/
theorem all_levels_sharp (n : Nat) (W : Submodule K (E n)) :
    (rowHits (R n) W : ℝ) ≤ ((Module.finrank K W : Nat) : ℝ) ^ alpha := by
  induction n with
  | zero =>
      have hbase : rowHits (R 0) W ≤ cap0 (Module.finrank K W) :=
        rank_base0 W
      have hbase' : (rowHits (R 0) W : ℝ) ≤
          (cap0 (Module.finrank K W) : ℝ) := by
        exact_mod_cast hbase
      exact hbase'.trans (cap0_le_rpow _)
  | succ n ih =>
      have hcount := hits_step_le (R n) W
      have h0 := ih (slice W inl)
      have h1 := ih (slice W inr)
      have h2 := ih (slice W diag)
      obtain ⟨hd01, hd02, hd12⟩ := slice_rank_pairs W
      have hd01' : ((Module.finrank K (slice W inl):Nat):ℝ) +
           ((Module.finrank K (slice W inr):Nat):ℝ) ≤
           ((Module.finrank K W:Nat):ℝ) := by exact_mod_cast hd01
      have hd02' : ((Module.finrank K (slice W inl):Nat):ℝ) +
           ((Module.finrank K (slice W diag):Nat):ℝ) ≤
           ((Module.finrank K W:Nat):ℝ) := by exact_mod_cast hd02
      have hd12' : ((Module.finrank K (slice W inr):Nat):ℝ) +
           ((Module.finrank K (slice W diag):Nat):ℝ) ≤
           ((Module.finrank K W:Nat):ℝ) := by exact_mod_cast hd12
      have hscalar := triple_alpha
          ((Module.finrank K W:Nat):ℝ)
          ((Module.finrank K (slice W inl):Nat):ℝ)
          ((Module.finrank K (slice W inr):Nat):ℝ)
          ((Module.finrank K (slice W diag):Nat):ℝ)
          (by positivity) (by positivity) (by positivity) (by positivity)
          hd01' hd02' hd12'
      have hcount' :
          (rowHits (R (n+1)) W : ℝ) ≤
          (rowHits (R n) (slice W inl) : ℝ) +
          (rowHits (R n) (slice W inr) : ℝ) +
          (rowHits (R n) (slice W diag) : ℝ) := by
        exact_mod_cast hcount
      linarith

/-- The affine coset bound at the SAME sharp exponent,
    for every tensor level and every arbitrary affine shift. -/
theorem all_levels_affine_sharp (n : Nat)
    (W : Submodule K (E n)) (a : E n) :
    (affineHits n W a : ℝ) ≤
      (((Module.finrank K W + 1 : Nat) : ℝ)) ^ alpha := by
  classical
  let U : Submodule K (E n) := W ⊔ K ∙ a
  have hct : affineHits n W a ≤ rowHits (R n) U := by
    unfold affineHits rowHits
    apply Finset.card_le_card
    intro r hr
    obtain ⟨hr, hcos⟩ := Finset.mem_filter.mp hr
    exact Finset.mem_filter.mpr ⟨hr, affine_subset_span n W a r hcos⟩
  have hdim : Module.finrank K U ≤ Module.finrank K W + 1 := by
    dsimp [U]
    calc
      Module.finrank K ↥(W ⊔ K ∙ a) ≤
          Module.finrank K W + Module.finrank K ↥(K ∙ a) :=
        Submodule.finrank_add_le_finrank_add_finrank _ _
      _ ≤ Module.finrank K W + 1 := by
        gcongr
        calc
          Module.finrank K ↥(K ∙ a) ≤ ({a} : Set (E n)).toFinset.card :=
            finrank_span_le_card ({a} : Set (E n))
          _ = 1 := by simp
  have hct' : (affineHits n W a:ℝ) ≤ (rowHits (R n) U:ℝ) := by
    exact_mod_cast hct
  have hU := all_levels_sharp n U
  have hdim' : ((Module.finrank K U:Nat):ℝ) ≤
      ((Module.finrank K W + 1:Nat):ℝ) := by exact_mod_cast hdim
  have hmono : ((Module.finrank K U:Nat):ℝ)^alpha ≤
      ((Module.finrank K W + 1:Nat):ℝ)^alpha :=
    Real.rpow_le_rpow (by positivity) hdim' (by linarith [alpha_gt_one] : 0 ≤ alpha)
  exact hct'.trans (hU.trans hmono)

#print axioms Nightfall.StructuralInformation.SubcubeSharpAllLevels.all_levels_sharp
#print axioms Nightfall.StructuralInformation.SubcubeSharpAllLevels.all_levels_affine_sharp

end Nightfall.StructuralInformation.SubcubeSharpAllLevels
