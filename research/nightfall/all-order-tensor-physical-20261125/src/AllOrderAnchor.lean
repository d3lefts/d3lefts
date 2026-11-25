import AllOrderCore
import Mathlib.Data.Fintype.Sum

namespace Nightfall.AllOrder
open Finset

variable {I J A C G : Type*} [Fintype I] [Fintype J] [DecidableEq I] [DecidableEq J]
  [DecidableEq C] [AddCommGroup G]

/-- Direct active-fiber anchor: compare whole equal-frequency tuples. If every
    short minimal zero-sum circuit is local, a nonzero component of the first
    tuple must have a near contact with a row of the reference tuple.
    No independent reference representation or symmetric difference is needed. -/
theorem nonzero_component_anchor (label : A → G) (a : I → A) (b : J → A)
    (near : A → A → Prop) (comp : I → C) (c : C)
    (hlocal : ∀ E : Finset (I ⊕ J), MinimalZero (fun s => label (Sum.elim a b s)) E →
      ∀ x ∈ E, ∀ y ∈ E, near (Sum.elim a b x) (Sum.elim a b y))
    (hwithin : ∀ i j, near (a i) (a j) → comp i = comp j)
    (hz : (∑ i, label (a i)) + (∑ j, label (b j)) = 0)
    (hnonzero : (∑ i ∈ univ.filter (fun i => comp i = c), label (a i)) ≠ 0) :
    ∃ i : I, comp i = c ∧ ∃ j : J, near (a i) (b j) := by
  classical
  by_contra hno
  push_neg at hno
  let mark : I ⊕ J → Bool := Sum.elim (fun i => decide (comp i = c)) (fun _ => false)
  let z : I ⊕ J → G := fun s => label (Sum.elim a b s)
  have hloc : ∀ E : Finset (I ⊕ J), MinimalZero z E → ∃ t, ∀ x ∈ E, mark x = t := by
    intro E hE
    by_cases he : ∃ i : I, Sum.inl i ∈ E ∧ comp i = c
    · obtain ⟨i,hi,hic⟩ := he
      refine ⟨true, ?_⟩
      intro x hx
      cases x with
      | inl k =>
        have h := hwithin i k (hlocal E hE (.inl i) hi (.inl k) hx)
        simp [mark, ← h, hic]
      | inr j => exact False.elim (hno i hic j (hlocal E hE (.inl i) hi (.inr j) hx))
    · refine ⟨false, ?_⟩
      intro x hx
      cases x with
      | inl i =>
        have hc : comp i ≠ c := fun hc => he ⟨i,hx,hc⟩
        simp [mark,hc]
      | inr j => rfl
  have hall : (∑ s : I ⊕ J, z s) = 0 := by
    rw [← Finset.univ_disjSum_univ, Finset.sum_disjSum]
    exact hz
  have hzero := zero_sum_each_component z mark hloc univ hall true
  apply hnonzero
  rw [Finset.sum_filter, ← Finset.univ_disjSum_univ, Finset.sum_disjSum] at hzero
  simpa [mark,z,Finset.sum_filter] using hzero

#print axioms nonzero_component_anchor
end Nightfall.AllOrder
