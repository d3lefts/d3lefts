import AllOrderTensorSource
import Mathlib.Data.Finset.Powerset
import Mathlib.Data.Nat.Choose.Bounds

namespace Nightfall.AllOrder.Geometry
open Finset
variable {J A : Type*} [Fintype J] [DecidableEq J] [Fintype A] [DecidableEq A]

noncomputable def ball (u : J → A) (r : ℕ) : Finset (J → A) := univ.filter (fun v => ham u v ≤ r)

noncomputable def offAgree (u : J → A) (S : Finset J) : Finset (J → A) := by
  classical
  exact univ.filter (fun v => ∀ j ∉ S, v j = u j)

/-- Restriction to the variable sites is injective on all rows agreeing off S. -/
theorem offAgree_card (u : J → A) (S : Finset J) : (offAgree u S).card ≤ (Fintype.card A)^S.card := by
  classical
  have h := Finset.card_le_card_of_injOn (s := offAgree u S) (t := (univ : Finset (S → A)))
    (fun v j => v j.val) (fun _ _ => Finset.mem_univ _) (by
      intro v hv w hw he
      funext j
      by_cases hj : j ∈ S
      · exact congrFun he ⟨j,hj⟩
      · have hv' := (Finset.mem_filter.mp hv).2 j hj
        have hw' := (Finset.mem_filter.mp hw).2 j hj
        exact hv'.trans hw'.symm)
  simpa [Fintype.card_fun] using h

/-- Every radius-r Hamming ball has a cardinal bound polynomial in the site
    count with explicit degree r, independent of the ambient tensor rank. -/
theorem ball_card_le (u : J → A) (r : ℕ) :
    (ball u r).card ≤ (r+1)*(Fintype.card J+1)^r*(Fintype.card A+1)^r := by
  classical
  let sets := (range (r+1)).biUnion (fun k => (univ : Finset J).powersetCard k)
  have hcov : ball u r ⊆ sets.biUnion (offAgree u) := by
    intro v hv
    let S := univ.filter (fun j => u j ≠ v j)
    have hS : S.card ≤ r := (Finset.mem_filter.mp hv).2
    have hm : S ∈ sets := Finset.mem_biUnion.mpr ⟨S.card, Finset.mem_range.mpr (Nat.lt_succ_of_le hS),
      Finset.mem_powersetCard.mpr ⟨Finset.subset_univ _,rfl⟩⟩
    refine Finset.mem_biUnion.mpr ⟨S,hm, Finset.mem_filter.mpr ⟨Finset.mem_univ _,?_⟩⟩
    intro j hj
    by_contra hn
    exact hj (Finset.mem_filter.mpr ⟨Finset.mem_univ _, Ne.symm hn⟩)
  have hsets : sets.card ≤ (r+1)*(Fintype.card J+1)^r := by
    calc
      _ ≤ ∑ k ∈ range (r+1), ((univ : Finset J).powersetCard k).card := Finset.card_biUnion_le
      _ = ∑ k ∈ range (r+1), (Fintype.card J).choose k := by simp [Finset.card_powersetCard]
      _ ≤ ∑ _ ∈ range (r+1), (Fintype.card J+1)^r := by
        apply Finset.sum_le_sum
        intro k hk
        have hkr : k ≤ r := Nat.le_of_lt_succ (Finset.mem_range.mp hk)
        calc
          _ ≤ (Fintype.card J)^k := Nat.choose_le_pow _ _
          _ ≤ (Fintype.card J+1)^k := Nat.pow_le_pow_left (Nat.le_succ _) _
          _ ≤ _ := Nat.pow_le_pow_right (by omega) hkr
      _ = _ := by simp
  calc
    _ ≤ (sets.biUnion (offAgree u)).card := Finset.card_le_card hcov
    _ ≤ ∑ S ∈ sets, (offAgree u S).card := Finset.card_biUnion_le
    _ ≤ ∑ _ ∈ sets, (Fintype.card A+1)^r := by
      apply Finset.sum_le_sum
      intro S hS
      obtain ⟨k,hk,hS'⟩ := Finset.mem_biUnion.mp hS
      have hcard := (Finset.mem_powersetCard.mp hS').2
      have hkr := Nat.le_of_lt_succ (Finset.mem_range.mp hk)
      calc
        _ ≤ (Fintype.card A)^S.card := offAgree_card u S
        _ ≤ (Fintype.card A+1)^S.card := Nat.pow_le_pow_left (Nat.le_succ _) _
        _ ≤ _ := Nat.pow_le_pow_right (by omega) (by omega)
    _ = sets.card*(Fintype.card A+1)^r := by simp
    _ ≤ _ := Nat.mul_le_mul_right _ hsets

#print axioms offAgree_card
#print axioms ball_card_le
end Nightfall.AllOrder.Geometry
