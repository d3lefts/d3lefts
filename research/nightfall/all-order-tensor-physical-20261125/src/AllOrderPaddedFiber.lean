import AllOrderActiveFiber
import Mathlib.Data.Fintype.Option

namespace Nightfall.AllOrder.Geometry
open Finset
variable {I J K : Type*} [Fintype I] [DecidableEq I] [Fintype J] [DecidableEq J] [Fintype K] [DecidableEq K]

abbrev Label (J K : Type*) := Option (Row J K)

def optionLabel (u : Label J K) : Tensor J K := u.elim 0 tensorLabel

abbrev Active (b : I → Label J K) := {i : I // (b i).isSome}

def actualRow (b : I → Label J K) (i : Active b) : Row J K := (b i.val).get i.property

theorem actualRow_some (b : I → Label J K) (i : Active b) : some (actualRow b i) = b i.val := by
  unfold actualRow
  exact Option.some_get _

theorem active_sum_eq (b : I → Label J K) :
    (∑ i : Active b, tensorLabel (actualRow b i)) = ∑ i, optionLabel (b i) := by
  classical
  have h : (∑ i : Active b, tensorLabel (actualRow b i)) = ∑ i : Active b, optionLabel (b i.val) := by
    apply Finset.sum_congr rfl
    intro i _
    rw [← actualRow_some b i]
    rfl
  rw [h]
  have hsub := Finset.sum_subtype (p := fun i : I => (b i).isSome = true) (F := inferInstanceAs (Fintype (Active b)))
      (univ.filter (fun i : I => (b i).isSome)) (fun i => by simp) (fun i => optionLabel (b i))
  rw [← hsub, Finset.sum_filter]
  apply Finset.sum_congr rfl
  intro i _
  cases h : b i <;> simp [h,optionLabel]

noncomputable def paddedGood (b : I → Label J K) (r : ℕ) : Prop := by
  classical
  exact activeGood (actualRow b) r

def rowBallBound (L s R : ℕ) : ℕ := (R+1)*(L+1)^R*(s+1)^R

def fiberBound (L s d : ℕ) : ℕ :=
  let R := (d+1)*circuitRadius s d
  (1+d*rowBallBound L s R)^d

/-- Polynomial fiber cardinality for arbitrary families of padded active
    tuples, with dummy labels allowed and zero-frequency edge cases included. -/
theorem padded_fiber_bound (S : Finset (I → Label J K))
    (hgood : ∀ b ∈ S, paddedGood b (circuitRadius (Fintype.card (NonzeroFactor K)) (Fintype.card I)))
    (z : Tensor J K) :
    (S.filter (fun b => (∑ i, optionLabel (b i)) = z)).card ≤
      fiberBound (Fintype.card J) (Fintype.card (NonzeroFactor K)) (Fintype.card I) := by
  classical
  let d := Fintype.card I
  let s := Fintype.card (NonzeroFactor K)
  let R := (d+1)*circuitRadius s d
  let F := S.filter (fun b => (∑ i, optionLabel (b i)) = z)
  by_cases hF : F.Nonempty
  · obtain ⟨b₀,hb₀⟩ := hF
    let U := (univ : Finset (Active b₀)).biUnion (fun j => ball (actualRow b₀ j) R)
    let V := insert none (U.image some)
    have hU : U.card ≤ d*rowBallBound (Fintype.card J) s R := by
      calc
        _ ≤ ∑ j : Active b₀, (ball (actualRow b₀ j) R).card := Finset.card_biUnion_le
        _ ≤ ∑ _ : Active b₀, rowBallBound (Fintype.card J) s R := Finset.sum_le_sum (fun j _ => ball_card_le _ _)
        _ = Fintype.card (Active b₀) * rowBallBound (Fintype.card J) s R := by simp
        _ ≤ _ := Nat.mul_le_mul_right _ (Fintype.card_subtype_le _)
    have hV : V.card ≤ 1+d*rowBallBound (Fintype.card J) s R := by
      have h := Finset.card_insert_le (a := (none : Label J K)) (s := U.image some)
      have h' := Finset.card_image_le (s := U) (f := some)
      dsimp [V]
      omega
    have hmem (b : I → Label J K) (hb : b ∈ F) (i : I) : b i ∈ V := by
      by_cases hi : (b i).isSome
      · let ai : Active b := ⟨i,hi⟩
        have hbS := (Finset.mem_filter.mp hb).1
        have hfreq : (∑ j : Active b, tensorLabel (actualRow b j)) = ∑ j : Active b₀, tensorLabel (actualRow b₀ j) := by
          rw [active_sum_eq, active_sum_eq, (Finset.mem_filter.mp hb).2, (Finset.mem_filter.mp hb₀).2]
        obtain ⟨j,hj⟩ := active_row_near_reference (actualRow b) (actualRow b₀) d
          (Fintype.card_subtype_le _) (Fintype.card_subtype_le _) (hgood b hbS) hfreq ai
        have hball : actualRow b ai ∈ ball (actualRow b₀ j) R := Finset.mem_filter.mpr ⟨Finset.mem_univ _, by rw [ham_symm]; exact hj⟩
        have hUmem : actualRow b ai ∈ U := Finset.mem_biUnion.mpr ⟨j,Finset.mem_univ _,hball⟩
        rw [← actualRow_some b ai]
        exact Finset.mem_insert_of_mem (Finset.mem_image.mpr ⟨_,hUmem,rfl⟩)
      · have hn : b i = none := by cases h : b i <;> simp [h] at hi ⊢
        rw [hn]
        exact Finset.mem_insert_self _ _
    let embed : F → (I → V) := fun b i => ⟨b.val i,hmem b.val b.property i⟩
    have hinj : Function.Injective embed := by
      intro b c h
      apply Subtype.ext
      funext i
      exact congrArg Subtype.val (congrFun h i)
    have hc := Fintype.card_le_of_injective embed hinj
    have hpow : F.card ≤ V.card^d := by simpa [Fintype.card_fun,d] using hc
    exact hpow.trans (Nat.pow_le_pow_left hV d)
  · have he : F = ∅ := Finset.not_nonempty_iff_eq_empty.mp hF
    change F.card ≤ _
    rw [he]
    simp

#print axioms active_sum_eq
#print axioms padded_fiber_bound
end Nightfall.AllOrder.Geometry
