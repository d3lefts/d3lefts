import PaperVGroupedEnergy
import T2CorrectionEventBridge

/-! Paper V v2.1 §4.6: derive the double light charge and sixfold
fiber bound from the actual zero-triple event, not separate premises.
The four slot-energy bounds remain physical hypotheses in this lemma. -/
namespace Nightfall.PaperVCorrectionComposition
open Finset
open Nightfall.StructuralInformation.T2CorrectionSix
open Nightfall.StructuralInformation.T2CorrectionEventBridge
open Nightfall.PaperVGroupedEnergy
variable {G : Type*} [AddCommGroup G] [DecidableEq G]
abbrev Tuple (G : Type*) := G × G × G × G

def freq (t : Tuple G) : G := t.1+t.2.1+t.2.2.1+t.2.2.2

noncomputable def outsideCorrection (R Z : Finset G) : Finset (Tuple G) :=
  Z.biUnion (eventCorrectionFiber R)

theorem correction_freq (R : Finset G) (z : G) (t : Tuple G)
    (ht : t ∈ eventCorrectionFiber R z) : freq t = z := by
  classical
  exact (Finset.mem_filter.mp ht).2.1

theorem actual_correction_energy (h₂ : ∀ x : G, x+x=0)
    (R Z L : Finset G) (c : Tuple G → ℝ) (M : ℕ) (eta : ℝ)
    (hZ : Z ⊆ L)
    (hM : ∀ z ∈ Z, (pairFiber R z).card ≤ M)
    (ha : ∑ t ∈ (outsideCorrection R Z).filter (fun t => t.1 ∈ L), (c t)^2 ≤ eta)
    (hb : ∑ t ∈ (outsideCorrection R Z).filter (fun t => t.2.1 ∈ L), (c t)^2 ≤ eta)
    (hc : ∑ t ∈ (outsideCorrection R Z).filter (fun t => t.2.2.1 ∈ L), (c t)^2 ≤ eta)
    (hd : ∑ t ∈ (outsideCorrection R Z).filter (fun t => t.2.2.2 ∈ L), (c t)^2 ≤ eta) :
    (∑ z ∈ Z, (∑ t ∈ eventCorrectionFiber R z, c t)^2) ≤ 12*(M : ℝ)*eta := by
  classical
  let S := outsideCorrection R Z
  let A := S.filter (fun t => t.1 ∈ L)
  let B := S.filter (fun t => t.2.1 ∈ L)
  let C := S.filter (fun t => t.2.2.1 ∈ L)
  let D := S.filter (fun t => t.2.2.2 ∈ L)
  have hF : ∀ z ∈ Z, S.filter (fun t => freq t=z) = eventCorrectionFiber R z := by
    intro z hz
    ext t
    constructor
    · intro ht
      obtain ⟨htS,htz⟩ := Finset.mem_filter.mp ht
      obtain ⟨y,_,hy⟩ := Finset.mem_biUnion.mp htS
      have h := correction_freq R y t hy
      rw [htz] at h
      simpa [← h] using hy
    · intro ht
      exact Finset.mem_filter.mpr ⟨Finset.mem_biUnion.mpr ⟨z,hz,ht⟩,correction_freq R z t ht⟩
  have hcard : ∀ z ∈ Z, ((S.filter (fun t => freq t=z)).card : ℝ) ≤ 6*(M : ℝ) := by
    intro z hz
    rw [hF z hz]
    exact_mod_cast event_correction_card_le_six_M h₂ R z M (hM z hz)
  have hdouble : ∀ t ∈ S, 2 ≤ (if t ∈ A then (1 : ℝ) else 0) +
      (if t ∈ B then 1 else 0) + (if t ∈ C then 1 else 0) + (if t ∈ D then 1 else 0) := by
    intro t ht
    obtain ⟨z,hz,hzT⟩ := Finset.mem_biUnion.mp ht
    have hL := hZ hz
    have hcov := event_correction_subset_six_cover h₂ R z hzT
    have h := (Finset.mem_filter.mp hcov).2
    change correctionCover z t.1 t.2.1 t.2.2.1 t.2.2.2 at h
    unfold correctionCover at h
    simp only [A,B,C,D,Finset.mem_filter,ht,true_and]
    rcases h with h|h|h|h|h|h
    all_goals
      rcases h with ⟨h1,h2,_⟩
      simp only [h1,h2,hL,if_true]
      split <;> split <;> norm_num
  have h := correction_grouped_energy S A B C D Z freq c (M : ℝ) eta
    (Nat.cast_nonneg M) ha hb hc hd hdouble hcard
  have he : (∑ z ∈ Z, (∑ t ∈ S.filter (fun t => freq t=z), c t)^2) =
      ∑ z ∈ Z, (∑ t ∈ eventCorrectionFiber R z, c t)^2 := by
    apply Finset.sum_congr rfl
    intro z hz
    rw [hF z hz]
  rw [he] at h
  exact h

#print axioms actual_correction_energy
end Nightfall.PaperVCorrectionComposition
