import AllOrderPaddedFiber

namespace Nightfall.AllOrder.Geometry
open Finset
variable {I J K : Type*} [Fintype I] [DecidableEq I] [Fintype J] [DecidableEq J] [Fintype K] [DecidableEq K]

/-- Dummy labels are isolated; nonzero labels are joined by Hamming proximity. -/
noncomputable def nearOption (r : ℕ) (u v : Label J K) : Prop :=
  match u,v with
  | some a, some b => ham a b ≤ r
  | _,_ => False

theorem nearOption_symm (r : ℕ) (u v : Label J K) (h : nearOption r u v) : nearOption r v u := by
  cases u <;> cases v <;> simp [nearOption,ham_symm] at h ⊢ <;> assumption

noncomputable def optionGraph (a : I → Label J K) (r : ℕ) : SimpleGraph I where
  Adj i j := i ≠ j ∧ nearOption r (a i) (a j)
  symm := by constructor; intro i j h; exact ⟨Ne.symm h.1,nearOption_symm _ _ _ h.2⟩
  loopless := by constructor; intro i h; exact h.1 rfl

noncomputable def compSlots (a : I → Label J K) (r : ℕ) (i : I) : Finset I := by
  classical
  exact univ.filter (fun j => (optionGraph a r).connectedComponentMk j = (optionGraph a r).connectedComponentMk i)

noncomputable def compSum (a : I → Label J K) (r : ℕ) (i : I) : Tensor J K := ∑ j ∈ compSlots a r i, optionLabel (a j)

noncomputable def keepSet (a : I → Label J K) (r : ℕ) : Finset I := by
  classical
  exact univ.filter (fun i => (a i).isSome ∧ compSum a r i ≠ 0)

noncomputable def pad (a : I → Label J K) (U : Finset I) (i : I) : Label J K :=
  if i ∈ U then a i else none

theorem compSlots_eq (a : I → Label J K) (r : ℕ) (i j : I)
    (h : (optionGraph a r).connectedComponentMk i = (optionGraph a r).connectedComponentMk j) :
    compSlots a r i = compSlots a r j := by
  classical
  unfold compSlots
  rw [h]

theorem keep_adj_closed (a : I → Label J K) (r : ℕ) (i j : I) (hi : i ∈ keepSet a r)
    (h : (optionGraph a r).Adj i j) : j ∈ keepSet a r := by
  classical
  have hcomp := SimpleGraph.ConnectedComponent.sound h.reachable
  have hsum : compSum a r i = compSum a r j := by unfold compSum; rw [compSlots_eq a r i j hcomp]
  have hs : (a j).isSome := by
    have hn := h.2
    cases ha : a i <;> cases hb : a j <;> simp [nearOption,ha,hb] at hn ⊢
  exact Finset.mem_filter.mpr ⟨Finset.mem_univ _,hs,hsum ▸ (Finset.mem_filter.mp hi).2.2⟩

theorem keep_reachable_closed (a : I → Label J K) (r : ℕ) {i j : I}
    (h : (optionGraph a r).Reachable i j) (hi : i ∈ keepSet a r) : j ∈ keepSet a r := by
  obtain ⟨w⟩ := h
  induction w with
  | nil => exact hi
  | cons h w ih => exact ih (keep_adj_closed a r _ _ hi h)

theorem pad_active_iff (a : I → Label J K) (r : ℕ) (i : I) :
    (pad a (keepSet a r) i).isSome ↔ i ∈ keepSet a r := by
  classical
  by_cases hi : i ∈ keepSet a r
  · simp [pad,hi,(Finset.mem_filter.mp hi).2.1]
  · simp [pad,hi]

theorem pad_freq (a : I → Label J K) (r : ℕ) :
    (∑ i, optionLabel (pad a (keepSet a r) i)) = ∑ i, optionLabel (a i) := by
  classical
  let g := optionGraph a r
  let C := g.ConnectedComponent
  let comp := g.connectedComponentMk
  letI : Fintype C := Fintype.ofFinite C
  rw [← Finset.sum_fiberwise (univ : Finset I) comp (fun i => optionLabel (pad a (keepSet a r) i)),
    ← Finset.sum_fiberwise (univ : Finset I) comp (fun i => optionLabel (a i))]
  apply Finset.sum_congr rfl
  intro c _
  let S := univ.filter (fun i => comp i = c)
  change ∑ i ∈ S, optionLabel (pad a (keepSet a r) i) = ∑ i ∈ S, optionLabel (a i)
  have hS (i : I) (hi : i ∈ S) : compSlots a r i = S := by
    unfold compSlots
    change univ.filter (fun j => comp j = comp i) = S
    rw [(Finset.mem_filter.mp hi).2]
  by_cases hz : (∑ i ∈ S, optionLabel (a i)) = 0
  · rw [hz]
    apply Finset.sum_eq_zero
    intro i hi
    have hsum : compSum a r i = 0 := by unfold compSum; rw [hS i hi,hz]
    have hn : i ∉ keepSet a r := fun h => (Finset.mem_filter.mp h).2.2 hsum
    simp [pad,hn,optionLabel]
  · apply Finset.sum_congr rfl
    intro i hi
    have hsum : compSum a r i ≠ 0 := by unfold compSum; rw [hS i hi]; exact hz
    by_cases hn : (a i).isSome
    · have hk : i ∈ keepSet a r := Finset.mem_filter.mpr ⟨Finset.mem_univ _,hn,hsum⟩
      simp [pad,hk]
    · have he : a i = none := by cases h : a i <;> simp [h] at hn ⊢
      simp [pad,he,optionLabel]

section Reach
variable (a : I → Label J K) (r : ℕ)
local notation "b" => pad a (keepSet a r)
local notation "G" => optionGraph a r
local notation "H" => nearGraph (actualRow b) r

theorem active_adj_iff (i j : Active b) : (H).Adj i j ↔ (G).Adj i.val j.val := by
  classical
  have hi := (pad_active_iff a r i.val).mp i.property
  have hj := (pad_active_iff a r j.val).mp j.property
  have hei : a i.val = some (actualRow b i) := by
    have h := (actualRow_some b i).symm
    simpa [pad,hi] using h
  have hej : a j.val = some (actualRow b j) := by
    have h := (actualRow_some b j).symm
    simpa [pad,hj] using h
  change (i ≠ j ∧ ham (actualRow b i) (actualRow b j) ≤ r) ↔
    (i.val ≠ j.val ∧ nearOption r (a i.val) (a j.val))
  rw [hei,hej]
  change _ ↔ (i.val ≠ j.val ∧ ham (actualRow b i) (actualRow b j) ≤ r)
  exact and_congr (not_congr Subtype.ext_iff) Iff.rfl

theorem active_walk_to_full {i j : Active b} (w : (H).Walk i j) : (G).Reachable i.val j.val := by
  induction w with
  | nil => exact SimpleGraph.Reachable.refl _
  | cons h w ih => exact (SimpleGraph.Adj.reachable ((active_adj_iff a r _ _).mp h)).trans ih

theorem full_walk_to_active {i j : I} (w : (G).Walk i j) (hi : (b i).isSome) :
    ∃ hj : (b j).isSome, (H).Reachable ⟨i,hi⟩ ⟨j,hj⟩ := by
  induction w with
  | nil => exact ⟨hi,SimpleGraph.Reachable.refl _⟩
  | @cons i k j h w ih =>
    have hk : (b k).isSome := (pad_active_iff a r k).mpr
      (keep_adj_closed a r i k ((pad_active_iff a r i).mp hi) h)
    obtain ⟨hj,hr⟩ := ih hk
    exact ⟨hj, (SimpleGraph.Adj.reachable ((active_adj_iff a r ⟨i,hi⟩ ⟨k,hk⟩).mpr h)).trans hr⟩

theorem active_component_iff (i j : Active b) :
    (H).connectedComponentMk i = (H).connectedComponentMk j ↔ (G).connectedComponentMk i.val = (G).connectedComponentMk j.val := by
  constructor
  · intro h
    obtain ⟨w⟩ := SimpleGraph.ConnectedComponent.exact h
    exact SimpleGraph.ConnectedComponent.sound (active_walk_to_full a r w)
  · intro h
    obtain ⟨w⟩ := SimpleGraph.ConnectedComponent.exact h
    obtain ⟨hj,hr⟩ := full_walk_to_active a r w i.property
    exact SimpleGraph.ConnectedComponent.sound hr

/-- Exact contraction preserves only the genuinely active nonzero components. -/
theorem pad_good : paddedGood b r := by
  classical
  unfold paddedGood activeGood
  intro i
  have hi := (pad_active_iff a r i.val).mp i.property
  have hn : compSum a r i.val ≠ 0 := (Finset.mem_filter.mp hi).2.2
  have he : (∑ j ∈ univ.filter (fun j : Active b => (H).connectedComponentMk j = (H).connectedComponentMk i),
      tensorLabel (actualRow b j)) = compSum a r i.val := by
    unfold compSum
    apply Finset.sum_bij (fun j _ => j.val)
    · intro j hj
      exact Finset.mem_filter.mpr ⟨Finset.mem_univ _,(active_component_iff a r j i).mp (Finset.mem_filter.mp hj).2⟩
    · intro j hj k hk he
      exact Subtype.ext he
    · intro j hj
      have hcomp : (G).connectedComponentMk j = (G).connectedComponentMk i.val := (Finset.mem_filter.mp hj).2
      have hjkeep := keep_reachable_closed a r (SimpleGraph.ConnectedComponent.exact hcomp.symm) hi
      let j' : Active b := ⟨j,(pad_active_iff a r j).mpr hjkeep⟩
      exact ⟨j',Finset.mem_filter.mpr ⟨Finset.mem_univ _,(active_component_iff a r j' i).mpr hcomp⟩,rfl⟩
    · intro j hj
      have hjkeep := (pad_active_iff a r j.val).mp j.property
      have h := actualRow_some b j
      rw [pad,if_pos hjkeep] at h
      rw [← h]
      rfl
  rw [he]
  exact hn
end Reach

#print axioms pad_freq
#print axioms active_component_iff
#print axioms pad_good
end Nightfall.AllOrder.Geometry
