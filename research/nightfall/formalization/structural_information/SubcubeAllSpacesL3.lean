import Mathlib

set_option maxRecDepth 10000
set_option maxHeartbeats 3000000

namespace Nightfall.StructuralInformation.SubcubeAllSpacesL3

abbrev K := ZMod 2

variable {V : Type*} [AddCommGroup V] [Module K V] [DecidableEq V]

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

noncomputable def rowHits {T : Type*} [AddCommGroup T] [Module K T]
    (R : Finset T) (W : Submodule K T) : Nat := by
  classical
  exact (R.filter fun r => r ∈ W).card

def rowsUp (R : Finset V) : Finset (V × V) :=
  (R.image inl ∪ R.image inr) ∪ R.image diag

private theorem hits_image_le (R : Finset V) (W : Submodule K (V × V))
    (f : V →ₗ[K] V × V) :
    rowHits (R.image f) W ≤ rowHits R (slice W f) := by
  classical
  change ((R.image f).filter fun x => x ∈ W).card ≤
    (R.filter fun x => f x ∈ W).card
  rw [Finset.filter_image]
  exact Finset.card_image_le

private theorem hits_union_le {T : Type*} [AddCommGroup T] [Module K T] [DecidableEq T]
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

def cap0 (q : Nat) : Nat := if q = 0 then 0 else 1
def cap1 (q : Nat) : Nat :=
  if q = 0 then 0 else if q = 1 then 1 else 3
def cap2 (q : Nat) : Nat :=
  if q = 0 then 0 else if q = 1 then 1 else
    if q = 2 then 3 else if q = 3 then 5 else 9
def cap3 (q : Nat) : Nat :=
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

abbrev E0 := K
abbrev E1 := E0 × E0
abbrev E2 := E1 × E1
abbrev E3 := E2 × E2

def R0 : Finset E0 := {1}
def R1 : Finset E1 := rowsUp R0
def R2 : Finset E2 := rowsUp R1
def R3 : Finset E3 := rowsUp R2

private theorem rank_base0 (W : Submodule K E0) :
    rowHits R0 W ≤ cap0 (Module.finrank K W) := by
  classical
  by_cases h : (1 : E0) ∈ W
  · have hr : 0 < Module.finrank K W := by
      apply Module.finrank_pos_iff_exists_ne_zero.mpr
      refine ⟨⟨1, h⟩, ?_⟩
      intro he
      have hzero : (1 : E0) = 0 := congrArg Subtype.val he
      exact (by decide : (1 : E0) ≠ 0) hzero
    have hcount : rowHits R0 W ≤ 1 := by
      change ((R0.filter fun r => r ∈ W)).card ≤ 1
      calc
        _ ≤ R0.card := Finset.card_filter_le _ _
        _ = 1 := by decide
    simpa [cap0, Nat.ne_of_gt hr] using hcount
  · have hz : rowHits R0 W = 0 := by
      unfold rowHits
      rw [Finset.card_eq_zero]
      apply Finset.filter_eq_empty_iff.mpr
      intro x hR hW
      have heq : x = (1 : E0) := by simpa [R0] using hR
      subst x
      exact h hW
    rw [hz]
    exact Nat.zero_le _

#print axioms Nightfall.StructuralInformation.SubcubeAllSpacesL3.hits_step_le
#print axioms Nightfall.StructuralInformation.SubcubeAllSpacesL3.rank_base0


/-! ## Generic certified propagation from every W in V to every W in V × V. -/
private theorem lift_bound [FiniteDimensional K V]
    (R : Finset V) (f g : Nat → Nat) (d : Nat)
    (hDim : Module.finrank K V = d)
    (hPrev : ∀ W : Submodule K V, rowHits R W ≤ f (Module.finrank K W))
    (hArith : ∀ q : Fin (2*d+1), ∀ a b c : Fin (d+1),
      a.val+b.val ≤ q.val → a.val+c.val ≤ q.val →
      b.val+c.val ≤ q.val →
      f a.val + f b.val + f c.val ≤ g q.val)
    (W : Submodule K (V × V)) :
    rowHits (rowsUp R) W ≤ g (Module.finrank K W) := by
  let q := Module.finrank K W
  let a := Module.finrank K (slice W inl)
  let b := Module.finrank K (slice W inr)
  let c := Module.finrank K (slice W diag)
  have hq : q ≤ 2*d := by
    calc
      q ≤ Module.finrank K (V × V) := W.finrank_le
      _ = d+d := by rw [Module.finrank_prod, hDim]
      _ = 2*d := by omega
  have ha : a ≤ d := by
    calc
      a ≤ Module.finrank K V := (slice W inl).finrank_le
      _ = d := hDim
  have hb : b ≤ d := by
    calc
      b ≤ Module.finrank K V := (slice W inr).finrank_le
      _ = d := hDim
  have hc : c ≤ d := by
    calc
      c ≤ Module.finrank K V := (slice W diag).finrank_le
      _ = d := hDim
  obtain ⟨h01,h02,h12⟩ := slice_rank_pairs W
  have hScalar : f a + f b + f c ≤ g q :=
    hArith ⟨q, by omega⟩ ⟨a,by omega⟩ ⟨b,by omega⟩ ⟨c,by omega⟩ h01 h02 h12
  have hRow := hits_step_le R W
  have hA := hPrev (slice W inl)
  have hB := hPrev (slice W inr)
  have hC := hPrev (slice W diag)
  have hScalar' :
      f (Module.finrank K (slice W inl)) +
      f (Module.finrank K (slice W inr)) +
      f (Module.finrank K (slice W diag)) ≤
      g (Module.finrank K W) := hScalar
  omega

/-- Every linear subspace of F₂² satisfies the exact 0,1,3 intersection cap. -/
theorem subcube_all_W_L1 (W : Submodule K E1) :
    rowHits R1 W ≤ cap1 (Module.finrank K W) := by
  exact lift_bound R0 cap0 cap1 1 (by simp [E0]) rank_base0 arithmetic_1 W

/-- Every linear subspace of F₂⁴ satisfies the exact 0,1,3,5,9 intersection cap. -/
theorem subcube_all_W_L2 (W : Submodule K E2) :
    rowHits R2 W ≤ cap2 (Module.finrank K W) := by
  exact lift_bound R1 cap1 cap2 2
    (by simp [E1, E0, Module.finrank_prod]) subcube_all_W_L1 arithmetic_2 W

/-- Every linear subspace of F₂⁸ satisfies the exact rank-indexed cap:
    q=0..8 ↦ 0,1,3,5,9,11,15,19,27.
    This quantifies over ALL subspaces W, not only coordinate or sampled spaces. -/
theorem subcube_all_W_L3 (W : Submodule K E3) :
    rowHits R3 W ≤ cap3 (Module.finrank K W) := by
  exact lift_bound R2 cap2 cap3 4
    (by simp [E2, E1, E0, Module.finrank_prod]) subcube_all_W_L2 arithmetic_3 W

#print axioms Nightfall.StructuralInformation.SubcubeAllSpacesL3.subcube_all_W_L1
#print axioms Nightfall.StructuralInformation.SubcubeAllSpacesL3.subcube_all_W_L2
#print axioms Nightfall.StructuralInformation.SubcubeAllSpacesL3.subcube_all_W_L3

#print axioms Nightfall.StructuralInformation.SubcubeAllSpacesL3.slice_rank_pairs

end Nightfall.StructuralInformation.SubcubeAllSpacesL3
