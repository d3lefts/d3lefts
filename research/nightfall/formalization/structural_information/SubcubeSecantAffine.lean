import SubcubeSecantAllLevels

set_option maxRecDepth 12000
set_option maxHeartbeats 4000000

namespace Nightfall.StructuralInformation.SubcubeSecantAffine

open Nightfall.StructuralInformation.SubcubeAllSpacesL3
open Nightfall.StructuralInformation.SubcubeAllLevels
open Nightfall.StructuralInformation.SubcubeAffineAllLevels
open Nightfall.StructuralInformation.SubcubeSecantSlices
open Nightfall.StructuralInformation.SubcubeSecantTransfer
open Nightfall.StructuralInformation.SubcubeSecantAllLevels

/-- The number of exact tensor secant sums contained in a translated subspace. -/
noncomputable def affineSecantHits (n : Nat) (W : Submodule K (E n)) (a : E n) : Nat := by
  classical
  exact ((pairSums (R n)).filter fun s => s - a ∈ W).card

/-- Affine reduction adds at most one point (zero) and one dimension.
    Unlike the unshifted linear theorem, this intentionally includes zero. -/
theorem all_levels_secant_affine_quartic (n : Nat)
    (W : Submodule K (E n)) (a : E n) :
    affineSecantHits n W a ≤
      1 + 12*n*(Module.finrank K W + 1)^4 := by
  classical
  let U : Submodule K (E n) := W ⊔ K ∙ a
  let S : Finset (E n) := pairSums (R n)
  let F : Finset (E n) := S.filter fun s => s-a ∈ W
  have hsub : F.erase 0 ⊆ S.filter (fun s => s ≠ 0 ∧ s ∈ U) := by
    intro s hs
    obtain ⟨hs0, hsF⟩ := Finset.mem_erase.mp hs
    obtain ⟨hsS, hsW⟩ := Finset.mem_filter.mp hsF
    exact Finset.mem_filter.mpr
      ⟨hsS, hs0, affine_subset_span n W a s hsW⟩
  have hzero : F.card ≤ (F.erase 0).card + 1 := by
    by_cases hz : (0 : E n) ∈ F
    · exact (Finset.card_erase_add_one hz).symm.le
    · have heq : F.erase 0 = F := by simp [hz]
      rw [heq]
      omega
  have hct : affineSecantHits n W a ≤ nonzeroHits S U + 1 := by
    change F.card ≤ (S.filter fun s => s ≠ 0 ∧ s ∈ U).card + 1
    exact hzero.trans (Nat.add_le_add_right (Finset.card_le_card hsub) 1)
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
  have hU := all_levels_nonzero_secants_quartic n U
  have hpow : (Module.finrank K U)^4 ≤
      (Module.finrank K W + 1)^4 := by
    gcongr
  calc
    affineSecantHits n W a ≤ nonzeroHits S U + 1 := hct
    _ ≤ 12*n*(Module.finrank K U)^4 + 1 :=
      Nat.add_le_add_right hU 1
    _ ≤ 12*n*(Module.finrank K W+1)^4 + 1 := by
      gcongr
    _ = 1 + 12*n*(Module.finrank K W+1)^4 := by omega

#print axioms Nightfall.StructuralInformation.SubcubeSecantAffine.all_levels_secant_affine_quartic

end Nightfall.StructuralInformation.SubcubeSecantAffine
