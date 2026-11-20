import SubcubeSharpAllLevels

set_option maxRecDepth 9000
set_option maxHeartbeats 4000000

namespace Nightfall.StructuralInformation.SubcubeSharpness

open Nightfall.StructuralInformation.SubcubeAllSpacesL3
open Nightfall.StructuralInformation.SubcubeAllLevels
open Nightfall.StructuralInformation.SubcubeSharpScalar
open Nightfall.StructuralInformation.SubcubeSharpAllLevels

variable {V : Type*} [AddCommGroup V] [Module K V] [DecidableEq V]

private theorem rowsUp_no_zero (R : Finset V) (h0 : (0:V) ∉ R) :
    (0 : V × V) ∉ rowsUp R := by
  intro hz
  change (0 : V × V) ∈
    ((R.image inl ∪ R.image inr) ∪ R.image diag) at hz
  rcases Finset.mem_union.mp hz with h | h
  · rcases Finset.mem_union.mp h with h | h
    · obtain ⟨r, hr, heq⟩ := Finset.mem_image.mp h
      have hr0 : r = 0 := by
        have he := congrArg Prod.fst heq
        simpa [inl] using he
      exact h0 (hr0 ▸ hr)
    · obtain ⟨r, hr, heq⟩ := Finset.mem_image.mp h
      have hr0 : r = 0 := by
        have he := congrArg Prod.snd heq
        simpa [inr] using he
      exact h0 (hr0 ▸ hr)
  · obtain ⟨r, hr, heq⟩ := Finset.mem_image.mp h
    have hr0 : r = 0 := by
      have he := congrArg Prod.fst heq
      simpa [diag, inl, inr] using he
    exact h0 (hr0 ▸ hr)

private theorem rowsUp_card (R : Finset V) (h0 : (0:V) ∉ R) :
    (rowsUp R).card = 3 * R.card := by
  classical
  let A := R.image inl
  let B := R.image inr
  let C := R.image diag
  have injA : Function.Injective (inl (V:=V)) := by
    intro a b h
    have hf := congrArg Prod.fst h
    simpa [inl] using hf
  have injB : Function.Injective (inr (V:=V)) := by
    intro a b h
    have hf := congrArg Prod.snd h
    simpa [inr] using hf
  have injC : Function.Injective (diag (V:=V)) := by
    intro a b h
    have hf := congrArg Prod.fst h
    simpa [diag, inl, inr] using hf
  have hdAB : Disjoint A B := by
    apply Finset.disjoint_left.mpr
    intro x hx hy
    obtain ⟨a,ha,hax⟩ := Finset.mem_image.mp hx
    obtain ⟨b,hb,hbx⟩ := Finset.mem_image.mp hy
    have heq : inl a = inr b := hax.trans hbx.symm
    have ha0 : a = 0 := by
      have hf := congrArg Prod.fst heq
      simpa [inl, inr] using hf
    exact h0 (ha0 ▸ ha)
  have hdAC : Disjoint A C := by
    apply Finset.disjoint_left.mpr
    intro x hx hy
    obtain ⟨a,ha,hax⟩ := Finset.mem_image.mp hx
    obtain ⟨b,hb,hbx⟩ := Finset.mem_image.mp hy
    have heq : inl a = diag b := hax.trans hbx.symm
    have hb0 : b = 0 := by
      have hf := congrArg Prod.snd heq
      simpa [inl, inr, diag] using hf.symm
    exact h0 (hb0 ▸ hb)
  have hdBC : Disjoint B C := by
    apply Finset.disjoint_left.mpr
    intro x hx hy
    obtain ⟨a,ha,hax⟩ := Finset.mem_image.mp hx
    obtain ⟨b,hb,hbx⟩ := Finset.mem_image.mp hy
    have heq : inr a = diag b := hax.trans hbx.symm
    have hb0 : b = 0 := by
      have hf := congrArg Prod.fst heq
      simpa [inl, inr, diag] using hf.symm
    exact h0 (hb0 ▸ hb)
  have hdU : Disjoint (A ∪ B) C := by
    apply Finset.disjoint_left.mpr
    intro x hx hy
    rcases Finset.mem_union.mp hx with hx | hx
    · exact (Finset.disjoint_left.mp hdAC) hx hy
    · exact (Finset.disjoint_left.mp hdBC) hx hy
  have hcA : A.card = R.card := Finset.card_image_of_injective R injA
  have hcB : B.card = R.card := Finset.card_image_of_injective R injB
  have hcC : C.card = R.card := Finset.card_image_of_injective R injC
  calc
    (rowsUp R).card = ((A ∪ B) ∪ C).card := rfl
    _ = A.card + B.card + C.card := by
        rw [Finset.card_union_of_disjoint hdU, Finset.card_union_of_disjoint hdAB]
    _ = 3 * R.card := by rw [hcA, hcB, hcC]; omega

/-- No tensor-subcube row is the zero vector at any level. -/
theorem rows_nonzero : ∀ n : Nat, (0 : E n) ∉ R n
  | 0 => by decide
  | n+1 => by
      change (0 : E n × E n) ∉ rowsUp (R n)
      exact rowsUp_no_zero (R n) (rows_nonzero n)

/-- The recursively specified tensor family contains exactly 3^L DISTINCT
    nonzero rank-one rows, for every tensor depth L. -/
theorem all_levels_cardinality : ∀ n : Nat, (R n).card = 3^n
  | 0 => by decide
  | n+1 => by
      change (rowsUp (R n)).card = 3^(n+1)
      calc
        (rowsUp (R n)).card = 3*(R n).card := rowsUp_card (R n) (rows_nonzero n)
        _ = 3^(n+1) := by rw [all_levels_cardinality n, pow_succ]; ring

/-- The full linear subspace witnesses dimension 2^L and exactly 3^L
    subcube rows. These are the matching integer extremizer parameters. -/
theorem full_space_extremizer (n : Nat) :
    Module.finrank K (⊤ : Submodule K (E n)) = 2^n ∧
    rowHits (R n) (⊤ : Submodule K (E n)) = 3^n := by
  constructor
  · rw [finrank_top, finrank_E n]
  · rw [show rowHits (R n) (⊤ : Submodule K (E n)) = (R n).card by
      classical
      simp [rowHits]]
    exact all_levels_cardinality n

#print axioms Nightfall.StructuralInformation.SubcubeSharpness.rows_nonzero
#print axioms Nightfall.StructuralInformation.SubcubeSharpness.all_levels_cardinality
#print axioms Nightfall.StructuralInformation.SubcubeSharpness.full_space_extremizer

end Nightfall.StructuralInformation.SubcubeSharpness
