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

#print axioms Nightfall.StructuralInformation.SubcubeAllSpacesL3.slice_rank_pairs

end Nightfall.StructuralInformation.SubcubeAllSpacesL3
