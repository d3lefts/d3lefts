import SubcubeSecantMixed
import SubcubeSecantScalar

set_option maxRecDepth 12000
set_option maxHeartbeats 4000000

namespace Nightfall.StructuralInformation.SubcubeSecantTransfer

open Nightfall.StructuralInformation.SubcubeAllSpacesL3
open Nightfall.StructuralInformation.SubcubeAllLevels
open Nightfall.StructuralInformation.SubcubeAffineAllLevels
open Nightfall.StructuralInformation.SubcubeSecantSlices
open Nightfall.StructuralInformation.SubcubeSecantMixed

variable {V : Type*} [AddCommGroup V] [Module K V] [DecidableEq V]

/-- Count only NONZERO pair sums. The zero sum occurs in every tensor row family
    and must not be counted three times during the pure-slice induction. -/
noncomputable def nonzeroHits (R : Finset V) (W : Submodule K V) : Nat := by
  classical
  exact (R.filter fun x => x ≠ 0 ∧ x ∈ W).card

private theorem nonzeroHits_union_le (R S : Finset V) (W : Submodule K V) :
    nonzeroHits (R ∪ S) W ≤ nonzeroHits R W + nonzeroHits S W := by
  classical
  change ((R ∪ S).filter fun x => x ≠ 0 ∧ x ∈ W).card ≤
    (R.filter fun x => x ≠ 0 ∧ x ∈ W).card +
    (S.filter fun x => x ≠ 0 ∧ x ∈ W).card
  rw [Finset.filter_union]
  exact Finset.card_union_le _ _

private theorem nonzeroHits_image_le (R : Finset V) (W : Submodule K (V × V))
    (f : V →ₗ[K] V × V) :
    nonzeroHits (R.image f) W ≤ nonzeroHits R (W.comap f) := by
  classical
  change ((R.image f).filter fun x => x ≠ 0 ∧ x ∈ W).card ≤
    (R.filter fun x => x ≠ 0 ∧ f x ∈ W).card
  rw [Finset.filter_image]
  calc
    ((R.filter fun x => f x ≠ 0 ∧ f x ∈ W).image f).card ≤
      (R.filter fun x => f x ≠ 0 ∧ f x ∈ W).card := Finset.card_image_le
    _ ≤ (R.filter fun x => x ≠ 0 ∧ f x ∈ W).card := by
      apply Finset.card_le_card
      intro x hx
      obtain ⟨hr, hneq, hw⟩ := Finset.mem_filter.mp hx
      have hnot : x ≠ 0 := by
        intro hx0
        subst x
        exact hneq (map_zero f)
      exact Finset.mem_filter.mpr ⟨hr, hnot, hw⟩

/-- The pure branches of pair sums inherit NONZERO slice counts. -/
theorem nonzeroHits_up_le (R : Finset V) (W : Submodule K (V × V)) :
    nonzeroHits (rowsUp R) W ≤ nonzeroHits R (slice W inl) +
      nonzeroHits R (slice W inr) + nonzeroHits R (slice W diag) := by
  have h1 := nonzeroHits_union_le (R.image inl ∪ R.image inr) (R.image diag) W
  have h2 := nonzeroHits_union_le (R.image inl) (R.image inr) W
  have h3 := nonzeroHits_image_le R W inl
  have h4 := nonzeroHits_image_le R W inr
  have h5 := nonzeroHits_image_le R W diag
  change nonzeroHits ((R.image inl ∪ R.image inr) ∪ R.image diag) W ≤ _
  omega

private theorem nonzeroHits_le_rowHits (R : Finset V) (W : Submodule K V) :
    nonzeroHits R W ≤ rowHits R W := by
  classical
  unfold nonzeroHits rowHits
  apply Finset.card_le_card
  intro x hx
  obtain ⟨hr, _, hw⟩ := Finset.mem_filter.mp hx
  exact Finset.mem_filter.mpr ⟨hr, hw⟩

/-- Generic upper bound for an injective linear image of the mixed product. -/
theorem mixed_image_quartic [FiniteDimensional K V] (R : Finset V)
    (hlinear : ∀ P : Submodule K V,
      rowHits R P ≤ Module.finrank K P * Module.finrank K P)
    (haffine : ∀ (Q : Submodule K V) (a : V),
      affineRowHits R Q a ≤ (Module.finrank K Q + 1) *
        (Module.finrank K Q + 1))
    (W : Submodule K (V × V)) (f : (V × V) →ₗ[K] (V × V))
    (hf : Function.Injective f) :
    nonzeroHits ((R.product R).image f) W ≤
      4 * (Module.finrank K W)^4 := by
  classical
  let U : Submodule K (V × V) := W.comap f
  let g : U →ₗ[K] W where
    toFun p := ⟨f p.val, p.property⟩
    map_add' := by
      intro a b
      apply Subtype.ext
      simp
    map_smul' := by
      intro a p
      apply Subtype.ext
      simp
  have hginj : Function.Injective g := by
    intro a b hab
    apply Subtype.ext
    exact hf (congrArg Subtype.val hab)
  have hdim : Module.finrank K U ≤ Module.finrank K W :=
    g.finrank_le_finrank_of_injective hginj
  have hbase := mixed_product_bound R hlinear haffine U
  have hmono : 4 * (Module.finrank K U)^4 ≤
      4 * (Module.finrank K W)^4 := by
    gcongr
  have h1 : nonzeroHits ((R.product R).image f) W ≤
      rowHits (R.product R) U := by
    change ((R.product R).image f |>.filter
      (fun x => x ≠ 0 ∧ x ∈ W)).card ≤
      ((R.product R).filter fun x => f x ∈ W).card
    rw [Finset.filter_image]
    calc
      _ ≤ ((R.product R).filter fun x => f x ≠ 0 ∧ f x ∈ W).card :=
        Finset.card_image_le
      _ ≤ ((R.product R).filter fun x => f x ∈ W).card := by
        apply Finset.card_le_card
        intro p hp
        obtain ⟨hpr, _, hpw⟩ := Finset.mem_filter.mp hp
        exact Finset.mem_filter.mpr ⟨hpr, hpw⟩
  exact h1.trans (hbase.trans (hmono.trans_eq rfl))

def shearAC : (V × V) →ₗ[K] (V × V) where
  toFun p := (p.1 + p.2, p.2)
  map_add' := by
    intro a b
    apply Prod.ext <;> simp [add_assoc, add_comm, add_left_comm]
  map_smul' := by
    intro a p
    apply Prod.ext <;> simp [smul_add]

def shearBC : (V × V) →ₗ[K] (V × V) where
  toFun p := (p.2, p.1 + p.2)
  map_add' := by
    intro a b
    apply Prod.ext <;> simp [add_assoc, add_comm, add_left_comm]
  map_smul' := by
    intro a p
    apply Prod.ext <;> simp [smul_add]

theorem shearAC_injective : Function.Injective (shearAC (V:=V)) := by
  intro p q h
  have ha : p.1 + p.2 = q.1 + q.2 := by
    simpa [shearAC] using congrArg Prod.fst h
  have hb : p.2 = q.2 := by
    simpa [shearAC] using congrArg Prod.snd h
  apply Prod.ext
  · rw [hb] at ha
    exact add_right_cancel ha
  · exact hb

theorem shearBC_injective : Function.Injective (shearBC (V:=V)) := by
  intro p q h
  have ha : p.2 = q.2 := by
    simpa [shearBC] using congrArg Prod.fst h
  have hb : p.1 + p.2 = q.1 + q.2 := by
    simpa [shearBC] using congrArg Prod.snd h
  apply Prod.ext
  · rw [ha] at hb
    exact add_right_cancel hb
  · exact ha

/-- The six-way bound now applies with a polynomial mixed-branch correction. -/
theorem nonzero_secant_step_quartic [FiniteDimensional K V]
    (R : Finset V)
    (hlinear : ∀ P : Submodule K V,
      rowHits R P ≤ Module.finrank K P * Module.finrank K P)
    (haffine : ∀ (Q : Submodule K V) (a : V),
      affineRowHits R Q a ≤ (Module.finrank K Q + 1) *
        (Module.finrank K Q + 1))
    (W : Submodule K (V × V)) :
    nonzeroHits (pairSums (rowsUp R)) W ≤
      nonzeroHits (pairSums R) (slice W inl) +
      nonzeroHits (pairSums R) (slice W inr) +
      nonzeroHits (pairSums R) (slice W diag) +
      12 * (Module.finrank K W)^4 := by
  classical
  let S := pairSums R
  let B := R.product R
  let C := mixedAC R
  let D := mixedBC R
  let q := Module.finrank K W
  have hcover : pairSums (rowsUp R) ⊆ sixSlices R :=
    six_way_cover R
  have h0 : nonzeroHits (pairSums (rowsUp R)) W ≤
      nonzeroHits (sixSlices R) W := by
    unfold nonzeroHits
    exact Finset.card_le_card
      (Finset.filter_subset_filter _ _ hcover)
  have h1 := nonzeroHits_union_le (rowsUp S) (B ∪ (C ∪ D)) W
  have h2 := nonzeroHits_union_le B (C ∪ D) W
  have h3 := nonzeroHits_union_le C D W
  have hpure := nonzeroHits_up_le S W
  have hlin : nonzeroHits B W ≤ 4 * q^4 := by
    have h := mixed_product_bound R hlinear haffine W
    exact (nonzeroHits_le_rowHits B W).trans (by simpa [q] using h)
  have hAC : nonzeroHits C W ≤ 4 * q^4 := by
    have h := mixed_image_quartic R hlinear haffine W shearAC shearAC_injective
    simpa only [mixedAC, shearAC] using h
  have hBC : nonzeroHits D W ≤ 4 * q^4 := by
    have h := mixed_image_quartic R hlinear haffine W shearBC shearBC_injective
    simpa only [mixedBC, shearBC] using h
  change nonzeroHits (rowsUp S ∪ (B ∪ (C ∪ D))) W ≤ _ at h0
  omega

#print axioms Nightfall.StructuralInformation.SubcubeSecantTransfer.nonzeroHits_up_le
#print axioms Nightfall.StructuralInformation.SubcubeSecantTransfer.mixed_image_quartic
#print axioms Nightfall.StructuralInformation.SubcubeSecantTransfer.nonzero_secant_step_quartic

end Nightfall.StructuralInformation.SubcubeSecantTransfer
