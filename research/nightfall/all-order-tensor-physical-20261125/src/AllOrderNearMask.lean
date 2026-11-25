import AllOrderMaskCost

namespace Nightfall.AllOrder
open Finset
open Nightfall.StructuralInformation.T2UniformParseval
open Nightfall.AllOrder.Geometry
variable {I A : Type*} [Fintype I] [DecidableEq I] [Fintype A] [DecidableEq A]

noncomputable def slotMask (i : I) (v : A → ℝ) (j : I) (a : A) : ℝ := if j=i then v a else 1

theorem slotMask_prod (i : I) (v : A → ℝ) (b : I → A) : (∏ j, slotMask i v j (b j)) = v (b i) := by
  classical
  rw [Finset.prod_eq_single i]
  · simp [slotMask]
  · intro j _ hj; simp [slotMask,hj]
  · simp

theorem slotMask_abs (i : I) (v : A → ℝ) (hv : ∀ a, |v a| ≤ 1) (j : I) (a : A) :
    |slotMask i v j a| ≤ 1 := by
  by_cases h : j=i <;> simp [slotMask,h,hv]

theorem slot_mask_cost (i : I) (v : A → ℝ) (hv : ∀ a, |v a| ≤ 1) : MaskCost (fun b => v (b i)) 1 := by
  classical
  let w : Unit → ℝ := fun _ => 1
  let m : Unit → I → A → ℝ := fun _ => slotMask i v
  have h := mask_cost_rep w m (fun _ => slotMask_abs i v hv)
  have he : maskRep w m = fun b => v (b i) := by funext b; simp [maskRep,w,m,slotMask_prod]
  simpa only [he,show (∑ t : Unit, |w t|) = 1 by simp [w]] using h

/-- Independent binary characters indexed by the labels; these are not
    extra paid oracle coordinates, only a signed mask representation. -/
theorem basis_inj : Function.Injective (probe (K := A)) := by
  intro a b h
  by_contra hab
  have hh := congrFun h a
  simp [probe,hab] at hh

theorem bitGroup_two (z : A → ZMod 2) : z+z=0 := by
  funext a
  change z a + z a = 0
  rcases zmod2_cases (z a) with h|h <;> rw [h] <;> decide

/-- A partial map equality mask has cost one, with no injectivity assumption
    on the partial map. Repeated query slots are allowed. -/
theorem partial_equality_mask_cost (τ : A → Option A) (i j : I) :
    MaskCost (fun b => if τ (b i) = some (b j) then 1 else 0) 1 := by
  classical
  let G := A → ZMod 2
  let w : AddChar G ℂ → ℝ := fun _ => (Fintype.card G : ℝ)⁻¹
  let v : AddChar G ℂ → A → ℝ := fun t a => (τ a).elim 0 (fun a' => sign t (probe a'))
  let m : AddChar G ℂ → I → A → ℝ := fun t k a => slotMask i (v t) k a * slotMask j (fun a => sign t (probe a)) k a
  have hv (t : AddChar G ℂ) (a : A) : |v t a| ≤ 1 := by
    cases h : τ a <;> simp [v,h,abs_sign bitGroup_two]
  have hm (t : AddChar G ℂ) (k : I) (a : A) : |m t k a| ≤ 1 := by
    unfold m
    rw [abs_mul]
    exact mul_le_one₀ (slotMask_abs _ _ (hv t) _ _) (abs_nonneg _) (slotMask_abs _ _ (fun _ => (abs_sign bitGroup_two _ _).le) _ _)
  have he : maskRep w m = fun b => if τ (b i) = some (b j) then 1 else 0 := by
    funext b
    unfold maskRep m
    simp_rw [Finset.prod_mul_distrib,slotMask_prod]
    cases h : τ (b i) with
    | none => simp [v,h]
    | some a' =>
      have havg := equality_mask_average bitGroup_two (probe a') (probe (b j))
      simpa [G,v,h,w,basis_inj.eq_iff] using havg
  have hc : ∑ t, |w t| = 1 := by
    have hn : (Fintype.card G : ℝ) ≠ 0 := by positivity
    simp [w, AddChar.card_eq, abs_of_nonneg (inv_nonneg.mpr (by positivity : (0:ℝ) ≤ Fintype.card G)), hn, nsmul_eq_mul]
  rw [← he, ← hc]
  exact mask_cost_rep w m hm

/-- Enumerate a bounded neighbor list with an optional entry for every index. -/
noncomputable def neighborAt (N : A → Finset A) (D : ℕ) (a : A) (k : Fin D) : Option A :=
  if h : k.val < (N a).card then some ((N a).equivFin.symm ⟨k.val,h⟩).val else none

theorem neighborAt_mem (N : A → Finset A) (D : ℕ) (a : A) (k : Fin D) (b : A)
    (h : neighborAt N D a k = some b) : b ∈ N a := by
  unfold neighborAt at h
  split at h
  · rename_i hk
    have he : ((N a).equivFin.symm ⟨k.val,hk⟩).val = b := Option.some.inj h
    rw [← he]
    exact ((N a).equivFin.symm ⟨k.val,hk⟩).property
  · contradiction

theorem neighborAt_unique (N : A → Finset A) (D : ℕ) (a b : A) (k l : Fin D)
    (hk : neighborAt N D a k = some b) (hl : neighborAt N D a l = some b) : k=l := by
  unfold neighborAt at hk hl
  split at hk
  · rename_i hkv
    split at hl
    · rename_i hlv
      have h : (N a).equivFin.symm ⟨k.val,hkv⟩ = (N a).equivFin.symm ⟨l.val,hlv⟩ :=
        Subtype.ext ((Option.some.inj hk).trans (Option.some.inj hl).symm)
      exact Fin.ext (congrArg (fun x : Fin (N a).card => x.val) ((N a).equivFin.symm.injective h))
    · contradiction
  · contradiction

theorem neighborAt_exists (N : A → Finset A) (D : ℕ) (hD : ∀ a, (N a).card ≤ D) (a b : A)
    (hb : b ∈ N a) : ∃ k : Fin D, neighborAt N D a k = some b := by
  let t := (N a).equivFin ⟨b,hb⟩
  let k := Fin.castLE (hD a) t
  refine ⟨k,?_⟩
  have hk : k.val < (N a).card := t.isLt
  simp [neighborAt,hk,k,t]

/-- Exact near-indicator mask from bounded row degree, without a tensor shift
    construction or any matching/injectivity requirement for neighbor maps. -/
theorem neighbor_mask_cost (N : A → Finset A) (D : ℕ) (hD : ∀ a, (N a).card ≤ D) (i j : I) :
    MaskCost (fun b => if b j ∈ N (b i) then 1 else 0) (D:ℝ) := by
  classical
  let H : Fin D → (I → A) → ℝ := fun k b => if neighborAt N D (b i) k = some (b j) then 1 else 0
  have h := mask_cost_sum (univ : Finset (Fin D)) H (fun _ => (1:ℝ)) (fun k _ => partial_equality_mask_cost (fun a => neighborAt N D a k) i j)
  have he : (fun b => ∑ k, H k b) = fun b => if b j ∈ N (b i) then 1 else 0 := by
    funext b
    by_cases hb : b j ∈ N (b i)
    · obtain ⟨k,hk⟩ := neighborAt_exists N D hD (b i) (b j) hb
      rw [if_pos hb,Finset.sum_eq_single k]
      · simp [H,hk]
      · intro l _ hl
        have hne : neighborAt N D (b i) l ≠ some (b j) := fun h => hl (neighborAt_unique N D (b i) (b j) l k h hk)
        simp [H,hne]
      · simp
    · rw [if_neg hb]
      apply Finset.sum_eq_zero
      intro k _
      have hne : neighborAt N D (b i) k ≠ some (b j) := fun h => hb (neighborAt_mem N D _ _ _ h)
      simp [H,hne]
  simpa [he] using h

#print axioms slot_mask_cost
#print axioms partial_equality_mask_cost
#print axioms neighbor_mask_cost
end Nightfall.AllOrder
