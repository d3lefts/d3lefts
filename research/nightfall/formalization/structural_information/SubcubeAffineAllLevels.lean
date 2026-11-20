import SubcubeAllLevels

set_option maxRecDepth 10000
set_option maxHeartbeats 3000000

namespace Nightfall.StructuralInformation.SubcubeAffineAllLevels
open Nightfall.StructuralInformation.SubcubeAllSpacesL3
open Nightfall.StructuralInformation.SubcubeAllLevels

/-! A coset a + W lies in the linear subspace W ⊔ K ∙ a of
dimension at most (finrank W)+1. All counts use the original tensor R L.
This is distinct from—and does not bound—quotient SECANT multiplicities. -/

noncomputable def affineHits (n : Nat)
    (W : Submodule K (E n)) (a : E n) : Nat := by
  classical
  exact ((R n).filter (fun r => r - a ∈ W)).card

theorem affine_subset_span (n : Nat) (W : Submodule K (E n))
    (a : E n) :
    (R n).filter (fun r => r - a ∈ W) ⊆
    (R n).filter (fun r => r ∈ (W ⊔ K ∙ a)) := by
  classical
  intro r hr
  obtain ⟨hr, hcos⟩ := Finset.mem_filter.mp hr
  refine Finset.mem_filter.mpr ⟨hr, ?_⟩
  have hdiff : r - a ∈ (W ⊔ K ∙ a) :=
    (le_sup_left : W ≤ W ⊔ K ∙ a) hcos
  have ha : a ∈ (W ⊔ K ∙ a) :=
    (le_sup_right : K ∙ a ≤ W ⊔ K ∙ a) (Submodule.mem_span_singleton_self a)
  have hsum : (r - a) + a ∈ (W ⊔ K ∙ a) :=
    (W ⊔ K ∙ a).add_mem hdiff ha
  simpa only [sub_add_cancel] using hsum

/-- A dimension-q affine coset contains at most (q+1)^2 tensor rows, uniformly
in the level n, with no balance or frame hypotheses. -/
theorem all_levels_affine_quadratic (n : Nat)
    (W : Submodule K (E n)) (a : E n) :
    affineHits n W a ≤
      (Module.finrank K W + 1) * (Module.finrank K W + 1) := by
  classical
  let U : Submodule K (E n) := W ⊔ K ∙ a
  have hct : affineHits n W a ≤ rowHits (R n) U := by
    unfold affineHits rowHits
    apply Finset.card_le_card
    exact affine_subset_span n W a
  have hdim : Module.finrank K U ≤ Module.finrank K W + 1 := by
    dsimp [U]
    calc
      Module.finrank K (W ⊔ K ∙ a) ≤
          Module.finrank K W + Module.finrank K (K ∙ a) :=
        Submodule.finrank_add_le_finrank_add_finrank _ _
      _ ≤ Module.finrank K W + 1 := by
        gcongr
        calc
          Module.finrank K (K ∙ a) ≤ ({a} : Set (E n)).toFinset.card :=
            finrank_span_le_card ({a} : Set (E n))
          _ = 1 := by simp
  have hU : rowHits (R n) U ≤ (Module.finrank K U)*(Module.finrank K U) :=
    all_levels_quadratic n U
  exact hct.trans (hU.trans (Nat.mul_le_mul hdim hdim))

#print axioms Nightfall.StructuralInformation.SubcubeAffineAllLevels.affine_subset_span
#print axioms Nightfall.StructuralInformation.SubcubeAffineAllLevels.all_levels_affine_quadratic

end Nightfall.StructuralInformation.SubcubeAffineAllLevels
