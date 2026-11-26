import PaperVPhysicalEnergy
import T2CorrectionEventBridge

/-! Paper V: compose actual complex physical path coefficients with the double-slot charge, rather than assume the four light-energy bounds. The correction-set membership and fiber bound are explicit premises; full Theorem 4.1 is not yet claimed. -/
namespace Nightfall.PaperVPhysicalEnergy
open Finset
open Nightfall.StructuralInformation.T2SecondStageLight
open Nightfall.StructuralInformation.T2ActualSource
open Nightfall.StructuralInformation.T2BornExpansion
open Nightfall.PaperVGroupedEnergy
variable {D : Type*} [Fintype D] [DecidableEq D]
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
theorem physical_double_light_grouped
    {G : Type*} [DecidableEq G] (freq : T D → G)
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E) (P : H D E →L[ℂ] H D E)
    (hpsi : ‖psi‖^2 ≤ 1) (hP0 : 0 ≤ P) (hP1 : P ≤ 1)
    (L : Finset D) (eta : ℝ) (heta : 0 ≤ eta)
    (hp : ∀ a ∈ L, ‖psi a‖^2 ≤ eta)
    (hq : ∀ b ∈ L, (∑ a : D, ‖sourcePath psi U b a‖^2) ≤ eta)
    (S : Finset (T D)) (Z : Finset G) (M : ℝ) (hM : 0 ≤ M)
    (hcover : ∀ t ∈ S, 2 ≤ (if t.1.1 ∈ L then (1 : ℝ) else 0) +
      (if t.1.2 ∈ L then 1 else 0) + (if t.2.1 ∈ L then 1 else 0) +
      (if t.2.2 ∈ L then 1 else 0))
    (hcard : ∀ z ∈ Z, ((S.filter (fun t => freq t=z)).card : ℝ) ≤ 6*M) :
    (∑ z ∈ Z, (∑ t ∈ S.filter (fun t => freq t=z), c psi U P t)^2) ≤ 12*M*eta := by
  classical
  let A := (L.product (univ : Finset D)).product (univ : Finset (D × D))
  let B := ((univ : Finset D).product L).product (univ : Finset (D × D))
  let C := (univ : Finset (D × D)).product (L.product (univ : Finset D))
  let F := (univ : Finset (D × D)).product ((univ : Finset D).product L)
  have ha : ∑ t ∈ A, (c psi U P t)^2 ≤ eta :=
    physical_left_output_light psi U P hpsi hP0 hP1 L eta heta hq
  have hb : ∑ t ∈ B, (c psi U P t)^2 ≤ eta :=
    physical_left_input_light psi U P hpsi hP0 hP1 L eta heta hp
  have hc : ∑ t ∈ C, (c psi U P t)^2 ≤ eta := by
    rw [show C = (univ : Finset (D × D)).product (L.product univ) from rfl,
      swap_energy psi U P hP0]
    exact ha
  have hf : ∑ t ∈ F, (c psi U P t)^2 ≤ eta := by
    rw [show F = (univ : Finset (D × D)).product (univ.product L) from rfl,
      swap_energy psi U P hP0]
    exact hb
  have hcov : ∀ t ∈ S, 2 ≤ (if t ∈ A then (1 : ℝ) else 0) +
      (if t ∈ B then 1 else 0) + (if t ∈ C then 1 else 0) + (if t ∈ F then 1 else 0) := by
    intro t ht
    simpa [A,B,C,F] using hcover t ht
  exact correction_grouped_energy S A B C F Z freq (c psi U P) M eta hM ha hb hc hf hcov hcard


#print axioms physical_double_light_grouped

open Nightfall.StructuralInformation.T2CorrectionSix
open Nightfall.StructuralInformation.T2CorrectionEventBridge

/-- Actual ordered source labels of the two physical paths. -/
def physicalLabelTuple {G : Type*} (label : D → G) (t : T D) : G × G × G × G :=
  (label t.1.1,label t.1.2,label t.2.1,label t.2.2)

def physicalFrequency {G : Type*} [Add G] (label : D → G) (t : T D) : G :=
  label t.1.1 + label t.1.2 + label t.2.1 + label t.2.2

noncomputable def physicalCorrectionPaths {G : Type*} [AddCommGroup G] [DecidableEq G]
    (label : D → G) (R Z : Finset G) : Finset (T D) := by
  classical
  exact univ.filter fun t => ∃ z ∈ Z, physicalLabelTuple label t ∈ eventCorrectionFiber R z

theorem physicalLabelTuple_injective {G : Type*} (label : D → G)
    (hl : Function.Injective label) : Function.Injective (physicalLabelTuple label) := by
  intro t u h
  apply Prod.ext
  · apply Prod.ext
    · exact hl (congrArg Prod.fst h)
    · exact hl (congrArg (fun x : G × G × G × G => x.2.1) h)
  · apply Prod.ext
    · exact hl (congrArg (fun x : G × G × G × G => x.2.2.1) h)
    · exact hl (congrArg (fun x : G × G × G × G => x.2.2.2) h)

/-- Paper V section 4.6: the physical double-light estimate on the actual
zero-triple correction events. Both the double-slot membership and the
sixfold fiber bound are now derived from their source definitions.
The unique original label per sector is an explicit model assumption. -/
theorem physical_event_correction_grouped
    {G : Type*} [AddCommGroup G] [DecidableEq G]
    (h₂ : ∀ x : G, x+x=0)
    (label : D → G) (hl : Function.Injective label)
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E) (P : H D E →L[ℂ] H D E)
    (hpsi : ‖psi‖^2 ≤ 1) (hP0 : 0 ≤ P) (hP1 : P ≤ 1)
    (R Z : Finset G) (L : Finset D) (eta : ℝ) (heta : 0 ≤ eta)
    (hp : ∀ a ∈ L, ‖psi a‖^2 ≤ eta)
    (hq : ∀ b ∈ L, (∑ a : D, ‖sourcePath psi U b a‖^2) ≤ eta)
    (M : ℕ) (hM : ∀ z ∈ Z, (pairFiber R z).card ≤ M)
    (hZ : ∀ d : D, label d ∈ Z → d ∈ L) :
    (∑ z ∈ Z, (∑ t ∈ (physicalCorrectionPaths label R Z).filter
      (fun t => physicalFrequency label t = z), c psi U P t)^2) ≤ 12*(M : ℝ)*eta := by
  classical
  let S := physicalCorrectionPaths label R Z
  have hc : ∀ t ∈ S, 2 ≤ (if t.1.1 ∈ L then (1 : ℝ) else 0) +
      (if t.1.2 ∈ L then 1 else 0) + (if t.2.1 ∈ L then 1 else 0) +
      (if t.2.2 ∈ L then 1 else 0) := by
    intro t ht
    have hmem : ∃ z ∈ Z, physicalLabelTuple label t ∈ eventCorrectionFiber R z :=
      (Finset.mem_filter.mp ht).2
    obtain ⟨z,hz,he⟩ := hmem
    have h := (Finset.mem_filter.mp (event_correction_subset_six_cover h₂ R z he)).2
    change correctionCover z (label t.1.1) (label t.1.2)
      (label t.2.1) (label t.2.2) at h
    have hlight (d : D) (hd : label d = z) : d ∈ L := by
      apply hZ
      rwa [hd]
    unfold correctionCover at h
    rcases h with h|h|h|h|h|h
    all_goals
      rcases h with ⟨h1,h2,_⟩
      simp only [hlight _ h1,hlight _ h2,if_true]
      split <;> split <;> norm_num
  have hcard : ∀ z ∈ Z, ((S.filter (fun t => physicalFrequency label t = z)).card : ℝ)
      ≤ 6*(M : ℝ) := by
    intro z hz
    have hm : ∀ t ∈ S.filter (fun t => physicalFrequency label t = z),
        physicalLabelTuple label t ∈ eventCorrectionFiber R z := by
      intro t ht
      obtain ⟨htS,htz⟩ := Finset.mem_filter.mp ht
      have hmem : ∃ y ∈ Z, physicalLabelTuple label t ∈ eventCorrectionFiber R y :=
        (Finset.mem_filter.mp htS).2
      obtain ⟨y,_,hy⟩ := hmem
      have he := (Finset.mem_filter.mp hy).2.1
      change physicalFrequency label t = y at he
      have hyz : y = z := he.symm.trans htz
      simpa only [hyz] using hy
    have hcount : (S.filter (fun t => physicalFrequency label t = z)).card ≤
        (eventCorrectionFiber R z).card :=
      Finset.card_le_card_of_injOn (physicalLabelTuple label) hm
        (physicalLabelTuple_injective label hl).injOn
    exact_mod_cast hcount.trans (event_correction_card_le_six_M h₂ R z M (hM z hz))
  exact physical_double_light_grouped (physicalFrequency label) psi U P hpsi hP0 hP1
    L eta heta hp hq S Z (M : ℝ) (Nat.cast_nonneg M) hc hcard

#print axioms physicalLabelTuple_injective
#print axioms physical_event_correction_grouped

end Nightfall.PaperVPhysicalEnergy
