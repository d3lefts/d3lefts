import SubcubeSecantSlices
import SubcubeAffineAllLevels

set_option maxRecDepth 12000
set_option maxHeartbeats 3000000

namespace Nightfall.StructuralInformation.SubcubeSecantMixed

open Nightfall.StructuralInformation.SubcubeAllSpacesL3

variable {V : Type*} [AddCommGroup V] [Module K V] [DecidableEq V]

private theorem bounded_fibers {α β : Type*} [DecidableEq β]
    (S : Finset α) (T : Finset β) (f : α → β) (m : Nat)
    (hmap : ∀ x ∈ S, f x ∈ T)
    (hfiber : ∀ b ∈ T, (S.filter fun x => f x = b).card ≤ m) :
    S.card ≤ T.card * m := by
  have hm : (S : Set α).MapsTo f T := fun x hx => hmap x hx
  rw [Finset.card_eq_sum_card_fiberwise hm]
  calc
    (∑ b ∈ T, (S.filter fun x => f x = b).card) ≤
      ∑ _b ∈ T, m := Finset.sum_le_sum (fun b hb => hfiber b hb)
    _ = T.card * m := by simp

/-- The mixed product of tensor row sets has a quartic finite-rank
    intersection bound. This is the new combinatorial kernel gate. -/
theorem mixed_product_bound [FiniteDimensional K V]
    (R : Finset V)
    (hlinear : ∀ P : Submodule K V,
      rowHits R P ≤ (Module.finrank K P) * (Module.finrank K P))
    (haffine : ∀ (Q : Submodule K V) (a : V),
      (R.filter fun s => s - a ∈ Q).card ≤
      (Module.finrank K Q + 1) * (Module.finrank K Q + 1))
    (U : Submodule K (V × V)) :
    rowHits (R.product R) U ≤ 4 * (Module.finrank K U)^4 := by
  classical
  let q := Module.finrank K U
  let P : Submodule K V := U.map (LinearMap.fst K V V)
  let Q : Submodule K V := slice U inr
  let S : Finset (V × V) := (R.product R).filter fun p => p ∈ U
  let T : Finset V := R.filter fun r => r ∈ P
  have hp : Module.finrank K P ≤ q := by
    calc
      Module.finrank K P ≤ Module.finrank K U :=
        Submodule.finrank_map_le (LinearMap.fst K V V) U
      _ = q := rfl
  have hk : Module.finrank K Q ≤ q := by
    have h := (slice_rank_pairs U).1
    change Module.finrank K (slice U inl) + Module.finrank K Q ≤ q at h
    omega
  have hm : ∀ p ∈ S, p.1 ∈ T := by
    intro p hmem
    obtain ⟨hpr, hU⟩ := Finset.mem_filter.mp hmem
    have hr : p.1 ∈ R := (Finset.mem_product.mp hpr).1
    have hp0 : p.1 ∈ P := by
      change p.1 ∈ U.map (LinearMap.fst K V V)
      exact ⟨p, hU, rfl⟩
    exact Finset.mem_filter.mpr ⟨hr, hp0⟩
  have hfib : ∀ r ∈ T, (S.filter fun p => p.1 = r).card ≤
      (q+1) * (q+1) := by
    intro r hr
    by_cases hex : (S.filter fun p => p.1 = r).Nonempty
    · obtain ⟨p0, hp0⟩ := hex
      have hp0U : p0 ∈ U :=
        (Finset.mem_filter.mp (Finset.mem_filter.mp hp0).1).2
      have hp0r : p0.1 = r := (Finset.mem_filter.mp hp0).2
      let T0 : Finset V := R.filter fun s => s - p0.2 ∈ Q
      have hmap0 : Set.MapsTo Prod.snd
          (S.filter fun p => p.1 = r) T0 := by
        intro p hmem
        obtain ⟨hpS, hpr⟩ := Finset.mem_filter.mp hmem
        obtain ⟨hpR, hpU⟩ := Finset.mem_filter.mp hpS
        have hs : p.2 ∈ R := (Finset.mem_product.mp hpR).2
        have hfst : p.1 = p0.1 := hpr.trans hp0r.symm
        have hsub : p - p0 ∈ U := U.sub_mem hpU hp0U
        have hpair : (p.1 - p0.1, p.2 - p0.2) ∈ U := by
          simpa [Prod.mk_sub_mk] using hsub
        have hvertical : (0, p.2 - p0.2) ∈ U := by
          simpa [sub_eq_zero.mpr hfst] using hpair
        exact Finset.mem_filter.mpr ⟨hs, hvertical⟩
      have hinj : Set.InjOn Prod.snd
          (S.filter fun p => p.1 = r) := by
        intro p hp p' hp' hsecond
        have hfirst : p.1 = p'.1 :=
          (Finset.mem_filter.mp hp).2.trans (Finset.mem_filter.mp hp').2.symm
        exact Prod.ext hfirst hsecond
      have hc : (S.filter fun p => p.1 = r).card ≤ T0.card :=
        Finset.card_le_card_of_injOn Prod.snd hmap0 hinj
      have ha : T0.card ≤ (Module.finrank K Q + 1) *
          (Module.finrank K Q + 1) := haffine Q p0.2
      have hb : (Module.finrank K Q + 1) *
          (Module.finrank K Q + 1) ≤ (q + 1)*(q + 1) :=
        Nat.mul_le_mul (Nat.add_le_add_right hk 1) (Nat.add_le_add_right hk 1)
      exact hc.trans (ha.trans hb)
    · have he : (S.filter fun p => p.1 = r) = ∅ :=
        Finset.not_nonempty_iff_eq_empty.mp hex
      simp [he]
  have hS : S.card ≤ T.card * ((q+1)*(q+1)) :=
    bounded_fibers S T Prod.fst ((q+1)*(q+1)) hm hfib
  have hT : T.card ≤ q*q := by
    have h := hlinear P
    have hh : T.card ≤ (Module.finrank K P) * (Module.finrank K P) := h
    exact hh.trans (Nat.mul_le_mul hp hp)
  have hSB : S.card ≤ q*q * ((q+1)*(q+1)) :=
    hS.trans (Nat.mul_le_mul_right _ hT)
  have hpoly : q*q * ((q+1)*(q+1)) ≤ 4*q^4 := by
    by_cases hq : q = 0
    · simp [hq]
    · have hq1 : 1 ≤ q := Nat.one_le_iff_ne_zero.mpr hq
      have h2 : q+1 ≤ 2*q := by omega
      have hsq : (q+1)*(q+1) ≤ (2*q)*(2*q) :=
        Nat.mul_le_mul h2 h2
      calc
        q*q*((q+1)*(q+1)) ≤ q*q*((2*q)*(2*q)) :=
          Nat.mul_le_mul_left _ hsq
        _ = 4*q^4 := by ring
  change S.card ≤ 4*q^4
  exact hSB.trans hpoly

#print axioms Nightfall.StructuralInformation.SubcubeSecantMixed.mixed_product_bound

end Nightfall.StructuralInformation.SubcubeSecantMixed
