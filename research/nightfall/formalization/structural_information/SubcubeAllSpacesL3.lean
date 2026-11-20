import Mathlib

set_option maxRecDepth 10000
set_option maxHeartbeats 3000000

namespace Nightfall.StructuralInformation.SubcubeAllSpacesL3

abbrev K := ZMod 2

variable {V : Type*} [AddCommGroup V] [Module K V]

private def inl : V →ₗ[K] V × V := LinearMap.inl K V V
private def inr : V →ₗ[K] V × V := LinearMap.inr K V V
private def diag : V →ₗ[K] V × V := inl + inr

private def slice (W : Submodule K (V × V)) (f : V →ₗ[K] V × V) : Submodule K V := W.comap f

private def liftTwo (W : Submodule K (V × V))
  (f g : V →ₗ[K] V × V) :
  (slice W f × slice W g) →ₗ[K] W where
  toFun := fun p => ⟨f p.1 + g p.2, W.add_mem p.1.property p.2.property⟩
  map_add' := by
    intro a b
    apply Subtype.ext
    simp only [map_add, Prod.fst_add, Prod.snd_add, Submodule.coe_add]
    abel
  map_smul' := by
    intro c a
    apply Subtype.ext
    simp [smul_add]

private theorem liftTwo_injective (W : Submodule K (V × V))
    (f g : V →ₗ[K] V × V)
    (hfg : ∀ a b : V, f a + g b = 0 → a = 0 ∧ b = 0) :
    Function.Injective (liftTwo W f g) := by
  intro a b hab
  have hz : liftTwo W f g (a-b) = 0 := by
    simp [map_sub, hab]
  have h0 : f (((a-b).1 : slice W f) : V) + g (((a-b).2 : slice W g) : V) = 0 :=
    congrArg Subtype.val hz
  obtain ⟨hleft, hright⟩ := hfg _ _ h0
  have hdiff : a-b=0 := by
    apply Prod.ext
    · apply Subtype.ext
      exact hleft
    · apply Subtype.ext
      exact hright
  exact sub_eq_zero.mp hdiff

private theorem inl_inr_zero (a b : V) (h : inl a + inr b = 0) : a=0 ∧ b=0 := by
  have hp : (a,b)=(0,0) := by simpa [inl, inr] using h
  exact ⟨congrArg Prod.fst hp, congrArg Prod.snd hp⟩

private theorem inl_diag_zero (a b : V) (h : inl a + diag b = 0) : a=0 ∧ b=0 := by
  have hp : (a+b,b)=(0,0) := by simpa [diag, inl, inr] using h
  have hb : b=0 := congrArg Prod.snd hp
  constructor
  · have ha := congrArg Prod.fst hp
    simpa [hb] using ha
  · exact hb

private theorem inr_diag_zero (a b : V) (h : inr a + diag b = 0) : a=0 ∧ b=0 := by
  have hp : (b,a+b)=(0,0) := by simpa [diag, inl, inr] using h
  have hb : b=0 := congrArg Prod.fst hp
  constructor
  · have ha := congrArg Prod.snd hp
    simpa [hb] using ha
  · exact hb

private theorem slice_rank_pairs [FiniteDimensional K V]
    (W : Submodule K (V × V)) :
    Module.finrank K (slice W inl) + Module.finrank K (slice W inr) ≤ Module.finrank K W ∧
    Module.finrank K (slice W inl) + Module.finrank K (slice W diag) ≤ Module.finrank K W ∧
    Module.finrank K (slice W inr) + Module.finrank K (slice W diag) ≤ Module.finrank K W := by
  constructor
  · simpa [Module.finrank_prod] using
      (liftTwo W inl inr).finrank_le_finrank_of_injective
        (liftTwo_injective W inl inr inl_inr_zero)
  constructor
  · simpa [Module.finrank_prod] using
      (liftTwo W inl diag).finrank_le_finrank_of_injective
        (liftTwo_injective W inl diag inl_diag_zero)
  · simpa [Module.finrank_prod] using
      (liftTwo W inr diag).finrank_le_finrank_of_injective
        (liftTwo_injective W inr diag inr_diag_zero)


/-! ## Uniform row-count recursion for every submodule -/

private noncomputable def rowHits {T : Type*} [AddCommGroup T] [Module K T]
    (R : Finset T) (W : Submodule K T) : Nat := by
  classical
  exact (R.filter fun r => r ∈ W).card

private def rowsUp (R : Finset V) : Finset (V × V) :=
  (R.image inl ∪ R.image inr) ∪ R.image diag

private theorem hits_image_le (R : Finset V) (W : Submodule K (V × V))
    (f : V →ₗ[K] V × V) :
    rowHits (R.image f) W ≤ rowHits R (slice W f) := by
  classical
  change ((R.image f).filter fun x => x ∈ W).card ≤
    (R.filter fun x => f x ∈ W).card
  rw [Finset.filter_image]
  exact Finset.card_image_le

private theorem hits_union_le {T : Type*} [AddCommGroup T] [Module K T]
    (R S : Finset T) (W : Submodule K T) :
    rowHits (R ∪ S) W ≤ rowHits R W + rowHits S W := by
  classical
  change ((R ∪ S).filter fun x => x ∈ W).card ≤
    (R.filter fun x => x ∈ W).card + (S.filter fun x => x ∈ W).card
  rw [Finset.filter_union]
  exact Finset.card_union_le _ _

private theorem hits_step_le (R : Finset V) (W : Submodule K (V × V)) :
    rowHits (rowsUp R) W ≤ rowHits R (slice W inl) +
      rowHits R (slice W inr) + rowHits R (slice W diag) := by
  have h1 := hits_union_le (R.image inl ∪ R.image inr) (R.image diag) W
  have h2 := hits_union_le (R.image inl) (R.image inr) W
  have h3 := hits_image_le R W inl
  have h4 := hits_image_le R W inr
  have h5 := hits_image_le R W diag
  change rowHits ((R.image inl ∪ R.image inr) ∪ R.image diag) W ≤ _ 
  omega

private def cap0 (q : Nat) : Nat := if q = 0 then 0 else 1
private def cap1 (q : Nat) : Nat :=
  if q = 0 then 0 else if q = 1 then 1 else 3
private def cap2 (q : Nat) : Nat :=
  if q = 0 then 0 else if q = 1 then 1 else
    if q = 2 then 3 else if q = 3 then 5 else 9
private def cap3 (q : Nat) : Nat :=
  if q = 0 then 0 else if q = 1 then 1 else if q = 2 then 3 else
    if q = 3 then 5 else if q = 4 then 9 else if q = 5 then 11 else
      if q = 6 then 15 else if q = 7 then 19 else 27

private theorem arithmetic_1 :
    ∀ q : Fin 3, ∀ a b c : Fin 2,
      a.val + b.val ≤ q.val → a.val + c.val ≤ q.val →
      b.val + c.val ≤ q.val →
      cap0 a.val + cap0 b.val + cap0 c.val ≤ cap1 q.val := by decide

private theorem arithmetic_2 :
    ∀ q : Fin 5, ∀ a b c : Fin 3,
      a.val + b.val ≤ q.val → a.val + c.val ≤ q.val →
      b.val + c.val ≤ q.val →
      cap1 a.val + cap1 b.val + cap1 c.val ≤ cap2 q.val := by decide

private theorem arithmetic_3 :
    ∀ q : Fin 9, ∀ a b c : Fin 5,
      a.val + b.val ≤ q.val → a.val + c.val ≤ q.val →
      b.val + c.val ≤ q.val →
      cap2 a.val + cap2 b.val + cap2 c.val ≤ cap3 q.val := by decide

private abbrev E0 := K
private abbrev E1 := E0 × E0
private abbrev E2 := E1 × E1
private abbrev E3 := E2 × E2

private def R0 : Finset E0 := {1}
private def R1 : Finset E1 := rowsUp R0
private def R2 : Finset E2 := rowsUp R1
private def R3 : Finset E3 := rowsUp R2

private theorem rank_base0 (W : Submodule K E0) :
    rowHits R0 W ≤ cap0 (Module.finrank K W) := by
  classical
  by_cases h : (1 : E0) ∈ W
  · have hneq : W ≠ ⊥ := by
      intro he
      simp [he] at h
    have hr : 0 < Module.finrank K W :=
      (Submodule.one_le_finrank_iff.mpr hneq)
    simp [rowHits, R0, h, cap0, Nat.ne_of_gt hr]
  · simp [rowHits, R0, h]

#print axioms Nightfall.StructuralInformation.SubcubeAllSpacesL3.hits_step_le
#print axioms Nightfall.StructuralInformation.SubcubeAllSpacesL3.rank_base0

#print axioms Nightfall.StructuralInformation.SubcubeAllSpacesL3.slice_rank_pairs

end Nightfall.StructuralInformation.SubcubeAllSpacesL3
